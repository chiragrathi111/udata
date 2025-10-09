CREATE OR REPLACE VIEW adempiere.pi_storagedetailbyproduct AS
 SELECT pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pbom.pp_product_bom_id,
    sum(
        CASE
            WHEN pp.issotrx = 'N'::bpchar THEN pp.quantity
            ELSE 0::numeric
        END) AS availablecount,
    pr.value,
    pr.created AS m_product_created,
    pr.createdby AS m_product_createdby,
    pr.updated AS m_product_updated,
    pr.updatedby AS m_product_updatedby,
    pr.isactive AS product_isactive,
    pp.ad_client_id,
    pp.ad_org_id,
    d.pi_deptartment_id,l.m_warehouse_id
   FROM adempiere.pi_productlabel pp
     JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
     LEFT JOIN adempiere.pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id
     JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
     JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
     LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
   JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
  WHERE NOT (EXISTS ( SELECT 1
           FROM adempiere.pi_productlabel pp_sales
          WHERE pp_sales.labeluuid::text = pp.labeluuid::text AND pp_sales.issotrx = 'Y'::bpchar))
  GROUP BY pp.m_product_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby,l.m_warehouse_id
  ORDER BY pp.m_product_id DESC;

=====================================================================================================
  INSERT INTO adempiere.ad_printformatitem (
    ad_printformatitem_id,ad_client_id,ad_org_id,isactive,created,createdby,updated,updatedby,
    ad_printformat_id,name,printname,isprinted,printareatype,seqno,printformattype,ad_column_id,
    xspace,yspace,xposition,yposition,ad_printformatitem_uu,
    maxwidth,isheightoneline,maxheight,fieldalignmenttype,linealignmenttype,sortno
) VALUES (1001132,1000000,0,'Y',now(),100,now(),100,1000023,'Warehouse','Warehouse','Y',                           
'C',150,'F',1000343,0,0,0,0,'6df6d9ad-b57d-4fd0-b473-095b0cdchir2',0,'N',0,'L','X',0);
=====================================================================================================




=====================================================================================================





=====================================================================================================