Deleted multiple bom Product:-

DELETE FROM adempiere.pp_product_bom
WHERE m_product_id IN (1003854, 1003856, 1003857)

Set is bom in Product window:-

UPDATE adempiere.m_product
SET isbom = 'Y'
WHERE m_product_id IN (1003854, 1003856, 1003857);

DELETE FROM adempiere.pp_product_bom_trl
WHERE pp_product_bom_id IN (
    SELECT pp_product_bom_id
    FROM adempiere.pp_product_bom
    WHERE m_product_id = 1004996
);


DELETE FROM adempiere.pp_product_bom
WHERE m_product_id IN (1004997,
1004998,
1004999,
1005000,
1005001)


SELECT m_product_id, name
FROM adempiere.m_product
WHERE name IN (
'810008HWH - A1 AURA 8 M HORI. PLATE WHITE',
'810008HZB - A3 AURA 8 M HORI. PLATE ZEBRANA',
'810008JB - A2 AURA 8 M PLATE SQUARE JET BLACK',
'810008OB - A4 AURA 8 M PLATE SQUARE OCEAN BLUE',
'810008RG - A2 AURA 8 M PLATE SQUARE ROSE GOLD',
'810008SG - A4 AURA 8 M PLATE SQUARE SAGE GREEN',
'810008WH - A1 AURA 8 M SQUARE PLATE WHITE',
'810008ZB - A3 AURA 8 M PLATE SQUARE ZEBRANA',
'810014AG - A2 AURA 14 M PLATE ANTIQUE GOLD',
'810014BR - A3 AURA 14 M PLATE BRAZILLIAN ROSEWOOD',
'810014CR - A4 AURA 14 M PLATE CRIMSON RED',
'810014GS - A2 AURA 14 M PLATE GUN METALLIC SILVER'
);


DELETE FROM adempiere.pp_product_bom_trl
WHERE pp_product_bom_id IN (
    SELECT pp_product_bom_id
    FROM adempiere.pp_product_bom
    WHERE m_product_id IN ('1004141',
'1004142',
'1004143',
'1004144',
'1004145',
'1004146',
'1004147',
'1004148',
'1004149',
'1004150',
'1004151',
'1004152')
);


DELETE FROM adempiere.pp_product_bom
WHERE m_product_id IN ('1004141',
'1004142',
'1004143',
'1004144',
'1004145',
'1004146',
'1004147',
'1004148',
'1004149',
'1004150',
'1004151',
'1004152')
