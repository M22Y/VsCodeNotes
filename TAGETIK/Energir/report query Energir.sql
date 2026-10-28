SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.code,"02").code, $Scenario.code, "02",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
UNION ALL
SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.code,"01").code, $Scenario.code, "01",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
UNION ALL
SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.prev.code,"12").code, $Scenario.prev.code, "12",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
UNION ALL
SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.prev.code,"11").code, $Scenario.prev.code, "11",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
UNION ALL
SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.prev.code,"10").code, $Scenario.prev.code, "10",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
UNION ALL
SELECT * FROM ${DATASETPARTITION("002", "CYT001", PROCESS($Scenario.prev.code,"09").code, $Scenario.prev.code, "09",,,)} 
WHERE TGK_COD_AZIENDA= ${$Entity.code}
AND TGK_COD_CONTO like '330%'
