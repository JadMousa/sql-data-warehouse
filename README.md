# Data Warehouse Project

A modern data warehouse built with SQL Server and T-SQL, implementing 
Medallion Architecture (Bronze → Silver → Gold) with a Star Schema 
in the Gold layer using a sales/retail domain.

---

## Project Overview

This project demonstrates end-to-end data warehouse development including:
- Loading raw data from ERP and CRM source systems
- Cleaning and transforming data through multiple layers
- Building an analytical Star Schema for business intelligence

---

## Architecture
```
Bronze Layer → Silver Layer → Gold Layer
(Raw Data)     (Cleaned)      (Star Schema)
```

### Medallion Architecture
- **Bronze** — Raw data loaded as-is from CSV source files (CRM + ERP)
- **Silver** — Cleaned, standardized, and deduplicated data
- **Gold** — Business-ready Star Schema with dimension and fact tables

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| SQL Server | Database engine |
| T-SQL | Data transformation and modeling |
| SSMS | Query execution and database management |
| VS Code | Script editing and Git integration |
| Git/GitHub | Version control |

---

## Data Model (Gold Layer — Star Schema)
      dim_customers
           ↑
fact_sales ←———+———→ dim_products

### dim_customers
Combines CRM and ERP customer data into one clean dimension including
name, country, gender, marital status, and birthdate.

### dim_products
Combines product and category data into one clean dimension including
product name, category, subcategory, cost, and product line.

### fact_sales
Central fact table containing sales transactions with foreign keys
to both dimension tables, plus sales amount, quantity, and price.

---

## Project Structure
```
sql-data-warehouse/
│
├── datasets/               # Source CSV files (CRM + ERP) - local only
├── docs/                   # Architecture diagrams
├── scripts/
│   ├── bronze/
│   │   └── load_bronze.sql        # Raw data ingestion
│   ├── silver/
│   │   └── transform_silver.sql   # Data cleaning & transformation
│   └── gold/
│       ├── dim_tables.sql         # Dimension tables
│       └── fact_tables.sql        # Fact table
├── tests/
│   └── quality_checks.sql         # Data quality validation
└── README.md
```
---

## How to Run

1. Open SQL Server Management Studio (SSMS)
2. Run `scripts/bronze/load_bronze.sql` — creates database, schemas, loads raw data
3. Run `scripts/silver/transform_silver.sql` — cleans and transforms data
4. Run `scripts/gold/dim_tables.sql` — creates dimension tables
5. Run `scripts/gold/fact_tables.sql` — creates fact table
6. Run `tests/quality_checks.sql` — validates data quality

---

## Dataset

Source data provided by 
[DataWithBaraa](https://github.com/DataWithBaraa/sql-data-warehouse-project) — 
ERP and CRM CSV files representing a sales/retail domain.

---

## Related Projects

- [Weather ETL Pipeline](https://github.com/JadMousa/weather-etl-pipeline) — 
Python, Apache Airflow, PostgreSQL, AWS S3, Star Schema