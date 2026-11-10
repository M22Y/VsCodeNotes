TGKML 1.0
B:=$Period.code;
A:=IF($PERIOD.code=="03","3",SUM(VALUE(B),-3));
C:= "0"+A;
result :=this.lowest.select("$PERIOD.CODE","=",C);
------------------------------------

TGKML 1.0

A:=IF($PERIOD.code=="03","03",IF($PERIOD.code=="06","03",IF($PERIOD.code=="09","06",IF($PERIOD.code=="12","09","0"))));

result :=this.A;

-----------------------------------

TGKML 1.0

A:=IF(code(@QUARTER)=="03","03",VALUE($PERIOD.code));

result :=this.select("$PERIOD.code", "=", A);


------------------------------------

TGKML 1.0

ENT:=IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), $ANL_TECH_ACCTS(HIERARCHY("100")).code);
ENT := "A1803"

result := THIS.LOWEST.SELECT("$Entity.code", "=", ENT);


result :=this.A;


TGKML 1.0

ENT:=IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), "$");

result := THIS.LOWEST.SELECT("$Entity.code", "=", ENT);


---------------------------





----------------
IF(IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), $ANL_TECH_ACCTS(HIERARCHY("100")).code) = "",1,IF($Entity(HIERARCHY("100")).code = IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), $ANL_TECH_ACCTS(HIERARCHY("100")).code), 1, 0));
----------------

IF(OR(IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), $ANL_TECH_ACCTS(HIERARCHY("100")).code) = "", $ANL_TECH_ACCTS(HIERARCHY("100")).ISLEAF=0),1,IF($Entity(HIERARCHY("100")).code = IFERROR(LEFT($ANL_TECH_ACCTS(HIERARCHY("100")).code, FIND("_", $ANL_TECH_ACCTS(HIERARCHY("100")).code) - 1), $ANL_TECH_ACCTS(HIERARCHY("100")).code), 1, 0));








----------------------

SELECT A.COD, A.COD_ELEGER, B.DESC_ELEGER0, CONCAT(A.COD_ELEGER, ' - ', B.DESC_ELEGER0) AS DESC_FR FROM ED_TECH_ACCTS_GERARCHIA_ABBI A JOIN ED_TECH_ACCTS_GERARCHIA B ON A.COD_ELEGER=B.COD_ELEGER  WHERE A.COD_GERARCHIA='100'

SELECT A.COD, A.COD_ELEGER, B.DESC_ELEGER0 FROM ED_TECH_ACCTS_GERARCHIA_ABBI A JOIN ED_TECH_ACCTS_GERARCHIA B ON A.COD_ELEGER=B.COD_ELEGER  WHERE A.COD_GERARCHIA='100'









