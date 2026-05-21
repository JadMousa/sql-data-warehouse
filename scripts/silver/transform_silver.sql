-- =============================================================
-- Silver Layer Transformations
-- =============================================================
USE DataWarehouse;
GO

-- =============================================================
-- 1. silver.crm_cust_info (CRM Customers)
-- =============================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE
);
GO

INSERT INTO silver.crm_cust_info
SELECT
    cst_id,
    TRIM(cst_key)          AS cst_key,
    TRIM(cst_firstname)    AS cst_firstname,
    TRIM(cst_lastname)     AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'Unknown'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE rn = 1;
GO

-- =============================================================
-- 2. silver.crm_prd_info (CRM Products)
-- =============================================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id         INT,
    cat_id         NVARCHAR(50),
    prd_key        NVARCHAR(50),
    prd_nm         NVARCHAR(50),
    prd_cost       INT,
    prd_line       NVARCHAR(50),
    prd_start_dt   DATE,
    prd_end_dt     DATE
);
GO

INSERT INTO silver.crm_prd_info
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key))         AS prd_key,
    TRIM(prd_nm)                                 AS prd_nm,
    ISNULL(prd_cost, 0)                          AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        ELSE 'Unknown'
    END                                          AS prd_line,
    CAST(prd_start_dt AS DATE)                   AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1 AS DATE)                               AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_id IS NOT NULL;
GO

-- =============================================================
-- 3. silver.crm_sales_details (CRM Sales)
-- =============================================================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

INSERT INTO silver.crm_sales_details
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE
        WHEN sls_sales <= 0 OR sls_sales IS NULL
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price <= 0 OR sls_price IS NULL
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;
GO

-- =============================================================
-- 4. silver.erp_cust_az12 (ERP Customer Details)
-- =============================================================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

INSERT INTO silver.erp_cust_az12
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
        ELSE 'Unknown'
    END AS gen
FROM bronze.erp_cust_az12;
GO

-- =============================================================
-- 5. silver.erp_loc_a101 (ERP Customer Locations)
-- =============================================================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

INSERT INTO silver.erp_loc_a101
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE'            THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA')  THEN 'United States'
        WHEN TRIM(cntry) = 'GB'            THEN 'United Kingdom'
        WHEN TRIM(cntry) = 'FR'            THEN 'France'
        WHEN TRIM(cntry) = 'AU'            THEN 'Australia'
        WHEN TRIM(cntry) = 'CA'            THEN 'Canada'
        WHEN TRIM(cntry) = ''
          OR cntry IS NULL                 THEN 'Unknown'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;
GO

-- =============================================================
-- 6. silver.erp_px_cat_g1v2 (ERP Product Categories)
-- =============================================================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO

INSERT INTO silver.erp_px_cat_g1v2
SELECT
    id,
    TRIM(cat)         AS cat,
    TRIM(subcat)      AS subcat,
    TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2;
GO