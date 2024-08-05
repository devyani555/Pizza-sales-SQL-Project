SHOW TABLES;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);


CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

ALTER TABLE orders
CHANGE COLUMN orer_date order_date DATE;

select *
from orders;

--

SELECT COUNT(order_id) as Total_Orders
FROM orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    -- Identify the highest-priced pizza.
    
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT p.pizza_id, p.pizza_type_id, p.size, pt.name
FROM pizzas p
INNER JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.size DESC 
LIMIT 1;   --  not the way to write this

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
 
 SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;
 
 -- Join the necessary tables to find the total quantity 
 -- of each pizza category ordered. 
 
SELECT pt.category, sum(od.quantity) AS quantity
FROM pizza_types pt 
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category 
ORDER BY quantity  DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, count(name) as name 
FROM pizza_types
GROUP BY category;

-- Group the orders by date and  
-- calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name,SUM(od.quantity * p.price) as Revenue
FROM pizza_types pt
JOIN pizzas p
on p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category, 
       ROUND((SUM(od.quantity * p.price) / 
           (SELECT SUM(order_details.quantity * pizzas.price)
            FROM order_details
            JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)
       ) * 100, 2) AS revenue
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.



SELECT order_date,
sum(revenue) OVER(ORDER BY ORDER_DATE) AS cum_revenue
FROM 
(SELECT o.order_date,
sum(od.quantity * p.price) as revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN orders o
ON o.order_id = od.order_id
GROUP BY o.order_date) as sales;

-- Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.

SELECT name, revenue 
FROM (
    SELECT category, name, revenue, 
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pt.category, pt.name, 
               SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt
        JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od ON od.pizza_id = p.pizza_id
        GROUP BY pt.category, pt.name
    ) AS a
) AS b
WHERE rn <= 3;

