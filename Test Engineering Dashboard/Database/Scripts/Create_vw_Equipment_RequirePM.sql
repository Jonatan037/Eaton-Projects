-- =============================================
-- Create View for Equipment Requiring PM
-- Description: Unified view of all equipment with RequiredPM/RequirePM = 1
-- Date: October 2025
-- =============================================

USE [TestEngineering]
GO

-- Drop view if it exists
IF OBJECT_ID('dbo.vw_Equipment_RequirePM', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Equipment_RequirePM;
GO

CREATE VIEW dbo.vw_Equipment_RequirePM
AS
-- ATE Inventory
SELECT 
    'ATE' AS EquipmentType,
    ATEInventoryID AS EquipmentID,
    EatonID,
    ATEName AS EquipmentName,
    Location,
    RequiredPM AS RequirePM,
    PMFrequency,
    PMResponsible,
    LastPM,
    LastPMBy,
    NextPM,
    PMEstimatedTime,
    IsActive
FROM dbo.ATE_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

-- Asset Inventory
SELECT 
    'Asset' AS EquipmentType,
    AssetID AS EquipmentID,
    EatonID,
    DeviceName AS EquipmentName,
    Location,
    RequiredPM AS RequirePM,
    PMFrequency,
    PMResponsible,
    LastPM,
    PMBy AS LastPMBy,
    NextPM,
    PMEstimatedTime,
    IsActive
FROM dbo.Asset_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

-- Fixture Inventory
SELECT 
    'Fixture' AS EquipmentType,
    FixtureID AS EquipmentID,
    EatonID,
    FixtureModelNoName AS EquipmentName,
    Location,
    RequiredPM AS RequirePM,
    PMFrequency,
    PMResponsible,
    LastPM,
    PMBy AS LastPMBy,
    NextPM,
    PMEstimatedTime,
    IsActive
FROM dbo.Fixture_Inventory
WHERE RequiredPM = 1 AND IsActive = 1

UNION ALL

-- Harness Inventory
SELECT 
    'Harness' AS EquipmentType,
    HarnessID AS EquipmentID,
    EatonID,
    HarnessModelNo AS EquipmentName,
    Location,
    RequiredPM AS RequirePM,
    PMFrequency,
    PMResponsible,
    LastPM,
    PMBy AS LastPMBy,
    NextPM,
    PMEstimatedTime,
    IsActive
FROM dbo.Harness_Inventory
WHERE RequiredPM = 1 AND IsActive = 1;
GO

PRINT 'View vw_Equipment_RequirePM created successfully.';
GO
