-- SQL Script to create the Test Validation Records table in the Battery database
-- Run this script in SQL Server Management Studio on the usyouwhp6205605 server

USE [Battery]
GO

-- Create the Test Validation Records table
CREATE TABLE [dbo].[Test Validation Records] (
    [ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Plant] NVARCHAR(100) NULL,
    [ProductionLine] NVARCHAR(100) NULL,
    [SubLine] NVARCHAR(100) NULL,
    [StationName] NVARCHAR(100) NULL,
    [VerifierEmployeeID] NVARCHAR(50) NULL,
    [VerifierEmployeeName] NVARCHAR(100) NULL,
    [SerialNumber] NVARCHAR(100) NULL,
    [CheckStatus] NVARCHAR(20) NULL,
    [VerificationDateTime] DATETIME NULL,
    [VerificationMachineName] NVARCHAR(100) NULL,
    [CreatedDate] DATETIME DEFAULT GETDATE()
);

-- Create an index on SerialNumber for faster lookups
CREATE INDEX IX_TestValidationRecords_SerialNumber ON [dbo].[Test Validation Records] ([SerialNumber]);

-- Create an index on VerificationDateTime for date-based queries
CREATE INDEX IX_TestValidationRecords_VerificationDateTime ON [dbo].[Test Validation Records] ([VerificationDateTime]);

-- Create an index on CheckStatus for status-based queries
CREATE INDEX IX_TestValidationRecords_CheckStatus ON [dbo].[Test Validation Records] ([CheckStatus]);

GO