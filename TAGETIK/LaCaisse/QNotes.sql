----------  OLD  -------------
SELECT DISTINCT ENTITY||
    COST_CENTER||
    ACCOUNT||
    T_ENTITY||
    T_COST_CENTER||
    T_ACCOUNT    K,
    NOTES
FROM  ${DATASETPARTITION("P01","000007",PROCESS($Scenario.code, $Period.code).code)} A
WHERE NOTES IS NOT NULL


----------  NEW  -------------

SELECT 
    DISTINCT ENTITY || '_' || ACCOUNT || '_' || COST_CENTER || '_' || FOURNISSEUR || '_' || SNA || '_' || PROJECT || '_' || T_ENTITY || '_' || T_ACCOUNT || '_' || T_COST_CENTER || '_' || T_FOURNISSEUR || '_' || T_SNA || '_' || T_PROJECT || '_' || CURRENCY  AS CONCAT_COLUMN,
    NOTES
FROM  ${DATASETPARTITION("P03","000007",PROCESS($Scenario.code, $Period.code).code)} A
WHERE NOTES IS NOT NULL
AND   SCENARIO = ${$Scenario.code}
AND  PERIOD IN (${$Scenario.attribute1} )
AND   ENTITY IN (${$Entity.code})
AND   COST_CENTER IN (${$Cust_dim2.code})


----------  NEW  -------------

SELECT 
    DISTINCT ENTITY || '_' || ACCOUNT || '_' || COST_CENTER || '_' || FOURNISSEUR || '_' || SNA || '_' || PROJECT || '_' || T_ENTITY || '_' || T_ACCOUNT || '_' || T_COST_CENTER || '_' || T_FOURNISSEUR || '_' || T_PROJECT || '_' || T_SNA || '_' || CURRENCY  AS CONCAT_COLUMN,
    NOTES
FROM  ${DATASETPARTITION("P03","000007",PROCESS($Scenario.code, $Scenario.attribute1).code)} A
WHERE NOTES IS NOT NULL
AND   SCENARIO = ${$Scenario.code}
AND   PERIOD = ${$Scenario.attribute1}
AND   ENTITY IN (${$Entity.code})
AND   COST_CENTER IN (${$Cust_dim2.code})
AND   TEXT_ORIGIN = '000200'