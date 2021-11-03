-- To work with the data, I've decided to use 4 tables from Olympics Database (scores, performance, judge and judges_aspect)
-- Let's display them:

SELECT *
FROM olympics..scores

SELECT TOP 3 *
FROM olympics..performance

SELECT TOP 50 PERCENT *
FROM olympics..judges

SELECT *
FROM olympics..judged_aspect 
LIMIT 5;


-- I'd like to organize the data a little bit, perform some basic operations with the performance table
-- Display olympic results of each national team

SELECT nation, COUNT(name) AS number_applicants, 
               AVG(total_element_score) AS average_score,  
			   SUM(total_segment_score) AS segment_score,
			   MAX(total_component_score) AS max_score
FROM olympics..performance
WHERE competition is NOT NULL and competition LIKE '%2018'
GROUP BY nation
HAVING MAX(total_component_score) > 30
ORDER BY number_applicants DESC;


-- Now, I could join scores, performance and judged_aspect tables in one table and look at their relationshps

SELECT * 
FROM olympics..scores AS s
INNER JOIN olympics..judged_aspect AS ja ON s.aspect_id=ja.aspect_id
INNER JOIN olympics..performance as p ON p.performance_id = ja.performance_id
ORDER BY 'rank' DESC




-- I'd like to sort all ranks or places that each team received and focus only 
-- on teams who received medals. For this, I will create a subquery and rename 
-- numeric placements to 'gold','silver' and 'bronze' medals. 
-- After this, I will combine all medals and display a country that received
-- the maximum ammount of medals

WITH winners (name,nation,total_segment_score, medals) AS (
  SELECT name, nation,  total_segment_score, CASE WHEN RANK =1 THEN 'gold'
                                                  WHEN RANK =2 THEN 'silver'
					          ELSE 'bronse'
					    END AS medals
     FROM olympics..performance
     WHERE RANK between 1 and 3)
SELECT nation, sum(total_segment_score) as score , count(medals) as total_medals
FROM winners 
GROUP BY nation
ORDER BY count(medals) DESC


-- I'd like to created a table with teams who received medals and save it for future useage.
-- I'm going to run 'drop table if exists' to be able to make any changes to this table later if I need to and avoid errors.

drop table if exists top_teams
CREATE TABLE top_teams
  (NAME nvarchar(255),
   nation nvarchar(255),
   total_segment_score numeric,
   medals nvarchar(255))

INSERT INTO top_teams
   SELECT NAME, nation,  total_segment_score, CASE WHEN RANK =1 THEN 'gold'
                                                   WHEN RANK =2 THEN 'silver'
					           ELSE 'bronse'
				              END AS medals
     FROM olympics..performance
     WHERE RANK between 1 and 3



-- I'd also like to create a view of this table and use it in my Tableau work later.
-- I have to Run th 'GO' command to separate this code from other to be able to activate it.
GO
Create View teams_medals as
   SELECT NAME, nation,  total_segment_score, CASE WHEN RANK =1 THEN 'gold'
                                                   WHEN RANK =2 THEN 'silver'
					           ELSE 'bronse'
					      END AS medals
     FROM olympics..performance
     WHERE RANK between 1 and 3
GO



-- And, finally. I'm going to extract and display individual scores of each player who received the 1st place,
-- country, program where they participated and scores by each judge.

SELECT p.name, p.nation,p.program, s.judge, sum(s.score) as judge_score
FROM olympics..performance AS p
INNER JOIN olympics..judged_aspect as ja ON p.performance_id = ja.performance_id
JOIN olympics..scores AS s ON s.aspect_id=ja.aspect_id
WHERE p.program LIKE '%pair skating%' and RANK = 1
GROUP BY s.judge, p.name, p.nation, p.program
ORDER BY p.name DESC


