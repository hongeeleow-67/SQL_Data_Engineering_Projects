SELECT LENGTH('SQL');

SELECT CHAR_LENGTH('SQL');

SELECT LOWER('SQL');

SELECT UPPER('Sql');

SELECT LEFT('SQL',2);
SELECT RIGHT('SQL',2);
SELECT SUBSTRING('SQL',2,1);

SELECT CONCAT('SQL','-','Functions');
SELECT 'SQL' || '-' || 'Functions';

SELECT ' SQL ';
SELECT TRIM(' SQL ');

SELECT REPLACE('SQL','Q','_');
SELECT REGEXP_REPLACE('data.nerd@gmail.com','^.*(@)','\1');

WITH title_lower AS (
    SELECT
        job_title
        , LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)

SELECT
    job_title
    , CASE
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Others'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;


-- NULLIF returns NULL if the second values matches the first; if not, return the first value
SELECT NULLIF(10,20);
SELECT NULLIF(10,10);

SELECT
    NULLIF(salary_year_avg, 0)
    , NULLIF(salary_hour_avg, 0)
FROM 
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

-- COALESCE returns first non-NULL values between different columns
SELECT COALESCE(0,1,2);
SELECT COALESCE(NULL,1,2);
SELECT COALESCE(NULL,NULL,2);

SELECT
    salary_year_avg
    , salary_hour_avg
    , COALESCE(salary_year_avg, salary_hour_avg * 2080) AS standardised_salary
FROM 
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

-- Final Example - Simplify with Coalesce
SELECT
    job_title_short
    , salary_year_avg
    , salary_hour_avg
    , COALESCE(salary_year_avg, salary_hour_avg * 2080) AS standardised_salary
    , CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 75000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 150000 THEN 'Mid'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardised_salary DESC
LIMIT 10;