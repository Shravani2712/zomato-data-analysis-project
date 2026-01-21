create database zomato;
USE zomato;
CREATE TABLE zomato_restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    country_code INT,
    city VARCHAR(100),
    address VARCHAR(500),
    locality VARCHAR(255),
    locality_verbose VARCHAR(500),
    longitude DECIMAL(10,7),
    latitude DECIMAL(10,7),
    cuisines VARCHAR(255),
    currency VARCHAR(50),
    has_table_booking ENUM('Yes','No'),
    has_online_delivery ENUM('Yes','No'),
    is_delivering_now ENUM('Yes','No'),
    switch_to_order_menu ENUM('Yes','No'),
    price_range INT,
    votes INT,
    average_cost_for_two INT,
    rating FLOAT(2,1),
    year_opening INT,
    month_opening INT,
    day_opening INT,
    date DATE,
    datekey_opening BIGINT
);
select * from zomato_restaurants limit 5;
-- Find the Numbers of Resturants based on City and Country.
SELECT city, country_code, COUNT(*) AS total_restaurants FROM zomato_restaurants GROUP BY city, country_code ORDER BY total_restaurants DESC;
-- Numbers of Resturants opening based on Year
SELECT year_opening, COUNT(*) AS total_restaurants FROM zomato_restaurants WHERE year_opening IS NOT NULL GROUP BY year_opening ORDER BY year_opening;
--  Numbers of Resturants opening based on Month
SELECT month_opening, COUNT(*) AS total_restaurants FROM zomato_restaurants WHERE month_opening IS NOT NULL GROUP BY month_opening ORDER BY month_opening;
--  Numbers of Resturants opening based on Quarter
SELECT 
CASE
WHEN month_opening IN (1, 2, 3) THEN 'Q1'
WHEN month_opening IN (4, 5, 6) THEN 'Q2'
WHEN month_opening IN (7, 8, 9) THEN 'Q3'
WHEN month_opening IN (10, 11, 12) THEN 'Q4'
END AS quarter, COUNT(*) AS total_restaurants FROM zomato_restaurants WHERE month_opening IS NOT NULL GROUP BY quarter ORDER BY quarter;
--  Percentage of Resturants based on "Has_Table_booking"
SELECT has_table_booking, COUNT(*) AS total_restaurants, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_restaurants),2) AS percentage FROM zomato_restaurants GROUP BY has_table_booking;
--  Percentage of Resturants based on "Has_Online_delivery"
SELECT has_online_delivery, COUNT(*) AS total_restaurants, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_restaurants),2) AS percentage FROM zomato_restaurants GROUP BY has_online_delivery;
--  Count of Resturants based on Average Ratings
SELECT rating, COUNT(*) AS total_restaurants FROM zomato_restaurants GROUP BY rating ORDER BY rating;
--  Find Total  Cusines, City, Ratings
SELECT COUNT(DISTINCT cuisines) AS total_cuisines, COUNT(DISTINCT city) AS total_cities, COUNT(rating) AS total_ratings FROM zomato_restaurants WHERE rating IS NOT NULL AND rating <> 'Not rated';
-- Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT
CASE
WHEN average_cost_for_two BETWEEN 0 AND 500 THEN 'Budget (0-500)'
WHEN average_cost_for_two BETWEEN 501 AND 1000 THEN 'Affordable (501-1000)'
WHEN average_cost_for_two BETWEEN 1001 AND 2000 THEN 'Mid-Range (1001-2000)'
WHEN average_cost_for_two BETWEEN 2001 AND 5000 THEN 'Premium (2001-5000)'
ELSE 'Luxury (Above 5000)'
END AS price_bucket, COUNT(*) AS restaurant_count FROM zomato_restaurants WHERE average_cost_for_two IS NOT NULL GROUP BY price_bucket ORDER BY restaurant_count DESC;
-- Top Cities by Number of Restaurants
SELECT city, COUNT(*) AS total_restaurants FROM zomato_restaurants GROUP BY city ORDER BY total_restaurants DESC LIMIT 10;
-- Top Cuisines by Popularity
SELECT cuisines, COUNT(*) AS restaurant_count FROM zomato_restaurants GROUP BY cuisines ORDER BY restaurant_count DESC LIMIT 10;
-- Average Rating by City 
SELECT city, ROUND(AVG(rating), 2) AS avg_rating FROM zomato_restaurants WHERE rating IS NOT NULL GROUP BY city ORDER BY avg_rating DESC;
-- Rating Distribution (Bucketed)
SELECT
CASE
WHEN rating BETWEEN 0 AND 2 THEN 'Poor (0-2)'
WHEN rating BETWEEN 2.1 AND 3 THEN 'Average (2-3)'
WHEN rating BETWEEN 3.1 AND 4 THEN 'Good (3-4)'
ELSE 'Excellent (4-5)'
END AS rating_bucket, COUNT(*) AS restaurant_count FROM zomato_restaurants WHERE rating IS NOT NULL GROUP BY rating_bucket;
-- Online Delivery Impact on Ratings
SELECT has_online_delivery, COUNT(*) AS total_restaurants, ROUND(AVG(rating),2) AS avg_rating FROM zomato_restaurants GROUP BY has_online_delivery;
-- Table Booking vs No Table Booking
SELECT has_table_booking, COUNT(*) AS restaurant_count, ROUND(AVG(average_cost_for_two),0) AS avg_price FROM zomato_restaurants GROUP BY has_table_booking;
-- Year-on-Year Restaurant Growth
SELECT year_opening, COUNT(*) AS restaurants_opened FROM zomato_restaurants GROUP BY year_opening ORDER BY year_opening;
-- Most Expensive Restaurants
SELECT restaurant_name, city, average_cost_for_two FROM zomato_restaurants ORDER BY average_cost_for_two DESC LIMIT 10;
-- City-wise Price Buckets
SELECT city,
CASE
WHEN average_cost_for_two <= 500 THEN 'Budget'
WHEN average_cost_for_two <= 1000 THEN 'Affordable'
WHEN average_cost_for_two <= 2000 THEN 'Mid-Range'
ELSE 'Premium'
END AS price_bucket, COUNT(*) AS restaurant_count FROM zomato_restaurants WHERE average_cost_for_two IS NOT NULL 
GROUP BY city, price_bucket ORDER BY city, restaurant_count DESC;
-- Restaurants with Highest Votes (Popularity)
SELECT restaurant_name, city, votes FROM zomato_restaurants ORDER BY votes DESC LIMIT 10;
-- Average Cost vs Rating Relationship
SELECT ROUND(average_cost_for_two, -2) AS cost_range, ROUND(AVG(rating),2) AS avg_rating FROM zomato_restaurants WHERE rating IS NOT NULL GROUP BY cost_range ORDER BY cost_range;
-- Cities with Best Rated Restaurants (Min 50 Restaurants)
SELECT city, COUNT(*) AS total_restaurants, ROUND(AVG(rating),2) AS avg_rating FROM zomato_restaurants GROUP BY city HAVING COUNT(*) >= 50 ORDER BY avg_rating DESC;
-- Duplicate Restaurant Names (Data Quality Check)
SELECT restaurant_name, COUNT(*) AS occurrences FROM zomato_restaurants GROUP BY restaurant_name HAVING COUNT(*) > 1;
-- Missing Data Audit
SELECT SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating, SUM(CASE WHEN average_cost_for_two IS NULL THEN 1 ELSE 0 END) AS missing_price FROM zomato_restaurants;
-- Create a VIEW for Reuse
CREATE VIEW city_performance AS 
SELECT city, COUNT(*) AS total_restaurants, ROUND(AVG(rating),2) AS avg_rating, ROUND(AVG(average_cost_for_two),0) AS avg_price FROM zomato_restaurants GROUP BY city;
SELECT * FROM zomato.city_performance;