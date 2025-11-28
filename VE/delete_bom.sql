Deleted multiple bom Product:-

DELETE FROM adempiere.pp_product_bom
WHERE m_product_id IN (1003854, 1003856, 1003857)

Set is bom in Product window:-

UPDATE adempiere.m_product
SET isbom = 'Y'
WHERE m_product_id IN (1003854, 1003856, 1003857);


=============================================================
DELETE FROM adempiere.pp_product_bom_trl
WHERE pp_product_bom_id IN (
    SELECT pp_product_bom_id
    FROM adempiere.pp_product_bom
    WHERE m_product_id IN (
1004996)
);
-----------------------------------------------------------

DELETE FROM adempiere.pp_product_bom
WHERE m_product_id IN (
1005001);
---------------------------------------------------------

SELECT m_product_id, name
FROM adempiere.m_product
WHERE name IN (
'810008HWH - A1 AURA 8 M HORI. PLATE WHITE',
'810008HZB - A3 AURA 8 M HORI. PLATE ZEBRANA'
);
-----------------------------------------------------------------
