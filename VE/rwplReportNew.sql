-- Report for Hold & Release
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
    pl.ad_client_id
FROM
    adempiere.pi_productLabel pl
JOIN
    adempiere.m_product pr ON pl.m_product_id = pr.m_product_id
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
    
 -- Report for dispatch
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
    o.description
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
    o.description
ORDER BY
    report_date DESC,
    pr.m_product_category_id,
    o.c_bpartner_id,
    pl.m_product_id;


CREATE OR REPLACE VIEW adempiere.pi_sales_return_report AS
SELECT rma.name,rma.documentno, rt.name AS returnstatus,u.name AS action_by,rma.help AS comment,pr.name AS Product,l.value AS locator,
riol.qtyentered AS quantity,rma.created AS returnDate,o.documentno AS SalesOrderNo,rma.AD_Client_ID,rma.AD_Org_ID
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

CREATE OR REPLACE VIEW adempiere.pi_sales_return_report_new AS
SELECT rma.name,rma.documentno, rt.name AS returnstatus,u.name AS action_by,rma.help AS comment,pr.name AS Product,l.value AS locator,
riol.qtyentered AS quantity,rma.created AS returnDate,o.documentno AS SalesOrderNo,rma.AD_Client_ID,rma.AD_Org_ID,
pr.erpcode AS erpcode,pr.description AS material_code
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
