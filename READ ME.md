# Customer Intelligence Platform – Data Analyst Project

## Overview
End-to-end data analytics project using the Olist Brazilian E-Commerce dataset. The goal is to transform raw e-commerce data into actionable business insights to improve customer retention, revenue performance, and product analysis.

## Business Objectives
- Analyze customer behavior and purchasing patterns
- Build RFM segmentation to identify customer value
- Detect churned and at-risk customers
- Identify top-performing products and categories
- Build KPIs for business decision-making

## Dataset
Source: Olist Brazilian E-Commerce (Kaggle)

Main tables used:
customers, orders, order_items, payments, reviews, products, sellers, geolocation, product category translation

## Architecture
PostgreSQL database (ecommerce_db)
- raw schema: ingestion of CSV files via Python
- clean schema: cleaned and transformed data via SQL
- analytics schema: business-ready tables (KPIs, RFM, churn, product performance)

## Tech Stack
Python (Pandas, SQLAlchemy)  
PostgreSQL  
SQL (ETL, cleaning, analytics)  
Power BI (dashboarding)  
Git / GitHub  
dotenv

## Data Pipeline
1. Ingestion: CSV files loaded into PostgreSQL (raw schema) using Python
2. Cleaning: SQL transformations, joins, type conversions, feature engineering
3. Analytics: creation of KPI tables, RFM segmentation, churn analysis, product performance
4. Visualization: Power BI dashboards connected to PostgreSQL

## Key Features

KPIs:
- Total revenue
- Number of orders
- Average order value
- Monthly revenue evolution

Customer Analytics:
- RFM segmentation (Champions, Loyal, At Risk, Lost, etc.)
- Customer value analysis
- Churn detection model

Product Analytics:
- Top revenue categories
- Revenue vs price analysis
- Pareto distribution

## Power BI Dashboard
Pages:
- Overview (KPIs, revenue trend, top categories)
- Customer Segmentation (RFM distribution, behavior analysis)
- Product Analysis (scatter plot revenue vs price, performance ranking)

## Project Structure
data-analyst-project/
data/raw/
notebooks/
scripts/ingestion.py
sql/schema.sql
sql/cleaning.sql
sql/analytics.sql
dashboard/
README.md
requirements.txt
.env

## How to Run
pip install -r requirements.txt  
python scripts/ingestion.py  

Create PostgreSQL database: ecommerce_db  
Run SQL scripts in order: schema → cleaning → analytics  
Connect Power BI to PostgreSQL

## Skills Demonstrated
- End-to-end data pipeline (ETL)
- SQL advanced transformations
- Data modeling (star schema)
- Business intelligence (Power BI)
- Customer segmentation (RFM)
- Churn analysis

## Future Improvements
- Automate pipeline with Airflow or Prefect
- Add machine learning churn prediction
- Deploy dashboard online
- Real-time data ingestion pipeline

## Author
Data Analyst Portfolio Project