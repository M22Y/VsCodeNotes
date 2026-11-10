DECLARE CURSOR CUR_MAP FOR
SELECT DISTINCT
  ACCOUNT,
  SCEN_TYPE,
  BAL_TYPE
  /*FROM &RL_MDA_MAP&  -- MD&A Account Mapping*/
FROM
  &SOURCE_FILTER&
WHERE
  ACCOUNT LIKE '%&NOTE&%'
  AND TEXT_ORIGIN = '&OUT_TYPE&'
  ;

DECLARE CUR_ACC NVARCHAR (30);

DECLARE CUR_SCE NVARCHAR (30);

DECLARE CUR_BAL NVARCHAR (30);

-- Declare cursor where each EXCLUDE row for a specific account, scenario and balance type is ordered by OID
DECLARE CURSOR CUR_DEL FOR

SELECT ROW_NUMBER() OVER (PARTITION BY ACCOUNT, BAL_TYPE, SCEN_TYPE ORDER BY OID) AS ROW_NUM,
    OID
FROM (
  SELECT OID, SCEN_TYPE, ACCOUNT, BAL_TYPE 
  FROM &RL_MDA_MAP&  -- MD&A Account Mapping
  WHERE 1=1
  AND ACCOUNT = CUR_ACC
  AND SCEN_TYPE = CUR_SCE
  AND BAL_TYPE = CUR_BAL
  AND RULE_TYPE = 'EXCLUDE'
  AND TEXT_ORIGIN = '13'
  UNION ALL
  SELECT OID, SCEN_TYPE, ACCOUNT1, BAL_TYPE1 
  FROM &RL_MDA_MAP&  -- MD&A Account Mapping
  WHERE 1=1
  AND ACCOUNT1 = CUR_ACC
  AND SCEN_TYPE = CUR_SCE
  AND BAL_TYPE1 = CUR_BAL
  AND RULE_TYPE = 'EXCLUDE'
  AND TEXT_ORIGIN = '13'
  UNION ALL
  SELECT OID, SCEN_TYPE, ACCOUNT2, BAL_TYPE2 
  FROM &RL_MDA_MAP&  -- MD&A Account Mapping
  WHERE 1=1
  AND ACCOUNT2 = CUR_ACC
  AND SCEN_TYPE = CUR_SCE
  AND BAL_TYPE2 = CUR_BAL
  AND RULE_TYPE = 'EXCLUDE'
  AND TEXT_ORIGIN = '13');

-- Declaring cursor variables
DECLARE CUR_DEL_OID NVARCHAR (50);
DECLARE CUR_DEL_NUM INT;

-- Declaring variables to dinamically build the AND filter
DECLARE CUR_DEL_ENT INT;
DECLARE CUR_DEL_ENT_CTP INT;
DECLARE CUR_DEL_ACC INT;
DECLARE CUR_DEL_CAT INT;
DECLARE CUR_DEL_ANA INT;
DECLARE CUR_DEL_SEG_CTP INT;
DECLARE CUR_DEL_ORI INT;

DELETE FROM &RL_NOTE& P
WHERE
  PROVENIENZA = 'SM0050';

OPEN CUR_MAP;

FOR CUR_ROW AS CUR_MAP
DO CUR_ACC := CUR_ROW.ACCOUNT;

CUR_SCE := CUR_ROW.SCEN_TYPE;

CUR_BAL := CUR_ROW.BAL_TYPE;

DELETE FROM #TARGET_PARTITION#;

INSERT INTO
  #TARGET_PARTITION# (
    OID,
    FW_ACC,
    SCEN_TYPE,
    BAL_TYPE,
    RULE_TYPE,
    SCENARIO,
    ENTITY,
    ENT_HIER,
    ENT_NODE,
    ENTITY_CTP,
    ENT_CTP_HIER,
    ENT_CTP_NODE,
    ACCOUNT,
    ACC_HIER,
    ACC_NODE,
    CATEGORY,
    CAT_HIER,
    CAT_NODE,
    ANALYSIS,
    ANA_HIER,
    ANA_NODE,
    TEXT_ORIGIN,
    SIGN,
    PROVENIENZA,
    USERUPD,
    DATEUPD,
    EN_VERSION,
    PERIOD_LENGTH,
    MDA_SCENARIO,
    MDA_PERIOD,
    SEGMENT_CTP,
    SEG_CTP_HIER,
    SEG_CTP_NODE,
    SOURCE_ORIGIN
  )
SELECT
  NEWID ()               OID,
  INS.FW_ACC,
  INS.SCEN_TYPE,
  INS.BAL_TYPE,
  'INCLUDE'              RULE_TYPE,
  INS.SCENARIO,
  INS.ENTITY,
  NULL                   ENT_HIER,
  NULL                   ENT_NODE,
  INS.ENTITY_CTP,
  NULL                   ENT_CTP_HIER,
  NULL                   ENT_CTP_NODE,
  INS.ACCOUNT,
  NULL                   ACC_HIER,
  NULL                   ACC_NODE,
  INS.CATEGORY,
  NULL                   CAT_HIER,
  NULL                   CAT_NODE,
  INS.ANALYSIS,
  NULL                   ANA_HIER,
  NULL                   ANA_NODE,
  '13'                   TEXT_ORIGIN,
  '1'                    SIGN,
  'SM0050'               PROVENIENZA,
  COALESCE('#USER#', '') USERUPD,
  CURRENT_TIMESTAMP      DATEUPD,
  0                      EN_VERSION,
  (
    SELECT
      MAX(TP.PERIOD_LENGTH)
    FROM
      &RL_MDA_MAP& TP
    WHERE
      TEXT_ORIGIN = '13'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
  ),
  '#SCENARIOS#' MDA_SCENARIO,
  '#PERIODS#' MDA_PERIOD,
  INS.SEGMENT_CTP,
  NULL SEG_CTP_HIER,
  NULL SEG_CTP_NODE,
  INS.SOURCE_ORIGIN
FROM
  (
    SELECT
      NULL     FW_ACC,
      CUR_SCE  SCEN_TYPE,
      CUR_BAL  BAL_TYPE,
      SCENARIO,
      NULL     ENTITY,
      NULL     ENTITY_CTP,
      CUR_ACC  ACCOUNT,
      NULL     CATEGORY,
      NULL     ANALYSIS,
      NULL     SEGMENT_CTP,
      NULL     SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      SCENARIO
    UNION ALL
    SELECT
      NULL    FW_ACC,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    SCENARIO,
      ENTITY,
      NULL    ENTITY_CTP,
      CUR_ACC ACCOUNT,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(ENTITY, 'ALL') <> 'ALL'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      ENTITY
    UNION ALL
    SELECT
      NULL        FW_ACC,
      CUR_SCE     SCEN_TYPE,
      CUR_BAL     BAL_TYPE,
      NULL        SCENARIO,
      COD_AZIENDA ENTITY,
      NULL        ENTITY_CTP,
      CUR_ACC     ACCOUNT,
      NULL        CATEGORY,
      NULL        ANALYSIS,
      NULL        SEGMENT_CTP,
      NULL        SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENTITY = 'ALL'
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      B.COD_AZIENDA ENTITY,
      NULL          ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      NULL          CATEGORY,
      NULL          ANALYSIS,
      NULL          SEGMENT_CTP,
      NULL          SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ENT_HIER,
          ENT_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENTITY IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)  
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.ENT_HIER
          AND (
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )
    UNION ALL
    SELECT
      NULL       FW_ACC,
      CUR_SCE    SCEN_TYPE,
      CUR_BAL    BAL_TYPE,
      NULL       SCENARIO,
      NULL       ENTITY,
      ENTITY_CTP,
      CUR_ACC    ACCOUNT,
      NULL       CATEGORY,
      NULL       ANALYSIS,
      NULL       SEGMENT_CTP,
      NULL       SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND ENTITY_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      ENTITY_CTP
    UNION ALL
    SELECT
      NULL        FW_ACC,
      CUR_SCE     SCEN_TYPE,
      CUR_BAL     BAL_TYPE,
      NULL        SCENARIO,
      NULL        ENTITY,
      COD_AZIENDA ENTITY_CTP,
      CUR_ACC     ACCOUNT,
      NULL        CATEGORY,
      NULL        ANALYSIS,
      NULL        SEGMENT_CTP,
      NULL        SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENTITY_CTP IN ('ALL', 'YYY')
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      NULL    FW_ACC,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    SCENARIO,
      NULL    ENTITY,
      'XXX'   ENTITY_CTP,
      CUR_ACC ACCOUNT,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      DUMMY
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENTITY_CTP IN ('ALL', 'XXX')
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      NULL          ENTITY,
      B.COD_AZIENDA ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      NULL          CATEGORY,
      NULL          ANALYSIS,
      NULL          SEGMENT_CTP,
      NULL          SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ENT_CTP_HIER,
          ENT_CTP_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENTITY_CTP IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.ENT_CTP_HIER
          AND (
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )
    UNION ALL
    SELECT
      FW_ACC,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    SCENARIO,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      CUR_ACC ACCOUNT,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(FW_ACC, 'ALL') <> 'ALL'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      FW_ACC
    UNION ALL
    SELECT
      COD_CONTO FW_ACC,
      CUR_SCE   SCEN_TYPE,
      CUR_BAL   BAL_TYPE,
      NULL      SCENARIO,
      NULL      ENTITY,
      NULL      ENTITY_CTP,
      CUR_ACC   ACCOUNT,
      NULL      CATEGORY,
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN
    FROM
      CONTO
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND FW_ACC = 'ALL'
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
    UNION ALL
    SELECT
      B.COD_CONTO FW_ACC,
      CUR_SCE     SCEN_TYPE,
      CUR_BAL     BAL_TYPE,
      NULL        SCENARIO,
      NULL        ENTITY,
      NULL        ENTITY_CTP,
      CUR_ACC     ACCOUNT,
      NULL        CATEGORY,
      NULL        ANALYSIS,
      NULL        SEGMENT_CTP,
      NULL        SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ACC_HIER,
          ACC_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND FW_ACC IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      ) A
        JOIN CONTO_GERARCHIA_FLAT B ON B.COD_CONTO_GERARCHIA = A.ACC_HIER
          AND (
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER1 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER2 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER3 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER4 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER5 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER6 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER7
          )
    UNION ALL
    SELECT
      NULL     FW_ACC,
      CUR_SCE  SCEN_TYPE,
      CUR_BAL  BAL_TYPE,
      NULL     SCENARIO,
      NULL     ENTITY,
      NULL     ENTITY_CTP,
      CUR_ACC  ACCOUNT,
      CATEGORY,
      NULL     ANALYSIS,
      NULL     SEGMENT_CTP,
      NULL     SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(CATEGORY, 'ALL') <> 'ALL'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      CATEGORY
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      NULL          ENTITY,
      NULL          ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      COD_CATEGORIA CATEGORY,
      NULL          ANALYSIS,
      NULL          SEGMENT_CTP,
      NULL          SOURCE_ORIGIN
    FROM
      CATEGORIA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND CATEGORY = 'ALL'
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      NULL          ENTITY,
      NULL          ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      COD_CATEGORIA CATEGORY,
      NULL          ANALYSIS,
      NULL          SEGMENT_CTP,
      NULL          SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          CAT_HIER,
          CAT_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND CATEGORY IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      ) A
        JOIN V_FLAT_CATEGORIA B ON B.COD_CATEGORIA_GERARCHIA = A.CAT_HIER
          AND (
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L0 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L1 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L2 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L3 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L4 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L5 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L6
          )
    UNION ALL
    SELECT
      NULL     FW_ACC,
      CUR_SCE  SCEN_TYPE,
      CUR_BAL  BAL_TYPE,
      NULL     SCENARIO,
      NULL     ENTITY,
      NULL     ENTITY_CTP,
      CUR_ACC  ACCOUNT,
      NULL     CATEGORY,
      ANALYSIS,
      NULL     SEGMENT_CTP,
      NULL     SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(ANALYSIS, 'ALL') <> 'ALL'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      ANALYSIS
    UNION ALL
    SELECT
      NULL      FW_ACC,
      CUR_SCE   SCEN_TYPE,
      CUR_BAL   BAL_TYPE,
      NULL      SCENARIO,
      NULL      ENTITY,
      NULL      ENTITY_CTP,
      CUR_ACC   ACCOUNT,
      NULL      CATEGORY,
      COD_DEST5 ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN
    FROM
      DEST5
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ANALYSIS = 'ALL'
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
    UNION ALL
    SELECT
      NULL      FW_ACC,
      CUR_SCE   SCEN_TYPE,
      CUR_BAL   BAL_TYPE,
      NULL      SCENARIO,
      NULL      ENTITY,
      NULL      ENTITY_CTP,
      CUR_ACC   ACCOUNT,
      NULL      CATEGORY,
      COD_DEST5 ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ANA_HIER,
          ANA_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ANALYSIS IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      ) A
        JOIN DEST5_GERARCHIA_FLAT B ON B.COD_DEST5_GERARCHIA = A.ANA_HIER
          AND (
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER1 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER2 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER3 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER4 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER5 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER6 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER7
          )
    UNION ALL
    SELECT
      NULL        FW_ACC,
      CUR_SCE     SCEN_TYPE,
      CUR_BAL     BAL_TYPE,
      NULL        SCENARIO,
      NULL        ENTITY,
      NULL        ENTITY_CTP,
      CUR_ACC     ACCOUNT,
      NULL        CATEGORY,
      NULL        ANALYSIS,
      SEGMENT_CTP,
      NULL        SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND SEGMENT_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      SEGMENT_CTP
    UNION ALL
    SELECT
      NULL        FW_ACC,
      CUR_SCE     SCEN_TYPE,
      CUR_BAL     BAL_TYPE,
      NULL        SCENARIO,
      NULL        ENTITY,
      NULL        ENTITY_CTP,
      CUR_ACC     ACCOUNT,
      NULL        CATEGORY,
      NULL        ANALYSIS,
      COD_AZIENDA SEGMENT_CTP,
      NULL        SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEGMENT_CTP IN ('ALL', 'YYY')
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      NULL    FW_ACC,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    SCENARIO,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      CUR_ACC ACCOUNT,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      'XXX'   SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      DUMMY
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEGMENT_CTP IN ('ALL', 'XXX')
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      NULL          ENTITY,
      NULL          ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      NULL          CATEGORY,
      NULL          ANALYSIS,
      B.COD_AZIENDA SEGMENT_CTP,
      NULL          SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          SEG_CTP_HIER,
          SEG_CTP_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEGMENT_CTP IS NULL
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.SEG_CTP_HIER
          AND (
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )
    UNION ALL
    SELECT
      NULL          FW_ACC,
      CUR_SCE       SCEN_TYPE,
      CUR_BAL       BAL_TYPE,
      NULL          SCENARIO,
      NULL          ENTITY,
      NULL          ENTITY_CTP,
      CUR_ACC       ACCOUNT,
      NULL          CATEGORY,
      NULL          ANALYSIS,
      NULL          SEGMENT_CTP,
      SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(SOURCE_ORIGIN, 'ALL') <> 'ALL'
      AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
      AND SCEN_TYPE = CUR_SCE
      AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
    GROUP BY
      SOURCE_ORIGIN
    UNION ALL
    SELECT
      NULL    FW_ACC,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    SCENARIO,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      CUR_ACC ACCOUNT,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      SO.COD  SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          SOURCE_ORIGIN AS COD
        FROM
          &RL_MDA_STAGING&
      ) SO
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SOURCE_ORIGIN = 'ALL'
          AND (ACCOUNT = CUR_ACC OR ACCOUNT1 = CUR_ACC OR ACCOUNT2 = CUR_ACC)
          AND SCEN_TYPE = CUR_SCE
          AND (BAL_TYPE = CUR_BAL OR BAL_TYPE1 = CUR_BAL OR BAL_TYPE2 = CUR_BAL)
      )
  ) INS
;



--**************************************************************************************************************************************

--**************************************************************************************************************************************

-- Clear temporary table
DELETE FROM SM0050_DATA_01;

--Insert data into temporary table for future use
INSERT INTO
  SM0050_DATA_01 (
    ACCOUNT	,
    BAL_TYPE	,
    SCEN_TYPE	,
    SCENARIO		,
    PERIOD		,
    ENTITY		,
    ENTITY_CTP		,
    FW_ACC	,
    CATEGORY		,
    CURRENCY1	,
    CURRENCY2		,
    ANALYSIS	,
    AMOUNT1	,
    AMOUNT2	,
    AMOUNT_TYPE		,
    PERIOD_LENGTH		,
    TEXT_ORIGIN		,
    SOURCE_SCENARIO		,
    SOURCE_ORIGIN		,
    SOURCE_TABLE
    )
SELECT
  CUR_ACC	ACCOUNT	,
  CUR_BAL	BAL_TYPE	,
  CUR_SCE	SCEN_TYPE	,
  SCENARIO		,
  PERIOD		,
  ENTITY		,
  ENTITY_CTP		,
  ACCOUNT	FW_ACC	,
  CATEGORY		,
  CURRENCY	CURRENCY1	,
  CURRENCY2		,
  CUSTOM_DIM5	ANALYSIS	,
  SUM(AMOUNT1)	AMOUNT1	,
  SUM(AMOUNT2)	AMOUNT2	,
  AMOUNT_TYPE		,
  PERIOD_LENGTH		,
  TEXT_ORIGIN		,
  SOURCE_SCENARIO		,
  SOURCE_ORIGIN		,
  SOURCE_TABLE		
FROM
  (
    SELECT
      *
    FROM
      &RL_MDA_STAGING& S1
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.SCENARIO = S1.SOURCE_SCENARIO
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.ENTITY = S1.ENTITY
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.ENTITY_CTP = COALESCE(S1.ENTITY_CTP, 'XXX')
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.FW_ACC = S1.ACCOUNT
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.CATEGORY = S1.CATEGORY
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.ANALYSIS = S1.CUSTOM_DIM5
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.SEGMENT_CTP = COALESCE(S1.SEGMENT_CTP, 'XXX')
      )
      AND S1.PERIOD_LENGTH = (
        SELECT
          MAX(TP.PERIOD_LENGTH)
        FROM
          #TARGET_PARTITION# TP
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          (
            TP.SOURCE_ORIGIN = 'ALL'
            OR TP.SOURCE_ORIGIN = S1.SOURCE_ORIGIN
          )
      )
  ) STAGING
GROUP BY
  SCENARIO		,
  PERIOD		,
  ENTITY		,
  ENTITY_CTP		,
  ACCOUNT	,
  CATEGORY		,
  CURRENCY	,
  CURRENCY2		,
  CUSTOM_DIM5	,
  AMOUNT_TYPE		,
  PERIOD_LENGTH		,
  TEXT_ORIGIN		,
  SOURCE_SCENARIO		,
  SOURCE_ORIGIN		,
  SOURCE_TABLE
;

--**************************************************************************************************************************************

--**************************************************************************************************************************************

-- Open deletion cursor
OPEN CUR_DEL;

FOR CUR_DEL_ROW AS CUR_DEL
DO 
CUR_DEL_NUM := CUR_DEL_ROW.ROW_NUM;
CUR_DEL_OID := CUR_DEL_ROW.OID;

-- Clear work table
DELETE FROM SM0050_DELETE_01;

-- Insert row into the work table
  INSERT INTO
    SM0050_DELETE_01 (
      OID,
      ACCOUNT,
      SCEN_TYPE,
      BAL_TYPE,
      ENTITY,
      ENTITY_CTP,
      FW_ACC,
      CATEGORY,
      ANALYSIS,
      SEGMENT_CTP,
      SOURCE_ORIGIN
    )
  SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE
    OID = CUR_DEL_OID
    AND ENTITY <> 'ALL'
    UNION ALL
  SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      COD_AZIENDA ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ENTITY = 'ALL'
          AND OID = CUR_DEL_OID
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      B.COD_AZIENDA ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT
          ENT_HIER,
          ENT_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ENT_HIER IS NOT NULL
          AND ENT_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.ENT_HIER
          AND (
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.ENT_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )


UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND ENTITY_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      COD_AZIENDA ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ENTITY_CTP IN ('ALL', 'YYY')
          AND OID = CUR_DEL_OID
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      'XXX' ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      DUMMY
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ENTITY_CTP IN ('ALL', 'XXX')
          AND OID = CUR_DEL_OID
      )
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      B.COD_AZIENDA ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ENT_CTP_HIER,
          ENT_CTP_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ENT_CTP_HIER IS NOT NULL
          AND ENT_CTP_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.ENT_CTP_HIER
          AND (
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.ENT_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )
UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(FW_ACC, 'ALL') <> 'ALL'
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      COD_CONTO FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      CONTO
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND FW_ACC = 'ALL'
          AND OID = CUR_DEL_OID
      )
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      B.COD_CONTO FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ACC_HIER,
          ACC_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ACC_HIER IS NOT NULL
          AND ACC_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN CONTO_GERARCHIA_FLAT B ON B.COD_CONTO_GERARCHIA = A.ACC_HIER
          AND (
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER1 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER2 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER3 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER4 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER5 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER6 OR
            SUBSTR_AFTER (A.ACC_NODE, '|') = B.COD_CONTO_ELEGER7
          )
UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(CATEGORY, 'ALL') <> 'ALL'
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      COD_CATEGORIA CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      CATEGORIA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND CATEGORY = 'ALL'
          AND OID = CUR_DEL_OID
      )
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      B.COD_CATEGORIA CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          CAT_HIER,
          CAT_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND CAT_HIER IS NOT NULL
          AND CAT_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN V_FLAT_CATEGORIA B ON B.COD_CATEGORIA_GERARCHIA = A.CAT_HIER
          AND (
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L0 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L1 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L2 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L3 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L4 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L5 OR
            SUBSTR_AFTER (A.CAT_NODE, '|') = B.L6
          )
UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(ANALYSIS, 'ALL') <> 'ALL'
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      COD_DEST5 ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      DEST5
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND ANALYSIS = 'ALL'
          AND OID = CUR_DEL_OID
      )
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      B.COD_DEST5 ANALYSIS,
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          ANA_HIER,
          ANA_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND ANA_HIER IS NOT NULL
          AND ANA_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN DEST5_GERARCHIA_FLAT B ON B.COD_DEST5_GERARCHIA = A.ANA_HIER
          AND (
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER1 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER2 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER3 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER4 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER5 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER6 OR
            SUBSTR_AFTER (A.ANA_NODE, '|') = B.COD_DEST5_ELEGER7
          )
UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND SEGMENT_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      COD_AZIENDA SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      AZIENDA
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SEGMENT_CTP IN ('ALL', 'YYY')
          AND OID = CUR_DEL_OID
      )
      AND COD_AZIENDA NOT IN ('$', 'DF_PCC_CAD', 'DF_PFC_CAD')
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      'XXX' SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      DUMMY
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SEGMENT_CTP IN ('ALL', 'XXX')
          AND OID = CUR_DEL_OID
      )
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      B.COD_AZIENDA SEGMENT_CTP,
      NULL    SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          SEG_CTP_HIER,
          SEG_CTP_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEG_CTP_HIER IS NOT NULL
          AND SEG_CTP_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN AZIENDA_GERARCHIA_FLAT B ON B.COD_AZIENDA_GERARCHIA = A.SEG_CTP_HIER
          AND (
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER1 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER2 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER3 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER4 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER5 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER6 OR
            SUBSTR_AFTER (A.SEG_CTP_NODE, '|') = B.COD_AZIENDA_ELEGER7
          )
UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      SOURCE_ORIGIN
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(SOURCE_ORIGIN, 'ALL') <> 'ALL'
      AND OID = CUR_DEL_OID
    UNION ALL
    SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE,
      NULL    ENTITY,
      NULL    ENTITY_CTP,
      NULL    FW_ACC,
      NULL    CATEGORY,
      NULL    ANALYSIS,
      NULL    SEGMENT_CTP,
      SO.COD SOURCE_ORIGIN
    FROM
      (
        SELECT DISTINCT
          SOURCE_ORIGIN AS COD
        FROM
          &RL_MDA_STAGING&
      ) SO
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SOURCE_ORIGIN = 'ALL'
          AND OID = CUR_DEL_OID
      )
;

-- Confirm filters to apply
SELECT COUNT(DISTINCT ENTITY) INTO CUR_DEL_ENT FROM SM0050_DELETE_01 WHERE ENTITY IS NOT NULL;
SELECT COUNT(DISTINCT ENTITY_CTP) INTO CUR_DEL_ENT_CTP FROM SM0050_DELETE_01 WHERE ENTITY_CTP IS NOT NULL;
SELECT COUNT(DISTINCT FW_ACC) INTO CUR_DEL_ACC FROM SM0050_DELETE_01 WHERE FW_ACC IS NOT NULL;
SELECT COUNT(DISTINCT CATEGORY) INTO CUR_DEL_CAT FROM SM0050_DELETE_01 WHERE CATEGORY IS NOT NULL;
SELECT COUNT(DISTINCT ANALYSIS) INTO CUR_DEL_ANA FROM SM0050_DELETE_01 WHERE ANALYSIS IS NOT NULL;
SELECT COUNT(DISTINCT SEGMENT_CTP) INTO CUR_DEL_SEG_CTP FROM SM0050_DELETE_01 WHERE SEGMENT_CTP IS NOT NULL;
SELECT COUNT(DISTINCT SOURCE_ORIGIN) INTO CUR_DEL_ORI FROM SM0050_DELETE_01 WHERE SOURCE_ORIGIN IS NOT NULL;

-- Combine filters
DELETE FROM SM0050_DELETE_02;

INSERT INTO SM0050_DELETE_02 (
      OID,
      ACCOUNT,
      SCEN_TYPE,
      BAL_TYPE,
      ENTITY,
      ENTITY_CTP,
      FW_ACC,
      CATEGORY,
      ANALYSIS,
      SEGMENT_CTP,
      SOURCE_ORIGIN
    )
SELECT
  base.OID,
  base.ACCOUNT,
  base.SCEN_TYPE,
  base.BAL_TYPE,
  e.ENTITY,
  ec.ENTITY_CTP,
  fa.FW_ACC,
  c.CATEGORY,
  a.ANALYSIS,
  sc.SEGMENT_CTP,
  so.SOURCE_ORIGIN
FROM
  (SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE
  FROM DUMMY) base
  LEFT JOIN (SELECT DISTINCT ENTITY FROM SM0050_DELETE_01 WHERE ENTITY IS NOT NULL) e ON CUR_DEL_ENT <> 0
  LEFT JOIN (SELECT DISTINCT ENTITY_CTP FROM SM0050_DELETE_01 WHERE ENTITY_CTP IS NOT NULL) ec ON CUR_DEL_ENT_CTP <> 0
  LEFT JOIN (SELECT DISTINCT FW_ACC FROM SM0050_DELETE_01 WHERE FW_ACC IS NOT NULL) fa ON CUR_DEL_ACC <> 0
  LEFT JOIN (SELECT DISTINCT CATEGORY FROM SM0050_DELETE_01 WHERE CATEGORY IS NOT NULL) c ON CUR_DEL_CAT <> 0
  LEFT JOIN (SELECT DISTINCT ANALYSIS FROM SM0050_DELETE_01 WHERE ANALYSIS IS NOT NULL) a ON CUR_DEL_ANA <> 0
  LEFT JOIN (SELECT DISTINCT SEGMENT_CTP FROM SM0050_DELETE_01 WHERE SEGMENT_CTP IS NOT NULL) sc ON CUR_DEL_SEG_CTP <> 0
  LEFT JOIN (SELECT DISTINCT SOURCE_ORIGIN FROM SM0050_DELETE_01 WHERE SOURCE_ORIGIN IS NOT NULL) so ON CUR_DEL_ORI <> 0;

-- Delete data from temporary table according to EXCLUDE filters
DELETE FROM SM0050_DATA_01 BD
WHERE EXISTS (
  SELECT
    1
  FROM
    SM0050_DELETE_02 CP
  WHERE 1=1
    AND (CUR_DEL_ENT = 0 OR BD.ENTITY = CP.ENTITY)
    AND (CUR_DEL_ENT_CTP = 0 OR BD.ENTITY_CTP = CP.ENTITY_CTP)
    AND (CUR_DEL_ACC = 0 OR BD.FW_ACC = CP.FW_ACC)
    AND (CUR_DEL_CAT = 0 OR BD.CATEGORY = CP.CATEGORY)
    AND (CUR_DEL_ANA = 0 OR BD.ANALYSIS = CP.ANALYSIS)
    AND (CUR_DEL_SEG_CTP = 0 OR BD.SEGMENT_CTP = CP.SEGMENT_CTP)
    AND (CUR_DEL_ORI = 0 OR BD.SOURCE_ORIGIN = CP.SOURCE_ORIGIN)
);


END FOR;

CLOSE CUR_DEL;

-- Insert new records into target note from temp table
INSERT INTO
  &RL_NOTE& (
    OID,
    SCENARIO,
    PERIOD,
    SCEN_TYPE,
    ENTITY,
    ACCOUNT,
    ENTITY_CTP,
    FW_ACC,
    CATEGORY,
    ANALYSIS,
    CURRENCY1,
    CURRENCY2,
    AMOUNT1,
    AMOUNT2,
    SCALE,
    BAL_TYPE,
    SIGN,
    TEXT_ORIGIN,
    SEGMENT_CTP,
    SOURCE_ORIGIN,
    PERIOD_LENGTH,
    PROVENIENZA,
    USERUPD,
    DATEUPD,
    EN_VERSION
  )
SELECT
  NEWID()                 OID,
  BD.SCENARIO,
  BD.PERIOD,
  BD.SCEN_TYPE,
  BD.ENTITY,
  BD.ACCOUNT,
  BD.ENTITY_CTP,
  BD.FW_ACC,
  '&OUT_CATEGORY&'         CATEGORY,
  BD.ANALYSIS,
  BD.CURRENCY1,
  BD.CURRENCY2,
  SUM(BD.AMOUNT1)*COALESCE(SIGN.SIGN, 1)     AMOUNT1,
  SUM(BD.AMOUNT2)*COALESCE(SIGN.SIGN, 1)     AMOUNT2,
  'U'                      SCALE,
  BD.BAL_TYPE,
  COALESCE(SIGN.SIGN, 1) SIGN,
  '&OUT_TXT_ORIGIN&'       TEXT_ORIGIN,
    BD.SEGMENT_CTP,
    BD.SOURCE_ORIGIN,
  BD.PERIOD_LENGTH,
  'SM0050'                 PROVENIENZA,
  COALESCE('#USER#', '')   USERUPD,
  CURRENT_TIMESTAMP        DATEUPD,
  0                        EN_VERSION
FROM SM0050_DATA_01 BD
  LEFT JOIN (
    SELECT
      SIGN
    FROM
      &RL_MDA_MAP&
    WHERE
      TEXT_ORIGIN = '15'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
  ) SIGN ON 1 = 1
GROUP BY
  BD.SCENARIO,
  BD.PERIOD,
  BD.SCEN_TYPE,
  BD.ENTITY,
  BD.ACCOUNT,
  BD.ENTITY_CTP,
  BD.FW_ACC,
  BD.ANALYSIS,
  BD.SEGMENT_CTP,
  BD.SOURCE_ORIGIN,
  BD.CURRENCY1,
  BD.CURRENCY2,
  COALESCE(SIGN.SIGN, 1),
  BD.BAL_TYPE,
  BD.PERIOD_LENGTH;


END FOR;

CLOSE CUR_MAP;
