/*
===============================================================================
DDL Script:create Gold views for Sales Customer object
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
## Build the customer business object from two sources
%md
### Use the silver table
%md
Using of sql_datawarehouse catalog
use catalog sql_datawarehouse;
select * from sql_datawarehouse.silver.crm_cust_info;
select count(*), cst_id from sql_datawarehouse.silver.crm_cust_info group by cst_id having count(*)>1;
%md
We are good to see the transformed data having no duplicates in the column id
%md
### So let us get the addional table customer data  from the other sourced table cust az12
select * from sql_datawarehouse.silver.erp_cust_az12;
%md
### So let us join the two tables crm_cust_info and erp_cust_az12 to get additional data of the customer like birthdate and gender information
select
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.BDATE,
    ca.GEN
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID;
%md
Now we have added the customer birth date and gender from erp sourced table similarly we have one more table for customer location details table using the column cst_key and CID we need to add location details to the customer table
select
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.BDATE,
    ca.GEN,
    la.cntry
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;
%md
### With that we collected all the customer data from multiple two source system
%md
Now we need check if we got any duplicated rows of the customer data
select cst_id,count(*) from (
  
  select
      ci.cst_id,
      ci.cst_key,
      ci.cst_firstname,
      ci.cst_lastname,
      ci.cst_marital_status,
      ci.cst_gndr,
      ci.cst_create_date,
      ca.BDATE,
      ca.GEN,
      la.cntry
  from 
  sql_datawarehouse.silver.crm_cust_info ci 
  left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
  left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key)
  group by cst_id having count(*)>1;
%md
We are on right way that we don't have any duplicate data
%md
Let us check for other columns for the integrated data
select
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.BDATE,
    ca.GEN,
    la.cntry
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;
%md
Here we found two columns of gender details let us check the consistency for this two rows
select distinct
    ci.cst_gndr,   
    ca.GEN
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key order by 1,2;
%md
So here we see different information in those two tables and we find data in one table and not in second table
%md
At this point of time we need to discuss with experts about the master data table so let us this crm table has accurate correct data so let us fix the data
%md
%md
If we have data in master source we are using that or else we are using second table data as gender data
select distinct
    ci.cst_gndr,   
    ca.GEN,
    case when ci.cst_gndr!='n/a' then ci.cst_gndr
      else coalesce(ca.gen,'n/a')
    end as new_gen
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key order by 1,2;
%md
Now we are good with perfect gender data coulmns
%md
Now fix the names of the columns with friendly understandable names and good order of the data
select
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case when ci.cst_gndr!='n/a' then ci.cst_gndr
      else coalesce(ca.gen,'n/a')
    end as gender,
    ca.BDATE as birthdate,
    ci.cst_create_date as create_date
    
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;
select
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case when ci.cst_gndr!='n/a' then ci.cst_gndr
      else coalesce(ca.gen,'n/a')
    end as gender,
    ca.BDATE as birthdate,
    ci.cst_create_date as create_date
    
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;
%md
# We can classify this as dimension table has this table contains descriptive data of the customer
%md
## Now let us create a surrogate key to identify the each records in the customer table for the data warehouse
select
    row_number() over(order by ci.cst_id) as customer_key,
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case when ci.cst_gndr!='n/a' then ci.cst_gndr
      else coalesce(ca.gen,'n/a')
    end as gender,
    ca.BDATE as birthdate,
    ci.cst_create_date as create_date
    
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;
%md
So as we are in gold layers and the objects in gold layer is virtual ones so create a view
create view sql_datawarehouse.gold.dim_customers as
select
    row_number() over(order by ci.cst_id) as customer_key,
    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname as last_name,
    la.cntry as country,
    ci.cst_marital_status as marital_status,
    case when ci.cst_gndr!='n/a' then ci.cst_gndr
      else coalesce(ca.gen,'n/a')
    end as gender,
    ca.BDATE as birthdate,
    ci.cst_create_date as create_date
    
from 
sql_datawarehouse.silver.crm_cust_info ci 
left join sql_datawarehouse.silver.erp_cust_az12 ca on ci.cst_key = ca.CID
left join sql_datawarehouse.silver.erp_loc_a101 la on la.cid=ci.cst_key;

%md
### Quality check of the view object in gold layers
select * from gold.dim_customers;
%md
check for the all columns in view
select distinct gender from gold.dim_customers;
%md
### So our quality checks are fine with the results
