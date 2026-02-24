-- ===============================================================================
-- Quality Checks : Silver Layer
-- ===============================================================================
-- Description : Validates data consistency, accuracy, and standardization across
--               all tables in the 'silver' schema. Checks are organized by table
--               and cover the following categories:
--                 - NULL or duplicate primary keys
--                 - Unwanted leading/trailing spaces in string fields
--                 - Data standardization and value consistency
--                 - Invalid date ranges and illogical date ordering
--                 - Cross-field consistency (e.g. sales = quantity × price)
--
-- Usage       : Run these checks after loading the Silver Layer.
--               Any query returning results indicates a data quality issue
--               that should be investigated and resolved before proceeding.
-- ===============================================================================


-- ============================================================================
-- Table | silver.crm_cust_info
-- ============================================================================

-- Check : NULL or duplicate primary key (cst_id)
-- Expect: No results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check : Unwanted leading/trailing spaces in cst_key
-- Expect: No results
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check : Distinct marital status values — verify only 'Single', 'Married', 'n/a'
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


-- ============================================================================
-- Table | silver.crm_prd_info
-- ============================================================================

-- Check : NULL or duplicate primary key (prd_id)
-- Expect: No results
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check : Unwanted leading/trailing spaces in prd_nm
-- Expect: No results
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check : NULL or negative values in prd_cost
-- Expect: No results
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check : Distinct product line values — verify only 'Mountain', 'Road', 'Other Sales', 'Touring', 'n/a'
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

-- Check : Illogical date ordering — end date precedes start date
-- Expect: No results
SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ============================================================================
-- Table | silver.crm_sales_details
-- ============================================================================

-- Check : Invalid raw date values in bronze source before casting
--         Flags values that are zero, not 8 digits, or fall outside plausible range
-- Expect: No results
SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check : Illogical date ordering — order date is later than ship or due date
-- Expect: No results
SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check : Cross-field consistency — sales must equal quantity × price
--         Also flags any NULL or non-positive values in key financial fields
-- Expect: No results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales    IS NULL OR sls_sales    <= 0
   OR sls_quantity IS NULL OR sls_quantity <= 0
   OR sls_price    IS NULL OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ============================================================================
-- Table | silver.erp_cust_az12
-- ============================================================================

-- Check : Out-of-range birthdates — must fall between 1924-01-01 and today
-- Expect: No results
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

-- Check : Distinct gender values — verify only 'Female', 'Male', 'n/a'
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- ============================================================================
-- Table | silver.erp_loc_a101
-- ============================================================================

-- Check : Distinct country values — verify codes are fully decoded and consistent
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ============================================================================
-- Table | silver.erp_px_cat_g1v2
-- ============================================================================

-- Check : Unwanted leading/trailing spaces across all string columns
-- Expect: No results
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat         != TRIM(cat)
   OR subcat      != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Check : Distinct maintenance values — verify standardization and completeness
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;
