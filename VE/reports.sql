Report View for Product:-

CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.pp_product_bom_id,
sum(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availablecount,
pr.value,pr.created AS m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,
pr.updatedby AS m_product_updatedby,pr.isactive AS product_isactive,pp.ad_client_id,pp.ad_org_id,d.pi_deptartment_id,l.m_warehouse_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
LEFT JOIN adempiere.pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
WHERE pp.islabeldiscarded = 'N' AND ltt.returns = 'N' AND NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY pp.m_product_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, l.m_warehouse_id
ORDER BY pp.m_product_id DESC;

=====================================================================================================
New Product View in jasper:-

SELECT pi.labeluuid AS label, mp.name AS productName,ml.m_inout_id,pi.quantity AS quantity,l.value As locatorName,
mp.name AS productName FROM adempiere.pi_productlabel pi
JOIN adempiere.m_inoutline ml on ml.m_inoutline_id = pi.m_inoutline_id 
JOIN adempiere.m_product mp on mp.m_product_id = pi.m_product_Id 
JOIN adempiere.m_locator l ON l.m_locator_id = pi.m_locator_id
JOIN adempiere.m_inout mi ON mi.m_inout_id = ml.m_inout_id
JOIN adempiere.c_order co ON co.c_order_id = mi.c_order_id
WHERE ml.ad_client_id = 1000000 AND l.m_locator_id = 1000124 AND pi.m_product_id = 1001485
AND co.documentno = '800996';

SELECT pi.labeluuid AS label, mp.name AS productName,ml.m_inout_id,pi.quantity AS quantity,l.value As locatorName,
mp.name AS productName FROM adempiere.pi_productlabel pi
JOIN adempiere.m_inoutline ml on ml.m_inoutline_id = pi.m_inoutline_id 
JOIN adempiere.m_product mp on mp.m_product_id = pi.m_product_Id 
JOIN adempiere.m_locator l ON l.m_locator_id = pi.m_locator_id
JOIN adempiere.m_inout mi ON mi.m_inout_id = ml.m_inout_id
JOIN adempiere.c_order co ON co.c_order_id = mi.c_order_id
WHERE ml.ad_client_id =  $P{AD_CLIENT_ID} AND
($P{M_LOCATOR_ID} IS NULL OR l.m_locator_id IN ($P!{M_LOCATOR_ID})) AND
($P{M_PRODUCT_ID} IS NULL OR pi.m_product_id IN ($P!{M_PRODUCT_ID})) AND
co.documentno = $P{PO_DOCUMENT_NO} ;
============================================================================================================================================
Report View for Locator:-

CREATE OR REPLACE VIEW adempiere.pi_productlabelViewBylocator AS
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.pp_product_bom_id,l.m_locatortype_id,
pp.m_locator_id,sum( CASE  WHEN pp.issotrx = 'N' THEN pp.quantity  ELSE 0 END) AS availablecount,
d.pi_deptartment_id,pr.value,pr.created AS m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,
pr.updatedby AS m_product_updatedby,pr.isactive AS product_isactive,l.isactive AS locator_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
LEFT JOIN adempiere.pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
WHERE pp.islabeldiscarded = 'N' AND ltt.returns = 'N' AND NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales
WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY pp.m_product_id, w.m_warehouse_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, l.isactive, l.m_locatortype_id, pp.m_locator_id, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby
ORDER BY pp.m_locator_id DESC;
======================================================================================================================================
Actual Reports:-

CREATE OR REPLACE VIEW adempiere.pi_storageDetailByProduct AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.pp_product_bom_id,
sum(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availablecount,
pr.value,pr.created AS m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,
pr.updatedby AS m_product_updatedby,pr.isactive AS product_isactive,pp.ad_client_id,pp.ad_org_id,d.pi_deptartment_id,l.m_warehouse_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
LEFT JOIN adempiere.pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
WHERE pp.islabeldiscarded = 'N' AND ltt.returns = 'N' AND NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY pp.m_product_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, l.m_warehouse_id
ORDER BY pp.m_product_id DESC;


CREATE OR REPLACE VIEW adempiere.pi_storageDetailByLocator AS
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.pp_product_bom_id,l.m_locatortype_id,
pp.m_locator_id,sum( CASE  WHEN pp.issotrx = 'N' THEN pp.quantity  ELSE 0 END) AS availablecount,
d.pi_deptartment_id,pr.value,pr.created AS m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,
pr.updatedby AS m_product_updatedby,pr.isactive AS product_isactive,l.isactive AS locator_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
LEFT JOIN adempiere.pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
WHERE pp.islabeldiscarded = 'N' AND ltt.returns = 'N' AND NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales
WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY pp.m_product_id, w.m_warehouse_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, l.isactive, l.m_locatortype_id, pp.m_locator_id, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby
ORDER BY pp.m_locator_id DESC;
==============================================================================================================================================
Discard View:-

CREATE OR REPLACE VIEW adempiere.pi_productlabeldiscardview AS 
SELECT pr.name AS product_name,pr.m_product_id,l.m_locator_id,u.name AS supervisor,d.pi_deptartment_id,u.ad_user_id,
d.value AS department,to_char(p.updated::date::timestamp with time zone, 'DD-MM-YYYY'::text) AS date,
p.updated,p.quantity,p.labeluuid,p.ad_client_id,p.ad_org_id FROM adempiere.pi_productlabel p
JOIN adempiere.m_locator l ON l.m_locator_id = p.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = p.m_product_id
JOIN adempiere.pi_deptartment d ON d.pi_deptartment_id = pr.pi_deptartment_id JOIN adempiere.ad_user u ON u.ad_user_id = p.updatedby
WHERE p.islabeldiscarded = 'Y' ORDER BY p.m_product_id DESC, p.updated;
==============================================================================================================================================
* Insert any new record on purcase order:-

INSERT INTO adempiere.c_order (
    c_order_id,
    ad_client_id,
    ad_org_id,
    isactive,
    created,
    createdby,
    updated,
    updatedby,

    -- PO Header
    issotrx,
    documentno,
    c_doctype_id,
    c_doctypetarget_id,

    dateordered,
    dateacct,
    datepromised,

    c_bpartner_id,
    c_bpartner_location_id,
    ad_user_id,
    m_warehouse_id,

    c_currency_id,
    m_pricelist_id,
    c_paymentterm_id,

    paymentrule,
    invoicerule,
    deliveryrule,
    freightcostrule,
    priorityrule,
    deliveryviarule,

    totallines,
    grandtotal,

    docstatus,
    docaction,

    posted,
    processed
)
VALUES (
    1009001,                -- c_order_id (must be unique)
    1000000,                -- ad_client_id
    1000000,                -- ad_org_id
    'Y',                    -- isactive
    NOW(), 100, NOW(), 100,

    'N',                    -- issotrx (N = Purchase Order)
    'PO-Test-001',          -- documentno
    1000016,                -- c_doctype_id
    1000016,                -- c_doctypetarget_id

    NOW(),                  -- dateordered
    NOW(),                  -- dateacct
    NOW(),                  -- datepromised

    1000003,                -- c_bpartner_id
    1000002,                -- c_bpartner_location_id
    100,                    -- ad_user_id
    1000000,                -- m_warehouse_id

    304,                    -- c_currency_id
    1000000,                -- m_pricelist_id
    1000000,                -- c_paymentterm_id

    'P',                    -- paymentrule (P = OnCredit)
    'I',                    -- invoicerule  (Immediately)
    'A',                    -- deliveryrule (Availability)
    'I',                    -- freightcostrule (Included)
    '5',                    -- priorityrule
    'D',                    -- deliveryviarule (Delivery)

    0,                      -- totallines
    0,                      -- grandtotal

    'DR',                   -- docstatus
    'CO',                   -- docaction

    'N',                    -- posted
    'N'                     -- processed
);
select * from adempiere.c_order where ad_client_id = 1000000 
=============================================================================================================================
Working:-

CREATE OR REPLACE VIEW adempiere.pi_productlabeldiscardviews AS 
SELECT pr.name AS product_name,pr.m_product_id,l.m_locator_id,u.name AS supervisor,d.pi_deptartment_id,u.ad_user_id,
d.value AS department,
TO_CHAR(p.updated,'DD-MM-YYYY HH12:MI AM') AS date,
p.updated,p.quantity,p.labeluuid,p.ad_client_id,p.ad_org_id,p.pi_paorder_id FROM adempiere.pi_productlabel p
JOIN adempiere.m_locator l ON l.m_locator_id = p.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = p.m_product_id
JOIN adempiere.pi_deptartment d ON d.pi_deptartment_id = pr.pi_deptartment_id JOIN adempiere.ad_user u ON u.ad_user_id = p.updatedby
JOIN adempiere.pi_paorder pa ON pa.pi_paorder_id = p.pi_paorder_id WHERE p.islabeldiscarded = 'Y' ORDER BY p.m_product_id DESC, p.updated;

