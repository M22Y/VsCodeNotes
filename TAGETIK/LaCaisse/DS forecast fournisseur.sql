/*
Datasource : 000006 - DS001 - Previous Budget (last adjusted) for Forecast
Description : load adjusted budget from V_DATI_SALDI for the forecast, adjusted to the last transfer period (Category) and cumulated P12 YTD (annual), $scenario is controlled REF2 and $Entity by the process
changelog : 
24-03-2026 - Youssef M. - Initial version 
  - Youssef M. - using  V_DATI_SALDI_FULL instead of  V_DATI_SALDI
*/

SELECT 
  COD_SCENARIO AS SCENARIO,
  COD_PERIODO AS PERIOD,
  COD_AZIENDA AS ENTITY, 
  COD_CONTO AS ACCOUNT, 
  COD_DEST2 AS COST_CENTER, 
  COD_DEST5 AS SUPPLIER, 
  COD_DEST1 AS SNA,
  COD_DEST3 AS PROJECT,
  COD_VALUTA2 AS CURRENCY,
  SUM(IMPORTO2) BUDGET
FROM   V_DATI_SALDI
WHERE  COD_PERIODO ='12'
AND   COD_SCENARIO = ${$Scenario.ref2.code}
AND  COD_AZIENDA IN (${$Entity.code})
AND   COD_CATEGORIA IN (
        SELECT COD_CATEGORIA
        FROM categoria_gerarchia_abbim
      WHERE  (
        COD_CATEGORIA_ELEGER ='PLAN_FW'
        )
      OR (  
        COD_CATEGORIA_ELEGER LIKE 'GR_P%'
        AND RIGHT(COD_CATEGORIA_ELEGER,2) <= ${$Scenario.ref2.attribute1}
        )
      )
GROUP BY
  COD_SCENARIO,
  COD_PERIODO,
  COD_AZIENDA, 
  COD_CONTO, 
  COD_DEST2,
  COD_DEST5, 
  COD_DEST1, 
  COD_DEST3, 
  COD_VALUTA2
