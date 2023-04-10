
        --------------------------------           SUPERMARKET SALES                ------------------------------

		-------CREATING DATABASE-------
CREATE DATABASE SALES;

USE SALES;

------------CREATING TABLE BY GIVING APPROPRIATE DATA TYPES ----------------

Create Table Super_market_sales (
                    Invoice_ID varchar(20) PRIMARY KEY,
					Branch char(1),
					city varchar(20),
					Customer_type char (10),
					Gender char (10),
					Product_line varchar(50),
					Unit_price Decimal,
					Quantity int,
					Tax Decimal,
					Total Decimal,
					sales_Date DATE,
					sales_Time Time,
					Payment varchar(30),
					cogs Decimal,
					gross_margin_percentage Decimal (10),
					gross_income Decimal,
					Rating Decimal 
					);

SELECT * FROM Super_market_sales;

------------USING BULK INSERT METHOD TO LOAD DATA BY GIVING THE LOCATION OF THE FILE AND FORMAT---------
				
Bulk insert Super_market_sales
from 'C:\Users\reshm\OneDrive\Desktop\Super_market_sales.CSV'
With (format = 'CSV',
       FIRSTROW = 2,
	   FIELDTERMINATOR = ',',
	   ROWTERMINATOR = '\n'
	   );


SELECT * FROM Super_market_sales;


---------  COUNTING THE CITY ---------

SELECT City, COUNT(Invoice_ID) AS CITY_COUNT
FROM Super_market_sales
GROUP BY City
ORDER BY CITY_COUNT DESC;


-------- CHECKING CITY WISE SALES ------

SELECT CITY , SUM(TOTAL) AS CITY_WISE_SALES
FROM Super_market_sales
GROUP BY city
ORDER BY CITY_WISE_SALES DESC;


---------- THE COUNT OF CUSTOMER TYPE (MEMBER , NORMAL)

SELECT CUSTOMER_TYPE , COUNT(Invoice_ID) AS CUSTOMER_TYPE_COUNT
FROM Super_market_sales
GROUP BY Customer_type;


-------- CUSTOMER WISE SALES ------

SELECT CUSTOMER_TYPE ,SUM(TOTAL) AS CUSTOMER_TYPE_SALES
FROM Super_market_sales
GROUP BY Customer_type;


--------- COUNT OF GENDER (MALE & FEMALE )

SELECT GENDER , COUNT(INVOICE_ID) AS GENDER_COUNT
FROM Super_market_sales
GROUP BY Gender;


------ TOTAL SALES BY GENDER ------

SELECT GENDER , SUM(TOTAL) AS GENDER_WISE_SALES 
FROM Super_market_sales
GROUP BY Gender;


-------- TOTAL SALES BY PRODUCTS --------

SELECT PRODUCT_LINE ,SUM(TOTAL) AS PRODUCT_WISE_SALES 
FROM Super_market_sales
GROUP BY Product_line
ORDER BY PRODUCT_WISE_SALES DESC;


--------- MOST PREFERED PRODUCTS BY CUSTOMERS -------

SELECT PRODUCT_LINE , COUNT(INVOICE_ID) AS PREFFERED_PRODUCTS
FROM Super_market_sales
GROUP BY Product_line
ORDER BY PREFFERED_PRODUCTS DESC;


---------- MOSTLY PREFERRED PAYMENT TYPE BY THE CUSTOMERS ------

SELECT PAYMENT , COUNT(INVOICE_ID) AS PREFERRED_PAYMENT_TYPE
FROM Super_market_sales
GROUP BY PAYMENT 
ORDER BY PREFERRED_PAYMENT_TYPE DESC;


------------ PAYMENT WISE SALES ------- 

SELECT PAYMENT , SUM(TOTAL) AS PAYMENT_WISE_SALES
FROM Super_market_sales
GROUP BY PAYMENT 
ORDER BY PAYMENT_WISE_SALES DESC;


-------- THE COUNT OF HIGHEST RATINGS GIVEN BY MEMBER TYPE CUSTOMERS ------

SELECT count(*)  as Highest_Ratings_Member 
FROM Super_market_sales
WHERE Rating > 7 and Customer_type = 'Member';


--------- THE COUNT OF HIGHEST RATINGS GIVEN THE NORMAL CUSTOMERS ------------

SELECT count(*)  as Highest_Ratings_Normal
FROM Super_market_sales
WHERE Rating > 7 and Customer_type = 'Normal';


----------- MAXIMUM AND MINIMUM SALES BY CITY ---------

Select city ,max(Total) AS MAXIMUM_SALES  ,MIN(Total) AS MINIMUM_SALES 
FROM Super_market_sales
group by city ;


------------ AVERAGE RATING OF PRODUCTS -------------

SELECT Product_Line, AVG(Rating) AS avg_rating
FROM Super_market_sales
GROUP BY Product_Line;



----THE  CORRELATION BETWEEN QUANTITY AND TOTAL INDICATES A POSITIVE 
----MEANS THAT AS THE QUANTITY SOLD INCREASES,THE TOTAL NUMBER OF SALES ALSO TENDS TO INCREASE 

SELECT 
  ((COUNT(*) * SUM(Quantity * Total)) - (SUM(Quantity) * SUM(Total))) /
  SQRT(((COUNT(*) * SUM(Quantity* Quantity)) - (SUM(Quantity) * SUM(Quantity))) *
  ((COUNT(*) * SUM(Total * Total)) - (SUM(Total) * SUM(Total)))) AS Quantity_sales_correlation 
FROM Super_market_sales;



--------CREATING A PROCEDURE FOR INVOICE ID , SO THAT IF EXCECUTE ONE ID IT WILL PROVIDE THE INFORMATION OF THAT ID------

GO
CREATE PROCEDURE get_invoice_details
    @Invoice_id VARCHAR(50)
AS
BEGIN
   SELECT *
   FROM Super_market_sales
   WHERE [Invoice_ID] = @Invoice_id;
END;


--------THIS WAY WE EXECUTE AND CHECK THE RESULTS FOR THE INVOICE ID------------

EXEC get_invoice_details '101-17-6199';


-------- CREATING VIEW NMAED RECORDS WHICH WILL GIVE ONLY REQUIRED DATA , AND DOESNT INCLUDE INFORMATION REGARDING PRICES, REVIEWS AND RATINGS 

CREATE VIEW RECORD AS
SELECT INVOICE_ID , BRANCH , CITY , CUSTOMER_TYPE ,GENDER ,PRODUCT_LINE 
FROM Super_market_sales


-----LETS SEE -----

SELECT * FROM RECORD


------- CREATING TRIGGERS -------
GO
CREATE TRIGGER prevent_duplicate_records
ON Super_market_sales
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Invoice_ID IN (SELECT Invoice_ID FROM Super_market_sales))
    BEGIN
        RAISERROR ('Duplicate record found. Insert operation aborted.', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
        INSERT INTO Super_market_sales(Invoice_ID, Customer_Type, Product_line, Quantity, Unit_Price, Total, Rating)
        SELECT Invoice_ID, Customer_Type, Product_line, Quantity, Unit_Price, Total, Rating
        FROM inserted
END


---------NOW LETS CHECK --------(GIVING THE VALUES WHICH ALREADY EXISTS IN THE DATA -------SHOWS THE RAISERROR

INSERT INTO Super_market_sales (Invoice_ID, Customer_Type, Product_line, Quantity, Unit_Price, Total, Rating)
VALUES ('101-17-6199', 'NORMAL', 'Food and beverages', 2, 20, 100, 4);



---------- IF WE TAKE NEW INVOICE ID WHICH IS NOT THERE IN DATA THEN IT WILL BE INSERTED----------------------

INSERT INTO Super_market_sales (Invoice_ID, Customer_Type, Product_line, Quantity, Unit_Price, Total, Rating)
VALUES ('101-17-6200', 'NORMAL', 'Food and beverages', 2, 20, 100, 4);


SELECT * FROM Super_market_sales -------SHOWS 1001 ROWS


DELETE FROM Super_market_sales
WHERE Invoice_ID = '101-17-6200';    --- DELETING ---- 


----------CREATED A PROCEDURE WHICH WILL REPREST THE TOP RATED PRODUCTS FROM THE DATA ------------------

GO
  CREATE PROCEDURE TOP_RATED_PRODUCTS
   AS 
     BEGIN
           SELECT * FROM Super_market_sales
	  
   WHERE  Rating > 7 
      END;           
 GO

 ---------EXECUTE----

 EXEC TOP_RATED_PRODUCTS


----------TRANSACTION TO DELETE THE GIVEN LOGIC , STATING WITH BEGIN MAY HELP US TO GET BACK THE DATA --------

 BEGIN TRANSACTION
         SAVE TRANSACTION T1
		 DELETE Super_market_sales WHERE Total < 100;


---------IT SHOWS THAT THE COMMAND SUCCES FOR REMOVING THE DATA WHERE TOTAL SALES LESS THAN 100 ----------

SELECT * FROM Super_market_sales


------------ ROLLBACK TRANSACTION WORKS AS UNDO ,WE CAN GET BACK THE DATA THAT WE HAVE DELETED ------

ROLLBACK TRANSACTION T1


--------- THE END--------
     --------------------------- THANK YOU ----------------------