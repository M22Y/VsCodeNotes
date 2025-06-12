select * from raccolta_prospetto_controllo where COD_PROSPETTO = 'DE060'

select * from ED_RESOURCE_GERARCHIA_FLAT WHERE COD_ELEGER7='STV_TLG'
select * from ED_RESOURCE_GERARCHIA_FLAT where COD_GERARCHIA='999'


SCENARIO=${$Scenario.code}
AND SUBSTRING(${$Scenario.code} FROM 5 FOR 3) = 'BDG'
AND TEXT_ORIGIN IN ('AW004_INPUT_DE050', 'AW004_INPUT_DE040')


SCENARIO=${$Scenario.code}
AND SUBSTRING(${$Scenario.code} FROM 5 FOR 3) = 'FCT'
AND TEXT_ORIGIN IN ('AW004_INPUT_DE150', 'AW004_INPUT_DE140'



---------------------------------------------



---------------------------------------------


IFERROR(IF({110}=1, {1},{1}-{73}), 0)
IFERROR(SUM({8}:{10}), 0)
IF(code(@QUARTER)="03", 1, 0)



SELECT COD, DESC0, COD_ELEGER7, DESC_ELEGER7 FROM ED_RESOURCE_GERARCHIA_FLAT WHERE COD_GERARCHIA LIKE '001' ORDER BY COD ASC

=IF(OR(OFFSET({8},0,-1)=""),"", XLOOKUP(OFFSET({8},0,-1), COD_DESC_RESOURCE, DESC_RES_TYPE, OFFSET({8},0,-1), 0, 1))

=IF({40}="STV_TLG", "Invalid resource", IF( {36}<>1, "Selected combination exists", IF({31}>0, "Add a comment",IF({34}="", "Not Saved", "")))   )

400110A0000
400120A0000

Add a comment

Selected combination exists

Invalid resource - Stevedoring/Tailgating can't be manually added in this form


=IF(AND({34}="" ,COUNTIF(STV_TLG, LEFT({7}, 11))>0), IF({7}="", "0", "STV_TLG"), "0")



IF({35}="", 1, COUNTIF(TESTCONC1,{35}))


=IF(COUNTIF(STV_TLG, LEFT({7}, 11))>0, IF({7}="", -1, 0), -1)

YES 1   ---      (-1       ---- STV_TLG 0   )
                    0                   1
Empty 0  ---     (-1       ---- STV_TLG 0   )
                    -1                  0



IF(OR({22}<>0,{23}<>0,{24}<>0),1,IF({34}="", 1, 0))
OLD  : IF(OR({22}<>0,{23}<>0,{24}<>0),1,0)