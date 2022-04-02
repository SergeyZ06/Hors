-- Initial CTE is to provide usable representation.
WITH t1 AS (
	SELECT DISTINCT
			 o.client_id
			,DATEPART(month, o.purchase_date) AS month
			,DATEPART(year, o.purchase_date) AS year
		FROM Orders AS o
	),

-- Second CTE is to ranking by date.
t2 AS (
	SELECT
			 t1.client_id
			,t1.month
			,t1.year
			,ROW_NUMBER() OVER(PARTITION BY t1.client_id ORDER BY t1.year, t1.month ASC) AS rn
		FROM t1
	)

-- Main query with only newest trade points.
SELECT
		 t2.client_id
		,t2.month
		,t2.year
	FROM t2
	WHERE t2.rn = 1;

/**
-- Main query with only newest trade points.
SELECT TOP 1 WITH TIES
		 t2.client_id
		,t2.month
		,t2.year
	FROM t2
	ORDER BY t2.rn;
**/
