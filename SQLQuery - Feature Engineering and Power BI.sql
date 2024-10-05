------------------- Human Resource: Employee Distribution Project ---------------------------
/* Skills used: Create Database, Alter/Modify/Update Table, Column, Datatype, Add Column,
				Standard SQL Queries, Case Statement, Subquery, Formatting Date Column */

CREATE DATABASE Human_Resource;

USE Human_Resource;

SELECT * FROM HR;

---------------------------	Part -1 Data Cleaning / Feature Engineering ----------------------
-- 1. Employee_id Column
ALTER TABLE HR
CHANGE COLUMN ﻿id emp_id VARCHAR(20) NULL;


-- 2. Birthdate Column
SELECT birthdate FROM HR;

UPDATE HR
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE HR
MODIFY COLUMN birthdate DATE;


-- 3. Hiredate Column
UPDATE HR
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE HR
MODIFY COLUMN hire_date DATE;


-- 4. Termdate Column
UPDATE HR
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

ALTER TABLE HR
MODIFY COLUMN termdate DATE;


-- 5. Add new column
ALTER TABLE HR 
ADD COLUMN age INT;

UPDATE HR
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM HR;

SELECT count(*) FROM HR
WHERE age < 18;


-----------------------------	PART - 2 Data Queries for Power BI --------------------------------

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;


-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT gender, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender
ORDER BY Count DESC;


-- 3. What is the age distribution of employees in the company?
SELECT MIN(age) AS Youngest
		MAX(age) AS Oldest
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
-- GROUP BY gender
-- ORDER BY Count DESC;

SELECT
	CASE
		WHEN age >= 21 AND age <= 25 THEN '21-25'
		WHEN age >= 26 AND age <= 35 THEN '21-25'
		WHEN age >= 36 AND age <= 45 THEN '21-25'
		WHEN age >= 46 AND age <= 55 THEN '21-25'
		ELSE '55+'
	END AS Age_Group
	COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY Age_Group
ORDER BY Age_Group;


-- 4. How many employees work at headquaters versus remote loacations?
SELECT location, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;


-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hiredate))/365,0) AS Avg_Employment_Length
FROM HR
WHERE age >= 18 AND 
		termdate <> '0000-00-00' AND
		termdate <= CURRENT_DATE();


-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, jobtitle, gender, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, jobtitle, gender
ORDER BY department;


-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle;


-- 8. Which department has the highest turnover rate?
SELECT department, 
		Total_Count, 
		Termination_Count,
		ROUND((Termination_Count/Total_Count)*100, 2) AS Termination_Rate
FROM (
	SELECT department,
			COUNT(*) AS Total_Count,
			SUM(CASE
					WHEN termdate <> '0000-00-00' AND termdate <= CURRENT_DATE() THEN 1
					ELSE 0
				END) AS Termination_Count
	FROM HR
	WHERE age >= 18
	GROUP BY department
	) AS Sub_query
ORDER BY Termination_Rate DESC;


-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, location_city, COUNT(*) AS Count
FROM HR
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state, location_city
ORDER BY Count DESC;


-- 10. How has the company's employee count changed over time based on hire and termdates?
SELECT YEAR, 
		HIRES,
		TERMINATIONS,
		HIRES - TERMINATIONS AS Net_Change
		ROUND((HIRES - TERMINATIONS)/HIRES*100, 2) AS Termination_Rate
FROM (
	SELECT YEAR(hire_date) AS YEAR
			COUNT(*) AS HIRES,
			SUM(CASE
					WHEN termdate <> '0000-00-00' AND termdate <= CURRENT_DATE() THEN 1
					ELSE 0
				END) AS TERMINATIONS
	FROM HR
	WHERE age >= 18
	GROUP BY YEAR(hire_date)
	) AS Sub_query
ORDER BY YEAR ASC;


-- 11. What is the tenure distribtuion for each department?
SELECT ROUND(AVG(DATEDIFF(termdate, hiredate))/365,0) AS Avg_Tenure
FROM HR
WHERE age >= 18 AND 
		termdate <> '0000-00-00' AND
		termdate <= CURRENT_DATE()
GROUP BY department;



---------------------------------------------		END		----------------------------------------------------