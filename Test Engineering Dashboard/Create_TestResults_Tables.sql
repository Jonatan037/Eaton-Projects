-- =============================================
-- CLEAN MIGRATION - Drop existing tables and recreate from scratch
-- =============================================

-- Drop foreign key constraints first
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_TestResultCommunications_TestResultID')
    ALTER TABLE dbo.TestResultCommunications DROP CONSTRAINT FK_TestResultCommunications_TestResultID

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_TestResultParameters_TestResultID')
    ALTER TABLE dbo.TestResultParameters DROP CONSTRAINT FK_TestResultParameters_TestResultID

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_TestResults_TestID')
    ALTER TABLE dbo.TestResults DROP CONSTRAINT FK_TestResults_TestID

-- Drop existing tables
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TestResultCommunications')
    DROP TABLE dbo.TestResultCommunications

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TestResultParameters')
    DROP TABLE dbo.TestResultParameters

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TestResults')
    DROP TABLE dbo.TestResults

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'OverallResults')
    DROP TABLE dbo.OverallResults

-- Drop existing views
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vw_TestResultsWithCounts')
    DROP VIEW dbo.vw_TestResultsWithCounts

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vw_RecentTestResults')
    DROP VIEW dbo.vw_RecentTestResults

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vw_OverallResultsWithStepCounts')
    DROP VIEW dbo.vw_OverallResultsWithStepCounts

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vw_RecentOverallResults')
    DROP VIEW dbo.vw_RecentOverallResults

PRINT 'Clean migration: All existing tables and views dropped'

-- =============================================
-- 0. CREATE OVERALL TEST RESULTS TABLE (MASTER/SUMMARY)
-- =============================================
CREATE TABLE dbo.OverallResults (
    TestID BIGINT IDENTITY(1,1) PRIMARY KEY,
    -- Test Session Information
    LineName NVARCHAR(100) NOT NULL,
    ParentWorkStation NVARCHAR(100) NOT NULL,
    WorkstationName NVARCHAR(100) NOT NULL,
    ShiftName NVARCHAR(50) NULL,
    OperatorName NVARCHAR(100) NOT NULL,
    TestSequenceName NVARCHAR(200) NOT NULL,
    CatalogNumber NVARCHAR(100) NULL,

    -- Test Timing
    TestStartTime DATETIME2 NOT NULL,
    TestEndTime DATETIME2 NOT NULL,

    -- Test Item Details
    SerialNumber NVARCHAR(100) NOT NULL,

    -- Overall Test Results
    OverallStatus NVARCHAR(20) NOT NULL CHECK (OverallStatus IN ('Passed', 'Failed')),
    TestComments NVARCHAR(500) NULL,

    -- Test Duration
    TestDurationMinutes INT NULL,

    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2 NULL,
    CreatedBy NVARCHAR(100) NULL,

    -- Constraints
    CONSTRAINT CK_OverallResults_Status CHECK (OverallStatus IN ('Passed', 'Failed')),
    CONSTRAINT CK_OverallResults_Timing CHECK (TestEndTime >= TestStartTime)
)

PRINT 'OverallResults table created successfully'
GO

-- =============================================
-- 1. CREATE MAIN TEST RESULTS TABLE
-- =============================================
CREATE TABLE dbo.TestResults (
    TestResultID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TestID BIGINT NOT NULL, -- Foreign key to OverallResults table

    -- Test Item Details
    SerialNumber NVARCHAR(100) NOT NULL,
    SequenceNumber INT NOT NULL,
    InstructionName NVARCHAR(500) NOT NULL,

    -- Test Results
    Results NVARCHAR(MAX) NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Passed', 'Failed')),
    TestComments NVARCHAR(500) NULL,

    -- Test Limits
    UpperTestLimit FLOAT NULL,
    LowerTestLimit FLOAT NULL,
    UpperControlLimit FLOAT NULL,
    LowerControlLimit FLOAT NULL,
    TestUnits NVARCHAR(50) NULL,

    -- Metadata
    StepDataType INT NULL, -- Used internally by the application
    CallingFunction NVARCHAR(500) NULL, -- For debugging purposes

    -- Test Timing (relative to test start)
    TestStartTime DATETIME2 NOT NULL,
    TestEndTime DATETIME2 NOT NULL,

    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Foreign Key Constraint
    CONSTRAINT FK_TestResults_TestID
        FOREIGN KEY (TestID) REFERENCES dbo.OverallResults(TestID)
        ON DELETE CASCADE,

    -- Constraints
    CONSTRAINT CK_TestResults_Status CHECK (Status IN ('Passed', 'Failed')),
    CONSTRAINT CK_TestResults_StepTiming CHECK (TestEndTime >= TestStartTime)
)

PRINT 'TestResults table created successfully'
GO

-- =============================================
-- 2. CREATE TEST RESULT PARAMETERS TABLE
-- =============================================
CREATE TABLE dbo.TestResultParameters (
    TestResultParameterID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TestResultID BIGINT NOT NULL,

    -- Parameter Details
    Parameter_Key NVARCHAR(200) NOT NULL,
    Parameter_Value NVARCHAR(MAX) NULL,
    Parameter_Unit NVARCHAR(50) NULL,

    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Foreign Key Constraint
    CONSTRAINT FK_TestResultParameters_TestResultID
        FOREIGN KEY (TestResultID) REFERENCES dbo.TestResults(TestResultID)
        ON DELETE CASCADE
)

PRINT 'TestResultParameters table created successfully'
GO

-- =============================================
-- 3. CREATE TEST RESULT COMMUNICATIONS TABLE
-- =============================================
CREATE TABLE dbo.TestResultCommunications (
    TestResultCommunicationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TestResultID BIGINT NOT NULL,

    -- Communication Details
    SequenceNumber DECIMAL(10,3) NOT NULL, -- Supports fractional sequence numbers
    CommunicationType NVARCHAR(10) NOT NULL CHECK (CommunicationType IN ('TX', 'RX', 'CM')), -- TX=Transmit, RX=Receive, CM=Comment
    CommunicationText NVARCHAR(MAX) NOT NULL,
    CommunicationTime DATETIME2 NOT NULL,

    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    -- Foreign Key Constraint
    CONSTRAINT FK_TestResultCommunications_TestResultID
        FOREIGN KEY (TestResultID) REFERENCES dbo.TestResults(TestResultID)
        ON DELETE CASCADE
)

PRINT 'TestResultCommunications table created successfully'
GO

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- OverallResults table indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.OverallResults') AND name = 'IX_OverallResults_SerialNumber')
BEGIN
    CREATE NONCLUSTERED INDEX IX_OverallResults_SerialNumber
    ON dbo.OverallResults (SerialNumber)
    INCLUDE (TestStartTime, OverallStatus, LineName, WorkstationName)

    PRINT 'Index IX_OverallResults_SerialNumber created successfully'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.OverallResults') AND name = 'IX_OverallResults_TestStartTime')
BEGIN
    CREATE NONCLUSTERED INDEX IX_OverallResults_TestStartTime
    ON dbo.OverallResults (TestStartTime DESC)
    INCLUDE (SerialNumber, OverallStatus, LineName, WorkstationName, OperatorName)

    PRINT 'Index IX_OverallResults_TestStartTime created successfully'
END

-- TestResults table indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResults') AND name = 'IX_TestResults_TestID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResults_TestID
    ON dbo.TestResults (TestID)
    INCLUDE (SequenceNumber, Status, InstructionName)

    PRINT 'Index IX_TestResults_TestID created successfully'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResults') AND name = 'IX_TestResults_SerialNumber')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResults_SerialNumber
    ON dbo.TestResults (SerialNumber)
    INCLUDE (TestStartTime, Status, SequenceNumber, InstructionName)

    PRINT 'Index IX_TestResults_SerialNumber created successfully'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResults') AND name = 'IX_TestResults_TestStartTime')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResults_TestStartTime
    ON dbo.TestResults (TestStartTime DESC)
    INCLUDE (SerialNumber, Status, SequenceNumber, InstructionName)

    PRINT 'Index IX_TestResults_TestStartTime created successfully'
END

-- TestResultParameters table indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResultParameters') AND name = 'IX_TestResultParameters_TestResultID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResultParameters_TestResultID
    ON dbo.TestResultParameters (TestResultID)

    PRINT 'Index IX_TestResultParameters_TestResultID created successfully'
END

-- TestResultCommunications table indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResultCommunications') AND name = 'IX_TestResultCommunications_TestResultID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResultCommunications_TestResultID
    ON dbo.TestResultCommunications (TestResultID)

    PRINT 'Index IX_TestResultCommunications_TestResultID created successfully'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.TestResultCommunications') AND name = 'IX_TestResultCommunications_Time')
BEGIN
    CREATE NONCLUSTERED INDEX IX_TestResultCommunications_Time
    ON dbo.TestResultCommunications (CommunicationTime)
    INCLUDE (TestResultID, CommunicationType)

    PRINT 'Index IX_TestResultCommunications_Time created successfully'
END

-- =============================================
-- CREATE USEFUL VIEWS
-- =============================================

-- View for recent overall test results summary
EXEC('
CREATE VIEW dbo.vw_RecentOverallResults
AS
SELECT
    TestID,
    SerialNumber,
    TestSequenceName,
    LineName,
    WorkstationName,
    OperatorName,
    TestStartTime,
    TestEndTime,
    OverallStatus,
    TestComments,
    TestDurationMinutes,
    CreatedDate
FROM dbo.OverallResults
WHERE TestStartTime >= DATEADD(DAY, -30, GETDATE())
')
PRINT 'View vw_RecentOverallResults created successfully'
GO

-- View for overall test results with step counts
EXEC('
CREATE VIEW dbo.vw_OverallResultsWithStepCounts
AS
SELECT
    o.TestID,
    o.SerialNumber,
    o.TestSequenceName,
    o.LineName,
    o.WorkstationName,
    o.OperatorName,
    o.TestStartTime,
    o.OverallStatus,
    COUNT(tr.TestResultID) AS StepCount,
    COUNT(tp.TestResultParameterID) AS TotalParameterCount,
    COUNT(tc.TestResultCommunicationID) AS TotalCommunicationCount
FROM dbo.OverallResults o
LEFT JOIN dbo.TestResults tr ON o.TestID = tr.TestID
LEFT JOIN dbo.TestResultParameters tp ON tr.TestResultID = tp.TestResultID
LEFT JOIN dbo.TestResultCommunications tc ON tr.TestResultID = tc.TestResultID
GROUP BY
    o.TestID,
    o.SerialNumber,
    o.TestSequenceName,
    o.LineName,
    o.WorkstationName,
    o.OperatorName,
    o.TestStartTime,
    o.OverallStatus
')
PRINT 'View vw_OverallResultsWithStepCounts created successfully'
GO

-- View for recent test results summary (detailed)
EXEC('
CREATE VIEW dbo.vw_RecentTestResults
AS
SELECT
    tr.TestResultID,
    tr.TestID,
    tr.SerialNumber,
    o.TestSequenceName,
    o.LineName,
    o.WorkstationName,
    o.OperatorName,
    tr.TestStartTime,
    tr.TestEndTime,
    tr.Status,
    tr.TestComments,
    DATEDIFF(MINUTE, tr.TestStartTime, tr.TestEndTime) AS StepDurationMinutes,
    tr.CreatedDate
FROM dbo.TestResults tr
INNER JOIN dbo.OverallResults o ON tr.TestID = o.TestID
WHERE tr.TestStartTime >= DATEADD(DAY, -30, GETDATE())
')
PRINT 'View vw_RecentTestResults created successfully'
GO

-- View for test results with parameter counts
EXEC('
CREATE VIEW dbo.vw_TestResultsWithCounts
AS
SELECT
    tr.TestResultID,
    tr.TestID,
    tr.SerialNumber,
    tr.SequenceNumber,
    tr.InstructionName,
    tr.TestStartTime,
    tr.Status,
    COUNT(tp.TestResultParameterID) AS ParameterCount,
    COUNT(tc.TestResultCommunicationID) AS CommunicationCount
FROM dbo.TestResults tr
LEFT JOIN dbo.TestResultParameters tp ON tr.TestResultID = tp.TestResultID
LEFT JOIN dbo.TestResultCommunications tc ON tr.TestResultID = tc.TestResultID
GROUP BY
    tr.TestResultID,
    tr.TestID,
    tr.SerialNumber,
    tr.SequenceNumber,
    tr.InstructionName,
    tr.TestStartTime,
    tr.Status
')
PRINT 'View vw_TestResultsWithCounts created successfully'
GO

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify table creation
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('OverallResults', 'TestResults', 'TestResultParameters', 'TestResultCommunications')
    AND TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;

-- Verify indexes
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('dbo.OverallResults'),
    OBJECT_ID('dbo.TestResults'),
    OBJECT_ID('dbo.TestResultParameters'),
    OBJECT_ID('dbo.TestResultCommunications')
)
ORDER BY TableName, IndexName;

PRINT 'Test Results database schema setup completed successfully'
GO