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
