-- TEMPORARY TEST SCRIPT TO VERIFY UPCOMING PMS DISPLAY
-- This script updates NextPM dates for testing purposes
-- Run this to create test data with different PM statuses

-- WARNING: This modifies your data! Back up first or note the original values.

-- Example: Update one item to be due this week (5 days from now)
-- UPDATE ATE_Inventory 
-- SET NextPM = DATEADD(DAY, 5, CAST(GETDATE() AS DATE))
-- WHERE EatonID = 'YPO-ATE-rPDU-001'

-- Example: Update one item to be due this month (15 days from now)
-- UPDATE ATE_Inventory 
-- SET NextPM = DATEADD(DAY, 15, CAST(GETDATE() AS DATE))
-- WHERE EatonID = 'ANOTHER-EQUIPMENT-ID'

-- To verify what items will show up, run this query:
SELECT 
    EatonID AS EquipmentEatonID,
    ATEName AS EquipmentName,
    Location,
    CASE 
        WHEN NextPM < CAST(GETDATE() AS DATE) THEN 'Overdue'
        WHEN NextPM BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 7, CAST(GETDATE() AS DATE)) THEN 'Due This Week'
        WHEN NextPM BETWEEN DATEADD(DAY, 8, CAST(GETDATE() AS DATE)) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE)) THEN 'Due This Month'
        ELSE 'Due Soon'
    END AS PMStatus,
    NextPM AS NextPMDate,
    ISNULL(PMResponsible, 'Unassigned') AS PMResponsible
FROM ATE_Inventory
WHERE IsActive = 1 
AND RequiredPM = 1
AND NextPM <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY 
    CASE WHEN NextPMDate < CAST(GETDATE() AS DATE) THEN 0 ELSE 1 END,
    NextPMDate ASC;

-- Current date for reference:
SELECT CAST(GETDATE() AS DATE) AS Today;
