-- =============================================
-- Hipot/Ground Bond Test Results Database Tables
-- Database: Phoenix
-- Created: December 2024
-- Description: Tables for storing Hipot and Ground Bond test results
--              from Associated Research OMNIA II 8204
-- =============================================

USE [Phoenix]
GO

-- =============================================
-- Table: HipotTestResults
-- Description: Stores production Hipot/Ground Bond test results for units
-- Each record represents a complete test sequence (GND + ACW tests)
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HipotTestResults')
BEGIN
    CREATE TABLE [dbo].[HipotTestResults]
    (
        -- Primary Key
        [TestResultID]          INT IDENTITY(1,1) NOT NULL,
        
        -- Unit Identification
        [SerialNumber]          NVARCHAR(50) NOT NULL,
        [PartNumber]            NVARCHAR(50) NULL,
        [WorkOrder]             NVARCHAR(50) NULL,
        
        -- Test Information
        [TestDateTime]          DATETIME NOT NULL DEFAULT GETDATE(),
        [OperatorENumber]       NVARCHAR(20) NOT NULL,
        [EquipmentID]           NVARCHAR(200) NULL,       -- OMNIA II Identification (can be long)
        [TestFileLoaded]        NVARCHAR(100) NULL,       -- Test file name if applicable
        
        -- Overall Test Result
        [OverallResult]         NVARCHAR(10) NOT NULL,    -- 'PASS' or 'FAIL'
        [TotalTestTime]         DECIMAL(10,2) NULL,       -- Total test duration in seconds
        
        -- Ground Bond Test Results (Step 1)
        [GND_Result]            NVARCHAR(10) NULL,        -- 'PASS', 'FAIL', or 'SKIP'
        [GND_Current_A]         DECIMAL(10,4) NULL,       -- Applied current in Amps
        [GND_Voltage_V]         DECIMAL(10,4) NULL,       -- Measured voltage
        [GND_Resistance_mOhm]   DECIMAL(10,4) NULL,       -- Measured resistance in mOhms
        [GND_HiLimit_mOhm]      DECIMAL(10,4) NULL,       -- HI limit setting
        [GND_LoLimit_mOhm]      DECIMAL(10,4) NULL,       -- LO limit setting
        [GND_DwellTime_s]       DECIMAL(10,2) NULL,       -- Dwell time in seconds
        [GND_Frequency_Hz]      INT NULL,                 -- 50 or 60 Hz
        
        -- AC Withstand (Hipot) Test Results (Step 2)
        [ACW_Result]            NVARCHAR(10) NULL,        -- 'PASS', 'FAIL', or 'SKIP'
        [ACW_Voltage_V]         DECIMAL(10,2) NULL,       -- Applied voltage
        [ACW_LeakageCurrent_mA] DECIMAL(10,4) NULL,       -- Measured leakage current
        [ACW_HiLimit_mA]        DECIMAL(10,4) NULL,       -- HI limit (Total)
        [ACW_LoLimit_mA]        DECIMAL(10,4) NULL,       -- LO limit (Total)
        [ACW_HiLimitReal_mA]    DECIMAL(10,4) NULL,       -- HI limit (Real)
        [ACW_LoLimitReal_mA]    DECIMAL(10,4) NULL,       -- LO limit (Real)
        [ACW_RampUp_s]          DECIMAL(10,2) NULL,       -- Ramp up time
        [ACW_DwellTime_s]       DECIMAL(10,2) NULL,       -- Dwell time
        [ACW_RampDown_s]        DECIMAL(10,2) NULL,       -- Ramp down time
        [ACW_Frequency_Hz]      INT NULL,                 -- 50 or 60 Hz
        [ACW_ArcSense]          INT NULL,                 -- Arc sense level (1-9)
        [ACW_ArcDetected]       BIT NULL,                 -- Arc detected flag
        
        -- Failure Information
        [FailureReason]         NVARCHAR(500) NULL,       -- Description of failure
        [FailureStep]           INT NULL,                 -- Which step failed (1=GND, 2=ACW)
        
        -- Additional Info
        [Comments]              NVARCHAR(500) NULL,
        [RawResponse]           NVARCHAR(MAX) NULL,       -- Raw data from equipment for debugging
        
        -- Audit Fields
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy]             NVARCHAR(50) NULL,
        [ModifiedDate]          DATETIME NULL,
        [ModifiedBy]            NVARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT [PK_HipotTestResults] PRIMARY KEY CLUSTERED ([TestResultID] ASC)
    )

    PRINT 'Table HipotTestResults created successfully.'
END
ELSE
BEGIN
    PRINT 'Table HipotTestResults already exists.'
END
GO

-- =============================================
-- Table: SafetyCheckResults
-- Description: Stores daily safety check (FailCHEK) validation results
-- Each operator must perform this check each shift before testing units
-- =============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SafetyCheckResults')
BEGIN
    CREATE TABLE [dbo].[SafetyCheckResults]
    (
        -- Primary Key
        [SafetyCheckID]         INT IDENTITY(1,1) NOT NULL,
        
        -- Check Information
        [CheckDateTime]         DATETIME NOT NULL DEFAULT GETDATE(),
        [OperatorENumber]       NVARCHAR(20) NOT NULL,
        [ShiftNumber]           INT NULL,                 -- 1, 2, or 3
        [EquipmentID]           NVARCHAR(200) NULL,       -- OMNIA II Identification (can be long)
        
        -- Overall Result
        [OverallResult]         NVARCHAR(10) NOT NULL,    -- 'PASS' or 'FAIL'
        
        -- Continuity Check Results
        [Continuity_Result]     NVARCHAR(10) NULL,        -- 'PASS' or 'FAIL'
        [Continuity_Resistance_mOhm] DECIMAL(10,4) NULL,  -- Measured resistance
        [Continuity_HiLimit_mOhm]    DECIMAL(10,4) NULL,  -- HI limit used
        [Continuity_LoLimit_mOhm]    DECIMAL(10,4) NULL,  -- LO limit used
        
        -- Ground Bond Check Results
        [GND_Result]            NVARCHAR(10) NULL,        -- 'PASS' or 'FAIL'
        [GND_Current_A]         DECIMAL(10,4) NULL,       -- Applied current
        [GND_Resistance_mOhm]   DECIMAL(10,4) NULL,       -- Measured resistance
        [GND_HiLimit_mOhm]      DECIMAL(10,4) NULL,       -- HI limit used
        [GND_LoLimit_mOhm]      DECIMAL(10,4) NULL,       -- LO limit used
        
        -- Additional Info
        [Comments]              NVARCHAR(500) NULL,
        [RawResponse]           NVARCHAR(MAX) NULL,       -- Raw data from equipment
        
        -- Validation
        [IsValidForShift]       BIT NOT NULL DEFAULT 1,   -- Is this valid for current shift?
        [ExpirationDateTime]    DATETIME NULL,            -- When this check expires
        
        -- Audit Fields
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy]             NVARCHAR(50) NULL,
        
        -- Constraints
        CONSTRAINT [PK_SafetyCheckResults] PRIMARY KEY CLUSTERED ([SafetyCheckID] ASC)
    )

    PRINT 'Table SafetyCheckResults created successfully.'
END
ELSE
BEGIN
    PRINT 'Table SafetyCheckResults already exists.'
END
GO

-- =============================================
-- Indexes for Performance
-- =============================================

-- HipotTestResults indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HipotTestResults_SerialNumber')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HipotTestResults_SerialNumber] 
    ON [dbo].[HipotTestResults] ([SerialNumber])
    INCLUDE ([TestDateTime], [OverallResult], [OperatorENumber])
    
    PRINT 'Index IX_HipotTestResults_SerialNumber created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HipotTestResults_TestDateTime')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HipotTestResults_TestDateTime] 
    ON [dbo].[HipotTestResults] ([TestDateTime] DESC)
    INCLUDE ([SerialNumber], [OverallResult], [OperatorENumber])
    
    PRINT 'Index IX_HipotTestResults_TestDateTime created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_HipotTestResults_Operator')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_HipotTestResults_Operator] 
    ON [dbo].[HipotTestResults] ([OperatorENumber], [TestDateTime] DESC)
    
    PRINT 'Index IX_HipotTestResults_Operator created.'
END
GO

-- SafetyCheckResults indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SafetyCheckResults_OperatorShift')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SafetyCheckResults_OperatorShift] 
    ON [dbo].[SafetyCheckResults] ([OperatorENumber], [CheckDateTime] DESC, [ShiftNumber])
    
    PRINT 'Index IX_SafetyCheckResults_OperatorShift created.'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SafetyCheckResults_Date')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_SafetyCheckResults_Date] 
    ON [dbo].[SafetyCheckResults] ([CheckDateTime] DESC)
    INCLUDE ([OperatorENumber], [OverallResult], [ShiftNumber])
    
    PRINT 'Index IX_SafetyCheckResults_Date created.'
END
GO

-- =============================================
-- Views for Common Queries
-- =============================================

-- View: Latest test result per serial number
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_LatestHipotTestBySerial')
    DROP VIEW [dbo].[vw_LatestHipotTestBySerial]
GO

CREATE VIEW [dbo].[vw_LatestHipotTestBySerial]
AS
WITH LatestTests AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY SerialNumber ORDER BY TestDateTime DESC) as RowNum
    FROM [dbo].[HipotTestResults]
)
SELECT 
    TestResultID,
    SerialNumber,
    PartNumber,
    WorkOrder,
    TestDateTime,
    OperatorENumber,
    EquipmentID,
    OverallResult,
    GND_Result,
    GND_Resistance_mOhm,
    ACW_Result,
    ACW_LeakageCurrent_mA,
    FailureReason
FROM LatestTests
WHERE RowNum = 1
GO

PRINT 'View vw_LatestHipotTestBySerial created.'
GO

-- View: Today's safety checks by operator
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_TodaySafetyChecks')
    DROP VIEW [dbo].[vw_TodaySafetyChecks]
GO

CREATE VIEW [dbo].[vw_TodaySafetyChecks]
AS
SELECT 
    sc.SafetyCheckID,
    sc.CheckDateTime,
    sc.OperatorENumber,
    u.FullName as OperatorName,
    sc.ShiftNumber,
    sc.EquipmentID,
    sc.OverallResult,
    sc.Continuity_Result,
    sc.GND_Result,
    sc.IsValidForShift
FROM [dbo].[SafetyCheckResults] sc
LEFT JOIN [TestEngineering].[dbo].[Users] u ON sc.OperatorENumber = u.ENumber
WHERE CAST(sc.CheckDateTime AS DATE) = CAST(GETDATE() AS DATE)
GO

PRINT 'View vw_TodaySafetyChecks created.'
GO

-- =============================================
-- Stored Procedures
-- =============================================

-- SP: Check if operator has valid safety check for current shift
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CheckOperatorSafetyStatus')
    DROP PROCEDURE [dbo].[sp_CheckOperatorSafetyStatus]
GO

CREATE PROCEDURE [dbo].[sp_CheckOperatorSafetyStatus]
    @OperatorENumber NVARCHAR(20),
    @ShiftNumber INT = NULL,
    @HasValidCheck BIT OUTPUT,
    @LastCheckDateTime DATETIME OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default to no valid check
    SET @HasValidCheck = 0
    SET @LastCheckDateTime = NULL
    
    -- Find the most recent passing safety check for today
    SELECT TOP 1 
        @HasValidCheck = CASE WHEN OverallResult = 'PASS' AND IsValidForShift = 1 THEN 1 ELSE 0 END,
        @LastCheckDateTime = CheckDateTime
    FROM [dbo].[SafetyCheckResults]
    WHERE OperatorENumber = @OperatorENumber
        AND CAST(CheckDateTime AS DATE) = CAST(GETDATE() AS DATE)
        AND (@ShiftNumber IS NULL OR ShiftNumber = @ShiftNumber)
        AND OverallResult = 'PASS'
        AND IsValidForShift = 1
    ORDER BY CheckDateTime DESC
END
GO

PRINT 'Stored procedure sp_CheckOperatorSafetyStatus created.'
GO

-- SP: Get test history for a serial number
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_GetHipotTestHistory')
    DROP PROCEDURE [dbo].[sp_GetHipotTestHistory]
GO

CREATE PROCEDURE [dbo].[sp_GetHipotTestHistory]
    @SerialNumber NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        TestResultID,
        SerialNumber,
        PartNumber,
        WorkOrder,
        TestDateTime,
        OperatorENumber,
        EquipmentID,
        OverallResult,
        TotalTestTime,
        GND_Result,
        GND_Resistance_mOhm,
        GND_HiLimit_mOhm,
        ACW_Result,
        ACW_Voltage_V,
        ACW_LeakageCurrent_mA,
        ACW_HiLimit_mA,
        FailureReason,
        Comments
    FROM [dbo].[HipotTestResults]
    WHERE SerialNumber = @SerialNumber
    ORDER BY TestDateTime DESC
END
GO

PRINT 'Stored procedure sp_GetHipotTestHistory created.'
GO

-- =============================================
-- Sample Data Verification Query
-- =============================================

PRINT ''
PRINT '============================================='
PRINT 'Database setup complete!'
PRINT 'Tables created: HipotTestResults, SafetyCheckResults'
PRINT 'Views created: vw_LatestHipotTestBySerial, vw_TodaySafetyChecks'
PRINT 'Stored Procedures: sp_CheckOperatorSafetyStatus, sp_GetHipotTestHistory'
PRINT '============================================='
GO
