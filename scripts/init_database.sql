-- =============================================================
-- Database Initialization Script
-- =============================================================
-- Description : Creates the 'DataWarehouse' database from scratch
--               and provisions three layered schemas:
--               bronze, silver, and gold.
--
-- Behavior    : If 'DataWarehouse' already exists, it will be
--               forcefully dropped and recreated.
--
-- ⚠ WARNING   : This operation is IRREVERSIBLE. All existing data
--               within 'DataWarehouse' will be permanently lost.
--               Ensure valid backups exist before proceeding.
-- =============================================================

USE master;
GO

-- -------------------------------------------------------------
-- Step 1 | Drop existing 'DataWarehouse' database (if found)
-- -------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- -------------------------------------------------------------
-- Step 2 | Create a fresh 'DataWarehouse' database
-- -------------------------------------------------------------
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- -------------------------------------------------------------
-- Step 3 | Create medallion architecture schemas
--          bronze → raw ingestion layer
--          silver → cleansed & conformed layer
--          gold   → aggregated & business-ready layer
-- -------------------------------------------------------------
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
