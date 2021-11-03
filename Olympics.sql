-- Select all 4 tables to be familiar with them

SELECT *
FROM olympics..scores

SELECT TOP 3 *
FROM olympics..performance

SELECT TOP 50 PERCENT *
FROM olympics..judges

SELECT *
FROM olympics..judged_aspect 
LIMIT 5;


-- basic operations with the performance table

SELECT nation, COUNT(name) AS number_applicants, 
               AVG(total_element_score) AS average_score,  
			   SUM(total_segment_score) AS segment_score,
			   MAX(total_component_score) AS max_score
FROM olympics..performance
WHERE competition is NOT NULL and competition LIKE '%2018'
GROUP BY nation
HAVING MAX(total_component_score) > 30
ORDER BY number_applicants DESC;


-- join scores, performance and judged_aspect in one table

SELECT * 
FROM olympics..scores AS s
INNER JOIN olympics..judged_aspect AS ja ON s.aspect_id=ja.aspect_id
INNER JOIN olympics..performance as p ON p.performance_id = ja.performance_id
ORDER BY 'rank' DESC


-- look at the winners and country that received the most medals 

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


-- Create a new table with countries who received medals, run drop table if exists if want to make any changes

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



-- create view of top_teams for later use of this table
GO
Create View teams_medals as
   SELECT NAME, nation,  total_segment_score, CASE WHEN RANK =1 THEN 'gold'
                                                   WHEN RANK =2 THEN 'silver'
									               ELSE 'bronse'
							                  END AS medals
     FROM olympics..performance
     WHERE RANK between 1 and 3
GO


-- Individual scores of each player who received the 1st place and sum of their scores

SELECT p.name, p.nation,p.program, s.judge, sum(s.score) as judge_score
FROM olympics..performance AS p
INNER JOIN olympics..judged_aspect as ja ON p.performance_id = ja.performance_id
JOIN olympics..scores AS s ON s.aspect_id=ja.aspect_id
WHERE p.program LIKE '%pair skating%' and RANK = 1
GROUP BY s.judge, p.name, p.nation, p.program
ORDER BY p.name DESC


