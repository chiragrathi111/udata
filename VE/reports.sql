Report View for Product:-

CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.PP_Product_BOM_ID,d.deptname As departmentName,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,
pr.value,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
JOIN adempiere.pi_deptartment d ON d.pi_deptartment_id = pr.pi_deptartment_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY pp.m_product_id,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,pr.m_product_category_id,
pbom.PP_Product_BOM_ID,pr.value,d.deptname Order BY pp.m_product_id desc; 

=====================================================================================================

