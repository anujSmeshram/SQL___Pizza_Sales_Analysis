-- Basic question:

-- Retrieve the total number of orders placed.
SELECT COUNT(orders.order_id) AS total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(pizzas.price * order_details.quantity),2) AS total_revenue FROM pizzas
JOIN  order_details ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name, MAX(pizzas.price) AS highest_price FROM pizzas 
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY MAX(pizzas.price) DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(*) AS order_count FROM pizzas 
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.)
SELECT pizza_types.name, sum(order_details.quantity) AS num FROM pizzas
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY num DESC
LIMIT 5;


-- Intermediate:
 
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) AS quantity FROM pizzas 
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day(AM/PM).

SELECT DATE_FORMAT(orders.order_time,'%h %p') AS hour, COUNT(*) AS orders_count FROM orders
GROUP BY hour;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(avg(quantity),0) FROM
(SELECT orders.orde_date, SUM(order_details.quantity) AS quantity FROM orders
JOIN order_details ON order_details.order_id = orders.order_id
GROUP BY orders.orde_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, ROUND(sum(order_details.quantity * pizzas.price),2) AS revenue FROM pizzas
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,ROUND((SUM(order_details.quantity * pizzas.price)/(SELECT SUM(order_details.quantity * pizzas.price) AS total_sales FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id))*100,2) AS revenue FROM pizzas
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;




-- Analyze the cumulative revenue generated over time.
SELECT orde_date, SUM(revenue) OVER(ORDER BY orde_date) AS cum_revenue FROM
(SELECT orders.orde_date, SUM(order_details.quantity * pizzas.price) AS revenue FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN orders ON orders.order_id = order_details.order_id
GROUP BY orders.orde_date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, category, revenue FROM 
(SELECT name, category,revenue,RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn FROM
(SELECT pizza_types.name,pizza_types.category,SUM(order_details.quantity * pizzas.price) AS revenue FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name,pizza_types.category) AS a ) AS b
WHERE rn <= 3;