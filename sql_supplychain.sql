use supply_chain;
select * from customer;
select * from orderitem;
select * from orders;
select * from product;
select * from supplier;

-- 1.Company sells the product at different discounted rates.
-- Refer actual product price in product table and selling price in the order item table. 
-- Write a query to find out total amount saved in each order
-- then display the orders from highest to lowest amount saved. 

select OrderId,
sum(p.UnitPrice) as Actual_price,
sum(oi.UnitPrice) as selling_price,
sum(p.UnitPrice- oi.UnitPrice) as amount_saved
from orderitem oi join product p on oi.ProductId=p.Id 
group by OrderId
order by amount_saved desc;

-- 2.Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.

select oi.ProductId, p.ProductName,
 s.CompanyName as supplier_company, s.ContactName as supplier_contact,
sum(quantity) total_quantity , sum(p.UnitPrice) total_sales from orderitem oi 
join product p on oi.ProductId=p.Id 
join supplier s on p.SupplierId=s.Id
group by ProductId 
order by  total_sales desc, total_quantity desc limit 25;

-- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- ●	Both customer and supplier belong to the same country
-- ●	Customer who does not have supplier in their country
-- ●	Supplier who does not have customer in their country

select c.FirstName, c.LastName, c.Country as customer_country,
s.Country as supplier_country , s.CompanyName
from customer c
left join supplier s
on c.Country = s.Country
union
select c.FirstName, c.LastName, c.Country as customer_country ,
s.country as supplier_country , s.companyName
from customer c
right join supplier s
on c.Country = s.country;

-- 4.Every supplier supplies specific products to the customers.
-- Create a view of suppliers and total sales made by their products and 
-- write a query on this view to find out top 2 suppliers 
-- (using windows function) in each country by total sales done by the products.

create view supplier_sales_info as
(select s.Id, s.CompanyName, s.ContactName,
s.Country ,sum(o.TotalAmount) as total_sales
from supplier s join product p on s.Id=p.SupplierId
join orderitem oi on oi.ProductId=p.Id
join orders o on o.Id=oi.OrderId
group by 1,2 order by 1);

 select * from (select *, rank() over(partition by Country 
order by total_sales desc) as  country_rank from supplier_sales_info) temp where country_rank < 3 ;

-- 5.	Find out for which products,
-- UK is dependent on other countries for the supply. 
-- List the countries which are supplying these products in the same list.

select c.Country as customer_country, 
p.ProductName,s.Country as supplier_country
 from customer c join orders o on c.Id=o.CustomerId
 join orderitem oi on o.Id=oi.OrderId
 join product p on p.Id = oi.ProductId
 join supplier s on s.Id=p.SupplierId
 where c.Country = 'UK' and s.Country != 'UK'
 order by s.Country;
 
 
-- 6.Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
-- ‘customer’ table attributes - Id, FirstName,LastName,Phone
-- ‘customer_backup’ table attributes - Id, FirstName,LastName,Phone
-- Create a trigger in such a way that It should insert the details
--  into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.

create table ccustomer
(Id int primary key ,
FirstName text,
LastName text,
phone text);

create table customer_backup
(Id int primary key,
FirstName text,
LastName text,
phone text);

create trigger back_up
after delete on ccustomer for each row
insert into customer_backup ( FirstName, LastName, phone)
values( o.FirstName, o.LastName, o.phone);

 ## EXTRA QUESTIONS

--  1. Create a list of customers who does not have suppliers in their country using subquery.
-- Create a list of suppliers  who does not have customers in their country using subquery.

select * from customer where country not in 
(select Country from supplier );

 select * from supplier where country not in 
(select Country from customer );

-- 2. create a list of all the products supplied from Japan.

select p.ProductName,s.Country as supplier_country
from product p join supplier s on s.Id=p.SupplierId
where s.Country like '%japan%';

-- 3. create a list of all the products supplied to london.

select p.ProductName,c.City as Target_location,c.Country as customer_country
from customer c join orders o on c.Id =o.CustomerId
join orderitem oi on o.Id=oi.OrderId
join product p on oi.ProductId=p.Id where c.City = 'london';

-- 4. list top 10 products sold from 'Richard's supply'(Consider selling price).

select p.ProductName,sum(oi.UnitPrice) as selling_price
from product p join orderitem oi
on p.Id=oi.ProductId group by p.ProductName
order by  selling_price desc limit 10;

-- 5. list all the products ordered from Mexico
-- as well as order details such as id and date.

select c.Country as customer_country, oi.OrderId,o.OrderDate,p.ProductName
from customer c join orders o on c.Id =o.CustomerId
join orderitem oi on o.Id=oi.OrderId
join product p on oi.ProductId=p.Id where c.Country='mexico'; 

 