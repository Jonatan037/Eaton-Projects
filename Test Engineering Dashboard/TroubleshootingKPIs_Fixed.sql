WITH OpenByPriorityCTE AS
    (SELECT Priority, COUNT(*) AS OpenCount
     FROM Troubleshooting_Log
     WHERE Status IN ('Open', 'In Progress')
     GROUP BY Priority),
ResolutionStatsCTE AS
    (/* Last 12 months resolution statistics - calculate resolution time from date difference */
     SELECT AVG(CAST(DATEDIFF(hour, ReportedDateTime, ResolvedDateTime) AS float)) AS AvgResolutionHours,
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
    (/* Group by Location instead of EquipmentType since EquipmentType column doesn't exist */
     SELECT Location AS EquipmentType, COUNT(*) AS IssueCount
     FROM Troubleshooting_Log
     WHERE Location IS NOT NULL
       AND ReportedDateTime >= DATEADD(month, -12, GETDATE())
     GROUP BY Location)
SELECT /* Open issues by priority */
       ISNULL((SELECT SUM(OpenCount) FROM OpenByPriorityCTE), 0) AS TotalOpenIssues,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Critical'), 0) AS OpenCritical,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'High'), 0) AS OpenHigh,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Medium'), 0) AS OpenMedium,
       ISNULL((SELECT OpenCount FROM OpenByPriorityCTE WHERE Priority = 'Low'), 0) AS OpenLow,
       /* Resolution statistics */
       CAST(ISNULL((SELECT AvgResolutionHours FROM ResolutionStatsCTE), 0) AS decimal(10, 2)) AS AvgResolutionHours,
       CAST(ISNULL((SELECT RepeatRate FROM ResolutionStatsCTE), 0) AS decimal(5, 2)) AS RepeatIssueRate,
       /* Top issue classifications (comma-separated) */
       (SELECT STUFF((SELECT ',' + IssueClassification + ':' + CAST(IssueCount AS varchar)
                      FROM TopClassificationsCTE FOR XML PATH('')), 1, 1, '')) AS TopClassifications,
       /* Issues by location (comma-separated) - using Location instead of EquipmentType */
       (SELECT STUFF((SELECT ',' + ISNULL(EquipmentType, 'Unknown') + ':' + CAST(IssueCount AS varchar)
                      FROM EquipmentTypeCTE FOR XML PATH('')), 1, 1, '')) AS IssuesByLocation;