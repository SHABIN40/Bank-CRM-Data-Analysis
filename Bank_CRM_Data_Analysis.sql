-- Q2 Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year

select * from customerInfo;
select Surname,EstimatedSalary from customerInfo
where Date(`Bank DOJ`) between '2019-08-01' and '2019-12-31'
order by EstimatedSalary DESC limit 5;


-- select Surname,EstimatedSalary, QUARTER(`Bank DOJ`)as quarter from customerInfo
-- where QUARTER(`Bank DOJ`) = 4 
-- order by EstimatedSalary DESC limit 5;



-- Q3Calculate the average number of products used by customers who have a credit card. (SQL)

select AVG(NumOfProducts) average_number_of_products from `bank_churn`
where HasCreditCard = 1;


-- Q4 Determine the churn rate by gender for the most recent year in the dataset.

SELECT g.GenderCategory,Count(b.CustomerId) as number_of_people_churned from bank_churn b
join
customerinfo c on b.CustomerId = c.CustomerId
join
gender g on c.GenderID = g.GenderID
where  b.Exited = 1 and YEAR(c.`Bank DOJ`)= '2019'
group by g.GenderCategory;


-- Q5 Compare the average credit score of customers who have exited and those who remain. (SQL)


select e.Exitcategory, AVG(b.CreditScore) as avg_credit_score_of_customers from bank_churn b
join exitcustomer e
on b.Exited = e.Exited
group by Exitcategory;


-- Q6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
  
  select g.GenderCategory,avg(c.EstimatedSalary),
  Count(c.CustomerId)as num_of_active_accounts 
  from customerInfo c
  join bank_churn b on c.CustomerId = b.CustomerId
  join Gender g on c.GenderID = g.GenderID
  where b.IsActiveMember = 1
  group by g.GenderCategory;
  

-- Q7 Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

select
case
	when CreditScore between 800 and 850 then 'Excellent'
    when CreditScore between 740 and 799 then 'Very Good'
    when CreditScore between 670 and 739 then 'Good'
    when CreditScore between 580 and 669 then 'Fair'
    else  'Poor'
end as credit_group,
Count(*)as Exit_rate from bank_churn
where Exited = 1
group by credit_group
order by Exit_rate Desc;



-- Q8 Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL) 


select c.GeographyID,g.GeographyLocation as location,Count(b.CustomerId)as number_of_active_customers from customerinfo c
join bank_churn b on c.CustomerId = b.CustomerId
join Geography g on c.GeographyID = g.GeographyID
where b.IsActiveMember = 1 and b.Tenure > 5
group by c.GeographyID,g.GeographyLocation
order by number_of_active_customers DESC;

-- Q9.	What is the impact of having a credit card on customer churn, based on the available data?

select c.category,count(b.CustomerId)as number_of_customer_churned from bank_churn b
join creditcard c on b.HasCreditCard = c.HasCreditCard
where Exited = 1
group by c.category;


-- Q10.	For customers who have exited, what is the most common number of products they had used?


select NumOfProducts,Count(NumOfProducts)as count_of_number_of_products from  bank_churn
where Exited = 1
group by NumOfProducts
order by count_of_number_of_products desc;

-- Q11 Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it


select 
YEAR(`Bank DOJ`)as joining_year,MONTHNAME(`Bank DOJ`) as joining_month ,Count(customerId)as number_of_customers_joining from customerInfo
group by joining_year,joining_month
order by joining_year DESC,number_of_customers_joining DESC;


-- Q12 Analyze the relationship between the number of products and the account balance for customers who have exited.-- 

select b.NumOfProducts,ROUND(AVG(b.Balance),2)as Average_Balances from bank_churn b
join
customerInfo c on b.CustomerId = c.CustomerId
where b.Exited = 1
group by b.NumOfProducts
order by Average_Balances  DESC ;


-- 15 Using SQL, write a query to find out the gender wise average income of male and female in each geography id. Also rank the gender according to the average value. (SQL)


select GeographyID,GenderCategory,Average_Income ,DENSE_RANK()OVER(PARTITION BY GeographyID ORDER BY Average_Income DESC )as `rank`
from
(select gy.GeographyID,g.GenderCategory,AVG(c.EstimatedSalary)as Average_Income 
from customerinfo c 
join 
geography gy on c.GeographyID = gy.GeographyID
join
gender g on c.GenderID = g.GenderID
group by gy.GeographyID,g.GenderCategory
order by gy.GeographyID)as cte;


-- 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select 
case
	when c.Age > 50 then '50+'
    when c.Age between 30 and 50 then '30-50'
    else '18-50'
end as Age_bracket,
AVG(b.tenure) as average_tenure from customerinfo c 
join 
bank_churn b on c.CustomerId = b.CustomerId
where b.Exited = 1
group by Age_bracket
order by average_tenure DESC ;

-- Q18. Is there any correlation between salary and Credit score of customers?(visuals)

select c.CustomerId,c.Surname,c.EstimatedSalary,b.CreditScore from customerinfo c
join
bank_churn b on c.CustomerId = b.CustomerId
order by b.CreditScore desc,c.EstimatedSalary desc;



-- 19. Rank each bucket of credit score as per the number of customers who have churned the bank.


select credit_group,number_of_customers_churned,RANK()OVER(ORDER BY number_of_customers_churned DESC)as `rank`
from
(select
case
	when CreditScore between 800 and 850 then 'Excellent'
    when CreditScore between 740 and 799 then 'Very Good'
    when CreditScore between 670 and 739 then 'Good'
    when CreditScore between 580 and 669 then 'Fair'
    else  'Poor'
end as credit_group,
COUNT(CustomerId) as number_of_customers_churned
from bank_churn
where Exited = 1
group by credit_group) as ct



-- 20. According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets who have lesser than average number of credit cards per bucket.


-- number of customer who have creditcard according to age bucket
select 
case
	when c.Age > 50 then '50+'
    when c.Age between 30 and 50 then '30-50'
    else '18-50'
end as Age_bracket,
Count(b.CustomerId)as number_of_customers_having_CrCard from customerinfo c
join
bank_churn b on c.customerId = b.customerId
where b.HasCreditCard = 1
group by Age_bracket;


-- retrieving those buckets who have lesser than the average number of card holders per bucket

with cte as 
(select 
case
	when c.Age > 50 then '50+'
    when c.Age between 30 and 50 then '30-50'
    else '18-50'
end as Age_bracket,
Count(b.CustomerId)as number_of_customers_having_CrCard from customerinfo c
join
bank_churn b on c.customerId = b.customerId
where b.HasCreditCard = 1
group by Age_bracket)
 select cte.Age_bracket,cte.number_of_customers_having_CrCard from cte
 where cte.number_of_customers_having_CrCard < (select AVG(number_of_customers_having_CrCard) from cte);


-- 21. Rank the Locations as per the number of people who have churned the bank and average balance of the learners.



select GeographyLocation,number_of_people_churned,average_balance,RANK()OVER(order by number_of_people_churned DESC,average_balance DESC)as `rank`
from
(select g.GeographyLocation,
count(c.CustomerId) as number_of_people_churned,
AVG(b.Balance)as average_balance 
from bank_churn b
join 
customerinfo c on b.CustomerId = c.CustomerId
join
geography g on c.GeographyID = g.GeographyID
where Exited = 1
group by g.GeographyLocation)as cte;


-- 22. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

select CONCAT(CustomerId,'_',Surname)AS CustomerId_Surname from customerinfo;


-- 23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

select b.*,(Select ExitCategory from exitcustomer where Exited = b.Exited)as ExitCategory from bank_churn b

-- 25. Write the query to get the customer ids, their last name and whether they are active or not for the customers whose surname  ends with “on”.

Select b.CustomerId,c.Surname,a.ActiveCategory from customerinfo c
join 
bank_churn b on c.CustomerId = b.CustomerId
join
activecustomer a on b.IsActiveMember = a.IsActiveMember
where c.Surname like '%on'
order by b.CustomerId;





-- subjective questions

-- Q8 (part 2) analyze the relation between number of products and number of churned customer

select NumOfProducts,COUNT(CustomerId)as number_of_churned_customers from bank_churn 
where Exited = 1
group by NumOfProducts
order by  NumOfProducts DESC ;


-- Q9.Utilize SQL queries to segment customers based on demographics and account details. 


select 
case
	when c.Age > 50 then '50+'
    when c.Age between 30 and 50 then '30-50'
    else '18-50'
end as Age_bracket,
round(AVG(b.Balance),2) as average_Balance,
round(AVG(c.EstimatedSalary),2) as average_salary
from customerinfo c 
join 
bank_churn b on c.CustomerId = b.CustomerId
where b.Exited = 1
group by Age_bracket
order by Age_bracket  ;



