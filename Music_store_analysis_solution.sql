/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */ 

select title,last_name,first_name,levels from employee
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */

select billing_country,count(*) as Invoice_Count
from invoice
group by billing_country
order by Invoice_Count desc


/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by total desc
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as Invoice_total
from invoice
group by billing_city
order by Invoice_total desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, first_name,last_name, sum(invoice.total) as Total
from customer JOIN invoice 
on invoice.customer_id=customer.customer_id
group by customer.customer_id
order by Total desc
limit 1;


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email, first_name, last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by email;

/* metho 2*/
select distinct email, first_name, last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id IN (
	select track_id 
	from track 
	join genre on track.genre_ID = genre.genre_ID
	where genre.name like 'Rock')
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


select artist.name, artist.artist_id, count(*) as track_count
from artist 
join album on artist.artist_id = album.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by track_count desc
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


select track_id,track.name 
from track
where milliseconds >( select avg(milliseconds) avg_track_length from track )
order by milliseconds desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

select customer.customer_id, customer.first_name || ' ' || customer.last_name AS customer_name ,
 artist.name as artist_name, sum(invoice_line.unit_Price*invoice_line.quantity) 
from customer 
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by customer.customer_id, artist.name
order by customer.customer_id

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(*) AS purchases, invoice.billing_country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with temp_t as(
	select customer.customer_id, customer.country, sum(invoice.total) as spent,
	row_number() over(partition by customer.country order by sum(invoice.total) desc)
	from customer
	join invoice on customer.customer_id= invoice.customer_id
	group by 1,2
	order by country
)
select * from temp_t
where row_number <=1 
order by country 




