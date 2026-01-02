-- Create Plant Table
-- This table stores plant information including various department managers

CREATE TABLE dbo.Plant (
    PlantID INT IDENTITY(1,1) PRIMARY KEY,
    Plant NVARCHAR(10) NOT NULL UNIQUE,
    PlantDescription NVARCHAR(200) NULL,
    PlantManager NVARCHAR(100) NULL,
    QualityManager NVARCHAR(100) NULL,
    FinanceManager NVARCHAR(100) NULL,
    HRManager NVARCHAR(100) NULL,
    EHSManager NVARCHAR(100) NULL,
    EngineeringManager NVARCHAR(100) NULL,
    ManufacturingManager NVARCHAR(100) NULL,
    TestEngineeringManager NVARCHAR(100) NULL,
    SCMManager NVARCHAR(100) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy NVARCHAR(100) NULL,
    IsActive BIT DEFAULT 1
);

-- Insert initial data
INSERT INTO dbo.Plant (Plant, PlantDescription, CreatedBy, IsActive)
VALUES 
    ('YPO', 'Youngsville Plant Operation', 'System', 1),
    ('RPO', 'Raleigh Plant Operation', 'System', 1),
    ('CPO', 'Capital Plant Operation', 'System', 1);

-- Add index for performance
CREATE INDEX IX_Plant_Plant ON dbo.Plant(Plant);
CREATE INDEX IX_Plant_IsActive ON dbo.Plant(IsActive);
