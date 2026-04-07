/*
===================================================
Create Database/Catalog and Schemas
===================================================
Script Purpose:
  This script create the catalog if the same catalog exists with same name it drops and then create the new catalog
  If it dropped the exsiting catalog and then create the three schema's inside of the database/catalog :Bronze,Silver,Gold
Warning:
  If database exists and have the data then the data will be dropped.
====================================================


D
---Using the newly created Catalog/Database---sql_data_warehouse
  
use catalog sql_datawarehouse;

%md
### Checking whether the catalog exists with same name if exists drop the catalog 
%sql
drop catalog if exists sql_datawarehouse cascade;
%md
### Create the catalog/Database 
%sql
create catalog sql_datawarehouse
%md
### Use the created catalog/database for the project
%sql
use catalog sql_datawarehouse;
%md
### Create the three schema's Layers _Bronze,Silver,Gold_
%sql
create schema bronze;
%sql
create schema silver;
%sql
create schema gold;
