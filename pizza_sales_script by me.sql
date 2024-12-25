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

-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name,round(sum(od.quantity*p.price),0) as revenue
from pizza_types as pt
join pizzas as p on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,concat(round((sum(od.quantity*p.price)/(SELECT round(SUM(p.price * od.quantity),2)AS total_sales
FROM pizzas as p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id))*100,2),"%") as revenue
from
pizza_types as pt
join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date,
round(sum(revenue) over (order by order_date)) as cumulative_sale
from
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue 
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rnk
from
	(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
	from pizza_types join pizzas
	on pizza_types.pizza_type_id=pizzas.pizza_type_id
	join order_details 
	on order_details.pizza_id=pizzas.pizza_id
	group by pizza_types.name,pizza_types.category) as a) as b
    where rnk<=3;
