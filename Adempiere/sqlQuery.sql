select il.line as pos, il.qtyinvoiced, p.value as productnumber, p.name as product, il.priceactual, il.linenetamt, cur.iso_code as currency
from adempiere.c_invoiceline il 
join adempiere.c_invoice i on i.c_invoice_id=il.c_invoice_id
join adempiere.m_product p on p.m_product_id=il.m_product_id
join adempiere.c_currency cur on cur.c_currency_id=i.c_currency_id

$F{product} +  " ProdNo. " + $F{productnumber}
$F{currency} +  " "  +$F{priceactual}
$F{currency} +  " "  + $F{linenetamt}

select i.documentno, i.dateinvoiced, b.name as bpname, b.value as bpvalue, loc.address1, loc.postal,loc.city, c.name as country, i.totallines, i.grandtotal, coalesce(it.taxamt,0) as taxamt, coalesce(t.rate,0) as taxrate, t.name as txtname, orginfo.phone, orginfo.fax, orginfo.email, orgloc.address1 as orgaddress, orgloc.city as orgcity, orgloc.postal as orgpostal, org.name as orgname, img.binarydata as orglogo, cur.iso_code as currency
from adempiere.c_invoice i
join adempiere.c_bpartner b on b.c_bpartner_id=i.c_bpartner_id
join adempiere.c_bpartner_location bploc on bploc.c_bpartner_location_id=i.c_bpartner_location_id
join adempiere.c_location loc on loc.c_location_id=bploc.c_location_id
join adempiere.c_country c on c.c_country_id=loc.c_country_id
left join adempiere.c_invoicetax it on it.c_invoice_id=i.c_invoice_id
left join adempiere.c_tax t on t.c_tax_id=it.c_tax_id
join adempiere.ad_orginfo orginfo on orginfo.ad_org_id=i.ad_org_id
join adempiere.c_location orgloc on orgloc.c_location_id=orginfo.c_location_id
join adempiere.ad_org org on org.ad_org_id=i.ad_org_id
left join adempiere.ad_image img on img.ad_image_id=orginfo.logo_id
join adempiere.c_currency cur on cur.c_currency_id=i.c_currency_id
where i.c_invoice_id=103

/home/chirag/JaspersoftWorkspace/MyReports/invoices.jasper

Sql Query:- ALTER TABLE [table name] ADD DEFAULT [DEFAULT VALUE] FOR [NAME OF COLUMN]
PGSql Query :- ALTER TABLE adempiere.c_chirag ALTER COLUMN chairperson SET DEFAULT 'Chirag Rathi';

=======================================================================================================================================
warehouse all product quantity:-
select sum(qtyonhand) from adempiere.m_warehouse a 
left outer join adempiere.m_storageonhand b on a.ad_org_id = b.ad_org_id
where a.name='Main Warehouse';

Column Data type change:-
ALTER TABLE adempiere.rok_war_machine 
ALTER COLUMN rok_war_machine_id TYPE INT
USING rok_war_machine_id::integer;

record remove on the table:-
DELETE FROM adempiere.ad_role
WHERE ad_client_id = 101;

=====================================================================================================================================
Widget Product base query:-

SELECT name,m_product_id FROM adempiere.m_product
WHERE ad_client_id = 1000001

select distinct(grandtotal) from adempiere.c_order b
join adempiere.c_orderline a on a.ad_client_id = b.ad_client_id
where b.issotrx = 'Y' and a.m_product_id = 1000029

select distinct(grandtotal) from adempiere.c_orderline b
join adempiere.c_order c on b.m_warehouse_id = c.m_warehouse_id
where b.m_product_id = 1000028 and c.issotrx = 'N' and b.c_bpartner_id = 1000015

==================================================================================================================================================================
Alter any table with terminal change possible:-
ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;

Delete the Existing Column
Alter Table adempiere.c_orderline drop column BatchNo;

How to check Product is valid or not with Qty and show warehouse name:-
SELECT b.name, a.qtyentered, c.name
FROM adempiere.c_orderline a
join adempiere.m_product b on a.m_product_id = b.m_product_id
join adempiere.m_warehouse c on a.m_warehouse_id = c.m_warehouse_id
WHERE expirydate IS NULL OR expirydate < CURRENT_DATE;

select b.name from adempiere.c_payment a
join adempiere.c_bpartner b on a.c_bpartner_id = b.c_bpartner_id
where a.isreceipt = 'Y'and a.docstatus = 'DR'

select b.name, a.grandtotal from adempiere.c_invoice a
join adempiere.c_bpartner b on a.c_bpartner_id = b.c_bpartner_id 
where issotrx = 'Y' and ispaid = 'N'

SELECT bp.Name AS CustomerName,inv.DocumentNo AS InvoiceNumber,
inv.DateInvoiced AS InvoiceDate,inv.TotalLines AS InvoiceAmount
FROM adempiere.C_BPartner bp
INNER JOIN adempiere.C_Invoice inv ON bp.C_BPartner_ID = inv.C_BPartner_ID
LEFT JOIN adempiere.C_Payment pay ON inv.C_Invoice_ID = pay.C_Invoice_ID
WHERE inv.DateInvoiced <= (CURRENT_DATE - INTERVAL '1 month')
AND pay.C_Payment_ID IS NULL AND inv.issotrx = 'Y'

==================================================================================================================================================================
If your Column Type is char to change integer :-
Starting three query using convert char to integer
and last Query using integer max length using like mobile no is 10 digit numeric(10,0)

SELECT * FROM adempiere.c_bankaccount
WHERE MICR ~ '[^0-9]+';

UPDATE adempiere.c_bankaccount
SET MICR = NULL -- or a default numeric value
WHERE MICR ~ '[^0-9]+';

ALTER TABLE adempiere.c_bankaccount
ALTER COLUMN MICR TYPE integer USING MICR::integer;

ALTER TABLE adempiere.c_bankaccount
ALTER COLUMN MICR TYPE numeric(9, 0);

==================================================================================================================================================================
If Alert Name for bill overdue in 21 DAys

SELECT 
a.name as Name,
b.c_invoice_id as Invoice,
b.dateinvoiced as Date,
b.grandtotal as Amount
FROM adempiere.c_invoice b
JOIN adempiere.c_bpartner a on a.c_bpartner_id = b.c_bpartner_id
WHERE b.ispaid = 'N' -- Unpaid
AND b.issotrx = 'Y'	-- Show only Sales Records
AND b.dateinvoiced + INTERVAL '21 days' <= current_date;

==================================================================================================================================================================
Batch_No,BatchDate and ExpiryDate add in idempiere:-

ALTER TABLE adempiere.C_Orderline ADD COLUMN Batch_No numeric;

ALTER TABLE adempiere.C_Orderline ADD COLUMN BatchDate DATE;

ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;

SELECT * FROM adempiere.c_orderline
WHERE c_orderline_id = '100'::integer;

Alter Table adempiere.c_orderline drop column BatchNo;

ALTER TABLE adempiere.c_orderline ALTER COLUMN Batch_No TYPE varchar(14);

==================================================================================================================================================================
Window Selecting Query:- Using client_id,user_id,role_id

select c.name as User_Name,b.name as Role_Name,e.name as Access_Window from adempiere.ad_user_roles a
join adempiere.ad_role b on a.ad_role_id = b.ad_role_id
join adempiere.ad_user c on a.ad_user_id = c.ad_user_id
join adempiere.ad_window_access d on a.ad_role_id = d.ad_role_id
join adempiere.ad_window e on d.ad_window_id = e.ad_window_id
where a.ad_client_id = 11 and a.ad_role_id = 102

==================================================================================================================================================================
Currently Working Data:-

select * from adempiere.c_order
where issotrx = 'Y'
and ad_client_id = 11

SELECT kc.ColumnName, dc.ColumnName, t.TableName, rt.IsValueDisplayed FROM adempiere.AD_Ref_Table rt INNER JOIN adempiere.AD_Column kc ON rt.AD_Key=kc.AD_Column_ID INNER JOIN adempiere.AD_Column dc ON rt.AD_Display=dc.AD_Column_ID INNER JOIN adempiere.AD_Table t ON rt.AD_Table_ID=t.AD_Table_ID WHERE rt.AD_Reference_ID=1

ALTER TABLE adempiere.C_Orderline ADD COLUMN Batch_No numeric;

ALTER TABLE adempiere.C_Orderline ADD COLUMN BatchDate DATE;

ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;

SELECT * FROM adempiere.c_orderline
WHERE c_orderline_id = '100'::integer;

Alter Table adempiere.c_orderline drop column BatchNo;

ALTER TABLE adempiere.c_orderline ALTER COLUMN Batch_No TYPE varchar(14);

select * from adempiere.ad_client

select * from adempiere.ad_user where ad_client_id = 11

select * from adempiere.ad_user_roles where ad_client_id = 11

select * from adempiere.ad_role where ad_client_id = 11

select * from adempiere.ad_window_access where ad_client_id = 11 and ad_role_id = 1000007


select c.name as User_Name,b.name as Role_Name,e.name as Access_Window from adempiere.ad_user_roles a
join adempiere.ad_role b on a.ad_role_id = b.ad_role_id
join adempiere.ad_user c on a.ad_user_id = c.ad_user_id
join adempiere.ad_window_access d on a.ad_role_id = d.ad_role_id
join adempiere.ad_window e on d.ad_window_id = e.ad_window_id
where c.ad_client_id = 11 and b.ad_role_id = 1000008

// e.name as Access_Window  join adempiere.ad_window e on d.ad_window_id = e.ad_window_id
// d.ad_window_id as Windows
//where a.ad_client_id = 11 and c.ad_user_id = 1000011 and a.ad_role_id = 1000007


select * from adempiere.ad_user_roles a
where a.ad_client_id = 11 and a.ad_role_id = 1000007 and a.ad_user_id = 1000011

SELECT ur.AD_User_ID, ur.AD_Role_ID, r.Name AS RoleName FROM adempiere.AD_User_Roles ur 
INNER JOIN adempiere.AD_Role r ON ur.AD_Role_ID =r.AD_Role_ID
WHERE ur.AD_User_ID = 1000011

==================================================================================================================================================================
Show PO list depend of MR:-
SELECT
    po.documentno AS purchase_order,
    po.dateordered AS order_date,
    CASE
        WHEN po.docstatus = 'CO' THEN 'Completed'
        ELSE 'Not Completed'
    END AS po_status,
    CASE
        WHEN mr.m_inout_id IS NOT NULL THEN 'Material Receipt Created'
        ELSE 'No Material Receipt'
    END AS mr_status
FROM
    adempiere.c_order po
LEFT JOIN
    adempiere.m_inout mr
ON
    po.c_order_id = mr.c_order_id
where po.ad_client_id = 1000002 and po.docstatus = 'CO' and mr.m_inout_id IS null;

==================================================================================================================================================================
Show PO list if poline qty product less then or null in material receipt line from

SELECT
    po.documentno AS purchase_order,
    pol.qtyordered AS po_qty_ordered,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN 'Completed, No Material Receipt'
        WHEN po.docstatus = 'DR' AND mr.m_inout_id IS NULL THEN 'Drafted, No Material Receipt'
		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN 'again created Material Receipt'
        ELSE 'Not Completed or Material Receipt Exists'
    END AS status
FROM
    adempiere.c_order po
JOIN
    adempiere.c_orderline pol
ON
    po.c_order_id = pol.c_order_id
LEFT JOIN
    adempiere.m_inout mr
ON
    po.c_order_id = mr.c_order_id
WHERE
    pol.qtyordered > (
        SELECT
            COALESCE(SUM(iol.qtyentered), 0)
        FROM
            adempiere.m_inoutline iol
        WHERE
            iol.c_orderline_id = pol.c_orderline_id
    ) and po.ad_client_id = 1000002;

TIP:- COALESCE this function is use null value to annotate o value.
Aggregating Data:- When using aggregate functions like SUM, AVG, or COUNT, COALESCE
				   can help ensure that NULL values are treated as zero or are not counted, depending on your requirements.

==================================================================================================================================================================
PO list show when not completed poline qty = inoutline qty:- 				   
select * from adempiere.m_inoutline
SELECT
    po.documentno AS purchase_order,
    pol.qtyordered AS po_qty_ordered,
    iol.qtyentered AS inbound_qty
FROM
    adempiere.c_order po
JOIN
    adempiere.c_orderline pol
ON
    po.c_order_id = pol.c_order_id
JOIN
    adempiere.m_inoutline iol
ON
    pol.c_orderline_id = iol.c_orderline_id
WHERE po.ad_client_id = 1000002 and
    pol.qtyordered > iol.qtyentered;

==================================================================================================================================================================
Show PO List with doc no.,date,supplier,warehouse,product,po qty and status:-

SELECT
    po.documentno AS purchase_order,
	bp.name AS Supplier,
	TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,
	wh.name AS Warehouse_Name,
	pr.name AS Product_Name,
    pol.qtyordered AS po_qty_ordered,
    CASE
        WHEN po.docstatus = 'DR' AND mr.m_inout_id IS NULL THEN 'Drafted, No Material Receipt'
		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN 'Completed, No Material Receipt'
		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN 'Material Receipt Created because some qty are pendding'
        ELSE 'Not Completed or Material Receipt Exists'
    END AS status
FROM adempiere.c_order po
JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id
LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id	
JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
JOIN adempiere.m_product pr ON pr.m_product_id = pol.m_product_id
WHERE pol.qtyordered > (
        SELECT COALESCE(SUM(iol.qtyentered), 0)
        FROM adempiere.m_inoutline iol
        WHERE iol.c_orderline_id = pol.c_orderline_id
    ) and po.ad_client_id = 1000002;

==================================================================================================================================================================
Change Date Formet:-
SELECT TO_CHAR(dateordered, 'DD-MM-YYYY') AS date_only
FROM adempiere.c_order where ad_client_id = 1000002 and issotrx = 'N'

only Date show not a time stamp:-
SELECT DATE(dateordered) AS date_only FROM adempiere.c_order where ad_client_id = 1000002 and issotrx = 'N'   

==================================================================================================================================================================

SELECT
    po.documentno AS purchase_order,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    pr.name AS Product_Name,
    pol.qtyordered AS po_qty_ordered,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true 
    END AS status
FROM adempiere.c_order po
JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id
LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id 
JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
JOIN adempiere.m_product pr ON pr.m_product_id = pol.m_product_id
WHERE pol.qtyordered > (
        SELECT COALESCE(SUM(iol.qtyentered), 0)
        FROM adempiere.m_inoutline iol
        WHERE iol.c_orderline_id = pol.c_orderline_id
    ) and po.ad_client_id = 1000002 and po.docstatus = 'CO'; 

==================================================================================================================================================================
No test:-
SELECT
    po.documentno AS purchase_order,
    pol.line AS po_line,
    pol.qtyordered AS po_qty_ordered,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN 'Completed, No Material Receipt'
        WHEN pol.qtyordered > COALESCE(SUM(iol.qty), 0) THEN 'PO Line Quantity > Inbound Shipment Quantity'
        ELSE 'Not Matched'
    END AS status,
    pol.qtyordered - COALESCE(SUM(iol.qty), 0) AS qty_difference
FROM
    c_order po
JOIN
    c_orderline pol
ON
    po.c_order_id = pol.c_order_id
LEFT JOIN
    m_inout mr
ON
    po.c_order_id = mr.c_order_id
LEFT JOIN
    m_inoutline iol
ON
    pol.c_orderline_id = iol.c_orderline_id
WHERE
    po.docstatus = 'CO'
GROUP BY
    po.documentno, pol.line, pol.qtyordered;
==================================================================================================================================================================
Current Data record find query:-
SELECT * FROM adempiere.m_storageonhand WHERE DATE(created) = CURRENT_DATE;

==================================================================================================================================================================
select a.documentno,
TO_CHAR(a.movementdate, 'DD-MM-YYYY') AS Date,
b.name,
c.name,
a.description
from adempiere.m_inventory a
join adempiere.m_warehouse b on a.m_warehouse_id = b.m_warehouse_id
join adempiere.ad_org c on a.ad_org_id = c.ad_org_id
where a.ad_client_id = 1000002 and a.docstatus = 'DR'
==================================================================================================================================================================
po data multiple same product but not minus repeat time :-

SELECT (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name
FROM adempiere.c_orderline a 
JOIN adempiere.c_order d ON d.c_order_id = a.c_order_id 
LEFT JOIN adempiere.m_inout b ON a.c_order_id = b.c_order_id 
LEFT JOIN adempiere.m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.c_orderline_id = a.c_orderline_id
JOIN adempiere.m_product e ON e.m_product_id = a.m_product_id 
WHERE d.documentno = '800022' AND d.ad_client_id = '11' AND a.c_order_id = (
  SELECT c_order_id FROM adempiere.c_order WHERE documentno = '800022' AND ad_client_id = '11'
)
GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id;
==================================================================================================================================================================
ALL List API DESC Format:-
PO List:-

SELECT DISTINCT
    po.documentno AS purchase_order,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true 
    END AS status
FROM adempiere.c_order po
JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id
LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id 
JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
WHERE pol.qtyordered > (
        SELECT COALESCE(SUM(iol.qtyentered), 0)
        FROM adempiere.m_inoutline iol
        WHERE iol.c_orderline_id = pol.c_orderline_id
    ) AND po.ad_client_id = 1000002 AND po.docstatus = 'CO' AND po.issotrx = 'N'
    ORDER BY po.documentno DESC; 
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------    
 MR List:-

SELECT
    DISTINCT(po.documentno) AS documentNo,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    co.documentno as orderDocumentno
FROM
    adempiere.m_inout po
JOIN
    adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id 
JOIN
    adempiere.c_order co ON co.c_order_id = po.c_order_id
JOIN
    adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
WHERE
    po.ad_client_id = 1000002
    AND po.docstatus = 'DR'
    AND po.ad_orgtrx_id IS NULL
    ORDER BY po.documentno DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------    
PI List:-

SELECT
    a.m_inventory_id,
    TO_CHAR(a.movementdate, 'DD/MM/YYYY') AS Date,
    b.name AS Warehouse_Name,
    c.name AS Org_Name,
    a.description
FROM
    adempiere.m_inventory a
JOIN
    adempiere.m_warehouse b ON a.m_warehouse_id = b.m_warehouse_id
JOIN
    adempiere.ad_org c ON a.ad_org_id = c.ad_org_id
WHERE
    a.ad_client_id = 1000002
    AND a.docstatus = 'DR'
    ORDER BY a.m_inventory_id DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------    
 SO List:-

SELECT DISTINCT
    so.documentno as Sales_Order,
    TO_CHAR(so.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    bp.name AS Customer,
    so.description,
    CASE
        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true 
    END AS status
FROM
    adempiere.c_order so
JOIN
    adempiere.c_orderline sol ON so.c_order_id = sol.c_order_id
JOIN
    adempiere.c_bpartner bp ON so.c_bpartner_id = bp.c_bpartner_id 
JOIN
    adempiere.m_warehouse wh ON so.m_warehouse_id = wh.m_warehouse_id
LEFT JOIN
    adempiere.m_inout mr ON so.c_order_id = mr.c_order_id
WHERE
    sol.qtyordered > (
        SELECT COALESCE(SUM(iol.qtyentered), 0)
        FROM adempiere.m_inoutline iol
        WHERE iol.c_orderline_id = sol.c_orderline_id
    )
AND
    so.ad_client_id = 1000002
AND
    so.issotrx = 'Y'
AND
    so.docstatus = 'CO'
    ORDER BY so.documentno DESC;
==================================================================================================================================================================
If m_inventoryline is null then m_inventory list also not show:-

SELECT DISTINCT(mi.m_inventory_id),TO_CHAR(mi.movementdate, 'DD-MM-YYYY') AS Date,b.name AS Warehouse_Name,
    o.name AS Org_Name,mi.description FROM adempiere.m_inventory mi
JOIN adempiere.m_inventoryline il ON il.m_inventory_id = mi.m_inventory_id
JOIN adempiere.m_warehouse b ON mi.m_warehouse_id = b.m_warehouse_id
JOIN adempiere.ad_org o ON mi.ad_org_id = o.ad_org_id
WHERE mi.ad_client_id = 11 AND il.m_inventory_id is not null AND mi.docStatus = 'DR' ORDER BY mi.m_inventory_id DESC;

==================================================================================================================================================================
Sales Order Details API currection enter document no only see required field not all field:-

SELECT
    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,
    bp.name AS Supplier,
    wh.name AS Warehouse_Name,
    po.description,
    ml.m_locator_id,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true
    END AS status
FROM
    adempiere.c_order po
JOIN
    adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id
LEFT JOIN
    adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN
    adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
JOIN
    adempiere.m_locator ml ON ml.m_warehouse_id = wh.m_warehouse_id
WHERE
    po.documentno = '50010'
    AND isDefault = 'Y' AND po.issotrx = 'Y';

==================================================================================================================================================================
Search Query for Receiving:-

SELECT DISTINCT
    po.documentno AS purchase_order,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true
    END AS status
FROM adempiere.c_order po
JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id
LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id
JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
WHERE pol.qtyordered > (
    SELECT COALESCE(SUM(iol.qtyentered), 0)
    FROM adempiere.m_inoutline iol
    WHERE iol.c_orderline_id = pol.c_orderline_id
)
AND po.ad_client_id = 1000002
AND po.docstatus = 'CO'
AND po.issotrx = 'N'
AND (
    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'
    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'
    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'
    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'
)
ORDER BY po.documentno DESC;

==================================================================================================================================================================
SELECT b.name AS Product_Name, a.expirydate as Date, e.qtyonhand AS Expiry_QTY, att.lot AS Lot_No, wh.value AS Warehouse_Name, ll.value AS Locator_Name 
FROM c_orderline a
JOIN m_product b ON a.m_product_id = b.m_product_id 
JOIN m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
JOIN m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN c_order f ON f.c_order_id = a.c_order_id
JOIN m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
JOIN m_locator ll ON ll.m_locator_id = e.m_locator_id
WHERE a.ad_client_id = 1000002 AND f.issotrx = 'N' AND a.expirydate < CURRENT_DATE

==================================================================================================================================================================
SELECT b.name AS Product_Name, a.expirydate as Date, e.qtyonhand AS ExpiryQTY, att.lot AS Lot_No, wh.value AS Warehouse_Name, ll.value AS Locator_Name 
FROM c_orderline a
JOIN m_product b ON a.m_product_id = b.m_product_id 
JOIN m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
JOIN m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN c_order f ON f.c_order_id = a.c_order_id
JOIN m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
JOIN m_locator ll ON ll.m_locator_id = e.m_locator_id
WHERE a.ad_client_id = 1000002 AND f.issotrx = 'N' AND a.expirydate >= CURRENT_DATE AND a.expirydate <= (CURRENT_DATE + MAKE_INTERVAL(months => 1))

==================================================================================================================================================================
PO List with search key:-
SELECT DISTINCT
    po.documentno AS purchase_order,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    CASE
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true
    END AS status
FROM adempiere.c_order po
JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id
LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id
JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id 
JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
WHERE pol.qtyordered > (
    SELECT COALESCE(SUM(iol.qtyentered), 0)
    FROM adempiere.m_inoutline iol
    WHERE iol.c_orderline_id = pol.c_orderline_id
) AND po.ad_client_id = '"+ clientID +"'
AND po.docstatus = 'CO'
AND po.issotrx = 'N'
AND (
    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'
    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'
    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'
    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'
)
ORDER BY po.documentno DESC;
-------------------------------------------------------------------------------------------------------------------------------
MR List with search key:-
SELECT DISTINCT
    po.documentno AS documentNo,
    bp.name AS Supplier,
    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    po.description,
    co.documentno AS orderDocumentno
FROM
    adempiere.m_inout po
JOIN
    adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id
JOIN
    adempiere.c_order co ON co.c_order_id = po.c_order_id
JOIN
    adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id
WHERE
    po.ad_client_id = '"+ clientID +"'
    AND po.docstatus = 'DR'
    AND po.ad_orgtrx_id IS NULL
    AND (
        po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'
        OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'
        OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'
        OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'
        OR co.documentno ILIKE '%' || COALESCE(?, co.documentno) || '%'
    )
ORDER BY po.documentno DESC;
-------------------------------------------------------------------------------------------------------------------------------
PI List with search key:-
SELECT
    a.m_inventory_id AS mrId,
    TO_CHAR(a.movementdate, 'DD-MM-YYYY') AS Date,
    b.name AS Warehouse_Name,
    c.name AS Org_Name,
    a.description
FROM
    adempiere.m_inventory a
JOIN
    adempiere.m_warehouse b ON a.m_warehouse_id = b.m_warehouse_id
JOIN
    adempiere.ad_org c ON a.ad_org_id = c.ad_org_id
WHERE
    a.ad_client_id = '"+ clientID +"'
    AND a.docstatus = 'DR'
    AND (
        a.m_inventory_id::VARCHAR ILIKE '%' || COALESCE(?, a.m_inventory_id::VARCHAR) || '%'
        OR c.name ILIKE '%' || COALESCE(?, c.name) || '%'
        OR b.name ILIKE '%' || COALESCE(?, b.name) || '%'
        OR a.description ILIKE '%' || COALESCE(?, a.description) || '%'
    )
ORDER BY a.m_inventory_id DESC;
------------------------------------------------------------------------------------------------------------------------------
SO List with search key:-
SELECT DISTINCT
    so.documentno AS Sales_Order,
    TO_CHAR(so.dateordered, 'DD/MM/YYYY') AS Order_Date,
    wh.name AS Warehouse_Name,
    bp.name AS Customer,
    so.description,
    CASE
        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false
        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true
    END AS status
FROM
    adempiere.c_order so
JOIN
    adempiere.c_orderline sol ON so.c_order_id = sol.c_order_id
JOIN
    adempiere.c_bpartner bp ON so.c_bpartner_id = bp.c_bpartner_id
JOIN
    adempiere.m_warehouse wh ON so.m_warehouse_id = wh.m_warehouse_id
LEFT JOIN
    adempiere.m_inout mr ON so.c_order_id = mr.c_order_id
WHERE
    sol.qtyordered > (
        SELECT COALESCE(SUM(iol.qtyentered), 0)
        FROM adempiere.m_inoutline iol
        WHERE iol.c_orderline_id = sol.c_orderline_id
    )
    AND so.ad_client_id = '"+ clientID +"'
    AND so.issotrx = 'Y'
    AND so.docstatus = 'CO'
    AND (
        so.documentno ILIKE '%' || COALESCE(?, so.documentno) || '%'
        OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'
        OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'
        OR so.description ILIKE '%' || COALESCE(?, so.description) || '%'
    )
ORDER BY so.documentno DESC;
==================================================================================================================================================================
Business partner wise payment records:-
if bill generate and bill not paid then list show business party wise 

SELECT c_invoice_id,grandtotal,TO_CHAR(dateinvoiced, 'DD/MM/YYYY') AS invoice_Date
FROM adempiere.c_invoice WHERE ad_client_id = 1000002 AND c_bpartner_id = 1000026 AND ispaid = 'N' 

==================================================================================================================================================================
After 42 days Customer List show based on Invoiced:-
SELECT bp.name AS Customer_Name,TO_CHAR(inv.created, 'DD/MM/YYYY') AS Invoice_Date,inv.grandtotal AS Amonut 
FROM adempiere.c_invoice inv 
JOIN adempiere.c_bpartner bp ON bp.c_bpartner_id = inv.c_bpartner_id
WHERE inv.ad_client_id = 1000002 AND inv.issotrx = 'Y' 
AND EXTRACT(DAY FROM (CURRENT_DATE - inv.dateinvoiced)) > 42

==================================================================================================================================================================
Create a new View:-
CREATE VIEW adempiere.chirag_test AS SELECT bp.name AS Customer_Name,inv.grandtotal AS Amonut 
FROM adempiere.c_invoice inv 
JOIN adempiere.c_bpartner bp ON bp.c_bpartner_id = inv.c_bpartner_id
WHERE inv.ad_client_id = 1000002 AND inv.issotrx = 'Y'
==================================================================================================================================================================
Create a new View:;-

CREATE VIEW adempiere.chirag_test AS SELECT * FROM adempiere.c_invoice (if you are not enter adempiere then create Public not a adempiere)
 
==================================================================================================================================================================
Create View some restriction Parameter:- like product,bpartnerand period 

 SELECT il.ad_client_id,
    il.ad_org_id,
    il.c_bpartner_id,
    il.m_product_id,
    adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying) AS dateinvoiced,
    sum(il.linenetamt) AS linenetamt,
    sum(il.linelistamt) AS linelistamt,
    sum(il.linelimitamt) AS linelimitamt,
    sum(il.linediscountamt) AS linediscountamt,
        CASE
            WHEN sum(il.linelistamt) = 0::numeric THEN 0::numeric
            ELSE adempiere.currencyround((sum(il.linelistamt) - sum(il.linenetamt)) / sum(il.linelistamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS linediscount,
    sum(il.lineoverlimitamt) AS lineoverlimitamt,
        CASE
            WHEN sum(il.linenetamt) = 0::numeric THEN 0::numeric
            ELSE 100::numeric - adempiere.currencyround((sum(il.linenetamt) - sum(il.lineoverlimitamt)) / sum(il.linenetamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS lineoverlimit,
    sum(il.qtyinvoiced) AS qtyinvoiced,
    il.issotrx
   FROM adempiere.rv_c_invoiceline il
     JOIN adempiere.c_invoice i ON i.c_invoice_id = il.c_invoice_id
  GROUP BY il.ad_client_id, il.ad_org_id, il.m_product_id, il.c_bpartner_id, (adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying)), il.issotrx, i.c_currency_id;

==================================================================================================================================================================
How to trace Locator available size:-

SELECT
  l.m_locator_id,
  l.value AS locator_name,
  l.maxquantity,
  COALESCE(l.maxquantity - COALESCE(SUM(m.qtybook), 0), l.maxquantity) AS available_size
FROM
  adempiere.m_locator l
LEFT JOIN
  adempiere.m_inventoryline m ON l.m_locator_id = m.m_locator_id
GROUP BY
  l.m_locator_id, l.value, l.maxquantity;

==================================================================================================================================================================
Purchase record deleted in terminal:-

Deleted Orderline:-

DELETE FROM adempiere.c_orderline
WHERE c_orderline_id = 1000302;

Deleted Order :-

DELETE FROM adempiere.c_order
WHERE c_order_id = 1000261;
==================================================================================================================================================================
Alter Table adempiere.c_bpartner
add column m_locator_id numeric(10,0);

==================================================================================================================================================================
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'm_inoutline' AND column_name = 'm_locator_id';

==================================================================================================================================================================
SELECT * FROM adempiere.m_warehouse WHERE m_reservelocator_id = 1000386;
UPDATE adempiere.m_warehouse SET m_reservelocator_id = null WHERE m_reservelocator_id = 1000386;
DELETE FROM adempiere.m_locator WHERE m_locator_id = 1000386;
DELETE FROM adempiere.m_warehouse WHERE m_warehouse_id = 1000019;

==================================================================================================================================================================
ALTER TABLE adempiere.m_inout ADD COLUMN pickStatus VARCHAR(255);
ALTER TABLE adempiere.c_order ADD COLUMN putStatus VARCHAR(255);

==================================================================================================================================================================
select i.c_bpartner_id,il.m_product_id,i.c_invoice_id,il.pricelist,il.qtyinvoiced,il.linenetamt from adempiere.c_invoice i
join adempiere.c_invoiceline il on i.c_invoice_id = il.c_invoice_id
where i.ad_client_id = 1000002 and i.issotrx = 'Y' 

==================================================================================================================================================================
sum and without sum product:-

SELECT
    c_bpartner_id,
    clientName,
    BPartnerName,
    c_invoice_id,
    date,
    ProductName,
    m_product_id,
    pricelist,
    qtyinvoiced AS IndividualQuantity,
    linenetamt AS IndividualNetAmount,
    SUM(qtyinvoiced) OVER(PARTITION BY c_bpartner_id, m_product_id) AS TotalQuantity,
    SUM(linenetamt) OVER(PARTITION BY c_bpartner_id, m_product_id) AS TotalNetAmount
FROM (
    SELECT
        i.c_bpartner_id,
        bp.name AS BPartnerName,
    cl.name as clientName,
        i.c_invoice_id,
        DATE(i.dateinvoiced) AS date,
        pr.name AS ProductName,
        il.m_product_id,
        il.pricelist,
        il.qtyinvoiced,
        il.linenetamt
    FROM
        adempiere.c_invoice i
    JOIN
        adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    JOIN
        adempiere.c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
    JOIN
        adempiere.m_product pr ON pr.m_product_id = il.m_product_id
    join adempiere.ad_client cl on cl.ad_client_id = i.ad_client_id
    WHERE
        i.ad_client_id = 1000002
        AND i.issotrx = 'Y'
        AND i.dateinvoiced > '2023/12/24'
        AND i.dateinvoiced < '2023/12/31'
) AS subquery
ORDER BY
    c_bpartner_id,
    m_product_id

==================================================================================================================================================================
Delete Warehouse id if locator is empty:-
DELETE FROM adempiere.M_Warehouse WHERE M_Warehouse_ID = 1000027;
==================================================================================================================================================================
SHOW PRODUCT LIST SALES AND AVAILABLE QTY:-

WITH InvoiceLineTotals AS (
SELECT il.m_product_id,SUM(il.qtyinvoiced) AS TotalQty,
SUM(il.linenetamt) AS TotalNetAmount FROM adempiere.c_invoice i
JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
WHERE i.ad_client_id =  1000002  AND i.issotrx = 'Y' ANd i.dateinvoiced > '01/11/2023' AND
i.dateinvoiced < '05/12/2023' GROUP BY il.m_product_id),
StorageOnHandTotals AS (
SELECT m_product_id,SUM(qtyonhand) AS AvailableQty
FROM adempiere.m_storageonhand WHERE Date(datematerialpolicy) < '04/12/2023' GROUP BY m_product_id),
BasePrice AS (
SELECT ol.m_product_id, MAX(ol.pricelimit) AS MaxPriceLimit
FROM adempiere.c_orderline ol
JOIN adempiere.c_order o ON o.c_order_id = ol.c_order_id
WHERE ol.ad_client_id =  1000002  AND o.issotrx = 'N'
GROUP BY m_product_id)
SELECT pr.name AS ProductName,COALESCE(i.TotalQty, 0) AS TotalQty,
ROUND(COALESCE(i.TotalNetAmount, 0),2) AS TotalNetAmount,
Round(COALESCE(s.AvailableQty, 0),0) AS AQty,cl.name As ClientName,
ROUND(COALESCE(b.MaxPriceLimit * s.AvailableQty, 0), 2) AS AValue
FROM adempiere.m_product pr
LEFT JOIN InvoiceLineTotals i ON pr.m_product_id = i.m_product_id
LEFT JOIN StorageOnHandTotals s ON pr.m_product_id = s.m_product_id
LEFT JOIN BasePrice b ON pr.m_product_id = b.m_product_id
join adempiere.ad_client cl on cl.ad_client_id = pr.ad_client_id
WHERE pr.ad_client_id =  1000002 ORDER BY pr.name

==================================================================================================================================================================
SALES $ STOCK ANALYSIS:-

WITH InvoiceLineTotals AS (
    SELECT
        il.m_product_id,
        SUM(il.qtyinvoiced) AS TotalQty,
        SUM(il.linenetamt) AS TotalNetAmount
    FROM
        adempiere.c_invoice i
        JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    WHERE
        i.ad_client_id = 1000002
        AND i.issotrx = 'Y'
        AND i.dateinvoiced >  $P{FromDate} 
        AND i.dateinvoiced <  $P{ToDate} 
    GROUP BY
        il.m_product_id
),
StorageOnHandTotals AS (
    SELECT
        m_product_id,
        SUM(qtyonhand) AS AvailableQty
    FROM
        adempiere.m_storageonhand
    WHERE
        DATE(datematerialpolicy) <  $P{ToDate} 
    GROUP BY
        m_product_id
),
BasePrice AS (
    SELECT
        ol.m_product_id,
        MAX(ol.pricelimit) AS MaxPriceLimit
    FROM
        adempiere.c_orderline ol
        JOIN adempiere.c_order o ON o.c_order_id = ol.c_order_id
    WHERE
        ol.ad_client_id = 1000002
        AND o.issotrx = 'N'
    GROUP BY
        m_product_id
),
PreviousMonth AS (
    SELECT
        il.m_product_id,
        SUM(il.qtyinvoiced) AS TotalPQty
    FROM
        adempiere.c_invoice i
        JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    WHERE
        i.ad_client_id = 1000002
        AND i.issotrx = 'Y'
        AND i.dateinvoiced >  $P{FromDate} ::DATE  -  INTERVAL '30 days'
        AND i.dateinvoiced <  $P{ToDate} ::DATE -  INTERVAL '30 days'
    GROUP BY
        il.m_product_id
)
SELECT
    pr.name AS ProductName,
    COALESCE(i.TotalQty, 0) AS TotalQty,
    ROUND(COALESCE(i.TotalNetAmount, 0), 2) AS TotalNetAmount,
    ROUND(COALESCE(s.AvailableQty, 0), 0) AS AQty,
    cl.name AS ClientName,
    ROUND(COALESCE(b.MaxPriceLimit * s.AvailableQty, 0), 2) AS AValue,
    ROUND(COALESCE(pp.TotalPQty, 0), 0) AS PQty
FROM
    adempiere.m_product pr
    LEFT JOIN InvoiceLineTotals i ON pr.m_product_id = i.m_product_id
    LEFT JOIN StorageOnHandTotals s ON pr.m_product_id = s.m_product_id
    LEFT JOIN BasePrice b ON pr.m_product_id = b.m_product_id
    LEFT JOIN PreviousMonth pp ON pr.m_product_id = pp.m_product_id
    JOIN adempiere.ad_client cl ON cl.ad_client_id = pr.ad_client_id
WHERE
    pr.ad_client_id = 1000002
ORDER BY
    pr.name

==================================================================================================================================================================
Current Date in Web Application :- @#Date@
Createing Date in Web Application for any table :- @SQL=SELECT created FROM adempiere.c_invoice WHERE issotrx='Y' AND AD_CLIENT_ID =@#AD_Client_ID@ limit 1

==================================================================================================================================================================
JasperReport view for bPartner wise sales Reports:-

select i.dateinvoiced, uo.name,i.c_invoice_id,i.c_bpartner_id,ac.name as clientName,i.c_invoice_id As InvoiceId,bp.name AS BPartnerName,pr.name AS ProductName,il.m_product_id,il.pricelist,il.qtyinvoiced,il.linenetamt from adempiere.c_invoice i
join adempiere.c_invoiceline il on i.c_invoice_id = il.c_invoice_id
join adempiere.c_bpartner bp on bp.c_bpartner_id = i.c_bpartner_id
join adempiere.m_product pr on pr.m_product_id = il.m_product_id 
join adempiere.ad_client ac on ac.ad_client_id = i.ad_client_id
join adempiere.c_uom uo on uo.c_uom_id = il.c_uom_id
where i.ad_client_id =  $P{AD_CLIENT_ID}  and i.dateinvoiced >  $P{FromDate} and i.dateinvoiced <   $P{ToDate} and i.issotrx = 'Y' order by c_bpartner_id, m_product_id

==================================================================================================================================================================
Baprtner wise sales Reports with date and invoices:-

SELECT
    c_bpartner_id,
    clientName,
    BPartnerName,
    c_invoice_id,
    date,
    ProductName,
    m_product_id,
    pricelist,
    qtyinvoiced AS IndividualQuantity,
    linenetamt AS IndividualNetAmount,
    SUM(qtyinvoiced) OVER(PARTITION BY c_bpartner_id, m_product_id) AS TotalQuantity,
    SUM(linenetamt) OVER(PARTITION BY c_bpartner_id, m_product_id) AS TotalNetAmount
FROM (
    SELECT
        i.c_bpartner_id,
        bp.name AS BPartnerName,
    cl.name as clientName,
        i.c_invoice_id,
        DATE(i.dateinvoiced) AS date,
        pr.name AS ProductName,
        il.m_product_id,
        il.pricelist,
        il.qtyinvoiced,
        il.linenetamt
    FROM
        adempiere.c_invoice i
    JOIN
        adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    JOIN
        adempiere.c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
    JOIN
        adempiere.m_product pr ON pr.m_product_id = il.m_product_id
    join adempiere.ad_client cl on cl.ad_client_id = i.ad_client_id
    WHERE
        i.ad_client_id =    $P{AD_CLIENT_ID} 
        AND i.issotrx = 'Y'
        AND i.dateinvoiced >   $P{FromDate}    
        AND i.dateinvoiced <   $P{ToDate} 
         AND (
        $P{BPartnerId} IS NULL OR
        i.c_bpartner_id = $P{BPartnerId}
    )   
) AS subquery
ORDER BY
    c_bpartner_id,
    m_product_id

==================================================================================================================================================================
Sales Representative wise Sales report but this query is working not salesRepid parameter wise show every time all records:-

SELECT 
    i.documentno AS invoice_number,
    bp.name AS Customer,
    br.ad_user_id,
    i.c_bpartner_id,
    i.salesrep_id,
    il.m_product_id,
    ad.name AS clientName,
    p.name AS productName,
    il.qtyinvoiced AS quantity,
    il.linenetamt AS netAmt,
    br.name AS SalesRep,
    i.dateinvoiced 
FROM 
    adempiere.c_invoice i
JOIN 
    adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
JOIN 
    adempiere.m_product p ON il.m_product_id = p.m_product_id
JOIN 
    adempiere.ad_user br ON i.salesrep_id = br.ad_user_id 
JOIN 
    adempiere.c_bpartner bp ON i.c_bpartner_id = bp.c_bpartner_id
JOIN 
    adempiere.ad_client ad ON ad.ad_client_id = i.ad_client_id
WHERE 
    i.issotrx = 'Y'  
    AND p.ad_client_id = $P{AD_CLIENT_ID}  
    AND i.dateinvoiced > $P{FromDate}     
    AND i.dateinvoiced < $P{ToDate}  
    AND (
        $P{SalesRepId} IS NULL OR br.ad_user_id = $P{SalesRepId}
    )
ORDER BY 
    i.salesrep_id, i.c_bpartner_id

==================================================================================================================================================================
Slaes & Stock Analysis with PreviousMonth sales qty details:-

WITH InvoiceLineTotals AS (
    SELECT
        il.m_product_id,
        SUM(il.qtyinvoiced) AS TotalQty,
        SUM(il.linenetamt) AS TotalNetAmount
    FROM
        adempiere.c_invoice i
        JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    WHERE
        i.ad_client_id =  $P{AD_CLIENT_ID} 
        AND i.issotrx = 'Y'
        AND i.dateinvoiced >  $P{FromDate} 
        AND i.dateinvoiced <  $P{ToDate} 
    GROUP BY
        il.m_product_id
),
StorageOnHandTotals AS (
    SELECT
        m_product_id,
        SUM(qtyonhand) AS AvailableQty
    FROM
        adempiere.m_storageonhand
    WHERE
        DATE(datematerialpolicy) <  $P{ToDate} 
    GROUP BY
        m_product_id
),
BasePrice AS (
    SELECT
        ol.m_product_id,
        MAX(ol.pricelimit) AS MaxPriceLimit
    FROM
        adempiere.c_orderline ol
        JOIN adempiere.c_order o ON o.c_order_id = ol.c_order_id
    WHERE
        ol.ad_client_id =  $P{AD_CLIENT_ID} 
        AND o.issotrx = 'N'
    GROUP BY
        m_product_id
),
PreviousMonth AS (
    SELECT
        il.m_product_id,
        SUM(il.qtyinvoiced) AS TotalPQty
    FROM
        adempiere.c_invoice i
        JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
    WHERE
        i.ad_client_id =  $P{AD_CLIENT_ID} 
        AND i.issotrx = 'Y'
        AND i.dateinvoiced >  $P{FromDate} ::DATE  -  INTERVAL '30 days'
        AND i.dateinvoiced <  $P{ToDate} ::DATE -  INTERVAL '30 days'
    GROUP BY
        il.m_product_id
)
SELECT
    pr.name AS ProductName,pr.m_product_id,
    COALESCE(i.TotalQty, 0) AS TotalQty,
    ROUND(COALESCE(i.TotalNetAmount, 0), 2) AS TotalNetAmount,
    ROUND(COALESCE(s.AvailableQty, 0), 0) AS AQty,
    cl.name AS ClientName,
    ROUND(COALESCE(b.MaxPriceLimit * s.AvailableQty, 0), 2) AS AValue,
    ROUND(COALESCE(pp.TotalPQty, 0), 0) AS PQty
FROM
    adempiere.m_product pr
    LEFT JOIN InvoiceLineTotals i ON pr.m_product_id = i.m_product_id
    LEFT JOIN StorageOnHandTotals s ON pr.m_product_id = s.m_product_id
    LEFT JOIN BasePrice b ON pr.m_product_id = b.m_product_id
    LEFT JOIN PreviousMonth pp ON pr.m_product_id = pp.m_product_id
    JOIN adempiere.ad_client cl ON cl.ad_client_id = pr.ad_client_id
WHERE
    pr.ad_client_id =  $P{AD_CLIENT_ID} 
    AND ($P{ProductId} IS NULL OR
 pr.m_product_id = $P{ProductId})
ORDER BY
    pr.name
==================================================================================================================================================================
Transaction dashboard:-

sql = "SELECT COUNT(DISTINCT mi) AS inoutCount,\n"
                        + "(SELECT COUNT(a) FROM adempiere.m_inout a WHERE a.movementtype = 'V+' AND DATE(a.created) = DATE(NOW())) AS inCount,\n"
                        + "(SELECT COUNT(b) FROM adempiere.m_inout b WHERE b.movementtype = 'C-' AND DATE(b.created) = DATE(NOW())) AS outCount,\n"
                        + "(SELECT COUNT(DISTINCT c) FROM adempiere.m_movement c WHERE DATE(c.created) = DATE(NOW()) AND c.m_warehouse_id = c.m_warehouseto_id) AS internalMoveCount, \n"
                        + "(SELECT COUNT(d) FROM adempiere.m_inoutlineconfirm d WHERE qcfailedqty != 0.00 AND DATE(d.created) = DATE(NOW())) AS qc\n"
                        + "FROM adempiere.m_inout mi WHERE DATE(mi.created) = DATE(NOW()) AND mi.ad_client_id = "+ clientId +";";
            } else if (wareHouseId != 0 && productId == 0) {
                sql = "SELECT COUNT(DISTINCT mi) AS inoutCount,\n"
                        + "(SELECT COUNT(a) FROM adempiere.m_inout a WHERE a.movementtype = 'V+' AND a.m_warehouse_id = "+ wareHouseId +" AND DATE(a.created) = DATE(NOW())) AS inCount,\n"
                        + "(SELECT COUNT(b) FROM adempiere.m_inout b WHERE b.movementtype = 'C-' AND b.m_warehouse_id = "+ wareHouseId +" AND DATE(b.created) = DATE(NOW())) AS outCount,\n"
                        + "(SELECT COUNT(DISTINCT c) FROM adempiere.m_movement c WHERE DATE(c.created) = DATE(NOW()) AND c.m_warehouse_id = "+ wareHouseId +") AS internalMoveCount, \n"
                        + "(SELECT COUNT(d) FROM adempiere.m_inoutlineconfirm d JOIN adempiere.m_inoutline ili ON ili.m_inoutline_id = c.m_inoutline_id JOIN adempiere.m_inout ii ON ii.m_inout_id = ili.m_inout_id\n"
                        + "JOIN adempiere.m_warehouse whh ON whh.m_warehouse_id = ii.m_warehouse_id WHERE qcfailedqty != 0.00 AND whh.m_warehouse_id = "+ wareHouseId +" AND DATE(d.created) = DATE(NOW())) AS qc\n"
                        + "FROM adempiere.m_inout mi WHERE DATE(mi.created) = DATE(NOW()) AND mi.m_warehouse_id = "+ wareHouseId +" AND mi.ad_client_id = "+ clientId +";";
            } else if (wareHouseId == 0 && productId != 0) {
                sql = "SELECT COUNT(DISTINCT mi) as inoutCount,\n"
                        + "(SELECT COUNT(a) FROM m_inout a JOIN m_inoutline aa ON aa.m_inout_id = a.m_inout_id WHERE a.movementtype = 'V+' AND aa.M_product_id = "+productId+" AND DATE(a.created) = DATE(NOW())) as inCount,\n"
                        + "(SELECT COUNT(a) FROM m_inout a JOIN m_inoutline aa ON aa.m_inout_id = a.m_inout_id WHERE a.movementtype = 'C-' AND aa.m_product_id = "+productId+" AND DATE(a.created) = DATE(NOW())) as outCount,\n"
                        + "(SELECT COUNT(DISTINCT c) FROM m_movement c JOIN m_movementline cc ON cc.m_movement_id = c.m_movement_id WHERE DATE(c.created) = DATE(NOW()) AND cc.m_product_id = "+productId+") as internalMoveCount,\n"
                        + "(SELECT COUNT(d) FROM adempiere.m_inoutlineconfirm d JOIN adempiere.m_inoutline ili ON ili.m_inoutline_id = c.m_inoutline_id JOIN adempiere.m_inout ii ON ii.m_inout_id = ili.m_inout_id\n"
                        + "JOIN adempiere.m_product wh ON wh.m_product_id = ili.m_product_id WHERE qcfailedqty != 0.00 AND wh.m_product_id = "+productId+" AND DATE(d.created) = DATE(NOW())) AS qc\n"
                        + "FROM m_inout mi JOIN m_inoutline mil ON mil.m_inout_id = mi.m_inout_id WHERE DATE(mi.created) = DATE(NOW()) AND mi.ad_client_id = "+clientId+" AND mil.m_product_id = "+productId+";";
            }
            pstmt = DB.prepareStatement(sql.toString(), null);
            RS = pstmt.executeQuery();
            while (RS.next()) {
                inoutCount = RS.getString("inoutCount");
                inCount = RS.getString("inCount");
                outCount = RS.getString("outCount");
                internalMoveCount = RS.getString("internalMoveCount");
                qaRejections = RS.getString("qc");
            }

==================================================================================================================================================================
ReturnQty and allQty query:-

SELECT SUM(movementqty) AS AllQty,(SELECT SUM(movementqty) AS returnQty FROM adempiere.m_inout i JOIN adempiere.m_inoutline li ON li.m_inout_id = i.m_inout_id WHERE i.ad_client_id = 1000002 AND i.movementtype = 'C+')
FROM adempiere.m_inout i JOIN adempiere.m_inoutline li ON li.m_inout_id = i.m_inout_id WHERE i.ad_client_id = 1000002 AND i.movementtype = 'C-'

==================================================================================================================================================================
Return dashboard:-

String sql = null;
            String returnPendingSql = null;
            if (wareHouseId == 0 && productId == 0) {
                sql = "SELECT SUM(DISTINCT(movementqty))AS salesQty,SUM(DISTINCT(qtydelivered)) AS returnQty FROM adempiere.m_rma rm\n"
                        + "JOIN adempiere.m_inout ii ON ii.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_inoutline ili ON ili.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_rmaline rmli ON rmli.m_rma_id = rm.m_rma_id\n"
                        + "WHERE rm.ad_client_id = " + clientId + ";";
                
                returnPendingSql = "SELECT count(docStatus) from m_inout mi \n"
                        + "join c_docType cd on cd.c_docType_Id = mi.c_docType_Id\n"
                        + "where cd.name = 'MM Customer Return' and mi.docstatus = 'DR' and mi.ad_client_id=" + clientId
                        + ";";
            } else if (wareHouseId != 0 && productId == 0) {
                sql = "SELECT SUM(DISTINCT(movementqty))AS salesQty,SUM(DISTINCT(qtydelivered)) AS returnQty FROM adempiere.m_rma rm\n"
                        + "JOIN adempiere.m_inout ii ON ii.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_inoutline ili ON ili.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_rmaline rmli ON rmli.m_rma_id = rm.m_rma_id\n"
                        + "JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = ii.m_warehouse_id\n"
                        + "WHERE ii.m_warehouse_id = "+ wareHouseId +" AND rm.ad_client_id = "+ clientId +";";

                returnPendingSql = "SELECT count(docStatus) from m_inout mi \n"
                        + "join c_docType cd on cd.c_docType_Id = mi.c_docType_Id\n"
                        + "where cd.name = 'MM Customer Return' and mi.docstatus = 'DR' and mi.ad_client_id=" + clientId
                        + " and mi.m_warehouse_id =" + wareHouseId + ";";
            } else if (wareHouseId == 0 && productId != 0) {
                sql = "SELECT SUM(DISTINCT(movementqty))AS salesQty,SUM(DISTINCT rmli.qtydelivered) AS returnQty FROM adempiere.m_rma rm\n"
                        + "JOIN adempiere.m_inout ii ON ii.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_inoutline ili ON ili.m_inout_id = rm.inout_id\n"
                        + "JOIN adempiere.m_rmaline rmli ON rmli.m_rma_id = rm.m_rma_id\n"
                        + "JOIN adempiere.m_product pd ON pd.m_product_id = rmli.m_product_id\n"
                        + "WHERE rm.ad_client_id = "+ clientId +" and rmli.m_product_id = "+ productId +"";

                returnPendingSql = "SELECT count(docStatus) from m_inout mi \n"
                        + "join c_docType cd on cd.c_docType_Id = mi.c_docType_Id\n"
                        + "join m_inoutline ml on ml.m_inout_id = mi.m_inout_id\n"
                        + "where cd.name = 'MM Customer Return' and mi.docstatus = 'DR' and mi.ad_client_id=" + clientId
                        + " and ml.m_product_id =" + productId + ";";
            }

==================================================================================================================================================================

CREATE VIEW adempiere.salesinvoicess AS
SELECT
    iv.c_order_id,
    iv.documentno AS Order_No,
    TO_CHAR(iv.DateOrdered, 'DD-Mon-YYYY') AS Date_Ordered,
    org.name AS OrgName,
    org_loc.address AS org_address,
    org_loc.city AS org_city,
    org_loc.regionname AS org_regionname,
    org_loc.countryname AS org_countryname,
    org_loc.postal AS org_postal,
    bp_loc.address AS bp_address,
    bp_loc.city AS bp_city,
    bp_loc.regionname AS bp_regionname,
    bp_loc.countryname AS bp_countryname,
    bp_loc.postal AS bp_postal,
    CASE
        WHEN ivl.m_product_id > 0 THEN mp.name
        ELSE cha.name
    END AS item,
    iv.totallines AS SubTotal,
    iv.grandtotal AS Total_Amount,
    (iv.grandtotal - iv.totallines) AS Tax_Amount,
    ivl.line AS Product_SNo,
    mp.name AS Product_Name,
    ivl.qtyordered AS Product_Qty_Invoiced,
    ROUND(ivl.priceentered, 2) AS Product_Price_Entered,
    cr.iso_code AS Product_Currency_Name,
    tax.name AS Product_Tax_Name,
    tax.rate AS Product_Tax_Rate,
    CASE
        WHEN tax.rate = 0.00 THEN 0.00
        ELSE (ivl.linenetamt * tax.rate / 100)
    END AS Product_Tax_Amount,
    mp.hsncode AS Product_HSN,
    ivl.linenetamt AS Product_Line_Amount,
    bp.name AS customer_name,
    adempiere.fnNumberToWords(iv.grandtotal::BIGINT) AS AmountInWord,
    cr.description AS currency_name,
    orginfo.phone,
    cli.gstno AS client_gstno,
    cli.panno AS client_panno,
    bp.gstno AS bp_gstno,
    bp.panno AS bp_panno,
    cr.cursymbol,
    cli.Name AS CompanyName
FROM adempiere.c_order iv
INNER JOIN adempiere.c_orderline ivl ON (iv.c_order_id = ivl.c_order_id)
LEFT JOIN adempiere.ad_image img ON (ivl.image_id = img.ad_image_id)
INNER JOIN adempiere.c_bpartner bp ON (bp.c_bpartner_id = iv.c_bpartner_id)
INNER JOIN adempiere.ad_client cli ON (cli.ad_client_id = iv.ad_client_id)
INNER JOIN adempiere.ad_org org ON (org.AD_Org_ID = iv.AD_Org_ID)
INNER JOIN adempiere.ad_orginfo orginfo ON (orginfo.AD_Org_ID = iv.AD_Org_ID)
LEFT JOIN adempiere.ad_image org_img ON (orginfo.Logo_ID = org_img.ad_image_id)
INNER JOIN adempiere.location_details org_loc ON (org_loc.c_location_id = orginfo.c_location_id)
INNER JOIN adempiere.c_bpartner_location bpl ON (bpl.c_bpartner_location_id = iv.c_bpartner_location_id)
INNER JOIN adempiere.m_warehouse wh ON (wh.m_warehouse_id = iv.m_warehouse_id)
INNER JOIN adempiere.location_details ware_loc ON (ware_loc.c_location_id = wh.c_location_id)
INNER JOIN adempiere.location_details bp_loc ON (bp_loc.c_location_id = bpl.c_location_id)
LEFT JOIN adempiere.m_product mp ON (mp.m_product_id = ivl.m_product_id)
LEFT JOIN adempiere.c_charge cha ON (cha.c_charge_id = ivl.c_charge_id)
INNER JOIN adempiere.c_uom uom ON (uom.c_uom_id = ivl.c_uom_id)
INNER JOIN adempiere.c_tax tax ON (tax.c_tax_id = ivl.c_tax_id)
INNER JOIN adempiere.c_currency cr ON (cr.c_currency_id = iv.c_currency_id)
ORDER BY ivl.line;

==================================================================================================================================================================
Jasper Report for if condtion:-
$F{city}==null ? '-' : $F{city} 

==================================================================================================================================================================
Material receipt Reports:-

SELECT i.documentno, i.movementdate, b.name as bpname, b.value as bpvalue, loc.address1,loc.address2, loc.postal, loc.city, c.name as country,ili.qcfailedqty,ili.line,orginfo.phone, orginfo.fax, orginfo.email, orgloc.address1 as orgaddress, orgloc.city as orgcity, orgloc.postal as orgpostal, org.name as orgname, img.binarydata as orglogo,cor.documentno AS SalesOrderNo,wh.name AS warehouseName from adempiere.m_inout i 
join adempiere.c_bpartner b on b.c_bpartner_id=i.c_bpartner_id
join adempiere.c_bpartner_location bploc on bploc.c_bpartner_location_id=i.c_bpartner_location_id
join adempiere.c_location loc on loc.c_location_id=bploc.c_location_id
join adempiere.c_country c on c.c_country_id=loc.c_country_id
join adempiere.ad_orginfo orginfo on orginfo.ad_org_id=i.ad_org_id
join adempiere.c_location orgloc on orgloc.c_location_id=orginfo.c_location_id
join adempiere.ad_org org on org.ad_org_id=i.ad_org_id
left join adempiere.ad_image img on img.ad_image_id =orginfo.logo_id
join adempiere.c_order cor ON cor.c_order_id = i.c_order_id 
join adempiere.m_warehouse wh ON wh.m_warehouse_id = i.m_warehouse_id
join adempiere.m_inoutline ili ON ili.m_inout_id = i.m_inout_id
where i.m_inout_id=1000280

select ili.line as pos, ili.movementqty,ili.qcfailedqty,pr.name as product from adempiere.m_inoutline ili
join adempiere.m_product pr on pr.m_product_id = ili.m_product_id
where ili.m_inout_id= 1000280
ORDER BY ili.line

select * from adempiere.m_inoutline

SELECT i.documentno, i.movementdate, b.name as bpname, b.value as bpvalue, loc.address1,loc.address2, loc.postal, loc.city, c.name as country,ili.qcfailedqty,ili.line,orginfo.phone, orginfo.fax, orginfo.email, orgloc.address1 as orgaddress, orgloc.city as orgcity, orgloc.postal as orgpostal, org.name as orgname, img.binarydata as orglogo,cor.documentno AS SalesOrderNo,wh.name AS warehouseName from adempiere.m_inout i 
join adempiere.c_bpartner b on b.c_bpartner_id=i.c_bpartner_id
join adempiere.c_bpartner_location bploc on bploc.c_bpartner_location_id=i.c_bpartner_location_id
join adempiere.c_location loc on loc.c_location_id=bploc.c_location_id
join adempiere.c_country c on c.c_country_id=loc.c_country_id
join adempiere.ad_orginfo orginfo on orginfo.ad_org_id=i.ad_org_id
join adempiere.c_location orgloc on orgloc.c_location_id=orginfo.c_location_id
join adempiere.ad_org org on org.ad_org_id=i.ad_org_id
left join adempiere.ad_image img on img.ad_image_id =orginfo.logo_id
join adempiere.c_order cor ON cor.c_order_id = i.c_order_id 
join adempiere.m_warehouse wh ON wh.m_warehouse_id = i.m_warehouse_id
join adempiere.m_inoutline ili ON ili.m_inout_id = i.m_inout_id
where i.m_inout_id=1000280

==================================================================================================================================================================
update all doc action in material receipt windows:-
UPDATE adempiere.m_inout
SET DocStatus = 'CO'
WHERE DocStatus = 'DR' and ad_client_id = 1000002 and issotrx = 'N';

==================================================================================================================================================================
Material Receipt remove records:-

select * from adempiere.m_inout where documentno ='1000551' and ad_client_id = 1000002

DELETE FROM adempiere.m_inout WHERE documentno = '1000551' and ad_client_id = 1000002;

select * from adempiere.m_inoutline where m_inoutline_id = 1002577 and ad_client_id = 1000002;

delete from adempiere.m_inoutline where m_inoutline_id = 1002577 and ad_client_id = 1000002;

delete from adempiere.m_transaction where m_inoutline_id = 1002577 and ad_client_id = 1000002;

delete from adempiere.m_matchpo where m_inoutline_id = 1002577 and ad_client_id = 1000002;

select * from adempiere.m_matchpo where m_inoutline_id = 1002577 and ad_client_id = 1000002;

select * from adempiere.m_transaction where m_inoutline_id = 1002577 and ad_client_id = 1000002;

==================================================================================================================================================================
Near Expiry Product list not randomly product show:-

CREATE OR REPLACE VIEW adempiere.NearExpiryProductLists AS
SELECT 
    b.name AS product_name,
    a.expirydate AS expiry_date,
    e.qtyonhand AS quantity,
    att.lot AS lot_no,
    wh.value AS warehouse_name,
    ll.value AS locator_name,
    f.ad_client_id,
    f.ad_org_id
FROM 
    adempiere.c_orderline a
JOIN 
    adempiere.m_product b ON a.m_product_id = b.m_product_id
JOIN 
    adempiere.m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
JOIN 
    adempiere.m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN 
    adempiere.m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN 
    adempiere.c_order f ON f.c_order_id = a.c_order_id
JOIN 
    adempiere.m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
JOIN 
    adempiere.m_locator ll ON ll.m_locator_id = e.m_locator_id
WHERE 
    f.issotrx = 'N' 
    AND a.expirydate >= CURRENT_DATE 
    AND a.expirydate IS NOT NULL      
    AND att.lot IS NOT NULL AND e.qtyonhand > 0;

==================================================================================================================================================================
Expiry Product List:-

CREATE OR REPLACE VIEW adempiere.ExpiryProductDetails AS
   SELECT b.name AS product_name,
    a.expirydate AS expiry_date,
    e.qtyonhand AS quantity,
    att.lot AS lot_no,
    wh.value AS warehouse_name,
    ll.value AS locator_name,
    f.ad_client_id,
    f.ad_org_id
   FROM adempiere.c_orderline a
     JOIN adempiere.m_product b ON a.m_product_id = b.m_product_id
     JOIN adempiere.m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
     JOIN adempiere.m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
     JOIN adempiere.m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
     JOIN adempiere.c_order f ON f.c_order_id = a.c_order_id
     JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
     JOIN adempiere.m_locator ll ON ll.m_locator_id = e.m_locator_id
  WHERE f.issotrx = 'N' AND a.expirydate < CURRENT_DATE AND a.expirydate IS NOT NULL      
    AND att.lot IS NOT NULL AND e.qtyonhand > 0;

==================================================================================================================================================================

select u.name As User,pl.labeluuid as label, mp.name As productName,uom.name As uom,ml.m_inout_id,pl.quantity As Quantity,to_char(pl.created, 'DD/MM/YYYY') AS date,
to_char(pl.created, 'DD/MM/YYYY hh:mi:ss AM') As dateTime from adempiere.pi_productlabel pl
JOIN adempiere.m_inoutline ml on ml.m_inoutline_id = pl.m_inoutline_id 
JOIN adempiere.m_product mp on mp.m_product_id = pl.m_product_Id 
JOIN adempiere.ad_user u ON u.ad_user_id = pl.createdby
JOIN adempiere.c_uom uom ON uom.c_uom_id = mp.c_uom_id
where pl.ad_client_id = 1000000 and ml.m_inout_id = 1000018 ;

==================================================================================================================================================================
Customer list with overdue days:-

 SELECT inv.c_invoice_id AS invoice_id,
    bp.name AS customer_name,
    to_char(inv.dateinvoiced, 'DD/MM/YYYY'::text) AS invoice_date,
    inv.grandtotal AS total_amount,
    inv.ad_client_id,
    inv.ad_org_id,
    (CURRENT_DATE - 42)::timestamp without time zone - inv.dateinvoiced AS overduedays
   FROM adempiere.c_invoice inv
     JOIN adempiere.c_bpartner bp ON bp.c_bpartner_id = inv.c_bpartner_id
  WHERE inv.ispaid = 'N' AND inv.issotrx = 'Y' AND inv.dateinvoiced <= (CURRENT_DATE - 42) and inv.ad_client_id = 1000002;

==================================================================================================================================================================
Added Favourite in dashboard:-

INSERT INTO adempiere.ad_tree_favorite_node(ad_client_id,ad_menu_id,ad_org_id,ad_tree_favorite_id, ad_tree_favorite_node_id,
seqno,createdby,updatedby,isfavourite) Values(1000002,205,1000004,1000012,1000012,1111100,1000002,1000002,'Y');
==================================================================================================================================================================
Added 5 records:-

INSERT INTO adempiere.ad_tree_favorite_node(ad_client_id,ad_menu_id,ad_org_id,ad_tree_favorite_id, ad_tree_favorite_node_id,
seqno,createdby,updatedby,isfavourite) Values(1000002,205,1000004,1000012,1000012,1111100,1000002,1000002,'Y'),
(1000002,204,1000004,1000012,1000012,1111100,1000002,1000002,'Y'),(1000002,129,1000004,1000012,1000012,1111100,1000002,1000002,'Y'),
(1000002,180,1000004,1000012,1000012,1111100,1000002,1000002,'Y'),(1000002,178,1000004,1000012,1000012,1111100,1000002,1000002,'Y');

==================================================================================================================================================================
qcfailedqty check:-

select m.m_inout_id,mli.m_product_id,mli.movementqty,mli.qcfailedqty,(mli.movementqty - mli.qcfailedqty) AS substralQty from adempiere.m_inout m
JOIN adempiere.m_inoutline mli ON mli.m_inout_id = m.m_inout_id
where m.ad_client_id = 1000002 and m.issotrx = 'N' and DATE(m.created) = DATE(NOW())


==================================================================================================================================================================
Warehouse list Query:-

SELECT w.m_warehouse_id AS warehouseID,w.name AS warehouseName,ml.m_locator_id AS locatorID,ml.value AS locatorValue,
ml.isdefault,CASE WHEN COALESCE(ms.TotalQty, 0) = 0 THEN 'false' ELSE 'true' END AS booleanValue,
COALESCE(ms.TotalQty, 0) AS TotalQty,((SELECT COUNT(*)FROM adempiere.M_Locator
WHERE m_warehouse_id = w.m_warehouse_id) - (SELECT COUNT(*)FROM adempiere.M_Locator l
LEFT JOIN (SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty FROM adempiere.M_StorageOnHand
GROUP BY M_Locator_ID) ms ON l.M_Locator_ID = ms.M_Locator_ID WHERE l.m_warehouse_id = w.m_warehouse_id
AND COALESCE(ms.TotalQty, 0) = 0)) * 100 / (SELECT COUNT(*)FROM adempiere.M_Locator
WHERE m_warehouse_id = w.m_warehouse_id) AS occupancy_percentage,lt.name AS locator_type
FROM adempiere.m_warehouse w JOIN adempiere.m_locator ml ON ml.m_warehouse_id = w.m_warehouse_id
JOIN adempiere.m_locatortype lt ON ml.m_locatortype_id = lt.m_locatortype_id
LEFT JOIN (SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty FROM adempiere.M_StorageOnHand
GROUP BY M_Locator_ID) ms ON ml.m_locator_id = ms.M_Locator_ID
WHERE ml.ad_client_id = 1000002
group by w.m_warehouse_id, w.name,ml.m_locator_id, lt.name, ml.value,ms.TotalQty, ml.isdefault;

==================================================================================================================================================================


==================================================================================================================================================================
"SELECT \n" + "    w.m_warehouse_id as warehouseID,\n" + "    w.name as warehouseName,\n"
          + " ml.isdefault,\n" + "    (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "     LEFT JOIN (\n"
          + "         SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
          + "         FROM adempiere.M_StorageOnHand\n" + "         GROUP BY M_Locator_ID\n"
          + "     ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
          + "     WHERE l.m_warehouse_id = w.m_warehouse_id\n"
          + "     AND COALESCE(ms.TotalQty, 0) = 0) AS emptyCount,\n"
          + "    (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS total_count,\n"
          + "    lt.name AS locator_type,\n" + "    ml.value AS location_values,\n"
          + "    ((SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) - \n"
          + "     (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "      LEFT JOIN (\n"
          + "          SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
          + "          FROM adempiere.M_StorageOnHand\n" + "          GROUP BY M_Locator_ID\n"
          + "      ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
          + "      WHERE l.m_warehouse_id = w.m_warehouse_id\n" + "      AND COALESCE(ms.TotalQty, 0) = 0) \n"
          + "    ) * 100 / (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS occupancy_percentage\n"
          + "FROM \n" + "    adempiere.m_warehouse w\n" + "JOIN \n"
          + "    adempiere.m_locator ml ON ml.m_warehouse_id = w.m_warehouse_id\n" + "JOIN \n"
          + "    adempiere.m_locatortype lt ON ml.m_locatortype_id = lt.m_locatortype_id\n" + "WHERE \n"
          + "    ml.ad_client_id = " + ad_client_id + "\n" + "GROUP BY \n"
          + "    w.m_warehouse_id, w.name, lt.name,ml.value,ml.isdefault;"

==================================================================================================================================================================
-- Create pi_qrRelations table in PostgreSQL
CREATE TABLE adempiere.pi_qrRelations (
    pi_qrRelations_id SERIAL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    isShippedOut NUMERIC(10,0),
    pstatus text,
    quantity NUMERIC,
    isInLocator NUMERIC(10,0),
    productId NUMERIC(10,0),
    locatorId NUMERIC(10,0),
    cOrderlineId NUMERIC(10,0),
    mInoutlineId NUMERIC(10,0),
    palletUUId varchar(255),
    FOREIGN KEY (ad_client_id) REFERENCES adempiere.ad_client(ad_client_id),
    FOREIGN KEY (ad_org_id) REFERENCES adempiere.ad_org(ad_org_id),
    FOREIGN KEY (createdby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (updatedby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (productId) REFERENCES adempiere.m_product(m_product_id),
    FOREIGN KEY (cOrderlineId) REFERENCES adempiere.c_orderline(c_orderline_id),
    FOREIGN KEY (mInoutlineId) REFERENCES adempiere.m_inoutline(m_inoutline_id)
);

==================================================================================================================================================================
Working Table:-
CREATE TABLE adempiere.c_farmer (
    c_farmer_id numeric(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    FarmerName VARCHAR(25) NOT NULL,
    Created TIMESTAMP without time zone DEFAULT now() not null,
    Createdby numeric(10,0) not null,
    Updated TIMESTAMP without time zone DEFAULT now() not null,
    Updatedby NUMERIC(10,0) not null,
    Description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,  
    Address VARCHAR(255),
    Landmark VARCHAR(100),
    SurveyNumber VARCHAR(10),
    VillageName VARCHAR(50),
    MobileNo NUMERIC(10));


==================================================================================================================================================================
One Table relation two another table:-

CREATE TABLE adempiere.c_kishan (
    c_kishan_id numeric(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    KishanName VARCHAR(25) NOT NULL,
    Created TIMESTAMP without time zone DEFAULT now() not null,
    Createdby numeric(10,0) not null,
    Updated TIMESTAMP without time zone DEFAULT now() not null,
    Updatedby NUMERIC(10,0) not null,
    Description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,  
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar);
  short table to added specific records like (name,id,etc)

CREATE TABLE adempiere.c_farmlist (
    c_farmlist_id numeric(10,0) NOT NULL PRIMARY KEY,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    FarmerName VARCHAR(25) NOT NULL,
    Created TIMESTAMP without time zone DEFAULT now() not null,
    Createdby numeric(10,0) not null,
    Updated TIMESTAMP without time zone DEFAULT now() not null,
    Updatedby NUMERIC(10,0) not null,
    Description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault character(1) NOT NULL DEFAULT 'N'::bpchar,
    c_kishan_id numeric(10,0),
    FOREIGN KEY (c_kishan_id) REFERENCES adempiere.c_kishan(c_kishan_id));
this table a main table and this table multiple child like show list last two line added this methods

both two table created Table & Column, Window,Tab and Field Window 

above line done then created Reference window(this records important otherwise not show list view in other table)

Mandotory fields:-
Name(show in Reference_key),EntiryType = UserMaintain,Validaion = Table Validation and save 

bottom see Table Validation tab create a new records
Mandotory Field:-
Table - Name of Table like c_kishan
Key_Column - c_kishan_id
Display Column - KishanName (Your Requirement what are you Display in list)
sql where - c_kishan.c_kishan_id<>0 

// If not use in isactive field window is not proper working
==================================================================================================================================================================
Stock checked:-

SELECT EXTRACT(DAY FROM CURRENT_DATE - i.created) AS stockCheckDays
FROM adempiere.m_inventory i 
JOIN adempiere.m_inventoryline li ON i.m_inventory_id = li.m_inventory_id
WHERE i.ad_client_id = 1000002
ORDER BY i.created DESC
LIMIT 1;

==================================================================================================================================================================
pi label and view table:-

CREATE TABLE adempiere.pi_productLabel (
    pi_productLabel_ID SERIAL PRIMARY KEY,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    qcPassed varchar(1),
    quantity NUMERIC,
    m_product_ID NUMERIC(10,0),
    m_locator_ID NUMERIC(10,0),
    c_orderline_ID NUMERIC(10,0) NULL,
    m_inoutline_ID NUMERIC(10,0) NULL,
    issotrx varchar(1),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    labelUUId varchar(255),
    FOREIGN KEY (ad_client_iD) REFERENCES adempiere.ad_client(ad_client_id),
    FOREIGN KEY (ad_org_iD) REFERENCES adempiere.ad_org(ad_org_id),
    FOREIGN KEY (createdby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (updatedby) REFERENCES adempiere.ad_user(ad_user_id),
    FOREIGN KEY (m_product_ID) REFERENCES adempiere.m_product(m_product_id),
    FOREIGN KEY (m_locator_ID) REFERENCES adempiere.m_locator(m_locator_ID),
    FOREIGN KEY (c_orderline_ID) REFERENCES adempiere.c_orderline(c_orderline_id),
    FOREIGN KEY (m_inoutline_ID) REFERENCES adempiere.m_inoutline(m_inoutline_id)
);

View Table:-

CREATE VIEW adempiere.pi_productlabelview AS 
SELECT p.m_product_id,
    lo.m_warehouse_id,
    p.m_locator_id,
    p.m_inoutline_id,
    p.c_orderline_id,
    o.c_order_id,
    p.labeluuid,
    p.quantity,
    p.qcpassed,
    p.issotrx,
    p.created,
    p.ad_client_id,
    p.ad_org_id
FROM adempiere.pi_productlabel p
    JOIN adempiere.m_locator lo ON lo.m_locator_id = p.m_locator_id
    JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = lo.m_warehouse_id
    JOIN adempiere.c_orderline li ON li.c_orderline_id = p.c_orderline_id
    JOIN adempiere.c_order o ON o.c_order_id = li.c_order_id;

==================================================================================================================================================================
locator wise product list:-

SELECT ly.name AS locatorTypeName,SUM(sh.qtyonhand) AS Qty FROM adempiere.m_locatortype ly 
JOIN adempiere.m_locator lo ON lo.m_locatortype_id = ly.m_locatortype_id
JOIN adempiere.m_storageonhand sh ON sh.m_locator_id = lo.m_locator_id
WHERE ly.ad_client_id = 1000002 GROUP BY ly.name

==================================================================================================================================================================
warehouse wise product list:-

SELECT wh.name AS warehouseName,SUM(sh.qtyonhand) AS Qty FROM adempiere.m_warehouse wh
JOIN adempiere.m_locator lo ON lo.m_warehouse_id = wh.m_warehouse_id
JOIN adempiere.m_storageonhand sh ON sh.m_locator_id = lo.m_locator_id
WHERE wh.ad_client_id = 1000002 GROUP BY wh.name

-------------------

SELECT 
    wh.name AS warehouseName,wh.m_warehouse_id ,
    COALESCE(SUM(sh.qtyonhand), 0) AS Qty 
FROM 
    adempiere.m_warehouse wh
LEFT JOIN 
    adempiere.m_locator lo ON lo.m_warehouse_id = wh.m_warehouse_id
LEFT JOIN 
    adempiere.m_storageonhand sh ON sh.m_locator_id = lo.m_locator_id
WHERE 
    wh.ad_client_id = 1000002 AND sh.m_product_id = 1000041 
GROUP BY 
    wh.name,wh.m_warehouse_id;

==================================================================================================================================================================
Merge of two or more  table:-
SELECT name,value,created,description FROM adempiere.m_product
UNION
SELECT name,value,created,description FROM adempiere.c_bpartner
UNION
SELECT name,value,created,description FROM adempiere.ad_user
where ad_client_id = 1000002 order by created desc;

==================================================================================================================================================================
Label Report View:-

CREATE VIEW adempiere.pi_productlabelviews AS
SELECT p.m_product_id,lo.m_warehouse_id,p.m_locator_id,p.m_inoutline_id,p.c_orderline_id,o.c_order_id,
p.labeluuid AS LabelUUID ,p.quantity AS Quantity,p.qcpassed,p.issotrx,p.created,p.ad_client_id,p.ad_org_id FROM adempiere.pi_productLabel p
JOIN adempiere.m_locator lo ON lo.m_locator_id = p.m_locator_id 
JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = lo.m_warehouse_id
JOIN adempiere.c_orderline li ON li.c_orderline_id = p.c_orderline_id
JOIN adempiere.c_order o ON o.c_order_id = li.c_order_id;


==================================================================================================================================================================
Remove FOREIGN key one table to another table FOREIGN key:-

this query use show constraint value for your table :-

SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'tc_hardeningdetail'
AND constraint_type = 'FOREIGN KEY';

enter constraint value and remove FOREIGN key:-

ALTER TABLE adempiere.tc_hardeningdetail DROP CONSTRAINT tc_hardeningdetail_tc_cropdetils_id_fkey;

Remove FOREIGN key id and column name :-

ALTER TABLE adempiere.tc_hardeningdetail DROP COLUMN tc_cropdetils_id;

and last check id is remove or not:-

select * from adempiere.tc_hardeningdetail


SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'tc_light'
AND constraint_type = 'FOREIGN KEY';

ALTER TABLE adempiere.tc_light DROP CONSTRAINT tc_light_m_locator_id_fkey;
ALTER TABLE adempiere.tc_light DROP COLUMN m_locator_id;


==================================================================================================================================================================
Added FOREIGN KEY in any other table:-

ALTER TABLE adempiere.tc_collectiondetails
ADD COLUMN tc_plantdetails_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_collectiondetails
ADD CONSTRAINT tc_collectiondetails_tc_plantdetails_id_fkey
FOREIGN KEY (tc_plantdetails_id)
REFERENCES adempiere.tc_plantdetails(tc_plantdetails_id);


==================================================================================================================================================================
Create a new Model (will be explained more in detail)
Except for the other mandatory fields the model must contain the following fields
C_DocType_ID numeric(10,0) NOT NULL DEFAULT 0::numeric (Reference = Table, Reference Key = C_DocType)
C_DocTypeTarget_ID numeric(10,0) NOT NULL DEFAULT 0::numeric
DocAction character varying(2) NOT NULL DEFAULT 'CO'::bpchar (Reference = Button, Process = Custom Workflow, Reference Key = _Document Action)
DocStatus character varying(2) NOT NULL DEFAULT 'DR'::character varying (Reference = List, Reference Key = _Document Status)
DocumentNo character varying(30) NOT NULL
processed character(1) DEFAULT 'N'::bpchar
processing character(1) DEFAULT 'N'::bpchar
isapproved character(1) NOT NULL DEFAULT 'Y'::bpchar
Generate the model class
The model class must implement DocAction.

==================================================================================================================================================================
Change Data Type:-
ALTER TABLE adempiere.tc_cycle
ALTER COLUMN cycle_no TYPE VARCHAR(10);
==================================================================================================================================================================
Reports:-
CREATE VIEW adempiere.tc_stagewiseProductivity AS
SELECT o.m_product_id As Stage,o.m_locator_id AS RRC,o.quantity,l.x AS Room 
FROM adempiere.tc_out o
JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id

CREATE VIEW adempiere.tc_techwiseP AS SELECT ord.salesrep_id,o.m_product_id,o.m_locator_id,o.quantity,o.ad_client_id,o.ad_org_id FROM adempiere.tc_out o
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
==================================================================================================================================================================
report Query:-

SELECT i.tc_in_id,CONCAT(i_pr.name, '-', o_pr.name) AS StageAndCycle,
    CASE 
        WHEN LAG(i.tc_in_id) OVER (ORDER BY i.tc_in_id) = i.tc_in_id THEN ''
        ELSE i.quantity::text
    END AS i_quantity,o.quantity AS o_quantity
FROM adempiere.tc_out o
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
WHERE DATE(o.created) = DATE(NOW()) 
ORDER BY i.tc_in_id;

         Final:-

CREATE OR REPLACE VIEW adempiere.tcv_CultureProductionView AS
SELECT CONCAT(i_pr.name, '-', o_pr.name) AS StageAndCycle,
    CASE WHEN LAG(i.tc_in_id) OVER (ORDER BY i.tc_in_id) = i.tc_in_id THEN NULL
    ELSE i.quantity END AS quantity,
    NULLIF(CASE WHEN o_pr.name LIKE 'M%' OR o_pr.name LIKE 'N%' THEN o.quantity ELSE 0 END, 0) AS M,
    NULLIF(CASE WHEN o_pr.name LIKE 'E%' THEN o.quantity ELSE 0 END, 0) AS E,
    NULLIF(CASE WHEN o_pr.name LIKE 'R%' THEN o.quantity ELSE 0 END, 0) AS R,
    o.ad_client_id,o.ad_org_id,o.created
FROM adempiere.tc_out o
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id;


Reports:-

SELECT 
    i_pr.name AS stageAndCycle,
    NULLIF(SUM(CASE WHEN DATE(i.created) = DATE(NOW()) THEN i.quantity ELSE 0 END), 0) AS OpeningStock,
    NULLIF(SUM(CASE WHEN DATE(i.created) != DATE(NOW()) THEN i.quantity ELSE 0 END), 0) AS Stocked,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'N%' THEN o.quantity ELSE 0 END), 0) AS N,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'M%' THEN o.quantity ELSE 0 END), 0) AS M,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'E%' THEN o.quantity ELSE 0 END), 0) AS E,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'R%' THEN o.quantity ELSE 0 END), 0) AS R,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'H%' THEN o.quantity ELSE 0 END), 0) AS Hardning
FROM 
    adempiere.tc_in i
JOIN 
    adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN 
    adempiere.tc_out o ON o.tc_in_id = i.tc_in_id
JOIN 
    adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
GROUP BY
    i_pr.name;

            Final:-

CREATE VIEW adempiere.tcv_growthRoomCultureProduction AS
SELECT i_pr.name AS stageAndCycle,
    NULLIF(SUM(CASE WHEN DATE(i.created) != DATE(NOW()) THEN i.quantity ELSE 0 END), 0) AS OpeningStock,
    NULLIF(SUM(CASE WHEN DATE(i.created) = DATE(NOW()) THEN i.quantity ELSE 0 END), 0) AS Stocked,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'N%' THEN o.quantity ELSE 0 END), 0) AS N,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'M%' THEN o.quantity ELSE 0 END), 0) AS M,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'E%' THEN o.quantity ELSE 0 END), 0) AS E,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'R%' THEN o.quantity ELSE 0 END), 0) AS R,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'H%' THEN o.quantity ELSE 0 END), 0) AS Hardning,
    i.ad_client_id,i.ad_org_id,MAX(Date(i.created)) AS orderDate
FROM adempiere.tc_in i
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_out o ON o.tc_in_id = i.tc_in_id
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
GROUP BY i_pr.name,i.ad_client_id,i.ad_org_id;   


With MediaOutLines AS (
SELECT pro.m_product_id,sum(mol.quantity) As TotalQty
    from adempiere.tc_mediaoutline mol
    JOIN adempiere.m_product pro ON pro.m_product_id = mol.m_product_id
    GROUP BY pro.m_product_id),
MediaLines AS (
SELECT pr.m_product_id,
NULLIF(SUM(CASE WHEN DATE(ml.created) != DATE(NOW()) THEN ml.quantity ELSE 0 END), 0) AS OpeningStock,
NULLIF(SUM(CASE WHEN DATE(ml.created) = DATE(NOW()) THEN ml.quantity ELSE 0 END), 0) AS Stocked 
from adempiere.tc_medialine ml
JOIN adempiere.m_product pr ON pr.m_product_id = ml.m_product_id
    GROUP BY pr.m_product_id)
select pr.m_product_id,pr.name AS MediaCategory,pr.description AS CodeIfAny,
ROUND(COALESCE(ml.OpeningStock, 0), 0) AS OpeningBalance,
ROUND(COALESCE(ml.Stocked, 0), 0) AS MediaStocked,
ROUND(COALESCE(mol.TotalQty, 0), 0) AS IssueToCT,
(COALESCE(ml.OpeningStock, 0) + COALESCE(ml.Stocked, 0) - COALESCE(mol.TotalQty, 0)) AS Balance
from adempiere.m_product pr
LEFT JOIN MediaLines ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN MediaOutLines mol ON pr.m_product_id = mol.m_product_id
where pr.m_product_category_id = 1000005


Final:-

WITH MediaOutLines AS (
    SELECT 
        pro.m_product_id,
        SUM(mol.quantity) AS TotalQty
    FROM 
        adempiere.tc_mediaoutline mol
    JOIN 
        adempiere.m_product pro ON pro.m_product_id = mol.m_product_id
    GROUP BY 
        pro.m_product_id
),
MediaLines AS (
    SELECT 
        pr.m_product_id,
        NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date = DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS OpeningStock,
        NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date != DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS Stocked 
    FROM 
        adempiere.tc_medialine ml
    JOIN 
        adempiere.m_product pr ON pr.m_product_id = ml.m_product_id
    GROUP BY 
        pr.m_product_id
)
SELECT 
    pr.m_product_id,
    pr.name AS MediaCategory,
    pr.description AS CodeIfAny,
    ROUND(COALESCE(ml.OpeningStock, 0), 0) AS OpeningBalance,
    ROUND(COALESCE(ml.Stocked, 0), 0) AS MediaStocked,
    ROUND(COALESCE(mol.TotalQty, 0), 0) AS IssueToCT,
    (COALESCE(ml.OpeningStock, 0) + COALESCE(ml.Stocked, 0) - COALESCE(mol.TotalQty, 0)) AS Balance
FROM 
    adempiere.m_product pr
LEFT JOIN 
    MediaLines ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN 
    MediaOutLines mol ON pr.m_product_id = mol.m_product_id
WHERE 
    pr.m_product_category_id = 1000005;

==================================================================================================================================================================
CREATE TABLE adempiere.tc_mediaorder (
        tc_mediaorder_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        name varchar(25) NOT NULL,value varchar(25),
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        description VARCHAR(255),
        documentNo VARCHAR(25) NOT NULL,
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
        docaction CHAR(2) NOT NULL DEFAULT 'CO'::bpchar,
        DocStatus CHAR(2) NOT NULL DEFAULT 'DR'::bpchar,
        c_doctype_id numeric(10,0) NOT NULL,
        c_doctypetarget_id numeric(10,0) NOT NULL,
        processed CHAR(1) DEFAULT 'N'::bpchar,
        processing CHAR(1) DEFAULT 'N'::bpchar,
        isapproved CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        dateOrdered DATE,
        salesrep_id NUMERIC(10,0),
        m_warehouse_id NUMERIC(10,0),
        FOREIGN KEY (m_warehouse_id) REFERENCES adempiere.m_warehouse(m_warehouse_id));
        
        
        CREATE TABLE adempiere.tc_medialine (
        tc_medialine_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        line numeric(10,0) NOT NULL,
        description VARCHAR(255),
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        quantity NUMERIC(10,0), 
        tc_mediaorder_id NUMERIC(10,0),
        m_locator_id NUMERIC(10,0),
        m_product_id NUMERIC(10,0),
        c_uom_id NUMERIC(10,0),
        FOREIGN KEY (c_uom_id) REFERENCES adempiere.c_uom(c_uom_id),    
        FOREIGN KEY (tc_mediaorder_id) REFERENCES adempiere.tc_mediaorder(tc_mediaorder_id),
        FOREIGN KEY (m_locator_id) REFERENCES adempiere.m_locator(m_locator_id),
        FOREIGN KEY (m_product_id) REFERENCES adempiere.m_product(m_product_id));


        CREATE TABLE adempiere.tc_mediaoutline (
        tc_mediaoutline_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
        ad_client_id NUMERIC(10, 0) NOT NULL,
        ad_org_id NUMERIC(10, 0) NOT NULL,
        created TIMESTAMP without time zone DEFAULT now() NOT NULL,
        createdby NUMERIC(10,0) NOT NULL,
        updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
        updatedby NUMERIC(10,0) NOT NULL,
        description VARCHAR(255),
        isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar,
        quantity NUMERIC(10,0),
        tc_order_id NUMERIC(10,0),
        m_locator_id NUMERIC(10,0),
        m_product_id NUMERIC(10,0),
        c_uom_id NUMERIC(10,0),
        tc_out_id NUMERIC(10,0),
        tc_medialine_id NUMERIC(10,0),
        tc_mediaoutline_uu VARCHAR(36) DEFAULT NULL::bpchar,
        FOREIGN KEY (c_uom_id) REFERENCES adempiere.c_uom(c_uom_id),
        FOREIGN KEY (tc_out_id) REFERENCES adempiere.tc_out(tc_out_id),
        FOREIGN KEY (tc_medialine_id) REFERENCES adempiere.tc_medialine(tc_medialine_id),
        FOREIGN KEY (tc_order_id) REFERENCES adempiere.tc_order(tc_order_id),
        FOREIGN KEY (m_locator_id) REFERENCES adempiere.m_locator(m_locator_id),
        FOREIGN KEY (m_product_id) REFERENCES adempiere.m_product(m_product_id));
==================================================================================================================================================================
Postgres data backup:-
pg_dump -U adempiere erp > data.sql

==================================================================================================================================================================
Tissue Report in server:-

1. StagewiseProductivity
CREATE OR REPLACE VIEW adempiere.tc_stagewiseProductivity AS
SELECT o.m_product_id As Stage,o.m_locator_id AS RRC,o.quantity,l.x AS Room,o.created,o.ad_client_id,o.ad_org_id,,pr.name As StageN 
FROM adempiere.tc_out o
JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id
JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id;

2. TechnicianWise Productivity
CREATE OR REPLACE VIEW adempiere.tc_technicianWiseProductvity AS 
SELECT ord.salesrep_id AS Technician,o.m_product_id AS StageId,o.m_locator_id RRC,o.quantity,o.ad_client_id,o.ad_org_id,o.created,pr.name As Stage 
FROM adempiere.tc_out o
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id;

3. Culture Production 
CREATE OR REPLACE VIEW adempiere.tcv_CultureProductionView AS
SELECT CONCAT(i_pr.name, '-', o_pr.name) AS StageAndCycle,
    CASE WHEN LAG(i.tc_in_id) OVER (ORDER BY i.tc_in_id) = i.tc_in_id THEN NULL
    ELSE i.quantity END AS quantity,
    NULLIF(CASE WHEN o_pr.name LIKE 'M%' OR o_pr.name LIKE 'N%' THEN o.quantity ELSE 0 END, 0) AS M,
    NULLIF(CASE WHEN o_pr.name LIKE 'E%' THEN o.quantity ELSE 0 END, 0) AS E,
    NULLIF(CASE WHEN o_pr.name LIKE 'R%' THEN o.quantity ELSE 0 END, 0) AS R,
    o.ad_client_id,o.ad_org_id,o.created
FROM adempiere.tc_out o
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id;

4. GrowthRoom Culture Production
CREATE VIEW adempiere.tcv_growthRoomCultureProduction AS
SELECT i_pr.name AS stageAndCycle,
    NULLIF(SUM(CASE WHEN DATE_TRUNC('month', i.created) != DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0) AS OpeningStock,
    NULLIF(SUM(CASE WHEN DATE_TRUNC('month', i.created) = DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0) AS Stocked,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'N%' THEN o.quantity ELSE 0 END), 0) AS ToCT,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'M%' THEN o.quantity ELSE 0 END), 0) AS M,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'E%' THEN o.quantity ELSE 0 END), 0) AS E,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'R%' THEN o.quantity ELSE 0 END), 0) AS R,
    NULLIF(SUM(CASE WHEN o_pr.name LIKE 'H%' THEN o.quantity ELSE 0 END), 0) AS Hardning,
    i.ad_client_id,i.ad_org_id,MAX(Date(i.created)) AS orderDate
FROM adempiere.tc_in i
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_out o ON o.tc_in_id = i.tc_in_id
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
GROUP BY i_pr.name,i.ad_client_id,i.ad_org_id;

5. Media Production:-
CREATE OR REPLACE VIEW adempiere.tcv_MediaProduction AS
WITH MediaOutLines AS (
SELECT pro.m_product_id,SUM(mol.quantity) AS TotalQty
FROM adempiere.tc_mediaoutline mol
JOIN adempiere.m_product pro ON pro.m_product_id = mol.m_product_id
GROUP BY pro.m_product_id),
MediaLines AS (
SELECT pr.m_product_id,MIN(DATE(ml.created)) AS created,
NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date = DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS OpeningStock,
NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date != DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS Stocked 
FROM adempiere.tc_medialine ml
JOIN adempiere.m_product pr ON pr.m_product_id = ml.m_product_id
GROUP BY pr.m_product_id)
SELECT pr.m_product_id,pr.name AS MediaCategory,pr.description AS CodeIfAny,
COALESCE(ml.OpeningStock, 0) AS OpeningBalance,COALESCE(ml.Stocked, 0) AS MediaStocked,
COALESCE(mol.TotalQty, 0) AS IssueToCT,
(COALESCE(ml.OpeningStock, 0) + COALESCE(ml.Stocked, 0) - COALESCE(mol.TotalQty, 0)) AS Balance,ml.created,pr.ad_client_id,pr.ad_org_id
FROM adempiere.m_product pr
LEFT JOIN MediaLines ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN MediaOutLines mol ON pr.m_product_id = mol.m_product_id
WHERE pr.m_product_category_id = 1000005;


==================================================================================================================================================================
ALTER TABLE adempiere.tc_farmer ALTER COLUMN mobileno TYPE VARCHAR(11);
==================================================================================================================================================================
Jasper line seperator:-
"Room (X) : " + $F{x} + System.getProperty("line.separator") +
"Rack (Y) : " + $F{y} + System.getProperty("line.separator") +
"Column (Z) : " + $F{z}
==================================================================================================================================================================
SELECT v.name,vt.name AS VisitType,v.date,
    CASE 
        WHEN v.description = 'completed' THEN 'Completed'
        WHEN v.description = 'cancel' THEN 'Cancelled'
        ELSE 'In Progress'
    END AS Status
FROM adempiere.tc_visit v
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000;

==================================================================================================================================================================
 create view adempiere.tcv_expiryview AS
 SELECT s.name AS species,
    v.name AS variety,
    cs.name AS stageandcycle,
    cd.parentcultureline,
    cd.date,
        CASE
            WHEN (cd.date + '21 days'::interval) >= CURRENT_DATE THEN date(cd.date + '21 days'::interval)
            ELSE NULL::date
        END AS expiry_date,
    cd.ad_client_id,
    cd.ad_org_id
   FROM adempiere.tc_culturedetails cd
     JOIN adempiere.tc_plantspecies s ON s.tc_plantspecies_id = cd.tc_species_id
     JOIN adempiere.tc_plantspecies si ON si.tc_plantspecies_id = cd.tc_species_ids
     JOIN adempiere.tc_variety v ON v.tc_variety_id = s.tc_variety_id
     JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cd.tc_culturestage_id;
==================================================================================================================================================================
SELECT
    COUNT(CASE WHEN v.description = 'completed' THEN 1 END) AS Completed_Count,
    COUNT(CASE WHEN v.description = 'cancel' THEN 1 END) AS Cancelled_Count,
    COUNT(CASE WHEN v.description is null THEN 1 END) AS InProgress_Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000;

==================================================================================================================================================================
SELECT 
    SUM(CASE WHEN DATE(created) = CURRENT_DATE THEN suckerno ELSE 0 END) AS today_sucker_sum,
    SUM(suckerno) AS all_no_sucker
FROM adempiere.tc_collectiondetails
WHERE ad_client_id = 1000000;
==================================================================================================================================================================
SELECT COUNT(*) AS incount ,
(SELECT COUNT(*) AS outCount FROM adempiere.tc_out)
FROM adempiere.tc_in
WHERE ad_client_id = 1000000
==================================================================================================================================================================
This query is most important because this two different required done:-

SELECT inCount,inQty,outCount,outQty
FROM (SELECT COUNT(*) AS inCount,SUM(quantity) AS inQty
FROM adempiere.tc_in WHERE ad_client_id = 1000000) AS inSubquery,
(SELECT COUNT(*) AS outCount,SUM(quantity) AS outQty 
FROM adempiere.tc_out) AS outSubquery;
==================================================================================================================================================================
SELECT 
    (SELECT COUNT(*) FROM adempiere.tc_visit WHERE ad_client_id = 1000000) AS TO_Count,
    (SELECT COUNT(*) FROM adempiere.tc_order WHERE ad_client_id = 1000000) AS LT_Count,
    (SELECT COUNT(*) FROM adempiere.tc_mediaorder WHERE ad_client_id = 1000000) AS ML_Count;
==================================================================================================================================================================
Attachement Image convert base 64;-
            
         MAttachment attechment = MAttachment.get(ctx, tableId,recordId);
         MAttachmentEntry[] entries = attechment.getEntries();
          
          for(MAttachmentEntry entry : entries) {
              byte[] data = entry.getData();
              
             base64 = Base64.getEncoder().encodeToString(data);
          }
         System.out.println(base64);
            

==================================================================================================================================================================
Remove not null value :-
ALTER TABLE adempiere.tc_firstvisit ALTER COLUMN name DROP NOT NULL;

==================================================================================================================================================================
SELECT Category,SUM(TotalQuantity) AS TotalQuantity
FROM (
    SELECT 
        CASE 
            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'
            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'
            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'
            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'
            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Hardening'
            ELSE 'Other'
        END AS Category,
        o.quantity AS TotalQuantity
    FROM adempiere.tc_out o
    JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id
) AS Subquery
WHERE Category <> 'Other' GROUP BY Category ORDER BY Category;

==================================================================================================================================================================
SELECT vt.name AS VisitType,
    COALESCE(COUNT(v.tc_visittype_id), 0) AS VisitCount,u.name AS UserName
FROM adempiere.tc_visittype vt
CROSS JOIN adempiere.ad_user u
LEFT JOIN adempiere.tc_visit v ON vt.tc_visittype_id = v.tc_visittype_id
AND u.ad_user_id = v.createdby
WHERE u.ad_user_id IN (SELECT ad_user_id FROM adempiere.ad_user_roles WHERE ad_role_id = 1000002) AND vt.ad_client_id = 1000000
GROUP BY vt.name,vt.tc_visittype_id, u.name
ORDER BY u.name,vt.tc_visittype_id, vt.name;

==================================================================================================================================================================
SELECT vt.name AS VisitType,
    COALESCE(COUNT(v.tc_visittype_id), 0) AS VisitCount,u.name AS UserName
FROM adempiere.tc_visittype vt
CROSS JOIN adempiere.ad_user u
LEFT JOIN adempiere.tc_visit v ON vt.tc_visittype_id = v.tc_visittype_id
AND u.ad_user_id = v.createdby
WHERE u.ad_user_id IN (SELECT ad_user_id FROM adempiere.ad_user_roles WHERE ad_role_id = 1000002) AND vt.ad_client_id = 1000000
GROUP BY vt.name,vt.tc_visittype_id, u.name
ORDER BY u.name,vt.tc_visittype_id, vt.name;

==================================================================================================================================================================
select sr.name,pr.name,ou.quantity from adempiere.tc_order o
join adempiere.ad_user sr ON o.salesrep_id = sr.ad_user_id
join adempiere.tc_out ou ON ou.tc_order_id = o.tc_order_id
join adempiere.m_product pr ON pr.m_product_id = ou.m_product_id
where o.ad_client_id = 1000000 order by sr.name
==================================================================================================================================================================
WITH user_totals AS (SELECT sr.ad_user_id AS user_id,
sr.name AS user_names,SUM(ou.quantity) AS total_quantity
FROM adempiere.tc_order o
JOIN adempiere.ad_user sr ON o.salesrep_id = sr.ad_user_id
JOIN adempiere.tc_out ou ON ou.tc_order_id = o.tc_order_id
WHERE o.ad_client_id = 1000000
GROUP BY sr.ad_user_id, sr.name),
max_user AS (SELECT user_id,user_names,total_quantity
FROM user_totals ORDER BY total_quantity DESC LIMIT 1)
SELECT 
    CASE
        WHEN ut.user_id = mu.user_id THEN ut.user_names
        ELSE ut.user_names
    END AS UserName,
    ut.user_id AS UserId,SUM(ut.total_quantity) AS TotalQuantity
FROM user_totals ut
CROSS JOIN max_user mu
GROUP BY 
    CASE
        WHEN ut.user_id = mu.user_id THEN ut.user_names
        ELSE ut.user_names
    END, ut.user_id
ORDER BY ut.user_id;

this query is proper working

==================================================================================================================================================================
SELECT 'Completed' AS Status,
    COUNT(CASE WHEN v.description = 'completed' THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000
UNION ALL
SELECT 'Cancelled' AS Status,
    COUNT(CASE WHEN v.description = 'cancel' THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000
UNION ALL
SELECT 'Upcoming' AS Status,
    COUNT(CASE WHEN v.description IS NULL THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000;

==
SELECT o.salesrep_id, u.name AS user_name, SUM(ml.quantity) AS total_quantity
FROM adempiere.tc_mediaorder o
JOIN adempiere.tc_medialine ml ON ml.tc_mediaorder_id = o.tc_mediaorder_id
JOIN adempiere.ad_user u ON u.ad_user_id = o.salesrep_id
GROUP BY o.salesrep_id, u.name;
================================================================================================================================================================
SELECT o.salesrep_id AS userId, u.name AS userName, SUM(ml.quantity) AS totalQuantity
FROM adempiere.tc_mediaorder o
JOIN adempiere.tc_medialine ml ON ml.tc_mediaorder_id = o.tc_mediaorder_id
JOIN adempiere.ad_user u ON u.ad_user_id = o.salesrep_id
WHERE o.ad_client_id = 1000000
GROUP BY o.salesrep_id, u.name;

==================================================================================================================================================================
CREATE OR REPLACE VIEW adempiere.TCV_mediareports AS
WITH MediaOutLines AS (
SELECT pro.m_product_id,SUM(mol.quantity) AS TotalQty,mol.description
FROM adempiere.tc_mediaoutline mol
JOIN adempiere.m_product pro ON pro.m_product_id = mol.m_product_id
GROUP BY pro.m_product_id,mol.description),
MediaLines AS (
SELECT pr.m_product_id,MIN(DATE(ml.created)) AS created,
NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date = DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS openingstock,
NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date != DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS Stocked 
FROM adempiere.tc_medialine ml
JOIN adempiere.m_product pr ON pr.m_product_id = ml.m_product_id
GROUP BY pr.m_product_id)
SELECT pr.m_product_id,pr.name AS MediaCategory,pr.description AS CodeIfAny,
COALESCE(ml.openingstock, 0) AS OpeningBalance,COALESCE(ml.Stocked, 0) AS MediaStocked,
COALESCE(mol.TotalQty, 0) AS IssueToCT,
(COALESCE(ml.openingstock, 0) + COALESCE(ml.Stocked, 0) - COALESCE(mol.TotalQty, 0)) AS Balance,ml.created,pr.ad_client_id,pr.ad_org_id,mol.description AS Discard
FROM adempiere.m_product pr
LEFT JOIN MediaLines ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN MediaOutLines mol ON pr.m_product_id = mol.m_product_id
WHERE pr.m_product_category_id = 1000005;
====================================================
WITH RECURSIVE cte AS (
-- Anchor query
SELECT parentuuid, tc_in_id, tc_out_id,c_uuid
FROM adempiere.tc_culturelabel
WHERE c_uuid = '32f0ba8d-1c87-49e0-b2d8-970634eb5732'

UNION ALL

-- Recursive query
SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id,t2.c_uuid
FROM cte t1
JOIN adempiere.tc_culturelabel t2
ON t1.parentuuid = t2.c_uuid
)
SELECT * FROM cte;
==============================================================================================================
CREATE OR REPLACE VIEW adempiere.TCV_mediareportNew AS
WITH MediaOutLines AS (
    SELECT 
        pro.m_product_id,
        COALESCE(SUM(mol.quantity), 0) AS TotalQty,
        mol.description
    FROM 
        adempiere.m_product pro
    LEFT JOIN 
        adempiere.tc_mediaoutline mol ON pro.m_product_id = mol.m_product_id
    GROUP BY 
        pro.m_product_id,
        mol.description
),
MediaLines AS (
    SELECT 
        pr.m_product_id,
        MIN(DATE(ml.created)) AS created,
        NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date = DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS openingstock,
        NULLIF(SUM(CASE WHEN DATE_TRUNC('month', ml.created)::date != DATE_TRUNC('month', CURRENT_DATE)::date THEN ml.quantity ELSE 0 END), 0) AS Stocked 
    FROM 
        adempiere.m_product pr
    LEFT JOIN 
        adempiere.tc_medialine ml ON pr.m_product_id = ml.m_product_id
    GROUP BY 
        pr.m_product_id
)
SELECT 
    pr.m_product_id,
    pr.name AS MediaCategory,
    pr.description AS CodeIfAny,
    COALESCE(ml.openingstock, 0) AS OpeningBalance,
    COALESCE(ml.Stocked, 0) AS MediaStocked,
    COALESCE(mol.TotalQty, 0) AS IssueToCT,
    (COALESCE(ml.openingstock, 0) + COALESCE(ml.Stocked, 0) - COALESCE(mol.TotalQty, 0)) AS Balance,
    ml.created,
    pr.ad_client_id,
    pr.ad_org_id,
    mol.description AS Discard,
    -- Calculate the Progressive Total of Media Stocked PrePacked for the one-year period
    SUM(CASE 
            WHEN DATE_TRUNC('year', ml.created) = DATE_TRUNC('year', CURRENT_DATE) THEN COALESCE(ml.Stocked, 0) 
            ELSE 0 
        END) 
    OVER (PARTITION BY pr.m_product_id ORDER BY ml.created ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ProgressiveTotalOneYear
FROM 
    adempiere.m_product pr
LEFT JOIN 
    MediaLines ml ON pr.m_product_id = ml.m_product_id
LEFT JOIN 
    MediaOutLines mol ON pr.m_product_id = mol.m_product_id
WHERE 
    pr.m_product_category_id = 1000005;

==================================================================================================================================================================
Added Any new Fiels and Foreign key in Table:-
ALTER TABLE adempiere.tc_order 
ADD cultureCode VARCHAR(255);

ALTER TABLE adempiere.tc_order
ADD COLUMN tc_variety_id NUMERIC(10,0);

ALTER TABLE adempiere.tc_order
ADD CONSTRAINT tc_order_tc_variety_id_fkey
FOREIGN KEY (tc_variety_id)
REFERENCES adempiere.tc_variety(tc_variety_id);

Alter table adempiere.tc_out
add column discardQty NUMERIC(10,0);

Alter table adempiere.tc_medialine
add column discardQty NUMERIC(10,0);

==================================================================================================================================================================
Jasper Report in GrowthRoom:-
SELECT v.name,ord.tc_variety_id,ord.culturecode,v.codeno,COALESCE(o.description, '') AS Contamination,i_pr.name AS stageAndCycle,
    COALESCE(NULLIF(SUM(CASE WHEN DATE_TRUNC('month', i.created) != DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0),0) AS OpeningStock,
    COALESCE(NULLIF(SUM(CASE WHEN DATE_TRUNC('month', i.created) = DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0),0) AS Stocked,
    COALESCE(NULLIF(SUM(CASE WHEN o_pr.name LIKE 'N%' OR o_pr.name LIKE 'BI%' THEN o.quantity ELSE 0 END), 0),0) AS ToCT,
    COALESCE(NULLIF(SUM(CASE WHEN o_pr.name LIKE 'M%' OR o_pr.name LIKE 'BM%' THEN o.quantity ELSE 0 END), 0),0) AS M,
    COALESCE(NULLIF(SUM(CASE WHEN o_pr.name LIKE 'E%' OR o_pr.name LIKE 'BE%' THEN o.quantity ELSE 0 END), 0),0) AS E,
    COALESCE(NULLIF(SUM(CASE WHEN o_pr.name LIKE 'R%' OR o_pr.name LIKE 'BR%' THEN o.quantity ELSE 0 END), 0),0) AS R,
    COALESCE(NULLIF(SUM(CASE WHEN o_pr.name LIKE 'H%' OR o_pr.name LIKE 'BH%' THEN o.quantity ELSE 0 END), 0),0) AS Hardning,
    i.ad_client_id,i.ad_org_id,MAX(Date(i.created)) AS orderDate
FROM adempiere.tc_in i
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_out o ON o.tc_in_id = i.tc_in_id
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = ord.tc_variety_id
where ord.ad_client_id = 1000000  AND o.created > '9/04/2024' AND o.created < '11/04/2024'
GROUP BY i_pr.name,i.ad_client_id,i.ad_org_id,v.name,ord.tc_variety_id,ord.culturecode,v.codeno,o.description Order By v.codeno;

==================================================================================================================================================================
Jasper Report in Culture Production:-
SELECT v.name,ord.tc_variety_id,ord.culturecode,CONCAT(i_pr.name, '-', o_pr.name) AS StageAndCycle,v.codeno,
    CASE 
        WHEN LAG(i.tc_in_id) OVER (ORDER BY i.tc_in_id) = i.tc_in_id THEN NULL
        ELSE i.quantity 
    END AS quantity,
    COALESCE(NULLIF(CASE WHEN o_pr.name LIKE 'M%' OR o_pr.name LIKE 'N%' OR o_pr.name LIKE 'BM%' THEN o.quantity ELSE 0 END, 0), 0) AS M,
    COALESCE(NULLIF(CASE WHEN o_pr.name LIKE 'E%' OR o_pr.name LIKE 'BE%' THEN o.quantity ELSE 0 END, 0), 0) AS E,
    COALESCE(NULLIF(CASE WHEN o_pr.name LIKE 'R%' OR o_pr.name LIKE 'BR%' THEN o.quantity ELSE 0 END, 0), 0) AS R,
    o.ad_client_id,o.ad_org_id,o.created
FROM adempiere.tc_out o
JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id
JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
JOIN adempiere.tc_order ord ON ord.tc_order_id = o.tc_order_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = ord.tc_variety_id
WHERE ord.ad_client_id = 1000000 AND o.created > '9/04/2024' AND o.created < '11/04/2024' 
ORDER BY v.codeno;

==================================================================================================================================================================
Culture Label View:-
SELECT cl.tc_CultureLabel_id,cl.tc_CultureLabel_uu,cl.created,cl.parentcultureline,cl.cycleno,cl.tcpf,cl.personal_code,
ps.codeno AS cropType,v.codeno AS Variety,ns.codeno AS natureSample,cs.codeno AS cultureStage,vt.name AS virusResult,mt.name AS mediaType,mat.machinecode AS machineName,
cl.ad_client_id,cl.ad_org_id FROM adempiere.tc_CultureLabel cl
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_virustesting vt ON vt.tc_virustesting_id = cl.tc_virustesting_id
JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = cl.tc_mediatype_id
JOIN adempiere.tc_machinetype mat ON mat.tc_machinetype_id = cl.tc_machinetype_id

==================================================================================================================================================================
Change Column Name:-
ALTER TABLE table_name RENAME COLUMN old_column_name TO new_column_name

ALTER TABLE adempiere.tc_machinetype RENAME COLUMN machinecode TO codeNo

==================================================================================================================================================================
Explant LAbel Get:-
SELECT el.tc_explantLabel_id,el.tc_explantLabel_uu,el.parentcultureline,el.tcpf,el.personalCode,
ps.codeno AS cropType,v.codeno AS Variety,ns.codeno AS natureSample,
el.sourcingDate AS explantDate,el.operationDate AS explantOperationDate
FROM adempiere.tc_explantLabel el
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = el.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = el.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = el.tc_naturesample_id
WHERE el.ad_client_id = 1000000 AND el.tc_explantLabel_uu = 'e50919e4-90a9-4e9f-a2e8-371adedc9bef';
==================================================================================================================================================================
Get Culture Label:-
SELECT cl.tc_CultureLabel_id,cl.tc_CultureLabel_uu,cl.created,cl.parentcultureline,cl.cycleno,cl.tcpf,cl.personal_code,
ps.codeno AS cropType,v.codeno AS Variety,ns.codeno AS natureSample,cs.codeno AS cultureStage,vt.name AS virusResult,mt.name AS mediaType,mat.machinecode AS machineName,
cl.ad_client_id,cl.ad_org_id FROM adempiere.tc_CultureLabel cl
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_virustesting vt ON vt.tc_virustesting_id = cl.tc_virustesting_id
JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = cl.tc_mediatype_id
JOIN adempiere.tc_machinetype mat ON mat.tc_machinetype_id = cl.tc_machinetype_id;
==================================================================================================================================================================
Culture Operation Date:-
SELECT cl.tc_CultureLabel_id,cl.tc_CultureLabel_uu,cl.parentcultureline,cl.cycleno,cl.tcpf,cl.personal_code,
ps.codeno AS cropType,v.codeno AS Variety,ns.codeno AS natureSample,cs.codeno AS cultureStage,vt.name AS virusResult,mt.name AS mediaType,mat.machinecode AS machineName,
cl.culturedate AS cultureDate,cl.cultureoperationdate AS cultureOperationDate
FROM adempiere.tc_cultureLabel cl
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_virustesting vt ON vt.tc_virustesting_id = cl.tc_virustesting_id
JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = cl.tc_mediatype_id
JOIN adempiere.tc_machinetype mat ON mat.tc_machinetype_id = cl.tc_machinetype_id
WHERE cl.ad_client_id = 1000000 AND cl.tc_cultureLabel_uu = '22a40c03-6faf-49c0-945f-ca7edab1bd2d';
==================================================================================================================================================================
Media Label Data:-
CREATE TABLE adempiere.tc_mediaLabelQr (
    tc_mediaLabelQr_id SERIAL PRIMARY KEY,
    tc_mediaLabelQr_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_ID NUMERIC(10, 0) NOT NULL,
    ad_org_ID NUMERIC(10, 0) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    createdby numeric(10,0) NOT NULL,
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby numeric(10,0) NOT NULL,
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    tcpf VARCHAR(25),
    operationDate DATE,
    personalCode VARCHAR(25),
    tc_machinetype_id NUMERIC(10,0),
    tc_mediatype_id NUMERIC(10,0),
    tc_medialine_id NUMERIC(10,0),
    FOREIGN KEY (tc_medialine_id) REFERENCES adempiere.tc_medialine(tc_medialine_id),
    FOREIGN KEY (tc_machinetype_id) REFERENCES adempiere.tc_machinetype(tc_machinetype_id),
    FOREIGN KEY (tc_mediatype_id) REFERENCES adempiere.tc_mediatype(tc_mediatype_id)
    );
==================================================================================================================================================================
Trace :-
SELECT ins.tc_in_id,ins.inUUid,ins.description,ins.m_product_id As inProductId,outs.tc_out_id, outs.c_uuid AS outUUid,
outs.m_product_id As outProductId,outs.cycle
FROM adempiere.tc_out AS outs
JOIN (
    SELECT tc_in_id, c_uuid AS inUUid, description,m_product_id
    FROM adempiere.tc_in
    WHERE ad_client_id = 1000000
) AS ins ON ins.tc_in_id = outs.tc_in_id
where ins.description = 'eceb9173-35c5-48ff-ac89-937e3ea4f543';
==================================================================================================================================================================
Primary Hardening Get Data:-
SELECT ph.tc_primaryhardeningLabel_id,ph.c_uuId AS UUId,ph.yearCode AS yearCode,ph.parentCultureLine AS PCultureLine,
ph.sourcingDate AS date,ph.cultureProcessedNumber AS cultureProcessNumber,ph.plotNumberTray AS plotNumberTray,ph.tcpf AS TCPF,
ph.operationDate AS operationDate,ph.personalCode AS personalCode,ps.codeno AS cropType,v.codeno AS variety,cs.codeno AS cultureStage,
o.c_uuid AS OutUUId FROM adempiere.tc_primaryhardeningLabel ph
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = ph.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = ph.tc_species_ids
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = ph.tc_culturestage_id
JOIN adempiere.tc_out o ON o.tc_out_id = ph.tc_out_id
WHERE ph.ad_client_id = 1000000 AND o.c_uuid = '1401c02b-4701-4511-b643-d6359ba475e5';
==================================================================================================================================================================
 Plant details Rejected list show:-

SELECT pd.isrejected,pd.tc_plantdetails_id AS ID,ps.codeno AS PlantSpecieCodeNo,v.codeno AS VarietyCodeNo,pd.codeno AS PlantCodeNo,
pd.date AS Date,pd.c_uuid AS UUid,pd.bunceweight AS BunchWeight,pd.weight AS Weight,pd.bunchesno AS BunchesNo,pd.tagno AS TagNo,
pd.diseasename AS DiseaseName,pd.medicinedetails AS MedicineDetails,pd.height AS Height,pd.stature AS Stature,pd.leavesno AS LeavesNo,pd.parentcultureline,
CASE
     WHEN pd.isrejected = 'N' THEN 'true'
     ELSE 'false'
   END AS Status
FROM adempiere.tc_plantdetails pd
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = pd.tc_species_ids
WHERE pd.ad_client_id = 1000000;
==================================================================================================================================================================
Dashboard Visit:-
SELECT 'Completed' AS Status,
COUNT(CASE WHEN s.name = 'Completed' THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000 AND v.tc_visittype_id = 1000002 
UNION ALL
SELECT 'Cancelled' AS Status,
COUNT(CASE WHEN s.name = 'Cancelled' THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000 AND v.tc_visittype_id = 1000002 
UNION ALL
SELECT 'Upcoming' AS Status,
COUNT(CASE WHEN s.name = 'On Process' THEN 1 END) AS Count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id
WHERE v.ad_client_id = 1000000 AND v.tc_visittype_id = 1000002;


==================================================================================================================================================================
SELECT t.name AS Room,lt.name As RoomType,t.m_locatortype_id,
       ts.name AS status,
       temperature,
       humidity,
       t.ad_client_id,
       t.ad_org_id
FROM adempiere.tc_temperatureStatus t
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = t.m_locatortype_id
JOIN adempiere.tc_tempstatus ts ON ts.tc_tempstatus_id = t.tc_tempstatus_id
WHERE t.ad_client_id =  1000000  order by t.m_locatortype_id ;
==================================================================================================================================================================
SELECT ts.temperature As temp,ts.humidity AS humidity,lo.value As locatorValue,cl.c_uuid AS cultureUUId,cl.personal_code AS personalCode,
pr.versionno AS inCycle,p.description AS outProductName,pr.description AS inProductName,cs.name AS stageName,cl.cycleno AS cycle,
cl.cultureoperationdate AS cultureoperationdate,i.created AS indate,o.created AS outdate,pr.value AS inProduct,p.value AS outProduct,
ps.name AS cropType,v.name AS varietyName,i.tc_in_id,o.tc_out_id,cl.tc_culturelabel_id,i.m_product_id,o.m_product_id 
FROM adempiere.tc_out o
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id
JOIN adempiere.tc_culturelabel cl ON cl.tc_out_id = o.tc_out_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.m_product p ON p.m_product_id = o.m_product_id
JOIN adempiere.m_product pr ON pr.m_product_id = i.m_product_id
JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
JOIN (SELECT ts.m_locatortype_id,MAX(ts.created) AS max_created
FROM adempiere.tc_temperaturestatus ts GROUP BY ts.m_locatortype_id
) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
WHERE o.ad_client_id = 1000000 AND o.c_uuid = '6a35f1f3-1344-4e66-8f3a-5a7fa911ad4e' ORDER BY ts.created DESC;
==================================================================================================================================================================
WITH RECURSIVE cte AS (
-- Anchor query
SELECT l.parentuuid, l.tc_in_id, l.tc_out_id,l.c_uuid,lo.value As location,l.created,l.cycleno,ps.name As cropType,cs.name As stage,v.name As variety,
    l.personal_code,ts.temperature As temp,ts.humidity AS humidity
FROM adempiere.tc_culturelabel l
    JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
    JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
JOIN (SELECT ts.m_locatortype_id,MAX(ts.created) AS max_created
FROM adempiere.tc_temperaturestatus ts GROUP BY ts.m_locatortype_id
) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
WHERE l.c_uuid = '32f0ba8d-1c87-49e0-b2d8-970634eb5732'

UNION ALL

-- Recursive query
SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id,t2.c_uuid,lo.value As location,t2.created,t2.cycleno,ps.name As cropType,cs.name As stage,v.name As variety,
    t2.personal_code,ts.temperature As temp,ts.humidity AS humidity
    
FROM cte t1
JOIN adempiere.tc_culturelabel t2
ON t1.parentuuid = t2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
    JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
JOIN (SELECT ts.m_locatortype_id,MAX(ts.created) AS max_created
FROM adempiere.tc_temperaturestatus ts GROUP BY ts.m_locatortype_id
) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)
SELECT * FROM cte;
==================================================================================================================================================================
 If you remove any field 1 record to other record then use this code 
 This code is show 1 record all data and remain record not show in JasperReport.
 <printWhenExpression><![CDATA[$V{REPORT_COUNT} == 1]]></printWhenExpression>
==================================================================================================================================================================

WITH RECURSIVE cte AS (
  -- Anchor query
  SELECT l.parentuuid, l.tc_in_id, l.tc_out_id, l.c_uuid, lo.value AS location, l.created, l.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         l.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
  FROM adempiere.tc_culturelabel l
  JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
  WHERE l.c_uuid =  'd442bb6f-0e35-4dd7-92d6-991e213ce9d4' AND l.ad_client_id =  1000000

  UNION ALL

  -- Recursive query
  SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id, t2.c_uuid, lo.value AS location, t2.created, t2.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         t2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 2 AS level
  FROM cte t1
  JOIN adempiere.tc_culturelabel t2 ON t1.parentuuid = t2.c_uuid
  JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)
SELECT cte.*
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, null as location, tcc.created, cte.cycleno, cte.cropType, pr.name, cte.variety, tcc.personalcode, null as temp, null as humidity, 3 AS level
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
join adempiere.tc_out eo on eo.tc_out_id = tcc.tc_out_id
Join adempiere.m_product pr on pr.m_product_id = eo.m_product_id
WHERE tcc.c_uuid IS NOT NULL order by created desc;



==================================================================================================================================================================
WITH RECURSIVE cte AS (
  -- Anchor query
  SELECT l.parentuuid, l.tc_in_id, l.tc_out_id, l.c_uuid, lo.value AS location, l.created, l.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         l.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
  FROM adempiere.tc_culturelabel l
  JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
  WHERE l.c_uuid =  '32f0ba8d-1c87-49e0-b2d8-970634eb5732' AND l.ad_client_id =  1000000

  UNION ALL

  -- Recursive query
  SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id, t2.c_uuid, lo.value AS location, t2.created, t2.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         t2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 2 AS level
  FROM cte t1
  JOIN adempiere.tc_culturelabel t2 ON t1.parentuuid = t2.c_uuid
  JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)

SELECT cte.*
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, NULL AS location, tcc.created, cte.cycleno, cte.cropType, pr.name, cte.variety, tcc.personalcode, NULL AS temp, NULL AS humidity, 3 AS level
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT null AS parentuuid, NULL AS tc_in_id, NULL AS tc_out_id, tpt.c_uuid, NULL AS location, tpt.created, NULL AS cycleno, NULL AS cropType,'Plant Tag', NULL AS variety, NULL AS personal_code, NULL AS temp, NULL AS humidity, 4 AS level
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL
ORDER BY created DESC;


==================================================================================================================================================================
Jasoer working Query:
WITH RECURSIVE cte AS (
  -- Anchor query
  SELECT l.parentuuid, l.tc_in_id, l.tc_out_id, l.c_uuid, lo.value AS location, l.created, l.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         l.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
  FROM adempiere.tc_culturelabel l
  JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
  WHERE l.c_uuid =   $P{CultureLabelUUId} AND l.ad_client_id =  $P{AD_CLIENT_ID} 

  UNION ALL

  -- Recursive query
  SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id, t2.c_uuid, lo.value AS location, t2.created, t2.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         t2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 2 AS level
  FROM cte t1
  JOIN adempiere.tc_culturelabel t2 ON t1.parentuuid = t2.c_uuid
  JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)
SELECT * FROM cte;


==================================================================================================================================================================
Working Query:-

WITH RECURSIVE cte AS (
SELECT l.parentuuid,l.tc_in_id,l.tc_out_id,l.c_uuid,lo.value AS location,l.created,l.cycleno,ps.name AS cropType,cs.name AS stage,v.name AS variety,l.personal_code,
ts.temperature AS temp,ts.humidity AS humidity,1 AS level FROM adempiere.tc_culturelabel l JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE l.c_uuid = 'd442bb6f-0e35-4dd7-92d6-991e213ce9d4' AND l.ad_client_id = 1000000
AND DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus) 
UNION ALL
SELECT t2.parentuuid,t2.tc_in_id,t2.tc_out_id,t2.c_uuid,lo.value AS location,
t2.created,t2.cycleno,ps.name AS cropType,cs.name AS stage,v.name AS variety,t2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level FROM cte 
JOIN adempiere.tc_culturelabel t2 ON cte.parentuuid = t2.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus))
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code,
MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,MIN(cte.humidity) AS min_humidity,MAX(cte.humidity) AS max_humidity,cte.level FROM cte 
GROUP BY cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,
cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,lo.value AS location,tcc.created,cte.cycleno,cte.cropType,pr.name,
cte.variety,tcc.personalcode,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator lo ON lo.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT null AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage,cte.variety,
NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created DESC;


Details Query for best understanding:-
WITH RECURSIVE cte AS (
    SELECT 
        l.parentuuid,
        l.tc_in_id,
        l.tc_out_id,
        l.c_uuid,
        lo.value AS location,
        l.created,
        l.cycleno,
        ps.name AS cropType,
        cs.name AS stage,
        v.name AS variety,
        l.personal_code,
        ts.temperature AS temp,
        ts.humidity AS humidity,
        1 AS level
    FROM 
        adempiere.tc_culturelabel l
    JOIN 
        adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
    JOIN 
        adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
    JOIN 
        adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
    JOIN 
        adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
    JOIN 
        adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
    JOIN 
        adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
    JOIN 
        adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
    WHERE 
        l.c_uuid = 'd442bb6f-0e35-4dd7-92d6-991e213ce9d4' 
        AND 
        l.ad_client_id = 1000000
        AND 
        DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus)  
    
    UNION ALL
    
    SELECT 
        t2.parentuuid,
        t2.tc_in_id,
        t2.tc_out_id,
        t2.c_uuid,
        lo.value AS location,
        t2.created,
        t2.cycleno,
        ps.name AS cropType,
        cs.name AS stage,
        v.name AS variety,
        t2.personal_code,
        ts.temperature AS temp,
        ts.humidity AS humidity,
        cte.level + 1 AS level  -- Incrementing the level
    FROM 
        cte 
    JOIN 
        adempiere.tc_culturelabel t2 ON cte.parentuuid = t2.c_uuid
    JOIN 
        adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
    JOIN 
        adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
    JOIN 
        adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
    JOIN 
        adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
    JOIN 
        adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
    JOIN 
        adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
    JOIN 
        adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
    WHERE 
        DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus)
)
SELECT 
    cte.parentuuid,
    cte.tc_in_id,
    cte.tc_out_id,
    cte.c_uuid,
    cte.location,
    cte.created,
    cte.cycleno,
    cte.cropType,
    cte.stage,
    cte.variety,
    cte.personal_code,
    MIN(cte.temp) AS min_temperature,
    MAX(cte.temp) AS max_temperature,
    MIN(cte.humidity) AS min_humidity,
    MAX(cte.humidity) AS max_humidity,
    cte.level
FROM 
    cte 
GROUP BY 
    cte.parentuuid,
    cte.tc_in_id,
    cte.tc_out_id,
    cte.c_uuid,
    cte.location,
    cte.created,
    cte.cycleno,
    cte.cropType,
    cte.stage,
    cte.variety,
    cte.personal_code,
    cte.level

UNION ALL

SELECT 
    DISTINCT tcc.parentuuid,
    tcc.tc_in_id,
    tcc.tc_out_id,
    tcc.c_uuid,
    lo.value AS location,
    tcc.created,
    cte.cycleno,
    cte.cropType,
    pr.name,
    cte.variety,
    tcc.personalcode,
    NULL AS min_temperature,
    NULL AS max_temperature,
    NULL AS min_humidity,
    NULL AS max_humidity,
    cte.level
FROM 
    cte
LEFT JOIN 
    adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
JOIN 
    adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN 
    adempiere.m_locator lo ON lo.m_locator_id = eo.m_locator_id
JOIN 
    adempiere.m_product pr ON pr.m_product_id = eo.m_product_id

UNION ALL

SELECT 
    DISTINCT null AS parentuuid,
    0 AS tc_in_id,
    0 AS tc_out_id,
    tpt.c_uuid,
    NULL AS location,
    tpt.created,
    0 AS cycleno,
    cte.cropType,
    'Plant Tag' AS stage,
    cte.variety,
    NULL AS personal_code,
    NULL AS min_temperature,
    NULL AS max_temperature,
    NULL AS min_humidity,
    NULL AS max_humidity,
    cte.level
FROM 
    cte
LEFT JOIN 
    adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
LEFT JOIN 
    adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE 
    tpt.c_uuid IS NOT NULL

==================================================================================================================================================================
Count of Visit completed,cancelled and In Progress:-

select s.name from adempiere.tc_visit v
join adempiere.tc_status s ON s.tc_status_id = v.tc_status_id

----------------------------------------------------------------------

SELECT TO_CHAR(v.created, 'YYYY-MM') AS month,
    SUM(CASE WHEN s.name = 'Completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN s.name = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN s.name = 'In Progress' THEN 1 ELSE 0 END) AS in_process_count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
GROUP BY TO_CHAR(v.created, 'YYYY-MM')
ORDER BY month;
 ----------------------------------------------------------------------   
SELECT TO_CHAR(v.created, 'YYYY-MM-DD') AS day,
    SUM(CASE WHEN s.name = 'Completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN s.name = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN s.name = 'In Progress' THEN 1 ELSE 0 END) AS in_process_count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
GROUP BY TO_CHAR(v.created, 'YYYY-MM-DD')
ORDER BY day;
----------------------------------------------------------------------
SELECT TO_CHAR(v.created, 'IYYY-IW') AS week,
    SUM(CASE WHEN s.name = 'Completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN s.name = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN s.name = 'In Progress' THEN 1 ELSE 0 END) AS in_process_count
FROM adempiere.tc_visit v
JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
GROUP BY TO_CHAR(v.created, 'IYYY-IW')
ORDER BY week;

==================================================================================================================================================================
Count of Culture Label:-
select * from adempiere.tc_culturelabel l
where l.isdiscarded = 'N'

SELECT TO_CHAR(l.created, 'YYYY-MM') AS month,COUNT(*) AS label_count
FROM adempiere.tc_culturelabel l WHERE l.isdiscarded = 'N'
GROUP BY TO_CHAR(l.created, 'YYYY-MM') ORDER BY month;
    
SELECT TO_CHAR(l.created, 'YYYY-MM-DD') AS day,COUNT(*) AS label_count
FROM adempiere.tc_culturelabel l WHERE l.isdiscarded = 'N'
GROUP BY TO_CHAR(l.created, 'YYYY-MM-DD') ORDER BY day;
    
SELECT TO_CHAR(l.created, 'IYYY-IW') AS week,COUNT(*) AS record_count
FROM adempiere.tc_culturelabel l WHERE l.isdiscarded = 'N'
GROUP BY TO_CHAR(l.created, 'IYYY-IW') ORDER BY week;
    
SELECT TO_CHAR(DATE_TRUNC('week', l.created) + INTERVAL '1 day', 'YYYY-MM-DD') AS week_start,COUNT(*) AS record_count
FROM adempiere.tc_culturelabel l WHERE l.isdiscarded = 'N'
GROUP BY TO_CHAR(DATE_TRUNC('week', l.created) + INTERVAL '1 day', 'YYYY-MM-DD') ORDER BY week_start;

==================================================================================================================================================================
SELECT 
    pt.cr_parenttest_id,
    pt.cr_parenttest_uu,
    pt.name,
    array_agg( ct.cr_childtest_id
    ) AS child_records
FROM 
    adempiere.cr_parenttest pt
JOIN 
    adempiere.cr_jointest jt ON jt.cr_parenttest_id = pt.cr_parenttest_id
JOIN 
    adempiere.cr_childtest ct ON jt.cr_childtest_id = ct.cr_childtest_id
GROUP BY 
    pt.cr_parenttest_id,
    pt.cr_parenttest_uu,
    pt.name;
==================================================================================================================================================================
CREATE TABLE adempiere.tc_intermediatejoinplant (
    tc_intermediatejoinplant_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    tc_intermediatejoinplant_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby NUMERIC(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    c_uuId VARCHAR(36) DEFAULT NULL::bpchar,
    tc_plantdetails_id NUMERIC(10,0),
    tc_intermediatevisit_id NUMERIC(10,0),
    FOREIGN KEY (tc_plantdetails_id) REFERENCES adempiere.tc_plantdetails(tc_plantdetails_id),
    FOREIGN KEY (tc_intermediatevisit_id) REFERENCES adempiere.tc_intermediatevisit(tc_intermediatevisit_id)
    );
    
    select ijp.tc_intermediatejoinplant_id,ijp.tc_plantdetails_id,ijp.tc_intermediatevisit_id from adempiere.tc_intermediatejoinplant ijp
    join adempiere.tc_plantdetails pd ON pd.tc_plantdetails_id = ijp.tc_plantdetails_id
    join adempiere.tc_intermediatevisit iv On iv.tc_intermediatevisit_id = ijp.tc_intermediatevisit_id
    where ijp.isactive = 'Y'
    
    select ijp.tc_intermediatejoinplant_id,ijp.tc_plantdetails_id from adempiere.tc_intermediatejoinplant ijp
    join adempiere.tc_plantdetails pd ON pd.tc_plantdetails_id = ijp.tc_plantdetails_id
    where pd.c_uuid = '38eb0063-e159-4b7b-8a40-609187bee886'
==================================================================================================================================================================
select iv.tc_intermediatevisit_id,iv.c_uuid,iv.reviewdetails,iv.reasondetails,iv.tc_visit_id,iv.tc_farmer_id,iv.tc_decision_id,pd.tc_plantdetails_id,pd.isrejected from adempiere.tc_intermediatevisit iv
join adempiere.tc_intermediatejoinplant ij On ij.tc_intermediatevisit_id = iv.tc_intermediatevisit_id
join adempiere.tc_plantdetails pd On pd.tc_plantdetails_id = ij.tc_plantdetails_id
where pd.isrejected = 'N' and iv.c_uuid = 'e174c7d4-9ea1-4399-a629-31afd02e1d6a';

select iv.tc_intermediatevisit_id,pd.tc_plantdetails_id from adempiere.tc_intermediatevisit iv
join adempiere.tc_intermediatejoinplant ij On ij.tc_intermediatevisit_id = iv.tc_intermediatevisit_id
join adempiere.tc_plantdetails pd On pd.tc_plantdetails_id = ij.tc_plantdetails_id
where pd.isrejected = 'N' and iv.c_uuid = 'e174c7d4-9ea1-4399-a629-31afd02e1d6a';
==================================================================================================================================================================
CREATE OR REPLACE FUNCTION get_status(filter TEXT)
RETURNS TABLE(
    period TEXT,
    completed_count INTEGER,
    cancelled_count INTEGER,
    in_progress_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(
            CASE
                WHEN filter = 'day' THEN date_trunc('day', v.created)
                WHEN filter = 'week' THEN date_trunc('week', v.created)
                WHEN filter = 'month' THEN date_trunc('month', v.created)
                WHEN filter = 'year' THEN date_trunc('year', v.created)
                WHEN filter = 'quarter' THEN date_trunc('quarter', v.created)
                ELSE date_trunc('day', v.created) -- default to day if no valid filter is provided
            END,
            'DD/MM/YYYY'
        ) AS period,
        CAST(SUM(CASE WHEN s.name = 'Completed' THEN 1 ELSE 0 END) AS INTEGER) AS completed_count,
        CAST(SUM(CASE WHEN s.name = 'Cancelled' THEN 1 ELSE 0 END) AS INTEGER) AS cancelled_count,
        CAST(SUM(CASE WHEN s.name = 'In Progress' THEN 1 ELSE 0 END) AS INTEGER) AS in_progress_count
    FROM
        adempiere.tc_visit v
    JOIN
        adempiere.tc_status s ON s.tc_status_id = v.tc_status_id
    GROUP BY
        period
    ORDER BY
        period;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_status('day');
SELECT * FROM get_status('week');
SELECT * FROM get_status('month');
SELECT * FROM get_status('year');
SELECT * FROM get_status('quarter');

==================================================================================================================================================================
Avarage Time Plant tag to suckerno:-
WITH InitialCollection AS (
    SELECT pt.tc_planttag_id, pt.c_uuid, pt.created AS initial_collection_date
    FROM adempiere.tc_planttag pt
),
PlantDetailsDates AS (
    SELECT cs.tc_plantdetails_id, cs.plantTagUUId, cs.created AS plantDetails_date
    FROM adempiere.tc_plantdetails cs
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = cs.plantTagUUId
    WHERE cs.plantTagUUId = pt.c_uuid
),    
SuckerCollectionDates AS (
    SELECT sc.tc_plantdetails_id, sc.suckerNo, sc.created AS sucker_collection_date
    FROM adempiere.tc_collectionjoinplant sc
    JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
)
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (scd.sucker_collection_date - ic.initial_collection_date)) / 86400),2) AS avg_duration_days
FROM InitialCollection ic
JOIN PlantDetailsDates crd ON ic.c_uuid = crd.plantTagUUId    
JOIN SuckerCollectionDates scd ON crd.tc_plantdetails_id = scd.tc_plantdetails_id;

------------------------------------------------------------------
Show full datils not show only avarage days:-
WITH InitialCollection AS (
    SELECT pt.tc_planttag_id, pt.c_uuid, pt.created AS initial_collection_date
    FROM adempiere.tc_planttag pt
),
PlantDetailsDates AS (
    SELECT cs.tc_plantdetails_id, cs.plantTagUUId, cs.created AS plantDetails_date
    FROM adempiere.tc_plantdetails cs
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = cs.plantTagUUId
    WHERE cs.plantTagUUId = pt.c_uuid
),    
SuckerCollectionDates AS (
    SELECT sc.tc_plantdetails_id, sc.suckerNo, sc.created AS sucker_collection_date
    FROM adempiere.tc_collectionjoinplant sc
    JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
)
SELECT 
    ic.initial_collection_date,
    crd.plantDetails_date,
    scd.sucker_collection_date,
    ROUND(EXTRACT(EPOCH FROM (scd.sucker_collection_date - ic.initial_collection_date)) / 86400,2) AS duration_days
FROM InitialCollection ic
JOIN PlantDetailsDates crd ON ic.c_uuid = crd.plantTagUUId    
JOIN SuckerCollectionDates scd ON crd.tc_plantdetails_id = scd.tc_plantdetails_id;

==================================================================================================================================================================    
Time get plant tag to multiplication culture label:-
WITH InitialCollection AS (
    SELECT pt.tc_planttag_id, pt.c_uuid, pt.created AS initial_collection_date FROM adempiere.tc_planttag pt),
PlantDetailsDates AS (
    SELECT cs.tc_plantdetails_id, cs.plantTagUUId, cs.created AS plantDetails_date FROM adempiere.tc_plantdetails cs
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = cs.plantTagUUId WHERE cs.plantTagUUId = pt.c_uuid
),    
SuckerCollectionDates AS (
    SELECT sc.tc_plantdetails_id, sc.suckerNo, sc.created AS sucker_collection_date FROM adempiere.tc_collectionjoinplant sc
    JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
),
explantDates As (
    SELECT el.c_uuid AS explantuuid,el.parentuuid As parentuuid,el.created AS explant_date FROM adempiere.tc_explantlabel el
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = el.parentuuid
),
initialcultureDates As (
    SELECT cl.c_uuid AS initialcultureuuid,cl.parentuuid As inicultureparentuuid,cl.created AS iniculture_date FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_explantlabel el ON el.c_uuid = cl.parentuuid
),
initial2cultureDates As (
    SELECT cl2.c_uuid AS initial2cultureuuid,cl2.parentuuid As ini2cultureparentuuid,cl2.created AS ini2culture_date FROM adempiere.tc_culturelabel cl2
    JOIN adempiere.tc_culturelabel cl ON cl.c_uuid = cl2.parentuuid
),
mulcultureDates As (
    SELECT clm.c_uuid AS mulcultureuuid,clm.parentuuid As mulcultureparentuuid,clm.created AS mulculture_date FROM adempiere.tc_culturelabel clm
    JOIN adempiere.tc_culturelabel cl ON cl.c_uuid = clm.parentuuid
)   
SELECT ic.initial_collection_date,crd.plantDetails_date,scd.sucker_collection_date,eld.explant_date,cld.iniculture_date,cld2.ini2culture_date,clmd.mulculture_date,
ROUND(EXTRACT(EPOCH FROM (scd.sucker_collection_date - ic.initial_collection_date)) / 86400,2) AS duration_days
FROM InitialCollection ic
JOIN PlantDetailsDates crd ON ic.c_uuid = crd.plantTagUUId    
JOIN SuckerCollectionDates scd ON crd.tc_plantdetails_id = scd.tc_plantdetails_id
JOIN explantDates eld ON eld.parentuuid = crd.plantTagUUId
JOIN initialcultureDates cld ON cld.inicultureparentuuid = eld.explantuuid
JOIN initial2cultureDates cld2 ON cld2.ini2cultureparentuuid = cld.initialcultureuuid   
JOIN mulcultureDates clmd ON clmd.mulcultureparentuuid = cld2.initial2cultureuuid   ;

============================================================================================================================================
User Management Report:-
SELECT users, userId, personalCode, date, id, labelName
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalCode AS personalCode,cl.created AS date,cl.tc_culturelabel_id AS id,'Culture Label' AS labelName
FROM adempiere.tc_culturelabel cl JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby WHERE cl.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,el.createdby AS userId,u.personalcode AS personalCode,el.created AS date,el.tc_explantlabel_id AS id,'Explant Label' AS labelName
FROM adempiere.tc_explantlabel el JOIN adempiere.ad_user u ON u.ad_user_id = el.createdby WHERE el.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,ml.createdby AS userId,u.personalcode AS personalCode,ml.created AS date,ml.tc_medialabelQr_id AS id,'Media Label' AS labelName
FROM adempiere.tc_medialabelQr ml JOIN adempiere.ad_user u ON u.ad_user_id = ml.createdby WHERE ml.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,pr.createdby AS userId,u.personalcode AS personalCode,pr.created AS date,pr.tc_primaryhardeningLabel_id AS id,'Primary Hardening' AS labelName
FROM adempiere.tc_primaryhardeningLabel pr JOIN adempiere.ad_user u ON u.ad_user_id = pr.createdby WHERE pr.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,sr.createdby AS userId,u.personalcode AS personalCode,sr.created AS date,sr.tc_secondaryhardeningLabel_id AS id,'Secondary Hardening' AS labelName
FROM adempiere.tc_secondaryhardeningLabel sr JOIN adempiere.ad_user u ON u.ad_user_id = sr.createdby WHERE sr.AD_CLIENT_ID = 1000000    
UNION ALL
SELECT u.name AS users,fv.createdby AS userId,u.personalcode AS personalCode,fv.created AS date,fv.tc_firstvisit_id AS id,'First Visit' AS labelName
FROM adempiere.tc_firstvisit fv JOIN adempiere.ad_user u ON u.ad_user_id = fv.createdby WHERE fv.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,iv.createdby AS userId,u.personalcode AS personalCode,iv.created AS date,iv.tc_intermediatevisit_id AS id,'Intermediate Visit' AS labelName
FROM adempiere.tc_intermediatevisit iv JOIN adempiere.ad_user u ON u.ad_user_id = iv.createdby WHERE iv.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,cv.createdby AS userId,u.personalcode AS personalCode,cv.created AS date,cv.tc_collectiondetails_id AS id,'Collection Visit' AS labelName
FROM adempiere.tc_collectiondetails cv JOIN adempiere.ad_user u ON u.ad_user_id = cv.createdby WHERE cv.AD_CLIENT_ID = 1000000  
) AS combined ORDER BY users,date;

===============================================================================
SELECT users, userId, personalCode, date, id, labelName
FROM (
SELECT u.name AS users,cl.createdby AS userId,cl.personal_code AS personalCode,cl.created AS date,cl.tc_culturelabel_id AS id,'Culture Label' AS labelName
FROM adempiere.tc_culturelabel cl JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby WHERE cl.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,el.createdby AS userId,el.personalcode AS personalCode,el.created AS date,el.tc_explantlabel_id AS id,'Explant Label' AS labelName
FROM adempiere.tc_explantlabel el JOIN adempiere.ad_user u ON u.ad_user_id = el.createdby WHERE el.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,ml.createdby AS userId,ml.personalcode AS personalCode,ml.created AS date,ml.tc_medialabelQr_id AS id,'Media Label' AS labelName
FROM adempiere.tc_medialabelQr ml JOIN adempiere.ad_user u ON u.ad_user_id = ml.createdby WHERE ml.AD_CLIENT_ID = 1000000
) AS combined WHERE labelName = 'Media Label' ORDER BY users;

====================================================================================
Jasper Working Fine:-
SELECT users, userId, personalCode, date, id, labelName
FROM (
SELECT u.name AS users,cl.createdby AS userId,cl.personal_code AS personalCode,cl.created AS date,cl.tc_culturelabel_id AS id,'Culture Label' AS labelName
FROM adempiere.tc_culturelabel cl JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby WHERE cl.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,el.createdby AS userId,el.personalcode AS personalCode,el.created AS date,el.tc_explantlabel_id AS id,'Explant Label' AS labelName
FROM adempiere.tc_explantlabel el JOIN adempiere.ad_user u ON u.ad_user_id = el.createdby WHERE el.AD_CLIENT_ID = 1000000
UNION ALL
SELECT u.name AS users,ml.createdby AS userId,ml.personalcode AS personalCode,ml.created AS date,ml.tc_medialabelQr_id AS id,'Media Label' AS labelName
FROM adempiere.tc_medialabelQr ml JOIN adempiere.ad_user u ON u.ad_user_id = ml.createdby WHERE ml.AD_CLIENT_ID = 1000000
) AS combined WHERE ($P{Label} IS NULL OR combined.labelName = $P{Label}) ORDER BY users;

===========================================================================================
SELECT users, userId, personalCode, date,orderId, id, labelName,countValue
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,cl.created AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Culture Label' AS labelName,
COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id) AS countValue FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = 1000000 AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,cl.created AS date,
o.tc_mediaorder_id As orderID,cl.tc_medialabelQr_id AS id,'Media Label' AS labelName,
COUNT(*) OVER (PARTITION BY cl.created, o.tc_mediaorder_id) AS countValue FROM adempiere.tc_medialabelQr cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_medialine o ON o.tc_medialine_id = cl.tc_medialine_id
WHERE cl.AD_CLIENT_ID = 1000000 AND u.personalcode is not null
) AS combined WHERE labelName = 'Media Label' ORDER BY users,date;
==============================================================================================
-----------------------------------------------------------------------------------------------
Final Working Query in JAsper Report:-
SELECT users, userId, personalCode, date,orderId, id, labelName,countValue,counts
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Culture Role' AS labelName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID}  AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_mediaorder_id As orderID,cl.tc_medialabelQr_id AS id,'Media Role' AS labelName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_mediaorder_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_mediaorder_id,u.name) AS counts FROM adempiere.tc_medialabelQr cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_medialine o ON o.tc_medialine_id = cl.tc_medialine_id
WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID} AND u.personalcode is not null
) AS combined WHERE combined.date > $P{FromDate} AND combined.date < $P{ToDate} 
 AND ($P{Label} IS NULL OR combined.labelName = $P{Label})  ORDER BY users,date,orderId;

==================================================================================================================================================================
Field Officer:-
SELECT users,userId,date,id,PlantID,visitName,countvalue,counts
FROM (
SELECT u.name As Users,fv.createdby As userId,fv.created As date,fv.tc_firstvisit_id AS id,fj.tc_plantdetails_id AS PlantID,'First Visit' AS visitName,
CAST(COUNT(*) OVER (PARTITION BY DATE(fv.created), fv.tc_firstvisit_id,u.name) AS NUMERIC) AS countvalue,COUNT(*) OVER (PARTITION BY fv.created, fv.tc_firstvisit_id,u.name,fj.tc_firstjoinplant_id) AS counts FROM adempiere.tc_firstvisit fv
JOIN adempiere.ad_user u ON u.ad_user_id = fv.createdby
JOIN adempiere.tc_firstjoinplant fj ON fj.tc_firstvisit_id = fv.tc_firstvisit_id    
WHERE fv.ad_client_id = 1000000 AND fj.tc_plantdetails_id is not null 
UNION ALL
SELECT u.name As Users,iv.createdby As userId,iv.created As date,iv.tc_intermediatevisit_id,ij.tc_plantdetails_id AS PlantID,'Intermediate Visit' AS visitName,
CAST(COUNT(*) OVER (PARTITION BY DATE(iv.created), iv.tc_intermediatevisit_id,u.name) AS NUMERIC) AS countvalue,COUNT(*) OVER (PARTITION BY iv.created, iv.tc_intermediatevisit_id,u.name,ij.tc_intermediatejoinplant_id) AS counts FROM adempiere.tc_intermediatevisit iv
JOIN adempiere.ad_user u ON u.ad_user_id = iv.createdby
JOIN adempiere.tc_intermediatejoinplant ij ON ij.tc_intermediatevisit_id = iv.tc_intermediatevisit_id   
WHERE iv.ad_client_id = 1000000 AND ij.tc_plantdetails_id is not null 
UNION ALL
SELECT u.name As Users,cv.createdby As userId,cv.created As date,cv.tc_collectiondetails_id,cj.tc_plantdetails_id AS PlantID,'Collection Visit' AS visitName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cv.created), cv.tc_collectiondetails_id,u.name) AS NUMERIC) AS countvalue,COUNT(*) OVER (PARTITION BY cv.created, cv.tc_collectiondetails_id,u.name,cj.tc_collectionjoinplant_id) AS counts FROM adempiere.tc_collectiondetails cv
JOIN adempiere.ad_user u ON u.ad_user_id = cv.createdby
JOIN adempiere.tc_collectionjoinplant cj ON cj.tc_collectiondetails_id = cv.tc_collectiondetails_id 
WHERE cv.ad_client_id = 1000000 AND cj.tc_plantdetails_id is not null 
) AS combined WHERE visitName = 'Intermediate Visit' ORDER BY users,date,id;
==================================================================================================================================================================
GrowthRoom update:-
SELECT v.name,ord.tc_variety_id,ord.culturecode,v.codeno,COALESCE(SUM(o.discardqty), 0) AS Contamination,i_pr.name AS stageAndCycle,
    COALESCE(SUM(CASE WHEN DATE_TRUNC('month', i.created) != DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0) AS OpeningStock,
    COALESCE(SUM(CASE WHEN DATE_TRUNC('month', i.created) = DATE_TRUNC('month', NOW()) THEN i.quantity ELSE 0 END), 0) AS Stocked,
    COALESCE(SUM(CASE WHEN o_pr.name LIKE 'N%' OR o_pr.name LIKE 'BI%' THEN o.quantity ELSE 0 END), 0) AS ToCT,
    COALESCE(SUM(CASE WHEN o_pr.name LIKE 'M%' OR o_pr.name LIKE 'BM%' THEN o.quantity ELSE 0 END), 0) AS M,
    COALESCE(SUM(CASE WHEN o_pr.name LIKE 'E%' OR o_pr.name LIKE 'BE%' THEN o.quantity ELSE 0 END), 0) AS E,
    COALESCE(SUM(CASE WHEN o_pr.name LIKE 'R%' OR o_pr.name LIKE 'BR%' THEN o.quantity ELSE 0 END), 0) AS R,
    COALESCE(SUM(CASE WHEN o_pr.name LIKE 'H%' OR o_pr.name LIKE 'H0%' THEN o.quantity ELSE 0 END), 0) AS Hardning,
    i.ad_client_id,i.ad_org_id,MAX(DATE(i.created)) AS orderDate
FROM adempiere.tc_order ord JOIN adempiere.tc_variety v ON v.tc_variety_id = ord.tc_variety_id
JOIN adempiere.tc_out o ON o.tc_order_id = ord.tc_order_id JOIN adempiere.m_product o_pr ON o.m_product_id = o_pr.m_product_id
JOIN adempiere.tc_in i ON i.tc_in_id = o.tc_in_id JOIN adempiere.m_product i_pr ON i.m_product_id = i_pr.m_product_id
WHERE ord.ad_client_id = 1000000 AND o.created > '2024-03-01' AND o.created < '2024-07-08'
GROUP BY v.name,ord.tc_variety_id,ord.culturecode,v.codeno,i_pr.name,i.ad_client_id,i.ad_org_id ORDER BY v.codeno;

==================================================================================================================================================================
Sucker Count Api:-

GetFORoleReportSuckerCountResponseDocument getFORoleReportSuckerCountResponseDocument = GetFORoleReportSuckerCountResponseDocument.Factory.newInstance();
        GetFORoleReportSuckerCountResponse getFORoleReportSuckerCountResponse = getFORoleReportSuckerCountResponseDocument.addNewGetFORoleReportSuckerCountResponse();
        GetFORoleReportSuckerCountRequest loginRequest = req.getGetFORoleReportSuckerCountRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String user = login.getUser();
        int clientId = login.getClientID();
        String userInput = loginRequest.getUserInput();
        String serviceType = loginRequest.getServiceType();
        PreparedStatement pstm = null;
        ResultSet rs = null;
        Trx trx = null;
        try {
            getCompiereService().connect();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "getReport", serviceType);
            if (err != null && err.length() > 0) {
                getFORoleReportSuckerCountResponse.setError(err);
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("getReport")) {
                getFORoleReportSuckerCountResponse.setError("Service type " + serviceType + " not configured");
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
            String sql = null;
            
            if(userInput.equals("day")) {
                sql = "SELECT day_info.day_name AS day_name,COALESCE(SUM(cv.suckerno), 0) AS sucker_count\n"
                        + "FROM (SELECT to_char(current_date, 'Day') AS day_name) AS day_info\n"
                        + "LEFT JOIN adempiere.tc_collectionjoinplant cv ON cv.created::date = current_date AND cv.ad_client_id = "+clientId+"\n"
                        + "AND cv.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = '"+user+"') GROUP BY day_info.day_name;";
            }else if(userInput.equals("week")) {
                sql = "WITH days AS (SELECT generate_series(0, 6) AS day_of_week),\n"
                        + "sucker_counts AS (\n"
                        + "SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,\n"
                        + "EXTRACT(dow FROM v.created) AS day_of_week,SUM(v.suckerno) AS visit_count\n"
                        + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= current_date - interval '6 days' AND v.created::date <= current_date\n"
                        + "GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))\n"
                        + "SELECT current_date - interval '6 days' + d.day_of_week * interval '1 day' AS dates,\n"
                        + "COALESCE(vc.day_name, to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,\n"
                        + "COALESCE(vc.visit_count, 0) AS sucker_count FROM days d\n"
                        + "LEFT JOIN sucker_counts vc ON current_date - interval '6 days' + d.day_of_week * interval '1 day' = vc.visit_day ORDER BY dates;";
            }else if(userInput.equals("month")) {
                sql = "WITH weeks AS (SELECT generate_series(0, 4) AS week_number),\n"
                        + "sucker_counts AS (SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,\n"
                        + "SUM(v.suckerno) AS sucker_count FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= (current_date - interval '29 days') AND v.created::date <= current_date GROUP BY date_trunc('week', v.created)),\n"
                        + "date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)\n"
                        + "SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.sucker_count, 0) AS sucker_count\n"
                        + "FROM date_range LEFT JOIN sucker_counts vc ON date_trunc('week', day) = vc.week_start\n"
                        + "GROUP BY date_trunc('week', day), vc.sucker_count ORDER BY week_start;\n"
                        + "";
            }else if(userInput.equals("year")) {
                sql = "WITH months AS (SELECT generate_series(0, 11) AS month),\n"
                        + "sucker_counts AS (\n"
                        + "SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,SUM(v.suckerno) AS sucker_count\n"
                        + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= (current_date - interval '364 days') \n"
                        + "AND v.created::date <= current_date GROUP BY date_trunc('month', v.created), to_char(v.created, 'FMMonth'))\n"
                        + "SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval, 'FMMonth') AS month_name,COALESCE(vc.sucker_count, 0) AS sucker_count \n"
                        + "FROM months m LEFT JOIN sucker_counts vc \n"
                        + "ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year\n"
                        + "ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;";
            }else if(userInput.equals("all")) {
                sql = "SELECT sum(v.suckerno) AS sucker_count FROM adempiere.tc_collectionjoinplant v\n"
                        + "JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"';";
            }
            if (sql == null) {
                getFORoleReportSuckerCountResponse.setError("No SQL");
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
        
            pstm = DB.prepareStatement(sql, null);
            rs = pstm.executeQuery();
            while (rs.next()) {
                GetReportDataSuckerCount data = getFORoleReportSuckerCountResponse.addNewGetReportDataSuckerCount();
                if (userInput.equals("day")) {
                    String day_name = rs.getString("day_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(day_name);
                    data.setCount(count);
                } else if (userInput.equals("week")) {
                    String days_name = rs.getString("day_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(days_name);
                    data.setCount(count);
                } else if (userInput.equals("month")) {
                    String week_start = rs.getString("week_start");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(week_start);
                    data.setCount(count);
                } else if (userInput.equals("year")) {
                    String month_name = rs.getString("month_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(month_name);
                    data.setCount(count);
                } else if (userInput.equals("all")) {
                    int count = rs.getInt("sucker_count");
                    data.setCount(count);
                }
            }
        } catch (Exception e) {
            getFORoleReportSuckerCountResponse.setError(e.getMessage());
            getFORoleReportSuckerCountResponse.setIsError(true);
        } finally {
            trx.close();
            getCompiereService().disconnect();
            closeDbCon(pstm, rs);
        }
        return getFORoleReportSuckerCountResponseDocument;

        --------------------------
        All Modify Query:-
        WITH year_counts AS (
SELECT date_trunc('year', v.created) AS year_start,COUNT(*) AS visit_count
FROM adempiere.tc_culturelabel v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan'
GROUP BY date_trunc('year', v.created))
SELECT to_char(year_start, 'YYYY-01-01') AS year_date,visit_count
FROM year_counts ORDER BY year_start;

==================================================================================================================================================================
Currently Working Api for Sucker Count with Excel Download:-
@Override
    public GetFORoleReportSuckerCountResponseDocument getFORoleReportSuckerCount(
            GetFORoleReportSuckerCountRequestDocument req) {
        GetFORoleReportSuckerCountResponseDocument getFORoleReportSuckerCountResponseDocument = GetFORoleReportSuckerCountResponseDocument.Factory.newInstance();
        GetFORoleReportSuckerCountResponse getFORoleReportSuckerCountResponse = getFORoleReportSuckerCountResponseDocument.addNewGetFORoleReportSuckerCountResponse();
        GetFORoleReportSuckerCountRequest loginRequest = req.getGetFORoleReportSuckerCountRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String user = login.getUser();
        int clientId = login.getClientID();
        String userInput = loginRequest.getUserInput();
        String serviceType = loginRequest.getServiceType();
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        PreparedStatement pstm = null;
        ResultSet rs = null;
        Trx trx = null;
        try {
            getCompiereService().connect();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "getReport", serviceType);
            if (err != null && err.length() > 0) {
                getFORoleReportSuckerCountResponse.setError(err);
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("getReport")) {
                getFORoleReportSuckerCountResponse.setError("Service type " + serviceType + " not configured");
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
            // Create SXSSFWorkbook
            SXSSFWorkbook workbook = new SXSSFWorkbook(-1);

            // Create styles
            CellStyle myStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font myFont = workbook.createFont();
            myFont.setBold(true);
            myStyle.setFont(myFont);

            CellStyle wrapStyle = workbook.createCellStyle();
            wrapStyle.setWrapText(true);
            // Create sheet and rows
            SXSSFSheet sheet = workbook.createSheet("Field Officer Visit Count Report");
            SXSSFRow headerRow = sheet.createRow(0);
            
         // Create header cells
            SXSSFCell cellH0 = headerRow.createCell(0);
            cellH0.setCellValue("Label Name");
            cellH0.setCellStyle(myStyle);

            SXSSFCell cellH1 = headerRow.createCell(1);
            cellH1.setCellValue("Count");
            cellH1.setCellStyle(myStyle);
            String sql = null;
            
            if(userInput.equals("day")) {
                sql = "SELECT day_info.day_name AS day_name,COALESCE(SUM(cv.suckerno), 0) AS sucker_count\n"
                        + "FROM (SELECT to_char(current_date, 'Day') AS day_name) AS day_info\n"
                        + "LEFT JOIN adempiere.tc_collectionjoinplant cv ON cv.created::date = current_date AND cv.ad_client_id = "+clientId+"\n"
                        + "AND cv.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = '"+user+"') GROUP BY day_info.day_name;";
            }else if(userInput.equals("week")) {
                sql = "WITH days AS (SELECT generate_series(0, 6) AS day_of_week),\n"
                        + "sucker_counts AS (\n"
                        + "SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,\n"
                        + "EXTRACT(dow FROM v.created) AS day_of_week,SUM(v.suckerno) AS visit_count\n"
                        + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= current_date - interval '6 days' AND v.created::date <= current_date\n"
                        + "GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))\n"
                        + "SELECT current_date - interval '6 days' + d.day_of_week * interval '1 day' AS dates,\n"
                        + "COALESCE(vc.day_name, to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,\n"
                        + "COALESCE(vc.visit_count, 0) AS sucker_count FROM days d\n"
                        + "LEFT JOIN sucker_counts vc ON current_date - interval '6 days' + d.day_of_week * interval '1 day' = vc.visit_day ORDER BY dates;";
            }else if(userInput.equals("month")) {
                sql = "WITH weeks AS (SELECT generate_series(0, 4) AS week_number),\n"
                        + "sucker_counts AS (SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,\n"
                        + "SUM(v.suckerno) AS sucker_count FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= (current_date - interval '29 days') AND v.created::date <= current_date GROUP BY date_trunc('week', v.created)),\n"
                        + "date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)\n"
                        + "SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.sucker_count, 0) AS sucker_count\n"
                        + "FROM date_range LEFT JOIN sucker_counts vc ON date_trunc('week', day) = vc.week_start\n"
                        + "GROUP BY date_trunc('week', day), vc.sucker_count ORDER BY week_start;\n"
                        + "";
            }else if(userInput.equals("year")) {
                sql = "WITH months AS (SELECT generate_series(0, 11) AS month),\n"
                        + "sucker_counts AS (\n"
                        + "SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,SUM(v.suckerno) AS sucker_count\n"
                        + "FROM adempiere.tc_collectionjoinplant v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"' AND v.created::date >= (current_date - interval '364 days') \n"
                        + "AND v.created::date <= current_date GROUP BY date_trunc('month', v.created), to_char(v.created, 'FMMonth'))\n"
                        + "SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval, 'FMMonth') AS month_name,COALESCE(vc.sucker_count, 0) AS sucker_count \n"
                        + "FROM months m LEFT JOIN sucker_counts vc \n"
                        + "ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year\n"
                        + "ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;";
            }else if(userInput.equals("all")) {
                sql = "SELECT sum(v.suckerno) AS sucker_count FROM adempiere.tc_collectionjoinplant v\n"
                        + "JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby\n"
                        + "WHERE v.ad_client_id = "+clientId+" AND u.name = '"+user+"';";
            }
            if (sql == null) {
                getFORoleReportSuckerCountResponse.setError("No SQL");
                getFORoleReportSuckerCountResponse.setIsError(true);
                return getFORoleReportSuckerCountResponseDocument;
            }
            pstm = DB.prepareStatement(sql, null);
            rs = pstm.executeQuery();
            int i = 1;
            while (rs.next()) {
                GetReportDataSuckerCount data = getFORoleReportSuckerCountResponse.addNewGetReportDataSuckerCount();
                if (userInput.equals("day")) {
                    String day_name = rs.getString("day_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(day_name);
                    data.setCount(count);
                    
                    SXSSFRow tableDescriptionRow = sheet.createRow(i);
                    SXSSFCell cell1 = tableDescriptionRow.createCell(0);
                    cell1.setCellValue(day_name);
                    cell1.setCellStyle(wrapStyle);

                    SXSSFCell cell2 = tableDescriptionRow.createCell(1);
                    cell2.setCellValue(count);
                    cell2.setCellStyle(wrapStyle);
                } else if (userInput.equals("week")) {
                    String days_name = rs.getString("day_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(days_name);
                    data.setCount(count);
                    
                    SXSSFRow tableDescriptionRow = sheet.createRow(i);
                    SXSSFCell cell1 = tableDescriptionRow.createCell(0);
                    cell1.setCellValue(days_name);
                    cell1.setCellStyle(wrapStyle);

                    SXSSFCell cell2 = tableDescriptionRow.createCell(1);
                    cell2.setCellValue(count);
                    cell2.setCellStyle(wrapStyle);
                } else if (userInput.equals("month")) {
                    String week_start = rs.getString("week_start");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(week_start);
                    data.setCount(count);
                    
                    SXSSFRow tableDescriptionRow = sheet.createRow(i);
                    SXSSFCell cell1 = tableDescriptionRow.createCell(0);
                    cell1.setCellValue(week_start);
                    cell1.setCellStyle(wrapStyle);

                    SXSSFCell cell2 = tableDescriptionRow.createCell(1);
                    cell2.setCellValue(count);
                    cell2.setCellStyle(wrapStyle);
                } else if (userInput.equals("year")) {
                    String month_name = rs.getString("month_name");
                    int count = rs.getInt("sucker_count");
                    data.setLabelName(month_name);
                    data.setCount(count);
                    
                    SXSSFRow tableDescriptionRow = sheet.createRow(i);
                    SXSSFCell cell1 = tableDescriptionRow.createCell(0);
                    cell1.setCellValue(month_name);
                    cell1.setCellStyle(wrapStyle);

                    SXSSFCell cell2 = tableDescriptionRow.createCell(1);
                    cell2.setCellValue(count);
                    cell2.setCellStyle(wrapStyle);
                } else if (userInput.equals("all")) {
                    int count = rs.getInt("sucker_count");
                    data.setCount(count);
                    
                    SXSSFRow tableDescriptionRow = sheet.createRow(i);
                    SXSSFCell cell1 = tableDescriptionRow.createCell(0);
                    cell1.setCellValue("All");
                    cell1.setCellStyle(wrapStyle);

                    SXSSFCell cell2 = tableDescriptionRow.createCell(1);
                    cell2.setCellValue(count);
                    cell2.setCellStyle(wrapStyle);
                }
                i++;
            }
            // Write workbook to ByteArrayOutputStream
            workbook.write(byteArrayOutputStream);
            workbook.close();
            byte[] excelBlobBytes = byteArrayOutputStream.toByteArray();
            getFORoleReportSuckerCountResponse.setExcelBlob(excelBlobBytes);
            getFORoleReportSuckerCountResponse.setIsError(false);
        } catch (Exception e) {
            getFORoleReportSuckerCountResponse.setError(e.getMessage());
            getFORoleReportSuckerCountResponse.setIsError(true);
        } finally {
            trx.close();
            getCompiereService().disconnect();
            closeDbCon(pstm, rs);
        }
        return getFORoleReportSuckerCountResponseDocument;
    }


==================================================================================================================================================================
Stage wise Contamination Dashboard query;-
SELECT Category, SUM(TotalDiscardQuantity) AS TotalDiscardQuantity 
FROM (
    SELECT
        CASE
            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'
            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'
            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'
            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'
            WHEN pr.name LIKE 'H0%' OR pr.name LIKE 'H%' THEN 'Hardening'
            ELSE 'Other'
        END AS Category,
        o.discardqty AS TotalDiscardQuantity
    FROM adempiere.tc_out o
    JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id
    WHERE o.ad_client_id = 1000000
) AS Subquery
WHERE Category <> 'Other' 
GROUP BY Category 
ORDER BY 
    CASE Category
        WHEN 'Initiation' THEN 1
        WHEN 'Multiplication' THEN 2
        WHEN 'Elongation' THEN 3
        WHEN 'Rooting' THEN 4
        WHEN 'Hardening' THEN 5
        ELSE 6
    END;


==================================================================================================================================================================
To Sub culture Query:-
Day:-
SELECT day_info.day_name AS day_name,current_date,COALESCE(COUNT(v.*), 0) AS visit_count
FROM (SELECT to_char(current_date, 'FMDay') AS day_name) AS day_info
LEFT JOIN adempiere.tc_culturelabel v ON v.created::date = current_date - interval '21 days'
AND v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND v.createdby IN 
(SELECT ad_user_id FROM adempiere.ad_user WHERE name = 'lavan') GROUP BY day_info.day_name;

Week:-
WITH days AS (SELECT generate_series(0, 6) AS day_of_week),
visit_counts AS (SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,
EXTRACT(dow FROM v.created) AS day_of_week,COUNT(*) AS visit_count FROM adempiere.tc_culturelabel v 
JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby WHERE v.ad_client_id = 1000000 
AND v.isdiscarded = 'N' AND u.name = 'lavan' AND v.created::date >= current_date - interval '27 days' -- considering the 21 days completion
AND v.created::date < current_date - interval '6 days' -- only up to the last 6 days from today
GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))
SELECT (current_date + d.day_of_week * interval '1 day')::date AS dates,
COALESCE(vc.day_name, to_char(current_date + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,
COALESCE(vc.visit_count, 0) AS visit_count FROM days d 
LEFT JOIN visit_counts vc ON date_trunc('day', current_date + d.day_of_week * interval '1 day' - interval '21 days') = vc.visit_day 
ORDER BY dates;

Month:-

==================================================================================================================================================================
User Log:-
SELECT l.ad_changelog_id As id,t.name As TableName,c.name,l.record_id,l.oldvalue,l.newvalue,u.name,l.updatedby,l.updated FROM adempiere.ad_changelog l
JOIN adempiere.ad_user u ON u.ad_user_id = l.updatedby
JOIN adempiere.ad_table t ON l.ad_table_id = t.ad_table_id  
JOIN adempiere.ad_column c ON c.ad_column_id = l.ad_column_id   
where l.ad_client_id = 1000000 AND u.name = 'bmfc' AND l.created::date = CURRENT_DATE;

==================================================================================================================================================================
Stage wise Culture Distribution:-
WITH categories AS (
    SELECT 'Initiation' AS Category
    UNION ALL SELECT 'Callusing'
    UNION ALL SELECT 'Multiplication'
    UNION ALL SELECT 'Elongation'
    UNION ALL SELECT 'Rooting'
    UNION ALL SELECT 'Hardening'
),
category_counts AS (
    SELECT
        CASE
            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'
            WHEN pr.name LIKE 'BC%' THEN 'Callusing'
            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'
            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'
            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'
            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Hardening'
            ELSE 'Other'
        END AS Category,
        SUM(o.qtyonhand) AS TotalQuantity
    FROM 
        adempiere.m_storageonhand o
    JOIN 
        adempiere.m_product pr ON pr.m_product_id = o.m_product_id
    WHERE 
        o.ad_client_id = 1000000
    GROUP BY 
        CASE
            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'
            WHEN pr.name LIKE 'BC%' THEN 'Callusing'
            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'
            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'
            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'
            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Hardening'
            ELSE 'Other'
        END
)
SELECT 
    c.Category, 
    COALESCE(cc.TotalQuantity, 0) AS TotalQuantity
FROM 
    categories c
LEFT JOIN 
    category_counts cc ON c.Category = cc.Category
ORDER BY 
    CASE c.Category
        WHEN 'Initiation' THEN 1
        WHEN 'Callusing' THEN 2
        WHEN 'Multiplication' THEN 3
        WHEN 'Elongation' THEN 4
        WHEN 'Rooting' THEN 5
        WHEN 'Hardening' THEN 6
        ELSE 7
    END;

==================================================================================================================================================================
User Management report Role:-
SELECT users, userId, personalCode, date,orderId, id, labelName,countValue,counts
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Culture Role' AS labelName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID} AND cl.isdiscarded = 'N' AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_mediaorder_id As orderID,cl.tc_medialabelQr_id AS id,'Media Role' AS labelName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_mediaorder_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_mediaorder_id,u.name) AS counts FROM adempiere.tc_medialabelQr cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_medialine o ON o.tc_medialine_id = cl.tc_medialine_id
WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID} AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'QA Role' AS labelName,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = $P{AD_CLIENT_ID} AND cl.isdiscarded = 'Y' AND u.personalcode is not null    
) AS combined WHERE combined.date >= $P{FromDate} AND combined.date < ($P{ToDate}::timestamp + INTERVAL '1 day') 
 AND ($P{Label} IS NULL OR combined.labelName = $P{Label})  ORDER BY users,date,orderId;

 --------------------
 Current Date show records:-
combined.date >= $P{FromDate} AND combined.date < ($P{ToDate}::timestamp + INTERVAL '1 day')
--------------------

==================================================================================================================================================================    
get unique village name:-
SELECT villagename FROM adempiere.tc_farmer WHERE ad_client_id = 1000000
GROUP BY villagename HAVING COUNT(*) > 1
UNION ALL
SELECT villagename FROM adempiere.tc_farmer WHERE ad_client_id = 1000000
GROUP BY villagename HAVING COUNT(*) = 1 ORDER BY villagename;

==================================================================================================================================================================
Get data for specific records:-

SELECT name,tc_culturestage_id FROM adempiere.tc_culturestage WHERE ad_client_id = 1000000 AND
 name IN ('Rooting','Hardening') ORDER BY tc_culturestage_id;

==================================================================================================================================================================
Actual Traceability If enter culture label or enter explant label or plant tag label):-

WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,cl.cycleno,ps.name AS cropType,cs.name AS stage,
var.name AS variety, cl.personal_code,ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE cl.c_uuid = 'ef247d26-d7f7-4d00-906a-21c7901d926e' AND cl.ad_client_id = 1000002
AND DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE ad_client_id = 1000002)
UNION ALL
SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,cl2.cycleno,ps.name AS cropType,cs.name AS stage,
var.name AS variety,cl2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level FROM cte
JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE created = ts.created)),
culture_result AS (
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code, 
MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,MIN(cte.humidity) AS min_humidity, MAX(cte.humidity) AS max_humidity,cte.level FROM cte
GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid, cte.location,cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety,cte.personal_code, cte.level
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,cte.cropType,pr.name AS stage,
cte.variety,tcc.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage, 
cte.variety,NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created ASC
),
explant_result AS (
SELECT DISTINCT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, loc.value AS location,tcc.created, 0 AS cycleno, ps.name AS cropType,
pr.name AS stage, var.name AS variety,tcc.personalcode AS personal_code, NULL AS min_temperature, NULL AS max_temperature, 
NULL AS min_humidity, NULL AS max_humidity, 1 AS level FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id WHERE tcc.c_uuid = 'ef247d26-d7f7-4d00-906a-21c7901d926e' AND tcc.ad_client_id = 1000002
UNION ALL
SELECT DISTINCT NULL AS parentuuid, 0 AS tc_in_id, 0 AS tc_out_id, tpt.c_uuid, NULL AS location,tpt.created, 0 AS cycleno, ps.name AS cropType,
'Plant Tag' AS stage, var.name AS variety,NULL AS personal_code, NULL AS min_temperature, NULL AS max_temperature,NULL AS min_humidity, NULL AS max_humidity, 2 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id WHERE tcc.c_uuid = 'ef247d26-d7f7-4d00-906a-21c7901d926e' AND tcc.ad_client_id = 1000002 AND tpt.c_uuid IS NOT NULL
),
plant_tag_result AS (
SELECT DISTINCT NULL AS parentuuid, 0 AS tc_in_id, 0 AS tc_out_id, tpt.c_uuid, NULL AS location,tpt.created, 0 AS cycleno, ps.name AS cropType,
'Plant Tag' AS stage, var.name AS variety,NULL AS personal_code, NULL AS min_temperature, NULL AS max_temperature,NULL AS min_humidity, NULL AS max_humidity, 1 AS level
FROM adempiere.tc_planttag tpt JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = pd.tc_species_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id 
WHERE tpt.c_uuid = 'ef247d26-d7f7-4d00-906a-21c7901d926e' AND tpt.ad_client_id = 1000002 AND NOT EXISTS (SELECT 1 FROM explant_result)
)   
SELECT * FROM culture_result
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;
==================================================================================================================================================================

WITH RECURSIVE cte AS (
    -- Recursive query for culture label
    SELECT cl.parentuuid, cl.tc_in_id, cl.tc_out_id, cl.c_uuid, loc.value AS location, cl.created, 
           cl.cycleno, ps.name AS cropType, cs.name AS stage, var.name AS variety, cl.personal_code, 
           ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
    WHERE cl.c_uuid = '8b0803a6-2f84-4a46-ab11-4fa626f45795'
    AND cl.ad_client_id = 1000002
    AND DATE(ts.created) = (
        SELECT MAX(DATE(created))
        FROM adempiere.tc_temperaturestatus
        WHERE ad_client_id = 1000002
    )
    UNION ALL
    SELECT cl2.parentuuid, cl2.tc_in_id, cl2.tc_out_id, cl2.c_uuid, loc.value AS location, cl2.created, 
           cl2.cycleno, ps.name AS cropType, cs.name AS stage, var.name AS variety, 
           cl2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, cte.level + 1 AS level
    FROM cte
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
    JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
    JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id
    JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
    WHERE DATE(ts.created) = (
        SELECT MAX(DATE(created))
        FROM adempiere.tc_temperaturestatus
        WHERE created = ts.created
    )
),
culture_result AS (
    -- Get the final result for culture label
    SELECT cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid, cte.location, cte.created, 
           cte.cycleno, cte.cropType, cte.stage, cte.variety, cte.personal_code, 
           MIN(cte.temp) AS min_temperature, MAX(cte.temp) AS max_temperature, 
           MIN(cte.humidity) AS min_humidity, MAX(cte.humidity) AS max_humidity, cte.level
    FROM cte
    GROUP BY cte.parentuuid, cte.tc_in_id, cte.tc_out_id, cte.c_uuid, cte.location, 
             cte.created, cte.cycleno, cte.cropType, cte.stage, cte.variety, 
             cte.personal_code, cte.level
    UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,cte.cropType,pr.name AS stage,
cte.variety,tcc.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage, 
cte.variety,NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created ASC
),
explant_result AS (
    -- Only check explant label if culture_result has no rows
    SELECT DISTINCT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, loc.value AS location, 
           tcc.created, 0 AS cycleno, ps.name AS cropType, pr.name AS stage, var.name AS variety, 
           tcc.personalcode AS personal_code, NULL AS min_temperature, NULL AS max_temperature, 
           NULL AS min_humidity, NULL AS max_humidity, 1 AS level
    FROM adempiere.tc_explantlabel tcc
    JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
    JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id
    JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = tcc.tc_species_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
    WHERE tcc.c_uuid = '8b0803a6-2f84-4a46-ab11-4fa626f45795'
)
-- Return culture_result if it has data, else return explant_result
SELECT * FROM culture_result
UNION ALL
SELECT * FROM explant_result
WHERE NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC;

==================================================================================================================================================================
Tracebility Query:-
New Working Fine:-
WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,cl.cycleno,ps.name AS cropType,cs.name AS stage, 
var.name AS variety,cl.personal_code,ts.temperature AS temp,ts.humidity AS humidity,1 AS level FROM adempiere.tc_culturelabel cl 
JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id 
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id 
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id 
JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id WHERE cl.c_uuid = '8b0803a6-2f84-4a46-ab11-4fa626f45795' 
AND cl.ad_client_id = 1000002 AND DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE ad_client_id = 1000002)
UNION ALL
SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,cl2.cycleno,ps.name AS cropType,cs.name AS stage, 
var.name AS variety,cl2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level FROM cte
JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus WHERE created = ts.created))
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety, 
cte.personal_code,MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,MIN(cte.humidity) AS min_humidity,MAX(cte.humidity) AS max_humidity, 
cte.level FROM cte GROUP BY cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType, 
cte.stage,cte.variety,cte.personal_code,cte.level
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,cte.cropType,pr.name AS stage,
cte.variety,tcc.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage, 
cte.variety,NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level 
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created ASC;

OLD Facing Error:-
WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.tc_in_id,cl.tc_out_id,cl.c_uuid,loc.value AS location,cl.created,
cl.cycleno,ps.name AS cropType,cs.name AS stage,var.name AS variety,cl.personal_code,ts.temperature AS temp,ts.humidity AS humidity,1 AS level
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_species_ids
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE cl.c_uuid =   $P{CultureLabelUUId} AND
cl.ad_client_id =  $P{AD_CLIENT_ID}  AND DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus)      
UNION ALL    
SELECT cl2.parentuuid,cl2.tc_in_id,cl2.tc_out_id,cl2.c_uuid,loc.value AS location,cl2.created,cl2.cycleno,ps.name AS cropType,
cs.name AS stage,var.name AS variety,cl2.personal_code,ts.temperature AS temp,ts.humidity AS humidity,cte.level + 1 AS level FROM cte
JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid JOIN adempiere.tc_out o ON o.tc_out_id = cl2.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = o.m_locator_id JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl2.tc_species_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl2.tc_culturestage_id JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_species_ids
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = loc.m_locatortype_id JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lt.m_locatortype_id
WHERE DATE(ts.created) = (SELECT MAX(DATE(created)) FROM adempiere.tc_temperaturestatus where created = ts.created))
SELECT cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code,
MIN(cte.temp) AS min_temperature,MAX(cte.temp) AS max_temperature,MIN(cte.humidity) AS min_humidity,MAX(cte.humidity) AS max_humidity,cte.level FROM cte
GROUP BY cte.parentuuid,cte.tc_in_id,cte.tc_out_id,cte.c_uuid,cte.location,cte.created,cte.cycleno,cte.cropType,cte.stage,cte.variety,cte.personal_code,cte.level
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.tc_in_id,tcc.tc_out_id,tcc.c_uuid,loc.value AS location,tcc.created,0 AS cycleno,cte.cropType,pr.name AS stage,cte.variety,
tcc.personalcode AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_locator loc ON loc.m_locator_id = eo.m_locator_id JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT DISTINCT NULL AS parentuuid,0 AS tc_in_id,0 AS tc_out_id,tpt.c_uuid,NULL AS location,tpt.created,0 AS cycleno,cte.cropType,'Plant Tag' AS stage,
cte.variety,NULL AS personal_code,NULL AS min_temperature,NULL AS max_temperature,NULL AS min_humidity,NULL AS max_humidity,cte.level FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL ORDER BY created ASC;

==================================================================================================================================================================
Old Jasper Tracebility Database:-
WITH RECURSIVE cte AS (
  -- Anchor query
  SELECT l.parentuuid, l.tc_in_id, l.tc_out_id, l.c_uuid, lo.value AS location, l.created, l.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         l.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
  FROM adempiere.tc_culturelabel l
  JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
  WHERE l.c_uuid =   $P{CultureLabelUUId}  AND l.ad_client_id =   $P{AD_CLIENT_ID} 

  UNION ALL

  -- Recursive query
  SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id, t2.c_uuid, lo.value AS location, t2.created, t2.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         t2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 2 AS level
  FROM cte t1
  JOIN adempiere.tc_culturelabel t2 ON t1.parentuuid = t2.c_uuid
  JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)

SELECT cte.*
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT tcc.parentuuid, tcc.tc_in_id, tcc.tc_out_id, tcc.c_uuid, NULL AS location, tcc.created, cte.cycleno, cte.cropType, pr.name, cte.variety, tcc.personalcode, NULL AS temp, NULL AS humidity, 3 AS level
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc
ON cte.parentuuid = tcc.c_uuid
JOIN adempiere.tc_out eo ON eo.tc_out_id = tcc.tc_out_id
JOIN adempiere.m_product pr ON pr.m_product_id = eo.m_product_id
UNION ALL
SELECT null AS parentuuid, NULL AS tc_in_id, NULL AS tc_out_id, tpt.c_uuid, NULL AS location, tpt.created, NULL AS cycleno, cte.cropType,'Plant Tag',cte.variety, NULL AS personal_code, NULL AS temp, NULL AS humidity, 4 AS level
FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
WHERE tpt.c_uuid IS NOT NULL
ORDER BY created DESC;

==================================================================================================================================================================
Get Device Records:-
SELECT dd.tc_devicedata_id As id,dd.c_uuid AS uuid,dd.name,dd.deviceid,dd.frequency,lt.name AS roomNo,tp.name As cornorType,st.name AS sensorType FROM adempiere.tc_devicedata dd
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = dd.m_locatortype_id
JOIN adempiere.tc_temperatureposition tp ON tp.tc_temperatureposition_id = dd.tc_temperatureposition_id
JOIN adempiere.tc_sensortype st ON st.tc_sensortype_id = dd.tc_sensortype_id

==================================================================================================================================================================
-- week
WITH days AS (SELECT generate_series(0, 6) AS day_of_week),
visit_counts AS (
SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,EXTRACT(dow FROM v.created) AS day_of_week,COUNT(*) AS visit_count
FROM adempiere.tc_culturelabel v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby 
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'SuperUser' AND v.created::date >= current_date - interval '6 days' 
AND v.created::date <= current_date GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))
SELECT current_date - interval '6 days' + d.day_of_week * interval '1 day' AS dates,
COALESCE(vc.day_name, to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,COALESCE(vc.visit_count, 0) AS visit_count FROM days d 
LEFT JOIN visit_counts vc ON date_trunc('day', current_date - interval '6 days' + d.day_of_week * interval '1 day') = vc.visit_day ORDER BY dates;

-- year
WITH months AS (SELECT generate_series(0, 11) AS month),
visit_counts AS (
SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,COUNT(*) AS visit_count
FROM adempiere.tc_culturelabel v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'SuperUser' AND v.created::date >= (current_date - interval '364 days') AND v.created::date <= current_date
GROUP BY date_trunc('month', v.created), to_char(v.created, 'FMMonth'))
SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval, 'FMMonth') AS month_name, 
COALESCE(vc.visit_count, 0) AS visit_count FROM months m 
LEFT JOIN visit_counts vc ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year
ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;

-- day
SELECT day_info.day_name AS day_name,COALESCE(COUNT(v.*), 0) AS visit_count
FROM (SELECT to_char(current_date, 'FMDay') AS day_name) AS day_info
LEFT JOIN adempiere.tc_culturelabel v ON v.created::date = current_date AND v.ad_client_id = 1000000 AND v.isdiscarded = 'N'
AND v.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = 'SuperUser')GROUP BY day_info.day_name;

-- all
SELECT COUNT(*) AS visit_count FROM adempiere.tc_culturelabel v
JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan'

-- month
WITH weeks AS (SELECT generate_series(0, 4) AS week_number),
visit_counts AS (
SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,
COUNT(*) AS visit_count FROM adempiere.tc_culturelabel v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'SuperUser'  AND v.created::date >= (current_date - interval '29 days') AND v.created::date <= current_date GROUP BY date_trunc('week', v.created)),
date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)
SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.visit_count, 0) AS visit_count
FROM date_range LEFT JOIN visit_counts vc ON date_trunc('week', day) = vc.week_start
GROUP BY date_trunc('week', day),vc.visit_count ORDER BY week_start;

==================================================================================================================================================================
select * from adempiere.tc_medialabelqr
-- week
WITH days AS (SELECT generate_series(0, 6) AS day_of_week),
visit_counts AS (
SELECT date_trunc('day', v.created) AS visit_day,to_char(v.created, 'FMDay') AS day_name,EXTRACT(dow FROM v.created) AS day_of_week,COUNT(*) AS visit_count
FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby 
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan' AND v.created::date >= current_date - interval '6 days' 
AND v.created::date <= current_date GROUP BY date_trunc('day', v.created),to_char(v.created, 'FMDay'),EXTRACT(dow FROM v.created))
SELECT current_date - interval '6 days' + d.day_of_week * interval '1 day' AS dates,
COALESCE(vc.day_name, to_char(current_date - interval '6 days' + d.day_of_week * interval '1 day', 'FMDay')) AS day_name,COALESCE(vc.visit_count, 0) AS counts FROM days d 
LEFT JOIN visit_counts vc ON date_trunc('day', current_date - interval '6 days' + d.day_of_week * interval '1 day') = vc.visit_day ORDER BY dates;

-- year
WITH months AS (SELECT generate_series(0, 11) AS month),
visit_counts AS (
SELECT date_trunc('month', v.created) AS month_year,to_char(v.created, 'FMMonth') AS month_name,COUNT(*) AS visit_count
FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan' AND v.created::date >= (current_date - interval '364 days') AND v.created::date <= current_date
GROUP BY date_trunc('month', v.created), to_char(v.created, 'FMMonth'))
SELECT to_char(date_trunc('month', current_date) - (m.month || ' months')::interval, 'FMMonth') AS month_name, 
COALESCE(vc.visit_count, 0) AS counts FROM months m 
LEFT JOIN visit_counts vc ON date_trunc('month', current_date) - (m.month || ' months')::interval = vc.month_year
ORDER BY date_trunc('month', current_date) - (m.month || ' months')::interval;

-- day
SELECT day_info.day_name AS day_name,COALESCE(COUNT(v.*), 0) AS counts
FROM (SELECT to_char(current_date, 'FMDay') AS day_name) AS day_info
LEFT JOIN adempiere.tc_medialabelqr v ON v.created::date = current_date AND v.ad_client_id = 1000000 AND v.isdiscarded = 'N'
AND v.createdby IN (SELECT ad_user_id FROM adempiere.ad_user WHERE name = 'lavan')GROUP BY day_info.day_name;

-- all
SELECT COUNT(*) AS counts FROM adempiere.tc_medialabelqr v
JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan'

-- month
WITH weeks AS (SELECT generate_series(0, 4) AS week_number),
counts AS (
SELECT date_trunc('week', v.created) AS week_start,to_char(date_trunc('week', v.created), 'YYYY-MM-DD') AS week_start_str,
COUNT(*) AS counts FROM adempiere.tc_medialabelqr v JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby
WHERE v.ad_client_id = 1000000 AND v.isdiscarded = 'N' AND u.name = 'lavan'  AND v.created::date >= (current_date - interval '29 days') AND v.created::date <= current_date GROUP BY date_trunc('week', v.created)),
date_range AS (SELECT (current_date - interval '29 days')::date + generate_series(0, 29) AS day)
SELECT to_char(date_trunc('week', day), 'YYYY-MM-DD') AS week_start,COALESCE(vc.counts, 0) AS counts
FROM date_range LEFT JOIN counts vc ON date_trunc('week', day) = vc.week_start
GROUP BY date_trunc('week', day),vc.counts ORDER BY week_start;

==================================================================================================================================================================
Allocate Storage:-
WITH RoomCapacity AS (SELECT lt.name AS RoomType,COUNT(DISTINCT s.m_locator_id) AS num_locators,
COUNT(DISTINCT s.m_locator_id) * 40 AS max_capacity FROM adempiere.m_storageonhand s
JOIN adempiere.m_locator l ON l.m_locator_id = s.m_locator_id
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
WHERE s.ad_client_id = 1000000 AND lt.name IN ('C1', 'C2', 'C3', 'C4')
GROUP BY lt.name)
SELECT rc.RoomType,rc.num_locators,rc.max_capacity,COALESCE(SUM(s.qtyonhand), 0) AS total_qtyonhand FROM RoomCapacity rc
LEFT JOIN adempiere.m_storageonhand s ON s.m_locator_id IN (SELECT l.m_locator_id FROM adempiere.m_locator l 
JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id WHERE lt.name = rc.RoomType)
GROUP BY rc.RoomType, rc.num_locators, rc.max_capacity ORDER BY rc.RoomType;

===========
User Specific:-
WITH RoomCapacity AS (
    SELECT lt.name AS RoomType,COUNT(DISTINCT l.m_locator_id) AS num_locators,COUNT(DISTINCT l.m_locator_id) * 50 AS max_capacity
    FROM adempiere.m_locator l JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id
    WHERE l.ad_client_id = 1000000 AND lt.name IN ('C1', 'C2', 'C3', 'C4') GROUP BY lt.name)
SELECT rc.RoomType AS roomType,rc.num_locators,rc.max_capacity,COALESCE(SUM(s.qtyonhand), 0) AS total_qtyonhand,
ROUND((COALESCE(SUM(s.qtyonhand), 0) / rc.max_capacity::float) * 100) AS percentage_occupied FROM RoomCapacity rc
LEFT JOIN adempiere.m_locator l ON l.m_locatortype_id = (SELECT m_locatortype_id FROM adempiere.m_locatortype WHERE name = rc.RoomType)
LEFT JOIN adempiere.m_storageonhand s ON s.m_locator_id = l.m_locator_id 
JOIN adempiere.ad_user u ON u.ad_user_id = s.createdby  
WHERE u.name = 'SuperUser' GROUP BY rc.RoomType, rc.num_locators, rc.max_capacity ORDER BY rc.RoomType;

==================================================================================================================================================================
sudo apt update
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install git -y
sudo apt install docker.io -y
sudo apt install python3 -y
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 10  
nvm use 10
sudo apt install docker-compose -y
sudo apt install golang-go -y
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin   

sudo usermod -a -G docker ${USER}
sudo reboot
sudo chmod 666 /var/run/docker.sock 
curl -sSL http://bit.ly/2ysbOFE | bash -s -- 2.5.6 1.5.9 

cd fabric-samples
sudo cp bin/* /usr/local/bin    '*/'not use after bin ' 
ls (not see chaincode folder)
    
this above command is using every thing image is downloaded and fabric-sample folder also available
but inside fabric-sample folder not show chaincode folder
why 
if i had any mistake please suggest me and solve my problem

==================================================================================================================================================================
Search option in Tissue culture All Farmar List API:-
StringBuilder sql = new StringBuilder("SELECT \n"
                    + "    tc_farmer_id AS id,\n"
                    + "    name AS farmerName,\n"
                    + "    mobileno AS mobileNo,\n"
                    + "    villagename AS villageName,\n"
                    + "    address AS address,\n"
                    + "    landmark AS landmark \n"
                    + "FROM \n"
                    + "    adempiere.tc_farmer\n"
                    + "WHERE \n"
                    + "    AD_Client_Id = " + AD_Client_Id + " \n");

            if (searchKey != null && !searchKey.trim().isEmpty()) {
                sql.append("    AND (name ILIKE '%' || ? || '%' \n"
                        + "    OR villagename ILIKE '%' || ? || '%' \n"
                        + "    OR address ILIKE '%' || ? || '%' \n"
                        + "    OR landmark ILIKE '%' || ? || '%') ");
            }
            pstm = DB.prepareStatement(sql.toString(), null);
            if (searchKey != null && !searchKey.trim().isEmpty()) {
            pstm.setString(1, searchKey);
            pstm.setString(2, searchKey);
            pstm.setString(3, searchKey);
            pstm.setString(4, searchKey);
            }
            rs = pstm.executeQuery();

==================================================================================================================================================================
Expiry Reports:-
WITH subquery AS (SELECT 
ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
cs.name || ' - ' || cl.cycleno AS Cycle,DATE(cl.cultureoperationdate) AS manufacturing_date,
DATE(cl.cultureoperationdate + INTERVAL '21 days') AS expiryDate,l.x AS Room,l.y AS Rack,l.z AS columns,
(SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id WHERE cl.ad_client_id = 1000000 
AND cl.isdiscarded = 'N' AND cl.c_uuid IS NOT NULL AND cl.parentuuid IS NOT NULL )
SELECT cultureCode,Cycle,manufacturing_date,expiryDate,Room,Rack,columns,COUNT(*) AS count
FROM subquery WHERE subquery_column = 0 AND expiryDate <= current_date
GROUP BY cultureCode,Cycle,manufacturing_date,expiryDate,Room,Rack,columns
ORDER BY expiryDate,cycle,Room,Rack,columns;

=========================
Update created:-
WITH subquery AS (SELECT 
ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
cs.name || ' - ' || cl.cycleno AS cycle,DATE(cl.created) AS manufacturingDate,
DATE(cl.created + INTERVAL '21 days') AS expiryDate,l.x AS room,l.y AS rack,l.z AS columns,
(SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id WHERE cl.ad_client_id = 1000000 
AND cl.isdiscarded = 'N' AND cl.c_uuid IS NOT NULL AND cl.parentuuid IS NOT NULL )
SELECT cultureCode,cycle,manufacturingDate,expiryDate,room,rack,columns,COUNT(*) AS count
FROM subquery WHERE subquery_column = 0 AND expiryDate <= current_date
GROUP BY cultureCode,cycle,manufacturingDate,expiryDate,room,rack,columns
ORDER BY expiryDate,cycle,Room,Rack,columns;
==================================================================================================================================================================
Expiry Report added in period:-
WITH subquery AS (
SELECT ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
cs.name || ' - ' || cl.cycleno AS cycle,DATE(cl.cultureoperationdate) AS manufacturingDate,
DATE(cl.cultureoperationdate + (cs.period::int * INTERVAL '1 day')) AS expiryDate,l.x AS room,l.y AS rack,l.z AS columns,cs.period AS period,
(SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column
FROM adempiere.tc_culturelabel cl 
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id 
WHERE cl.ad_client_id = 1000000 AND cl.isdiscarded = 'N' AND cl.c_uuid IS NOT NULL AND cl.parentuuid IS NOT NULL)
SELECT cultureCode,cycle,manufacturingDate,expiryDate,room,rack,columns,COUNT(*) AS count,period
FROM subquery WHERE subquery_column = 0 AND expiryDate <= current_date
GROUP BY cultureCode,cycle,manufacturingDate,expiryDate,room,rack,columns,period
ORDER BY expiryDate,cycle,room,rack,columns;
=================================================
created use:-
WITH subquery AS (
SELECT ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
cs.name || ' - ' || cl.cycleno AS cycle,DATE(cl.created) AS manufacturingDate,
DATE(cl.created + (cs.period::int * INTERVAL '1 day')) AS expiryDate,l.x AS room,l.y AS rack,l.z AS columns,
cs.period AS period,(SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id 
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id 
JOIN adempiere.tc_in i ON i.tc_in_id = cl.tc_in_id JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id 
WHERE cl.ad_client_id = 1000000 AND cl.isdiscarded = 'N' AND cl.c_uuid IS NOT NULL AND cl.parentuuid IS NOT NULL)
SELECT cultureCode,cycle,manufacturingDate,expiryDate,room,rack,columns,COUNT(*) AS count,period
FROM subquery WHERE subquery_column = 0 AND expiryDate <= current_date
GROUP BY cycle,room,rack,columns,cultureCode,manufacturingDate,expiryDate,period ORDER BY expiryDate,cycle,room,rack,columns;
==================================================================================================================================================================
WITH subquery AS (SELECT cl.c_uuid As cultureUUid,cl.tc_culturelabel_id As cultureId,o.c_uuid As outUUid,o.tc_out_id As outId,
ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
cs.name || ' - ' || cl.cycleno AS cycle,DATE(cl.created) AS manufacturingDate,DATE(cl.created + (cs.period::int * INTERVAL '1 day')) AS expiryDate,
(SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column FROM adempiere.tc_culturelabel cl 
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.m_locator l ON l.m_locator_id = o.m_locator_id JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id 
WHERE cl.ad_client_id = 1000000 AND cl.isdiscarded = 'N' AND cl.tosubculturecheck = 'N' AND cl.c_uuid IS NOT NULL AND cl.parentuuid IS NOT NULL)
SELECT cultureUUid,cultureId,outUUid,outId,cultureCode,cycle,manufacturingDate,expiryDate
FROM subquery WHERE subquery_column = 0 AND expiryDate <= current_date ORDER BY expiryDate,cycle;

==================================================================================================================================================================
records show with InId:-
WITH subquery AS (
    SELECT 
        ps.codeno || ' ' || v.codeno || ' ' || cl.parentcultureline || ' ' || TO_CHAR(cl.culturedate, 'DD-MM-YY') || ' ' || ns.codeno AS cultureCode,
        cs.name || ' - ' || cl.cycleno AS cycle,
        DATE(cl.created) AS manufacturingDate,
        DATE(cl.created + (cs.period::int * INTERVAL '1 day')) AS expiryDate,
        l.x AS room,
        l.y AS rack,
        l.z AS columns,
        cs.period AS period,
        (SELECT COUNT(*) FROM adempiere.tc_culturelabel cll WHERE cll.parentuuid = cl.c_uuid LIMIT 1) AS subquery_column,
    (SELECT i.tc_in_id FROM adempiere.tc_in i WHERE i.parentuuid = o.c_uuid)As tcId
    FROM 
        adempiere.tc_culturelabel cl
    JOIN 
        adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
    JOIN 
        adempiere.tc_variety v ON v.tc_variety_id = cl.tc_species_ids
    JOIN 
        adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
    JOIN 
        adempiere.tc_in i ON i.tc_in_id = cl.tc_in_id
    JOIN 
        adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
    JOIN 
        adempiere.m_locator l ON l.m_locator_id = o.m_locator_id
    JOIN 
        adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
    WHERE 
        cl.ad_client_id = 1000000
        AND cl.isdiscarded = 'N'
        AND cl.tosubculturecheck = 'Y'
        AND cl.c_uuid IS NOT NULL
        AND cl.parentuuid IS NOT NULL
)
SELECT 
    cultureCode,
    cycle,
    manufacturingDate,
    expiryDate,
    room,
    rack,
    columns,
    COUNT(*) AS count,
    period,tcId
FROM 
    subquery
WHERE 
    subquery_column = 0
    AND manufacturingDate <= current_date
GROUP BY 
    cycle,
    room,
    rack,
    columns,
    cultureCode,
    manufacturingDate,
    expiryDate,
    period,tcId
ORDER BY 
    expiryDate,
    cycle,
    room,
    rack,
    columns;
 
==================================================================================================================================================================            
Medium Technician :-
SELECT 
    mo.tc_mediaorder_id,
    mo.quantity,
    mo.m_product_id,
    mo.ad_user_id,
    sub.total_quantity,
    mo.quantity - sub.total_quantity AS actualQty
FROM 
    adempiere.tc_mediaorder mo
LEFT JOIN (
    SELECT 
        ml.tc_mediaorder_id,
        ml.m_product_id,
        SUM(ml.quantity) AS total_quantity
    FROM 
        adempiere.tc_medialine ml
    GROUP BY 
        ml.tc_mediaorder_id, ml.m_product_id
) sub ON mo.tc_mediaorder_id = sub.tc_mediaorder_id AND mo.m_product_id = sub.m_product_id
WHERE 
    mo.docstatus = 'DR' AND mo.quantity is not null;


    =============================
    ------------------------
    SELECT 
    mo.tc_mediaorder_id,
    mo.quantity,
    mo.m_product_id,
    mo.ad_user_id,
    COALESCE(sub.total_quantity, 0) AS total_quantity,
    mo.quantity - COALESCE(sub.total_quantity, 0) AS actualQty,
    SUM(mo.quantity - COALESCE(sub.total_quantity, 0)) OVER () AS totalActualQty
FROM 
    adempiere.tc_mediaorder mo
LEFT JOIN (
    SELECT 
        ml.tc_mediaorder_id,
        ml.m_product_id,
        SUM(ml.quantity) AS total_quantity
    FROM 
        adempiere.tc_medialine ml
    GROUP BY 
        ml.tc_mediaorder_id, ml.m_product_id
) sub ON mo.tc_mediaorder_id = sub.tc_mediaorder_id AND mo.m_product_id = sub.m_product_id
WHERE 
    mo.quantity IS NOT NULL limit 1;
==================================================================================================================================================================
@Override
    public WarehouseLocatorListResponseDocument wareList(
            WarehouseLocatorListRequestDocument warehouseLocatorListRequestDocument) {
        WarehouseLocatorListResponseDocument warehouseLocatorListResponseDocument = WarehouseLocatorListResponseDocument.Factory
                .newInstance();
        WarehouseLocatorListResponse warehouseLocatorListResponse = warehouseLocatorListResponseDocument
                .addNewWarehouseLocatorListResponse();
        WarehouseLocatorListRequest warehouseLocatorListRequest = warehouseLocatorListRequestDocument
                .getWarehouseLocatorListRequest();
        ADLoginRequest loginReq = warehouseLocatorListRequest.getADLoginRequest();
        int ad_client_id = loginReq.getClientID();
        String serviceType = warehouseLocatorListRequest.getServiceType();
        PreparedStatement pstm = null;
        ResultSet rs = null;

        try {
            String err = login(loginReq, webServiceName, "wareList", serviceType);
            if (err != null && err.length() > 0) {
                warehouseLocatorListResponse.setError(err);
                warehouseLocatorListResponse.setIsError(true);
                return warehouseLocatorListResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("wareList")) {
                warehouseLocatorListResponse.setIsError(true);
                warehouseLocatorListResponse.setError("Service type " + serviceType + " not configured");
                return warehouseLocatorListResponseDocument;
            }

            String sql = "SELECT \n" + "    w.m_warehouse_id as warehouseID,\n" + "    w.name as warehouseName,\n"
                    + " ml.isdefault,\n" + "    (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "     LEFT JOIN (\n"
                    + "         SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
                    + "         FROM adempiere.M_StorageOnHand\n" + "         GROUP BY M_Locator_ID\n"
                    + "     ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
                    + "     WHERE l.m_warehouse_id = w.m_warehouse_id\n"
                    + "     AND COALESCE(ms.TotalQty, 0) = 0) AS emptyCount,\n"
                    + "    (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS total_count,\n"
                    + "    lt.name AS locator_type,\n" + "    ml.value AS location_values,\n"
                    + "    ((SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) - \n"
                    + "     (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "      LEFT JOIN (\n"
                    + "          SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
                    + "          FROM adempiere.M_StorageOnHand\n" + "          GROUP BY M_Locator_ID\n"
                    + "      ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
                    + "      WHERE l.m_warehouse_id = w.m_warehouse_id\n" + "      AND COALESCE(ms.TotalQty, 0) = 0) \n"
                    + "    ) * 100 / (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS occupancy_percentage\n"
                    + "FROM \n" + "    adempiere.m_warehouse w\n" + "JOIN \n"
                    + "    adempiere.m_locator ml ON ml.m_warehouse_id = w.m_warehouse_id\n" + "JOIN \n"
                    + "    adempiere.m_locatortype lt ON ml.m_locatortype_id = lt.m_locatortype_id\n" + "WHERE \n"
                    + "    ml.ad_client_id = " + ad_client_id + "\n" + "GROUP BY \n"
                    + "    w.m_warehouse_id, w.name, lt.name,ml.value,ml.isdefault;";
            pstm = DB.prepareStatement(sql.toString(), null);
            rs = pstm.executeQuery();

            List<Integer> warehouseIds = new ArrayList<>();

            while (rs.next()) {
                int warehouseId = rs.getInt("warehouseID");
                String warehouseName = rs.getString("warehouseName");
                int occupancyPercents = rs.getInt("occupancy_percentage");
                String locatorType = rs.getString("locator_type");
                String locatorName = rs.getString("location_values");

                if (!warehouseIds.contains(warehouseId)) {
                    WarehouseListAccess warehouseListAccess = warehouseLocatorListResponse.addNewWarehouseListAccess();
                    warehouseListAccess.setWarehouseId(warehouseId);
                    warehouseListAccess.setWarehouseName(warehouseName);
                    warehouseListAccess.setOccupancyPercentage(occupancyPercents);

                    LocationType locationType = warehouseListAccess.addNewLocations();
                    locationType.setLocatorTypeName(locatorType);

                    Locators locators = locationType.addNewLocators();
                    locators.setLocatorName(locatorName);
                    locators.setIsOccupied(false);
                    warehouseIds.add(warehouseId);
                } else {
                    WarehouseListAccess[] warehouseListAccessArray = warehouseLocatorListResponse
                            .getWarehouseListAccessArray();
                    for (WarehouseListAccess wLAcess : warehouseListAccessArray) {
                        if (wLAcess.getWarehouseId() == warehouseId) {
                            boolean flag = false;
                            LocationType[] LocationsArray = wLAcess.getLocationsArray();
                            for (LocationType lType : LocationsArray) {
                                if (lType.getLocatorTypeName().equals(locatorType)) {
                                    Locators locators = lType.addNewLocators();
                                    locators.setLocatorName(locatorName);
                                    locators.setIsOccupied(true);
                                    flag = true;
                                    break;
                                }
                            }
                            if (flag == false) {
                                LocationType locationType = wLAcess.addNewLocations();
                                locationType.setLocatorTypeName(locatorType);
                                Locators locators = locationType.addNewLocators();
                                locators.setLocatorName(locatorName);
                                locators.setIsOccupied(false);
                            }
                            break;
                        }
                    }
                }
            }

        } catch (Exception e) {
            warehouseLocatorListResponse.setError(e.getLocalizedMessage());
            warehouseLocatorListResponse.setIsError(true);
            return warehouseLocatorListResponseDocument;
        } finally {
            closeDbCon(pstm, rs);
            getCompiereService().disconnect();
        }
        return warehouseLocatorListResponseDocument;
    }



    ================================================    

    String sql = "SELECT \n" + "    w.m_warehouse_id as warehouseID,\n" + "    w.name as warehouseName,\n"
                    + " ml.isdefault,\n" + "    (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "     LEFT JOIN (\n"
                    + "         SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
                    + "         FROM adempiere.M_StorageOnHand\n" + "         GROUP BY M_Locator_ID\n"
                    + "     ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
                    + "     WHERE l.m_warehouse_id = w.m_warehouse_id\n"
                    + "     AND COALESCE(ms.TotalQty, 0) = 0) AS emptyCount,\n"
                    + "    (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS total_count,\n"
                    + "    lt.name AS locator_type,\n" + "    ml.value AS location_values,\n"
                    + "    ((SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) - \n"
                    + "     (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "      LEFT JOIN (\n"
                    + "          SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
                    + "          FROM adempiere.M_StorageOnHand\n" + "          GROUP BY M_Locator_ID\n"
                    + "      ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
                    + "      WHERE l.m_warehouse_id = w.m_warehouse_id\n" + "      AND COALESCE(ms.TotalQty, 0) = 0) \n"
                    + "    ) * 100 / (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS occupancy_percentage\n"
                    + "FROM \n" + "    adempiere.m_warehouse w\n" + "JOIN \n"
                    + "    adempiere.m_locator ml ON ml.m_warehouse_id = w.m_warehouse_id\n" + "JOIN \n"
                    + "    adempiere.m_locatortype lt ON ml.m_locatortype_id = lt.m_locatortype_id\n" + "WHERE \n"
                    + "    ml.ad_client_id = " + ad_client_id + "\n" + "GROUP BY \n"
                    + "    w.m_warehouse_id, w.name, lt.name,ml.value,ml.isdefault;";


==================================================================================================
Medium Technician:-
SELECT ml.TC_MediaLine_id,md.name As mediaType, mel.c_uuid AS mediaLabelUUId, mel.tc_mediaLabelQr_id, DATE(mel.updated),count(*) AS count,
SUM(COUNT(*)) OVER () AS total_labels   
FROM adempiere.TC_MediaLine ml
JOIN adempiere.tc_mediaLabelQr mel ON mel.TC_MediaLine_id = ml.TC_MediaLine_id
JOIN adempiere.tc_mediatype md ON md.tc_mediatype_id = mel.tc_mediatype_id
WHERE ml.ad_client_id = 1000000 AND mel.isdiscarded = 'N'
AND DATE(mel.updated) <= CURRENT_DATE - INTERVAL '21 days'
AND (SELECT COUNT(*) FROM adempiere.TC_MediaOutLine mol WHERE mol.TC_MediaLine_id = ml.TC_MediaLine_id LIMIT 1) = 0
GROUP BY ml.TC_MediaLine_id, md.name, mel.c_uuid, mel.tc_mediaLabelQr_id, DATE(mel.updated) Limit 1;

Details Api:-
SELECT ml.tc_mediaorder_id As mediaOrderId,ml.TC_MediaLine_id,md.name As mediaType, mel.c_uuid AS mediaLabelUUId, mel.tc_mediaLabelQr_id, DATE(mel.updated),ml.quantity As quantity
FROM adempiere.TC_MediaLine ml
JOIN adempiere.tc_mediaLabelQr mel ON mel.TC_MediaLine_id = ml.TC_MediaLine_id
JOIN adempiere.tc_mediatype md ON md.tc_mediatype_id = mel.tc_mediatype_id
WHERE ml.ad_client_id = 1000000 AND mel.isdiscarded = 'N'
AND DATE(mel.updated) <= CURRENT_DATE - INTERVAL '21 days'
AND (SELECT COUNT(*) FROM adempiere.TC_MediaOutLine mol WHERE mol.TC_MediaLine_id = ml.TC_MediaLine_id LIMIT 1) = 0
GROUP BY ml.TC_MediaLine_id, md.name, mel.c_uuid, mel.tc_mediaLabelQr_id, DATE(mel.updated);



TechnicianWise Discard Report:-
SELECT cl.tc_cultureLabel_id AS id,cl.c_uuid AS uuid,cl.updated AS Date,cl.updatedby AS techID,u.name AS technician,
cl.personalCode2 AS personalCode,cl.discarddate AS discardDate,cs.name As stage,dt.name As discardReason FROM adempiere.tc_cultureLabel cl
JOIN adempiere.ad_user u ON u.ad_user_id = cl.updatedby
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_discardtype dt ON dt.tc_discardtype_id = cl.tc_discardtype_id
WHERE cl.AD_Client_Id = 1000002 AND cl.updated >= '05/01/2024'   
AND cl.updated <  ('05/11/2024'::timestamp + INTERVAL '1 day') 
AND cl.personalCode2 is not null  AND isdiscarded = 'Y' ORDER BY u.name,cl.tc_cultureLabel_id;

User Management Report:-
SELECT users, userId, personalCode, date,orderId, id, labelName,discarded,countValue,counts
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Tissue Culture Technician' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = 1000002 AND cl.isdiscarded = 'N' AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_mediaorder_id As orderID,cl.tc_medialabelQr_id AS id,'Medium technician' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_mediaorder_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_mediaorder_id,u.name) AS counts FROM adempiere.tc_medialabelQr cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_medialine o ON o.tc_medialine_id = cl.tc_medialine_id
WHERE cl.AD_CLIENT_ID = 1000002 AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.updatedby AS userId,u.personalcode AS personalCode,Date(cl.updated) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Quality Checker' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.updatedby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = 1000002 AND cl.isdiscarded = 'Y' AND u.personalcode is not null 
) AS combined WHERE combined.date >= '01/01/2024' AND combined.date < ('05/11/2024'::timestamp + INTERVAL '1 day') 
AND ($P{Label} IS NULL OR combined.labelName = $P{Label}) ORDER BY users,date,orderId;

User Management Report:-
SELECT users, userId, personalCode, date,orderId, id, labelName,discarded,countValue,counts
FROM (
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Tissue Culture Technician' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = 1000002 AND cl.isdiscarded = 'N' AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.createdby AS userId,u.personalcode AS personalCode,Date(cl.created) AS date,
o.tc_mediaorder_id As orderID,cl.tc_medialabelQr_id AS id,'Medium Technician' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_mediaorder_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_mediaorder_id,u.name) AS counts FROM adempiere.tc_medialabelQr cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.createdby JOIN adempiere.tc_medialine o ON o.tc_medialine_id = cl.tc_medialine_id
WHERE cl.AD_CLIENT_ID = 1000002 AND u.personalcode is not null
UNION ALL
SELECT u.name AS users,cl.updatedby AS userId,u.personalcode AS personalCode,Date(cl.updated) AS date,
o.tc_order_id As orderID,cl.tc_culturelabel_id AS id,'Quality Checker' AS labelName,cl.isdiscarded As discarded,
CAST(COUNT(*) OVER (PARTITION BY DATE(cl.created), o.tc_order_id,u.name) AS NUMERIC) AS countValue,COUNT(*) OVER (PARTITION BY cl.created, o.tc_order_id,u.name) AS counts FROM adempiere.tc_culturelabel cl 
JOIN adempiere.ad_user u ON u.ad_user_id = cl.updatedby JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
WHERE cl.AD_CLIENT_ID = 1000002 AND cl.isdiscarded = 'Y' AND u.personalcode is not null 
) AS combined WHERE combined.date >= '01/01/2024' AND combined.date < ('05/11/2024'::timestamp + INTERVAL '1 day') 
AND ($P{Label} IS NULL OR combined.labelName = $P{Label}) 
    ORDER BY users,date,orderId;



=========================================================================

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'c_invoice';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.c_invoice'::regclass;    


=========================================================================

CREATE TABLE adempiere.p_testing (
    p_testing_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    p_testing_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,value varchar(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    C_Country_ID NUMERIC(10,0),
    C_Region_ID NUMERIC(10,0),
    C_City_ID NUMERIC(10,0),
    FOREIGN KEY (C_Country_ID) REFERENCES adempiere.C_Country(C_Country_ID),
    FOREIGN KEY (C_Region_ID) REFERENCES adempiere.C_Region(C_Region_ID),
    FOREIGN KEY (C_City_ID) REFERENCES adempiere.C_City(C_City_ID)
    );    

===============================================================================
CREATE OR REPLACE VIEW adempiere.pi_productlabelViewNew AS 
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pp.m_locator_id,
Date(pp.updated) AS Date,SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,pr.weight AS unitWeight,
pr.weight * SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS totalUnitWeight,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
WHERE NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY pp.m_product_id,Date(pp.updated),pr.weight,w.m_warehouse_id,uom.name,pp.ad_client_id,pp.ad_org_id, 
pp.m_locator_id,pr.m_product_category_id Order BY Date(pp.updated) desc;


====================================================================================

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
========================================================================================================================

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


============================================================================================================================
Window field set any default value in idempiere:-
int recordId = get_ID();
        MProduct_Custom pro = new MProduct_Custom(p_ctx, recordId, get_TrxName());
        
        Object boxQtyObj = pro.get_Value("BoxQnty");
        int boxQtys = 0;
        if (boxQtyObj instanceof BigDecimal) {
            boxQtys = ((BigDecimal) boxQtyObj).intValue();
        } else if (boxQtyObj instanceof Integer) {
            boxQtys = (Integer) boxQtyObj;
        }
        if (boxQtys < 0) {
            boxQtys = 0;
        }
        pro.set_ValueOfColumn("BoxQnty", boxQtys);

============================================================================================================================
SELECT m_locator_id,SUM(qtyonhand) AS total_qty
FROM adempiere.m_storageonhand WHERE ad_client_id = 1000000
GROUP BY m_locator_id HAVING SUM(qtyonhand) <> 0 ORDER BY m_locator_id;

SELECT l.m_locator_id,l.value AS locator_name,COALESCE(SUM(s.qtyonhand), 0) AS total_qty
FROM adempiere.m_locator l
LEFT JOIN adempiere.m_storageonhand s ON l.m_locator_id = s.m_locator_id
WHERE l.ad_client_id = 1000000 GROUP BY l.m_locator_id, l.value
HAVING COALESCE(SUM(s.qtyonhand), 0) = 0 ORDER BY l.m_locator_id;

SELECT l.m_locator_id,l.value AS locator_name,COALESCE(SUM(s.quantity), 0) AS total_qty
FROM adempiere.m_locator l
LEFT JOIN adempiere.pi_productlabel s ON l.m_locator_id = s.m_locator_id 
WHERE l.ad_client_id = 1000000 GROUP BY l.m_locator_id, l.value
HAVING COALESCE(SUM(s.quantity), 0) = 0 ORDER BY l.m_locator_id;


===================================================================================================================================
Stonex Filed Config Condition:-
SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.reporttitle AS report_title,pr.status AS report_status,
adrep.binarydata AS report_binarydata,prt.pi_report_task_ID AS task_id,pr.createdby,prt.name AS task_title,
prt.description AS task_description,prt.status AS task_status,prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,
prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,
prsf.inspection AS inspection,prsf.comments AS field_comments,prsf.config AS field_config,prsf.pi_report_subtask_field_ID AS field_id,
prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,prsf.helptext AS field_help,
prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name
FROM adempiere.pi_report pr
JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID
JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID
JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID
LEFT JOIN adempiere.ad_attachment adrep ON adrep.ad_table_id = 1000016 AND adrep.record_id = pr.pi_report_id
WHERE pr.pi_report_id = 1000007
  AND (
    -- condition 1: answerText exists and is not empty
    (prsf.config::jsonb ->> 'answerText') IS NOT NULL
    AND (prsf.config::jsonb ->> 'answerText') <> ''
    
    OR
    
    -- condition 2: at least one option selected=true
    EXISTS (
      SELECT 1 FROM jsonb_array_elements(prsf.config::jsonb -> 'options') AS opt
      WHERE (opt ->> 'selected')::boolean = true
    )
  )
ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;
=======================================================================================================================================