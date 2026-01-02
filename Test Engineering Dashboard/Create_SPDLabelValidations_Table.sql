CREATE TABLE [dbo].[SPDLabelValidations]
(
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ValidationTime] DATETIME NOT NULL DEFAULT (GETDATE()),
    [OperatorName] NVARCHAR(100) NULL,
    [OperatorENumber] NVARCHAR(50) NULL,
    [SerialNumber] NVARCHAR(50) NULL,
    [CatalogNumber] NVARCHAR(50) NULL,
    [MaterialScanned] NVARCHAR(100) NULL,
    [MaterialExpected] NVARCHAR(100) NULL,
    [IsMatch] BIT NOT NULL,
    [Workcell] NVARCHAR(50) NULL
);

CREATE INDEX IX_SPDLabelValidations_Serial ON [dbo].[SPDLabelValidations] ([SerialNumber]);
CREATE INDEX IX_SPDLabelValidations_Time ON [dbo].[SPDLabelValidations] ([ValidationTime]);
