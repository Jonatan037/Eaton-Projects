# ============================================
# NCM Warehouse Inventory Data Auto-Import Script
# Runs on your local PC with OneDrive sync
# Imports CSV files directly to SQL Server
# ============================================

# CONFIGURATION - Update these paths
$OneDriveCsvFolder = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - NCM Data"  # Where Power Automate exports land
$ArchiveFolder = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - NCM Data\Archived"  # Processed files go here
$LogFile = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - NCM Data\import_log.txt"

# SQL Server Configuration
$SqlServer = ".\SQLEXPRESS"  # Your SQL Server instance
$Database = "TestEngineering"
$ConnectionString = "Server=$SqlServer;Database=$Database;Integrated Security=True;Connection Timeout=60"

# Retry Configuration
$MaxRetries = 5
$RetryDelaySeconds = 30

# ============================================
# FUNCTIONS
# ============================================

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Wait-ForNetworkAndSqlServer {
    param(
        [string]$ServerName,
        [int]$MaxWaitMinutes = 10,
        [int]$CheckIntervalSeconds = 30
    )
    
    $serverHost = $ServerName.Split('\')[0]
    if ($serverHost -eq ".") { $serverHost = "localhost" }
    
    $maxAttempts = [math]::Ceiling(($MaxWaitMinutes * 60) / $CheckIntervalSeconds)
    $attempt = 0
    
    Write-Log "Waiting for network and SQL Server availability..."
    
    while ($attempt -lt $maxAttempts) {
        $attempt++
        
        # Check if SQL Server service is running (for local instances)
        if ($serverHost -eq "localhost" -or $serverHost -eq ".") {
            $sqlService = Get-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue
            if ($sqlService -and $sqlService.Status -eq "Running") {
                Write-Log "  SQL Server service is running"
                return $true
            }
            else {
                Write-Log "  SQL Server service not running (attempt $attempt of $maxAttempts)"
            }
        }
        else {
            # For remote servers, try a TCP connection test
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $tcpClient.Connect($serverHost, 1433)
                $tcpClient.Close()
                Write-Log "  SQL Server is reachable"
                return $true
            }
            catch {
                Write-Log "  Cannot reach SQL Server (attempt $attempt of $maxAttempts)"
            }
        }
        
        if ($attempt -lt $maxAttempts) {
            Write-Log "  Waiting $CheckIntervalSeconds seconds before retry..."
            Start-Sleep -Seconds $CheckIntervalSeconds
        }
    }
    
    Write-Log "  WARNING: Could not verify SQL Server availability after $MaxWaitMinutes minutes"
    return $false
}

function Open-SqlConnectionWithRetry {
    param(
        [string]$ConnString,
        [int]$Retries = $MaxRetries,
        [int]$DelaySeconds = $RetryDelaySeconds
    )
    
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $ConnString
    
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Log "  Attempting SQL connection (attempt $i of $Retries)..."
            $connection.Open()
            Write-Log "  SQL connection successful"
            return $connection
        }
        catch {
            Write-Log "  Connection attempt $i failed: $($_.Exception.Message)"
            if ($i -lt $Retries) {
                Write-Log "  Waiting $DelaySeconds seconds before retry..."
                Start-Sleep -Seconds $DelaySeconds
            }
            else {
                throw $_
            }
        }
    }
}

function Parse-CsvLine {
    param([string]$Line)
    
    $result = @()
    $inQuotes = $false
    $current = ""
    
    for ($i = 0; $i -lt $Line.Length; $i++) {
        $c = $Line[$i]
        
        if ($c -eq '"') {
            if ($inQuotes -and ($i + 1) -lt $Line.Length -and $Line[$i + 1] -eq '"') {
                $current += '"'
                $i++
            } else {
                $inQuotes = -not $inQuotes
            }
        } elseif ($c -eq ',' -and -not $inQuotes) {
            $result += $current.Trim()
            $current = ""
        } else {
            $current += $c
        }
    }
    
    $result += $current.Trim()
    return $result
}

function Parse-Decimal {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return 0 }
    $cleaned = $Value -replace '[^\d\.\-]', ''
    if ([string]::IsNullOrWhiteSpace($cleaned)) { return 0 }
    try { return [decimal]$cleaned } catch { return 0 }
}

function Parse-Int {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return 0 }
    $cleaned = $Value -replace '[^\d\-]', ''
    if ([string]::IsNullOrWhiteSpace($cleaned)) { return 0 }
    try { return [int]$cleaned } catch { return 0 }
}

function Parse-Date {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    try { return [datetime]::Parse($Value) } catch { return $null }
}

function Escape-SqlString {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return "" }
    return $Value.Trim().Replace("'", "''")
}

# Get value by header name with fallback to empty - tries multiple possible header names
function Get-ColumnValue {
    param(
        [hashtable]$HeaderMap,
        [array]$Values,
        [string[]]$PossibleNames
    )
    
    foreach ($name in $PossibleNames) {
        # Try exact match first
        if ($HeaderMap.ContainsKey($name)) {
            $idx = $HeaderMap[$name]
            if ($idx -lt $Values.Count) {
                return $Values[$idx]
            }
        }
        # Try lowercase match
        $lowerName = $name.ToLower()
        if ($HeaderMap.ContainsKey($lowerName)) {
            $idx = $HeaderMap[$lowerName]
            if ($idx -lt $Values.Count) {
                return $Values[$idx]
            }
        }
    }
    return ""
}

function Import-NCMCsvFile {
    param([string]$FilePath)
    
    $fileName = Split-Path $FilePath -Leaf
    Write-Log "Processing file: $fileName"
    
    try {
        # Read CSV file manually to handle potential formatting issues
        $lines = Get-Content -Path $FilePath -Encoding UTF8
        
        if ($lines.Count -le 1) {
            Write-Log "  No data rows in file"
            return @{ Imported = 0; Skipped = 0; Error = $null }
        }
        
        # Parse header row
        $headerLine = $lines[0]
        $headers = Parse-CsvLine -Line $headerLine
        Write-Log "  CSV has $($headers.Count) columns"
        
        # Build header index map for flexible column matching
        $headerMap = @{}
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $headerName = $headers[$i].Trim()
            $headerMap[$headerName] = $i
            # Also store lowercase version for case-insensitive matching
            $headerMap[$headerName.ToLower()] = $i
            # Store normalized version (lowercase, single spaces)
            $normalized = $headerName.ToLower() -replace '\s+', ' '
            $headerMap[$normalized] = $i
        }
        
        # Debug: Log first few headers found for troubleshooting
        $firstHeaders = ($headers | Select-Object -First 10) -join ', '
        Write-Log "  First 10 headers: $firstHeaders"
        
        # Skip header row, process data rows
        $dataRows = $lines | Select-Object -Skip 1 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        Write-Log "  Found $($dataRows.Count) rows in CSV"
        
        if ($dataRows.Count -eq 0) {
            Write-Log "  No data rows to process"
            return @{ Imported = 0; Skipped = 0; Error = $null }
        }
        
        # Connect to SQL Server with retry logic
        $connection = Open-SqlConnectionWithRetry -ConnString $ConnectionString
        
        # Get current timestamp for LoadDate
        $loadDate = Get-Date
        
        $imported = 0
        $skipped = 0
        $rowNum = 0
        
        foreach ($line in $dataRows) {
            $rowNum++
            
            try {
                # Parse CSV line
                $values = Parse-CsvLine -Line $line
                
                if ($values.Count -lt 10) { 
                    Write-Log "  Row $rowNum`: Insufficient columns ($($values.Count)), skipping"
                    $skipped++
                    continue 
                }
                
                # HEADER-BASED COLUMN MAPPING - uses header names, not positions
                # Each field tries multiple possible header names for flexibility
                
                $materialNumber = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Number", "material number", "MaterialNumber"))
                $materialDescription = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Description", "material description", "MaterialDescription", "Description"))
                $plant = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Plant", "plant"))
                $warehouseNumber = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Warehouse Number", "warehouse number", "WarehouseNumber", "Whse"))
                $stockCategory = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Stock Category", "stock category", "StockCategory"))
                $specStockIndicator = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Spec Stock Indicator", "spec stock indicator", "Spec. Stock Indicator"))
                $storageType = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Storage Type", "storage type", "StorageType"))
                $storageBin = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Storage Bin", "storage bin", "StorageBin"))
                $stdMovAvgPrice = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Std./Mov.Avg Price", "std./mov.avg price", "StdMovAvgPrice", "Price"))
                $currency = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Currency", "currency", "Curr", "Crcy"))
                $per = Parse-Int (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Per", "per", "PER"))
                $totalStock = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Total Stock", "total stock", "TotalStock"))
                $baseUoM = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Base UoM", "base uom", "BaseUoM", "UoM", "Unit"))
                $totalValue = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Total Value", "total value", "TotalValue", "Value"))
                $mrpController = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("MRP Controller", "mrp controller", "MRPController"))
                $businessUnit = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Business Unit", "business unit", "BusinessUnit"))
                $materialType = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Type", "material type", "MaterialType"))
                $profitCtr = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Profit Ctr.", "profit ctr.", "ProfitCtr", "Profit Center"))
                $cooperDivision = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Cooper Division", "cooper division", "CooperDivision"))
                $divisionText = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Division Text", "division text", "DivisionText"))
                $quant = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Quant", "quant", "Quantity"))
                $goodsReceipt = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Goods Receipt", "goods receipt", "GoodsReceipt"))
                $itemText = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Item Text", "item text", "ItemText"))
                $sLoc = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("SLoc.", "sloc.", "SLoc", "sloc", "Storage Location"))
                $invTyp = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Inv.Typ", "inv.typ", "InvTyp", "Inventory Type"))
                $sLocDesc = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Sloc.Desc", "sloc.desc", "SLocDesc", "SLoc Description"))
                $slsDoc = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Sls.Doc", "sls.doc", "SlsDoc", "Sales Doc"))
                $slsItem = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Sls.Item", "sls.item", "SlsItem", "Sales Item"))
                $specialStockNumber = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Special Stock Number", "special stock number", "SpecialStockNumber"))
                $specialStockDescription = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Special Stock Description", "special stock description", "SpecialStockDescription"))
                $safetyStock = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Safety Stock", "safety stock", "SafetyStock"))
                $prefVendNum = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Pref Vend Num", "pref vend num", "PrefVendNum", "Preferred Vendor"))
                $prefVendName = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Pref Vend Name", "pref vend name", "PrefVendName", "Vendor Name"))
                $catalogNumber = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Catalog Number", "catalog number", "CatalogNumber"))
                $materialGroup = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Group", "material group", "MaterialGroup"))
                $extMaterialGroup = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Ext.Material Group", "ext.material group", "ExtMaterialGroup"))
                $basicProdHy = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Basic Prod.Hy", "basic prod.hy", "BasicProdHy"))
                $purchasingGrp = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Purchasing Grp", "purchasing grp", "PurchasingGrp"))
                $procKey = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Proc.Key", "proc.key", "ProcKey"))
                $splProcKey = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Spl.Proc.Key", "spl.proc.key", "SplProcKey"))
                $phyInvIndCC = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Phy.Inv.IndCC", "phy.inv.indcc", "PhyInvIndCC"))
                $stockDetGroup = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Stock.Det.Group", "stock.det.group", "StockDetGroup"))
                $plantSpMatStatus = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("PlantSp.Mat.Status", "plantsp.mat.status", "PlantSpMatStatus"))
                $imUnrestStock = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("IM-Unrest.Stock", "im-unrest.stock", "IMUnrestStock", "Unrestricted Stock"))
                $imQualityInspStock = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("IM-Quality Insp. Stock", "im-quality insp. stock", "IMQualityInspStock"))
                $imBlockedStock = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("IM-Blocked Stock", "im-blocked stock", "IMBlockedStock"))
                $phyInvDate = Parse-Date (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Phy.Inv.Date", "phy.inv.date", "PhyInvDate"))
                $priceControl = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Price Control", "price control", "PriceControl"))
                $mrpCntDesc = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("MRP Cnt. Desc.", "mrp cnt. desc.", "MRPCntDesc"))
                $count = Parse-Int (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Count", "count"))
                $reserved = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Reserved", "reserved"))
                $batch = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Batch", "batch"))
                $classType = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Class Type", "class type", "ClassType"))
                $class = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Class", "class"))
                $characteristic = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Characteristic", "characteristic"))
                $characteristicValue = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Characteristic Value", "characteristic value", "CharacteristicValue"))
                $materialOrigin = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Origin", "material origin", "MaterialOrigin"))
                $materialUsage = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Material Usage", "material usage", "MaterialUsage"))
                $producedInHouse = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Produced in-house", "produced in-house", "ProducedInHouse"))
                $slsOrderDate = Parse-Date (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Sls Order Date", "sls order date", "SlsOrderDate"))
                $regionalProductHierarchy = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Regional Product hierarchy", "regional product hierarchy", "RegionalProductHierarchy"))
                $aprcCode = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("APRC Code(Product Line)", "aprc code(product line)", "APRCCode"))
                $pcode = Escape-SqlString (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Pcode(Product Family)", "pcode(product family)", "Pcode"))
                $openDeliveryQuantity = Parse-Decimal (Get-ColumnValue -HeaderMap $headerMap -Values $values -PossibleNames @("Open Delivery Quantity", "open delivery quantity", "OpenDeliveryQuantity"))
                
                # Insert record
                $insertCmd = $connection.CreateCommand()
                $insertCmd.CommandText = @"
                    INSERT INTO NCM_Warehouse_Inventory 
                    (LoadDate, MaterialNumber, MaterialDescription, CatalogNumber, Plant, WarehouseNumber, 
                     StorageType, StorageBin, SLoc, SLocDesc, InvTyp, TotalStock, BaseUoM, TotalValue, 
                     StdMovAvgPrice, Currency, Per, StockCategory, SpecStockIndicator, IMUnrestStock, 
                     IMQualityInspStock, IMBlockedStock, SafetyStock, Reserved, MRPController, MRPCntDesc, 
                     BusinessUnit, MaterialType, ProfitCtr, CooperDivision, DivisionText, MaterialGroup, 
                     ExtMaterialGroup, BasicProdHy, StockDetGroup, PlantSpMatStatus, PurchasingGrp, 
                     ProcKey, SplProcKey, PrefVendNum, PrefVendName, Quant, GoodsReceipt, ItemText, 
                     Count, OpenDeliveryQuantity, SlsDoc, SlsItem, SpecialStockNumber, SpecialStockDescription, 
                     SlsOrderDate, PhyInvIndCC, PhyInvDate, PriceControl, Batch, ClassType, Class, 
                     Characteristic, CharacteristicValue, MaterialOrigin, MaterialUsage, ProducedInHouse, 
                     RegionalProductHierarchy, APRCCode, Pcode)
                    VALUES 
                    (@LoadDate, @MaterialNumber, @MaterialDescription, @CatalogNumber, @Plant, @WarehouseNumber,
                     @StorageType, @StorageBin, @SLoc, @SLocDesc, @InvTyp, @TotalStock, @BaseUoM, @TotalValue,
                     @StdMovAvgPrice, @Currency, @Per, @StockCategory, @SpecStockIndicator, @IMUnrestStock,
                     @IMQualityInspStock, @IMBlockedStock, @SafetyStock, @Reserved, @MRPController, @MRPCntDesc,
                     @BusinessUnit, @MaterialType, @ProfitCtr, @CooperDivision, @DivisionText, @MaterialGroup,
                     @ExtMaterialGroup, @BasicProdHy, @StockDetGroup, @PlantSpMatStatus, @PurchasingGrp,
                     @ProcKey, @SplProcKey, @PrefVendNum, @PrefVendName, @Quant, @GoodsReceipt, @ItemText,
                     @Count, @OpenDeliveryQuantity, @SlsDoc, @SlsItem, @SpecialStockNumber, @SpecialStockDescription,
                     @SlsOrderDate, @PhyInvIndCC, @PhyInvDate, @PriceControl, @Batch, @ClassType, @Class,
                     @Characteristic, @CharacteristicValue, @MaterialOrigin, @MaterialUsage, @ProducedInHouse,
                     @RegionalProductHierarchy, @APRCCode, @Pcode)
"@
                # Add parameters
                $insertCmd.Parameters.AddWithValue("@LoadDate", $loadDate) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialNumber", $materialNumber) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialDescription", $materialDescription) | Out-Null
                $insertCmd.Parameters.AddWithValue("@CatalogNumber", $catalogNumber) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Plant", $plant) | Out-Null
                $insertCmd.Parameters.AddWithValue("@WarehouseNumber", $warehouseNumber) | Out-Null
                $insertCmd.Parameters.AddWithValue("@StorageType", $storageType) | Out-Null
                $insertCmd.Parameters.AddWithValue("@StorageBin", $storageBin) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SLoc", $sLoc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SLocDesc", $sLocDesc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@InvTyp", $invTyp) | Out-Null
                $insertCmd.Parameters.AddWithValue("@TotalStock", $totalStock) | Out-Null
                $insertCmd.Parameters.AddWithValue("@BaseUoM", $baseUoM) | Out-Null
                $insertCmd.Parameters.AddWithValue("@TotalValue", $totalValue) | Out-Null
                $insertCmd.Parameters.AddWithValue("@StdMovAvgPrice", $stdMovAvgPrice) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Currency", $currency) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Per", $per) | Out-Null
                $insertCmd.Parameters.AddWithValue("@StockCategory", $stockCategory) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SpecStockIndicator", $specStockIndicator) | Out-Null
                $insertCmd.Parameters.AddWithValue("@IMUnrestStock", $imUnrestStock) | Out-Null
                $insertCmd.Parameters.AddWithValue("@IMQualityInspStock", $imQualityInspStock) | Out-Null
                $insertCmd.Parameters.AddWithValue("@IMBlockedStock", $imBlockedStock) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SafetyStock", $safetyStock) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Reserved", $reserved) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MRPController", $mrpController) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MRPCntDesc", $mrpCntDesc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@BusinessUnit", $businessUnit) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialType", $materialType) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ProfitCtr", $profitCtr) | Out-Null
                $insertCmd.Parameters.AddWithValue("@CooperDivision", $cooperDivision) | Out-Null
                $insertCmd.Parameters.AddWithValue("@DivisionText", $divisionText) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialGroup", $materialGroup) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ExtMaterialGroup", $extMaterialGroup) | Out-Null
                $insertCmd.Parameters.AddWithValue("@BasicProdHy", $basicProdHy) | Out-Null
                $insertCmd.Parameters.AddWithValue("@StockDetGroup", $stockDetGroup) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PlantSpMatStatus", $plantSpMatStatus) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PurchasingGrp", $purchasingGrp) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ProcKey", $procKey) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SplProcKey", $splProcKey) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PrefVendNum", $prefVendNum) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PrefVendName", $prefVendName) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Quant", $quant) | Out-Null
                $insertCmd.Parameters.AddWithValue("@GoodsReceipt", $goodsReceipt) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ItemText", $itemText) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Count", $count) | Out-Null
                $insertCmd.Parameters.AddWithValue("@OpenDeliveryQuantity", $openDeliveryQuantity) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SlsDoc", $slsDoc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SlsItem", $slsItem) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SpecialStockNumber", $specialStockNumber) | Out-Null
                $insertCmd.Parameters.AddWithValue("@SpecialStockDescription", $specialStockDescription) | Out-Null
                if ($null -eq $slsOrderDate) {
                    $insertCmd.Parameters.AddWithValue("@SlsOrderDate", [DBNull]::Value) | Out-Null
                } else {
                    $insertCmd.Parameters.AddWithValue("@SlsOrderDate", $slsOrderDate) | Out-Null
                }
                $insertCmd.Parameters.AddWithValue("@PhyInvIndCC", $phyInvIndCC) | Out-Null
                if ($null -eq $phyInvDate) {
                    $insertCmd.Parameters.AddWithValue("@PhyInvDate", [DBNull]::Value) | Out-Null
                } else {
                    $insertCmd.Parameters.AddWithValue("@PhyInvDate", $phyInvDate) | Out-Null
                }
                $insertCmd.Parameters.AddWithValue("@PriceControl", $priceControl) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Batch", $batch) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ClassType", $classType) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Class", $class) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Characteristic", $characteristic) | Out-Null
                $insertCmd.Parameters.AddWithValue("@CharacteristicValue", $characteristicValue) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialOrigin", $materialOrigin) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialUsage", $materialUsage) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ProducedInHouse", $producedInHouse) | Out-Null
                $insertCmd.Parameters.AddWithValue("@RegionalProductHierarchy", $regionalProductHierarchy) | Out-Null
                $insertCmd.Parameters.AddWithValue("@APRCCode", $aprcCode) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Pcode", $pcode) | Out-Null
                
                $insertCmd.ExecuteNonQuery() | Out-Null
                $imported++
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-Log "  Row $rowNum`: Error - $errorMsg"
                $skipped++
            }
        }
        
        $connection.Close()
        
        Write-Log "  Imported: $imported, Skipped: $skipped"
        
        return @{ Imported = $imported; Skipped = $skipped; Error = $null }
    }
    catch {
        Write-Log "  ERROR: $_"
        return @{ Imported = 0; Skipped = 0; Error = $_.Exception.Message }
    }
}

# ============================================
# MAIN SCRIPT
# ============================================

Write-Log "=========================================="
Write-Log "NCM Warehouse Inventory Import Started"
Write-Log "=========================================="

# Wait for SQL Server to be available (important for scheduled tasks at startup)
$sqlReady = Wait-ForNetworkAndSqlServer -ServerName $SqlServer -MaxWaitMinutes 10 -CheckIntervalSeconds 30
if (-not $sqlReady) {
    Write-Log "WARNING: Proceeding despite SQL Server availability check failure"
}

# Create archive folder if it doesn't exist
if (-not (Test-Path $ArchiveFolder)) {
    New-Item -ItemType Directory -Path $ArchiveFolder -Force | Out-Null
    Write-Log "Created archive folder: $ArchiveFolder"
}

# Check if source folder exists
if (-not (Test-Path $OneDriveCsvFolder)) {
    Write-Log "ERROR: Source folder not found: $OneDriveCsvFolder"
    Write-Log "Please update the `$OneDriveCsvFolder variable in this script."
    exit 1
}

# Find CSV files (exclude archived folder)
$csvFiles = Get-ChildItem -Path $OneDriveCsvFolder -Filter "*.csv" -File | 
            Where-Object { $_.DirectoryName -notlike "*Archived*" }

if ($csvFiles.Count -eq 0) {
    Write-Log "No new CSV files found in: $OneDriveCsvFolder"
    Write-Log "Import completed - nothing to process"
    exit 0
}

Write-Log "Found $($csvFiles.Count) CSV file(s) to evaluate"

# ============================================
# PARSE DATES FROM FILENAMES AND FIND MOST RECENT
# Supports formats:
#   - Report_2026-01-15.csv
#   - PaginatedReport_2026-01-19T01_34.5537726Z.csv
# ============================================

function Get-DateFromFilename {
    param([string]$FileName)
    
    # Try pattern: PaginatedReport_2026-01-19T01_34.5537726Z.csv
    if ($FileName -match '(\d{4})-(\d{2})-(\d{2})T') {
        $year = [int]$Matches[1]
        $month = [int]$Matches[2]
        $day = [int]$Matches[3]
        return [datetime]::new($year, $month, $day)
    }
    
    # Try pattern: Report_2026-01-15.csv
    if ($FileName -match '(\d{4})-(\d{2})-(\d{2})') {
        $year = [int]$Matches[1]
        $month = [int]$Matches[2]
        $day = [int]$Matches[3]
        return [datetime]::new($year, $month, $day)
    }
    
    # Fallback: use file's last write time
    return $null
}

# Build list of files with their dates
$filesWithDates = @()
foreach ($file in $csvFiles) {
    $fileDate = Get-DateFromFilename -FileName $file.Name
    if ($null -eq $fileDate) {
        $fileDate = $file.LastWriteTime.Date
        Write-Log "  Could not parse date from '$($file.Name)', using file date: $($fileDate.ToString('yyyy-MM-dd'))"
    }
    $filesWithDates += [PSCustomObject]@{
        File = $file
        Date = $fileDate
        DateString = $fileDate.ToString('yyyy-MM-dd')
    }
}

# Sort by date descending and get the most recent
$filesWithDates = $filesWithDates | Sort-Object -Property Date -Descending

$mostRecentDate = $filesWithDates[0].Date
$mostRecentDateStr = $mostRecentDate.ToString('yyyy-MM-dd')

Write-Log "Most recent data date: $mostRecentDateStr"

# Get all files for the most recent date (there might be multiple exports on the same day)
$filesToProcess = $filesWithDates | Where-Object { $_.DateString -eq $mostRecentDateStr }
$filesToArchiveOnly = $filesWithDates | Where-Object { $_.DateString -ne $mostRecentDateStr }

# If multiple files for the same date, use the one with the latest timestamp in filename or last write time
if ($filesToProcess.Count -gt 1) {
    Write-Log "  Found $($filesToProcess.Count) files for $mostRecentDateStr - selecting the latest one"
    # Sort by LastWriteTime to get the most recent export
    $filesToProcess = $filesToProcess | Sort-Object { $_.File.LastWriteTime } -Descending | Select-Object -First 1
}

$fileToImport = $filesToProcess[0].File
Write-Log "Selected file to import: $($fileToImport.Name)"

# Archive older files without processing
if ($filesToArchiveOnly.Count -gt 0) {
    Write-Log "Archiving $($filesToArchiveOnly.Count) older file(s) without processing..."
    foreach ($oldFile in $filesToArchiveOnly) {
        $archivePath = Join-Path $ArchiveFolder $oldFile.File.Name
        if (Test-Path $archivePath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $newName = [System.IO.Path]::GetFileNameWithoutExtension($oldFile.File.Name) + "_$timestamp.csv"
            $archivePath = Join-Path $ArchiveFolder $newName
        }
        Move-Item -Path $oldFile.File.FullName -Destination $archivePath -Force
        Write-Log "  Archived (skipped): $($oldFile.File.Name) [Date: $($oldFile.DateString)]"
    }
}

# ============================================
# CLEAR EXISTING DATA AND IMPORT FRESH SNAPSHOT
# NCM data is snapshot data - we want only the latest state
# ============================================

Write-Log "Clearing existing NCM data before import (snapshot replacement)..."
try {
    $connection = Open-SqlConnectionWithRetry -ConnString $ConnectionString
    $truncateCmd = $connection.CreateCommand()
    $truncateCmd.CommandText = "TRUNCATE TABLE NCM_Warehouse_Inventory"
    $truncateCmd.ExecuteNonQuery() | Out-Null
    $connection.Close()
    Write-Log "  Existing data cleared successfully"
}
catch {
    Write-Log "  WARNING: Could not truncate table - $($_.Exception.Message)"
    Write-Log "  Proceeding with import (may result in duplicates)"
}

# Process the most recent file
$totalImported = 0
$totalSkipped = 0
$filesProcessed = 0

$result = Import-NCMCsvFile -FilePath $fileToImport.FullName

if ($null -eq $result.Error) {
    $totalImported += $result.Imported
    $totalSkipped += $result.Skipped
    $filesProcessed++
    
    # Move to archive folder
    $archivePath = Join-Path $ArchiveFolder $fileToImport.Name
    
    # If file already exists in archive, add timestamp
    if (Test-Path $archivePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $newName = [System.IO.Path]::GetFileNameWithoutExtension($fileToImport.Name) + "_$timestamp.csv"
        $archivePath = Join-Path $ArchiveFolder $newName
    }
    
    Move-Item -Path $fileToImport.FullName -Destination $archivePath -Force
    Write-Log "  Moved to archive: $archivePath"
}
else {
    Write-Log "  File NOT archived due to error"
}

Write-Log "=========================================="
Write-Log "Import Summary:"
Write-Log "  Data date imported: $mostRecentDateStr"
Write-Log "  Files processed: $filesProcessed"
Write-Log "  Files archived (older): $($filesToArchiveOnly.Count)"
Write-Log "  Records imported: $totalImported"
Write-Log "  Records skipped: $totalSkipped"
Write-Log "=========================================="

# Only prompt for key press if running interactively (not from Task Scheduler)
if ([Environment]::UserInteractive -and -not $env:TASK_SCHEDULER_RUN) {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
