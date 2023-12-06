Create Database Music_Store;
Use Music_Store;
Show Tables;

CREATE TABLE Employee (
    Employee_id INT PRIMARY KEY,
    First_name VARCHAR(100) Not Null,
    Last_name VARCHAR(100) Not Null,
    Title VARCHAR(100) Not Null,
    Levels Varchar(100) Not Null,    
    Reports_to Int Not Null,
    Birthdate DATE Not Null,
    Hire_date DATE Not Null,
    Address VARCHAR(100) Not Null,
    City VARCHAR(100) Not Null,
    State VARCHAR(100) Not Null,
    Country VARCHAR(100) Not Null,
    Postal_code VARCHAR(100) Not Null,
    Phone VARCHAR(100) Not Null,
    Fax VARCHAR(100) Not Null,
    Email VARCHAR(100) Not Null,
    Foreign key (Reports_to) references Employee(Employee_id)
);

CREATE TABLE Customer (
    Customer_id INT primary key,
    First_name VARCHAR(100) Not Null,
    Last_name VARCHAR(100) Not Null,
    Company VARCHAR(100) Not Null,
    Address VARCHAR(100) Not Null,
    City VARCHAR(100) Not Null,
    State VARCHAR(100) Not Null,
    Country VARCHAR(100) Not Null,
    Postal_code VARCHAR(100) Not Null,
    Phone VARCHAR(100) Not Null,
    Fax VARCHAR(100) Not Null,
    Email VARCHAR(100) Not Null,
    Support_rep_id int Not Null,
    foreign key (Support_rep_id) references Employee(Employee_id)
    on update cascade 
    on delete cascade
);

CREATE TABLE Invoice (
    Invoice_id INT Primary key,
    Customer_id int Not Null ,
    Invoice_date DATE Not Null,
    Billing_address VARCHAR(100) Not Null,
    Billing_city VARCHAR(100) Not Null,
    Billing_state VARCHAR(100) Not Null,
    Billing_country VARCHAR(100) Not Null,
    Billing_postal_code VARCHAR(100) Not Null,
    Total INT Not Null,
    Foreign key (Customer_id) references Customer(Customer_id)
    On Update Cascade
    On Delete Cascade
    
);


CREATE TABLE Invoice_line (
    Invoice_line_id INT primary key,
    Invoice_id INT Not Null,
    track_id INT,
    unit_price VARCHAR(100) Not Null,
    quantity VARCHAR(100) Not Null,
    Foreign key (Invoice_id) references Invoice(Invoice_id)
    On Update Cascade
    On Delete Cascade
);

CREATE TABLE Track (
    Track_id INT primary key,
    Name VARCHAR(100) Not Null,
    Album_id INT Not Null,
    Media_type_id INT Not Null,
    Genre_id int Not Null,
    Composer VARCHAR(100) Not Null,
    Milliseconds int Not Null,
    Bytes VARCHAR(100) Not Null,
    Unit_price INT Not Null,
    foreign key (Media_type_id) references Media_type(Media_type_id),
    foreign key (Genre_id) references Genre (Genre_id),
    foreign key(Album_id) references Album (Album_id)
);

CREATE TABLE Playlist_track (
    Playlist_id INT Not Null,
    Track_id INT,primary key(Playlist_id,Track_id),
    foreign key (Playlist_id) references Playlist(Playlist_id)
    On Update Cascade
    On Delete Cascade,
    Foreign key (Track_id) references Track(Track_id)
    On Update Cascade
    On Delete Cascade
);
CREATE TABLE Album (
    Album_id INT primary key,
    Title VARCHAR(100) Not Null,
    Artist_id INT Not Null,
    Foreign key (Artist_id) references Artist(Artist_id)
    On Update Cascade
    On Delete Cascade
);

CREATE TABLE Playlist (
    Playlist_id INT primary key,
    Name VARCHAR(100) Not Null
);
CREATE TABLE Artist (
    Artist_id INT primary key,
    Name VARCHAR(100) Not Null
);

CREATE TABLE Media_type (
    Media_type_id INT primary key,
    Name VARCHAR(100) Not Null 
);
CREATE TABLE Genre (
    Genre_id INT primary key,
    Name VARCHAR(100) Not Null 
);


/* Q1: Who is the senior most employee based on job title? **

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/** Q2: Which countries have the most Invoices? **

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? **

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals **

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.**

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;




/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. **

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. **

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. **

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;




/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent **

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. **

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;






