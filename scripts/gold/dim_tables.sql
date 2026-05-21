-- =============================================================
-- Gold Layer: Dimension Tables (Star Schema)
-- =============================================================
USE DataWarehouse;
GO

-- =============================================================
-- 1. gold.dim_customers
-- =============================================================
IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;

CREATE TABLE gold.dim_customers (
    customer_key    INT IDENTITY(1,1) PRIMARY KEY,
    customer_id     INT,
    customer_number NVARCHAR(50),
    first_name      NVARCHAR(50),
    last_name       NVARCHAR(50),
    country         NVARCHAR(50),
    marital_status  NVARCHAR(50),
    gender          NVARCHAR(50),
    birthdate       DATE,
    create_date     DATE
);
GO

INSERT INTO gold.dim_customers
SELECT
    c.cst_id              AS customer_id,
    c.cst_key             AS customer_number,
    c.cst_firstname       AS first_name,
    c.cst_lastname        AS last_name,
    l.cntry               AS country,
    c.cst_marital_status  AS marital_status,
    CASE
        WHEN c.cst_gndr != 'Unknown' THEN c.cst_gndr
        ELSE COALESCE(e.gen, 'Unknown')
    END                   AS gender,
    e.bdate               AS birthdate,
    c.cst_create_date     AS create_date
FROM silver.crm_cust_info c
LEFT JOIN silver.erp_cust_az12 e ON c.cst_key = e.cid
LEFT JOIN silver.erp_loc_a101  l ON c.cst_key = l.cid;
GO

-- =============================================================
-- 2. gold.dim_products
-- =============================================================
IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;

CREATE TABLE gold.dim_products (
    product_key     INT IDENTITY(1,1) PRIMARY KEY,
    product_id      INT,
    product_number  NVARCHAR(50),
    product_name    NVARCHAR(50),
    category_id     NVARCHAR(50),
    category        NVARCHAR(50),
    subcategory     NVARCHAR(50),
    maintenance     NVARCHAR(50),
    cost            INT,
    product_line    NVARCHAR(50),
    start_date      DATE
);
GO

INSERT INTO gold.dim_products
SELECT
    p.prd_id       AS product_id,
    p.prd_key      AS product_number,
    p.prd_nm       AS product_name,
    p.cat_id       AS category_id,
    c.cat          AS category,
    c.subcat       AS subcategory,
    c.maintenance  AS maintenance,
    p.prd_cost     AS cost,
    p.prd_line     AS product_line,
    p.prd_start_dt AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 c ON p.cat_id = c.id
WHERE p.prd_end_dt IS NULL;
GO