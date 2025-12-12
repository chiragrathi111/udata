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
Deleted all bom:-

DELETE FROM adempiere.pp_product_bomline
WHERE pp_product_bom_id IN (
    SELECT pb2.pp_product_bom_id
    FROM adempiere.pp_product_bom pb2
    JOIN adempiere.m_product pr ON pr.m_product_id = pb2.m_product_id
    LEFT JOIN adempiere.pp_product_bomline pbl 
           ON pb2.pp_product_bom_id = pbl.pp_product_bom_id
    WHERE pr.ad_client_id = 1000000
      AND pbl.pp_product_bomline_id IS NULL
      AND pr.PI_Deptartment_ID IN (1000007,1000008,1000011)
);

DELETE FROM adempiere.pp_product_bom_trl
WHERE pp_product_bom_id IN (
    SELECT pb2.pp_product_bom_id
    FROM adempiere.pp_product_bom pb2
    JOIN adempiere.m_product pr ON pr.m_product_id = pb2.m_product_id
    LEFT JOIN adempiere.pp_product_bomline pbl 
           ON pb2.pp_product_bom_id = pbl.pp_product_bom_id
    WHERE pr.ad_client_id = 1000000
      AND pbl.pp_product_bomline_id IS NULL
      AND pr.PI_Deptartment_ID IN (1000007,1000008,1000011)
);

DELETE FROM adempiere.pp_product_bom pb
WHERE pb.pp_product_bom_id IN (
    SELECT pb2.pp_product_bom_id
    FROM adempiere.pp_product_bom pb2
    JOIN adempiere.m_product pr ON pr.m_product_id = pb2.m_product_id
    LEFT JOIN adempiere.pp_product_bomline pbl 
           ON pb2.pp_product_bom_id = pbl.pp_product_bom_id
    WHERE pr.ad_client_id = 1000000
      AND pbl.pp_product_bomline_id IS NULL
      AND pr.PI_Deptartment_ID IN (1000007,1000008,1000011)
);
------------------------------------------------------------------------

Get list of bom:-
SELECT pb.m_product_id, pb.pp_product_bom_id,pr.PI_Deptartment_ID,pr.name
FROM adempiere.pp_product_bom pb
JOIN adempiere.m_product pr ON pr.m_product_id = pb.m_product_id
LEFT JOIN adempiere.pp_product_bomline pbl 
       ON pb.pp_product_bom_id = pbl.pp_product_bom_id
WHERE pr.ad_client_id = 1000000 and pbl.pp_product_bomline_id IS NULL AND pr.PI_Deptartment_ID IN (1000007,1000008,1000011);

===========================================================================================
Updated Product records:-
UPDATE adempiere.m_product
SET isbom = 'Y',
pi_deptartment_id = 1000007,
c_uom_id = 100,
productcount = 0
WHERE m_product_id IN (
1016219
);

------------------------------------------------------------------------------