/*
1a. Display the first and last names of all actors from the table actor.
1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
*/
SELECT actor.first_name, actor.last_name FROM actor;

SELECT CONCAT (first_name, " ", last_name) AS `Actor Name`;

/*
2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?
2b. Find all actors whose last name contain the letters GEN:
2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
*/
SELECT * FROM actor
WHERE first_name = "Joe";

SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

SELECT * FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

/*
3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant).
3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
*/
ALTER TABLE actor
ADD COLUMN description BLOB;

ALTER TABLE actor
DROP COLUMN description;

/*
4a. List the last names of actors, as well as how many actors have that last name.
4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
change it to GROUCHO.
*/
SELECT last_name, count(*) as 'count' FROM actor
GROUP BY last_name;

SELECT last_name, count(*) as 'count' FROM actor
GROUP BY last_name
HAVING count > 2;

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'; #don't need search last name here, but just did it anyways inorder to avoid safe update mode.

/*
5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
*/
SHOW CREATE TABLE actor;
DESCRIBE sakila.address;

/*
6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
6d. How many copies of the film Hunchback Impossible exist in the inventory system?
6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:
*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff LEFT JOIN address ON staff.address_id = address.address_id;

SELECT s.first_name, s.last_name, SUM(p.amount) AS 'Total_Amount'
FROM staff s LEFT JOIN payment p on s.staff_id = p.staff_id;

SELECT f.title, COUNT(i.actor_id) AS 'Total' FROM film f
INNER JOIN film_actor i ON f.film_id = i.film_id
GROUP BY f.title;

SELECT COUNT(i.film_id) AS 'Count', f.title FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total'
FROM customer c LEFT JOIN payment p on c.customer_id = p. customer_id
GROUP BY c.last_name ORDER BY c.last_name;

/*
7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
7b. Use subqueries to display all actors who appear in the film Alone Trip.
7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.
7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.
*/
SELECT title FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id = (SELECT language_id from language WHERE name ='English');

SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id 
					IN (SELECT film_id from film WHERE title ='Alone Trip'));
                    
SELECT first_name, last_name, email FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city ON (a.city_id = city.city_id)
JOIN country ON (city.country_id = country.country_id)
ORDER BY last_name;

SELECT title FROM film f
JOIN film_category fc ON (f.film_id = fc.film_id)
JOIN category c ON ( fc.category_id = c.category_id);

/*
7e. Display the most frequently rented movies in descending order.
7f. Write a query to display how much business, in dollars, each store brought in.
7g. Write a query to display for each store its store ID, city, and country.
7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*/
SELECT title, COUNT(f.film_id) AS 'Most_rented_Movie' FROM film f
JOIN inventory i ON (f.film_id = i.film_id)
JOIN rental r ON (i.inventory_id = r.inventory_id)
GROUP BY title
ORDER BY Most_rented_Movie DESC;

SELECT s.store_id, SUM(p.amount) AS 'Total' FROM payment p
JOIN staff s ON (p.staff_id = s.staff_id)
GROUP BY store_id;

SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id = a.address_id)
JOIN city c ON (a.city_id = c.city_id)
JOIN country ON (c.country_id = country.country_id);

SELECT c.name AS 'Top_Five', SUM(p.amount) AS 'Total' FROM category c
JOIN film_category fc ON (c.category_id = fc.category_id)
JOIN inventory i ON (fc.film_id = i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id =  p.rental_id)
GROUP BY c.name
ORDER BY Total LIMIT 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
8b. How would you display the view that you created in 8a?
8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
*/
CREATE VIEW Top_Five AS
SELECT c.name AS 'Top_Five', SUM(p.amount) AS 'Total' FROM category c
JOIN film_category fc ON (c.category_id = fc.category_id)
JOIN inventory i ON (fc.film_id = i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id =  p.rental_id)
GROUP BY c.name
ORDER BY Total LIMIT 5;

SELECT * FROM Top_Five;

DROP VIEW Top_Five;







