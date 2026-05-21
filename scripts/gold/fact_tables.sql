-- =============================================================
-- Gold Layer: Fact Table (Star Schema)
-- =============================================================
USE DataWarehouse;
GO

IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_sales;

CREATE TABLE gold.fact_sales (
    order_number   NVARCHAR(50),
    product_key    INT,
    customer_key   INT,
    order_date     DATE,
    shipping_date  DATE,
    due_date       DATE,
    sales_amount   INT,
    quantity       INT,
    price          INT
);
GO

INSERT INTO gold.fact_sales
SELECT
    s.sls_ord_num  AS order_number,
    p.product_key,
    c.customer_key,
    s.sls_order_dt AS order_date,
    s.sls_ship_dt  AS shipping_date,
    s.sls_due_dt   AS due_date,
    s.sls_sales    AS sales_amount,
    s.sls_quantity AS quantity,
    s.sls_price    AS price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products  p ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c ON s.sls_cust_id = c.customer_id;
GO