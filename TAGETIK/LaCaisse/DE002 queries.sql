code($Entity)+"_"+code($Account)+"_"+code($Cust_Dim2)+"_"+code($Cust_Dim5)+"_"+code($Cust_Dim1)+"_"+code($Cust_Dim3)+"_"+code($ANL_ENTITY_MIR)+"_"+code($ANL_ACCOUNT_MIR)+"_"+code($ANL_CC_MIR)+"_"+code($ANL_SUPPLIER)+"_"+code($ANL_PROJECT)+"_"+code($ANL_SNA)+"_"+code($Currency)
code($Entity)+"_"+code($Account)+"_"+code($Cust_Dim2)+"_"+code($Cust_Dim5)+"_"+code($Cust_Dim1)+"_"+code($Cust_Dim3)+"_"+code($Currency)


COD_AZIENDA || '_' || COD_CONTO || '_' || COD_DEST2 || '_' || COD_DEST5 || '_' || COD_DEST1 || '_' || COD_DEST3 || '_' || COD_VALUTA || '_' || COD_PERIODO AS CONCAT_COLUMN,

-- OLD --
IFERROR(VLOOKUP(CONCAT({31}, "_01"), BUDGET_LIMIT_LOOKUP, 6, FALSE)/{33}, 0)
-- NEW --
IFERROR(VLOOKUP(CONCAT({30}, "_01"), BUDGET_LIMIT_LOOKUP, 4, FALSE), 0)


TGKML 1.0
result := this.GETLEAF($Period.code) ;
Annual Amount (Devise de transaction);Annual Amount (transaction currency);;

$Scenario.attribute1

TGKML 1.0
result := this.GETLEAF($Period.code) ;


TGKML 1.0

result := this.GETLEAF("TRF_BUD_P"+$Scenario.attribute1);

code($Entity)+"_"+code($Account)+"_"+code($Cust_Dim2)+"_"+code($Cust_Dim5)+"_"+code($Cust_Dim1)+"_"+code($Cust_Dim3)+"_"+code($ANL_ENTITY_MIR)+"_"+code($ANL_ACCOUNT_MIR)+"_"+code($ANL_CC_MIR)+"_"+code($ANL_SUPPLIER)+"_"+code($ANL_PROJECT)+"_"+code($ANL_SNA)+"_"+code($Currency)


Annual Amount (Devise de transaction);Annual Amount (transaction currency);;
CONCAT_COLUMN_FULL;CONCAT_COLUMN_FULL;;
Notes;Notes;;
IFERROR(VLOOKUP({2}, QNotes, 2, 0), "")

Contrôle du transfert total;Transfer amount control;;
abs(sum({4}:{15}))-abs({1})



IFERROR(IF(AND({5}=0, {6}=0, {7}=0, {8}=0, {9}=0, {10}=0, {11}=0, {12}=0, {13}=0, {14}=0, {15}=0, {16}=0, {18}=0, {19}=0, {20}=0, {21}=0, {22}=0, {23}=0, {24}=0, {25}=0, {26}=0, {27}=0, {28}=0, {29}=0), 1, 0), 0)
La saisie manuelle n est pas fait pour tous les tansferts
Manuel input is not done for all transfers

----------------------------------------------
TGKML 1.0
A := Parameter("$SCE_P").parameterValue.attribute1;
B := SET($Period(A).code);
result := B;

TGKML 1.0
A := Parameter("$SCE_P").parameterValue.attribute1;
B := SET($Period(A).code);
result := this.GETLEAF(B);

TGKML 1.0
A := Parameter("$SCE_P").parameterValue.attribute1;
result := this.GETLEAF(A);


TGKML 1.0
result := this.GETLEAF($Sceanrio.attribute1);


TGKML 1.0
ENT:= Parameter("ENT_LLE").parameterValue.code;
A:= SET(Cust_Dim2(Hierarchy("001")).GETNODE(ENT).LOWEST.code);
result := THIS.GETLEAF(A)+ THIS.GETNODE(ENT);



TGKML 1.0
ENT := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.code;
A:= SET(Entity(Hierarchy("001")).GETNODE(ENT).LOWEST.code);
result := THIS.GETLEAF(A)+ THIS.GETNODE(ENT);



A := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.code;


---------------------------------------
TGKML 1.0
ENT := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.trimset(1).code;
A:=THIS.LOWEST.SELECT("$ENTITY.CODE","=",ENT);
result := A;


---------------------------------------

TGKML 1.0
ENT := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.trimset(1).code;
A:=THIS.LOWEST.SELECT("$ENTITY.CODE","=",ENT);

ENT_TOT:= Parameter("$DEST2_001_P").parameterValue.Children.trimset(1).code;
B:= THIS.LOWEST.SELECT("$ENTITY.CODE","=",ENT_TOT);
D:= This.lowest.code;

C:= IF(Parameter("$DEST2_001_P").parameterValue=='001', B, A);
result := C;

---------------------------------------
TGKML 1.0
ENT := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.trimset(1).code;
A:=THIS.LOWEST.SELECT("$ENTITY.CODE","=",ENT);
D:= $Entity(HIERARCHY("001")).lowest.code;
C:= IF(Parameter("$DEST2_001_P").parameterValue.code=="001", D, A);
result :=this.lowest.select("$ENTITY.CODE","=",C);


---------------------------------------


TGKML 1.0
ENT := Parameter("$DEST2_001_P").parameterValue.Lowest.Parent.trimset(1).code;
A:= THIS.LOWEST.SELECT("$ENTITY.CODE","=",ENT);

D:= THIS.Lowest.SELECT("$ENTITY.CODE","=","001");
C:= $Entity(HIERARCHY("001")).lowest.code;
E:= SET(Entity(Hierarchy("001")).GETNODE("001").LOWEST.code);

result:= D;



=IF({21}>0, IF({21}>={9},1,0), IF(AND({9}>=0,{9}<=-1*{21}),1,0))




CONCAT_COLUMN;CONCAT_COLUMN;;
code($Entity)+"_"+code($Account)+"_"+code($Cust_Dim2)+"_"+code($Cust_Dim5)+"_"+code($Cust_Dim1)+"_"+code($Cust_Dim3)+"_"+code($Currency)

code($Period)
=IF({31}>1, 1, 0)

--------------------------------


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

