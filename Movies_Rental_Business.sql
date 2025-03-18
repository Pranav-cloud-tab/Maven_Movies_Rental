-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE MAVENMOVIES;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT* FROM RENTAL;

SELECT* FROM INVENTORY; 

SELECT* FROM CUSTOMER;

SELECT* FROM film;

SELECT* FROM film_actor;

-- You need to provide customer firstname, lastname and email id to the marketing team --

SELECT first_name,last_name,email
from customer;

-- How many movies are with rental rate of $0.99? --

select count(*) as cheapest_rentals
from film
where rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --

select rental_rate,count(*) as total_numb_of_movies
from film
group by rental_rate;

-- Which rating has the most films? --
select rating,count(*) as rating_category_count
from film
group by rating
order by rating_category_count desc;

-- Which rating is most prevalant in each store? --
select inv.store_id,f.rating,count(*) as total_films
from inventory as inv left join film as f
on inv.film_id = f.film_id
group by inv.store_id,f.rating
order by inv.store_id,total_films desc;


-- List of films by Film Name, Category, Language --
select f.title,l.name as l_n,c.name as c_n
from film as f left join language as l
on f.language_id=l.language_id
left join film_category as fc
on f.film_id=fc.film_id
left join category as c
on fc.category_id=c.category_id;



-- How many times each movie has been rented out?
select f.title,count(r.rental_id) as total_count
from film as f left join inventory as i 
on f.film_id=i.film_id
left join rental as r
on r.inventory_id=i.inventory_id
group by f.title
order by total_count desc;


-- REVENUE PER FILM (TOP 10 GROSSERS)
select f.title,sum(p.amount) as T_C
from payment as p join rental as r
on p.rental_id=r.rental_id
left join inventory as i
on r.inventory_id=i.inventory_id
left join film as f
on i.film_id=f.film_id
group by f.title
order by T_C desc;


-- Most Spending Customer so that we can send him/her rewards or debate points
select c.customer_id,sum(p.amount) as T_A, c.first_name
from customer as c left join payment as p
on c.customer_id=p.customer_id
group by c.customer_id
order by T_A desc
limit 1;


-- Which Store has historically brought the most revenue?
select s.store_id,sum(p.amount) as t_r
from payment as p left join staff as s
on p.staff_id=s.staff_id
group by s.store_id;


-- How many rentals we have for each month
select extract(year from rental_date) as Y,extract(month from rental_date) as M, count(rental_id) as N_O_R
from rental
group by extract(year from rental_date),extract(month from rental_date);


-- Reward users who have rented at least 30 times (with details of customers)
SELECT c.first_name, c.last_name, c.customer_id,c.email,COUNT(r.rental_id) AS N_O_T
FROM rental AS r
LEFT JOIN customer AS c ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name,c.email
HAVING COUNT(r.rental_id) > 30;


-- Could you pull all payments from our first 100 customers (based on customer ID)

select*
from payment
where customer_id between 1 and 100;


-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

select*
from payment
where (customer_id between 1 and 100) and amount > 5 and payment_date > '2006-01-01';

-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?

select*
from payment
where amount > 5 and customer_id in ( select customer_id from payment
	where (customer_id between 1 and 100) and amount > 5 and payment_date > '2006-01-01');
    
    
-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

select title,special_features
from film    
where special_features like 'Behind the Scenes';

-- unique movie ratings and number of movies G, PG, PG-13, R, NC-17

select rating,count(film_id)
from film
group by rating


-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(title) as title_count
from film
group by rental_duration



-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION
SELECT RATING,
	COUNT(FILM_ID)  AS COUNT_OF_FILMS,
    MIN(LENGTH) AS SHORTEST_FILM,
    MAX(LENGTH) AS LONGEST_FILM,
    AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
    AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;
    


-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?


SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;


-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”


select customer_id,count(*) as total_rentals
from rental
group by customer_id
having total_rentals  < 15;


-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

select title,length,rental_rate
from film
order by length desc;


-- CATEGORIZE MOVIES AS PER LENGTH

SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

SELECT *
FROM CATEGORY;


-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;



-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”


SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;    


-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select f.title,f.description,i.store_id,i.inventory_id,f.film_id
from film as f inner join inventory as i
on f.film_id=i.film_id;

-- Actor first_name, last_name and number of movies

select a.actor_id,a.first_name, a.last_name,count(f.film_id) as N_O_F
from film_actor as fa left join film as f
on fa.film_id=f.film_id
left join actor as a
on a.actor_id=fa.actor_id
group by a.actor_id
order by N_O_F desc;


-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

select f.title,count(fa.actor_id) as N_O_A
from film as f left join film_actor as fa
on f.film_id=fa.film_id
group by f.title
order by N_O_A desc;



-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

(select first_name,last_name,"staff" as designation
from staff
union 
select first_name,last_name,"advisor" as designation
from advisor);













