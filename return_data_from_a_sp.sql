USE AdventureWorks2012;
GO

IF OBJECT_ID('Sales.usp_GetSalesYTD', 'P') IS NOT NULL
	DROP PROCEDURE Sales.usp_GetSalesYTD;
GO

CREATE PROCEDURE Sales.usp_GetSalesYTD
	@SalePerson NVARCHAR(50) = NULL, -- NULL default value
	@SalesYTD MONEY = NULL OUTPUT
	AS

	-- Validate @SalePerson parameter
	IF @SalePerson IS NULL
		BEGIN 
			PRINT 'ERROR: You must specify a last name for the sales person.'
			RETURN(1)
		END
	ELSE
		BEGIN
		-- Make sure the value is valid
			IF((SELECT COUNT(*) FROM HumanResources.vEmployee WHERE LastName = @SalePerson) = 0)
			RETURN(2);
		END
	-- get the sales for the specified name and 
	-- assign it to the output parameter.
	SELECT @SalesYTD = SalesYTD
	FROM Sales.SalesPerson AS sp
	JOIN HumanResources.vEmployee AS e ON e.BusinessEntityID = sp.BusinessEntityID
	WHERE e.LastName = @SalePerson;
	-- check for SQL server errors
	IF @@ERROR > 0 --use the @@ERROR function after a Transact-SQL statement to detect whether an error occurred during the execution of the statement
		BEGIN
			RETURN(3);
		END
	ELSE
		BEGIN
			-- check to see if the ytd_sales value is NULL.
			IF @SalesYTD IS NULL
				RETURN(4); -- NULL sales value found for the salesperson.
			ELSE 
			-- SUCCESS!!
				RETURN(0);
		END
		-- Run the stored procedure without specifying an input value.
		EXEC Sales.usp_GetSalesYTD;
GO

-- Declare the variables to receive the output value and return code   
-- of the procedure.  
DECLARE @SalesYTDBySalesPerson MONEY, @ret_code INT;  
-- Execute the procedure specifying a last name for the input parameter  
-- and saving the output value in the variable @SalesYTDBySalesPerson  
EXECUTE @ret_code = Sales.usp_GetSalesYTD  
    N'Blythe', @SalesYTD = @SalesYTDBySalesPerson OUTPUT;  
-- check the return code 
IF @ret_code = 0
BEGIN
	PRINT 'Successful execution.';
	PRINT 'Year-to-date sales for this employee is ' + convert(varchar(10),@SalesYTDBySalesPerson); 
END
ELSE IF @ret_code = 1
	PRINT 'Required parameter value is not specified.';
ELSE IF @ret_code = 2
	PRINT 'Specified parameter value is not valid.';
ELSE IF @ret_code = 3
	PRINT 'Error has occurred getting sales value.';
ELSE IF @ret_code = 4
	PRINT 'NULL sales value found for the salesperson.';
GO 
