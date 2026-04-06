* Hold & Release Report:-

CREATE OR REPLACE VIEW adempiere.pi_hold_release_report AS
SELECT
    pr.erpcode AS ERP_Code,
    pr.name AS Material_Name,
    loc.value AS Locator,
    pl.quantity AS Quantity,
    CASE 
        WHEN pl.reserved = 'Y' THEN 'Hold'
        WHEN pl.reserved = 'N' AND pl.reservedTo IS NOT NULL THEN 'Released'
        ELSE 'Available'
    END AS Hold_Status,
    pl.reservedFrom AS Hold_Date,
    pl.reservedTo AS Released_Date,
    pl.remark AS Reason_for_Hold,
    u.name AS Action_By,
    org.name AS Organization,
    wh.name AS Warehouse,
    pl.ad_org_id,
    wh.m_warehouse_id,
    pl.m_product_id,
    pr.erpcode AS filter_erpcode,
    pl.reserved AS status_flag,
    pl.ad_client_id,TO_CHAR(pl.reservedFrom,'DD/MM/YYYY HH12:MI AM') AS hold_datetime,
    TO_CHAR(pl.reservedTo,'DD/MM/YYYY HH12:MI AM') AS released_datetime,pc.name AS customer_name,pr.m_product_category_id
    
FROM
    adempiere.pi_productLabel pl
JOIN
    adempiere.m_product pr ON pl.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN
    adempiere.m_locator loc ON pl.m_locator_id = loc.m_locator_id
JOIN
    adempiere.m_warehouse wh ON loc.m_warehouse_id = wh.m_warehouse_id
JOIN
    adempiere.ad_org org ON pl.ad_org_id = org.ad_org_id
LEFT JOIN
    adempiere.ad_user u ON pl.updatedby = u.ad_user_id
WHERE
    pl.isactive = 'Y'
    AND (pl.reserved = 'Y' OR pl.reservedTo IS NOT NULL)
ORDER BY
    pl.reservedFrom DESC;
    
----------------------------------------------------------------------------------
* Dispatch Report:-

CREATE OR REPLACE VIEW adempiere.pi_dispatch_report_new AS
SELECT
    DATE(pl.updated) AS report_date,
    pl.m_product_id,
    pr.m_product_category_id,
    o.c_bpartner_id,
    SUM(pl.quantity) AS total_quantity, -- Changed to SUM to merge labels
    pr.weight AS unit_weight_kg,
    ROUND(SUM(pr.weight * pl.quantity)/1000, 3) AS total_weight_ton,
    pl.ad_client_id,
    pl.ad_org_id,
    mi.documentno AS ReceiptNo,
    pr.erpcode,
    mml.value AS pickup_locator,
    COALESCE(pri.pricestd, 0) AS unitprice, -- Added Unit Price
    COALESCE(pri.pricestd, 0) * SUM(pl.quantity) AS totalunitprice, -- Added Total Price
    o.description,u.name AS action_by
FROM
    adempiere.pi_productlabel pl
JOIN
    adempiere.M_InOutLine il ON il.M_InOutLine_id = pl.M_InOutLine_id
LEFT JOIN 
    adempiere.m_locator mml ON mml.m_locator_id = pl.previouslocator
JOIN
    adempiere.M_InOut mi ON mi.M_InOut_id = il.M_InOut_id
JOIN
    adempiere.M_Product pr ON pr.M_Product_id = pl.M_product_id
JOIN
    adempiere.C_OrderLine ol ON ol.C_OrderLine_ID = pl.C_OrderLine_ID
JOIN
    adempiere.C_Order o ON o.C_Order_ID = ol.C_Order_ID
JOIN adempiere.AD_User u ON u.AD_User_ID = mi.updatedby
-- Join to get a single active price per product
LEFT JOIN (
    SELECT DISTINCT ON (m_product_id) m_product_id, pricestd 
    FROM adempiere.m_productprice 
    WHERE isactive = 'Y' 
    ORDER BY m_product_id, updated DESC
) pri ON pri.m_product_id = pr.m_product_id
WHERE pl.issotrx = 'Y'
GROUP BY
    DATE(pl.updated), -- Grouping by Date only
    pl.m_product_id,
    pr.m_product_category_id,
    o.c_bpartner_id, 
    pr.weight,
    pl.ad_client_id,
    pl.ad_org_id,
    mi.documentno,
    pr.erpcode,
    mml.value,
    pri.pricestd, -- Added for grouping
    o.description,u.name
ORDER BY
    report_date DESC,
    pr.m_product_category_id,
    o.c_bpartner_id,
    pl.m_product_id;
----------------------------------------------------------------------------------

* Sales Return Report:-

CREATE OR REPLACE VIEW adempiere.pi_sales_return_report_new AS
SELECT rma.name,rma.documentno, rt.name AS returnstatus,u.name AS action_by,rma.help AS comment,pr.name AS Product,l.value AS locator,
riol.qtyentered AS quantity,rma.created AS returnDate,o.documentno AS SalesOrderNo,rma.AD_Client_ID,rma.AD_Org_ID,
pr.erpcode AS erpcode,pr.description AS material_code,pr.M_Product_ID
FROM adempiere.M_RMA rma
JOIN adempiere.M_InOut rio ON rio.M_RMA_ID = rma.M_RMA_ID
JOIN adempiere.M_InOutLine riol ON riol.M_InOut_ID = rio.M_InOut_ID
JOIN adempiere.M_Product pr ON pr.M_Product_ID = riol.M_Product_ID
JOIN adempiere.M_Locator l ON l.M_Locator_ID = riol.M_Locator_ID
JOIN adempiere.M_RMAType rt ON rt.M_RMAType_ID = rma.M_RMAType_ID
JOIN adempiere.AD_User u ON u.AD_User_ID = rma.updatedby
JOIN adempiere.M_InOut sio ON sio.M_InOut_ID = rma.InOut_ID
JOIN adempiere.C_Order o ON o.C_Order_ID = sio.C_Order_ID
ORDER BY rma.documentno DESC, rma.updated DESC;

---------------------------------------------
* Inward Report:-

CREATE OR REPLACE VIEW adempiere.pi_inward_report_new AS
SELECT
    DATE(mi.created) AS report_date, -- Using MovementDate for business accuracy
    il.M_Product_ID,
    pr.M_Product_Category_ID,
    SUM(il.QtyEntered) AS total_quantity,
    pr.Weight AS unit_weight_kg,
    ROUND(SUM(pr.Weight * il.QtyEntered)/1000, 3) AS total_weight_ton,
    il.AD_Client_ID,
    il.AD_Org_ID,
    mi.DocumentNo AS ReceiptNo,
    pr.erpcode, -- In standard iDempiere, 'Value' is the Search Key/ERP Code
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * SUM(il.QtyEntered) AS totalunitprice,
    mi.Description AS Reference_Number,u.name AS action_by
FROM
    adempiere.M_InOutLine il
JOIN
    adempiere.M_InOut mi ON mi.M_InOut_ID = il.M_InOut_ID
JOIN
    adempiere.M_Product pr ON pr.M_Product_ID = il.M_Product_ID
JOIN adempiere.AD_User u ON u.AD_User_ID = mi.updatedby
LEFT JOIN (
    -- Subquery to fetch the latest price
    SELECT DISTINCT ON (M_Product_ID) M_Product_ID, PriceStd 
    FROM adempiere.M_ProductPrice 
    WHERE IsActive = 'Y' 
    ORDER BY M_Product_ID, Updated DESC
) pri ON pri.M_Product_ID = il.M_Product_ID
WHERE 
    mi.IsSOTrx = 'N'             -- 'N' ensures this is an Inward (Material Receipt)
    AND mi.DocStatus IN ('CO', 'CL') -- Optional: Filter for Completed or Closed documents
GROUP BY
    DATE(mi.created),
    il.M_Product_ID,
    pr.M_Product_Category_ID,
    pr.Weight,
    il.AD_Client_ID,
    il.AD_Org_ID,
    mi.DocumentNo,
    pr.erpcode,
    pri.pricestd,
    mi.Description,u.name
ORDER BY
    report_date DESC,
    pr.M_Product_Category_ID,
    il.M_Product_ID;

------------------------------------------------------------------
* Common Report :-

CREATE OR REPLACE VIEW adempiere.pi_common_report AS
SELECT DATE(pl.updated) AS report_date,pr.m_product_category_id,pl.m_product_id,pl.ad_client_id,pl.ad_org_id,
    SUM(CASE WHEN pl.issotrx = 'N' THEN pl.quantity ELSE 0 END) AS inward_qty,
    SUM(CASE WHEN pl.issotrx = 'Y' THEN pl.quantity ELSE 0 END) AS dispatch_qty,
    SUM(
        CASE 
            WHEN ltt.returns = 'Y' 
            AND pl.sales_return = 'N'
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
COALESCE(mpp_sales.pricelist, 0) AS sales_pricelist, pr.erpcode FROM adempiere.pi_productlabel pl 
JOIN adempiere.m_product pr ON pr.m_product_id = pl.m_product_id
LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pl.m_locator_id
LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
LEFT JOIN adempiere.m_productprice mpp_purchase ON mpp_purchase.m_product_id = pr.m_product_id AND mpp_purchase.m_pricelist_version_id = 1000000
LEFT JOIN adempiere.m_productprice mpp_sales ON mpp_sales.m_product_id = pr.m_product_id AND mpp_sales.m_pricelist_version_id = 1000001
GROUP BY DATE(pl.updated),pr.m_product_category_id,pl.m_product_id,
pl.ad_client_id,pl.ad_org_id,pr.weight,mpp_purchase.pricelist,mpp_sales.pricelist,pr.erpcode
ORDER BY DATE(pl.updated) DESC,pr.m_product_category_id,pl.m_product_id;

----------------------------------------------------------------------
* Damage Report :-

CREATE OR REPLACE VIEW adempiere.pi_damage_report AS 
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
    pp.ad_org_id,
    mml.value AS pickup_locator,
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalunitprice,
    pp.description AS comment,u.name As action_by
FROM 
    adempiere.pi_productlabel pp
    JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
    LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
    LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
    LEFT JOIN adempiere.m_locator mml ON mml.m_locator_id = pp.previouslocator
    LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
    JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
    JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
    JOIN adempiere.ad_user u ON pp.updatedby = u.ad_user_id
    -- Join to Product Price
    LEFT JOIN adempiere.m_productprice pri ON pri.m_product_id = pr.m_product_id
        AND pri.isactive = 'Y'
    LEFT JOIN adempiere.M_PriceList_Version priv ON priv.M_PriceList_Version_id = pri.M_PriceList_Version_id
    LEFT JOIN adempiere.M_PriceList prl ON prl.M_PriceList_ID = priv.M_PriceList_ID

WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales 
        WHERE pp_sales.labeluuid = pp.labeluuid 
        AND pp_sales.issotrx = 'Y'
    )
    AND ltt.returns = 'Y' 
    AND pp.sales_return = 'N' 
    AND prl.name = 'Sales'
GROUP BY 
    pp.m_product_id, pr.weight, uom.name, pp.ad_client_id, pp.ad_org_id, 
    pr.isactive, pr.m_product_category_id, pr.erpcode, pbom.PP_Product_BOM_ID, 
    pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, pp.updated, 
    mml.value, pri.pricestd,pp.description,u.name
ORDER BY 
       DATE(pp.updated) DESC;

------------------------------------------------------------------------------------------