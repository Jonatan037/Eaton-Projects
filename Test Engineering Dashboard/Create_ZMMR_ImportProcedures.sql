-- =============================================
-- Stored Procedure: Import ZMMR Scrap Data from CSV
-- This procedure imports CSV data into ZMMR_ScrapData table
-- with duplicate detection and logging
-- Database: TestEngineering
-- =============================================

USE TestEngineering;
GO

CREATE PROCEDURE sp_ImportZMMRScrapData
    @FilePath NVARCHAR(500),        -- Full path to the CSV file
    @ImportedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BatchID UNIQUEIDENTIFIER = NEWID();
    DECLARE @FileName NVARCHAR(255);
    DECLARE @RecordsImported INT = 0;
    DECLARE @RecordsSkipped INT = 0;
    DECLARE @ErrorMessage NVARCHAR(MAX) = NULL;
    
    -- Extract filename from path
    SET @FileName = RIGHT(@FilePath, CHARINDEX('\', REVERSE(@FilePath)) - 1);
    IF @FileName = @FilePath
        SET @FileName = RIGHT(@FilePath, CHARINDEX('/', REVERSE(@FilePath)) - 1);
    
    -- Create import log entry
    INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status)
    VALUES (@BatchID, @FileName, @ImportedBy, 'In Progress');
    
    BEGIN TRY
        -- Create temp table to hold CSV data
        CREATE TABLE #TempZMMR (
            zmmr_amount VARCHAR(50),
            zmmr_cost_center_code VARCHAR(50),
            zmmr_material_desc NVARCHAR(500),
            zmmr_material_number VARCHAR(100),
            zmmr_movement_type VARCHAR(20),
            zmmr_mrp_controller_desc NVARCHAR(200),
            zmmr_plant_code VARCHAR(20),
            zmmr_posting_date VARCHAR(50),
            zmmr_quantity VARCHAR(50),
            zmmr_reason_desc NVARCHAR(200),
            zmmr_users_full_name NVARCHAR(200),
            Total1 VARCHAR(50),
            Total2 VARCHAR(50)
        );
        
        -- Use BULK INSERT to load CSV
        -- Note: Adjust FIELDTERMINATOR and ROWTERMINATOR as needed
        DECLARE @SQL NVARCHAR(MAX);
        SET @SQL = N'
        BULK INSERT #TempZMMR
        FROM ''' + @FilePath + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            TABLOCK
        )';
        
        EXEC sp_executesql @SQL;
        
        -- Count total rows loaded
        DECLARE @TotalRows INT;
        SELECT @TotalRows = COUNT(*) FROM #TempZMMR;
        
        -- Insert new records (skip duplicates based on hash)
        INSERT INTO ZMMR_ScrapData (
            Amount,
            CostCenterCode,
            MaterialDescription,
            MaterialNumber,
            MovementType,
            MRPControllerDesc,
            PlantCode,
            PostingDate,
            Quantity,
            ReasonDescription,
            UserFullName,
            ImportFileName,
            ImportBatchID
        )
        SELECT 
            CAST(t.zmmr_amount AS DECIMAL(18,4)),
            LTRIM(RTRIM(t.zmmr_cost_center_code)),
            LTRIM(RTRIM(t.zmmr_material_desc)),
            LTRIM(RTRIM(t.zmmr_material_number)),
            CAST(t.zmmr_movement_type AS INT),
            LTRIM(RTRIM(t.zmmr_mrp_controller_desc)),
            LTRIM(RTRIM(t.zmmr_plant_code)),
            CAST(t.zmmr_posting_date AS DATE),
            CAST(t.zmmr_quantity AS INT),
            LTRIM(RTRIM(t.zmmr_reason_desc)),
            LTRIM(RTRIM(t.zmmr_users_full_name)),
            @FileName,
            @BatchID
        FROM #TempZMMR t
        WHERE NOT EXISTS (
            SELECT 1 FROM ZMMR_ScrapData z
            WHERE z.RowHash = HASHBYTES('SHA2_256', 
                CAST(CAST(t.zmmr_amount AS DECIMAL(18,4)) AS VARCHAR(50)) + '|' + 
                LTRIM(RTRIM(t.zmmr_cost_center_code)) + '|' + 
                LTRIM(RTRIM(t.zmmr_material_number)) + '|' + 
                t.zmmr_movement_type + '|' + 
                LTRIM(RTRIM(t.zmmr_plant_code)) + '|' + 
                CONVERT(VARCHAR(10), CAST(t.zmmr_posting_date AS DATE), 120) + '|' + 
                t.zmmr_quantity + '|' +
                ISNULL(LTRIM(RTRIM(t.zmmr_users_full_name)), '')
            )
        );
        
        SET @RecordsImported = @@ROWCOUNT;
        SET @RecordsSkipped = @TotalRows - @RecordsImported;
        
        -- Update import log
        UPDATE ZMMR_ImportLog
        SET Status = 'Completed',
            RecordsImported = @RecordsImported,
            RecordsSkipped = @RecordsSkipped
        WHERE BatchID = @BatchID;
        
        -- Cleanup
        DROP TABLE #TempZMMR;
        
        -- Return summary
        SELECT 
            @BatchID AS BatchID,
            @FileName AS FileName,
            @RecordsImported AS RecordsImported,
            @RecordsSkipped AS RecordsSkipped,
            'Completed' AS Status;
            
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        
        UPDATE ZMMR_ImportLog
        SET Status = 'Failed',
            ErrorMessage = @ErrorMessage
        WHERE BatchID = @BatchID;
        
        -- Cleanup
        IF OBJECT_ID('tempdb..#TempZMMR') IS NOT NULL
            DROP TABLE #TempZMMR;
        
        -- Return error
        SELECT 
            @BatchID AS BatchID,
            @FileName AS FileName,
            0 AS RecordsImported,
            0 AS RecordsSkipped,
            'Failed' AS Status,
            @ErrorMessage AS ErrorMessage;
            
        THROW;
    END CATCH
END
GO

-- =============================================
-- Alternative: Stored Procedure for importing from pre-staged table
-- Use this when BULK INSERT isn't available (e.g., shared hosting)
-- The ASP.NET app will populate the staging table
-- =============================================

CREATE PROCEDURE sp_ImportZMMRFromStaging
    @FileName NVARCHAR(255),
    @ImportedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BatchID UNIQUEIDENTIFIER = NEWID();
    DECLARE @RecordsImported INT = 0;
    DECLARE @RecordsSkipped INT = 0;
    
    -- Create import log entry
    INSERT INTO ZMMR_ImportLog (BatchID, FileName, ImportedBy, Status)
    VALUES (@BatchID, @FileName, @ImportedBy, 'In Progress');
    
    BEGIN TRY
        -- Get count before insert
        DECLARE @BeforeCount INT;
        SELECT @BeforeCount = COUNT(*) FROM ZMMR_ScrapData;
        
        -- Insert from staging table (skip duplicates)
        INSERT INTO ZMMR_ScrapData (
            Amount, CostCenterCode, MaterialDescription, MaterialNumber,
            MovementType, MRPControllerDesc, PlantCode, PostingDate,
            Quantity, ReasonDescription, UserFullName,
            ImportFileName, ImportBatchID
        )
        SELECT 
            s.Amount, s.CostCenterCode, s.MaterialDescription, s.MaterialNumber,
            s.MovementType, s.MRPControllerDesc, s.PlantCode, s.PostingDate,
            s.Quantity, s.ReasonDescription, s.UserFullName,
            @FileName, @BatchID
        FROM ZMMR_StagingData s
        WHERE NOT EXISTS (
            SELECT 1 FROM ZMMR_ScrapData z
            WHERE z.Amount = s.Amount
              AND z.CostCenterCode = s.CostCenterCode
              AND z.MaterialNumber = s.MaterialNumber
              AND z.MovementType = s.MovementType
              AND z.PlantCode = s.PlantCode
              AND z.PostingDate = s.PostingDate
              AND z.Quantity = s.Quantity
              AND ISNULL(z.UserFullName, '') = ISNULL(s.UserFullName, '')
        );
        
        SET @RecordsImported = @@ROWCOUNT;
        
        -- Calculate skipped
        DECLARE @StagingCount INT;
        SELECT @StagingCount = COUNT(*) FROM ZMMR_StagingData;
        SET @RecordsSkipped = @StagingCount - @RecordsImported;
        
        -- Clear staging table
        TRUNCATE TABLE ZMMR_StagingData;
        
        -- Update log
        UPDATE ZMMR_ImportLog
        SET Status = 'Completed',
            RecordsImported = @RecordsImported,
            RecordsSkipped = @RecordsSkipped
        WHERE BatchID = @BatchID;
        
        SELECT @BatchID AS BatchID, @RecordsImported AS RecordsImported, 
               @RecordsSkipped AS RecordsSkipped, 'Completed' AS Status;
               
    END TRY
    BEGIN CATCH
        UPDATE ZMMR_ImportLog
        SET Status = 'Failed', ErrorMessage = ERROR_MESSAGE()
        WHERE BatchID = @BatchID;
        
        THROW;
    END CATCH
END
GO

-- Staging table for ASP.NET to populate before calling sp_ImportZMMRFromStaging
CREATE TABLE ZMMR_StagingData (
    Amount DECIMAL(18,4) NOT NULL,
    CostCenterCode VARCHAR(20) NOT NULL,
    MaterialDescription NVARCHAR(200) NULL,
    MaterialNumber VARCHAR(50) NOT NULL,
    MovementType INT NOT NULL,
    MRPControllerDesc NVARCHAR(100) NULL,
    PlantCode VARCHAR(10) NOT NULL,
    PostingDate DATE NOT NULL,
    Quantity INT NOT NULL,
    ReasonDescription NVARCHAR(100) NULL,
    UserFullName NVARCHAR(100) NULL
);
GO

PRINT 'Import stored procedures created successfully.';
