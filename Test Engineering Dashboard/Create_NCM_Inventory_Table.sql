-- =============================================
-- NCM Warehouse Inventory Table
-- Created for Plant Quality Dashboard
-- Data source: RPO_Warehouse_Inventory.xlsx from SharePoint
-- Filter for dashboard: Plant = 1624, SLoc = 8001
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NCM_Warehouse_Inventory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[NCM_Warehouse_Inventory] (
        -- Primary key for tracking
        [ID] INT IDENTITY(1,1) PRIMARY KEY,
        [LoadDate] DATETIME NOT NULL DEFAULT GETDATE(),
        
        -- Material identification
        [MaterialNumber] NVARCHAR(50) NULL,
        [MaterialDescription] NVARCHAR(255) NULL,
        [CatalogNumber] NVARCHAR(100) NULL,
        
        -- Plant and location
        [Plant] NVARCHAR(20) NULL,
        [WarehouseNumber] NVARCHAR(20) NULL,
        [StorageType] NVARCHAR(20) NULL,
        [StorageBin] NVARCHAR(50) NULL,
        [SLoc] NVARCHAR(20) NULL,
        [SLocDesc] NVARCHAR(100) NULL,
        [InvTyp] NVARCHAR(20) NULL,
        
        -- Stock and value
        [TotalStock] DECIMAL(18,3) NULL,
        [BaseUoM] NVARCHAR(10) NULL,
        [TotalValue] DECIMAL(18,2) NULL,
        [StdMovAvgPrice] DECIMAL(18,2) NULL,
        [Currency] NVARCHAR(10) NULL,
        [Per] INT NULL,
        
        -- Stock categories
        [StockCategory] NVARCHAR(50) NULL,
        [SpecStockIndicator] NVARCHAR(20) NULL,
        [IMUnrestStock] DECIMAL(18,3) NULL,
        [IMQualityInspStock] DECIMAL(18,3) NULL,
        [IMBlockedStock] DECIMAL(18,3) NULL,
        [SafetyStock] DECIMAL(18,3) NULL,
        [Reserved] DECIMAL(18,3) NULL,
        
        -- Controllers and business
        [MRPController] NVARCHAR(20) NULL,
        [MRPCntDesc] NVARCHAR(100) NULL,
        [BusinessUnit] NVARCHAR(50) NULL,
        [MaterialType] NVARCHAR(20) NULL,
        [ProfitCtr] NVARCHAR(20) NULL,
        [CooperDivision] NVARCHAR(50) NULL,
        [DivisionText] NVARCHAR(100) NULL,
        
        -- Material grouping
        [MaterialGroup] NVARCHAR(50) NULL,
        [ExtMaterialGroup] NVARCHAR(100) NULL,
        [BasicProdHy] NVARCHAR(100) NULL,
        [StockDetGroup] NVARCHAR(50) NULL,
        [PlantSpMatStatus] NVARCHAR(20) NULL,
        
        -- Purchasing
        [PurchasingGrp] NVARCHAR(20) NULL,
        [ProcKey] NVARCHAR(20) NULL,
        [SplProcKey] NVARCHAR(20) NULL,
        [PrefVendNum] NVARCHAR(50) NULL,
        [PrefVendName] NVARCHAR(100) NULL,
        
        -- Quantities
        [Quant] NVARCHAR(50) NULL,
        [GoodsReceipt] NVARCHAR(100) NULL,
        [ItemText] NVARCHAR(255) NULL,
        [Count] INT NULL,
        [OpenDeliveryQuantity] DECIMAL(18,3) NULL,
        
        -- Sales related
        [SlsDoc] NVARCHAR(50) NULL,
        [SlsItem] NVARCHAR(50) NULL,
        [SpecialStockNumber] NVARCHAR(50) NULL,
        [SpecialStockDescription] NVARCHAR(255) NULL,
        [SlsOrderDate] DATE NULL,
        
        -- Physical inventory
        [PhyInvIndCC] NVARCHAR(20) NULL,
        [PhyInvDate] DATE NULL,
        [PriceControl] NVARCHAR(10) NULL,
        
        -- Classification
        [Batch] NVARCHAR(50) NULL,
        [ClassType] NVARCHAR(20) NULL,
        [Class] NVARCHAR(50) NULL,
        [Characteristic] NVARCHAR(100) NULL,
        [CharacteristicValue] NVARCHAR(255) NULL,
        
        -- Material attributes
        [MaterialOrigin] NVARCHAR(50) NULL,
        [MaterialUsage] NVARCHAR(50) NULL,
        [ProducedInHouse] NVARCHAR(10) NULL,
        
        -- Product hierarchy
        [RegionalProductHierarchy] NVARCHAR(100) NULL,
        [APRCCode] NVARCHAR(50) NULL,
        [Pcode] NVARCHAR(50) NULL
    );
    
    -- Create indexes for common queries
    CREATE NONCLUSTERED INDEX [IX_NCM_Inventory_Plant_SLoc] 
        ON [dbo].[NCM_Warehouse_Inventory] ([Plant], [SLoc]);
    
    CREATE NONCLUSTERED INDEX [IX_NCM_Inventory_LoadDate] 
        ON [dbo].[NCM_Warehouse_Inventory] ([LoadDate] DESC);
    
    CREATE NONCLUSTERED INDEX [IX_NCM_Inventory_MaterialNumber] 
        ON [dbo].[NCM_Warehouse_Inventory] ([MaterialNumber]);
    
    PRINT 'Table NCM_Warehouse_Inventory created successfully.';
END
ELSE
BEGIN
    PRINT 'Table NCM_Warehouse_Inventory already exists.';
END
GO

-- =============================================
-- View for NCM Dashboard Data (Plant 1624, SLoc 8001)
-- Gets the most recent data load only
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_NCM_Dashboard_Current')
    DROP VIEW [dbo].[vw_NCM_Dashboard_Current];
GO

CREATE VIEW [dbo].[vw_NCM_Dashboard_Current]
AS
WITH LatestLoad AS (
    SELECT MAX(LoadDate) AS MaxLoadDate
    FROM [dbo].[NCM_Warehouse_Inventory]
    WHERE [Plant] = '1624' AND [SLoc] = '8001'
)
SELECT 
    inv.[ID],
    inv.[LoadDate],
    inv.[MaterialNumber],
    inv.[MaterialDescription],
    inv.[CatalogNumber],
    inv.[Plant],
    inv.[SLoc],
    inv.[SLocDesc],
    inv.[TotalStock],
    inv.[BaseUoM],
    inv.[TotalValue],
    inv.[MRPController],
    inv.[MRPCntDesc],
    inv.[MaterialType],
    inv.[MaterialGroup]
FROM [dbo].[NCM_Warehouse_Inventory] inv
INNER JOIN LatestLoad ll ON inv.[LoadDate] = ll.MaxLoadDate
WHERE inv.[Plant] = '1624' AND inv.[SLoc] = '8001';
GO

-- =============================================
-- View for NCM Top Materials by Total Value
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_NCM_TopMaterials')
    DROP VIEW [dbo].[vw_NCM_TopMaterials];
GO

CREATE VIEW [dbo].[vw_NCM_TopMaterials]
AS
WITH LatestLoad AS (
    SELECT MAX(LoadDate) AS MaxLoadDate
    FROM [dbo].[NCM_Warehouse_Inventory]
    WHERE [Plant] = '1624' AND [SLoc] = '8001'
),
MaterialTotals AS (
    SELECT 
        inv.[MaterialNumber],
        MAX(inv.[MaterialDescription]) AS MaterialDescription,
        SUM(inv.[TotalValue]) AS TotalValue,
        MAX(inv.[LoadDate]) AS LoadDate
    FROM [dbo].[NCM_Warehouse_Inventory] inv
    INNER JOIN LatestLoad ll ON inv.[LoadDate] = ll.MaxLoadDate
    WHERE inv.[Plant] = '1624' AND inv.[SLoc] = '8001'
    GROUP BY inv.[MaterialNumber]
)
SELECT 
    [MaterialNumber],
    [MaterialDescription],
    [TotalValue],
    [LoadDate]
FROM MaterialTotals;
GO

-- =============================================
-- View for NCM Summary (Total Value for Gauge)
-- =============================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_NCM_Summary')
    DROP VIEW [dbo].[vw_NCM_Summary];
GO

CREATE VIEW [dbo].[vw_NCM_Summary]
AS
WITH LatestLoad AS (
    SELECT MAX(LoadDate) AS MaxLoadDate
    FROM [dbo].[NCM_Warehouse_Inventory]
    WHERE [Plant] = '1624' AND [SLoc] = '8001'
)
SELECT 
    SUM(inv.[TotalValue]) AS TotalNCMValue,
    COUNT(DISTINCT inv.[MaterialNumber]) AS UniqueMaterials,
    MAX(inv.[LoadDate]) AS DataAsOf
FROM [dbo].[NCM_Warehouse_Inventory] inv
INNER JOIN LatestLoad ll ON inv.[LoadDate] = ll.MaxLoadDate
WHERE inv.[Plant] = '1624' AND inv.[SLoc] = '8001';
GO

PRINT 'NCM Dashboard views created successfully.';
GO

-- =============================================
-- NCM Goals Table (if not already created by Settings page)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PlantQuality_NCMGoals]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PlantQuality_NCMGoals] (
        [ID] INT IDENTITY(1,1) PRIMARY KEY,
        [Scope] NVARCHAR(50) NOT NULL,
        [Year] INT NOT NULL,
        [Month] INT NOT NULL,
        [MonthlyGoal] DECIMAL(18,2) NOT NULL DEFAULT 0,
        [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedDate] DATETIME NULL
    );
    
    -- Create index for quick lookups
    CREATE NONCLUSTERED INDEX [IX_NCMGoals_Scope_Year_Month] 
        ON [dbo].[PlantQuality_NCMGoals] ([Scope], [Year], [Month]);
    
    -- Insert default YPO goal for current year
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @Month INT = 1;
    
    WHILE @Month <= 12
    BEGIN
        INSERT INTO [dbo].[PlantQuality_NCMGoals] ([Scope], [Year], [Month], [MonthlyGoal])
        VALUES ('YPO', @CurrentYear, @Month, 75000.00);
        SET @Month = @Month + 1;
    END
    
    PRINT 'Table PlantQuality_NCMGoals created with default values.';
END
ELSE
BEGIN
    PRINT 'Table PlantQuality_NCMGoals already exists.';
END
GO
