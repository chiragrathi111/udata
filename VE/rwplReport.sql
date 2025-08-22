-- to see storage detail by product
CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pr.erpcode,pbom.PP_Product_BOM_ID,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY pp.m_product_id,pr.weight,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,pr.m_product_category_id,pr.erpcode,
pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_product_id desc;

-- to see storage detail by locator
CREATE OR REPLACE VIEW adempiere.pi_productlabelViews AS 
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pr.erpcode,pbom.PP_Product_BOM_ID,l.m_locatortype_id,pp.m_locator_id,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,l.isactive AS locator_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY pp.m_product_id,pr.weight,w.m_warehouse_id,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,l.isactive,l.m_locatortype_id, 
pp.m_locator_id,pr.m_product_category_id,pr.erpcode,pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_locator_id desc;


CREATE OR REPLACE VIEW adempiere.sales_plan_detail_view AS
SELECT spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id,sp.salesplandate,
SUM(pi.totalqnty) AS total_quantity,
SUM(pi.completedqnty) AS completed_quantity,
SUM(pi.totalqnty - pi.completedqnty) AS pending_quantity,
CASE WHEN pi.totalqnty = pi.completedqnty THEN 'Completed'
ELSE 'In Progress' END AS status,spl.ad_client_id,spl.ad_org_id
FROM adempiere.pi_salesplanline spl
JOIN adempiere.pi_salesplan sp ON sp.pi_salesplan_id = spl.pi_salesplan_id
JOIN adempiere.pi_planitem pi ON pi.pi_salesplanline_id = spl.pi_salesplanline_id
GROUP BY spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id,sp.salesplandate,
spl.ad_client_id,spl.ad_org_id,pi.totalqnty,pi.completedqnty
ORDER BY sp.salesplandate DESC,spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id;

CREATE OR REPLACE VIEW adempiere.pir_emptylocator AS
SELECT l.m_locator_id,l.value AS locator_name,l.ad_client_id,l.ad_org_id
FROM adempiere.m_locator l LEFT JOIN adempiere.pi_productlabel s ON l.m_locator_id = s.m_locator_id
WHERE NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales
WHERE pp_sales.labeluuid = s.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY l.m_locator_id, l.value, s.ad_client_id, s.ad_org_id
HAVING COALESCE(sum(s.quantity), 0) = 0 ORDER BY l.m_locator_id;

-- to see storage detail in daily emial
CREATE OR REPLACE VIEW adempiere.pi_inventoryviewforemail AS
SELECT pr.m_product_category_id,pp.m_product_id,pr.erpcode,
sum(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availablecount,
pr.weight AS unitweight,pr.weight * sum(CASE
WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalunitweight,
pr.value,pp.ad_client_id,pp.ad_org_id FROM adempiere.pi_productlabel pp
JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
WHERE NOT (EXISTS ( SELECT 1 FROM adempiere.pi_productlabel pp_sales
WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
GROUP BY pp.m_product_id, pr.weight, pr.m_product_category_id, pr.erpcode, pr.value, pp.ad_client_id, pp.ad_org_id
ORDER BY pp.m_product_id DESC;


-- to see all existing labels in warehouse
CREATE OR REPLACE VIEW adempiere.pi_productlabelviewOnlyLabel AS 
SELECT p.m_product_id,lo.m_warehouse_id,p.m_locator_id,p.m_inoutline_id,p.c_orderline_id,o.c_order_id,p.labeluuid,
p.quantity,p.qcpassed,p.issotrx,p.created,p.ad_client_id,p.ad_org_id
FROM adempiere.pi_productlabel p 
JOIN adempiere.m_locator lo ON lo.m_locator_id = p.m_locator_id
JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = lo.m_warehouse_id 
Left JOIN adempiere.c_orderline li ON li.c_orderline_id = p.c_orderline_id
Left JOIN adempiere.c_order o ON o.c_order_id = li.c_order_id 
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = p.labeluuid AND pp_sales.issotrx = 'Y');


-- to see empty locators
CREATE OR REPLACE VIEW adempiere.pi_emptyLocatorView AS 
SELECT l.m_locator_id,l.value AS locator_name,l.ad_client_id,l.ad_org_id
FROM adempiere.m_locator l
LEFT JOIN adempiere.pi_productlabel s ON l.m_locator_id = s.m_locator_id 
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = s.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY l.m_locator_id, l.value,s.ad_client_id,s.ad_org_id
HAVING COALESCE(SUM(s.quantity), 0) = 0 ORDER BY l.m_locator_id;


CREATE TABLE adempiere.pi_salesplan (
    pi_salesplan_ID SERIAL PRIMARY KEY,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    salesplandate timestamp without time zone,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    status VARCHAR(255),
    pi_salesplan_UU varchar(50),
    FOREIGN KEY (ad_client_iD) REFERENCES adempiere.ad_client(ad_client_id),
    FOREIGN KEY (ad_org_iD) REFERENCES adempiere.ad_org(ad_org_id),
    FOREIGN KEY (createdby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (updatedby) REFERENCES adempiere.ad_user(ad_user_id));


CREATE TABLE adempiere.pi_salesplanline (
    pi_salesplanline_ID SERIAL PRIMARY KEY,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    c_bpartner_ID NUMERIC(10, 0) NOT NULL,
    pi_salesplan_ID Integer,
    pi_salesplanline_UU varchar(50),
    m_warehouse_ID NUMERIC(10, 0) NOT NULL,
    description VARCHAR(255),
    status VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    FOREIGN KEY (ad_client_iD) REFERENCES adempiere.ad_client(ad_client_id),
    FOREIGN KEY (ad_org_iD) REFERENCES adempiere.ad_org(ad_org_id),
    FOREIGN KEY (createdby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (updatedby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (c_bpartner_ID) REFERENCES adempiere.c_bpartner(c_bpartner_ID),
    FOREIGN KEY (m_warehouse_ID) REFERENCES adempiere.m_warehouse(m_warehouse_ID),
    FOREIGN KEY (pi_salesplan_ID) REFERENCES adempiere.pi_salesplan(pi_salesplan_ID));

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Working:-
CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS
SELECT 
    pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pr.erpcode,
    pbom.PP_Product_BOM_ID,
    SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,
    pr.weight AS unitWeight,
    pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
    pr.value,
    pr.created AS m_product_created,
    pr.createdby AS m_product_createdby,
    pr.updated AS m_product_updated,
    pr.updatedby AS m_product_updatedby,
    pr.isactive AS product_isactive,
    pp.ad_client_id,
    pp.ad_org_id
FROM 
    adempiere.pi_productlabel pp
    JOIN adempiere.m_product pr 
        ON pr.m_product_id = pp.m_product_id
    LEFT JOIN adempiere.PP_Product_BOM pbom 
        ON pbom.m_product_id = pr.m_product_id
    LEFT JOIN adempiere.m_locator l 
        ON l.m_locator_id = pp.m_locator_id
    LEFT JOIN adempiere.m_locatortype ltt 
        ON ltt.m_locatortype_id = l.m_locatortype_id
    JOIN adempiere.m_product_category pc 
        ON pc.m_product_category_id = pr.m_product_category_id
    JOIN adempiere.c_uom uom 
        ON uom.c_uom_id = pr.c_uom_id
WHERE 
    -- exclude anything in locator types with returns = 'Y'
    (ltt.returns IS NULL OR ltt.returns <> 'Y')
    AND NOT EXISTS (
        SELECT 1
        FROM adempiere.pi_productlabel pp_sales
        JOIN adempiere.m_locator l2 ON l2.m_locator_id = pp_sales.m_locator_id
        JOIN adempiere.m_locatortype ltt2 ON ltt2.m_locatortype_id = l2.m_locatortype_id
        WHERE pp_sales.labeluuid = pp.labeluuid
          AND pp_sales.issotrx = 'Y'
          AND ltt2.returns = 'N'
    )
GROUP BY 
    pp.m_product_id,
    pr.weight,
    uom.name,
    pp.ad_client_id,
    pp.ad_org_id,
    pr.isactive,
    pr.m_product_category_id,
    pr.erpcode,
    pbom.PP_Product_BOM_ID,
    pr.value,
    pr.created,
    pr.createdby,
    pr.updated,
    pr.updatedby
ORDER BY 
    pp.m_product_id DESC;
============================================================================