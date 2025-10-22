-- Quick table creation script for manual CSV import
-- Run this in Azure Portal Query Editor or VS Code SQL extension

-- Create BrandDetail table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='BrandDetail' AND xtype='U')
CREATE TABLE BrandDetail (
    BRAND_ID INT PRIMARY KEY,
    BRAND_NAME NVARCHAR(255),
    BRAND_TYPE NVARCHAR(100),
    BRAND_URL_ADDR NVARCHAR(500),
    INDUSTRY_NAME NVARCHAR(255),
    SUBINDUSTRY_ID INT,
    SUBINDUSTRY_NAME NVARCHAR(255)
);

-- Create DailySpend table
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
);

-- Verify tables were created
SELECT 'Tables created successfully' as Status;
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN ('BrandDetail', 'DailySpend');
