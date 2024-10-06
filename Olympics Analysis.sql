-- Interestingly every dataset has a story that can be developed after thorough interview.
-- Olympics competition is organized every 3 years, there are those that are feted in the process, 
-- focus of the analysis is to look deep into the data and as well develop a worthwhile story

-- Querying data and writing code is what makes the concepts stick
-- Analysis allows one to build an intuition regarding the data and in the process master concepts that rather seemed dificult at first.

-- Building a table that will hold the data
-- Interviewing the data to can help one learn of data incostintency

DROP TABLE athletes_events

CREATE TABLE athletes_events(
	id text,
	name text,
	gender text,
	age text,
	height text,
	weight text,
	team text,
	noc text,
	games text,
	year integer,
	season text,
	city text,
	sport text,
	event text,
	medal text
)

DELETE FROM athletes_events


-- Focus is summer olympics which is the biggest event
COPY athletes_events
FROM 'C:\Users\KEVIN\Desktop\Machine Learning\DataAnalysis\olympicsAnalysis\athlete_events.csv'
WITH (FORMAT CSV, HEADER)
WHERE season = 'Summer'

CREATE INDEX id_idx on athletes_events(id)

SELECT * 
FROM athletes_events
LIMIT 5

CREATE TABLE noc_nations(
	noc char(3),
	region text,
	notes text
)

COPY noc_nations
FROM 'C:\Users\KEVIN\Desktop\Machine Learning\DataAnalysis\olympicsAnalysis\noc_regions.csv'
WITH (FORMAT CSV, HEADER)

SELECT *
FROM noc_nations
LIMIT 

-- To import the data, there are columns such as that for age, height and weight that had to be assigned the 
-- text data type, there instants of NA.

-- Data Wrangling to allow for better analysis.

ALTER TABLE athletes_events ADD COLUMN age_column text

-- assigning the new age_column the details from the original age column
UPDATE athletes_events
SET age_column = age
SELECT
age_column,
count(age_column) as numbers
FROM athletes_events
GROUP BY age_column
ORDER BY numbers DESC
-- NA has 9189 records

UPDATE athletes_events
SET age_column = ' '
WHERE age_column = '0'

-- There are various aspects of the data that cleaning will not make the data better, on reviewing 
-- There are instances where a person is as old as 71yrs and as young as 13, the same are exceptionally
-- but since the analysis is focused on matters medals and specific names in the field, we shall retain the data as is

-- Drpping the column that was intially created for purposes of data cleaning.

ALTER TABLE athletes_events DROP COLUMN age_column

UPDATE athletes_events
SET gender = 'male'
WHERE gender = 'M'

UPDATE athletes_events
SET gender = 'female'
WHERE gender = 'F'

-- Total count of athletes

-- Total athletes representation by olympic Season
SELECT 
year,
count(distinct id) as athletes,
city
FROM athletes_events
GROUP BY year, city
HAVING count(distinct id) > 5000
ORDER BY athletes DESC

SELECT 
	count(distinct id) as total_athletes
FROM athletes_events
	
-- The summer olympics has recorded 116,776 unique athletes since its inception in 1896

SELECT
year,
city,
round((count(CASE WHEN gender = 'male' THEN 'male' END)::decimal/ count(gender)::decimal)* 100, 2) as Male,
round((count(CASE WHEN gender = 'female' THEN 'Female' END)::decimal/ count(gender)::decimal)*100, 2) as Female,
count(gender) as total_athletes
FROM
(SELECT
distinct(id),
year,
city,
name,
gender
FROM athletes_events)
GROUP BY year, city
ORDER BY Male DESC

-- Over the the years the competition has witnessed more of the male gender as compared to the female gender
-- This begs the question of further understanding the sports/fields, are they gender oriented

-- Joining Tables to understand the representation per country


-- Top 18 nations to have over 2000 athletes

SELECT
	region,
	count(CASE WHEN gender = 'male' THEN 'Male' END) as Male,
	count(CASE WHEN gender = 'female' THEN 'Female' END) as Female,
	count(id) as total
FROM(
SELECT
	distinct(id),
	region,
	gender
FROM(
SELECT
* 
FROM athletes_events
JOIN noc_nations
USING (noc)))
GROUP BY region
HAVING count(id)>2000
ORDER BY total DESC

-- Nations with 100 athletes in the competition
SELECT
	region,
	count(CASE WHEN gender = 'male' THEN 'Male' END) as Male,
	count(CASE WHEN gender = 'female' THEN 'Female' END) as Female,
	count(id) as total
FROM(
SELECT
	distinct(id),
	region,
	gender
FROM(
SELECT
* 
FROM athletes_events
JOIN noc_nations
USING (noc)))
GROUP BY region
HAVING count(id) < 100
ORDER BY total DESC

-- Host cities

SELECT *
FROM athletes_events
LIMIT 5




-- London, Athens(Athina), Paris, Stockholm & Los angeles have hosted the olympics more than 2 twice




-- Sports dominated by Male gender
SELECT
sport,
count(case WHEN gender = 'male' then 'male' END) as Male,
count(case WHEN gender = 'female' then 'female' END) as Female
FROM (
SELECT
sport,
gender
FROM athletes_events)
GROUP BY sport
Having count(case WHEN gender = 'female' then 'female' END) = 0


-- Sports dominated by Female gender
SELECT
sport,
count(case WHEN gender = 'male' then 'male' END) as Male,
count(case WHEN gender = 'female' then 'female' END) as Female
FROM (
SELECT
sport,
gender
FROM athletes_events)
GROUP BY sport
Having count(case WHEN gender = 'male' then 'male' END) = 0


-- Various sports representation
SELECT
sport,
round((count(case WHEN gender = 'male' then 'male' END)::decimal / count(sport)::decimal)*100,2) as Male,
round((count(case WHEN gender = 'female' then 'female' END)::decimal / count(sport)::decimal) *100,2) as Female,
count(sport)
FROM (
SELECT
sport,
gender
FROM athletes_events)
GROUP BY sport
ORDER BY count(sport) DESC


-- Medals by country, atleast for those that have won medals.

SELECT
n.region,
count(CASE WHEN a.medal = 'Gold' then 'Gold' END) as Gold,
count(CASE WHEN a.medal = 'Silver' then 'Silver' END) as Silver,
count(CASE WHEN a.medal = 'Bronze' then 'Bronze' END) as Bronze,
count(a.medal)
FROM athletes_events a
JOIN noc_nations n
USING(noc)
WHERE a.medal<>'NA'
GROUP BY n.region
ORDER BY count(a.medal) DESC

-- Atleast 134 nations have won medals in the olympics competition


SELECT
a.name,
n.region,
a.sport,
count(CASE WHEN a.medal = 'Gold' then 'Gold' END) as Gold,
count(CASE WHEN a.medal = 'Silver' then 'Silver' END) as Silver,
count(CASE WHEN a.medal = 'Bronze' then 'Bronze' END) as Bronze,
count(a.medal)
FROM athletes_events a
JOIN noc_nations n
USING(noc)
WHERE a.medal<>'NA'
GROUP BY n.region, a.name, a.sport
ORDER BY count(a.medal) DESC

-- Medal standing for men
SELECT
a.name,
n.region,
a.sport,
count(CASE WHEN a.medal = 'Gold' then 'Gold' END) as Gold,
count(CASE WHEN a.medal = 'Silver' then 'Silver' END) as Silver,
count(CASE WHEN a.medal = 'Bronze' then 'Bronze' END) as Bronze,
count(a.medal)
FROM athletes_events a
JOIN noc_nations n
USING(noc)
WHERE a.medal<>'NA' AND gender = 'male'
GROUP BY n.region, a.name, a.sport
ORDER BY count(a.medal) DESC


-- Medal standings for Women
SELECT
a.name,
n.region,
a.sport,
count(CASE WHEN a.medal = 'Gold' then 'Gold' END) as Gold,
count(CASE WHEN a.medal = 'Silver' then 'Silver' END) as Silver,
count(CASE WHEN a.medal = 'Bronze' then 'Bronze' END) as Bronze,
count(a.medal)
FROM athletes_events a
JOIN noc_nations n
USING(noc)
WHERE a.medal<>'NA' AND gender = 'female'
GROUP BY n.region, a.name, a.sport
ORDER BY count(a.medal) DESC


--Persons of interest
 	-- "Allyson Michelle Felix"
	-- "Michael Fred Phelps, II"
	
	
-- Areas of investigation 
	--First ever competition
	--Competitions involved in and medal spread
	
SELECT
year,
event,
medal,
age
FROM athletes_events
WHERE name = 'Allyson Michelle Felix'
ORDER BY year
-- Allyson entered the competition at the age of 18yrs old
-- Allyson first olympics competition was in 2004, she featured in the 200 metres race where she won Silver
-- In 2008 she as well did 200 metres and 400 metres relay where she won Silver and Gold respectively
-- In 2012 she tried 100 Metres race was never successful, but she won Gold in 200 Metres, 100 Metres  and 400 Metres Relays
-- In 2016 she again won Gold in 100 Metres and 400 Metres relays, she as well won silver in 400 metres race



SELECT
year,
name,
age,
event,
medal
FROM athletes_events
WHERE name = 'Michael Fred Phelps, II'
ORDER BY year


SELECT
year,
count(CASE WHEN medal = 'Gold' THEN 'GOLD' END) as gold,
count(CASE WHEN medal = 'Silver' THEN 'SIlver' END) as silver,
count(CASE WHEN medal = 'Bronze' THEN 'Bronze' END) as bronze,
count(medal)
FROM athletes_events
WHERE name = 'Michael Fred Phelps, II' and medal <>'NA'
GROUP BY year
ORDER BY year








