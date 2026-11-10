SELECT 
TB1 AS "Scenario",
TB2 AS "Period",
TB3 AS "Entity",
TB4 AS "Local GL",
TB5 AS "Local GL Desc",
TB6 AS "Tagetik Account",
CAST(TB9 AS NUMERIC (27,2)) AS "Amount in Entity Currency",
TB7 AS "Currency",
TB8 AS "Category",
dateupd,
userupd,
provenienza AS "Origin"

FROM ${DATASETPARTITION("001","000001","CONSOLIDATION",$Scenario.code,"01")}
WHERE TB6 = ${$Account(HIERARCHY("010")).code}
AND TB1 = ${$Scenario.code}
AND TB3 = ${$Entity.code}


SELECT 
TB1 AS "Scenario",
TB2 AS "Period",
TB3 AS "Entity",
TB4 AS "Local GL",
TB5 AS "Local GL Desc",
TB6 AS "Tagetik Account",
CAST(TB9 AS NUMERIC (27,2)) AS "Amount in Entity Currency",
TB7 AS "Currency",
TB8 AS "Category"

FROM ${DATASETPARTITION("001","000001","CONSOLIDATION",$Scenario.code,$Period.code)}
WHERE EXISTS (SELECT DISTINCT COD_RACCOLTA,COD_SCENARIO,COD_PERIODO FROM ows_tabella_partizione WHERE COD_SCENARIO = ${$Scenario.code} AND COD_PERIODO = ${$Period.code})
AND TB6 = ${$Account(HIERARCHY("010")).code}
AND TB1 = ${$Scenario.code}
AND TB2 = ${$Period.code}





