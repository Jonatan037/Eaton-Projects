/*
Create table to store account requests for Test Engineering Dashboard.
Paste this into SSMS and execute against the TestEngineering database.
*/

IF OBJECT_ID('dbo.AccountRequests','U') IS NULL
BEGIN
    CREATE TABLE dbo.AccountRequests (
        RequestID            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AccountRequests PRIMARY KEY,
        SubmittedAt          DATETIME2(0) NOT NULL CONSTRAINT DF_AccountRequests_SubmittedAt DEFAULT (SYSUTCDATETIME()),
        Status               NVARCHAR(20) NOT NULL CONSTRAINT DF_AccountRequests_Status DEFAULT ('Pending'), -- Pending|Approved|Rejected
        FullName             NVARCHAR(100) NOT NULL,
        ENumber              NVARCHAR(20) NOT NULL,
        Email                NVARCHAR(255) NOT NULL,
        Department           NVARCHAR(100) NOT NULL,
        JobRole              NVARCHAR(100) NOT NULL,
        PasswordHash         CHAR(64) NOT NULL, -- SHA-256 hex (lowercase)
        ProfileFileName      NVARCHAR(255) NULL,
        ProfileContentType   NVARCHAR(100) NULL,
    ProfileImage         VARBINARY(MAX) NULL, -- Legacy option: store bytes (unused in current app)
    ProfilePath          NVARCHAR(400) NULL,  -- Preferred: relative path to saved file under ~/Uploads/ProfilePictures
        ClientIp             NVARCHAR(45) NULL,   -- IPv4/IPv6
        UserAgent            NVARCHAR(256) NULL,
        ReviewedAt           DATETIME2(0) NULL,
        ReviewedByUserID     INT NULL,
        ReviewedBy           NVARCHAR(100) NULL,
        Decision             NVARCHAR(20) NULL,   -- Approved|Rejected
        DecisionNotes        NVARCHAR(1000) NULL,
        AssignedAppRole      NVARCHAR(50) NULL
    );

    ALTER TABLE dbo.AccountRequests WITH CHECK ADD CONSTRAINT CK_AccountRequests_Status CHECK ([Status] IN (N'Pending', N'Approved', N'Rejected'));
    ALTER TABLE dbo.AccountRequests WITH CHECK ADD CONSTRAINT CK_AccountRequests_Decision CHECK ([Decision] IS NULL OR [Decision] IN (N'Approved', N'Rejected'));

    CREATE INDEX IX_AccountRequests_Status_SubmittedAt ON dbo.AccountRequests([Status], [SubmittedAt] DESC);
    CREATE INDEX IX_AccountRequests_Email ON dbo.AccountRequests([Email]);
    CREATE INDEX IX_AccountRequests_ENumber ON dbo.AccountRequests([ENumber]);

    -- Avoid duplicate pending requests for same identifier (optional filtered unique indexes)
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_AccountRequests_Email_Pending' AND object_id = OBJECT_ID('dbo.AccountRequests'))
    BEGIN
        CREATE UNIQUE INDEX UX_AccountRequests_Email_Pending ON dbo.AccountRequests([Email]) WHERE [Status] = N'Pending';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_AccountRequests_ENumber_Pending' AND object_id = OBJECT_ID('dbo.AccountRequests'))
    BEGIN
        CREATE UNIQUE INDEX UX_AccountRequests_ENumber_Pending ON dbo.AccountRequests([ENumber]) WHERE [Status] = N'Pending';
    END
END
GO

/* Optional helper stored procedures (use later for admin UI)

CREATE OR ALTER PROCEDURE dbo.AccountRequest_Approve
    @RequestID INT,
    @ReviewedByUserID INT = NULL,
    @ReviewedBy NVARCHAR(100) = NULL,
    @AssignedAppRole NVARCHAR(50) = NULL,
    @DecisionNotes NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.AccountRequests
    SET Status = N'Approved',
        Decision = N'Approved',
        ReviewedAt = SYSUTCDATETIME(),
        ReviewedByUserID = @ReviewedByUserID,
        ReviewedBy = @ReviewedBy,
        AssignedAppRole = @AssignedAppRole,
        DecisionNotes = @DecisionNotes
    WHERE RequestID = @RequestID AND Status = N'Pending';
END
GO

CREATE OR ALTER PROCEDURE dbo.AccountRequest_Reject
    @RequestID INT,
    @ReviewedByUserID INT = NULL,
    @ReviewedBy NVARCHAR(100) = NULL,
    @DecisionNotes NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.AccountRequests
    SET Status = N'Rejected',
        Decision = N'Rejected',
        ReviewedAt = SYSUTCDATETIME(),
        ReviewedByUserID = @ReviewedByUserID,
        ReviewedBy = @ReviewedBy,
        DecisionNotes = @DecisionNotes
    WHERE RequestID = @RequestID AND Status = N'Pending';
END
GO
*/
