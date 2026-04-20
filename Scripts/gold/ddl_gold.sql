/*
===============================================================================
DDL Script:create Gold views for Sales business object
===============================================================================
Script Purpose:
    This script create sales object view for the gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables(Star Schema)

    Each view performs transformations and combines data from the silver layer
    to produce a clean and enriched and business ready dataset.
Usage:
  -These views can be queried directly for analytics and reporting.

===================================================================================
*/

%md
### We need to build Sales Business object
%md
We need to use the catalog sql_datawarehouse
use catalog sql_datawarehouse;
%md
Now let us pull data from silver layer sales_details table
select * from sql_datawarehouse.silver.crm_sales_details;
%md
Here we have product key and cust_id column which can be used to join the tables so let us replace them with the surrogate keys that we create
select 
sd.sls_ord_num,
pr.product_key,
cu.customer_key,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
 from sql_datawarehouse.silver.crm_sales_details sd
left join sql_datawarehouse.gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join sql_datawarehouse.gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id;
%md
### This table can be considered as fact table as it has event based information with all the dim keys
%md
Let us rename the columns for better readability
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
 from sql_datawarehouse.silver.crm_sales_details sd
left join sql_datawarehouse.gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join sql_datawarehouse.gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id;
%md
### Firstly we have dimension keys and dates and measures as groups
%md
### Create a virtual views for the above for the gold layers object and this is fact table
create view sql_datawarehouse.gold.fact_sales as
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
 from sql_datawarehouse.silver.crm_sales_details sd
left join sql_datawarehouse.gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join sql_datawarehouse.gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id;
%md
### Quality check of the fact table
select * from sql_datawarehouse.gold.fact_sales;
%md
### One more to check whether the fact table connects all the dimension tables
%md
Check for the customers table
select * from sql_datawarehouse.gold.fact_sales f
left join sql_datawarehouse.gold.dim_customers c
on f.customer_key=c.customer_key where c.customer_key is null;
%md
Let us check it for the products table
select * from sql_datawarehouse.gold.fact_sales f
left join sql_datawarehouse.gold.dim_customers c
on f.customer_key=c.customer_key
left join sql_datawarehouse.gold.dim_products p
on f.product_key=p.product_key where p.product_key is null;
