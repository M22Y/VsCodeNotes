/*RG - Added three new dimensions and changed AW code from P01 to P03*/
SELECT  SCENARIO,
        PERIOD,
        ENTITY,
        ACCOUNT,
        COST_CENTER,
	    FOURNISSEUR,
	    PROJECT,
	    SNA,
        (
            SELECT cod_categoria 
            FROM categoria 
            WHERE cod_categoria LIKE 'TRF_BUD%'
            AND RIGHT(cod_categoria,2) IN (${$Scenario.attribute1})
        ) AS CATEGORY,
        CTP_ENTITY,
        CTP_COST_CENTER,
	    CTP_FOURNISSEUR,
        CTP_PROJECT,
	    CTP_SNA,
        CURRENCY,
        AMOUNT,
        CURRENCY_TRANS,
        AMOUNT_TRANS,		
        NOTES, 
        NUM_ECR,
        SOURCE_ENTITY
FROM
(
    SELECT  SCENARIO,
            SP.COD_PERIODO AS PERIOD,
            ENTITY,
            ACCOUNT,
            COST_CENTER,
	        FOURNISSEUR,
	        PROJECT,
	        SNA,
            T_ENTITY AS CTP_ENTITY,
            T_COST_CENTER AS CTP_COST_CENTER,			
	        T_FOURNISSEUR AS CTP_FOURNISSEUR,
	        T_PROJECT AS CTP_PROJECT,
	        T_SNA AS CTP_SNA,			
            CURRENCY,
			CURRENCY_TRANS,
            SUM(AMOUNT) AS AMOUNT,
			SUM(AMOUNT_TRANS) AS AMOUNT_TRANS,
            NOTES, 
            NUM_ECR,
            SOURCE_ENTITY
    FROM ${DATASETPARTITION("P03","000007",PROCESS($Scenario.item(0).code,"12").code)}  A
    JOIN    SCENARIO_PERIODO SP
        ON  SP.COD_SCENARIO = A.SCENARIO
        AND SP.COD_PERIODO >= A.PERIOD
    WHERE   TEXT_ORIGIN = '000220'
            AND CATEGORY LIKE 'TRF_BUD%'
            AND RIGHT(CATEGORY,2) IN (${$Scenario.attribute1})
    GROUP BY SCENARIO,
            SP.COD_PERIODO,
            ENTITY,
            ACCOUNT,
            COST_CENTER,
	        FOURNISSEUR,
	        PROJECT,
	        SNA,
            T_ENTITY,
            T_COST_CENTER,
	        T_FOURNISSEUR,
	        T_PROJECT,
	        T_SNA,
            CURRENCY,
			CURRENCY_TRANS,
            NOTES, 
            NUM_ECR,
            MOV_TYPE,
            SOURCE_ENTITY
) B