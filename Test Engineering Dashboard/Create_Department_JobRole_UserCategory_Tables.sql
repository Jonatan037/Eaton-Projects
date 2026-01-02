-- =============================================
-- Create Department, JobRole, and UserCategory Tables
-- These tables replace hardcoded dropdown values in the application
-- =============================================

-- 1. CREATE DEPARTMENT TABLE
-- =============================================
CREATE TABLE dbo.Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    Department NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentDescription NVARCHAR(500) NULL,
    SortOrder INT DEFAULT 999,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy NVARCHAR(100) NULL,
    IsActive BIT DEFAULT 1
);

-- Insert Department data
SET IDENTITY_INSERT dbo.Department ON;

INSERT INTO dbo.Department (DepartmentID, Department, DepartmentDescription, SortOrder, CreatedBy, IsActive)
VALUES 
    (1, 'Manufacturing', 'Manufacturing Operations', 10, 'System', 1),
    (2, 'Quality', 'Quality Assurance and Control', 20, 'System', 1),
    (3, 'Engineering', 'Engineering Department', 30, 'System', 1),
    (4, 'EHS', 'Environmental, Health, and Safety', 40, 'System', 1),
    (5, 'Test Engineering', 'Test Engineering Department', 50, 'System', 1),
    (6, 'IT', 'Information Technology', 60, 'System', 1),
    (7, 'SCM', 'Supply Chain Management', 70, 'System', 1),
    (8, 'Sustainability', 'Sustainability Department', 80, 'System', 1),
    (9, 'Finance', 'Finance Department', 90, 'System', 1),
    (10, 'HR', 'Human Resources', 100, 'System', 1),
    (999, 'Other', 'Other Department', 999, 'System', 1);

SET IDENTITY_INSERT dbo.Department OFF;

-- Add indexes for performance
CREATE INDEX IX_Department_Department ON dbo.Department(Department);
CREATE INDEX IX_Department_IsActive ON dbo.Department(IsActive);
CREATE INDEX IX_Department_SortOrder ON dbo.Department(SortOrder);

-- =============================================
-- 2. CREATE JOB ROLE TABLE
-- =============================================
CREATE TABLE dbo.JobRole (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    Role NVARCHAR(100) NOT NULL UNIQUE,
    RoleDescription NVARCHAR(500) NULL,
    SortOrder INT DEFAULT 999,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy NVARCHAR(100) NULL,
    IsActive BIT DEFAULT 1
);

-- Insert JobRole data
SET IDENTITY_INSERT dbo.JobRole ON;

INSERT INTO dbo.JobRole (JobRoleID, Role, RoleDescription, SortOrder, CreatedBy, IsActive)
VALUES 
    (1, 'Engineer', 'Engineering Role', 10, 'System', 1),
    (2, 'Technician', 'Technician Role', 20, 'System', 1),
    (3, 'Tester', 'Tester Role', 30, 'System', 1),
    (4, 'Supervisor', 'Supervisor Role', 40, 'System', 1),
    (5, 'Manager', 'Manager Role', 50, 'System', 1),
    (6, 'Analyst', 'Analyst Role', 60, 'System', 1),
    (7, 'Coordinator', 'Coordinator Role', 70, 'System', 1),
    (8, 'Assembler', 'Assembler Role', 80, 'System', 1),
    (9, 'Assistant', 'Assistant Role', 90, 'System', 1),
    (999, 'Other', 'Other Role', 999, 'System', 1);

SET IDENTITY_INSERT dbo.JobRole OFF;

-- Add indexes for performance
CREATE INDEX IX_JobRole_Role ON dbo.JobRole(Role);
CREATE INDEX IX_JobRole_IsActive ON dbo.JobRole(IsActive);
CREATE INDEX IX_JobRole_SortOrder ON dbo.JobRole(SortOrder);

-- =============================================
-- 3. CREATE USER CATEGORY TABLE
-- =============================================
CREATE TABLE dbo.UserCategory (
    UserCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    Category NVARCHAR(100) NOT NULL UNIQUE,
    CategoryDescription NVARCHAR(500) NULL,
    SortOrder INT DEFAULT 999,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100) NULL,
    ModifiedDate DATETIME NULL,
    ModifiedBy NVARCHAR(100) NULL,
    IsActive BIT DEFAULT 1
);

-- Insert UserCategory data
SET IDENTITY_INSERT dbo.UserCategory ON;

INSERT INTO dbo.UserCategory (UserCategoryID, Category, CategoryDescription, SortOrder, CreatedBy, IsActive)
VALUES 
    (1, 'Super Admin', 'Super Administrator with full system access', 10, 'System', 1),
    (2, 'Admin', 'Administrator with elevated privileges', 20, 'System', 1),
    (3, 'Regular', 'Regular user with standard access', 30, 'System', 1),
    (4, 'Viewer', 'View-only access', 40, 'System', 1),
    (999, 'Other', 'Other Category', 999, 'System', 1);

SET IDENTITY_INSERT dbo.UserCategory OFF;

-- Add indexes for performance
CREATE INDEX IX_UserCategory_Category ON dbo.UserCategory(Category);
CREATE INDEX IX_UserCategory_IsActive ON dbo.UserCategory(IsActive);
CREATE INDEX IX_UserCategory_SortOrder ON dbo.UserCategory(SortOrder);

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify Department table
SELECT DepartmentID, Department, DepartmentDescription, SortOrder, IsActive 
FROM dbo.Department 
ORDER BY SortOrder;

-- Verify JobRole table
SELECT JobRoleID, Role, RoleDescription, SortOrder, IsActive 
FROM dbo.JobRole 
ORDER BY SortOrder;

-- Verify UserCategory table
SELECT UserCategoryID, Category, CategoryDescription, SortOrder, IsActive 
FROM dbo.UserCategory 
ORDER BY SortOrder;
