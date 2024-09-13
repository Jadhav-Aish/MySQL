USE coffee_shop_sales_db;

-- return all the columns from coffee_shop_sales table:
SELECT * FROM `coffee shop sales`;

-- DATA CLEANING 

--  I can check datatypes with help of Describe:
DESCRIBE `coffee shop sales`;

-- If i can check datatype then i can see on this there is need to change data types of some columns like that transaction_date, transaction_time
-- Also change the format of date & time.

-- In this i can update the table to this format dd-mm-yy from string to date.
UPDATE `coffee shop sales`
SET transaction_date = str_to_date(transaction_date , '%d-%m-%Y');

-- Altering table & we can changing the data type of this perticular transaction_date & we are doing it by modify column
ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_date DATE;


-- Similarly change the data type & format on transaction_time column
UPDATE `coffee shop sales`
SET transaction_time = str_to_date(transaction_time , '%H:%i:%s');

-- Change the data type of some other columns.
ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_time TIME;

-- change the column name

ALTER TABLE `coffee shop sales`
CHANGE COLUMN ï»¿transaction_id  transaction_id INT;

-- Total Sales Analysis 
-- 1) calculate the total saleas for each respective month.
SELECT SUM(unit_price * transaction_qty) AS Total_Sales
FROM `coffee shop sales`;
-- give me 698812 for a total sales of all months

SELECT CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000 , 'K') AS Total_Sales
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date) = 3; -- MARCH MONTH
--  FOR 98.8350K MARCH MONTH

-- 2) Determine the month-on-month inclease or decrease in sales.
-- 3) Calculate the difference in sales between the selected month & the previous month.

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT
    current_sales.month,
    current_sales.total_sales,
    (current_sales.total_sales - previous_sales.total_sales) / previous_sales.total_sales * 100 AS mom_increase_percentage
FROM (
    SELECT
        MONTH(transaction_date) AS month,
        ROUND(SUM(unit_price * transaction_qty)) AS total_sales
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS current_sales
LEFT JOIN (
    SELECT
        MONTH(transaction_date) AS month,
        ROUND(SUM(unit_price * transaction_qty)) AS total_sales
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS previous_sales
ON current_sales.month = previous_sales.month + 1
ORDER BY 
    current_sales.month;
    
-- TOTAL ORDERS
SELECT COUNT(transaction_id) AS total_orders
FROM `coffee shop sales`;
-- total order 149116

SELECT COUNT(transaction_id) AS total_orders
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date)=5; -- may month
-- total order in may = 33527

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT
    current_orders.month,
    current_orders.total_orders,
    (current_orders.total_orders - previous_orders.total_orders) / previous_orders.total_orders * 100 AS mom_increase_percentage
FROM (
    SELECT
        MONTH(transaction_date) AS month,
        ROUND(COUNT(transaction_id)) AS total_orders
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS current_orders
LEFT JOIN (
    SELECT
        MONTH(transaction_date) AS month,
         ROUND(COUNT(transaction_id)) AS total_orders
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS previous_orders
ON current_orders.month = previous_orders.month + 1
ORDER BY 
    current_orders.month;
    
-- TOTAL QUANTITY SOLD
SELECT SUM(transaction_qty) AS total_quantity_sold
FROM `coffee shop sales`;
--  total_quantity_sold = 214470

SELECT SUM(transaction_qty) AS total_quantity_sold
FROM `coffee shop sales`
WHERE
MONTH(transaction_date) = 5;
-- total_quantity_sold in may = 48233

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT
    current_quantity_sold.month,
    current_quantity_sold.total_quantity_sold,
    (current_quantity_sold.total_quantity_sold - previous_quantity_sold.total_quantity_sold) / previous_quantity_sold.total_quantity_sold * 100 AS mom_increase_percentage
FROM (
    SELECT
        MONTH(transaction_date) AS month,
        ROUND(SUM(transaction_qty)) AS total_quantity_sold
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS current_quantity_sold
LEFT JOIN (
    SELECT
        MONTH(transaction_date) AS month,
         ROUND(SUM(transaction_qty)) AS total_quantity_sold
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) IN (4, 5) -- for months of April and May
    GROUP BY 
        MONTH(transaction_date)
) AS previous_quantity_sold
ON current_quantity_sold.month = previous_quantity_sold.month + 1
ORDER BY 
    current_quantity_sold.month;
    
-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT 
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales,
CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_quantity_sold,
CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_orders
FROM
`coffee shop sales`
WHERE 
transaction_date ='2023-05-18';

-- weekday & weekend sale
-- weekend = sat - sun
-- weekday = mon - fri
-- sun = 1
-- .
-- .
-- sat = 7

SELECT 
CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
ELSE 'WEEKDAYS'
END AS dat_type,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date) = 2 -- Feb Month
GROUP BY 
CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
ELSE 'WEEKDAYS'
END ;

-- SALES BY STORE LOCATION
SELECT 
store_location,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS total_sales
FROM `coffee shop sales`
WHERE MONTH(transaction_date) = 6 -- Jun Month
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;


-- SALES TREND OVER PERIOD
SELECT 
CONCAT(ROUND(AVG(total_sale)/1000,1),'K') AS Avg_sales
FROM
(
SELECT
SUM(unit_price*transaction_qty) AS total_sale
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date) = 4
GROUP BY transaction_date
) AS internal_query;

-- DAILY SALES FOR MONTH SELECTED
SELECT 
DAY(transaction_date) AS day_of_month,
ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM `coffee shop sales`
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        (SELECT AVG(total_sales) FROM (
            SELECT 
                SUM(unit_price * transaction_qty) AS total_sales
            FROM 
                `coffee shop sales`
            WHERE 
                MONTH(transaction_date) = 5  -- Filter for May
            GROUP BY 
                DAY(transaction_date)
        ) AS inner_avg) AS avg_sales
    FROM 
        `coffee shop sales`
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- SALES BY PRODUCT CATEGORY
SELECT 
product_category,
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k') AS total_sales
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price*transaction_qty) DESC;

-- SALES BY PRODUCTS (TOP 10)
SELECT 
product_category,
(ROUND(SUM(unit_price*transaction_qty),1)) AS total_sales
FROM `coffee shop sales`
WHERE 
MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price*transaction_qty) DESC
LIMIT 10;

-- SALES BY DAY | HOUR
SELECT 
ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
SUM(transaction_qty) as total_quantity_sold,
COUNT(*) AS total_orders
FROM `coffee shop sales`
WHERE 
DAYOFWEEK(transaction_date) = 3 --  Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
AND HOUR(transaction_time) = 8 -- Filter for hour number 8
AND MONTH(transaction_date) = 5; --  Filter for May (month number 5)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
CASE 
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday'
END AS Day_of_Week,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
`coffee shop sales`
WHERE 
MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
CASE 
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
ELSE 'Sunday'
END;

-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
























    
   


    








