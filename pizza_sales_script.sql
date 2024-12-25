-- Retrieve the total number of orders placed.
SELECT count(*) as total_orders FROM pizzahut.orders;

-- Calculate the total revenue generated from pizza sales.
SELECT round(SUM(p.price * o.quantity),2)AS total_sales
FROM pizzas AS p
JOIN order_details AS o
ON p.pizza_id = o.pizza_id;

-- Identify the highest-priced pizza.
select pt.name,p.price
from pizzas as p
join pizza_types as pt
on p.pizza_type_id=pt.pizza_type_id
order by price desc limit 1;

-- Identify the most common pizza size ordered.
select p.size,count(od.pizza_id) as most_ordered 
from 
order_details as od
join pizzas as p
on od.pizza_id=p.pizza_id
group by p.size
order by most_ordered desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name,sum(od.quantity) as quantity
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.name order by quantity desc limit 5 ;

-- Join the necessary tables to find the total quantity of each pizza category ordered.-- 
select pt.category,sum(od.quantity) as quantity
from pizza_types as pt 
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category order by quantity desc limit 5;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hours,count(order_id) as order_count
from orders
group by hours ;

-- Join relevant tables to find the category-wise distribution
select category,count(category) as count
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity)) from
(select o.order_date days,sum(od.quantity) as quantity
from orders as o
join order_details as od
on o.order_id=od.order_id
group by o.order_date) as per_day;