-- Create StationType table in TestEngineering database
USE [TestEngineering]
GO

-- Create the StationType table
CREATE TABLE [dbo].[StationType] (
    [ID] INT IDENTITY(1,1) NOT NULL,
    [StationType] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    CONSTRAINT [PK_StationType] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

-- Pre-populate the table with test station types
INSERT INTO [dbo].[StationType] ([StationType], [Description])
VALUES 
    ('Functional Test', ''),
    ('Hipot', ''),
    ('Cable Scan', ''),
    ('Flashing', ''),
    ('Packout Validation', ''),
    ('Functional Test + Hipot', ''),
    ('Functional Test + Flashing', ''),
    ('Database Network', ''),
    ('Database Archive', ''),
    ('Storage', ''),
    ('Programming / Coding', '')
GO

-- Verify the data
SELECT * FROM [dbo].[StationType]
GO
