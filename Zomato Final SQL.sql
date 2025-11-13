create database zomato;
select * from maindata;
-- Find the Numbers of Resturants based on City and Country.
select city, count(restaurantid) from maindata
group by city;
select countryname, count(countrycode) from maindata
group by Countryname;
-- Numbers of Resturants opening based on Year
select 
distinct(yearOpening) as year, count(YearDate)
from maindata
group by (yearopening);
--  Numbers of Resturants opening based on Month
select 
distinct MonthName, count(MonthOpening)
from maindata
group by MonthName;
--  Numbers of Resturants opening based on Quarter
select 
distinct Quarter, count(RestaurantID)
from maindata
where Quarter is not null
group by Quarter
order by Quarter;
--  Percentage of Resturants based on "Has_Table_booking"
select 
Has_Table_booking,
count(*) as TotalRestaurants,
round((count(*) / (select count(*) from maindata)) * 100, 2) as percentage
from maindata
group by Has_Table_booking;
--  Percentage of Resturants based on "Has_Online_delivery"
select 
Has_Online_delivery,
count(*) as TotalRestaurants,
round((count(*) / (select count(*) from maindata)) * 100, 2) as percentage
from maindata
group by Has_Online_delivery;
--  Count of Resturants based on Average Ratings
select
rating as IndividualRating,
count(*) as Restaurantcount
from maindata
where Rating is not null
group by Rating
order by Rating asc;
--  Find Total  Cusines, City, Ratings
select cuisines, count(cuisines) from maindata
 group by cuisines;
 select city, count(Cuisines) from maindata
 group by City;
 select Rating, count(Cuisines) from maindata
 group by Rating;
-- Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
select
Cost_Range, count(*) as TotalRestaurants
from (select
case
when Average_Cost_for_two between 0 and 300 then '0-300'
when Average_Cost_for_two between 301 and 600 then '301-600'
when Average_Cost_for_two between 601 and 1000 then '601-1000'
when Average_Cost_for_two between 1001 and 430000 then '1001-430000'
else 'other'
end as Cost_Range
from maindata)
as subquery
group by Cost_Range;