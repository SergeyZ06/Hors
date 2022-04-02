-- Initial CTE is to provide usable representation.
WITH t1 AS (
	SELECT DISTINCT
			 o.client_id
			,DATEPART(month, o.purchase_date) AS month
			,DATEPART(year, o.purchase_date) AS year
		FROM Orders AS o
	),

-- Second CTE is to define previous date.
t2 AS (
	SELECT
			 t1.client_id
			,t1.month
			,t1.year
			,LAG(t1.month) OVER(PARTITION BY t1.client_id ORDER BY t1.year, t1.month ASC) AS month_lag
			,LAG(t1.year) OVER(PARTITION BY t1.client_id ORDER BY t1.year, t1.month ASC) AS year_lag
		FROM t1
	)

-- Main query with only that points which had previous month activity.
SELECT
		 t2.client_id
		,t2.month
		,t2.year
	FROM t2
	WHERE
		(t2.year = t2.year_lag AND t2.month = t2.month_lag + 1)
		OR (t2.year = t2.year_lag + 1 AND t2.month = 1 AND t2.month_lag = 12);
