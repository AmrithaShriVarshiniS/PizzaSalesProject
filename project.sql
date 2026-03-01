-- Objective:
-- The SQL Pizza Sales Analysis project aims to uncover insights from pizza store sales data using SQL.
-- To analyze customer behavior, sales trends, and operational patterns.

-- Key Learning Outcomes:
-- Apply SQL querying skills for real-world data analysis
-- Extract, join, group, and aggregate data to generate insights
-- Make data-driven decisions based on sales data




CREATE DATABASE PROJECT;
use project;
select * from order_details limit 10;
select * from orders limit 10;
select * from pizza_types;
-- select count(pizza_type_id) from pizza_types;
select * from pizzas;
-- select count(pizza_id) from pizzas;


-- Chapter 1: Introduction
-- Areas of Focus:
-- 1 Top-Selling & Most Ordered Pizzas: Most frequently ordered & high revenue-generating types.
-- 2 Revenue Analysis: Sales trends over time, including seasonal patterns.
-- 3 Order Patterns: Peak hours, average sales per day.
-- 4 Category-Wise Analysis: Distribution across categories to improve inventory and 
-- marketing
-- ----------------------------------------------------------------------------------------------------------
-- Top-Selling & Most Ordered Pizzas: Most frequently ordered & high revenue-generating types.
-- Result
-- 1. Most frequently ordered Pizza_type is 'big_meat_s' with '1914' orders
select pizza_id, sum(quantity) as quantity_pizzaType
from order_details 
group by pizza_id
order by quantity_pizzaType desc
limit 1;

-- high revenue-generating types
-- thai_ckn_l is the high revenue-generating pizza type which has generated	Rs. 29257.5 
with rev_temp as (select od.pizza_id, od.quantity, p.price
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id)
,rev1 as(
select *, 
quantity*price as revenue
from rev_temp)
select pizza_id, round(sum(revenue),2) as total_revenue
from rev1
group by pizza_id
order by total_revenue desc
limit 1;

-- 2
-- Revenue Analysis: Sales trends over time, including seasonal patterns.
-- What they really want: Time-based aggregation; Trend identification; Seasonality detection;

-- 2A - month/seasonal Revenue analysis

-- RESULT: total revenue = '817860.04'; total quantity sold = '49574'
-- there is not much noticeable seasonal or monthly pattern since the range of percentage contribution 
-- of monthly revenue is from 7.83% to 8.87% i.e. the difference in revenue contribution lies only between 1%.
-- Thus, seasonal/monthly revenue distribution pattern is uniform.
with rev_date_temp as (select od.*, p.price, o.date, o.time, od.quantity*p.price as revenue
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id
left join orders as o
on od.order_id = o.order_id)
select sum(revenue) from rev_date_temp;
select  date_format(date, '%b') as month, round(sum(revenue),2) as month_rev, 
concat(round(sum(revenue)*100/(select sum(revenue) from rev_date_temp),2), '%') as month_rev_percent
from rev_date_temp
group by date_format(date, '%b')
order by month_rev desc;


-- 2.b day based revenue analysis
-- Result
-- Revenue peaks on Fridays (16.64%) and remains strong through Thursday and Saturday (~15%), 
-- indicating higher end-of-week demand. 
-- Sunday records the lowest contribution (12.13%), suggesting reduced weekend closure effect.

with rev_date_temp as (select od.*, p.price, o.date, o.time, od.quantity*p.price as revenue
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id
left join orders as o
on od.order_id = o.order_id)
-- select * from rev_date_temp;
select date_format(date, '%a') as day, round(sum(revenue),2) as day_rev, 
concat(round(sum(revenue)*100/(select sum(revenue) from rev_date_temp),2), '%') as day_rev_percent
from rev_date_temp
group by date_format(date, '%a')
order by day_rev desc;


-- 3 Order Patterns: Peak hours, average sales per day.
-- 3A Time based (peak hour) revenue generation analysis 

-- Result
-- Revenue is heavily concentrated during lunch hours (12–2 PM), contributing over 26% combined.
-- A secondary peak is observed during early dinner hours (5–7 PM), contributing around 21% combined.
-- Late night (after 9 PM) contributes negligibly (<1%).

with rev_date_temp as (select od.*, p.price, o.date, o.time, od.quantity*p.price as revenue
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id
left join orders as o
on od.order_id = o.order_id)
-- select * from rev_date_temp;
select hour(time) as time_of_day,
round(sum(revenue),2) as time_rev, 
concat(round(sum(revenue)*100/(select sum(revenue) from rev_date_temp),2), '%') as time_rev_percent
from rev_date_temp
group by time_of_day
order by time_rev desc;

-- Result
-- sales peaks at afternoons(40%) & evenings(39%) contributing to 80% of revenue generation 
-- i.e. from 12 noon to 8 PM. Nights sharply declines to 15% & forenoons generate least revenue with only 5%.

with rev_date_temp as (select od.*, p.price, o.date, o.time, od.quantity*p.price as revenue
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id
left join orders as o
on od.order_id = o.order_id)
 select case
   when hour(time) < 12 then 'forenoon'
   when hour(time) >= 12 and hour(time) < 16 then 'afternoon'
   when hour(time) >= 16 and hour(time) < 20 then 'evening'
   else 'night'
 end as time_of_day,
 round(sum(revenue),2) as time_rev, 
 concat(round(sum(revenue)*100/(select sum(revenue) from rev_date_temp),2), '%') as time_rev_percent
 from rev_date_temp
 group by time_of_day
 order by time_rev desc;




-- 3B Avg Sales per Day
-- Result
-- Fridays generate the highest revenue (Rs. 2721), indicating strong end-of-week demand.
-- Thursday (Rs. 2375) and Saturday (Rs. 2368) also perform strongly, suggesting demand begins increasing before the weekend and sustains into Saturday.
-- Sunday (Rs. 1907) records the lowest revenue, indicating weaker post-weekend sales momentum.
-- Revenue remains relatively stable from Monday to Wednesday (around Rs. 2200), followed by a clear spike toward the end of the week.

with rev_date_temp as (select od.*, p.price, o.date, o.time, od.quantity*p.price as revenue
from order_details as od
left join pizzas as p
on od.pizza_id = p.pizza_id
left join orders as o
on od.order_id = o.order_id)
-- select * from rev_date_temp;
,rev_per_date as (
select date, round(sum(revenue),2) as sum_day_rev
from rev_date_temp
group by date
order by sum_day_rev desc)
-- select * from rev_per_date;
select date_format(date, '%a') as day, round(avg(sum_day_rev),2) as avg_day_rev
-- concat(round(sum(revenue)*100/(select sum(revenue) from rev_date_temp),2), '%') as day_rev_percent
from rev_per_date
group by date_format(date, '%a')
order by avg_day_rev desc;
-- dates & orders are to be aggregated first & only then avg is to be calculated. 
-- if we calculate avg directy on revenue column, we'll calculate row level



-- Category-Wise Analysis: Distribution across categories to improve inventory and marketing
-- 4 a: categorywise quantity sold & % contribution of each category
-- 4 b: categorywise revenue generated % contribution of each category
-- 4 c: Possibly average order size per category

-- Result
-- Category-wise Summary
-- Classic
-- * Highest quantity share (30%)
-- * Highest revenue share (26.9%)
-- * Lowest ASP (₹14.78)
--   → Volume-driven category. Competes on price, drives overall sales.

-- **Chicken**
-- * Lowest quantity share (~22%)
-- * Revenue share higher than volume share (23.96%)
-- * Highest ASP (₹17.73)
--   → Premium-priced. Strong revenue per unit despite lower volume.

-- **Supreme**
-- * Balanced quantity (24%) and revenue (25.46%)
-- * High ASP (₹17.37)
--   → Upper-mid premium category with stable performance.

-- **Veggie**
-- * Similar quantity (23%) and revenue (23.68%)
-- * Mid ASP (₹16.63)
--   → Balanced contributor, neither strongly premium nor volume-heavy.

-- * Classic dominates through **volume**.
-- * Chicken & Supreme strengthen revenue through **higher pricing (ASP effect)**.
-- * Revenue differences are primarily explained by **price positioning**, not just sales volume.



-- 4 a: categorywise quantity sold & % contribution of each category

with category_analysis as(
select pt.*, p.size, p.price, od.*,
quantity*price as revenue
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id
)
select category, sum(quantity) as categ_quantity 
, sum(sum(quantity)) over() as tot_quantity
, concat(round(sum(quantity)*100/sum(sum(quantity)) over(), 2), '%') as percent_quantity
from category_analysis
group by category
order by sum(quantity) desc;
-- Result: 
-- Classic has highest contribution (30%) to quantity sold.
-- followed by Supreme, Veggie & Chicken with 24%, 23% & 22% respectively.
-- So Classic leads other categories with 6-8 percentage points in quantity share.


-- 4 b: categorywise revenue generated % contribution of each category
with category_analysis as(
select pt.*, p.size, p.price, od.*,
quantity*price as revenue
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id
)
select category, round(sum(revenue),2) as category_revenue 
, round(sum(sum(revenue)) over (),2) as total_revenue
, concat(round(sum(revenue)*100/sum(sum(revenue)) over (), 2), '%') as percent_revenue
from category_analysis
group by category
order by sum(revenue) desc;
-- Result
-- Classic has highest revenue contribution(26.9%) followed by Supreme(25.46%), Chicken(23.96%) & Veggie(23.68%)


-- ASP: Avg Selling Price = Revenue/Units Sold

with category_analysis as(
select pt.*, p.size, p.price, od.*,
quantity*price as revenue
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id
)
-- select * from category_analysis;
select category, round(sum(revenue)/sum(quantity), 2) as Avg_selling_price
from category_analysis
group by category
order by Avg_selling_price desc;
-- Result: 
-- Chicken has highest ASP (17.73) followed by Supreme (17.37), Veggie(16.63) and 
-- Classic has the least ASP(14.78)

-- Chapter 2: Data Exploration
-- Task 1: Retrieve the total number of orders placed.
-- Task 2: Calculate the total revenue generated from pizza sales.
-- Task 3: Identify the highest-priced pizza.
-- Task 4: Identify the most common pizza size ordered.

-- Task 1: Retrieve the total number of orders placed.
-- Result : '48620' is the total number of orders placed
select * from order_details limit 10;
select count(order_id) from order_details as TotalNoOfOrders;

-- Task 2: Calculate the total revenue generated from pizza sales.
-- total revenue = 'Rs. 817860.04' (already calculated in Chapter 1)

-- Task 3: Identify the highest-priced pizza.
-- Highest priced Pizza is 'the_greek' pizza in size 'XXL'
select * from pizzas where price = (select max(price) from pizzas);

-- Task 4: Identify the most common pizza size ordered.
-- Result: L is the most commonly ordered pizza size with 18956 numbers sold followed by
-- M (15635), S (14403), XL (552), XXL (28)
with size_orderDetails as (
select p.*, od.order_details_id, od.order_id, od.quantity
from pizzas as p
inner join order_details as od
on p.pizza_id = od.pizza_id)
-- select * from size_orderDetails;
select size, sum(quantity) as Total_quantity
from size_orderDetails
group by size
order by size;


-- Chapter 3: Sales Analysis - Crunching the Numbers
-- Task 1: List the top 5 most ordered pizza types along with their quantities.
-- Task 2: Determine the distribution of orders by hour of the day.
-- Task 3: Determine the top 3 most ordered pizza types based on revenue.

-- Task 1: List the top 5 most ordered pizza types along with their quantities.
-- Result: these are the top 5 most ordered pizza types along with their quantities
-- 1. The Classic Deluxe Pizza:2453, 
-- 2. The Barbecue Chicken Pizza:2432,
-- 3. The Hawaiian Pizza:2422,
-- 4. The Pepperoni Pizza:2418,
-- 5. The Thai Chicken Pizza:2371

with pizzaTypes_orderDetails as (
select pt.*, od.*
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id
)
select pizza_type_id, name, sum(quantity) as total_quantity
from pizzaTypes_orderDetails
group by pizza_type_id, name
order by total_quantity desc
limit 5;



-- Task 3: Determine the top 3 most ordered pizza types based on revenue.
-- Result: top 3 most ordered pizza types based on revenue are
-- The Thai Chicken Pizza:	43434.25
-- The Barbecue Chicken Pizza:	42768
-- The California Chicken Pizza:  41409.5
with od_pt_p as(
select pt.pizza_type_id, name, quantity, price, quantity*price as revenue
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id)
select pizza_type_id, name, sum(revenue) as total_revenue
from od_pt_p
group by pizza_type_id, name
order by total_revenue desc;


-- Chapter 4: Operational Insights
-- Task 1: Calculate the percentage contribution of each pizza type to total revenue.
-- Task 2: Analyze the cumulative revenue generated over time.
-- Task 3: Determine the top 3 most ordered pizza types based on revenue for each pizza 
-- category.

-- Task 1: Calculate the percentage contribution of each pizza type to total revenue.
-- Result: 
-- Top pizzas contribute around 5% each; Mid performers around 3–4%; Lowest around 1–2%
-- In line with earlier result, The Thai Chicken Pizza(5.31%), The Barbecue Chicken Pizza(5.23%),
-- The California Chicken Pizza	(5.06%) are the top contributers

with od_pt_p as(
select pt.pizza_type_id, name, quantity, price, quantity*price as revenue
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id)
select pizza_type_id, name,
concat(round(sum(revenue)*100/(select sum(revenue) from od_pt_p), 2), '%') as revenue_contribution
from od_pt_p
group by pizza_type_id, name
order by revenue_contribution desc;

-- Task 2: Analyze the cumulative revenue generated over time.
-- Result:
-- Monthly revenue contribution remains steady at around 8%, indicating uniform revenue distribution across months.
-- Revenue growth is consistent month-over-month with no significant seasonal spikes.

with od_pt_p as(
select date, time, quantity*price as revenue
from orders as o
left join order_details as od
on od.order_id = o.order_id
left join pizzas as p
on p.pizza_id = od.pizza_id)
select date, time, sum(revenue) as revenue,
sum(sum(revenue)) over(order by  date, time rows between unbounded preceding and current row) as cumulative_revenue
from od_pt_p
group by date, time;

with od_pt_p as(
select date, time, quantity*price as revenue
from orders as o
left join order_details as od
on od.order_id = o.order_id
left join pizzas as p
on p.pizza_id = od.pizza_id)
-- select * from od_pt_p;
, running_revenue as (
select month(date) as month, round(sum(revenue),2) as revenue,
round(sum(sum(revenue)) over(order by  month(date)),2) as cumulative_revenue,
round(sum(sum(revenue)) over(order by  month(date))*100/ sum(sum(revenue)) over(), 2) as percent_growth
from od_pt_p
group by month(date)
)
select month, percent_growth,
lag(percent_growth, 1, 0) over(order by month) as lag_percent_growth,
round(percent_growth-lag(percent_growth, 1, 0) over(order by month),2) as monthly_rev_growth
from running_revenue;



-- Task 3: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- Result: U
with pt_p_od as (
select pt.category, pt.name, p.pizza_type_id, price * quantity as revenue
from pizza_types as pt
inner join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
inner join order_details as od
on p.pizza_id = od.pizza_id)
, category_pt as
(select category, name, pizza_type_id, round(sum(revenue), 2) as total_revenue
from pt_p_od
group by category, name, pizza_type_id
order by total_revenue)
, ranked as(
select *, 
dense_rank() over(partition by category order by total_revenue desc) as rn
from category_pt)
select * from ranked
where rn <= 3;


-- Chapter 5: Category-Wise Analysis
-- Task 1: Join the necessary tables to find the total quantity of each pizza category ordered.
-- Task 2: Join relevant tables to find the category-wise distribution of pizzas.
-- Task 3: Group the orders by the date and calculate the average number of pizzas ordered per day.

-- Task 1: Join the necessary tables to find the total quantity of each pizza category ordered.
-- Result: # category, total_quantity
-- 'Chicken', '11050'
-- 'Classic', '14888'
-- 'Supreme', '11987'
-- 'Veggie', '11649'

with pt_p_od as (
select pt.category, od.quantity
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id) 
select category, sum(quantity) as total_quantity 
from pt_p_od
group by category
order by total_quantity desc;

-- Task 2: Join relevant tables to find the category-wise distribution of pizzas.
-- result: categorywise qua

with pt_p_od as (
select pt.category, od.quantity
from pizza_types as pt
left join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
left join order_details as od
on p.pizza_id = od.pizza_id) 
,final as (select category, sum(quantity) as total_quantity 
from pt_p_od
group by category
order by total_quantity desc)
select *, total_quantity*100/sum(total_quantity) over() as percent_distribution
from final;

select category, 
total_quantity*100/(select sum(total_quantity) from category_quantity) as percent_quantity
from category_quantity;


-- Task 3: Group the orders by the date and calculate the average number of pizzas ordered per day.
with od_o as (
select date, sum(quantity) as quan_per_day
from order_details as od
inner join orders as o
on od.order_id = o.order_id
group by date)
select avg(quan_per_day) as avg_qnty_per_day
from od_o;



-- End of Project Deliverables:
-- Create the summary of insights and recommendations for store management 

-- 







-- 1. Quantity
with quan_temp as(
select pizza_id, sum(quantity) as quantityPerPizzaID,
ntile(5) over(order by sum(quantity) desc) as percentile
from order_details
group by pizza_id)
, quantPerPercentile as(
select percentile, sum(quantityPerPizzaID) as quantPerPercentile
from quan_temp
group by percentile)
select pizza_id from quan_temp where percentile = 1;
select percentile, 
concat(round(quantPerPercentile*100/(select sum(quantPerPercentile) from quantPerPercentile),2), '%') as quantity_contribution
from quantPerPercentile;
-- out of 91 pizza_types(pizza_id), 19 is contributing to 40% of sales & they are as follows
-- 'bbq_ckn_l', 'bbq_ckn_m', 'big_meat_s', 'cali_ckn_l','cali_ckn_m','classic_dlx_m','classic_dlx_s',
-- 'five_cheese_l','four_cheese_l','hawaiian_l','hawaiian_s','ital_supr_m','mexicana_l','pepperoni_m',
-- 'pepperoni_s', 'sicilian_s', 'southw_ckn_l', 'spicy_ital_l', 'thai_ckn_l'

select p.pizza_id, sum(od.quantity) as total_quantity
from pizzas as p
inner join order_details as od
on p.pizza_id = od.pizza_id
group by p.pizza_id
order by total_quantity desc;
