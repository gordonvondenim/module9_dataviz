use sakila;
select * from sakila.actor;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat_ws(' ', upper( first_name), upper( last_name)) as Actor_Name from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like '%gen';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor where last_name like '%LI%';
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor drop column description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) from actor group by last_name having count(last_name) > 1;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor set first_name = 'Harpo' where first_name = 'Groucho';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor set first_name = 'Groucho' where first_name = 'Harpo';
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address
from staff
join address using (address_id);
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, staff_id, SUM(amount) AS total_amount
FROM staff
JOIN payment USING (staff_id)
WHERE payment_date LIKE "2005-05%"
GROUP BY staff_id;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select film_id, title, count(actor_id) as number_actors
from film
inner join film_actor using (film_id) group by film_id;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id) as inventory_count
from inventory
join film using (film_id) where title = "Hunchback Impossible";
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
select customer.first_name, customer.last_name, sum(payment.amount) as 'total amount paid' 
from payment
join customer using (customer_id) group by customer.last_name order by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select film.title, language.name from film, language
where language.name = 'English' and (film.title like 'Q%' or film.title like 'K%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name, actor_id
from actor
where actor_id in
(
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN
 (
	SELECT film_id
	FROM film
	WHERE title = "Alone Trip"
  )
  );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email, country
from customer
JOIN address USING (address_id) JOIN city USING (city_id) JOIN country USING (country_id)
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title, name
from film
join film_category using (film_id) join category using (category_id)
where name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT film_id, title, COUNT(rental_date) AS number_of_rentals
FROM rental
JOIN inventory USING (inventory_id) JOIN film USING (film_id)
GROUP BY film_id ORDER BY number_of_rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount)
FROM store
JOIN customer USING (store_id) JOIN payment USING (customer_id) GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
JOIN address USING (address_id) JOIN city USING (city_id) JOIN country USING (country_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) as revenue
FROM category 
JOIN film_category USING (category_id) JOIN inventory USING (film_id) JOIN rental USING (inventory_id) JOIN payment USING (rental_id)
GROUP BY name ORDER BY revenue DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres AS
SELECT name, SUM(amount) as revenue
FROM category 
JOIN film_category USING (category_id) JOIN inventory USING (film_id) JOIN rental USING (inventory_id) JOIN payment USING (rental_id)
GROUP BY name ORDER BY revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genres;