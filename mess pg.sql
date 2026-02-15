DROP TABLE IF EXISTS mess_data;
CREATE TABLE mess_data (
    roll_no VARCHAR(10),
    date DATE,
    lunch VARCHAR(10),
    dinner VARCHAR(10),
    sweet VARCHAR(10),
    meal_type VARCHAR(20),
    dish_name VARCHAR(50),
    quantity INTEGER,
    price NUMERIC,
    meal_count INTEGER,
    total_bill NUMERIC,
    month VARCHAR(20),
    cost_category VARCHAR(20)
);

SELECT current_database();

DROP TABLE IF EXISTS mess_data;

CREATE TABLE mess_data (
    roll_no VARCHAR(10),
    date DATE,
    lunch VARCHAR(10),
    dinner VARCHAR(10),
    sweet VARCHAR(10),
    meal_type VARCHAR(20),
    dish_name VARCHAR(50),
    quantity INTEGER,
    price NUMERIC,
    meal_count INTEGER,
    total_bill NUMERIC,
    month VARCHAR(20),
    cost_category VARCHAR(20)
);

SELECT * FROM mess_data;


COPY mess_data
FROM 'C:/Users/parv/Desktop/to import (1).csv'
WITH (
    FORMAT csv,
    HEADER true
);
SELECT COUNT(*) FROM mess_data;

SELECT * FROM mess_data LIMIT 5;

ANALYSIS AND BRINGING OUT SOM
-- Ensure each transaction is uniquely identifiable
ALTER TABLE mess_data
ADD COLUMN id SERIAL PRIMARY KEY;

-- Calculate total mess revenue collected
SELECT SUM(total_bill) AS total_revenue
FROM mess_data;


-- Count total meals served
SELECT SUM(meal_count) AS total_meals_served
FROM mess_data;


-- ===============================================
-- 1) Check Primary Key and total rows
-- ===============================================
-- Ensures every transaction is uniquely identified
SELECT COUNT(id) AS total_rows
FROM mess_data;



-- ===============================================
-- 2) Detect duplicate transactions (if any)
-- ===============================================
-- Using GROUP BY to check duplicate roll_no + date entries
SELECT roll_no, date, COUNT(*) AS duplicate_count
FROM mess_data
GROUP BY roll_no, date
HAVING COUNT(*) > 1;



-- ===============================================
-- 3) Handle NULL values in sweet column
-- ===============================================
-- Replace NULL sweet with 'Not Taken'
SELECT id, roll_no, COALESCE(sweet, 'Not Taken') AS sweet_status
FROM mess_data;



-- ===============================================
-- 4) Monthly Revenue using GROUP BY
-- ===============================================
SELECT month, SUM(total_bill) AS monthly_revenue
FROM mess_data
GROUP BY month
ORDER BY monthly_revenue DESC;



-- ===============================================
-- 5) Revenue Ranking by Month (Using RANK)
-- ===============================================
SELECT month,
       SUM(total_bill) AS revenue,
       RANK() OVER (ORDER BY SUM(total_bill) DESC) AS revenue_rank
FROM mess_data
GROUP BY month;



-- ===============================================
-- 6) Top 5 Transactions using ROW_NUMBER
-- ===============================================
SELECT *
FROM (
    SELECT id, roll_no, total_bill,
           ROW_NUMBER() OVER (ORDER BY total_bill DESC) AS row_num
    FROM mess_data
) sub
WHERE row_num <= 5;



-- ===============================================
-- 7) Total Spending per Student
-- ===============================================
SELECT roll_no,
       SUM(total_bill) AS total_spent
FROM mess_data
GROUP BY roll_no
ORDER BY total_spent DESC;



-- ===============================================
-- 8) Rank Students by Spending
-- ===============================================
SELECT roll_no,
       SUM(total_bill) AS total_spent,
       RANK() OVER (ORDER BY SUM(total_bill) DESC) AS spending_rank
FROM mess_data
GROUP BY roll_no;



-- ===============================================
-- 9) Create Meal Summary (Aggregation Table)
-- ===============================================
-- Temporary summary using subquery
SELECT meal_type,
       COUNT(*) AS total_orders,
       SUM(total_bill) AS revenue
FROM mess_data
GROUP BY meal_type;



-- ===============================================
-- 10) JOIN Example (Self Join for comparison)
-- ===============================================
-- Compare each student's spending with overall average
SELECT m.roll_no,
       SUM(m.total_bill) AS student_total,
       avg_table.avg_spending
FROM mess_data m
JOIN (
    SELECT AVG(total_bill) AS avg_spending
    FROM mess_data
) avg_table
ON 1=1
GROUP BY m.roll_no, avg_table.avg_spending;



-- ===============================================
-- 11) Identify Above Average Spenders
-- ===============================================
SELECT roll_no,
       SUM(total_bill) AS total_spent
FROM mess_data
GROUP BY roll_no
HAVING SUM(total_bill) >
       (SELECT AVG(total_bill) FROM mess_data);



-- ===============================================
-- 12) Dish Popularity Ranking
-- ===============================================
SELECT dish_name,
       SUM(quantity) AS total_quantity,
       RANK() OVER (ORDER BY SUM(quantity) DESC) AS dish_rank
FROM mess_data
GROUP BY dish_name;



-- ===============================================
-- 13) Running Total Revenue (Window Function)
-- ===============================================
SELECT id,
       date,
       total_bill,
       SUM(total_bill) OVER (ORDER BY date) AS running_revenue
FROM mess_data;



-- ===============================================
-- 14) Revenue Contribution Percentage
-- ===============================================
SELECT dish_name,
       SUM(total_bill) AS revenue,
       ROUND(
           (SUM(total_bill) * 100.0) /
           (SELECT SUM(total_bill) FROM mess_data),
           2
       ) AS revenue_percentage
FROM mess_data
GROUP BY dish_name
ORDER BY revenue_percentage DESC;



-- ===============================================
-- 15) Highest Revenue Dish per Meal Type
-- ===============================================
SELECT *
FROM (
    SELECT meal_type,
           dish_name,
           SUM(total_bill) AS revenue,
           RANK() OVER (PARTITION BY meal_type ORDER BY SUM(total_bill) DESC) AS rank_in_meal
    FROM mess_data
    GROUP BY meal_type, dish_name
) ranked
WHERE rank_in_meal = 1;

