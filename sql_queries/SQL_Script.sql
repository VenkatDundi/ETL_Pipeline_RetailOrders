drop table if exists df_orders;

create table df_orders(
[order_id] int primary key
,[order_date] date
,[ship_mode] varchar(20)
,[segment] varchar(20)
,[country] varchar(20)
,[city] varchar(20)
,[state] varchar(20)
,[postal_code] varchar(20)
,[region] varchar(20)
,[category] varchar(20)
,[sub_category] varchar(20)
,[product_id] varchar(50)
,[quantity] int
,[discount] decimal(7,2)
,[sale_price] decimal(7,2)
,[returns] decimal(7,2)
,[returns%] decimal(7,2)
)

select * from df_orders where sale_price=0;

select top 5 * from df_orders;


/* Update returns% - NULL to 0 */

update df_orders set [returns%] = 0 
where [sale_price]=0 and [discount]=0 and returns=0;


/* Top Region in Sales */

select top 1 region as 'Region', sum(sale_price) as 'Regional Sales'		
from df_orders
group by region order by 2 desc;

select region as 'Region', sum(sale_price) as 'Regional Sales'		
from df_orders
group by region order by 2 desc;


/* Top State by Sales */

select top 1 *, rank() over(order by [State Sales] desc) as 'rank'			
from(select [state], sum(sale_price) as 'State Sales' 
from df_orders group by [state]) x;


select * from (select *, rank() over(partition by [region] order by [State Sales] desc) as 'rank'			
from(select [region], [state], sum(sale_price) as 'State Sales' 
from df_orders group by [region], [state]) x) x1 where x1.rank <=3;



/* Top City by Sales */

with cte as
(select city, sum(sale_price) as 'City Sales' 
from df_orders group by city)	 
select top 1 cte.city, cte.[City Sales], rank() over(order by cte.[City Sales] desc) as 'rank' from cte;

/* Top Segment by Sales */

with cte as																	
(select segment, sum(sale_price) as 'Segment Sales' 
from df_orders  group by segment)
select top 1 cte.segment, cte.[Segment Sales], rank() over(order by cte.[Segment Sales] desc) as 'r' from cte;


/* Region with highest order frequency */

select top 1 region, count(order_id) as 'Orders' 
from df_orders group by region order by 2 desc;


/* Shipment mode distribution */

with cte as
(select distinct ship_mode, count(order_id) over(partition by ship_mode) as 'Orders',
sum(sale_price) over(partition by ship_mode) as 'Sales' 
from df_orders)
select cte.ship_mode, cte.Orders, cte.Sales, 
round((cte.Sales * 100.0) / (select sum(sale_price) from df_orders), 3) as 'Sales %' from cte;



/* Top products with highest profit returns % */

select * from (select product_id as 'Product_ID', [returns%] as 'Returns%', 
dense_rank() over(order by [returns%] desc) as 'rank' 
from df_orders)x where x.rank<=1;


/* Top products with highest loss % */
select * from (select product_id as 'Product_ID', [returns%] as 'Returns%', 
dense_rank() over(order by [returns%] asc) as 'rank' 
from df_orders)x where x.rank<=1;


/* Average discount per product category */

select distinct category as 'Category', AVG(discount) over(partition by category) as 'Average Discount' from df_orders;

select category, count(order_id) as 'Order Count', sum(discount) as 'Total Discount', 
sum(discount)/count(order_id) as 'Average' from df_orders group by category;

/* Products with highest discount percentage */ 
--- Using Case to avoid the 'Divide by Zero' as we have '0' for sale_price and discount

select *, rank() over(order by [Discount%] desc) as 'r' from 
(select product_id, case when [discount] = 0 and [sale_price] = 0 then 0
			when [sale_price] !=0 then CAST([discount]*100 / ([discount]+[sale_price]) as decimal(4,2))
			end as 'Discount%'
		from df_orders) x;


/* Orders and Quantity by category, sub category */

select category, [sub_category], count(order_id) as 'Order Count', sum(quantity) as 'Quantity' from df_orders group by category, [sub_category] order by 1, 2, 3 desc, 4 desc;



/* Top 10 revenue generating products */

select top 10 *, rank() over(order by x.[Sales] desc) as 'r' from (select product_id, sum(sale_price) as 'Sales' from df_orders group by product_id) x;

/* Top 5 best selling products for each region */

with cte as
(select *, rank() over(partition by region order by [Sales] desc) as 'r' from (select distinct region, product_id, sum(sale_price) over(partition by region, product_id) as 'Sales' from df_orders) x)
select * from cte where cte.r<=5;


select top 5 * from df_orders;


/* Month over month growth comparison between 2022 and 2023 */

with cte as(
select x.Month, x.[Month Sales], lead(x.[Month Sales]) over(partition by x.Month order by x.Month, x.Year) as 'Recent Sales' from (select month(order_date) as 'Month', year(order_date) as 'Year', sum(sale_price)as 'Month Sales' from df_orders group by month(order_date), year(order_date)) x)
select *, CAST((cte.[Recent Sales] - cte.[Month Sales]) * 100.0 / (cte.[Month Sales]) as Decimal(4,2)) 'Month Over Month' from cte where cte.[Recent Sales] is not null;


with cte as (
select month(order_date) as 'Month', year(order_date) as 'Year', sum(sale_price)as 'Month Sales' from df_orders group by month(order_date), year(order_date)) --order by 1, 2)
select cte.Month, max(case when cte.Year=2022 then cte.[Month Sales] else 0 end) as '2022',
					max(case when cte.Year=2023 then cte.[Month Sales] else 0 end) as '2023' from cte group by cte.Month order by cte.Month;

/* Year over Year comparison */

select Year(order_date) as 'Year', sum(sale_price) as 'Year Sales' from df_orders group by year(order_date);


with cte as(							--- Using PIVOT
select 	[2022] as 'Sales_2022',
		[2023] as 'Sales_2023'
		from (select Year(order_date) as 'Year', sale_price from df_orders) as src
		PIVOT
		(
			sum(sale_price) for Year IN ([2022], [2023])
		) as pvt)

select *, CAST((cte.[Sales_2023]-cte.[Sales_2022]) * 100.0 / cte.[Sales_2022] as decimal(4,2)) as 'Growth %' from cte;


/* Highest Sales Month for each Category */

with cte as(
select x.category, x.Month, x.[Monthly Sales], rank() over(partition by x.category order by x.[Monthly Sales] desc) as 'r' from (select category, format(order_date, 'yyyyMM') as 'Month', sum(sale_price) as 'Monthly Sales' from df_orders group by category, format(order_date, 'yyyyMM')) x)
select * from cte where cte.r<=1;					--- using Format (yyyyMM)


with cte as(
select x.category, x.Month, x.[Monthly Sales], rank() over(partition by x.category order by x.[Monthly Sales] desc) as 'r' from (select category, month(order_date) as 'Month', sum(sale_price) as 'Monthly Sales' from df_orders group by category, month(order_date)) x)
select * from cte where cte.r<=1;				--- using Fomrat(MM) - Irrespective of Year, considering the sales per Month


/* Subcategory with highest growth by profit in 2023 compared to 2022 */



with cte as(
select sub_category, format(order_date, 'yyyy') as 'Year', sum(sale_price) as 'Sales' from df_orders group by sub_category, format(order_date, 'yyyy')), cte2 as(
select sub_category,
		[2022] as 'Sales_2022',
		[2023] as 'Sales_2023'
		from (
			select sub_category, Year, Sales from cte
		) as src
		PIVOT
		(
			max([Sales]) for Year in ([2022], [2023])
		) as pvt)
select top 5 *, CAST((cte2.[Sales_2023] - cte2.[Sales_2022]) * 100.0 / cte2.[Sales_2022] AS decimal(4,2)) as 'Growth %' from cte2 order by 4 desc;


select count(distinct(segment)) as 'Total Segments', 
		count(order_id) as 'Total Orders',
		count(distinct(product_id)) as 'Unique Products',
		count(distinct(category)) as 'Unique Categories',
		count(distinct(sub_category)) as 'Unique Sub Categories',
		sum(sale_price) as 'Total Sales',
		sum(discount) as 'Total Discount' from df_orders;

exec TopSubCategoryProfit 3;

CREATE PROCEDURE TopSubCategoryProfit
    @ranking int
AS
BEGIN
		with cte as(
	select sub_category, format(order_date, 'yyyy') as 'Year', sum(sale_price) as 'Sales' from df_orders group by sub_category, format(order_date, 'yyyy')), cte2 as(
	select sub_category,
			[2022] as 'Sales_2022',
			[2023] as 'Sales_2023'
			from (
				select sub_category, Year, Sales from cte
			) as src
			PIVOT
			(
				max([Sales]) for Year in ([2022], [2023])
			) as pvt)
	select top (@ranking) *, CAST((cte2.[Sales_2023] - cte2.[Sales_2022]) * 100.0 / cte2.[Sales_2022] AS decimal(4,2)) as 'Growth %' from cte2 order by 4 desc;
END;