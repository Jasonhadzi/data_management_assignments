-- Azure Data Ingestion Validation Queries
-- Run these queries to verify that data was ingested correctly

-- 1. Basic record counts
SELECT 'BrandDetail' as TableName, COUNT(*) as RecordCount FROM BrandDetail
UNION ALL
SELECT 'DailySpend' as TableName, COUNT(*) as RecordCount FROM DailySpend;

-- 2. Sample data from BrandDetail table
SELECT TOP 10 * FROM BrandDetail;

-- 3. Sample data from DailySpend table
SELECT TOP 10 * FROM DailySpend;

-- 4. Total spend by state (top 10)
SELECT 
    STATE_ABBR,
    COUNT(DISTINCT BRAND_ID) as UniqueBrands,
    SUM(SPEND_AMOUNT) as TotalSpend,
    SUM(TRANS_COUNT) as TotalTransactions
FROM DailySpend
GROUP BY STATE_ABBR
ORDER BY TotalSpend DESC;

-- 5. Top spending brands across all states
SELECT 
    b.BRAND_NAME,
    b.INDUSTRY_NAME,
    COUNT(DISTINCT d.STATE_ABBR) as StatesCount,
    SUM(d.SPEND_AMOUNT) as TotalSpend,
    SUM(d.TRANS_COUNT) as TotalTransactions
FROM BrandDetail b
JOIN DailySpend d ON b.BRAND_ID = d.BRAND_ID
GROUP BY b.BRAND_NAME, b.INDUSTRY_NAME
ORDER BY TotalSpend DESC;

-- 6. Industry analysis
SELECT 
    INDUSTRY_NAME,
    COUNT(DISTINCT BRAND_ID) as BrandCount,
    SUM(d.SPEND_AMOUNT) as TotalSpend
FROM BrandDetail b
JOIN DailySpend d ON b.BRAND_ID = d.BRAND_ID
GROUP BY INDUSTRY_NAME
ORDER BY TotalSpend DESC;

-- 7. Data quality checks
-- Check for any NULL values in critical fields
SELECT 'BrandDetail NULL Checks' as CheckType, 
       SUM(CASE WHEN BRAND_ID IS NULL THEN 1 ELSE 0 END) as NullBrandIds,
       SUM(CASE WHEN BRAND_NAME IS NULL OR BRAND_NAME = '' THEN 1 ELSE 0 END) as NullBrandNames
FROM BrandDetail
UNION ALL
SELECT 'DailySpend NULL Checks' as CheckType,
       SUM(CASE WHEN BRAND_ID IS NULL THEN 1 ELSE 0 END) as NullBrandIds,
       SUM(CASE WHEN SPEND_AMOUNT IS NULL THEN 1 ELSE 0 END) as NullSpendAmounts
FROM DailySpend;

-- 8. Foreign key integrity check
SELECT 
    'Orphaned DailySpend records' as CheckType,
    COUNT(*) as Count
FROM DailySpend d
LEFT JOIN BrandDetail b ON d.BRAND_ID = b.BRAND_ID
WHERE b.BRAND_ID IS NULL;

-- 9. Date range analysis
SELECT 
    MIN(TRANS_DATE) as EarliestDate,
    MAX(TRANS_DATE) as LatestDate,
    COUNT(DISTINCT TRANS_DATE) as UniqueDates
FROM DailySpend;

-- 10. Brand performance by state (example: California)
SELECT 
    b.BRAND_NAME,
    b.INDUSTRY_NAME,
    d.SPEND_AMOUNT,
    d.TRANS_COUNT,
    d.TRANS_DATE
FROM BrandDetail b
JOIN DailySpend d ON b.BRAND_ID = d.BRAND_ID
WHERE d.STATE_ABBR = 'CA'
ORDER BY d.SPEND_AMOUNT DESC;
