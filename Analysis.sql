####Introduction
-- the following is a projects focused on data analysis through SQL,
-- source of database:https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting
-- source for question for data analysis:https://github.com/Princekrampah/WalmartSalesAnalysis


-- Use Wallmartproject


-- 1
-- Data was cleaned from Null values by making all values in table not null

#
CREATE TABLE Sales_Data(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch	VARCHAR(5) NOT NULL,
city	VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender	VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price	DECIMAL(10, 2) NOT NULL,
quantity	INT NOT NULL,
VAT	FLOAT(6, 4) NOT NULL,
total	DECIMAL(12, 4) NOT NULL,
date	DATETIME NOT NULL,
time	TIME NOT NULL,
payment_method	VARCHAR(15) NOT NULL,
cogs	DECIMAL(10, 2) NOT NULL,
gross_margin_percentage	FLOAT(11, 9) NOT NULL,
gross_income	DECIMAL(10, 2) NOT NULL,
rating	FLOAT(2, 1) NOT NULL
);



--  2
-- Feature engineering:creating new columns from existing ones

#
-- select time from sales_data:
-- 2.1

-- Here we want to make it easier to identify the time of day so Morning,Afternoon or Evening and then analyse to check which
-- part of the day the most sales take place 


####QUESTION:Which part of the day most of the sales are made.


#
alter table sales_data
add column time_of_day varchar(30);	

-- After creating the new column we populate it so that if time is before 12:00:00 then we enter AM else we put PM
#
update sales_data
set time_of_day = 'Morning'
where time <= '12:00:00';
#
update sales_data
set time_of_day = 'Afternoon'
where time > '12:00:00' and time <='16:00:00';
# 
update sales_data
set time_of_day = 'Evening'
where time > '16:00:00';

###ANSWER:The highest amount of sales according to data take place in Evening with total of 429 sales, then there is Afternoon
-- coming in second place with 376 total invoices and lastly Morning with total of 190 invoices
#this is if the sales means the number of invoices

#below is the code showing the results

Select time_of_day, count(*) from sales_data
group by time_of_day;

#if the sales means the total price that time of the day
#them the answer is  Evening 137365.2735 then afternoon 122276.6055 then Morning 61244.5155

Select time_of_day, sum(total) from sales_data
group by time_of_day;




#####2.2
-- to get the dayname what we can do is use the dayname function then
###QUESTION:on which day of the week each branch is busiest.

alter table sales_data
add column dayname VARCHAR(10);

select dayname(date) from sales_data;
#this part will populate the table using the aggregate function
update sales_data 
set dayname = DAYNAME(date);
"
####Answer:Because we cant group by 2 different columns we can first create 3 
-- tables where each only displays all the information about each,then from 
-- from each table we count total invoices then group them by weekday
-- hence the answer was for branch A=Sunday ####for branch B=Saturday ####for branch C= is both Tuesday and Saturday
"
 


#here is the code for branch A
select a.dayname,count(b.dayname) as branch_A_sales_per_day
from sales_data as a 
Right join 
(select * from sales_data where branch = 'A') as b
on a.invoice_id = b.invoice_id
group by dayname


#here is the code for branch B
select a.dayname,count(b.dayname) as branch_B_sales_per_day
from sales_data as a 
Right join 
(select * from sales_data where branch = 'B') as b
on a.invoice_id = b.invoice_id
group by dayname

#here is the code for branch C
select a.dayname,count(b.dayname) as branch_C_sales_per_day
from sales_data as a 
Right join 
(select * from sales_data where branch = 'C') as b
on a.invoice_id = b.invoice_id
group by dayname


#####2.3 
-- first we create a new column named month_name

select date,monthname(date) from sales_data

#creating the new column
alter table sales_data
add column monthname varchar(15)

#populating the new monthname column
update sales_data
set monthname = monthname(date)

####Question:determine which month of the year has the most sales and profit.


####Answer:first we will need to find the month of the year with most sales then
-- we can find the month with highest profit
-- in terms of sales the month with highest sales is January(116291.87$),followed
-- by March(108867.15$) and lastly February(95727.38$)

-- while in terms of profit/gross income the month with the highest is 
-- January(5537.95$),followed by March(5184.38$) and lastly 
-- February(4558.65$)

#code for total sales per month
Select monthname, sum(total) as 'total_sales_per_month' from sales_data
group by monthname order by total_sales_per_month desc;

#this is the code to find the highest total profit per month
SELECT 
    monthname, SUM(gross_income) AS 'total_profit_per_month'
FROM
    sales_data
GROUP BY monthname
ORDER BY total_profit_per_month DESC;

#######-------------------===================--------------Business Questions To Answer
####----------------------------------------Generic Question:
###Question 1:How many unique cities does the data have?
##Answer:the data has 3 uniques cities (Yangon,Naypyitaw and Mandalay)

#this is the code for finding all unique cities
select city from sales_data
group by city

###Question 2:in which city is each branch?
##Answer:the best way to do this will be to use a union which removes any duplicates
-- Branch A is in Yangon, Branch B is in Mandalay and Branch C is in Naypaitaw 

#the code to find which branch belongs to which city is below
select branch, city from sales_data
union 
select branch,city from sales_data


####----------------------------------------Product Related:
###Question 1:How many unique product lines does the data have?
##Answer: there are 6 different product lines which are:
-- 1.Food and beverages
-- 2.Health and beauty
-- 3.Sports and travel
-- 4.Fashion accessories
-- 5.Home and lifestyle
-- 6.Electronic accessories


#here is the code to find out the unique product lines
select product_line from sales_data
group by product_line

###Question 2:What is the most common payment method?
##Answer:the most used payment method is cash with total of 344 

#first code that I came up with to find the most used payment method
select payment_method,count(*) as uses_per_method from sales_data
group by payment_method
having count(*)  = (select max(a.uses_per_method) from
(select payment_method,count(*) as uses_per_method from sales_data
group by payment_method) as a)

#this is the revised version
select payment_method,count(*) as uses_per_method from sales_data
group by payment_method
order by uses_per_method desc
limit 1

###Question 3:What is the most selling product line?
##Answer: the most selling product line is Food and beverages with 952 sales

#here is the code
select product_line,sum(quantity) as total_sales
from sales_data
group by product_line

###Question 4:What is the total revenue by month?
##Answer: the total revenue per month is:
-- January = 116291.87$
-- February = 95727.38$
-- March = 108867.15$

#here is the code 
select monthname,sum(total) as monthly_revenue from sales_data
group by monthname

###Question 5:What month had the largest COGS?
##Answer:  the month with Largest COGS is January with COGS = 110754.16$

#the code is
select monthname,sum(cogs) as monthly_cogs 
from sales_data
group by monthname
order by monthly_cogs desc
limit 1
 
 
###Question 6:What product line had the largest revenue?
##Answer: the product line with the largest revenue is Food and beverages with revenue of 56144.84$

 
 #the code is below
select product_line,sum(total) as revenue from sales_data
group by product_line
order by revenue desc
limit 1


###Question 7:What is the city with the largest revenue?
##Answer:the city with the largest revenue is Naypyitaw with revenue of 110490.78$
 
#here is the code 
select city,sum(total) as revenue from sales_data
group by city
order by revenue desc
limit 1
 
 
###Question 8:What product line had the largest VAT?
##Answer:the product line with largest VAT is Food and beverages with total VAT of 2673.56$

#here is the code 
select product_line,sum(VAT) as total_VAT from sales_data
group by product_line
order by total_VAT desc
limit 1
 
 
###Question 9:Fetch each product line and add a column to those product line showing 'Good', 'Bad'. Good if its greater than average sales
##Answer:
# product_line, avg_qnty, remark
-- Food and beverages, 5.4713, Bad
-- Health and beauty, 5.5894, Good
-- Sports and travel, 5.5337, Good
-- Fashion accessories, 5.0674, Bad
-- Home and lifestyle, 5.6938, Good
-- Electronic accessories, 5.6864, Good

#the code is
SELECT 
    product_line,
    AVG(quantity) AS avg_qnty,
    CASE
        WHEN
            AVG(quantity) > (SELECT 
                    AVG(quantity) AS avg_standard
                FROM
                    sales_data)
        THEN
            'Good'
        ELSE 'Bad'
    END AS remark
FROM
    sales_data
GROUP BY product_line;



 
###Question 10:Which branch sold more products than average product sold?
##Answer: the answer is branch A and C

-- The process is as follows
-- first I find the average of the the total products sold
#here is the code
select avg(B.products) from
(select branch,sum(quantity) as products
from sales_data
group by branch) as B


-- then I compare that with the total products sold per branch

#the full code is as follows
select A.branch,A.products_sold from
(select branch,sum(quantity) as products_sold 
from sales_data
group by branch) as A
where A.products_sold >= (select avg(B.products) from
(select branch,sum(quantity) as products
from sales_data
group by branch) as B)


###Question  11:What is the most common product line by gender?
##Answer: For males the most common product line is Sports and travel while for Female its Health and beauty

##process: first we separate the 2 genders then we take a look at them one at a time
SELECT 
    product_line, COUNT(product_line) AS Totsales, gender
FROM
    sales_data
WHERE
    gender = 'Male'
GROUP BY product_line
ORDER BY Totsales
LIMIT 1;

#this is the code for Females
SELECT 
    product_line, COUNT(product_line) AS Totsales, gender
FROM
    sales_data
WHERE
    gender = 'Female'
GROUP BY product_line
ORDER BY Totsales
LIMIT 1;


###Question 12:What is the average rating of each product line?
##Answer:the avarage rating of each product line is:
-- Food and beverages 7.11322
-- Fashion accessories 7.02921
-- Health and beauty 6.98344
-- Electronic accessories 6.90651
-- Sports and travel 6.85951
-- Home and lifestyle 6.83750


#here is the code
SELECT 
    product_line, ROUND(AVG(rating), 2) AS avarage_rating
FROM
    sales_data
GROUP BY product_line
ORDER BY avarage_rating DESC;



####----------------------------------------Sales Related:
###Question 1:Number of sales made in each time of the day per weekday
##Answer: the answer is displayed below
# dayname, time_of_day, sales
-- Monday, Morning, 20
-- Monday, Afternoon, 48
-- Monday, Evening, 56
-- Tuesday, Morning, 36
-- Tuesday, Afternoon, 53
-- Tuesday, Evening, 69
-- Wednesday, Morning, 22
-- Wednesday, Afternoon, 61
-- Wednesday, Evening, 58
-- Thursday, Morning, 33
-- Thursday, Afternoon, 49
-- Thursday, Evening, 56
-- Friday, Morning, 29
-- Friday, Afternoon, 58
-- Friday, Evening, 51
-- Saturday, Morning, 28
-- Saturday, Afternoon, 55
-- Saturday, Evening, 81
-- Sunday, Morning, 22
-- Sunday, Afternoon, 52
-- Sunday, Evening, 58

#the code is displayed below
SELECT 
    dayname, time_of_day, COUNT(time_of_day) AS sales
FROM
    sales_data
GROUP BY dayname , time_of_day
ORDER BY dayname ASC , time_of_day DESC

 


###Question 2:Which of the customer types brings the most revenue?
##Answer:the customers who are members bring in more revenue to the business according to our data


#here is the code
SELECT 
    customer_type, ROUND(SUM(total), 2) AS total_revenue
FROM
    sales_data
GROUP BY customer_type
ORDER BY total_revenue DESC




###Question 3:Which city has the largest tax percent/ VAT (Value Added Tax)?
##Answer:the city with the largest VAT is Naypyitaw

#here is the code
SELECT 
    city, ROUND(SUM(VAT), 2) AS total_VAT
FROM
    sales_data
GROUP BY city
ORDER BY total_VAT DESC


###Question 4:Which customer type pays the most in VAT?
##Answer:the customers who are members pay the most taxes

#the code is
SELECT 
    customer_type,
    ROUND(SUM(VAT), 2) AS total_VAT,
    COUNT(*) AS total_customers
FROM
    sales_data
GROUP BY customer_type
ORDER BY total_VAT DESC

####----------------------------------------Customers Related:
###Question 1:How many unique customer types does the data have?
##Answer: There are 2 types: Members and Normal

#the code is
SELECT 
    customer_type
FROM
    sales_data
GROUP BY customer_type



###Question 2:How many unique payment methods does the data have?
##Answer:there are 3 unique payment methods and those are: Credit card, Ewallet and Cash

#the code is
SELECT 
    payment_method
FROM
    sales_data
GROUP BY payment_method

###Question 3:What is the most common customer type?
##Answer:the most common customer type is Member

#the code is
SELECT 
    customer_type, COUNT(*) AS number_of_customers
FROM
    sales_data
GROUP BY customer_type
ORDER BY number_of_customers DESC

###Question 4:Which customer type buys the most?
##Answer: the type of customer who buy the most #of items is Members


#the code is
SELECT 
    customer_type, SUM(quantity) AS total_purchases
FROM
    sales_data
GROUP BY customer_type
ORDER BY total_purchases DESC


###Question 5:What is the gender of most of the customers?
##Answer:the gender of the majority of the customers is MALE

#the code is
SELECT 
    gender, COUNT(*) AS tot
FROM
    sales_data
GROUP BY gender
ORDER BY tot DESC


###Question 6:What is the gender distribution per branch?
##Answer:the table below shows the distribution of the customers gender per branch
# branch, gender, tot
-- A, Male, 179
-- A, Female, 160
-- B, Male, 169
-- B, Female, 160
-- C, Female, 177
-- C, Male, 150


#the code is
SELECT 
    branch, gender, COUNT(gender) AS tot
FROM
    sales_data
GROUP BY branch , gender
ORDER BY branch ASC , tot DESC


###Question 7:Which time of the day do customers give most ratings?
##Answer:the time of day with the most rating is Evening 
SELECT 
    time_of_day, SUM(rating) AS tot_rating
FROM
    sales_data
GROUP BY time_of_day
ORDER BY tot_rating DESC



###Question 8:Which time of the day do customers give most ratings per branch?
##Answer:The times of day with highest rating per branch are: branch A= Evening,branch B= Evening, branch C= Evening

#the code is
SELECT 
    branch, time_of_day, SUM(rating) AS tot_rating
FROM
    sales_data
GROUP BY branch , time_of_day
ORDER BY branch ASC , tot_rating DESC



###Question 9:Which day fo the week has the best avg ratings?
##Answer:the day of the week with the highest avarage rating is Monday


#the code is 
SELECT 
    dayname, AVG(rating) AS average_rating
FROM
    sales_data
GROUP BY dayname
ORDER BY average_rating DESC




###Question 10:Which day of the week has the best average ratings per branch?
##Answer:The day of the week with highest average rating per branch is: branch A= Friday,branch B= Monday, branch C= Saturday

#the code is
SELECT 
    branch, dayname, AVG(rating) AS avg_rating
FROM
    sales_data
GROUP BY branch , dayname
ORDER BY branch ASC , avg_rating DESC
