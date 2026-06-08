/*
===============================================================================
Stored Procedure: Load Silver Layer 
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'silver' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

To Use:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver as
BEGIN
DECLARE @start_time DATETIME , @end_time DATETIME ,@batch_start_time DATETIME ,@batch_end_time DATETIME

                             PRINT'*****LOADING SILVER LAYER*****'
							       PRINT'==========================================='
                             PRINT'****LOADING CRM TABLES****'

SET @batch_start_time =GETDATE();
SET @start_time = GETDATE();
PRINT'>>Truncating table silver.crm_cust_info<<'
TRUNCATE TABLE silver.crm_cust_info
PRINT'>> Inserting data into silver.crm_cust_info <<'

			INSERT INTO silver.crm_cust_info(
					cst_id,
					cst_key,
					cst_firstname,
					cst_lastname,
					cst_marital_status,
					cst_gndr,
					cst_create_date
			)
			select 
					cst_id,
					cst_key,
					TRIM(cst_firstname) as cst_firstname,
					TRIM(cst_lastname) as cst_lastname,
					CASE when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
						 when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
						 else 'n/a'
					END AS cst_martial_status,

					CASE when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
						 when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
						 else 'n/a'
					END AS cst_gndr,

					cst_create_date
			FROM
				(
				select * ,
						ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_check
						from bronze.crm_cust_info
						where cst_id is not null
				)t 
				where flag_check = 1

SET @end_time = GETDATE();
PRINT'>>Loaded table silver.crm_cust_info : '+ CAST(DATEDIFF(second,@start_time,@end_time)as NVARCHAR) + 'seconds'
PRINT'==========================================='

SET @start_time = GETDATE();
PRINT'>>Truncating table silver.crm_prd_info<<'
TRUNCATE TABLE silver.crm_prd_info
PRINT'>> Inserting data into silver.crm_prd_info <<'

			INSERT INTO silver.crm_prd_info
			(
				prd_id,
				category_id,
				product_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
			)
			select 
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') as category_id,
				SUBSTRING(prd_key,7,LEN(prd_key)) as product_key,
				prd_nm,
				ISNULL(prd_cost,0) as prd_cost,
				CASE UPPER(TRIM(prd_line))
					 when 'M' then 'Mountain'
					 when 'R' then 'Road'
					 when 'S' then 'Other Sales'
					 when 'T' then 'Touring'
					 ELSE 'n/a'
				END AS prd_line,
				CAST(prd_start_dt as date) as prd_start_dt,
				CAST(LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt

			from bronze.crm_prd_info
SET @end_time = GETDATE();
PRINT'>>Loaded table silver.crm_prd_info: '+CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'
PRINT'==========================================='

SET @start_time = GETDATE();
PRINT'>>Truncating table silver.crm_sales_details<<'
TRUNCATE TABLE silver.crm_sales_details
PRINT'>> Inserting data into silver.crm_sales-details<<'

			INSERT INTO silver.crm_sales_details
			(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
    
			)
			select 
					sls_ord_num,
					sls_prd_key,
					sls_cust_id,
					CASE 
					when sls_order_dt <= 0 or LEN(sls_order_dt) != 8 THEN null
					else CAST(CAST(sls_order_dt as varchar)as date) 
					END AS sls_order_dt,

					CASE 
					when sls_ship_dt <= 0 or LEN(sls_ship_dt) != 8 THEN null
					else CAST(CAST(sls_ship_dt as varchar)as date)
					END AS sls_ship_dt,

					CASE 
					when sls_due_dt <= 0 or LEN(sls_due_dt) != 8 THEN null
					else CAST(CAST(sls_due_dt as varchar)as date)
					END AS sls_due_dt,

					CASE 
					when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
					then sls_quantity * ABS(sls_price)
					else sls_sales
					END AS sls_sales,

					sls_quantity,

					CASE 
					when sls_price is null or sls_price <= 0
					then sls_sales / NULLIF(sls_quantity,0)
					else sls_price
					END AS sls_price

			from bronze.crm_sales_details
SET @end_time = GETDATE();
PRINT'>>Loaded table silver.crm_sales_details: '+CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'
PRINT'==========================================='

                            PRINT'****LOADING ERP TABLES****'

SET @start_time = GETDATE();
PRINT'>>Truncating table silver.erp_cust_az12<<'
TRUNCATE TABLE silver.erp_cust_az12
PRINT'>> Inserting data into silver.erp_cust_az12<<'

		INSERT INTO silver.erp_cust_az12
		(
				cid,
				bdate,
				gen
		)
		select 
				CASE
				when cid like 'NAS%' then SUBSTRING(cid,4,LEN(cid))
				else cid
				END AS cid,

				CASE when bdate > GETDATE() then null
				else bdate
				END AS bdate,

				CASE 
				when UPPER(TRIM(gen)) IN ('F' ,'FEMALE') then 'Female'
				when UPPER(TRIM(gen)) IN ('M' ,'MALE') then 'Male'
				else 'n/a'
				END AS gen

		from bronze.erp_cust_az12
SET @end_time = GETDATE();
PRINT'>>Loaded table silver.erp_cust_az12: '+CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'
PRINT'==========================================='

SET @start_time = GETDATE();
PRINT'>>Truncating table silver.erp_loc_a101<<'
TRUNCATE TABLE silver.erp_loc_a101
PRINT'>> Inserting data into silver.erp_loc_a101<<'

			INSERT INTO silver.erp_loc_a101
			(
					cid,
					cntry
			)
			select 
					REPLACE(cid,'-','') as cid,

					CASE 
					when cntry is null or cntry = ' ' then 'n/a'
					when UPPER(cntry) = 'DE' then 'Germany'
					when UPPER(cntry) IN ('US','USA') then 'United States'
					else cntry
					END AS cntry

			from bronze.erp_loc_a101

SET @end_time = GETDATE();
PRINT'>>Loaded table silver.erp_loc_a101: '+CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'
PRINT'==========================================='

SET @start_time = GETDATE();
PRINT'>>Truncating table silver.erp_px_cat_g1v2<<'
TRUNCATE TABLE silver.erp_px_cat_g1v2
PRINT'>> Inserting data into silver.erp_px_cat_g1v2<<'

				INSERT INTO silver.erp_px_cat_g1v2
				(
						id,
						cat,
						subcat,
						maintenance
				)
				select 
						id,
						cat,
						subcat,
						maintenance
				from bronze.erp_px_cat_g1v2

SET @end_time = GETDATE();
PRINT'>>Loaded table silver.erp_px_cat_g1v2: '+CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'
PRINT'==========================================='

SET @batch_end_time = GETDATE();

PRINT'!!!!!!!!Loaded Silver Layer Successfully!!!!!!!!'
PRINT'Total Load Duration: '+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + 'seconds'
END



