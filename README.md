# Azure DevOps Pipeline - CSV Data Ingestion

This project demonstrates automated data ingestion from CSV files into Azure SQL Database using Azure DevOps Pipelines.

## Quick Start

### 1. Azure DevOps Pipeline Setup
1. **Create a new pipeline** in Azure DevOps
2. **Select your repository** (GitHub/Azure Repos)
3. **Choose "Existing Azure Pipelines YAML file"**
4. **Select `azure-pipelines.yml`**

### 2. Configure Pipeline Variables
In Azure DevOps → Pipelines → Library, create these variables:
- `azureSqlUsername`: Your SQL admin username
- `azureSqlPassword`: Your SQL admin password (mark as secret)

### 3. Run the Pipeline
- Click "Run pipeline"
- Monitor the execution in real-time
- Check logs in the Artifacts section

## Local Development (Optional)

### Environment Setup
Create a `.env` file with your Azure SQL credentials:
```
AZURE_SERVER=hadzikos.database.windows.net
AZURE_DATABASE=hadzikosDB
AZURE_USERNAME=your-admin-username
AZURE_PASSWORD=your-admin-password
```

### Test Locally
```bash
pip install -r requirements.txt
python test_connection.py
python ingest_data_to_azure.py
python run_validation.py
```

## Data Schema

### BrandDetail Table
- BRAND_ID (INT, PRIMARY KEY)
- BRAND_NAME (NVARCHAR)
- BRAND_TYPE (NVARCHAR)
- BRAND_URL_ADDR (NVARCHAR)
- INDUSTRY_NAME (NVARCHAR)
- SUBINDUSTRY_ID (INT)
- SUBINDUSTRY_NAME (NVARCHAR)

### DailySpend Table
- BRAND_ID (INT, FOREIGN KEY to BrandDetail)
- BRAND_NAME (NVARCHAR)
- SPEND_AMOUNT (DECIMAL)
- STATE_ABBR (NVARCHAR)
- TRANS_COUNT (DECIMAL)
- TRANS_DATE (DATE)
- VERSION (DATE)

## Troubleshooting

### Common Issues

1. **Connection Timeout**: Ensure your IP address is added to Azure SQL Database firewall rules
2. **Authentication Failed**: Double-check your username and password in the .env file
3. **Driver Not Found**: Install Microsoft ODBC Driver 18 for SQL Server
4. **Permission Denied**: Ensure your user has CREATE TABLE and INSERT permissions

### Logs
The script creates a `data_ingestion.log` file with detailed information about the ingestion process.

## Files

### Core Pipeline Files
- `azure-pipelines.yml` - Main Azure DevOps pipeline configuration
- `PIPELINE_SETUP_GUIDE.md` - Detailed setup instructions

### Data Files
- `brand-detail-url-etc_0_0_0.csv` - Brand detail data (13,324 records)
- `2021-01-19--data_01be88c2-0306-48b3-0042-fa0703282ad6_1304_5_0.csv` - Daily spend data (141,561 records)

### Python Scripts
- `load_data.py` - Minimal CSV data loader for Azure DevOps pipeline

### SQL Scripts
- `create_tables_only.sql` - Database table creation script
- `validation_queries.sql` - Sample queries for data validation (run separately)
