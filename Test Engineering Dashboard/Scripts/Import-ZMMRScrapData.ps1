# ============================================
# ZMMR Scrap Data Auto-Import Script
# Runs on your local PC with OneDrive sync
# Imports CSV files directly to SQL Server
# ============================================

# CONFIGURATION - Update these paths
$OneDriveCsvFolder = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - SAP Scrap Data"  # Where Power BI exports land
$ArchiveFolder = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - SAP Scrap Data\Archived"  # Processed files go here
$LogFile = "C:\Users\$env:USERNAME\OneDrive - Eaton\YPO - Test Engineering Dashboard\YPO - SAP Scrap Data\import_log.txt"

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

function Import-ZMMRCsvFile {
    param([string]$FilePath)
    
    $fileName = Split-Path $FilePath -Leaf
    Write-Log "Processing file: $fileName"
    
    try {
        # Read CSV file manually (Import-Csv fails because Power BI exports duplicate "Total" columns)
        $lines = Get-Content -Path $FilePath -Encoding UTF8
        
        if ($lines.Count -le 1) {
            Write-Log "  No data rows in file"
            return @{ Imported = 0; Skipped = 0; Error = $null }
        }
        
        # Parse header row to determine column count and positions
        $headerLine = $lines[0]
        $headers = Parse-CsvLine -Line $headerLine
        Write-Log "  CSV has $($headers.Count) columns"
        
        # Skip header row, process data rows
        $dataRows = $lines | Select-Object -Skip 1 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        Write-Log "  Found $($dataRows.Count) rows in CSV"
        
        if ($dataRows.Count -eq 0) {
            Write-Log "  No data rows to process"
            return @{ Imported = 0; Skipped = 0; Error = $null }
        }
        
        # Connect to SQL Server with retry logic
        $connection = Open-SqlConnectionWithRetry -ConnString $ConnectionString
        
        # Create batch ID for this import
        $batchId = [Guid]::NewGuid().ToString()
        
        # Create import log entry
        $logCmd = $connection.CreateCommand()
        $logCmd.CommandText = @"
            IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ZMMR_ImportLog')
            BEGIN
                INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status) 
                VALUES ('$batchId', '$fileName', '$env:USERNAME', 'In Progress')
            END
"@
        try { $logCmd.ExecuteNonQuery() | Out-Null } catch { }
        
        $imported = 0
        $skipped = 0
        $rowNum = 0
        
        foreach ($line in $dataRows) {
            $rowNum++
            
            try {
                # Parse CSV line (handles quoted fields with commas)
                $values = Parse-CsvLine -Line $line
                
                if ($values.Count -lt 12) { 
                    Write-Log "  Row $rowNum`: Insufficient columns ($($values.Count)), skipping"
                    $skipped++
                    continue 
                }
                
                # Map CSV columns by index (Power BI export format - UPDATED with MRPControllerCode):
                # 0=zmmr_amount, 1=zmmr_cost_center_code, 2=zmmr_material_desc, 3=zmmr_material_number,
                # 4=zmmr_movement_type, 5=zmmr_mrp_controller_code (NEW), 6=zmmr_mrp_controller_desc, 
                # 7=zmmr_plant_code, 8=zmmr_posting_date, 9=zmmr_quantity, 10=zmmr_reason_desc, 
                # 11=zmmr_users_full_name, 12=Total, 13=Total (duplicates - ignored)
                
                # Parse amount - handle potential formatting issues
                $amountStr = $values[0] -replace '[^\d\.\-]', ''
                if ([string]::IsNullOrWhiteSpace($amountStr)) { $amountStr = "0" }
                $amount = [decimal]$amountStr
                
                $costCenter = $values[1].Trim()
                $materialDesc = $values[2].Trim().Replace("'", "''")  # Escape single quotes
                $materialNum = $values[3].Trim()
                
                # Parse movement type
                $mvtTypeStr = $values[4] -replace '[^\d]', ''
                if ([string]::IsNullOrWhiteSpace($mvtTypeStr)) { $mvtTypeStr = "0" }
                $movementType = [int]$mvtTypeStr
                
                $mrpControllerCode = $values[5].Trim()
                $mrpController = $values[6].Trim().Replace("'", "''")
                $plantCode = $values[7].Trim()
                
                # Parse posting date
                $postingDateStr = $values[8].Trim()
                $postingDate = $null
                if (-not [string]::IsNullOrWhiteSpace($postingDateStr)) {
                    try {
                        $postingDate = [datetime]::Parse($postingDateStr)
                    } catch {
                        Write-Log "  Row $rowNum`: Invalid date '$postingDateStr', skipping"
                        $skipped++
                        continue
                    }
                } else {
                    Write-Log "  Row $rowNum`: Empty posting date, skipping"
                    $skipped++
                    continue
                }
                
                # Parse quantity
                $qtyStr = $values[9] -replace '[^\d\-]', ''
                if ([string]::IsNullOrWhiteSpace($qtyStr)) { $qtyStr = "0" }
                $quantity = [int]$qtyStr
                
                $reasonDesc = $values[10].Trim().Replace("'", "''")
                $userName = $values[11].Trim().Replace("'", "''")
                
                # Insert new record - let the unique index handle duplicates
                $insertCmd = $connection.CreateCommand()
                $insertCmd.CommandText = @"
                    INSERT INTO ZMMR_ScrapData 
                    (Amount, CostCenterCode, MaterialDescription, MaterialNumber, 
                     MovementType, MRPControllerCode, MRPControllerDesc, PlantCode, PostingDate, 
                     Quantity, ReasonDescription, UserFullName, ImportFileName, ImportBatchID)
                    VALUES 
                    (@Amount, @CostCenter, @MaterialDesc, @MaterialNum,
                     @MovementType, @MRPControllerCode, @MRPController, @PlantCode, @PostingDate,
                     @Quantity, @ReasonDesc, @UserName, @FileName, @BatchID)
"@
                $insertCmd.Parameters.AddWithValue("@Amount", $amount) | Out-Null
                $insertCmd.Parameters.AddWithValue("@CostCenter", $costCenter) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialDesc", $materialDesc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MaterialNum", $materialNum) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MovementType", $movementType) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MRPControllerCode", $mrpControllerCode) | Out-Null
                $insertCmd.Parameters.AddWithValue("@MRPController", $mrpController) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PlantCode", $plantCode) | Out-Null
                $insertCmd.Parameters.AddWithValue("@PostingDate", $postingDate) | Out-Null
                $insertCmd.Parameters.AddWithValue("@Quantity", $quantity) | Out-Null
                $insertCmd.Parameters.AddWithValue("@ReasonDesc", $reasonDesc) | Out-Null
                $insertCmd.Parameters.AddWithValue("@UserName", $userName) | Out-Null
                $insertCmd.Parameters.AddWithValue("@FileName", $fileName) | Out-Null
                $insertCmd.Parameters.AddWithValue("@BatchID", $batchId) | Out-Null
                
                $insertCmd.ExecuteNonQuery() | Out-Null
                $imported++
            }
            catch {
                $errorMsg = $_.Exception.Message
                # Check if it's a duplicate key error (expected for already-imported rows)
                if ($errorMsg -match "duplicate key" -or $errorMsg -match "IX_ZMMR_RowHash") {
                    $skipped++
                    # Don't log every duplicate - just count them
                } else {
                    Write-Log "  Row $rowNum`: Error - $errorMsg"
                    $skipped++
                }
            }
        }
        
        # Update import log
        $updateCmd = $connection.CreateCommand()
        $updateCmd.CommandText = @"
            IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ZMMR_ImportLog')
            BEGIN
                UPDATE ZMMR_ImportLog 
                SET Status = 'Completed', RecordsImported = $imported, RecordsSkipped = $skipped 
                WHERE BatchID = '$batchId'
            END
"@
        try { $updateCmd.ExecuteNonQuery() | Out-Null } catch { }
        
        $connection.Close()
        
        Write-Log "  Imported: $imported, Skipped: $skipped (duplicates or errors)"
        
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
Write-Log "ZMMR Scrap Data Import Started"
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

Write-Log "Found $($csvFiles.Count) CSV file(s) to process"

$totalImported = 0
$totalSkipped = 0
$filesProcessed = 0

foreach ($file in $csvFiles) {
    $result = Import-ZMMRCsvFile -FilePath $file.FullName
    
    if ($null -eq $result.Error) {
        $totalImported += $result.Imported
        $totalSkipped += $result.Skipped
        $filesProcessed++
        
        # Move to archive folder
        $archivePath = Join-Path $ArchiveFolder $file.Name
        
        # If file already exists in archive, add timestamp
        if (Test-Path $archivePath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $newName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + "_$timestamp.csv"
            $archivePath = Join-Path $ArchiveFolder $newName
        }
        
        Move-Item -Path $file.FullName -Destination $archivePath -Force
        Write-Log "  Moved to archive: $archivePath"
    }
    else {
        Write-Log "  File NOT archived due to error"
    }
}

Write-Log "=========================================="
Write-Log "Import Summary:"
Write-Log "  Files processed: $filesProcessed"
Write-Log "  Records imported: $totalImported"
Write-Log "  Duplicates skipped: $totalSkipped"
Write-Log "=========================================="

# Only prompt for key press if running interactively (not from Task Scheduler)
if ([Environment]::UserInteractive -and -not $env:TASK_SCHEDULER_RUN) {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
