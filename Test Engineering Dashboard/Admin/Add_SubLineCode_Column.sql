-- Add SubLineCode column to SubLine_Cell table in TestEngineering database
USE [TestEngineering]
GO

-- Add the new SubLineCode column
ALTER TABLE [dbo].[SubLine_Cell]
ADD [SubLineCode] NVARCHAR(200) NULL
GO

-- Update existing records to populate SubLineCode based on ProductionLine and SubLineCellName
UPDATE s
SET s.SubLineCode = CONCAT(p.ProductionLineName, ' - ', s.SubLineCellName)
FROM [dbo].[SubLine_Cell] s
LEFT JOIN [dbo].[ProductionLine] p ON s.ProductionLineID = p.ProductionLineID
WHERE s.SubLineCode IS NULL
GO

-- Verify the update
SELECT SubLineCellID, SubLineCellName, ProductionLineID, SubLineCode
FROM [dbo].[SubLine_Cell]
GO
