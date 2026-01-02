-- =============================================
-- SPD Test Results View
-- Similar to Tracks View_PowerBI_QDMS_INDEX_VIEW but for SPD test data
-- =============================================

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vw_SPD_TestResults')
    DROP VIEW dbo.vw_SPD_TestResults
GO

CREATE VIEW dbo.vw_SPD_TestResults
AS
SELECT
    TestID,
    SerialNumber,
    CatalogNumber AS PartNumber,
    TestStartTime AS StartTime,
    TestEndTime,
    OverallStatus AS Status,
    CASE WHEN OverallStatus = 'Passed' THEN 1 ELSE 0 END AS Results,
    LineName,
    WorkstationName AS Workcell,
    OperatorName,
    TestSequenceName,
    TestComments,
    TestDurationMinutes,
    CreatedDate
FROM dbo.OverallResults
WHERE OverallStatus IS NOT NULL
GO

PRINT 'View vw_SPD_TestResults created successfully'
GO

-- Test the view
SELECT TOP 10
    SerialNumber,
    PartNumber,
    StartTime,
    Status,
    Results,
    Workcell,
    OperatorName
FROM dbo.vw_SPD_TestResults
ORDER BY StartTime DESC
GO
