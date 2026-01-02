-- Alternative version using affected equipment columns for more detailed categorization
WITH OpenByPriorityCTE AS
    (SELECT Priority, COUNT(*) AS OpenCount
     FROM Troubleshooting_Log
     WHERE Status IN ('Open', 'In Progress')
     GROUP BY Priority),
ResolutionStatsCTE AS
    (SELECT AVG(CAST(DATEDIFF(hour, ReportedDateTime, ResolvedDateTime) AS float)) AS AvgResolutionHours,
            COUNT(CASE WHEN IsRepeat = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS RepeatRate
     FROM Troubleshooting_Log
     WHERE ResolvedDateTime >= DATEADD(month, -12, GETDATE())
       AND ResolvedDateTime IS NOT NULL),
TopClassificationsCTE AS
    (SELECT TOP 5 IssueClassification, COUNT(*) AS IssueCount
     FROM Troubleshooting_Log
     WHERE IssueClassification IS NOT NULL
       AND ReportedDateTime >= DATEADD(month, -12, GETDATE())
     GROUP BY IssueClassification
     ORDER BY COUNT(*) DESC),
EquipmentTypeCTE AS
    (/* Unpivot affected equipment columns to get equipment type counts */
     SELECT EquipmentType, COUNT(*) AS IssueCount
     FROM (SELECT CASE WHEN AffectedATE IS NOT NULL THEN 'ATE'
                       WHEN AffectedEquipment IS NOT NULL THEN 'Equipment'
                       WHEN AffectedFixture IS NOT NULL THEN 'Fixture'
                       WHEN AffectedHarness IS NOT NULL THEN 'Harness'
                       ELSE 'Other' END AS EquipmentType
           FROM Troubleshooting_Log
           WHERE ReportedDateTime >= DATEADD(month, -12, GETDATE())
             AND (AffectedATE IS NOT NULL OR AffectedEquipment IS NOT NULL OR
                  AffectedFixture IS NOT NULL OR AffectedHarness IS NOT NULL)) AS EquipmentTypes
     GROUP BY EquipmentType)
SELECT ISNULL((SELECT SUM(OpenCount) FROM OpenByPriorityCTE), 0) AS TotalOpenIssues,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Critical'), 0) AS OpenCritical,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'High'), 0) AS OpenHigh,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Medium'), 0) AS OpenMedium,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Low'), 0) AS OpenLow,
       CAST(ISNULL((SELECT AvgResolutionHours FROM ResolutionStatsCTE), 0) AS decimal(10, 2)) AS AvgResolutionHours,
       CAST(ISNULL((SELECT RepeatRate FROM ResolutionStatsCTE), 0) AS decimal(5, 2)) AS RepeatIssueRate,
       (SELECT STUFF((SELECT ',' + IssueClassification + ':' + CAST(IssueCount AS varchar)
                      FROM TopClassificationsCTE FOR XML PATH('')), 1, 1, '')) AS TopClassifications,
       (SELECT STUFF((SELECT ',' + EquipmentType + ':' + CAST(IssueCount AS varchar)
                      FROM EquipmentTypeCTE FOR XML PATH('')), 1, 1, '')) AS IssuesByEquipmentType;