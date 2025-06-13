Media Production View:-

CREATE OR REPLACE VIEW adempiere.tcvn_mediaproduction AS
SELECT 
    pr.m_product_id,
    pr.name AS mediacategory,
    pr.description AS codeifany,
    COALESCE(ml.openingstock, 0) AS openingbalance,
    COALESCE(ml.stocked, 0) AS mediastocked,
    COALESCE(mol.totalqty, 0) AS issuetoct,
    COALESCE(ml.openingstock, 0) + COALESCE(ml.stocked, 0) - COALESCE(mol.totalqty, 0) - COALESCE(di.discarded_qty, 0) AS balance,
    ml.created,
    pr.ad_client_id,
    pr.ad_org_id,
	COALESCE(di.discarded_qty, 0) AS discardedquantity,
    COALESCE(di.discarded_count, 0) AS discarded_count
FROM adempiere.m_product pr
LEFT JOIN (
    SELECT 
        pr_1.m_product_id,
        min(date(ml_1.created)) AS created,
        NULLIF(sum(
            CASE
                WHEN date_trunc('month', ml_1.created)::date = date_trunc('month', CURRENT_DATE::timestamp with time zone)::date THEN ml_1.quantity
                ELSE 0
            END), 0) AS openingstock,
        NULLIF(sum(
            CASE
                WHEN date_trunc('month', ml_1.created)::date <> date_trunc('month', CURRENT_DATE::timestamp with time zone)::date THEN ml_1.quantity
                ELSE 0
            END), 0) AS stocked
    FROM adempiere.tc_medialine ml_1
    JOIN adempiere.m_product pr_1 ON pr_1.m_product_id = ml_1.m_product_id 
    GROUP BY pr_1.m_product_id
) ml ON pr.m_product_id = ml.m_product_id 
LEFT JOIN (
    SELECT 
        pro.m_product_id,
        sum(mol_1.quantity) AS totalqty
    FROM adempiere.tc_mediaoutline mol_1 
    JOIN adempiere.m_product pro ON pro.m_product_id = mol_1.m_product_id
    GROUP BY pro.m_product_id
) mol ON pr.m_product_id = mol.m_product_id
LEFT JOIN (
    SELECT 
        ml.m_product_id,
        sum(CASE WHEN mlq.isdiscarded = 'Y' THEN 1 ELSE 0 END) AS discarded_count,
        sum(CASE WHEN mlq.isdiscarded = 'Y' THEN ml.quantity ELSE 0 END) AS discarded_qty
    FROM adempiere.tc_medialine ml
    JOIN adempiere.tc_mediaLabelQr mlq ON ml.tc_medialine_id = mlq.tc_medialine_id
    GROUP BY ml.m_product_id
) di ON pr.m_product_id = di.m_product_id
JOIN adempiere.m_product_category pc ON pr.m_product_category_id = pc.m_product_category_id 
WHERE pc.name = 'BMedia';

=============================================================================================


