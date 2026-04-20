/*
===============================================================================
DDL Script:create Gold views for Product business object
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
### Now we are building the product business object to get all the available product data into one
%md
Before getting the data we need to make sure we are using the correct catalog for this entire project we are using sql_datawarehouse catalog
use catalog sql_datawarehouse;
%md
Let us fetch the available tables records from silver layer
%md
### First Table product info table from silver layer and from source CRM System
select * from sql_datawarehouse.silver.crm_prd_info;
%md
The above table consists of historical data now we are choosing the current data
select
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from sql_datawarehouse.silver.crm_prd_info
where prd_end_dt is null;
%md
### So the above data is current product info data
%md
Let us pull data from other table which is comming from ERP source
select * from sql_datawarehouse.silver.erp_px_cat_g1v2;
%md
### Let us join the two tables to get the total information of the product and it's categories data
select
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.MAINTENANCE
from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
%md
### As we joined the table we need to check for the quality
select prd_key,count(*) from (
select
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.MAINTENANCE
from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null) group by prd_key having count(*)>1;
%md
There are no duplicates in data after joining and we see no repetated columns in the joined table
%md
Let us group the data together to have a understandable to improve the readability
select
pn.prd_id,
pn.prd_key,
pn.prd_nm,
pn.cat_id,
pc.cat,
pc.subcat,
pc.MAINTENANCE,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt

from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
%md
Now rename the columns for better readability
select
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.MAINTENANCE as maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
%md
### This table has a descriptive data of the product information so we can classify the this table as dimension table so we need to have a primary key
select
row_number() over (order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.MAINTENANCE as maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
%md
### So now we have a primary key for the each product we can use this key for building the data model
%md
### As we need to have virtual tables as objects in gold layer we need to create a view for the above product information
create view sql_datawarehouse.gold.dim_products as
select
row_number() over (order by pn.prd_start_dt,pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.MAINTENANCE as maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from sql_datawarehouse.silver.crm_prd_info pn
left join sql_datawarehouse.silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null;
%md
We are good with the products dimension table as view for gold layer
select * from sql_datawarehouse.gold.dim_products;
