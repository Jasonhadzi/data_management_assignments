#!/usr/bin/env python3
"""
Demo CSV Data Loader for Azure DevOps Pipeline
Loads first 50 records from each CSV into Azure SQL Database for demonstration purposes
"""

import os
import pandas as pd
import pymssql
import sys
from dotenv import load_dotenv

def load_csv_to_sql():
    """Load CSV files into Azure SQL Database (Demo version - first 50 records only)"""
    
    # Load environment variables from .env file (for local testing)
    load_dotenv()
    
    # Get connection parameters from environment variables
    server = os.getenv('AZURE_SERVER')
    database = os.getenv('AZURE_DATABASE') 
    username = os.getenv('AZURE_USERNAME')
    password = os.getenv('AZURE_PASSWORD')
    
    if not all([server, database, username, password]):
        print("❌ Missing environment variables")
        sys.exit(1)
    
    try:
        print("🔗 Connecting to Azure SQL Database...")
        connection = pymssql.connect(
            server=server,
            database=database,
            user=username,
            password=password,
            timeout=30
        )
        cursor = connection.cursor()
        print("✅ Connected successfully!")
        
        # Create tables if they don't exist
        print("📊 Creating database tables...")
        
        # Create BrandDetail table
        brand_detail_sql = """
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BrandDetail' AND xtype='U')
        CREATE TABLE BrandDetail (
            BRAND_ID INT PRIMARY KEY,
            BRAND_NAME NVARCHAR(255),
            BRAND_TYPE NVARCHAR(100),
            BRAND_URL_ADDR NVARCHAR(500),
            INDUSTRY_NAME NVARCHAR(255),
            SUBINDUSTRY_ID INT,
            SUBINDUSTRY_NAME NVARCHAR(255)
        )
        """
        
        # Create DailySpend table
        daily_spend_sql = """
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='DailySpend' AND xtype='U')
        CREATE TABLE DailySpend (
            ID INT IDENTITY(1,1) PRIMARY KEY,
            BRAND_ID INT,
            BRAND_NAME NVARCHAR(255),
            SPEND_AMOUNT DECIMAL(18,2),
            STATE_ABBR NVARCHAR(10),
            TRANS_COUNT DECIMAL(18,2),
            TRANS_DATE DATE,
            VERSION DATE,
            FOREIGN KEY (BRAND_ID) REFERENCES BrandDetail(BRAND_ID)
        )
        """
        
        cursor.execute(brand_detail_sql)
        cursor.execute(daily_spend_sql)
        connection.commit()
        print("✅ Tables created successfully!")
        
        # Clear existing data for demo purposes
        print("🧹 Clearing existing data for demo...")
        cursor.execute("DELETE FROM DailySpend")
        cursor.execute("DELETE FROM BrandDetail")
        connection.commit()
        print("✅ Existing data cleared!")
        
        # Load BrandDetail data (first 50 records only)
        print("📊 Loading BrandDetail data (first 50 records for demo)...")
        df_brand = pd.read_csv("brand-detail-url-etc_0_0_0.csv")
        df_brand = df_brand.head(50)  # Only first 50 records
        df_brand = df_brand.fillna('')
        
        insert_sql = """
        INSERT INTO BrandDetail 
        (BRAND_ID, BRAND_NAME, BRAND_TYPE, BRAND_URL_ADDR, INDUSTRY_NAME, SUBINDUSTRY_ID, SUBINDUSTRY_NAME)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        data_tuples = [tuple(row) for row in df_brand.values]
        cursor.executemany(insert_sql, data_tuples)
        connection.commit()
        print(f"✅ Loaded {len(data_tuples)} BrandDetail records")
        
        # Load DailySpend data (first 50 records that match BrandDetail brands)
        print("📊 Loading DailySpend data (first 50 matching records for demo)...")
        df_spend = pd.read_csv("2021-01-19--data_01be88c2-0306-48b3-0042-fa0703282ad6_1304_5_0.csv")
        df_spend = df_spend.fillna(0)
        df_spend['TRANS_DATE'] = pd.to_datetime(df_spend['TRANS_DATE']).dt.date
        df_spend['VERSION'] = pd.to_datetime(df_spend['VERSION']).dt.date
        
        # Filter DailySpend to only include brands that exist in BrandDetail, then take first 50
        existing_brand_ids = set(df_brand['BRAND_ID'].tolist())
        df_spend = df_spend[df_spend['BRAND_ID'].isin(existing_brand_ids)]
        df_spend = df_spend.head(50)  # Take first 50 matching records
        print(f"   Filtered DailySpend data: {len(df_spend)} rows (matching existing brands)")
        
        insert_sql = """
        INSERT INTO DailySpend 
        (BRAND_ID, BRAND_NAME, SPEND_AMOUNT, STATE_ABBR, TRANS_COUNT, TRANS_DATE, VERSION)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        data_tuples = [tuple(row) for row in df_spend.values]
        cursor.executemany(insert_sql, data_tuples)
        connection.commit()
        print(f"✅ Loaded {len(data_tuples)} DailySpend records")
        
        # Verify data
        cursor.execute("SELECT COUNT(*) FROM BrandDetail")
        brand_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM DailySpend")
        spend_count = cursor.fetchone()[0]
        
        print(f"📊 Final counts: BrandDetail={brand_count}, DailySpend={spend_count}")
        
        # Show sample data
        print("\n📋 Sample BrandDetail data:")
        cursor.execute("SELECT TOP 3 * FROM BrandDetail")
        for row in cursor.fetchall():
            print(f"   {row}")
        
        print("\n📋 Sample DailySpend data:")
        cursor.execute("SELECT TOP 3 * FROM DailySpend")
        for row in cursor.fetchall():
            print(f"   {row}")
        
        connection.close()
        print("✅ Demo data loading completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    load_csv_to_sql()