
SELECT COD_VALUTA,CAMBIO_MEDIO
FROM DATI_CAMBIO
WHERE COD_SCENARIO= ${$Scenario.code}
AND COD_PERIODO ='12'

------------OLD QUERY---------
SELECT  COD_AZIENDA || '_' || COD_CONTO || '_' || COD_DEST2 AS CONCAT_COLUMN
,
    COD_AZIENDA, 
    COD_CONTO, 
    COD_DEST2, 
    SUM(IMPORTO) TOT,
    COD_VALUTA 
FROM    V_DATI_SALDI
WHERE   COD_PERIODO ='12'
AND     COD_SCENARIO= ${$Scenario.code}
AND     COD_CATEGORIA IN (
                SELECT COD_CATEGORIA
                FROM categoria_gerarchia_abbim
            WHERE   (
                COD_CATEGORIA_ELEGER ='PLAN_FW'
                )
            OR  (   
                COD_CATEGORIA_ELEGER LIKE 'GR_P%'
                AND RIGHT(COD_CATEGORIA_ELEGER,2) < ${$Scenario.attribute1}
                )
            )
GROUP BY COD_AZIENDA || '_' || COD_CONTO || '_' || COD_DEST2,

    COD_AZIENDA, 
    COD_CONTO, 
    COD_DEST2, 
    COD_VALUTA


-----------NEW QUERY----------

SELECT 
  COD_AZIENDA AS ENTITY, 
  COD_CONTO AS ACCOUNT, 
  COD_DEST2 AS COST_CENTERS, 
  COD_DEST5 AS SUPPLIER, 
  COD_DEST1 AS SNA,
  COD_DEST3 AS PROJECT,
  COD_AZIENDA || '_' || COD_CONTO || '_' || COD_DEST2 || '_' || COD_DEST5 || '_' || COD_DEST1 || '_' || COD_DEST3 || '_' || COD_VALUTA AS CONCAT_COLUMN,
  COD_VALUTA AS CURRENCY,
  SUM(IMPORTO) TOT
FROM  V_DATI_SALDI
WHERE  COD_PERIODO ='12'
AND   COD_SCENARIO = ${$Scenario.code}
AND  COD_AZIENDA IN (${$Entity.code})
AND   COD_DEST2 IN (${$Cust_dim2.code})
AND   COD_DEST5 IN (${$Cust_dim5.code})
AND   COD_DEST1 IN (${$Cust_dim1.code})
AND   COD_DEST3 IN (${$Cust_dim3.code})
AND   COD_CATEGORIA IN (
        SELECT COD_CATEGORIA
        FROM categoria_gerarchia_abbim
      WHERE  (
        COD_CATEGORIA_ELEGER ='PLAN_FW'
        )
      OR (  
        COD_CATEGORIA_ELEGER LIKE 'GR_P%'
        AND RIGHT(COD_CATEGORIA_ELEGER,2) < ${$Scenario.attribute1}
        )
      )
GROUP BY COD_AZIENDA || '_' || COD_CONTO || '_' || COD_DEST2 || '_' || COD_DEST5 || '_' || COD_DEST1 || '_' || COD_DEST3 || '_' || COD_VALUTA,
  COD_AZIENDA, 
  COD_CONTO, 
  COD_DEST2,
  COD_DEST5, 
  COD_DEST1, 
  COD_DEST3, 
  COD_VALUTA


