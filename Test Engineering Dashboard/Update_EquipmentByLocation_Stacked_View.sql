/*************************************************************************************************
 * Update Equipment Inventory Dashboard - Equipment by Location View
 * Purpose: Modify to return equipment type breakdown by location for stacked column chart
 * Date: October 27, 2025
 *************************************************************************************************/

USE [TestEngineering]
GO

-- Drop and recreate vw_EquipmentInventory_ByLocation for stacked chart
IF OBJECT_ID('vw_EquipmentInventory_ByLocation', 'V') IS NOT NULL
    DROP VIEW vw_EquipmentInventory_ByLocation;
GO

CREATE VIEW vw_EquipmentInventory_ByLocation
AS
WITH AllEquipment AS (
    SELECT 
        Location,
        'ATE' AS EquipmentType
    FROM dbo.ATE_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Asset' AS EquipmentType
    FROM dbo.Asset_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Fixture' AS EquipmentType
    FROM dbo.Fixture_Inventory 
    WHERE IsActive = 1
    
    UNION ALL
    
    SELECT 
        Location,
        'Harness' AS EquipmentType
    FROM dbo.Harness_Inventory 
    WHERE IsActive = 1
),
TopLocations AS (
    -- Get ALL locations by total count (removed TOP 10 restriction)
    SELECT 
        ISNULL(Location, 'Unassigned') AS Location,
        COUNT(*) AS TotalCount
    FROM AllEquipment
    GROUP BY Location
)
-- Return equipment type breakdown for each top location
-- Note: ORDER BY removed from view - will be handled in C# code
SELECT 
    ISNULL(ae.Location, 'Unassigned') AS Location,
    ae.EquipmentType,
    COUNT(*) AS EquipmentCount,
    (SELECT TotalCount FROM TopLocations WHERE Location = ISNULL(ae.Location, 'Unassigned')) AS TotalForLocation
FROM AllEquipment ae
INNER JOIN TopLocations tl ON ISNULL(ae.Location, 'Unassigned') = tl.Location
GROUP BY ae.Location, ae.EquipmentType;
GO

PRINT 'View vw_EquipmentInventory_ByLocation updated successfully for stacked column chart';
GO

-- Test query
SELECT 'Test Results:' AS Info;
SELECT * FROM vw_EquipmentInventory_ByLocation;
GO
