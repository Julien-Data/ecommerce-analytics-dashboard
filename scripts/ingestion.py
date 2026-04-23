import pandas as pd
from sqlalchemy import create_engine

from dotenv import load_dotenv
import os

load_dotenv()  # charge le .env

DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

engine = create_engine(f'postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}')

# --- 2. Liste des CSV et tables RAW ---
csv_table_map = {
    "data/raw/olist_customers_dataset.csv": "raw_customers",
    "data/raw/olist_geolocation_dataset.csv": "raw_geolocation",
    "data/raw/olist_order_items_dataset.csv": "raw_order_items",
    "data/raw/olist_order_payments_dataset.csv": "raw_payments",
    "data/raw/olist_order_reviews_dataset.csv": "raw_reviews",
    "data/raw/olist_orders_dataset.csv": "raw_orders",
    "data/raw/olist_products_dataset.csv": "raw_products",
    "data/raw/olist_sellers_dataset.csv": "raw_sellers",
    "data/raw/product_category_name_translation.csv": "raw_category_translation"
}

# --- 3. Lecture et insertion ---
for csv_path, table_name in csv_table_map.items():
    print(f"Ingestion de {csv_path} dans la table {table_name} ...")
    df = pd.read_csv(csv_path, encoding='utf-8-sig')
    df.to_sql(table_name, engine, schema="raw", if_exists='replace', index=False)
    print(f"Terminé : {table_name} ({len(df)} lignes)")