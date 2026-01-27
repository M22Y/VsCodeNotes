

DECLARE all_columns VARCHAR;
DECLARE  delete_sql VARCHAR;
DECLARE  insert_sql VARCHAR;
DECLARE  debug VARCHAR;
DECLARE  columns VARCHAR;
DECLARE  source_partition VARCHAR;
DECLARE  source_scn VARCHAR;
 
BEGIN
 
source_scn := ${$Scenario.&A_2_REFRENCE_SCENARIO&.code};
columns := UPPER('&A_5_COLUMNS&');
source_partition := '${DatasetPARTITION("&A_1_AWCODE&", "&A_3_SOURCE_DATASET_CODE&", $Scenario.&A_2_REFRENCE_SCENARIO&.code)}';

/* Generate the delete statement to delete ALL rows for the target scenario */
delete_sql := 
 'DELETE FROM &A_4_TARGET_DATASET&
      WHERE &TARGET_SCENARIO_COL& = ''&Z_TARGET_SCENARIO&'' 
       AND &TARGET_PERIOD_COL& IN (
               SELECT cod_periodo
               FROM scenario_periodo
               WHERE cod_scenario = ''&Z_TARGET_SCENARIO&''
                AND flag_bloccato IN (&A_8_PERIODS&))';

/* Delete ALL rows */
EXECUTE delete_sql;

/* Generate Insert Statement */
insert_sql := 
'INSERT INTO &A_4_TARGET_DATASET& (
    &A_7_TARGET_COLUMNS&,
    &TARGET_SCENARIO_COL&,
    OID,
    PROVENIENZA,
    USERUPD,
    DATEUPD
)
SELECT
    &A_6_SOURCE_COLUMNS&,
    ''&Z_TARGET_SCENARIO&'',
    gen_random_uuid() AS OID,
    ''DATA_COPY_UTILITY_SELECTED_COLUMNS'' AS PROVENIENZA,
    ''#USER#'' AS USERUPD,
    CURRENT_TIMESTAMP AS DATEUPD
FROM ' || source_partition || '
WHERE
    &SOURCE_SCENARIO_COL& = ''' || source_scn || '''
    AND &SOURCE_PERIOD_COL& IN (
        SELECT cod_periodo
        FROM scenario_periodo
        WHERE cod_scenario = ''&Z_TARGET_SCENARIO&''
        AND flag_bloccato IN (&A_8_PERIODS&)
    )';

/* Execute Insert Statement */
EXECUTE insert_sql;

END;
 



