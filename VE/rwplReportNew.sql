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
LEFT JOIN adempiere.pi_productlabel pl ON pl.M_InOutLine_id = il.M_InOutLine_id
LEFT JOIN (
    -- Subquery to fetch the latest price
    SELECT DISTINCT ON (M_Product_ID) M_Product_ID, PriceStd 
    FROM adempiere.M_ProductPrice 
    WHERE IsActive = 'Y' 
    ORDER BY M_Product_ID, Updated DESC
) pri ON pri.M_Product_ID = il.M_Product_ID
WHERE 
    mi.IsSOTrx = 'N' AND pl.isrestricted = 'N'          -- 'N' ensures this is an Inward (Material Receipt)
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

    new added :-

CREATE OR REPLACE VIEW adempiere.pi_inward_report_new AS
SELECT
    DATE(mi.created) AS report_date,
    il.M_Product_ID,
    pr.M_Product_Category_ID,
    SUM(il.QtyEntered) AS total_quantity,
    pr.Weight AS unit_weight_kg,
    ROUND(SUM(pr.Weight * il.QtyEntered) / 1000, 3) AS total_weight_ton,
    il.AD_Client_ID,
    il.AD_Org_ID,
    mi.DocumentNo AS ReceiptNo,
    pr.erpcode,
    COALESCE(pri.PriceStd, 0) AS unitprice,
    COALESCE(pri.PriceStd, 0) * SUM(il.QtyEntered) AS totalunitprice,
    mi.Description AS Reference_Number,
    u.Name AS action_by
FROM adempiere.M_InOutLine il
INNER JOIN adempiere.M_InOut mi
    ON mi.M_InOut_ID = il.M_InOut_ID
INNER JOIN adempiere.M_Product pr
    ON pr.M_Product_ID = il.M_Product_ID
INNER JOIN adempiere.AD_User u
    ON u.AD_User_ID = mi.UpdatedBy
LEFT JOIN
(
    SELECT DISTINCT ON (M_Product_ID)
           M_Product_ID,
           PriceStd
    FROM adempiere.M_ProductPrice
    WHERE IsActive = 'Y'
    ORDER BY M_Product_ID, Updated DESC
) pri
    ON pri.M_Product_ID = il.M_Product_ID
WHERE
    mi.IsSOTrx = 'N'
    AND mi.DocStatus IN ('CO', 'CL')

    -- Only include receipt lines having at least one unrestricted label
    AND EXISTS
    (
        SELECT 1
        FROM adempiere.pi_productlabel pl
        WHERE pl.M_InOutLine_ID = il.M_InOutLine_ID
          AND pl.IsRestricted = 'N'
    )

    -- Remove this line after testing
    -- AND pr.M_Product_ID = 1001570
    -- AND mi.M_InOut_ID = 1027984

GROUP BY
    DATE(mi.created),
    il.M_Product_ID,
    pr.M_Product_Category_ID,
    pr.Weight,
    il.AD_Client_ID,
    il.AD_Org_ID,
    mi.DocumentNo,
    pr.erpcode,
    pri.PriceStd,
    mi.Description,
    u.Name

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
WHERE pl.isrestricted = 'N'
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
Restricted Report:-

CREATE OR REPLACE VIEW adempiere.pi_restrict_report AS
SELECT
    pl.quantity AS actual_qty,
    pl.actualqty AS updated_qty,
    CASE 
        WHEN pl.isrestricted = 'Y' THEN 'Restricted'
        WHEN pl.isrestricted = 'N' AND pl.releaseDate IS NOT NULL THEN 'Released'
        ELSE 'Available'
    END AS restrict_status,
    pl.restricteddate AS restricted_date,
    pl.releaseDate AS released_date,
    pl.remark AS old_records,
    u.name AS action_by,
    pl.ad_org_id,
    wh.m_warehouse_id,
    pl.m_product_id,
    pl.m_locator_id,
    pl.description AS comment,
    pr.erpcode AS erpcode,
    pl.isrestricted AS status_flag,
    pl.ad_client_id,
    TO_CHAR(pl.restricteddate,'DD/MM/YYYY HH12:MI AM') AS restricted_datetime,
    TO_CHAR(pl.releaseDate,'DD/MM/YYYY HH12:MI AM') AS released_datetime,
    pr.m_product_category_id,
    date(li.movementdate) AS receipt_date,
    to_char(li.movementdate, 'DD/MM/YYYY HH12:MI AM') AS receipt_datetime,
    pl.restrict_comment AS restrict_comment,
    pl.release_comment
    
FROM
    adempiere.pi_productLabel pl
JOIN
    adempiere.m_product pr ON pl.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
JOIN adempiere.m_inoutline mil ON mil.m_inoutline_id = pl.m_inoutline_id
     JOIN adempiere.m_inout li ON li.m_inout_id = mil.m_inout_id
JOIN
    adempiere.m_locator loc ON pl.m_locator_id = loc.m_locator_id
JOIN
    adempiere.m_warehouse wh ON loc.m_warehouse_id = wh.m_warehouse_id
LEFT JOIN
    adempiere.ad_user u ON pl.updatedby = u.ad_user_id
WHERE
    pl.isactive = 'Y' 
    AND pl.reserved = 'N'
    AND (pl.isrestricted = 'Y' OR pl.releaseDate IS NOT NULL)
ORDER BY
    pl.restricteddate DESC;
------------------------------------------------------------------------------------------------
Ageing Report :-

CREATE OR REPLACE VIEW adempiere.pi_ageing_report AS

SELECT

    pc.m_product_category_id AS m_product_category_id,

    pr.erpcode AS erp_code,

    pr.value AS search_key,

    pr.m_product_id AS m_product_id,

    pi.m_locator_id AS m_locator_id,

    SUM(pi.quantity) AS total_qty_available,--pi.quantity

    (CURRENT_DATE - DATE(i.movementdate)) AS age_days,

    CASE
        WHEN (CURRENT_DATE - DATE(i.movementdate)) BETWEEN 0 AND 15
            THEN '0-15 Days'

        WHEN (CURRENT_DATE - DATE(i.movementdate)) BETWEEN 16 AND 30
            THEN '16-30 Days'

        WHEN (CURRENT_DATE - DATE(i.movementdate)) BETWEEN 31 AND 60
            THEN '31-60 Days'

        WHEN (CURRENT_DATE - DATE(i.movementdate)) BETWEEN 61 AND 90
            THEN '61-90 Days'

        WHEN (CURRENT_DATE - DATE(i.movementdate)) BETWEEN 91 AND 180
            THEN '91-180 Days'

        ELSE 'More than 181 Days'
    END AS age_bucket,

    COALESCE(pri.pricestd, 0) AS unit_rate,

    pr.weight AS unit_weight,

    ROUND(
        SUM(pi.quantity) * COALESCE(pri.pricestd, 0),
        2
    ) AS total_rate,

    ROUND(
        SUM(pi.quantity) * pr.weight,
        3
    ) AS total_weight,

    DATE(i.movementdate) AS receipt_date,

    i.documentno,

    il.ad_client_id,

    il.ad_org_id,pr.erpcode

FROM adempiere.pi_productlabel pi

JOIN adempiere.m_inoutline il ON il.m_inoutline_id = pi.m_inoutline_id

JOIN adempiere.m_inout i
    ON i.m_inout_id = il.m_inout_id

JOIN adempiere.m_product pr
    ON pr.m_product_id = il.m_product_id

JOIN adempiere.m_product_category pc
    ON pc.m_product_category_id = pr.m_product_category_id

LEFT JOIN (
    SELECT DISTINCT ON (m_product_id)
        m_product_id,
        pricestd
    FROM adempiere.m_productprice
    WHERE isactive = 'Y'
    ORDER BY m_product_id, updated DESC
) pri
ON pri.m_product_id = il.m_product_id

WHERE
    NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales 
        WHERE pp_sales.labeluuid = pi.labeluuid 
        AND pp_sales.issotrx = 'Y'
    ) 
    AND i.docstatus NOT IN ('VO','RE') 
    AND pi.isactive = 'Y' 
    AND pi.qcpassed = 'Y'
    AND pi.isrestricted = 'N'
    -- AND pi.finaldispatch = 'N'
    AND pi.quantity > 0
    AND pi.labeluuid IS NOT NULL
GROUP BY

    pc.m_product_category_id,

    pr.erpcode,

    pr.value,

    pr.m_product_id,

    pi.m_locator_id,

    DATE(i.movementdate),

    pri.pricestd,

    pr.weight,

    i.documentno,

    il.ad_client_id,

    il.ad_org_id

ORDER BY
    DATE(i.movementdate) DESC,
    pr.m_product_id;
------------------------------------------------------------------------------------------
Total Tons :-

CREATE OR REPLACE VIEW adempiere.pir_totaltons AS
 SELECT w.m_warehouse_id,
    pp.m_locator_id,
    sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS availablecount,
    pr.weight AS unitweight,
    round(sum(pr.weight * pp.quantity) / 1000, 3) AS total_weight_ton,
    pp.ad_client_id,
    pp.ad_org_id,
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitprice,
    pr.erpcode,
    pr.m_product_category_id
   FROM adempiere.pi_productlabel pp
     JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
     JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
     JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
     LEFT JOIN adempiere.m_productprice pri ON pri.m_product_id = pr.m_product_id
  WHERE NOT (EXISTS ( SELECT 1
           FROM adempiere.pi_productlabel pp_sales
          WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
AND pp.isrestricted = 'N'
  GROUP BY w.m_warehouse_id, pp.m_locator_id, pp.ad_client_id, pp.ad_org_id, pr.weight, pri.pricestd, pr.erpcode, pr.m_product_category_id
  ORDER BY pp.m_locator_id DESC;

------------------------------------------------------------------------------------------
Inventory View for Email :-

CREATE OR REPLACE VIEW adempiere.pi_inventoryviewforemail AS
 SELECT pr.m_product_category_id,
    pp.m_product_id,
    pr.erpcode,
    sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS availablecount,
    pr.weight AS unitweight,
    pr.weight * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitweight,
    pr.value,
    pp.ad_client_id,
    pp.ad_org_id,
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitprice
   FROM adempiere.pi_productlabel pp
     JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
     JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
     LEFT JOIN adempiere.m_productprice pri ON pri.m_product_id = pr.m_product_id AND pri.isactive = 'Y'
  WHERE NOT (EXISTS ( SELECT 1
           FROM adempiere.pi_productlabel pp_sales
          WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'))
AND pp.isrestricted = 'N'
  GROUP BY pp.m_product_id, pr.weight, pr.m_product_category_id, pr.erpcode, pr.value, pp.ad_client_id, pp.ad_org_id, pri.pricestd
  ORDER BY pp.m_product_id DESC;

------------------------------------------------------------------------------------------
Storage Details By Locator :-

CREATE OR REPLACE VIEW adempiere.pi_productlabelViews AS
 SELECT w.m_warehouse_id,
    pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pr.erpcode,
    pbom.pp_product_bom_id,
    l.m_locatortype_id,
    pp.m_locator_id,
    sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS availablecount,
    pr.weight AS unitweight,
    pr.weight * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitweight,
    pr.value,
    pr.created AS m_product_created,
    pr.createdby AS m_product_createdby,
    pr.updated AS m_product_updated,
    pr.updatedby AS m_product_updatedby,
    pr.isactive AS product_isactive,
    l.isactive AS locator_isactive,
    pp.ad_client_id,
    pp.ad_org_id,
    pp.m_inoutline_id,
    mio.documentno AS m_inout_docno,
    mio.movementdate AS m_inout_date,
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitprice,
        pr.description
   FROM adempiere.pi_productlabel pp
     JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
     LEFT JOIN ( SELECT DISTINCT ON (pp_product_bom.m_product_id) pp_product_bom.m_product_id,
            pp_product_bom.pp_product_bom_id
           FROM adempiere.pp_product_bom
          WHERE pp_product_bom.isactive = 'Y') pbom ON pbom.m_product_id = pr.m_product_id
     JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
     JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
     JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
     JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
     JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
     LEFT JOIN adempiere.m_inoutline miol ON miol.m_inoutline_id = pp.m_inoutline_id
     LEFT JOIN adempiere.m_inout mio ON mio.m_inout_id = miol.m_inout_id
     LEFT JOIN ( SELECT DISTINCT ON (m_productprice.m_product_id) m_productprice.m_product_id,
            m_productprice.pricestd
           FROM adempiere.m_productprice
          WHERE m_productprice.isactive = 'Y'
          ORDER BY m_productprice.m_product_id, m_productprice.updated DESC) pri ON pri.m_product_id = pr.m_product_id
  WHERE NOT (EXISTS ( SELECT 1
           FROM adempiere.pi_productlabel pp_sales
          WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')) AND ltt.returns = 'N' AND pp.isrestricted = 'N'
  GROUP BY w.m_warehouse_id, pr.m_product_category_id, pp.m_product_id, uom.name, pr.erpcode, pbom.pp_product_bom_id, l.m_locatortype_id, pp.m_locator_id, pr.weight, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, pr.isactive, l.isactive, pp.ad_client_id, pp.ad_org_id, pp.m_inoutline_id, mio.documentno, mio.movementdate,pr.description, pri.pricestd
  ORDER BY pp.m_locator_id DESC;
------------------------------------------------------------------------------------------
Storage Details By Product :-

CREATE OR REPLACE VIEW adempiere.pi_productlabelViewByProduct AS
 SELECT pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pr.erpcode,
    pbom.pp_product_bom_id,
    sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS availablecount,
    pr.weight AS unitweight,
    pr.weight * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitweight,
    pr.value,
    pr.created AS m_product_created,
    pr.createdby AS m_product_createdby,
    pr.updated AS m_product_updated,
    pr.updatedby AS m_product_updatedby,
    pr.isactive AS product_isactive,
    pp.ad_client_id,
    pp.ad_org_id,
    pp.m_inoutline_id,
    mio.documentno AS m_inout_docno,
    mio.movementdate AS m_inout_date,
    COALESCE(pri.pricestd, 0) AS unitprice,
    COALESCE(pri.pricestd, 0) * sum(
        CASE
            WHEN pp.issotrx = 'N' THEN pp.quantity
            ELSE 0
        END) AS totalunitprice
   FROM adempiere.pi_productlabel pp
     JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
     LEFT JOIN ( SELECT DISTINCT ON (pp_product_bom.m_product_id) pp_product_bom.m_product_id,
            pp_product_bom.pp_product_bom_id
           FROM adempiere.pp_product_bom
          WHERE pp_product_bom.isactive = 'Y') pbom ON pbom.m_product_id = pr.m_product_id
     LEFT JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id
     LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
     JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
     JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
     LEFT JOIN adempiere.m_inoutline miol ON miol.m_inoutline_id = pp.m_inoutline_id
     LEFT JOIN adempiere.m_inout mio ON mio.m_inout_id = miol.m_inout_id
     LEFT JOIN ( SELECT DISTINCT ON (m_productprice.m_product_id) m_productprice.m_product_id,
            m_productprice.pricestd
           FROM adempiere.m_productprice
          WHERE m_productprice.isactive = 'Y'
          ORDER BY m_productprice.m_product_id, m_productprice.updated DESC) pri ON pri.m_product_id = pr.m_product_id
  WHERE NOT (EXISTS ( SELECT 1
           FROM adempiere.pi_productlabel pp_sales
          WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')) AND ltt.returns = 'N'
          AND pp.isrestricted = 'N'
  GROUP BY pr.m_product_category_id, pp.m_product_id, uom.name, pr.erpcode, pbom.pp_product_bom_id, pr.weight, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, pr.isactive, pp.ad_client_id, pp.ad_org_id, pp.m_inoutline_id, mio.documentno, mio.movementdate, pri.pricestd
  ORDER BY pp.m_product_id DESC;
==============================================================================================

            <url>file:///home/chirag/PiERP/pi-erp/core/pi-erp-core/idempiere-release-10/org.idempiere.p2/target/repository</url>
