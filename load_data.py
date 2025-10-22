#!/usr/bin/env python3
"""
Minimal CSV Data Loader for Azure DevOps Pipeline
Loads CSV data into Azure SQL Database using pandas and pyodbc
"""

import os
import pandas as pd
import pymssql
import sys

def load_csv_to_sql():
    """Load CSV files into Azure SQL Database"""
    
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
        
        # Load BrandDetail data
        print("📊 Loading BrandDetail data...")
        df_brand = pd.read_csv("brand-detail-url-etc_0_0_0.csv")
        df_brand = df_brand.fillna('')
        
        insert_sql = """
        INSERT INTO BrandDetail 
        (BRAND_ID, BRAND_NAME, BRAND_TYPE, BRAND_URL_ADDR, INDUSTRY_NAME, SUBINDUSTRY_ID, SUBINDUSTRY_NAME)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        data_tuples = [tuple(row) for row in df_brand.values]
        cursor.executemany(insert_sql, data_tuples)
        connection.commit()
        print(f"✅ Loaded {len(data_tuples)} BrandDetail records")
        
        # Load DailySpend data
        print("📊 Loading DailySpend data...")
        df_spend = pd.read_csv("2021-01-19--data_01be88c2-0306-48b3-0042-fa0703282ad6_1304_5_0.csv")
        df_spend = df_spend.fillna(0)
        df_spend['TRANS_DATE'] = pd.to_datetime(df_spend['TRANS_DATE']).dt.date
        df_spend['VERSION'] = pd.to_datetime(df_spend['VERSION']).dt.date
        
        insert_sql = """
        INSERT INTO DailySpend 
        (BRAND_ID, BRAND_NAME, SPEND_AMOUNT, STATE_ABBR, TRANS_COUNT, TRANS_DATE, VERSION)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        
        # Process in chunks
        chunk_size = 1000
        total_inserted = 0
        
        for i in range(0, len(df_spend), chunk_size):
            chunk = df_spend.iloc[i:i+chunk_size]
            data_tuples = [tuple(row) for row in chunk.values]
            cursor.executemany(insert_sql, data_tuples)
            connection.commit()
            total_inserted += len(data_tuples)
            print(f"📈 Loaded chunk {i//chunk_size + 1}: {len(data_tuples)} records")
        
        print(f"✅ Loaded {total_inserted} DailySpend records")
        
        # Verify data
        cursor.execute("SELECT COUNT(*) FROM BrandDetail")
        brand_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM DailySpend")
        spend_count = cursor.fetchone()[0]
        
        print(f"📊 Final counts: BrandDetail={brand_count}, DailySpend={spend_count}")
        
        connection.close()
        print("✅ Data loading completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    load_csv_to_sql()
