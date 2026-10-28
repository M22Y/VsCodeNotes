SELECT
    Category,
    SUM(T.Amount) AS Total_Amount
FROM
(
    /* REQ 4 : dati_rett_riga_cons_3 */
    SELECT
        D.COD_CATEGORIA AS Category,
        D.IMPORTO AS Amount
    FROM dati_rett_riga_cons_3 D
    WHERE D.COD_SCENARIO = '2027BDGPSCCAD'
      AND D.COD_PERIODO = '12'
      AND D.COD_CONTO = '4500017'

    UNION ALL

    /* REQ 7 : dati_saldi_cons_3 */
    SELECT
        D.COD_CATEGORIA AS Category,
        D.IMPORTO AS Amount
    FROM dati_saldi_cons_3 D
    WHERE D.COD_SCENARIO = '2027BDGPSCCAD'
      AND D.COD_PERIODO = '12'
      AND D.COD_CONTO = '4500017'
) T
GROUP BY Category

