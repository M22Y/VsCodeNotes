/*Load Conso*/
/******************************* REQ 4 : dati_rett_riga_cons_3 ***************************/
SELECT 
'Consolidated Journal Rows' AS Source_Table,
'Entity/Consolidation Journal Rows - Consolidable' AS Amount_Type,
${$Scenario.code}  As Scenario,
D.COD_PERIODO As Period,
D.NUM_RETTIFICA As Journal_Number,
D.COD_AZIENDA As Division,
D.COD_CONTO As Account_Code,
C.DESC_CONTO0 As Account_Description,
D.COD_DEST1 As Custom_Dim_1,
D.COD_DEST2 As Custom_Dim_2,
D.COD_DEST3 As Custom_Dim_3,
D.COD_DEST4 As Custom_Dim_4,
D.COD_DEST5 As Custom_Dim_5,
D.COD_CATEGORIA As Category,
D.COD_AZI_CTP As CTP_Division,
D.COD_DEST2_CTP As Costum_Dim2_CTP,
D.COD_AZI_CTP_SEGMENT as Division_CTP_SEGMENT,
D.COD_DEST2_CTP_SEGMENT as Costum_Dim2_CTP_SEGMENT,
D.COD_VALUTA As Currency,
D.IMPORTO As Amount,
D.COD_VALUTA2 As Currency2,
D.IMPORTO2 As Amount2,
D.NOTE,
D.NUM_EVENTO As Event_Number
FROM dati_rett_riga_cons_3 D
INNER JOIN CONTO C
    ON C.COD_CONTO = D.COD_CONTO
WHERE D.COD_SCENARIO = LEFT(${$Scenario.code}, LEN(${$Scenario.code}) - 1)
  AND D.COD_AZIENDA  IN (${$ENTITY.CODE})
  AND D.COD_CATEGORIA IN (SELECT COD_CATEGORIA FROM V_CATEGORIA_FLAT WHERE L2='C999')
  AND D.COD_CONTO  IN (SELECT DISTINCT COD_CONTO FROM CONTO_GERARCHIA_ABBI WHERE COD_CONTO_GERARCHIA IN ('001', '003', '004'))
UNION ALL
/******************************* REQ 7 : dati_saldi_cons_3 ***************************/
SELECT 
'Consolidation Table 3' AS Source_Table,
'Consolidated Amounts - Consolidable' AS Amount_Type,
${$Scenario.code}  As Scenario,
D.COD_PERIODO As Period,
NULL As Journal_Number,
D.COD_AZIENDA As Division,
D.COD_CONTO As Account_Code,
C.DESC_CONTO0 As Account_Description,
D.COD_DEST1 As Custom_Dim_1,
D.COD_DEST2 As Custom_Dim_2,
D.COD_DEST3 As Custom_Dim_3,
D.COD_DEST4 As Custom_Dim_4,
D.COD_DEST5 As Custom_Dim_5,
D.COD_CATEGORIA As Category,
D.COD_AZI_CTP As CTP_Division,
D.COD_DEST2_CTP As Costum_Dim2_CTP,
NULL as Division_CTP_SEGMENT,
NULL as Costum_Dim2_CTP_SEGMENT,
D.COD_VALUTA As Currency,
D.IMPORTO As Amount,
NULL As Currency2,
NULL As Amount2,
D.NOTE,
NULL As Event_Number
FROM dati_saldi_cons_3 D
INNER JOIN CONTO C
    ON C.COD_CONTO = D.COD_CONTO
WHERE D.COD_SCENARIO = LEFT(${$Scenario.code}, LEN(${$Scenario.code}) - 1)
  AND D.COD_AZIENDA  IN (${$ENTITY.CODE})
  AND D.COD_CATEGORIA IN (SELECT COD_CATEGORIA FROM V_CATEGORIA_FLAT WHERE L2='C999')
  AND D.COD_CONTO  IN (SELECT DISTINCT COD_CONTO FROM CONTO_GERARCHIA_ABBI WHERE COD_CONTO_GERARCHIA IN ('001', '003', '004'))