-- CTE для формирования хеш-имени и "чистого" адреса.
WITH t1 AS (
    SELECT
        o.`Торг_точка_грязная` AS name, 
        LOWER(REPLACE(REPLACE(REPLACE(REPLACE(o.`Торг_точка_грязная`, ' ', ''), '.', ''), ',', ''), '"', '')) AS name_hash,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(o.`Торг_точка_грязная_адрес`, '-', ''), 'он же', ''), '--------------------------------------', ''), 'самовывоз', ''), '0', ''), '1', ''), 'ба', ''), 'б/а', ''), 'Ж', ''), 'БА', ''), 'Б/А', '') AS address_clear
    FROM
        outlets AS o
    ),

-- CTE: если после фильтрации адрес пустой (т.е. адрес содержал только мусор), то присвоить NULL.
t2 AS (
    SELECT
        t1.name,
        t1.name_hash,
        IIF(t1.address_clear = '', NULL, t1.address_clear) AS address_clear
    FROM
        t1
    ),

-- CTE для формирования списка адресов для каждой торговой точки.
t3 AS (
    SELECT
        t2.name,
        --t2.name_hash,
        --t2.address_dirty,
        GROUP_CONCAT(t2.address_clear, '|') OVER(PARTITION BY t2.name_hash) AS list_addresses
    FROM
        t2
    )

-- Вставка соответствующего outlet_clean_id для каждой торговой точки, где сформированный список адресов совпадает с списком адресов из таблицы "outlets_clean".
UPDATE outlets
SET outlet_clean_id = (SELECT oc.id FROM outlets_clean AS oc WHERE oc.`Торг_точка_чистый_адрес` = (SELECT t3.list_addresses FROM t3 WHERE t3.name = `Торг_точка_грязная`));
