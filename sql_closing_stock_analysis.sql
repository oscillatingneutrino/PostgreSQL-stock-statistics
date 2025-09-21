/*
This code will give back the returns based on closing measurements,
mean, trimmed mean, median, mean absolute deviation, median absolute deviation, standard deviation 
*/

/*--------------------------------------------------------------------------------------------------------------------*/
WITH cter AS (
SELECT date, company,
/* This gives the returns; rfc = returns from closing */
/* yesterday is closing stock price from the day prior. This is not used at all later on */

	close - LAG(close,1) OVER (PARTITION BY company ORDER BY date) AS rfc
	
--	LAG(close,1) OVER (PARTITION BY company ORDER BY date) AS yesterday

FROM stocks_data
),
/*--------------------------------------------------------------------------------------------------------------------*/


/*--------------------------------------------------------------------------------------------------------------------*/
menmed AS (
/* This code calculates the mean, the median using percentile_cont, and the standard deviation using STDDEV_SAMP */
	SELECT
		company,
		ROUND(AVG(rfc),5) AS mean,
		--numeric here makes this go from double precision --> numeric
		ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rfc)::numeric,5) AS median,
		ROUND(STDDEV_SAMP(rfc),5) AS standard_dev
		
FROM cter
WHERE rfc IS NOT NULL
GROUP BY company
),
/*--------------------------------------------------------------------------------------------------------------------*/

trimm AS (
/* This code gets the trimmed mean. Trim bottom and top 1% */
	SELECT
		company,
		ROUND(AVG(rfc),5) AS trimm_mean
	FROM (
		SELECT
			company,
			rfc,
			CUME_DIST() OVER (PARTITION BY company ORDER BY rfc) AS cume
		FROM cter
		WHERE rfc IS NOT NULL
	) t

WHERE cume BETWEEN 0.01 and 0.99
	
GROUP BY company
),

/*--------------------------------------------------------------------------------------------------------------------*/
mean_madcow AS (
/* This cte gets the mean absolute deviation */
	SELECT
		c.company,
		ROUND(AVG(ABS(c.rfc-m.mean)),5) AS mean_MAD
	FROM menmed m
JOIN cter c
	ON c.company = m.company
GROUP BY c.company
),

median_madcow AS (
/* This cte gets the median absolute deviation */
	SELECT
		c.company,
		ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ABS(c.rfc - m.median))::numeric,5) AS median_MAD
	FROM menmed m
JOIN cter c
	ON c.company = m.company
GROUP BY c.company
)
/*--------------------------------------------------------------------------------------------------------------------*/

SELECT
	m.company,
	m.mean,
	t.trimm_mean,
	mea.mean_MAD,
	m.median,
	med.median_MAD,
	m.standard_dev
FROM menmed m
JOIN trimm t
	ON m.company = t.company
JOIN mean_madcow mea
	ON mea.company = m.company
JOIN median_madcow med
	ON med.company = m.company;
