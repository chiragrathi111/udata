CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pr.erpcode,pbom.PP_Product_BOM_ID,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
LEFT JOIN adempiere.m_locator l On l.m_locator_id = pp.m_locator_id LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y' ) AND ltt.returns = 'N'
GROUP BY pp.m_product_id,pr.weight,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,pr.m_product_category_id,pr.erpcode,
pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_product_id desc;

CREATE OR REPLACE VIEW adempiere.pi_productlabelViews AS 
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pr.erpcode,pbom.PP_Product_BOM_ID,l.m_locatortype_id,pp.m_locator_id,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,l.isactive AS locator_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y') AND ltt.returns = 'N'
GROUP BY pp.m_product_id,pr.weight,w.m_warehouse_id,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,l.isactive,l.m_locatortype_id, 
pp.m_locator_id,pr.m_product_category_id,pr.erpcode,pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_locator_id desc;

------------------------------------------
No use:-

CREATE OR REPLACE VIEW adempiere.pi_damage_report AS 
SELECT pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pr.erpcode,pbom.PP_Product_BOM_ID,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,DATE(pp.updated) AS report_date,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
LEFT JOIN adempiere.m_locator l On l.m_locator_id = pp.m_locator_id LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y' ) AND ltt.returns = 'Y'
GROUP BY pp.m_product_id,pr.weight,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,pr.m_product_category_id,pr.erpcode,
pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_product_id desc;

---------------------------------------------------------

CREATE OR REPLACE VIEW adempiere.pi_dispatch_report AS
SELECT
    DATE(pl.updated) AS report_date,
    pl.m_product_id,
    pr.m_product_category_id,
    o.c_bpartner_id,
    SUM(pl.quantity) AS total_quantity,
    pr.weight AS unit_weight_kg,
    ROUND(SUM(pr.weight * pl.quantity)/1000, 3) AS total_weight_ton,
    pl.ad_client_id,
    pl.ad_org_id
FROM
    adempiere.pi_productlabel pl
JOIN
    adempiere.M_InOutLine il ON il.M_InOutLine_id = pl.M_InOutLine_id
JOIN
    adempiere.M_Product pr ON pr.M_Product_id = pl.M_product_id
JOIN
    adempiere.C_OrderLine ol ON ol.C_OrderLine_ID = pl.C_OrderLine_ID -- NEW: Join to Order Line
JOIN
    adempiere.C_Order o ON o.C_Order_ID = ol.C_Order_ID -- NEW: Join to Order to get BPartner ID

WHERE pl.issotrx = 'Y'
GROUP BY
    DATE(pl.updated),
    pl.m_product_id,
    pr.m_product_category_id,
    o.c_bpartner_id, 
    pr.weight,
    pl.ad_client_id,
    pl.ad_org_id
ORDER BY
    DATE(pl.updated) DESC,
    pr.m_product_category_id,
    o.c_bpartner_id,
    pl.m_product_id;

-------------------------------------------------------------
 CREATE OR REPLACE VIEW adempiere.pi_inward_report AS
SELECT
    DATE(pl.updated) AS report_date,
    pl.m_product_id,
    pr.m_product_category_id,
    SUM(pl.quantity) AS total_quantity,
    pr.weight AS unit_weight_kg,
    ROUND(SUM(pr.weight * pl.quantity)/1000, 3) AS total_weight_ton,
    pl.ad_client_id,
    pl.ad_org_id
FROM
    adempiere.pi_productlabel pl
JOIN
    adempiere.M_InOutLine il ON il.M_InOutLine_id = pl.M_InOutLine_id
JOIN
    adempiere.M_Product pr ON pr.M_Product_id = pl.M_product_id

WHERE pl.issotrx = 'N'
GROUP BY
    DATE(pl.updated),
    pl.m_product_id,
    pr.m_product_category_id,
    pr.weight,
    pl.ad_client_id,
    pl.ad_org_id
ORDER BY
    DATE(pl.updated) DESC,
    pr.m_product_category_id,
    pl.m_product_id;

    -----------------------------------------------
    DROP VIEW IF EXISTS adempiere.pi_damage_report;

CREATE VIEW adempiere.pi_damage_report AS 
SELECT 
    pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pr.erpcode,
    pbom.PP_Product_BOM_ID,
    SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,
    pr.weight AS unitWeight,
    pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,
    DATE(pp.updated) AS report_date,
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
    JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
    LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
    LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
    LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
    JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
    JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales 
        WHERE pp_sales.labeluuid = pp.labeluuid 
        AND pp_sales.issotrx = 'Y'
    )
    AND ltt.returns = 'Y'
GROUP BY 
    pp.m_product_id, pr.weight, uom.name, pp.ad_client_id, pp.ad_org_id, 
    pr.isactive, pr.m_product_category_id, pr.erpcode, pbom.PP_Product_BOM_ID, 
    pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, pp.updated
ORDER BY 
    pp.m_product_id DESC;


============================================================================
CREATE OR REPLACE VIEW adempiere.pi_common_report AS
SELECT
    DATE(pl.updated) AS report_date,
    pr.m_product_category_id,
    pl.m_product_id,
    pl.ad_client_id,
    pl.ad_org_id,

    -- Inward (issotrx = 'N')
    SUM(CASE WHEN pl.issotrx = 'N' THEN pl.quantity ELSE 0 END) AS inward_qty,

    -- Dispatch (issotrx = 'Y')
    SUM(CASE WHEN pl.issotrx = 'Y' THEN pl.quantity ELSE 0 END) AS dispatch_qty,

    -- Damage (returns = 'Y')
    SUM(CASE 
            WHEN ltt.returns = 'Y' 
                 AND NOT EXISTS (
                     SELECT 1 
                     FROM adempiere.pi_productlabel ps 
                     WHERE ps.labeluuid = pl.labeluuid 
                     AND ps.issotrx = 'Y'
                 )
            THEN pl.quantity 
            ELSE 0 
        END) AS damage_qty,

    -- Stock (returns = 'N' and not sold)
    SUM(CASE 
            WHEN ltt.returns = 'N' 
                 AND NOT EXISTS (
                     SELECT 1 
                     FROM adempiere.pi_productlabel ps 
                     WHERE ps.labeluuid = pl.labeluuid 
                     AND ps.issotrx = 'Y'
                 )
            THEN pl.quantity 
            ELSE 0 
        END) AS stock_qty

FROM 
    adempiere.pi_productlabel pl
    JOIN adempiere.m_product pr ON pr.m_product_id = pl.m_product_id
    LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pl.m_locator_id
    LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id

GROUP BY 
    DATE(pl.updated),
    pr.m_product_category_id,
    pl.m_product_id,
    pl.ad_client_id,
    pl.ad_org_id

ORDER BY 
    DATE(pl.updated) DESC,
    pr.m_product_category_id,
    pl.m_product_id;

--------------------------------------------------------------------
-- CREATE OR REPLACE VIEW adempiere.pi_common_report AS
SELECT DATE(pl.updated) AS report_date,pr.m_product_category_id,pl.m_product_id,pl.ad_client_id,pl.ad_org_id,
    SUM(CASE WHEN pl.issotrx = 'N' THEN pl.quantity ELSE 0 END) AS inward_qty,
    SUM(CASE WHEN pl.issotrx = 'Y' THEN pl.quantity ELSE 0 END) AS dispatch_qty,
    SUM(CASE 
            WHEN ltt.returns = 'Y' 
                 AND NOT EXISTS (
                     SELECT 1 FROM adempiere.pi_productlabel ps WHERE ps.labeluuid = pl.labeluuid AND ps.issotrx = 'Y')
            THEN pl.quantity 
            ELSE 0 
        END) AS damage_qty,
    SUM(CASE 
            WHEN ltt.returns = 'N' 
                 AND NOT EXISTS (
                     SELECT 1 FROM adempiere.pi_productlabel ps WHERE ps.labeluuid = pl.labeluuid AND ps.issotrx = 'Y')
            THEN pl.quantity 
            ELSE 0 
        END) AS stock_qty
FROM adempiere.pi_productlabel pl JOIN adempiere.m_product pr ON pr.m_product_id = pl.m_product_id
LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pl.m_locator_id
LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
GROUP BY DATE(pl.updated),pr.m_product_category_id,pl.m_product_id,pl.ad_client_id,pl.ad_org_id
ORDER BY DATE(pl.updated) DESC,pr.m_product_category_id,pl.m_product_id;    

    

=====================================================================================
CREATE OR REPLACE VIEW adempiere.pi_common_report AS
SELECT DATE(pl.updated) AS report_date,pr.m_product_category_id,pl.m_product_id,pl.ad_client_id,pl.ad_org_id,
    SUM(CASE WHEN pl.issotrx = 'N' THEN pl.quantity ELSE 0 END) AS inward_qty,
    SUM(CASE WHEN pl.issotrx = 'Y' THEN pl.quantity ELSE 0 END) AS dispatch_qty,
    SUM(
        CASE 
            WHEN ltt.returns = 'Y' 
                 AND NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel ps WHERE ps.labeluuid = pl.labeluuid AND ps.issotrx = 'Y')
            THEN pl.quantity 
            ELSE 0 
        END
    ) AS damage_qty,
   SUM(
        CASE 
            WHEN ltt.returns = 'N' 
                 AND NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel ps WHERE ps.labeluuid = pl.labeluuid AND ps.issotrx = 'Y')
            THEN pl.quantity 
            ELSE 0 
        END
    ) AS stock_qty,
pr.weight AS unitWeight,COALESCE(mpp_purchase.pricelist, 0) AS purchase_pricelist,
COALESCE(mpp_sales.pricelist, 0) AS sales_pricelist FROM adempiere.pi_productlabel pl 
JOIN adempiere.m_product pr ON pr.m_product_id = pl.m_product_id
LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pl.m_locator_id
LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
LEFT JOIN adempiere.m_productprice mpp_purchase ON mpp_purchase.m_product_id = pr.m_product_id AND mpp_purchase.m_pricelist_version_id = 1000000
LEFT JOIN adempiere.m_productprice mpp_sales ON mpp_sales.m_product_id = pr.m_product_id AND mpp_sales.m_pricelist_version_id = 1000001
GROUP BY DATE(pl.updated),pr.m_product_category_id,pl.m_product_id,
pl.ad_client_id,pl.ad_org_id,pr.weight,mpp_purchase.pricelist,mpp_sales.pricelist
ORDER BY DATE(pl.updated) DESC,pr.m_product_category_id,pl.m_product_id;

