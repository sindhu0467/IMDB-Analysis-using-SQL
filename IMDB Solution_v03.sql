USE imdb;

-- The total number of rows in each table of the schema:

SELECT 
    *
FROM
    (SELECT 
        'director_mapping' AS table_name, COUNT(*)
    FROM
        director_mapping UNION ALL SELECT 
        'genre' AS table_name, COUNT(*)
    FROM
        genre UNION ALL SELECT 
        'movie' AS table_name, COUNT(*)
    FROM
        movie UNION ALL SELECT 
        'names' AS table_name, COUNT(*)
    FROM
        names UNION ALL SELECT 
        'ratings' AS table_name, COUNT(*)
    FROM
        ratings UNION ALL SELECT 
        'role_mapping' AS table_name, COUNT(*)
    FROM
        role_mapping) AS base ; 

-- The columns in the movie table have null values:

SELECT 
    *
FROM
    movie
WHERE
    (country IS NULL
        OR worlwide_gross_income IS NULL
        OR languages IS NULL
        OR production_company IS NULL);

#country and worlwide_gross_income or languages or production_company are the columns which have null values.
 
#The total number of movies released each year and the trend look month wise:

SELECT 
    year, COUNT(DISTINCT id) as number_of_movies
FROM
    movie
GROUP BY year;  

SELECT 
    MONTH(date_published) as month_num, COUNT(DISTINCT id) as number_of_movies
FROM
    movie
GROUP BY MONTH(date_published);

#The highest number of movies is produced in the month of March.

  
#No. of movies produced in the USA or India in the year 2019:

SELECT 
    country, COUNT(DISTINCT id) as number_of_movies
FROM
    movie
WHERE
    LOWER(TRIM(country)) IN ('usa' , 'india')
        AND year = 2019
GROUP BY country; 

#India produced 295 movies in the year 2019 and USA produced 592 movies in the year 2019.

#The genres present in the data set:

SELECT DISTINCT
    genre
FROM
    genre; 

#Genre that had the highest number of movies produced overall:

SELECT DISTINCT
    genre, COUNT(DISTINCT id) AS number_of_movies
FROM
    movie AS m
        INNER JOIN
    genre AS g ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(m.id))
GROUP BY genre
ORDER BY count_movies DESC; 

#Drama genre has the highest number of movies produced.

#No. of movies with only one genre:

SELECT 
    COUNT(id) as number_of_movies
FROM
    (SELECT 
        id, COUNT(DISTINCT genre) AS count_genres
    FROM
        movie AS m
    INNER JOIN genre AS g ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(m.id))
    GROUP BY id
    HAVING count_genres = 1
    ORDER BY count_genres DESC) base;  

#There are 3289 movies with 1 genre only.

#The average duration of movies in each genre:

SELECT 
    genre, AVG(duration) AS avg_duration
FROM
    movie AS m
        INNER JOIN
    genre AS g ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(m.id))
GROUP BY genre
ORDER BY genre;

#'Drama' has the average duration of 106.77 mins.

#The rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

SELECT genre,
       count_movies AS movie_count,
       Rank() OVER(ORDER BY count_movies DESC) AS gerne_rank
FROM   (SELECT genre,
               Count(DISTINCT id) AS count_movies
        FROM   movie AS m
               INNER JOIN genre AS g
                       ON Lower(Trim(g.movie_id)) = Lower(Trim(m.id))
        GROUP  BY genre) base
ORDER  BY 3 ASC  ;

#Rank of Thriller genre is 3 and it produced 1484 movies.

#The minimum and maximum values in  each column of the ratings table except the movie_id column?

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS min_median_rating
FROM
    ratings ; 

#The top 10 movies based on average rating?

SELECT *
FROM   (SELECT DISTINCT title,
                        avg_rating,
                        Dense_rank()
                          OVER(
                            ORDER BY avg_rating DESC) AS movie_rank
        FROM   movie AS m
               INNER JOIN ratings AS r
                       ON Lower(Trim(m.id)) = Lower(Trim(r.movie_id))) base
WHERE  movie_rank BETWEEN 1 AND 10
ORDER  BY movie_rank ASC ; 

#Summarising the ratings table based on the movie counts by median ratings:

SELECT DISTINCT
    median_rating, COUNT(DISTINCT id) as movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON LOWER(TRIM(m.id)) = LOWER(TRIM(r.movie_id))
GROUP BY median_rating
ORDER BY median_rating  ; 


#Movies with a median rating of 7 is highest in number. 

#Production house that has produced the most number of hit movies (average rating > 8):
 
SELECT DISTINCT production_company,
                movie_count,
                Rank()
                  OVER(
                    ORDER BY movie_count DESC) AS prod_company_rank
FROM   (SELECT DISTINCT production_company,
                        Count(DISTINCT id) AS movie_count
        FROM   movie AS m
               INNER JOIN ratings AS r
                       ON Lower(Trim(m.id)) = Lower(Trim(r.movie_id))
        WHERE  avg_rating > 8
               AND production_company IS NOT NULL
        GROUP  BY production_company) base;  


#Dream Warrior Pictures and National Theatre Live has produced 3 movies with average rating > 8 and stood in first place.

#No. of movies released in each genre during March 2017 in the USA had more than 1,000 votes:

SELECT 
    genre, COUNT(DISTINCT id) AS movie_count
FROM
    movie AS m
        INNER JOIN
    genre AS g ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(m.id))
        INNER JOIN
    ratings AS r ON LOWER(TRIM(m.id)) = LOWER(TRIM(r.movie_id))
WHERE
    LOWER(TRIM(country)) = 'usa'
        AND MONTH(date_published) = 03
        AND year = 2017
        AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC; 

#movies of each genre that start with the word ‘The’ and which have an average rating > 8?

SELECT 
    title, avg_rating, genre
FROM
    movie AS m
        INNER JOIN
    genre AS g ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(m.id))
        INNER JOIN
    ratings AS r ON LOWER(TRIM(m.id)) = LOWER(TRIM(r.movie_id))
WHERE
    avg_rating > 8
        AND LOWER(TRIM(title)) LIKE 'the%';  

#No. Of the movies released between 1 April 2018 and 1 April 2019 with a median rating of 8?

SELECT 
    COUNT(DISTINCT id) as movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON LOWER(TRIM(m.id)) = LOWER(TRIM(r.movie_id))
WHERE
    (date_published >= '2018-04-01'
        AND date_published <= '2019-04-01')
        AND median_rating = 8;

#There are 361 movies released between 2018-04-01 and 2019-04-01


#Do German movies get more votes than Italian movies? 

SELECT DISTINCT
    languages, SUM(total_votes) as total_votes_sum
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON LOWER(TRIM(m.id)) = LOWER(TRIM(r.movie_id))
WHERE
    LOWER(TRIM(languages)) IN ('german' , 'italian')
GROUP BY languages;



-- Answer is Yes

#Which columns in the names table have null values??

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) known_for_movies_nulls
FROM
    names; 

#Height and Date of Birth and Known for movies are the columns


#Who are the top three directors in the top three genres whose movies have an average rating > 8?

CREATE VIEW director_summary AS
    SELECT DISTINCT
        name_id, name, r.movie_id, avg_rating, median_rating, genre
    FROM
        names AS n
            INNER JOIN
        director_mapping AS dm ON LOWER(TRIM(n.id)) = LOWER(TRIM(dm.name_id))
            INNER JOIN
        ratings AS r ON LOWER(TRIM(dm.movie_id)) = LOWER(TRIM(r.movie_id))
            INNER JOIN
        genre AS g ON LOWER(TRIM(dm.movie_id)) = LOWER(TRIM(g.movie_id));

SELECT 
    name AS director_name, COUNT(movie_id) AS movie_count
FROM
    director_summary
WHERE
    avg_rating > 8
        AND genre IN (SELECT 
            genre
        FROM
            (SELECT DISTINCT
                genre, COUNT(g.movie_id) AS movie_count
            FROM
                genre AS g
            INNER JOIN ratings AS r ON LOWER(TRIM(g.movie_id)) = LOWER(TRIM(r.movie_id))
            WHERE
                avg_rating > 8
            GROUP BY genre
            ORDER BY movie_count DESC
            LIMIT 3) base)
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;


#James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 

#Who are the top two actors whose movies have a median rating >= 8?

SELECT DISTINCT
    name, COUNT(r.movie_id) AS movie_count
FROM
    names AS n
        INNER JOIN
    role_mapping AS rm ON LOWER(TRIM(n.id)) = LOWER(TRIM(rm.name_id))
        INNER JOIN
    ratings AS r ON LOWER(TRIM(rm.movie_id)) = LOWER(TRIM(r.movie_id))
WHERE
    category = 'actor'
        AND median_rating >= 8
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;



#Which are the top three production houses based on the number of votes received by their movies?

SELECT   production_company,
         vote_count,
         Rank() OVER(ORDER BY vote_count DESC) AS prod_comp_rank
FROM     (
                    SELECT     production_company,
                               Sum(total_votes) AS vote_count
                    FROM       movie            AS m
                    INNER JOIN ratings          AS r
                    ON         Lower(Trim(m.id)) = Lower(Trim(r.movie_id))
                    GROUP BY   production_company ) base limit 3 ;

#Marvel Studios rules the movie world.

#Rank actors with movies released in India based on their average ratings and actor is at the top of the list:

SELECT *,DENSE_RANK() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
FROM (
SELECT name AS actor_name, sum(total_votes) as total_votes,
                COUNT(m.id) AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
INNER JOIN role_mapping AS rm
ON m.id=rm.movie_id
INNER JOIN names AS nm
ON rm.name_id=nm.id
WHERE category='actor' AND country='india'
GROUP BY name
HAVING COUNT(m.id)>=5 ) base
LIMIT 5;


-- Top actor is Vijay Sethupathi

#The top five actresses in Hindi movies released in India based on their average ratings:

SELECT *,RANK() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM (
SELECT name AS actress_name, sum(total_votes) as total_votes,
                COUNT(m.id) AS movie_count,
                ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
INNER JOIN role_mapping AS rm
ON m.id=rm.movie_id
INNER JOIN names AS nm
ON rm.name_id=nm.id
WHERE category='actress' AND country='india' AND languages='hindi'
GROUP BY name
HAVING COUNT(m.id)>=3 ) base
LIMIT 5; 



#Taapsee Pannu tops with average rating 7.74. 

/* Thriller movies as per avg rating and classifying them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT 
    title,
    avg_rating,
    genre,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating > 7 AND avg_rating <= 8 THEN 'Hit movies'
        WHEN avg_rating > 5 AND avg_rating <= 7 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
    END AS 'category_of_movies'
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    LOWER(genre) = 'thriller';


#The genre-wise running total and moving average of the average movie duration:

SELECT DISTINCT genre,
                Avg(duration)
                  OVER(
                    partition BY genre) AS avg_duration,
                Sum(duration)
                  OVER(
                    ORDER BY genre)     AS running_total_duration,
                Avg(duration)
                  OVER(
                    ORDER BY genre)     AS moving_avg_duration
FROM   movie AS m
       INNER JOIN genre AS g
               ON Lower(m.id) = Lower(g.movie_id); 


#The five highest-grossing movies of each year that belong to the top three genres:

CREATE VIEW top_3_genre AS
    (SELECT 
        genre
    FROM
        (SELECT DISTINCT
            genre, COUNT(ge.movie_id) AS movie_count
        FROM
            genre AS ge
        INNER JOIN ratings AS r ON LOWER(ge.movie_id) = LOWER(r.movie_id)
        GROUP BY genre
        ORDER BY movie_count DESC
        LIMIT 3) base); 

SELECT *
FROM   (SELECT genre,
               year,
               title                                     AS movie_name,
               worlwide_gross_income,
               Rank()
                 OVER(
                   partition BY year
                   ORDER BY worlwide_gross_income DESC ) AS movie_rank
        FROM   movie AS m
               INNER JOIN genre AS g
                       ON m.id = g.movie_id
        WHERE  genre IN (SELECT genre
                         FROM   top_3_genre)) base
WHERE  movie_rank <= 5; 

#The top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies:

SELECT   *,
         Rank() OVER(ORDER BY movie_count DESC) AS prod_comp_rank
FROM     (
                    SELECT     production_company,
                               Count(DISTINCT id) AS movie_count
                    FROM       movie              AS m
                    INNER JOIN ratings            AS r
                    ON         m.id = r.movie_id
                    WHERE      position(',' IN languages)>0
                    AND        production_company IS NOT NULL
                    AND        median_rating >= 8
                    GROUP BY   production_company ) base limit 2 ;

#Top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre:

CREATE VIEW actress_movie_count AS
    (SELECT 
        name AS actress_name,
        COUNT(DISTINCT rm.movie_id) AS movie_count
    FROM
        role_mapping AS rm
            INNER JOIN
        names AS n ON rm.name_id = n.id
            INNER JOIN
        genre AS g ON rm.movie_id = g.movie_id
    WHERE
        LOWER(category) = 'actress'
            AND genre = 'drama'
    GROUP BY name);

#drop view actress_movie_count ; 

CREATE VIEW actress_votes AS
    (SELECT DISTINCT
        name AS actress_name,
        SUM(total_votes) AS total_votes,
        AVG(avg_rating) AS actress_avg_rating
    FROM
        names AS n
            INNER JOIN
        role_mapping AS rm ON n.id = rm.name_id
            INNER JOIN
        ratings AS r ON rm.movie_id = r.movie_id
    WHERE
        category = 'actress'
    GROUP BY name); 

SELECT DISTINCT am.actress_name,
                total_votes,
                movie_count,
                actress_avg_rating,
                Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM            actress_movie_count                    AS am
INNER JOIN      actress_votes                          AS av
ON              am.actress_name = av.actress_name limit 3 ;




/* The following details extracted for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations */

WITH movie_date_info AS
(
SELECT d.name_id, name, d.movie_id,
	   m.date_published, 
       LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
FROM director_mapping d
	 JOIN names AS n 
     ON d.name_id=n.id 
	 JOIN movie AS m 
     ON d.movie_id=m.id
),

date_difference AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_date_info
 ),
 
 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_difference
	 GROUP BY name_id
 ),
 
 final_result AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS avg_inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration,
		 ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id
	 GROUP BY director_id
 )
 SELECT *	
 FROM final_result
 LIMIT 9;

