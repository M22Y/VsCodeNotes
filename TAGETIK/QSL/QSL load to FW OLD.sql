/*  
Special method : Load to Financial workspace
Description : Load data from a partition to Dati_Saldi_Lordi for a specific Entity/Division contexte
Updated : Youssef. M - 23-03-2026

*/


DELETE FROM DATI_SALDI_LORDI
WHERE COD_SCENARIO = ${$Scenario.code}
AND COD_DEST2 IN (SELECT DISTINCT DIVISION FROM #TARGET_PARTITION#)
AND COD_AZIENDA IN (SELECT DISTINCT ENTITY FROM #TARGET_PARTITION#)
AND PROVENIENZA = 'QDL';
 
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
  uuid_generate_v1()                                                   AS OID_DATI_SALDI_LORDI,
  SCENARIO                                 AS COD_SCENARIO,
  PERIOD                                   AS COD_PERIODO,
  ENTITY                                   AS COD_AZIENDA,
  ACCOUNT                                  AS COD_CONTO,
  'NA'                                     AS COD_DEST1,
  DIVISION                                 AS COD_DEST2,
  PRODUCT                                  AS COD_DEST3,
  CUSTOMER                                 AS COD_DEST4,
  'NA'                                     AS COD_DEST5,
  CATEGORY                                 AS COD_CATEGORIA,
  SUM(VALUE_DOLLARS) OVER (
    PARTITION BY SCENARIO, ENTITY, CATEGORY, DIVISION, ACCOUNT, CURRENCY, CUSTOMER, PRODUCT
    ORDER BY PERIOD
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )                                        AS IMPORTO,
  CURRENCY                                 AS COD_VALUTA,
  SUM(VALUE_DOLLARS) OVER (
    PARTITION BY SCENARIO, ENTITY, CATEGORY, DIVISION, ACCOUNT, CURRENCY, CUSTOMER, PRODUCT
    ORDER BY PERIOD
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  )                                        AS IMPORTO_VALUTA_ORIGINARIA,
  CURRENCY                                 AS COD_VALUTA_ORIGINARIA,
  'QDL'                                    AS PROVENIENZA,
  USERUPD                                  AS USERUPD,
  DATEUPD                                  AS DATEUPD
FROM #TARGET_PARTITION#;