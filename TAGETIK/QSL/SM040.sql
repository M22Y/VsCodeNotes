DECLARE CURSOR CUR_MAP FOR
SELECT DISTINCT
  ACCOUNT,
  SCEN_TYPE,
  BAL_TYPE
  /*FROM &RL_MDA_MAP&  -- MD&A Account Mapping*/
FROM
  &SOURCE_FILTER&
WHERE
  ACCOUNT LIKE '%&NOTE&%';

DECLARE CUR_ACC NVARCHAR (30);

DECLARE CUR_SCE NVARCHAR (30);

DECLARE CUR_BAL NVARCHAR (30);

-- Declare cursor where each EXCLUDE row for a specific account, scenario and balance type is ordered by OID
DECLARE CURSOR CUR_DEL FOR

SELECT ROW_NUMBER() OVER (PARTITION BY ACCOUNT, BAL_TYPE, SCEN_TYPE ORDER BY OID) AS ROW_NUM,
    OID
FROM &RL_MDA_MAP&  -- MD&A Account Mapping
WHERE
  ACCOUNT = CUR_ACC
  AND SCEN_TYPE = CUR_SCE
  AND BAL_TYPE = CUR_BAL
  AND RULE_TYPE = 'EXCLUDE'
  AND TEXT_ORIGIN = '13';

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
DECLARE CUR_DEL_SEC INT;
DECLARE CUR_DEL_PRO INT;
DECLARE CUR_DEL_COS INT;
DECLARE CUR_DEL_SEG INT;
DECLARE CUR_DEL_JOU INT;

DELETE FROM &RL_NOTE& P
WHERE
  PROVENIENZA = 'SM0040';

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
    SOURCE_ORIGIN,
    SECURITY,
    SEC_HIER,
    SEC_NODE,
    PROFIT_CENTER,
    PRO_HIER,
    PRO_NODE,
    COST_CENTER,
    COST_HIER,
    COST_NODE,
    SEGMENT,
    SEG_HIER,
    SEG_NODE,
    JOURNAL_NUMBER
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
  'SM0040'               PROVENIENZA,
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
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
  ),
  '#SCENARIOS#' MDA_SCENARIO,
  '#PERIODS#' MDA_PERIOD,
  INS.SEGMENT_CTP,
  NULL SEG_CTP_HIER,
  NULL SEG_CTP_NODE,
  INS.SOURCE_ORIGIN,
  INS.SECURITY,
  NULL SEC_HIER,
  NULL SEC_NODE,
  INS.PROFIT_CENTER,
  NULL PRO_HIER,
  NULL PRO_NODE,
  INS.COST_CENTER,
  NULL COST_HIER,
  NULL COST_NODE,
  INS.SEGMENT,
  NULL SEG_HIER,
  NULL SEG_NODE,
  INS.JOURNAL_NUMBER
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
      NULL     SOURCE_ORIGIN,
      NULL     SECURITY,
      NULL     PROFIT_CENTER,
      NULL     COST_CENTER,
      NULL     SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(ENTITY, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      NULL        COST_CENTER,
      NULL        SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL       SOURCE_ORIGIN,
      NULL       SECURITY,
      NULL       PROFIT_CENTER,
      NULL       COST_CENTER,
      NULL       SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND ENTITY_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      NULL        COST_CENTER,
      NULL        SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(FW_ACC, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      NULL        COST_CENTER,
      NULL        SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL     SOURCE_ORIGIN,
      NULL     SECURITY,
      NULL     PROFIT_CENTER,
      NULL     COST_CENTER,
      NULL     SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(CATEGORY, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL     SOURCE_ORIGIN,
      NULL     SECURITY,
      NULL     PROFIT_CENTER,
      NULL     COST_CENTER,
      NULL     SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(ANALYSIS, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      NULL        COST_CENTER,
      NULL        SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND SEGMENT_CTP NOT IN ('ALL', 'XXX', 'YYY')
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      NULL        COST_CENTER,
      NULL        SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      SOURCE_ORIGIN,
      NULL          SECURITY,
      NULL          PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(SOURCE_ORIGIN, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
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
      SO.COD  SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL     ANALYSIS,
      NULL     SEGMENT_CTP,
      NULL     SOURCE_ORIGIN,
      SECURITY,
      NULL     PROFIT_CENTER,
      NULL     COST_CENTER,
      NULL     SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(SECURITY, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
    GROUP BY
      SECURITY
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      COD_DEST1 SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      DEST1
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SECURITY = 'ALL'
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      COD_DEST1 SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          SEC_HIER,
          SEC_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SECURITY IS NULL
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
      ) A
        JOIN DEST1_GERARCHIA_FLAT B ON B.COD_DEST1_GERARCHIA = A.SEC_HIER
          AND (
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER1 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER2 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER3 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER4 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER5 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER6 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER7
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
      NULL          SOURCE_ORIGIN,
      NULL          SECURITY,
      PROFIT_CENTER,
      NULL          COST_CENTER,
      NULL          SEGMENT,
      NULL     JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(PROFIT_CENTER, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
    GROUP BY
      PROFIT_CENTER
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      COD_DEST2 PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      DEST2
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND PROFIT_CENTER = 'ALL'
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      COD_DEST2 PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          PRO_HIER,
          PRO_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND PROFIT_CENTER IS NULL
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
      ) A
        JOIN DEST2_GERARCHIA_FLAT B ON B.COD_DEST2_GERARCHIA = A.PRO_HIER
          AND (
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER1 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER2 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER3 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER4 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER5 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER6 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER7
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
      NULL        SEGMENT_CTP,
      NULL        SOURCE_ORIGIN,
      NULL        SECURITY,
      NULL        PROFIT_CENTER,
      COST_CENTER,
      NULL        SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(COST_CENTER, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
    GROUP BY
      COST_CENTER
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      COD_DEST3 COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      DEST3
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND COST_CENTER = 'ALL'
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      COD_DEST3 COST_CENTER,
      NULL      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          COST_HIER,
          COST_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND COST_CENTER IS NULL
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
      ) A
        JOIN DEST3_GERARCHIA_FLAT B ON B.COD_DEST3_GERARCHIA = A.COST_HIER
          AND (
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER1 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER2 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER3 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER4 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER5 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER6 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER7
          )
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(SEGMENT, 'ALL') <> 'ALL'
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
    GROUP BY
      SEGMENT
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      COD_DEST4 SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      DEST4
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEGMENT = 'ALL'
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      COD_DEST4 SEGMENT,
      NULL   JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          SEG_HIER,
          SEG_NODE
        FROM
          &RL_MDA_MAP&
        WHERE
          RULE_TYPE = 'INCLUDE'
          AND SEGMENT IS NULL
          AND ACCOUNT = CUR_ACC
          AND SCEN_TYPE = CUR_SCE
          AND BAL_TYPE = CUR_BAL
      ) A
        JOIN DEST4_GERARCHIA_FLAT B ON B.COD_DEST4_GERARCHIA = A.SEG_HIER
          AND (
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER1 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER2 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER3 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER4 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER5 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER6 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER7
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
      NULL      ANALYSIS,
      NULL      SEGMENT_CTP,
      NULL      SOURCE_ORIGIN,
      NULL      SECURITY,
      NULL      PROFIT_CENTER,
      NULL      COST_CENTER,
      NULL      SEGMENT,
      '%'||REPLACE(JOURNAL_NUMBER,' ','')||'%' JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE
      RULE_TYPE = 'INCLUDE'
      AND COALESCE(REPLACE(JOURNAL_NUMBER,' ',''),'')<>''
      AND ACCOUNT = CUR_ACC
      AND SCEN_TYPE = CUR_SCE
      AND BAL_TYPE = CUR_BAL
    GROUP BY
      '%'||REPLACE(JOURNAL_NUMBER,' ','')||'%'
  ) INS
;



--**************************************************************************************************************************************

--**************************************************************************************************************************************

-- Clear temporary table
DELETE FROM SM0040_DATA_01;

--Insert data into temporary table for future use
INSERT INTO
  SM0040_DATA_01 (
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
    SECURITY	,
    PROFIT_CENTER	,
    COST_CENTER	,
    SEGMENT	,
    SEGMENT_CTP		,
    ANALYSIS	,
    AMOUNT1	,
    AMOUNT2	,
    AMOUNT_TYPE		,
    PERIOD_LENGTH		,
    JOURNAL_MUMBER		,
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
  CUSTOM_DIM1	SECURITY	,
  CUSTOM_DIM2	PROFIT_CENTER	,
  CUSTOM_DIM3	COST_CENTER	,
  CUSTOM_DIM4	SEGMENT	,
  SEGMENT_CTP		,
  CUSTOM_DIM5	ANALYSIS	,
  SUM(AMOUNT1)	AMOUNT1	,
  SUM(AMOUNT2)	AMOUNT2	,
  AMOUNT_TYPE		,
  PERIOD_LENGTH		,
  JOURNAL_MUMBER		,
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
          TP.SECURITY = S1.CUSTOM_DIM1
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.PROFIT_CENTER = S1.CUSTOM_DIM2
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.COST_CENTER = S1.CUSTOM_DIM3
      )
      AND EXISTS (
        SELECT
          1
        FROM
          #TARGET_PARTITION# TP
        WHERE
          TP.SEGMENT = S1.CUSTOM_DIM4
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
      AND ('CP20250128'=COALESCE((SELECT TOP 1 JOURNAL_NUMBER FROM #TARGET_PARTITION# TP GROUP BY JOURNAL_NUMBER),'CP20250128') OR EXISTS (SELECT 1 FROM #TARGET_PARTITION# TP
      WHERE S1.JOURNAL_MUMBER LIKE TP.JOURNAL_NUMBER))
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
  CUSTOM_DIM1	,
  CUSTOM_DIM2	,
  CUSTOM_DIM3	,
  CUSTOM_DIM4	,
  SEGMENT_CTP		,
  CUSTOM_DIM5	,
  AMOUNT_TYPE		,
  PERIOD_LENGTH		,
  JOURNAL_MUMBER		,
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
DELETE FROM SM0040_DELETE_01;

-- Insert row into the work table
  INSERT INTO
    SM0040_DELETE_01 (
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
      SOURCE_ORIGIN,
      SECURITY,
      PROFIT_CENTER,
      COST_CENTER,
      SEGMENT,
      JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL     JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      SO.COD SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
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
      NULL    SOURCE_ORIGIN,
      SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(SECURITY, 'ALL') <> 'ALL'
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
      NULL    SOURCE_ORIGIN,
      COD_DEST1 SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      DEST1
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SECURITY = 'ALL'
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
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN,
      B.COD_DEST1 SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          SEC_HIER,
          SEC_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SEC_HIER IS NOT NULL
          AND SEC_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN DEST1_GERARCHIA_FLAT B ON B.COD_DEST1_GERARCHIA = A.SEC_HIER
          AND (
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER1 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER2 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER3 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER4 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER5 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER6 OR
            SUBSTR_AFTER (A.SEC_NODE, '|') = B.COD_DEST1_ELEGER7
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(PROFIT_CENTER, 'ALL') <> 'ALL'
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      COD_DEST2 PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      DEST2
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND PROFIT_CENTER = 'ALL'
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
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      B.COD_DEST2 PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          PRO_HIER,
          PRO_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND PRO_HIER IS NOT NULL
          AND PRO_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN DEST2_GERARCHIA_FLAT B ON B.COD_DEST2_GERARCHIA = A.PRO_HIER
          AND (
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER1 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER2 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER3 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER4 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER5 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER6 OR
            SUBSTR_AFTER (A.PRO_NODE, '|') = B.COD_DEST2_ELEGER7
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(COST_CENTER, 'ALL') <> 'ALL'
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      COD_DEST3 COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      DEST3
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND COST_CENTER = 'ALL'
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
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      COD_DEST3 COST_CENTER,
      NULL    SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          COST_HIER,
          COST_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND COST_HIER IS NOT NULL
          AND COST_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN DEST3_GERARCHIA_FLAT B ON B.COD_DEST3_GERARCHIA = A.COST_HIER
          AND (
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER1 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER2 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER3 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER4 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER5 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER6 OR
            SUBSTR_AFTER (A.COST_NODE, '|') = B.COD_DEST3_ELEGER7
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(SEGMENT, 'ALL') <> 'ALL'
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      COD_DEST4 SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      DEST4
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SEGMENT = 'ALL'
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
      NULL    SEGMENT_CTP,
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      B.COD_DEST4 SEGMENT,
      NULL    JOURNAL_NUMBER
    FROM
      (
        SELECT DISTINCT
          SEG_HIER,
          SEG_NODE
        FROM
          &RL_MDA_MAP&
        WHERE 1=1
          AND SEG_HIER IS NOT NULL
          AND SEG_NODE IS NOT NULL
          AND OID = CUR_DEL_OID
      ) A
        JOIN DEST4_GERARCHIA_FLAT B ON B.COD_DEST4_GERARCHIA = A.SEG_HIER
          AND (
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER1 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER2 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER3 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER4 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER5 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER6 OR
            SUBSTR_AFTER (A.SEG_NODE, '|') = B.COD_DEST4_ELEGER7
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
      NULL    SOURCE_ORIGIN,
      NULL    SECURITY,
      NULL    PROFIT_CENTER,
      NULL    COST_CENTER,
      NULL    SEGMENT,
      '%'||REPLACE(JOURNAL_NUMBER,' ','')||'%' JOURNAL_NUMBER
    FROM
      &RL_MDA_MAP&
    WHERE 1=1
      AND COALESCE(REPLACE(JOURNAL_NUMBER,' ',''),'')<>''
      AND OID = CUR_DEL_OID
;

-- Confirm filters to apply
SELECT COUNT(DISTINCT ENTITY) INTO CUR_DEL_ENT FROM SM0040_DELETE_01 WHERE ENTITY IS NOT NULL;
SELECT COUNT(DISTINCT ENTITY_CTP) INTO CUR_DEL_ENT_CTP FROM SM0040_DELETE_01 WHERE ENTITY_CTP IS NOT NULL;
SELECT COUNT(DISTINCT FW_ACC) INTO CUR_DEL_ACC FROM SM0040_DELETE_01 WHERE FW_ACC IS NOT NULL;
SELECT COUNT(DISTINCT CATEGORY) INTO CUR_DEL_CAT FROM SM0040_DELETE_01 WHERE CATEGORY IS NOT NULL;
SELECT COUNT(DISTINCT ANALYSIS) INTO CUR_DEL_ANA FROM SM0040_DELETE_01 WHERE ANALYSIS IS NOT NULL;
SELECT COUNT(DISTINCT SEGMENT_CTP) INTO CUR_DEL_SEG_CTP FROM SM0040_DELETE_01 WHERE SEGMENT_CTP IS NOT NULL;
SELECT COUNT(DISTINCT SOURCE_ORIGIN) INTO CUR_DEL_ORI FROM SM0040_DELETE_01 WHERE SOURCE_ORIGIN IS NOT NULL;
SELECT COUNT(DISTINCT SECURITY) INTO CUR_DEL_SEC FROM SM0040_DELETE_01 WHERE SECURITY IS NOT NULL;
SELECT COUNT(DISTINCT PROFIT_CENTER) INTO CUR_DEL_PRO FROM SM0040_DELETE_01 WHERE PROFIT_CENTER IS NOT NULL;
SELECT COUNT(DISTINCT COST_CENTER) INTO CUR_DEL_COS FROM SM0040_DELETE_01 WHERE COST_CENTER IS NOT NULL;
SELECT COUNT(DISTINCT SEGMENT) INTO CUR_DEL_SEG FROM SM0040_DELETE_01 WHERE SEGMENT IS NOT NULL;
SELECT COUNT(DISTINCT JOURNAL_NUMBER) INTO CUR_DEL_JOU FROM SM0040_DELETE_01 WHERE JOURNAL_NUMBER IS NOT NULL;

-- Combine filters
DELETE FROM SM0040_DELETE_02;

INSERT INTO SM0040_DELETE_02 (
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
      SOURCE_ORIGIN,
      SECURITY,
      PROFIT_CENTER,
      COST_CENTER,
      SEGMENT,
      JOURNAL_NUMBER
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
  so.SOURCE_ORIGIN,
  s.SECURITY,
  pc.PROFIT_CENTER,
  cc.COST_CENTER,
  sg.SEGMENT,
  j.JOURNAL_NUMBER
FROM
  (SELECT
      CUR_DEL_OID OID,
      CUR_ACC ACCOUNT,
      CUR_SCE SCEN_TYPE,
      CUR_BAL BAL_TYPE
  FROM DUMMY) base
  LEFT JOIN (SELECT DISTINCT ENTITY FROM SM0040_DELETE_01 WHERE ENTITY IS NOT NULL) e ON CUR_DEL_ENT <> 0
  LEFT JOIN (SELECT DISTINCT ENTITY_CTP FROM SM0040_DELETE_01 WHERE ENTITY_CTP IS NOT NULL) ec ON CUR_DEL_ENT_CTP <> 0
  LEFT JOIN (SELECT DISTINCT FW_ACC FROM SM0040_DELETE_01 WHERE FW_ACC IS NOT NULL) fa ON CUR_DEL_ACC <> 0
  LEFT JOIN (SELECT DISTINCT CATEGORY FROM SM0040_DELETE_01 WHERE CATEGORY IS NOT NULL) c ON CUR_DEL_CAT <> 0
  LEFT JOIN (SELECT DISTINCT ANALYSIS FROM SM0040_DELETE_01 WHERE ANALYSIS IS NOT NULL) a ON CUR_DEL_ANA <> 0
  LEFT JOIN (SELECT DISTINCT SEGMENT_CTP FROM SM0040_DELETE_01 WHERE SEGMENT_CTP IS NOT NULL) sc ON CUR_DEL_SEG_CTP <> 0
  LEFT JOIN (SELECT DISTINCT SOURCE_ORIGIN FROM SM0040_DELETE_01 WHERE SOURCE_ORIGIN IS NOT NULL) so ON CUR_DEL_ORI <> 0
  LEFT JOIN (SELECT DISTINCT SECURITY FROM SM0040_DELETE_01 WHERE SECURITY IS NOT NULL) s ON CUR_DEL_SEC <> 0
  LEFT JOIN (SELECT DISTINCT PROFIT_CENTER FROM SM0040_DELETE_01 WHERE PROFIT_CENTER IS NOT NULL) pc ON CUR_DEL_PRO <> 0
  LEFT JOIN (SELECT DISTINCT COST_CENTER FROM SM0040_DELETE_01 WHERE COST_CENTER IS NOT NULL) cc ON CUR_DEL_COS <> 0
  LEFT JOIN (SELECT DISTINCT SEGMENT FROM SM0040_DELETE_01 WHERE SEGMENT IS NOT NULL) sg ON CUR_DEL_SEG <> 0
  LEFT JOIN (SELECT DISTINCT JOURNAL_NUMBER FROM SM0040_DELETE_01 WHERE JOURNAL_NUMBER IS NOT NULL) j ON CUR_DEL_JOU <> 0;

-- Delete data from temporary table according to EXCLUDE filters
DELETE FROM SM0040_DATA_01 BD
WHERE EXISTS (
  SELECT
    1
  FROM
    SM0040_DELETE_02 CP
  WHERE 1=1
    AND (CUR_DEL_ENT = 0 OR BD.ENTITY = CP.ENTITY)
    AND (CUR_DEL_ENT_CTP = 0 OR BD.ENTITY_CTP = CP.ENTITY_CTP)
    AND (CUR_DEL_ACC = 0 OR BD.FW_ACC = CP.FW_ACC)
    AND (CUR_DEL_CAT = 0 OR BD.CATEGORY = CP.CATEGORY)
    AND (CUR_DEL_ANA = 0 OR BD.ANALYSIS = CP.ANALYSIS)
    AND (CUR_DEL_SEG_CTP = 0 OR BD.SEGMENT_CTP = CP.SEGMENT_CTP)
    AND (CUR_DEL_ORI = 0 OR BD.SOURCE_ORIGIN = CP.SOURCE_ORIGIN)
    AND (CUR_DEL_SEC = 0 OR BD.SECURITY = CP.SECURITY)
    AND (CUR_DEL_PRO = 0 OR BD.PROFIT_CENTER = CP.PROFIT_CENTER)
    AND (CUR_DEL_COS = 0 OR BD.COST_CENTER = CP.COST_CENTER)
    AND (CUR_DEL_SEG = 0 OR BD.SEGMENT = CP.SEGMENT)
    AND (CUR_DEL_JOU = 0 OR BD.JOURNAL_MUMBER LIKE CP.JOURNAL_NUMBER)
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
  NULL                     FW_ACC,
  '&OUT_CATEGORY&'         CATEGORY,
  BD.ANALYSIS,
  BD.CURRENCY1,
  BD.CURRENCY2,
  SUM(BD.AMOUNT1)     AMOUNT1,
  SUM(BD.AMOUNT2)     AMOUNT2,
  'U'                      SCALE,
  BD.BAL_TYPE,
  COALESCE(SIGN.SIGN, '1') SIGN,
  '&OUT_TXT_ORIGIN&'       TEXT_ORIGIN,
  BD.PERIOD_LENGTH,
  'SM0040'                 PROVENIENZA,
  COALESCE('#USER#', '')   USERUPD,
  CURRENT_TIMESTAMP        DATEUPD,
  0                        EN_VERSION
FROM SM0040_DATA_01 BD
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
  BD.ANALYSIS,
  BD.SEGMENT_CTP,
  BD.SOURCE_ORIGIN,
  BD.CURRENCY1,
  BD.CURRENCY2,
  COALESCE(SIGN.SIGN, '1'),
  BD.BAL_TYPE,
  BD.PERIOD_LENGTH;


END FOR;

CLOSE CUR_MAP;
