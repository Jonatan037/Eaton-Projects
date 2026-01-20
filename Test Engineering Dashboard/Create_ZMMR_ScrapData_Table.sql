-- =============================================
-- ZMMR Scrap Data Table for SAP Scrap Tracking
-- Source: Power BI Paginated Report Export (OneDrive CSV)
-- Created: January 2026
-- Database: TestEngineering
-- =============================================

USE TestEngineering;
GO

-- Drop existing table if needed (comment out in production)
-- DROP TABLE IF EXISTS ZMMR_ScrapData;

-- Main scrap data table
CREATE TABLE ZMMR_ScrapData (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Amount DECIMAL(18,4) NOT NULL,              -- zmmr_amount (cost in dollars)
    CostCenterCode VARCHAR(20) NOT NULL,        -- zmmr_cost_center_code (e.g., 1624-40018)
    MaterialDescription NVARCHAR(200) NULL,      -- zmmr_material_desc
    MaterialNumber VARCHAR(50) NOT NULL,         -- zmmr_material_number (part number)
    MovementType INT NOT NULL,                   -- zmmr_movement_type (551=scrap, 552=return)
    MRPControllerDesc NVARCHAR(100) NULL,        -- zmmr_mrp_controller_desc (product line)
    PlantCode VARCHAR(10) NOT NULL,              -- zmmr_plant_code (1624)
    PostingDate DATE NOT NULL,                   -- zmmr_posting_date
    Quantity INT NOT NULL,                       -- zmmr_quantity (negative=out, positive=return)
    ReasonDescription NVARCHAR(100) NULL,        -- zmmr_reason_desc (e.g., Quality/Defective)
    UserFullName NVARCHAR(100) NULL,             -- zmmr_users_full_name
    
    -- Import tracking fields
    ImportedDate DATETIME DEFAULT GETDATE(),
    ImportFileName NVARCHAR(255) NULL,
    ImportBatchID UNIQUEIDENTIFIER NULL,
    
    -- Create a hash for duplicate detection
    RowHash AS HASHBYTES('SHA2_256', 
        CAST(Amount AS VARCHAR(50)) + '|' + 
        CostCenterCode + '|' + 
        MaterialNumber + '|' + 
        CAST(MovementType AS VARCHAR(10)) + '|' + 
        PlantCode + '|' + 
        CONVERT(VARCHAR(10), PostingDate, 120) + '|' + 
        CAST(Quantity AS VARCHAR(20)) + '|' +
        ISNULL(UserFullName, '')
    ) PERSISTED
);
GO

-- Indexes for common query patterns
CREATE INDEX IX_ZMMR_PostingDate ON ZMMR_ScrapData (PostingDate);
CREATE INDEX IX_ZMMR_CostCenter ON ZMMR_ScrapData (CostCenterCode);
CREATE INDEX IX_ZMMR_PlantCode ON ZMMR_ScrapData (PlantCode);
CREATE INDEX IX_ZMMR_MovementType ON ZMMR_ScrapData (MovementType);
CREATE INDEX IX_ZMMR_MRPController ON ZMMR_ScrapData (MRPControllerDesc);
CREATE INDEX IX_ZMMR_MaterialNumber ON ZMMR_ScrapData (MaterialNumber);
CREATE UNIQUE INDEX IX_ZMMR_RowHash ON ZMMR_ScrapData (RowHash);
GO

-- Import log table to track file imports
CREATE TABLE ZMMR_ImportLog (
    ImportID INT IDENTITY(1,1) PRIMARY KEY,
    BatchID UNIQUEIDENTIFIER NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    ImportDate DATETIME DEFAULT GETDATE(),
    RecordsImported INT DEFAULT 0,
    RecordsSkipped INT DEFAULT 0,
    Status VARCHAR(20) DEFAULT 'In Progress', -- In Progress, Completed, Failed
    ErrorMessage NVARCHAR(MAX) NULL,
    ImportedBy NVARCHAR(100) NULL
);
GO

-- View for scrap summary by date (excludes returns/552)
CREATE VIEW vw_ScrapSummaryByDate AS
SELECT 
    PostingDate,
    COUNT(*) AS TransactionCount,
    SUM(ABS(Quantity)) AS TotalQuantity,
    SUM(ABS(Amount)) AS TotalCost,
    COUNT(DISTINCT MaterialNumber) AS UniqueMaterials,
    COUNT(DISTINCT CostCenterCode) AS UniqueCostCenters
FROM ZMMR_ScrapData
WHERE MovementType = 551  -- Only scrap (not returns)
GROUP BY PostingDate;
GO

-- View for scrap by product line (MRP Controller)
CREATE VIEW vw_ScrapByProductLine AS
SELECT 
    MRPControllerDesc AS ProductLine,
    YEAR(PostingDate) AS Year,
    MONTH(PostingDate) AS Month,
    COUNT(*) AS TransactionCount,
    SUM(ABS(Quantity)) AS TotalQuantity,
    SUM(ABS(Amount)) AS TotalCost
FROM ZMMR_ScrapData
WHERE MovementType = 551
GROUP BY MRPControllerDesc, YEAR(PostingDate), MONTH(PostingDate);
GO

-- View for net scrap (scrap - returns)
CREATE VIEW vw_NetScrapByMonth AS
SELECT 
    YEAR(PostingDate) AS Year,
    MONTH(PostingDate) AS Month,
    SUM(CASE WHEN MovementType = 551 THEN ABS(Amount) ELSE 0 END) AS GrossScrapCost,
    SUM(CASE WHEN MovementType = 552 THEN ABS(Amount) ELSE 0 END) AS ReturnsCost,
    SUM(CASE WHEN MovementType = 551 THEN ABS(Amount) ELSE 0 END) - 
        SUM(CASE WHEN MovementType = 552 THEN ABS(Amount) ELSE 0 END) AS NetScrapCost,
    SUM(CASE WHEN MovementType = 551 THEN ABS(Quantity) ELSE 0 END) AS GrossScrapQty,
    SUM(CASE WHEN MovementType = 552 THEN ABS(Quantity) ELSE 0 END) AS ReturnsQty,
    SUM(CASE WHEN MovementType = 551 THEN ABS(Quantity) ELSE 0 END) - 
        SUM(CASE WHEN MovementType = 552 THEN ABS(Quantity) ELSE 0 END) AS NetScrapQty
FROM ZMMR_ScrapData
GROUP BY YEAR(PostingDate), MONTH(PostingDate);
GO

-- View for top scrap materials
CREATE VIEW vw_TopScrapMaterials AS
SELECT TOP 100
    MaterialNumber,
    MaterialDescription,
    MRPControllerDesc AS ProductLine,
    COUNT(*) AS OccurrenceCount,
    SUM(ABS(Quantity)) AS TotalQuantity,
    SUM(ABS(Amount)) AS TotalCost
FROM ZMMR_ScrapData
WHERE MovementType = 551
GROUP BY MaterialNumber, MaterialDescription, MRPControllerDesc
ORDER BY TotalCost DESC;
GO

-- View for scrap by reason
CREATE VIEW vw_ScrapByReason AS
SELECT 
    ISNULL(ReasonDescription, 'Unknown') AS Reason,
    YEAR(PostingDate) AS Year,
    MONTH(PostingDate) AS Month,
    COUNT(*) AS TransactionCount,
    SUM(ABS(Quantity)) AS TotalQuantity,
    SUM(ABS(Amount)) AS TotalCost
FROM ZMMR_ScrapData
WHERE MovementType = 551
GROUP BY ReasonDescription, YEAR(PostingDate), MONTH(PostingDate);
GO

PRINT 'ZMMR Scrap Data tables and views created successfully.';
