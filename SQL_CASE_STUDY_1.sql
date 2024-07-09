-- SQL CASE STUDY 1 (DANNY'S DINNER) OF #8WEEKSQLCHALLENGE By DANNY MA

CREATE TABLE sales (
  customer_id VARCHAR(1) , order_date DATE, product_id INT
);
INSERT INTO sales
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 SELECT * FROM sales;

CREATE TABLE menu (
  product_id INT,product_name VARCHAR(5),price INT
);
INSERT INTO menu
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
   SELECT * FROM menu;

CREATE TABLE members (
  customer_id VARCHAR(1),join_date DATE
);
INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
SELECT * FROM members;

-- CASE STUDY QUESTIONS

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id,SUM(price) AS total_amount_spend FROM(
SELECT s.*,m.product_name,m.price FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id) AS a
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?

SELECT customer_id,COUNT(DISTINCT order_date) AS no_of_days_visited FROM sales GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?

SELECT customer_id,product_name AS first_bought_item FROM(
SELECT customer_id,product_name,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk FROM(
SELECT s.*,m.product_name,m.price FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id) AS a) AS b
WHERE rnk=1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name AS most_bought_item,COUNT(product_name) AS no_of_time_purchased FROM(
SELECT s.*,m.product_name,m.price FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id) AS a
GROUP BY product_name
ORDER BY no_of_time_purchased DESC LIMIT 1;


-- 5. Which item was the most popular for each customer?

WITH cte AS( 
SELECT customer_id,product_name,cnt,
RANK() OVER(PARTITION BY customer_id ORDER BY cnt DESC) AS rnk FROM(
SELECT DISTINCT customer_id,  product_name,
COUNT(product_name) AS cnt FROM(
SELECT s.*,m.product_name,m.price FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id) AS a
GROUP BY customer_id,product_name) AS b)
SELECT customer_id,product_name AS most_popular_item FROM cte
WHERE rnk=1;


-- 6. Which item was purchased first by the customer after they became a member?

WITH cte AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
INNER JOIN members AS mb ON s.customer_id = mb.customer_id AND s.order_date >= mb.join_date
ORDER BY s.order_date) AS a)
SELECT customer_id, product_name AS first_item_after_becoming_member FROM cte WHERE rnk=1;
 
 
 -- 7. Which item was purchased just before the customer became a member?
 
WITH cte AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rnk
FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
INNER JOIN members AS mb ON s.customer_id = mb.customer_id AND s.order_date < mb.join_date
) AS a)
SELECT customer_id, product_name AS last_item_before_becoming_member FROM cte WHERE rnk=1;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT customer_id,COUNT(product_id) AS total_items_bought_before_being_member, SUM(price) AS total_amount_spent_before_being_member FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
INNER JOIN members AS mb ON s.customer_id = mb.customer_id AND s.order_date < mb.join_date) AS a
GROUP BY customer_id ORDER BY customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH cte AS(
SELECT customer_id,product_name,price,
CASE 
	WHEN product_name = 'sushi' THEN price*10*2
    ELSE price*10
END AS points FROM(
SELECT s.*,m.product_name,m.price FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id) As a)
SELECT customer_id, SUM(points) AS total_points_earned FROM cte 
GROUP BY customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(price*10*2) AS total_points_earned FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
INNER JOIN members AS mb 
ON s.customer_id = mb.customer_id AND s.order_date >= mb.join_date AND DATEDIFF(s.order_date,mb.join_date)<=7 ORDER BY customer_id) AS a
GROUP BY customer_id ORDER BY customer_id;


-- Additional tasks to display certain output  tables provided in the challenge(BONUS QUESTIONS)

-- Task --> 1
WITH cte AS (
SELECT *,
CASE
	WHEN join_date>order_date THEN "N"
    WHEN join_date IS NULL THEN "N"
    ELSE "Y"
END AS member FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
LEFT JOIN members AS mb 
ON s.customer_id = mb.customer_id) AS a)
SELECT customer_id,order_date,product_name,price,member FROM cte;


-- Task --> 2
WITH cte AS (
SELECT *,
CASE
	WHEN join_date>order_date THEN "N"
    WHEN join_date IS NULL THEN "N"
    ELSE "Y"
END AS member FROM(
SELECT s.*,m.product_name,m.price,mb.join_date FROM sales AS s INNER JOIN menu AS m ON s.product_id = m.product_id 
LEFT JOIN members AS mb 
ON s.customer_id = mb.customer_id) AS a)
SELECT customer_id,order_date,product_name,price,member,
CASE
	WHEN member = "N" THEN "null"
    ELSE  DENSE_RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date) 
END AS ranking FROM cte;