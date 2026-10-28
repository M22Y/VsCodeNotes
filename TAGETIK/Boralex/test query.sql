/*
Special method : Load to Financial workspace and conversion MTD to YTD
Description : Load data from a partition to DATI_SALDI_LORDI for a specific Entity
Updated : TJE 2026-07-31
*/
 
---------- Deletion Part ---------------
----------------------------------
------Step 1 : Delete 
----------------------------------
 
DELETE FROM DATI_SALDI_LORDI
WHERE COD_SCENARIO = ${$Scenario.code}
AND COD_DEST1 IN (
    ${$Cust_Dim1.code}
 
)
AND PROVENIENZA = &ORIGIN&;
 
 
------------ Insertion and Select ------------------
----------------------------------
---- Step 2: Generate all fiscal periods (01-12) used to created missing periods when source data is incomplete.
----------------------------------
WITH PERIODS AS (
 
    SELECT '01' AS COD_PERIODO
    UNION ALL SELECT '02'
    UNION ALL SELECT '03'
    UNION ALL SELECT '04'
    UNION ALL SELECT '05'
    UNION ALL SELECT '06'
    UNION ALL SELECT '07'
    UNION ALL SELECT '08'
    UNION ALL SELECT '09'
    UNION ALL SELECT '10'
    UNION ALL SELECT '11'
    UNION ALL SELECT '12'
 
),
 
----------------------------------
---- Step 3 : Aggregate source data at the target grain to prevent duplicates and ensure correct YTD calculation
----------------------------------
 
SOURCE_AGG AS (
 
    SELECT
&SCENARIO&             AS SCENARIO,
&PERIOD&               AS PERIOD,
&ENTITY&               AS ENTITY,
&ACCOUNT&              AS ACCOUNT,
&COD_DEST1&            AS DEST1,
&COD_DEST2&            AS DEST2,
&COD_DEST3&            AS DEST3,
&COD_DEST4&            AS DEST4,
&COD_DEST5&            AS DEST5,
&CATEGORY&             AS CATEGORY,
&CURRENCY&             AS CURRENCY,
&CURRENCY_TRANSAC&     AS CURRENCY_TRANSAC,
        SUM(&IMPORTO&)         AS IMPORTO_MTD,
        SUM(&IMPORTO_VALUTA_ORIGINARIA&) AS IMPORTO_VALUTA_ORIGINARIA_MTD
 
    FROM &SOURCE_TABLE&
WHERE &COD_DEST1& IN ( ${$Cust_Dim1.code} )
    GROUP BY
&SCENARIO&,
&PERIOD&,
&ENTITY&,
&ACCOUNT&,
&COD_DEST1&,
&COD_DEST2&,
&COD_DEST3&,
&COD_DEST4&,
&COD_DEST5&,
&CATEGORY&,
&CURRENCY&,
&CURRENCY_TRANSAC&
 
 
),
 
 
----------------------------------
--- Step 4 : Extract unique dimensional combinations from the source data independently of the period
----------------------------------
 
 
BASE_COMBINATIONS AS (
 
    SELECT DISTINCT
        SCENARIO,
        ENTITY,
        ACCOUNT,
        DEST1,
        DEST2,
        DEST3,
        DEST4,
        DEST5,
        CATEGORY,
        CURRENCY,
        CURRENCY_TRANSAC
 
    FROM SOURCE_AGG
WHERE &COD_DEST1& IN ( ${$Cust_Dim1.code} )
),
----------------------------------
-- Step 5 : Generate a full 12 period calendar for each  dimensional combinations
----------------------------------
EXPANDED AS (
 
    SELECT
        B.SCENARIO,
        P.COD_PERIODO,
        B.ENTITY,
        B.ACCOUNT,
        B.DEST1,
        B.DEST2,
        B.DEST3,
        B.DEST4,
        B.DEST5,
        B.CATEGORY,
        B.CURRENCY,
        B.CURRENCY_TRANSAC
 
    FROM BASE_COMBINATIONS B
    CROSS JOIN PERIODS P
 
),
----------------------------------
-- Step 6 : Reattach source amounts to the  generated periods and calculate running YTD
----------------------------------
YTD_DATA AS (
 
    SELECT
        E.SCENARIO,
        E.COD_PERIODO,
        E.ENTITY,
        E.ACCOUNT,
        E.DEST1,
        E.DEST2,
        E.DEST3,
        E.DEST4,
        E.DEST5,
        E.CATEGORY,
        E.CURRENCY,
        E.CURRENCY_TRANSAC,
 
        SUM(COALESCE(S.IMPORTO_MTD, 0)) OVER (
            PARTITION BY
                E.SCENARIO,
                E.ENTITY,
                E.CATEGORY,
                E.DEST1,
                E.DEST2,
                E.DEST3,
                E.DEST4,
                E.DEST5,
                E.ACCOUNT,
                E.CURRENCY
            ORDER BY E.COD_PERIODO
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS IMPORTO_YTD,
 
        SUM(COALESCE(S.IMPORTO_VALUTA_ORIGINARIA_MTD, 0)) OVER (
            PARTITION BY
                E.SCENARIO,
                E.ENTITY,
                E.CATEGORY,
                E.DEST1,
                E.DEST2,
                E.DEST3,
                E.DEST4,
                E.DEST5,
                E.ACCOUNT,
                E.CURRENCY
            ORDER BY E.COD_PERIODO
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS IMPORTO_VALUTA_ORIGINARIA_YTD
 
    FROM EXPANDED E
 
    LEFT JOIN SOURCE_AGG S
        ON E.SCENARIO     = S.SCENARIO
       AND E.COD_PERIODO  = S.PERIOD
       AND E.ENTITY       = S.ENTITY
       AND E.ACCOUNT      = S.ACCOUNT
       AND E.CATEGORY     = S.CATEGORY
       AND E.DEST1        = S.DEST1
       AND E.DEST2        = S.DEST2
       AND E.DEST3        = S.DEST3
       AND E.DEST4        = S.DEST4
       AND E.DEST5        = S.DEST5
       AND E.CURRENCY     = S.CURRENCY
 
)
 
--------------------------------------------------
-- Step 7 : Load final YTD dataset into  DATI_SALDI_LORDI
--------------------------------------------------
 
INSERT INTO DATI_SALDI_LORDI (
    OID_DATI_SALDI_LORDI,
    COD_SCENARIO,
    COD_PERIODO,
    COD_AZIENDA,
    COD_CONTO,
    COD_DEST1,
    COD_DEST2,
    COD_DEST3,
    COD_DEST4,
    COD_DEST5,
    COD_CATEGORIA,
    IMPORTO,
    COD_VALUTA,
    IMPORTO_VALUTA_ORIGINARIA,
    COD_VALUTA_ORIGINARIA,
    PROVENIENZA,
    USERUPD,
    DATEUPD
)
 
SELECT
    uuid_generate_v1() AS OID_DATI_SALDI_LORDI,
    SCENARIO AS COD_SCENARIO,
    COD_PERIODO AS COD_PERIODO,
    ENTITY AS COD_AZIENDA,
    ACCOUNT AS COD_CONTO,
    DEST1 AS COD_DEST1,
    DEST2 AS COD_DEST2,
    DEST3 AS COD_DEST3,
    DEST4 AS COD_DEST4,
    DEST5 AS COD_DEST5,
    CATEGORY AS COD_CATEGORIA,
    IMPORTO_YTD AS IMPORTO,
    CURRENCY AS COD_VALUTA,
    IMPORTO_VALUTA_ORIGINARIA_YTD AS IMPORTO_VALUTA_ORIGINARIA,
    CURRENCY_TRANSAC AS COD_VALUTA_ORIGINARIA,
&ORIGIN& AS PROVENIENZA,
    '#USER#' AS USERUPD,
    NOW() AS DATEUPD
 
FROM YTD_DATA
WHERE
 
IMPORTO_VALUTA_ORIGINARIA_YTD <> 0
 
AND DEST1 IN ( ${$Cust_Dim1.code} )
 
 
;
 
 
/*Example of how the YTD calculation works when source data is incomplete.*/
-- Missing periods are generated using a CROSS JOIN between all dimensional combinations and the fiscal calendar (01-12).
--
-- A LEFT JOIN is then used to preserve generated  periods even when no source record exists.
--
-- This ensures:
--
-- Source:
-- 01 = 100
-- 02 = 50
-- 05 = 25
--
-- Result:
-- 01 = 100
-- 02 = 150
-- 03 = 150
-- 04 = 150
-- 05 = 175
-- ...
-- 12 = 175
 
/*END*/