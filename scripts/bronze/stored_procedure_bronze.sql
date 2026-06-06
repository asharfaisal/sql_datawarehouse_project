/*
===============================================================================
Stored Procedure: Load Bronze Layer 
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

To Use:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN
        DECLARE @start_time DATETIME , @end_time DATETIME

        PRINT '=====================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=====================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '**********LOADING CRM FILES**********';
		PRINT 'Inserting Data into:bronze.crm_cust_info';
		PRINT '=====================================================';

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading  bronze.crm_cust_info: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT 'Inserting Data into:bronze.crm_prd_info';
		PRINT '======================================================';

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);

		SET @end_time = GETDATE();
        PRINT 'Loading  bronze.crm_prd_info: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT 'Inserting Data into:bronze.crm_sales_details';
		PRINT '=====================================================';

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loading  bronze.crm_sales_details: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

		-- source erp --
		PRINT '**********LOADING ERP FILES**********';
	    
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT 'Inserting Data into:bronze.erp_cust_az12';
		PRINT '======================================================';

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Loading  bronze.erp_cust_az12: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT 'Inserting Data into:bronze.erp_loc_a101';
		PRINT '======================================================';

		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading  bronze.erp_loc_a101: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2

		PRINT 'Inserting Data into:bronze.erp_px_cat_g1v2';
		PRINT '==================================================';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\SQL\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with
		(
		  FIRSTROW = 2 ,
		  FIELDTERMINATOR = ',',
		  TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading  bronze.erp_px_cat_g1v2: '+ CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + 'seconds'; 
		PRINT'=======================================================';

END


