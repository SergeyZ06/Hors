-- Initial CTE is to provide usable representation.
WITH t1 AS (
	SELECT DISTINCT
			 o.client_id
			,DATEPART(month, o.purchase_date) AS month
			,DATEPART(year, o.purchase_date) AS year
		FROM Orders AS o
	),

-- Second CTE is to define next date.
t2 AS (
	SELECT
			 t1.client_id
			,t1.month
			,t1.year
			,LEAD(t1.month) OVER(PARTITION BY t1.client_id ORDER BY t1.year, t1.month ASC) AS month_lead
			,LEAD(t1.year) OVER(PARTITION BY t1.client_id ORDER BY t1.year, t1.month ASC) AS year_lead
		FROM t1
	),

-- Third CTE is to define next month unactive points.
t3 AS (
	SELECT *
		FROM t2
		WHERE
			t2.month_lead IS NULL
			OR (t2.year = t2.year_lead AND t2.month <> t2.month_lead - 1)
			OR (t2.year = t2.year_lead - 1 AND (t2.month <> 12 OR t2.month_lead <> 1))
	)

SELECT
		 t3.client_id
		,IIF(t3.month = 12, 1, t3.month + 1) AS month
		,IIF(t3.month = 12, t3.year + 1, t3.year) AS year
	FROM t3;
