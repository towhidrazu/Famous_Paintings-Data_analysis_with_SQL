![horse](https://github.com/towhidrazu/Famous_Paintings-Data_analysis_with_SQL/blob/main/horse_and_boats.jpg)
# Famous_Paintings-Data_analysis_with_SQL
## Answering several questions using SQL queries from Paintaings data

***Little background: Recently, I visited the Museum of Natural Sciences at the University of Saskatchewan. On the same day, after returning home, I opened YouTube and came across a video from the famous TechTFQ channel. The video focused on paintings and museum data analysis using SQL. The dataset included information about various paintings displayed in museums worldwide. The analysis involved answering a handful of questions using SQL queries. Given my recent museum visit, I found a connection to the content and decided to recreate the project, intending to add it to my portfolio.***


**Dataset is taken from this link: https://www.kaggle.com/datasets/mexwell/famous-paintings**

In this project, under the folder of 'datasets' we have 8 numbers of CSV files. We have to import those CSV files into our postgreSQL. To do that easily we will use python programming language. We will use 'pandas' and 'sqlalchemy' library of python. Pandas is a very popular python library used for working with data sets. It has functions for analyzing, cleaning, exploring, and manipulating data. SQLAlchemy is the Python SQL toolkit and Object Relational Mapper that gives application developers the full power and flexibility of SQL. 

Now will install the following python libraries through terminal one by one
```
pip install pandas

pip install sqlalchemy

--additionally if required he have to install following 2 libraries

pip install pyarrow

pip install psycopg2

```

Then we will create a database in postgreSQL named 'paintaings' where we will load our CSV files.

Now on Visual Studio code we will run the following codes to create 8 new tables with all their data from 8 CSV files under paintaings database.

```
import pandas as pandas
from sqlalchemy import create_engine

conn_string = 'postgresql://postgres:password@localhost/paintings'
db = create_engine(conn_string)
conn = db.connect()

files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size', 'subject', 'work']

for file in files:
    df = pd.read_csv(f'F:\paintaings\Dataset\{file}.csv')
    df.to_sql(file, con=conn, if_exists='replace', index=False)
```

Now all 8 CSV files are loaded into our paintaings database of PostgreSQL and ready to be used with SQL queries.

**1) Fetch all the paintings which are not displayed on any museums?**
```
SELECT * 
FROM work
WHERE museum_id IS null
```

<br>
<br>

**2) Are there museuems without any paintings?**
```
#solution 1
SELECT *
FROM museum m
WHERE museum_id NOT IN (SELECT museum_id 
			FROM work w 
			WHERE m.museum_id = w.museum_id)
#solution 2
SELECT *
FROM museum m
WHERE NOT EXISTS (SELECT museum_id 
		FROM work w 
		WHERE m.museum_id = w.museum_id)
```
***Features and/(or) clauses involved: Subquery***

<br>
<br>

**3) How many paintings have an asking price of more than their regular price?**
```
#solution 1
SELECT COUNT(*) AS No_of_paintaings
FROM product_size
WHERE sale_price > regular_price

#solution 2
SELECT COUNT(*) AS No_of_paintaings
FROM product_size
WHERE (sale_price - regular_price) > '0'
```

<br>
<br>

**4) Identify the paintings whose asking price is less than 50% of its regular price.**
```
SELECT * 
FROM product_size
WHERE sale_price < regular_price / 2
```

<br>
<br>

**5) Which canva size costs the most?**
```
SELECT c.label AS Canva, p.sale_price
FROM product_size AS p
JOIN canvas_size AS c
ON p.size_id = c.size_id::text
ORDER BY p.sale_price DESC
LIMIT 1
```
***Features and/(or) clauses involved: JOIN, LIMIT***

<br>
<br>

**6) Delete duplicate records from work, product_size, subject and image_link tables.**
```
```

<br>
<br>

**7) Identify the museums with invalid city information in the given dataset.**
```
SELECT *
FROM museum
WHERE city ~'[0-9]'
```
***Features and/(or) clauses involved: Regular expression***

<br>

**Note: Explanation from ChatGPT**
In PostgreSQL, the tilde (~) is used as a match operator for regular expressions in queries. Let's break down the two regular expressions you provided:

1. `~'^[0-9]'`: This regular expression matches strings that start with a digit (0-9). The caret (^) is an anchor that asserts the start of the string, and `[0-9]` specifies a character class that includes any digit from 0 to 9.

2. `~'[0-9]'`: This regular expression matches any string that contains at least one digit (0-9). It doesn't specify the position of the digit within the string.

Here's a brief summary:

- `~'^[0-9]'`: Matches strings that start with a digit.
- `~'[0-9]'`: Matches strings that contain at least one digit.

In summary, the difference lies in the positioning of the digit within the string. The first one specifies that the digit must be at the beginning of the string, while the second one only requires the presence of a digit anywhere in the string.

<br>
<br>

**8) Museum_Hours table has 1 invalid entry. Identify it and remove it.**
```
```

<br>
<br>

**9) Fetch the top 10 most famous painting subject.**
```
#Solution 1
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

#Solution 2
select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10
```
***Features and/(or) clauses involved: Common table expression (CTE)***

<br>
<br>

**10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.**
```
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
```
***Features and/(or) clauses involved: Looking from 2 conditions from same column***

<br>
<br>

**11) How many museums are open every single day?**
```
SELECT COUNT(museum_id) no_of_museums
FROM (
	SELECT museum_id, COUNT(museum_id)
	FROM museum_hours
	GROUP BY museum_id
	HAVING COUNT(museum_id) = 7
	) Sub
```

<br>
<br>

**12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)**
```
WITH temp AS(SELECT m.name, m.city, m.country, w.museum_id
FROM work w
JOIN museum m
ON w.museum_id = m.museum_id)
SELECT name, museum_id, city, country, COUNT(museum_id) AS no_of_paintaings
FROM temp
GROUP BY name, city, country, museum_id
ORDER BY COUNT(museum_id) DESC
LIMIT 5
```

<br>
<br>

**13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)**
```
SELECT full_name AS artist_name, no_of_paintaings, rank
FROM(
	SELECT a.full_name, COUNT(1) no_of_paintaings, RANK() OVER(ORDER BY COUNT(1) DESC)
	FROM artist a
	JOIN work w
	ON a.artist_id = w.artist_id
	GROUP BY a.full_name
	) sub
WHERE rank <= 5
```
***Features and/(or) clauses involved: Subquery, RANK window function***

<br>
<br>

**14) Display the 3 least popular canva sizes**
```
SELECT label, no_of_paintaings, ranking
FROM(
	SELECT c.label, COUNT(1) AS no_of_paintaings, DENSE_RANK() OVER(ORDER BY COUNT(1)) AS ranking
	FROM canvas_size c
	JOIN product_size p ON c.size_id::text = p.size_id
	JOIN work w ON w.work_id = p.work_id
	GROUP BY c.label
	) sub
WHERE ranking <=3
```
***Features and/(or) clauses involved: DENSE_RANK window function, Join 3 tables***

<br>
<br>

**15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?**
```
#Solution 1
SELECT m.name, m.state, mh.day, mh.open, mh.close, mh.duration
FROM(
	SELECT *, TO_TIMESTAMP(close, 'HH:MI AM') - TO_TIMESTAMP(open,'HH:MI PM') AS duration
	FROM museum_hours
	ORDER BY TO_TIMESTAMP(close, 'HH:MI AM') - TO_TIMESTAMP(open,'HH:MI PM') DESC
	LIMIT 1) mh
JOIN museum m
ON m.museum_id = mh.museum_id

#Solution 2
select museum_name,state as city,day, open, close, duration
	from (	select m.name as museum_name, m.state, day, open, close
			, to_timestamp(open,'HH:MI AM') 
			, to_timestamp(close,'HH:MI PM') 
			, to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration
			, rank() over (order by (to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM')) desc) as rnk
			from museum_hours mh
		 	join museum m on m.museum_id=mh.museum_id) x
	where x.rnk=1;
```
***Features and/(or) clauses involved: Convert TEXT value TO_TIMESTAMP and take only hour values from there***

<br>
<br>

**16) Which museum has the most no of most popular painting style?**
```
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
```
***Features and/(or) clauses involved: 2nd degree subquery (subquery inside a subquery)***

<br>
<br>

**17) Identify the artists whose paintings are displayed in multiple countries.**
```
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
```
***Features and/(or) clauses involved: DISTINCT, ORDER BY 2 columns***

<br>
<br>

**18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.**
```
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
```
***Features and/(or) clauses involved: Multiple CTEs, String agreegation, DISTINCT, CROSSS JOIN***

<br>
<br>

**19) Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label.**
```
```

<br>
<br>

**20) Which country has the 5th highest no of paintings?**
```
SELECT country, no_of_paintaings
FROM (
	SELECT m.country, COUNT(1) no_of_paintaings, RANK() OVER(ORDER BY COUNT(1) DESC)
	FROM work w
	JOIN museum m
	ON w.museum_id = m.museum_id
	GROUP BY m.country
	) temp
WHERE rank = 5

```
***Features and/(or) clauses involved: Subquery, RANK window function***

<br>
<br>

**21) Which are the 3 most popular and 3 least popular painting styles?**
```
```

<br>
<br>

**22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.**
```
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
```
***Features and/(or) clauses involved: Subquery, RANK window function, Join 3 tables***
