/*
Datasource : 000007 - DS002 - Previous Budget (last adjusted extrapolated) for Budget
Description : load adjusted budget from V_DATI_SALDI for the Budget, adjusted to the last transfer period (Category) and cumulated P12 YTD (annual), $scenario is controlled REF2 and $Entity by the process
changelog : 24-03-2026 - Youssef M. - Initial version 
*/
WITH BUDGET_ADJUSTED AS (
SELECT 
  COD_SCENARIO AS SCENARIO,
  '12' AS PERIOD,
  COD_AZIENDA AS ENTITY, 
  COD_CONTO AS ACCOUNT, 
  COD_DEST2 AS COST_CENTER, 
  COD_DEST5 AS SUPPLIER, 
  COD_DEST1 AS SNA,
  COD_DEST3 AS PROJECT,
  COD_VALUTA2 AS CURRENCY,
  SUM(IMPORTO2) BUDGET_PY
FROM  V_DATI_SALDI_FULL_MENSILI
WHERE  COD_PERIODO >= ${$Scenario.prev.attribute1}
AND   COD_SCENARIO = ${$Scenario.prev.code}
AND  COD_AZIENDA IN (${$Entity.code})
AND   COD_CATEGORIA IN (
        SELECT COD_CATEGORIA
        FROM categoria_gerarchia_abbim
      WHERE  (
        COD_CATEGORIA_ELEGER ='PLAN_FW'
        )
      OR (  
        COD_CATEGORIA_ELEGER LIKE 'GR_P%'
        AND RIGHT(COD_CATEGORIA_ELEGER,2) <= ${$Scenario.prev.attribute1}
        )
      )
GROUP BY
  COD_SCENARIO,
  COD_AZIENDA, 
  COD_CONTO, 
  COD_DEST2,
  COD_DEST5, 
  COD_DEST1, 
  COD_DEST3, 
  COD_VALUTA2
) 

SELECT
  BA.SCENARIO,
  BA.PERIOD,
  BA.ENTITY, 
  BA.ACCOUNT, 
  BA.COST_CENTER, 
  BA.SUPPLIER, 
  BA.SNA,
  BA.PROJECT,
  BA.CURRENCY,
  (SUM(BA.BUDGET_PY)/(12-${$Scenario.prev.attribute1}+1))*12 AS BUDGET_PY
FROM BUDGET_ADJUSTED AS BA
GROUP BY
  BA.SCENARIO,
  BA.PERIOD,
  BA.ENTITY, 
  BA.ACCOUNT, 
  BA.COST_CENTER, 
  BA.SUPPLIER, 
  BA.SNA,
  BA.PROJECT,
  BA.CURRENCY
