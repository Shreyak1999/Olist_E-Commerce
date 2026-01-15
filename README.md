## 📊 Olist E-Commerce Data Analysis (SQL + Python)

### 📌 Project Overview

This project analyzes the Brazilian Olist e-commerce dataset to derive business insights related to revenue trends, customer retention, and seller performance.

The focus is on:

* Designing a clean analytical data model
* Writing production-grade SQL for business metrics
* Using Python for visualization and storytelling

### 🛠️ Tech Stack

* Database: PostgreSQL
* Query Language: SQL (CTEs, window functions, views)
* Analysis & Visualization: Python (Pandas, Matplotlib, Seaborn)
* Environment: VS Code
* Dataset Source: Kaggle – Olist Brazilian E-Commerce Dataset

### 📂 Project Structure

- Olist_E-Commerce/
- ├── .vscode/
- │   └── settings.json
- │
- ├── data/
- │   ├── raw/                -- original Kaggle CSV files
- │   └── output_csv/         -- optional SQL/Python exports
- │
- ├── notebooks/
- │   └── analysis.ipynb      -- Python analysis & visualizations
- │
- ├── outputs/
- │   ├── clv.png
- │   ├── funnel_analysis.png
- │   ├── highest_rev_indi.png
- │   └── seller_perf.png     -- saved analytical charts
- │
- ├── sql/
- │   ├── create_schema.sql
- │   ├── load_data.sql
- │   ├── create_views.sql    -- ⭐ analytical views
- │   ├── revenue_analysis.sql
- │   ├── cohort_analysis.sql
- │   ├── seller_perf.sql
- │   ├── funnel_analysis.sql
- │   ├── customer_lifetime_value.sql
- │   └── olist_postgres.session.sql
- │
- └── README.md

### 🧱 Data Model

A star schema was implemented to support analytical queries efficiently.

#### Fact Tables

- fact_orders
- fact_order_items
- fact_payments
- fact_reviews
- Dimension Tables
- dim_customers
- dim_sellers
- dim_products
- dim_date

### 📊 Analytical SQL Views

All core business metrics are exposed as PostgreSQL views to separate transformation from analysis.

#### Key Views

* monthly_revenue
    * Total revenue
    * Active customers
    * Average order value
    * Month-over-month revenue growth
* cohort_retention
    * Customer cohorts based on first purchase month
    * Retention tracked across subsequent months
* seller_performance
    * Seller-level revenue
    * Order volume
    * On-time delivery percentage
    * Average customer review score

### 📈 Key Business Insights
* Revenue is highly concentrated among a small subset of sellers
* Sellers with lower on-time delivery rates tend to receive poorer reviews
* Significant customer churn occurs after the first purchase month
* Revenue growth exhibits clear monthly seasonality
* Funnel analysis highlights drop-offs between order placement and delivery
* Each insight is backed by SQL metrics and Python visualizations