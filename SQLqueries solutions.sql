-- Solve the below SQL problems using the Famous Paintings & Museum dataset:

--To check all the tables one by one at a glance 

SELECT * FROM artist

SELECT * FROM canvas_size

SELECT * FROM image_link

SELECT * FROM museum

SELECT * FROM museum_hours

SELECT * FROM product_size

SELECT * FROM subject

SELECT * FROM work



--1) Fetch all the paintings which are not displayed on any museums?

SELECT * 
FROM work
WHERE museum_id IS null

--2) Are there museuems without any paintings?

--solution 1
SELECT *
FROM museum m
WHERE museum_id NOT IN (SELECT museum_id 
						FROM work w 
						WHERE m.museum_id = w.museum_id)

--solution 2
SELECT *
FROM museum m
WHERE NOT EXISTS (SELECT museum_id 
						FROM work w 
						WHERE m.museum_id = w.museum_id)

--3) How many paintings have an asking price of more than their regular price? 

--solution 1
SELECT COUNT(*) AS No_of_paintaings
FROM product_size
WHERE sale_price > regular_price

--solution 2
SELECT COUNT(*) AS No_of_paintaings
FROM product_size
WHERE (sale_price - regular_price) > '0'

--4) Identify the paintings whose asking price is less than 50% of its regular price.

SELECT * 
FROM product_size
WHERE sale_price < regular_price / 2


--5) Which canva size costs the most?

SELECT c.label AS Canva, p.sale_price
FROM product_size AS p
JOIN canvas_size AS c
ON p.size_id = c.size_id::text
ORDER BY p.sale_price DESC
LIMIT 1

--6) Delete duplicate records from work, product_size, subject and image_link tables.

--Deleting duplicate records from work
DELETE FROM work
WHERE CTID NOT IN
				(SELECT MIN(CTID)
				FROM work
				GROUP BY work_id, name, artist_id, style, museum_id)

--Deleting duplicate records from product_size
DELETE FROM product_size
WHERE CTID NOT IN
				(SELECT MIN(CTID)
				FROM product_size
				GROUP BY work_id, size_id, sale_price, regular_price)

--Deleting duplicate records from subject
DELETE FROM subject
WHERE CTID NOT IN
				(SELECT MIN(CTID)
				FROM subject
				GROUP BY work_id, subject)
				
--Deleting duplicate records from image_link
DELETE FROM image_link
WHERE CTID NOT IN
				(SELECT MIN(CTID)
				FROM image_link
				GROUP BY work_id, url)

--7) Identify the museums with invalid city information in the given dataset.
SELECT *
FROM museum
WHERE city ~'[0-9]'

/* Explanation from ChatGPT
In PostgreSQL, the tilde (~) is used as a match operator for regular expressions in queries. Let's break down the two regular expressions you provided:

1. `~'^[0-9]'`: This regular expression matches strings that start with a digit (0-9). The caret (^) is an anchor that asserts the start of the string, and `[0-9]` specifies a character class that includes any digit from 0 to 9.

2. `~'[0-9]'`: This regular expression matches any string that contains at least one digit (0-9). It doesn't specify the position of the digit within the string.

Here's a brief summary:

- `~'^[0-9]'`: Matches strings that start with a digit.
- `~'[0-9]'`: Matches strings that contain at least one digit.

In summary, the difference lies in the positioning of the digit within the string. The first one specifies that the digit must be at the beginning of the string, while the second one only requires the presence of a digit anywhere in the string.
*/

--8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

--Identifying invalid entry.
SELECT *
FROM museum_hours
WHERE CTID NOT IN
				(SELECT MIN(CTID) 
				FROM museum_hours
				GROUP BY museum_id, day, open, close)

--Removing the invalid entry

--Solution 1 (Using CTID)
DELETE FROM museum_hours
WHERE CTID NOT IN
				(SELECT MIN(CTID) 
				FROM museum_hours
				GROUP BY museum_id, day, open, close)


--Solution 2 (Using multi steps)

--Step 1: Creating a new table as like as existing table with additional column of rank number
CREATE TABLE museum_hours2 AS(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY museum_id, day, open, close) rnk
	FROM museum_hours)

--to check newly created table
SELECT * FROM museum_hours2

--Step 2: Deleting duplicate entries while keeping 1 entry from each duplicate entry set
DELETE FROM museum_hours2
WHERE rnk > 1

--to check newly created table after deletion of duplicate entry
SELECT * FROM museum_hours2

--Step3: Deleting additionally created rnk column from newly created table
ALTER TABLE museum_hours2 DROP COLUMN rnk

--Step 4: Drop original table
DROP TABLE museum_hours

--Step 5: Renaming newly created table as original table
ALTER TABLE museum_hours2 RENAME TO museum_hours

--to finally check table from where duplicate records have been remobed while keeping 1 entry from each duplicate entry set
SELECT * FROM museum_hours


--9) Fetch the top 10 most famous painting subject.

--Soultion 1
WITH temp AS(SELECT s.*, w.*
FROM subject s
RIGHT JOIN work w
ON s.work_id = w.work_id
ORDER BY s.subject)
SELECT subject, COUNT(subject) no_of_paints
FROM temp
GROUP BY subject
ORDER BY COUNT(subject) DESC
LIMIT 10

--Solution 2 (but problem in result of 'Abstract/ Modern Art'. Have to explore further)
SELECT subject, COUNT(subject) AS numbers
FROM subject
GROUP BY subject
ORDER BY COUNT(subject) DESC
LIMIT 10

--Solution 3
select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;

--10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT mh1.museum_id, m.name, m.city, m.country
FROM museum_hours mh1
JOIN museum m
ON mh1.museum_id = m.museum_id
WHERE day = 'Sunday' 
AND EXISTS (
			SELECT 1
			FROM museum_hours mh2
			WHERE mh1.museum_id = mh2.museum_id
			AND day = 'Monday'
			)


--11) How many museums are open every single day?
SELECT COUNT(museum_id) no_of_museums
FROM (
	SELECT museum_id, COUNT(museum_id)
	FROM museum_hours
	GROUP BY museum_id
	HAVING COUNT(museum_id) = 7
	) Sub
	
--12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

WITH temp AS(SELECT m.name, m.city, m.country, w.museum_id
FROM work w
JOIN museum m
ON w.museum_id = m.museum_id)
SELECT name, museum_id, city, country, COUNT(museum_id) AS no_of_paintaings
FROM temp
GROUP BY name, city, country, museum_id
ORDER BY COUNT(museum_id) DESC
LIMIT 5

--13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT full_name AS artist_name, no_of_paintaings, rank
FROM(
	SELECT a.full_name, COUNT(1) no_of_paintaings, RANK() OVER(ORDER BY COUNT(1) DESC)
	FROM artist a
	JOIN work w
	ON a.artist_id = w.artist_id
	GROUP BY a.full_name
	) sub
WHERE rank <= 5

--14) Display the 3 least popular canva sizes

SELECT label, no_of_paintaings, ranking
FROM(
	SELECT c.label, COUNT(1) AS no_of_paintaings, DENSE_RANK() OVER(ORDER BY COUNT(1)) AS ranking
	FROM canvas_size c
	JOIN product_size p ON c.size_id::text = p.size_id
	JOIN work w ON w.work_id = p.work_id
	GROUP BY c.label
	) sub
WHERE ranking <=3

--15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

SELECT m.name, m.state, mh.day, mh.open, mh.close, mh.duration
FROM(
	SELECT *, TO_TIMESTAMP(close, 'HH:MI AM') - TO_TIMESTAMP(open,'HH:MI PM') AS duration
	FROM museum_hours
	ORDER BY TO_TIMESTAMP(close, 'HH:MI AM') - TO_TIMESTAMP(open,'HH:MI PM') DESC
	LIMIT 1) mh
JOIN museum m
ON m.museum_id = mh.museum_id

select museum_name,state as city,day, open, close, duration
	from (	select m.name as museum_name, m.state, day, open, close
			, to_timestamp(open,'HH:MI AM') 
			, to_timestamp(close,'HH:MI PM') 
			, to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration
			, rank() over (order by (to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM')) desc) as rnk
			from museum_hours mh
		 	join museum m on m.museum_id=mh.museum_id) x
	where x.rnk=1;

--16) Which museum has the most no of most popular painting style?
--Solution 1
SELECT m.name AS museum_name, temp.style, COUNT(temp.museum_id) AS no_of_paintaings
	FROM
		(SELECT * FROM work WHERE style =
			(SELECT style
			FROM work
			GROUP BY 1
			ORDER BY COUNT(1) DESC
			LIMIT 1)
		 ) temp
JOIN museum m ON temp.museum_id = m.museum_id
WHERE temp.museum_id IS NOT null
GROUP BY m.name, temp.style
ORDER BY COUNT(temp.museum_id) DESC
LIMIT 1
	
--Solution 2
with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1;

--17) Identify the artists whose paintings are displayed in multiple countries

WITH cte AS
		(SELECT a.full_name, w.work_id, w.name, m.country
		FROM work w
		JOIN artist a ON w.artist_id = a.artist_id
		JOIN museum m ON w.museum_id = m.museum_id)
SELECT full_name AS name_of_artist, COUNT(DISTINCT country) AS no_of_countries
FROM cte
GROUP BY full_name
HAVING COUNT(DISTINCT country) > 1
ORDER BY 2 DESC, 1


--18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

WITH CTE_COUNTRY AS
		(SELECT country, COUNT(1), RANK() OVER(ORDER BY COUNT(1) DESC)
		FROM museum
		GROUP BY country),
	 CTE_CITY AS
	 	(SELECT city, COUNT(1), RANK() OVER(ORDER BY COUNT(1) DESC)
		FROM museum
		GROUP BY city)
SELECT STRING_AGG(DISTINCT country, ', ') AS country, STRING_AGG(city, ', ') AS city
FROM CTE_COUNTRY
CROSS JOIN CTE_CITY
WHERE CTE_COUNTRY.rank=1
AND CTE_CITY.rank = 1

--19) Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label

SELECT a.full_name AS artist_name, sub.sale_price, w.name AS paintaing_name, m.name AS museum_name, m.city AS museum_city , c.label AS canvas_label
FROM 
	(SELECT * , RANK() OVER(ORDER BY sale_price) AS cheap, RANK() OVER(ORDER BY sale_price DESC) AS expensive
	FROM product_size) AS sub
JOIN work w ON w.work_id = sub.work_id
JOIN artist a ON a.artist_id = w.artist_id
JOIN museum m ON m.museum_id = w.museum_id
JOIN canvas_size c ON c.size_id = sub.size_id::NUMERIC
WHERE sub.cheap = 1 OR sub.expensive= 1

--20) Which country has the 5th highest no of paintings?

SELECT country, no_of_paintaings
FROM (
		SELECT m.country, COUNT(1) no_of_paintaings, RANK() OVER(ORDER BY COUNT(1) DESC)
		FROM work w
		JOIN museum m
		ON w.museum_id = m.museum_id
		GROUP BY m.country
		) temp
WHERE rank = 5

--21) Which are the 3 most popular and 3 least popular painting styles?

---Solution 1
SELECT style, CASE 
				WHEN rnk <= 3 THEN 'most popular'
				ELSE 'least expensive'
			END AS popularity
FROM 
	(SELECT style, COUNT(1), RANK() OVER(ORDER BY COUNT(1) DESC) rnk, COUNT(1) OVER() no_of_records  
	FROM work
	WHERE style IS NOT null
	GROUP BY style) sub
WHERE rnk <= 3 OR
	  rnk > no_of_records - 3

--Solution 2
SELECT style, CASE 
				WHEN cheap <= 3 THEN 'least popular'
				WHEN expensive <=3 THEN 'most expensive'
			END AS popularity
FROM 
	(SELECT style, COUNT(1), RANK() OVER(ORDER BY COUNT(1)) cheap, RANK() OVER(ORDER BY COUNT(1) DESC) expensive  
	FROM work
	WHERE style IS NOT null
	GROUP BY style) sub
WHERE cheap <= 3 OR
	  expensive <= 3
	
--22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

SELECT full_name AS artist_name, nationality, no_of_paintaings
FROM (
	SELECT a.full_name, a.nationality, COUNT(1) AS no_of_paintaings, RANK () OVER (ORDER BY COUNT(1) DESC)
	FROM work w
	JOIN artist a ON a.artist_id = w.artist_id
	JOIN subject s ON s.work_id = w.work_id
	JOIN museum m ON m.museum_id = w.museum_id
	WHERE m.country != 'USA' AND
	s.subject = 'Portraits'
	GROUP BY a.full_name, a.nationality
	) sub
WHERE rank = 1


