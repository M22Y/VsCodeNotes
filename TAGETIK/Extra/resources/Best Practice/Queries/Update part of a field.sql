UPDATE CONTO
SET DESC_CONTO0 = REPLACE(DESC_CONTO0, 'Actifs au titre de droits d'utilisation', 'Actifs au titre de droits d'utilisation Batiments - cout')
WHERE DESC_CONTO0 LIKE '%Actifs au titre de droits d'utilisation - cout%';