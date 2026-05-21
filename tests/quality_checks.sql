-- =============================================================
-- Quality Checks
-- =============================================================
USE DataWarehouse;
GO

-- =============================================================
-- Bronze Layer Checks
-- =============================================================

-- Check for NULLs in customer ID
SELECT COUNT(*) AS null_cst_id
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;

-- Check for duplicate customer IDs
SELECT cst_id, COUNT(*) AS cnt
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- =============================================================
-- Silver Layer Checks
-- =============================================================

-- Check gender values are standardized
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Check marital status values are standardized
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

-- Check no future birthdates exist
SELECT COUNT(*) AS future_birthdates
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Check country values are standardized
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

-- Check sales amounts are positive
SELECT COUNT(*) AS negative_sales
FROM silver.crm_sales_details
WHERE sls_sales <= 0;

-- =============================================================
-- Gold Layer Checks
-- =============================================================

-- Check no NULLs in fact_sales keys
SELECT COUNT(*) AS null_product_keys
FROM gold.fact_sales
WHERE product_key IS NULL;

SELECT COUNT(*) AS null_customer_keys
FROM gold.fact_sales
WHERE customer_key IS NULL;

-- Check row counts match between silver and gold
SELECT COUNT(*) AS silver_sales FROM silver.crm_sales_details;
SELECT COUNT(*) AS gold_sales   FROM gold.fact_sales;

-- Check surrogate keys are unique
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;