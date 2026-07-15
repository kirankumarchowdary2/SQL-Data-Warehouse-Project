# Databricks Data Pipeline - Medallion Architecture

<div align="center">

![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![PySpark](https://img.shields.io/badge/PySpark-E25A1C?style=for-the-badge&logo=apache-spark&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)

**Enterprise-Grade Data Pipeline with Bronze → Silver → Gold Medallion Architecture**

[Overview](#overview) • [Architecture](#architecture) • [Layers](#layers) • [Setup](#setup) • [Usage](#usage)

</div>

---

## Overview

This project implements a production-ready data pipeline on Databricks using the Medallion Architecture pattern. The pipeline ingests raw data from multiple sources (CRM, ERP systems), cleanses and transforms it through multiple layers, and exposes high-quality analytical datasets.

### Key Capabilities
✅ Multi-layer data processing (Bronze → Silver → Gold)  
✅ Automated data quality validation and completeness checks  
✅ Version control integration for all transformations  
✅ Databricks Jobs for reliable job orchestration  
✅ Delta Live Tables for streaming and batch pipelines  
✅ Data lineage and governance tracking  
✅ Incremental & full load support  

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA SOURCES                             │
│         (CRM Systems, ERP Systems, APIs, Files)            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│              DATABRICKS CLUSTER                              │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  BRONZE LAYER (Raw Data Ingestion)                    │  │
│  │  ├─ Copy-Into: Load raw CSV files                     │  │
│  │  ├─ Minimal transformation                            │  │
│  │  └─ Data completeness checks                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                       ↓                                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  SILVER LAYER (Data Cleansing & Standardization)      │  │
│  │  ├─ Data cleaning & validation                        │  │
│  │  ├─ Schema standardization                            │  │
│  │  ├─ Remove nulls & duplicates                         │  │
│  │  └─ Data quality rules applied                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                       ↓                                      │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  GOLD LAYER (Analytics Ready)                         │  │
│  │  ├─ Business logic applied                            │  │
│  │  ├─ Aggregations & transformations                    │  │
│  │  ├─ Analytics & reporting tables                      │  │
│  │  └─ Performance optimized                             │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────┐
│            ANALYTICS & BUSINESS INTELLIGENCE                │
│        (Dashboards, Reports, ML Models)                     │
└──────────────────────────────────────────────────────────────┘
```

---

## Layers

### 🥉 Bronze Layer - Raw Data Ingestion

**Purpose:** Store raw data as-is from source systems with minimal transformation

**Responsibilities:**
- Load raw CSV/Parquet files from source systems (CRM, ERP)
- Use `COPY INTO` command for efficient batch loading
- Maintain 100% data fidelity - no data loss
- Track data ingestion metadata (load timestamp, source, file size)
- Implement data completeness checks
- Support both full and incremental loads

**Key Components:**
```
Bronze Schema Structure:
├─ Tables from CRM system
│  ├─ crm_sales_data
│  ├─ crm_cost_info
│  └─ crm_pd_info
└─ Tables from ERP system
   ├─ erp_cost_azure
   ├─ erp_load_alol
   └─ erp_pcp_aws
```

**Data Quality Checks:**
- Completeness validation (no missing required columns)
- Schema consistency verification
- Row count validation against source
- Try-catch error handling for failed loads

---

### 🥈 Silver Layer - Data Cleansing & Standardization

**Purpose:** Clean, validate, and standardize data for analytics

**Responsibilities:**
- Remove null values in duration and related columns
- Apply schema standardization across all tables
- Handle data type conversions (duration minutes, date formats)
- Implement conditional formatting based on data categories
- Apply business rules and data quality expectations
- Version transformations in Git for traceability

**Key Transformations:**
1. **Duration Column Processing:**
   - Extract duration minutes from raw timestamp data
   - Handle duration-minutes columns with separator
   - Cast to proper integer type
   - Replace with default value (0 for nulls)

2. **Conditional Type Formatting:**
   - Map type categories (Movie → 0, TV Show → 1)
   - Handle case-insensitive matching
   - Validate against approved categories

3. **Data Type Casting:**
   - Duration to IntegerType
   - Rating columns to proper numeric types
   - Dates to TimestampType

**Example SQL Transformation:**
```sql
SELECT 
    dt.withColumn("duration_minutes", 
        CAST(
            REGEXP_REPLACE(col("duration"), " .*", "") AS IntegerType
        )
    ).filter(col("duration_minutes").isNotNull())
FROM bronze_data dt
```

---

### 🥇 Gold Layer - Analytics Ready Data

**Purpose:** Provide business-ready, optimized data for analytics and reporting

**Responsibilities:**
- Apply business logic and aggregations
- Create dimensional and fact tables
- Optimize for query performance
- Support both historical and current state data
- Enable advanced analytics and ML models

**Gold Layer Tables:**
- Aggregated sales metrics by region/date
- Customer analytics tables
- Product performance metrics
- Trend analysis tables
- Data marts for specific business domains

---

## Project Structure

```
databricks-pipeline/
├── README.md                              # This file
├── .gitignore                             # Git ignore rules
│
├── notebooks/
│   ├── 01_bronze_layer.py                # Raw data ingestion
│   ├── 02_silver_layer.py                # Data cleansing & validation
│   ├── 03_gold_layer.py                  # Analytics transformations
│   └── 04_data_quality_checks.py         # Quality validation framework
│
├── jobs/
│   ├── bronze_ingestion_job.json         # Bronze layer job config
│   ├── silver_transformation_job.json    # Silver layer job config
│   └── gold_analytics_job.json           # Gold layer job config
│
├── pipelines/
│   ├── medallion_pipeline.json           # End-to-end pipeline
│   └── pipeline_config.yaml              # Pipeline parameters
│
├── src/
│   ├── data_quality.py                   # QC functions
│   ├── transformations.py                # Transformation utilities
│   └── utils.py                          # Helper functions
│
├── config/
│   ├── database_config.yaml              # Database settings
│   ├── source_config.yaml                # Source system configs
│   └── parameters.json                   # Job parameters
│
└── docs/
    ├── ARCHITECTURE.md                   # Detailed architecture
    ├── DATA_DICTIONARY.md                # Column definitions
    ├── TRANSFORMATION_LOGIC.md           # Business rules
    └── TROUBLESHOOTING.md                # Common issues
```

---

## Prerequisites

- ✅ **Databricks Workspace** (Premium tier recommended)
- ✅ **Databricks Cluster** (Runtime 11.3 or higher)
- ✅ **Source data** (CSV/Parquet files accessible from cluster)
- ✅ **Databricks CLI** for notebook management
- ✅ **Git** for version control
- ✅ **Python 3.8+** for local development

---

## Setup & Installation

### 1. Clone Repository & Set Up Databricks

```bash
git clone https://github.com/yourusername/databricks-pipeline.git
cd databricks-pipeline
```

### 2. Create Databricks Cluster

```bash
# Create cluster with proper configuration
databricks clusters create \
  --json @cluster_config.json
```

**Recommended Cluster Config:**
```json
{
  "cluster_name": "medallion-pipeline-cluster",
  "spark_version": "11.3.x-scala2.12",
  "node_type_id": "i3.xlarge",
  "num_workers": 4,
  "autoscale": {
    "min_workers": 2,
    "max_workers": 8
  },
  "spark_conf": {
    "spark.databricks.delta.preview.enabled": "true"
  }
}
```

### 3. Initialize Databricks Schemas

```python
# Run in Databricks notebook
spark.sql("CREATE SCHEMA IF NOT EXISTS bronze")
spark.sql("CREATE SCHEMA IF NOT EXISTS silver")
spark.sql("CREATE SCHEMA IF NOT EXISTS gold")
```

### 4. Import Notebooks

```bash
# Import all notebooks to Databricks workspace
databricks workspace import_directory ./notebooks /Users/your-email/medallion-pipeline
```

### 5. Configure Source Data Access

```python
# In your notebook, configure mount or ADLS access
dbutils.fs.mount(
  source = "abfss://container@storage.dfs.core.windows.net/",
  mount_point = "/mnt/data",
  extra_configs = {"fs.azure.account.key.storage.dfs.core.windows.net": "key"}
)
```

---

## Usage

### Running Individual Notebooks

#### Bronze Layer - Data Ingestion
```python
# Notebook: 01_bronze_layer.py
# Load raw data using COPY INTO

spark.sql("""
  COPY INTO bronze.crm_sales_data
  FROM 's3://source-bucket/crm/sales.csv'
  FILEFORMAT = CSV
  FORMAT_OPTIONS ('inferSchema' = 'true', 'header' = 'true')
  COPY_OPTIONS ('mergeSchema' = 'true')
""")
```

#### Silver Layer - Data Cleansing
```python
# Notebook: 02_silver_layer.py
# Apply data quality transformations

df = spark.read.table("bronze.crm_sales_data")

# Remove nulls and apply transformations
silver_df = (df
  .filter(col("duration_minutes").isNotNull())
  .withColumn("type_flag", 
    when(lower(col("type")) == "movie", 0)
    .when(lower(col("type")) == "tv show", 1)
    .otherwise(-1)
  )
)

silver_df.write.mode("overwrite").saveAsTable("silver.crm_sales_data")
```

#### Gold Layer - Analytics
```python
# Notebook: 03_gold_layer.py
# Create aggregated analytics tables

gold_df = spark.sql("""
  SELECT 
    date_trunc('month', load_date) as month,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    SUM(amount) as total_revenue
  FROM silver.crm_sales_data
  GROUP BY date_trunc('month', load_date)
""")

gold_df.write.mode("overwrite").saveAsTable("gold.sales_summary")
```

### Creating Databricks Jobs

#### Bronze Layer Job
```bash
databricks jobs create --json '{
  "name": "bronze-ingestion-job",
  "new_cluster": {
    "spark_version": "11.3.x-scala2.12",
    "node_type_id": "i3.xlarge",
    "num_workers": 2
  },
  "notebook_task": {
    "notebook_path": "/Users/your-email/medallion-pipeline/01_bronze_layer"
  },
  "schedule": {
    "quartz_cron_expression": "0 0 * * * ?",
    "timezone_id": "UTC"
  }
}'
```

#### Silver Layer Job (Depends on Bronze)
```bash
databricks jobs create --json '{
  "name": "silver-transformation-job",
  "new_cluster": {...},
  "notebook_task": {
    "notebook_path": "/Users/your-email/medallion-pipeline/02_silver_layer"
  },
  "depends_on": [
    {"job_id": <bronze-job-id>}
  ]
}'
```

#### Gold Layer Job (Depends on Silver)
```bash
databricks jobs create --json '{
  "name": "gold-analytics-job",
  "new_cluster": {...},
  "notebook_task": {
    "notebook_path": "/Users/your-email/medallion-pipeline/03_gold_layer"
  },
  "depends_on": [
    {"job_id": <silver-job-id>}
  ]
}'
```

### Running Pipeline Sequence

```bash
# Trigger the pipeline - jobs run sequentially based on dependencies
databricks jobs run-now --job-id <bronze-job-id>

# Monitor job runs
databricks runs get-output --run-id <run-id>

# Check job status
databricks jobs list-runs --job-id <bronze-job-id> --limit 5
```

### Using Databricks Pipelines (Advanced)

```python
# Create end-to-end pipeline with Delta Live Tables
import dlt

@dlt.table(
  comment="Raw data from CRM source",
  schema="bronze"
)
def crm_raw_data():
  return spark.read.format("csv").load("/mnt/data/crm_sales.csv")

@dlt.table(
  comment="Cleaned CRM data",
  schema="silver"
)
@dlt.expect_all({"valid_duration": "duration_minutes > 0"})
def crm_cleaned_data():
  return spark.sql("""
    SELECT * FROM crm_raw_data
    WHERE duration_minutes IS NOT NULL
  """)

@dlt.table(
  comment="Analytics ready data",
  schema="gold"
)
def crm_analytics():
  return spark.sql("""
    SELECT 
      date_trunc('day', release_date) as day,
      COUNT(*) as record_count
    FROM crm_cleaned_data
    GROUP BY date_trunc('day', release_date)
  """)
```

---

## Data Quality Checks

### Try-Catch Error Handling

```python
# Handle load failures gracefully
try:
    spark.sql("""
      COPY INTO bronze.crm_sales_data
      FROM 's3://bucket/crm/sales.csv'
      FILEFORMAT = CSV
    """)
    print("✓ Bronze load completed successfully")
except Exception as e:
    print(f"✗ Bronze load failed: {str(e)}")
    # Log error and continue
    dbutils.notebook.exit("ERROR: Bronze load failed")
```

### Completeness Validation

```python
# Validate all required columns are present
required_columns = ['id', 'date', 'amount', 'duration_minutes']

for col in required_columns:
    count = spark.sql(f"SELECT COUNT(*) FROM silver.data WHERE {col} IS NULL").collect()[0][0]
    if count > 0:
        print(f"⚠ Warning: {count} NULL values in {col}")
```

### Schema Versioning

```python
# Track schema changes in Git
schema_version = "v2.1"
schema_hash = spark.table("silver.crm_sales_data").schema.json()

# Log schema changes
with open("schemas/silver_v2.1.json", "w") as f:
    f.write(schema_hash)

# Commit to Git
# git add schemas/
# git commit -m "Update silver schema to v2.1"
```

---

## Monitoring & Troubleshooting

### View Job Runs
```bash
# List all job runs
databricks jobs list-runs --job-id <job-id> --limit 10

# Get detailed run information
databricks runs get --run-id <run-id>

# Stream job output
databricks runs get-output --run-id <run-id>
```

### Check Data Quality Metrics
```python
# Verify record counts at each layer
bronze_count = spark.table("bronze.crm_sales_data").count()
silver_count = spark.table("silver.crm_sales_data").count()
gold_count = spark.table("gold.sales_summary").count()

print(f"Bronze: {bronze_count} | Silver: {silver_count} | Gold: {gold_count}")
```

### Monitor Cluster Performance
```bash
# Get cluster metrics
databricks clusters get --cluster-id <cluster-id>

# List active clusters
databricks clusters list
```

### Common Issues

**Issue:** Jobs fail with timeout
- **Solution:** Increase cluster size or optimize query performance

**Issue:** NULL values causing failures
- **Solution:** Add explicit null handling with `.filter()` or `COALESCE()`

**Issue:** Schema mismatch errors
- **Solution:** Use `mergeSchema` option in COPY INTO or validate schema before load

---

## Best Practices

### Performance Optimization
- Partition data by date for faster queries
- Use Z-order clustering for frequently filtered columns
- Enable Delta Lake caching for repeated queries
- Monitor cluster utilization and scale dynamically

### Data Governance
- Version all transformations in Git
- Document business logic in code comments
- Maintain data lineage across layers
- Track schema changes and impacts

### Reliability
- Implement comprehensive error handling
- Add data quality checkpoints at each layer
- Use job dependencies for sequential execution
- Monitor data freshness and SLAs

### Maintainability
- Keep notebooks focused on single responsibility
- Use parameters for environment-specific configs
- Write reusable transformation functions
- Document data sources and lineage

---

## Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and test thoroughly
3. Update documentation
4. Commit with clear messages: `git commit -m "Add feature description"`
5. Push and create Pull Request

---

## License

MIT License - see LICENSE file for details

---

## Support & Resources

📚 **Documentation:**
- [Databricks Documentation](https://docs.databricks.com/)
- [PySpark API Reference](https://spark.apache.org/docs/latest/api/python/)
- [Delta Lake Guide](https://docs.delta.io/)

🔗 **Links:**
- [Medallion Architecture Pattern](https://databricks.com/blog/2022/06/24/data-lakehouse-medallion-architecture-best-practices.html)
- [Databricks CLI Reference](https://docs.databricks.com/dev-tools/cli/)

💬 **Questions?**
- GitHub Issues: [Create an issue](https://github.com/yourusername/databricks-pipeline/issues)
- Email: your-email@example.com

---

<div align="center">

**Built with ❤️ using Databricks & PySpark**

⭐ If this helped you, please star the repository!

</div>
