SELECT A.REF_NUM NUMBER,
    B.REF_DESC DESCRIPTION,
    B.REF_TYPE TYPE,
    A.ACCOUNT || ' - ' || C.DESC_CONTO0 ACCOUNT,
    A.BAL_TYPE || ' - ' || D.DESC0 BALANCE_TYPE,
    A.ENTITY || ' - ' || E.DESC_AZIENDA0 ENTITY,
    B.SIGN,
    SUM(A.AMOUNT1) AMOUNT,
    A.TEXT_ORIGIN
FROM $ { DATASETPARTITION(
        "003",
        "000061",
        PROCESS($Scenario.code, $Period.code).code,
        $Scenario.code,
        $Period.code
    ) } A
    JOIN (
        SELECT REF_NUM || ACC_IN || BAL_TYPE_IN WOW,
            REF_DESC,
            SIGN,
            'Primary' REF_TYPE
        FROM AW_003_000060_000001
        UNION ALL
        SELECT REF_NUM || ACCOUNT_OUT || BAL_TYPE_OUT,
            REF_DESC,
            SIGN2,
            'Secondary' REF_TYPE
        FROM AW_003_000060_000001
    ) B ON A.REF_NUM || A.ACCOUNT || A.BAL_TYPE = B.WOW
    JOIN CONTO C ON C.COD_CONTO = A.ACCOUNT
    JOIN ED_CO_00002 D ON D.COD = A.BAL_TYPE
    JOIN AZIENDA E ON E.COD_AZIENDA = A.ENTITY
WHERE A.REF_NUM = $ { $ANL_CO_00009.code }
    AND A.SCEN_TYPE = $ { $ANL_CO_00007.code }
GROUP BY A.REF_NUM,
    B.REF_DESC,
    B.REF_TYPE,
    A.ACCOUNT || ' - ' || C.DESC_CONTO0,
    A.BAL_TYPE || ' - ' || D.DESC0,
    A.ENTITY || ' - ' || E.DESC_AZIENDA0,
    B.SIGN,
    A.TEXT_ORIGIN
ORDER BY B.REF_TYPE,
    A.ACCOUNT || ' - ' || C.DESC_CONTO0,
    A.BAL_TYPE || ' - ' || D.DESC0,
    A.ENTITY || ' - ' || E.DESC_AZIENDA0