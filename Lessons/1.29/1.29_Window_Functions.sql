-- Window functions add context without destroying rows
    -- pipelines need row-level data
    -- aggregates collapse rows
    -- window functions keep rows AND add insight

-- Count Rows - Aggregation Only
SELECT
    COUNT(*)
FROM
    job_postings_fact;

-- Count Rows - Window Function
SELECT
    job_id
    , COUNT(*) OVER ()
FROM
    job_postings_fact;

-- PARTIITION BY - Find hourly salary
SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , AVG(salary_hour_avg) OVER ()
FROM
    job_postings_fact
LIMIT 10;

SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , AVG(salary_hour_avg) OVER (PARTITION BY job_title_short)
FROM
    job_postings_fact
ORDER BY
    RANDOM()
LIMIT 10;

SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , AVG(salary_hour_avg) OVER (PARTITION BY job_title_short) AS role_salary_hour_avg_per
    , AVG(salary_hour_avg) OVER (PARTITION BY job_title_short, company_id) AS company_role_salary_hour_avg_per
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    RANDOM()
LIMIT 10;

-- ORDER BY - Ranking hourly salary
SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , RANK() OVER (ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
-- ORDER BY
--     salary_hour_avg DESC
LIMIT 10;

-- PARTITION BY & ORDER BY - Running Average Hourly Salary
SELECT
    job_posted_date
    , job_title_short
    , salary_hour_avg
    , AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short 
        ORDER BY job_posted_date
    ) AS running_salary_hour_avg
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short
    , job_posted_date
LIMIT 10;

-- PARTITION BY & ORDER BY - Ranking by job_title_short
SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC,
    job_title_short
LIMIT 10;

SELECT
    job_posted_date
    , job_title_short
    , salary_hour_avg
    , MAX(salary_hour_avg) OVER (
        PARTITION BY job_title_short 
        ORDER BY job_posted_date
    ) AS running_salary_hour_avg
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short
    , job_posted_date
LIMIT 10;


-- Ranking Functions - RANK() vs DENSE_RANK
SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 140;

SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , DENSE_RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC
LIMIT 140;

SELECT
    job_id
    , job_title_short
    , salary_hour_avg
    , ROW_NUMBER() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    rank_hourly_salary
LIMIT 140;

-- ROW_NUMBER() - Providing a new job_id
SELECT
    *
    , ROW_NUMBER() OVER (
        ORDER BY job_posted_date
    ) AS new_job_id
FROM
    job_postings_fact
ORDER BY
    job_posted_date
LIMIT 20;

-- LAG() - sees previous record
WITH previous_current_salary AS (
    SELECT
        job_id
        , company_id
        , job_title
        , job_title_short
        , job_posted_date
        , salary_year_avg
        , LAG(salary_year_avg) OVER (
            PARTITION BY company_id
            ORDER BY job_posted_date
        ) AS previous_posting_salary
        , salary_year_avg - LAG(salary_year_avg) OVER (
            PARTITION BY company_id
            ORDER BY job_posted_date
        ) AS salary_change
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    ORDER BY company_id, job_posted_date
    LIMIT 60
)
SELECT *
FROM previous_current_salary
WHERE salary_change IS NOT NULL;

-- LEAD() - sees next record
WITH current_next_salary AS (
    SELECT
        job_id
        , company_id
        , job_title
        , job_title_short
        , job_posted_date
        , salary_year_avg
        , LEAD(salary_year_avg) OVER (
            PARTITION BY company_id
            ORDER BY job_posted_date
        ) AS next_posting_salary
        , LEAD(salary_year_avg) OVER (
            PARTITION BY company_id
            ORDER BY job_posted_date
        ) - salary_year_avg AS salary_change
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    ORDER BY company_id, job_posted_date
    LIMIT 60
)
SELECT *
FROM current_next_salary
WHERE salary_change IS NOT NULL;