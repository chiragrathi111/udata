idempiere documentation


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          warepro name dynamic:-
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 In system_configurator
  1. for name change in login page and browser tittle
      name: ZK_BROWSER_TITLE
      Configured Value: WarePro
  
  2. for browser icon
      name: ZK_BROWSER_ICON
      Configured Value: ~./theme/default/images/icon.png  (added images path in Eclipse /org.adempiere.ui.zk/WEB-INF/src/web/theme/default/images)

  3. for icon which is same as 5th one, but will used in diff locations
      name: ZK_LOGIN_ICON
      Configured Value: /images/warepro-logo.svg

  4. for app description:
      name: ZK_APP_DESCRIPTION
      Configured Value: WarePro is a large commericial building used for<br></br> the storage of goods materials



-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Traceabilty wdiget:
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
 1. Received
   -- who created MR is Received user
   
 2. qcaccepted
   -- who marked mr as qc completed
 
 3. stored
   -- who completed MR doc action is stored user

 4. Picked
   -- who created customer shipment is picked user
 
 5. dispatched
   -- who completed customer shipment


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create view for ExpiringProducts_V
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
   CREATE OR REPLACE VIEW adempiere.ExpiringProducts_V (ExpiringProducts_V_ID) AS
SELECT
    ROW_NUMBER() OVER () AS ExpiringProducts_V_ID,
    a.ad_client_id,
    a.ad_org_id,
    a.created,
    a.createdby,
    a.updated,
    a.updatedby,
    a.expirydate,
    e.qtyonhand AS ExpiryQTY,
    wh.m_warehouse_id,
    a.m_product_id,
  mp.name as productName,
    wh.value AS WarehouseName,
    CASE
        WHEN a.expirydate <= CURRENT_DATE + INTERVAL '30 days' THEN '0-30 days'
        WHEN a.expirydate <= CURRENT_DATE + INTERVAL '60 days' THEN '31-60 days'
        WHEN a.expirydate <= CURRENT_DATE + INTERVAL '90 days' THEN '61-90 days'
        WHEN a.expirydate <= CURRENT_DATE + INTERVAL '120 days' THEN '91-120 days'
        ELSE 'More than 120 days'
    END AS DayCount
FROM
    adempiere.c_orderline a
JOIN
    adempiere.m_storageonhand e ON a.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN
    adempiere.m_warehouse wh ON wh.m_warehouse_id = a.m_warehouse_id
JOIN
    adempiere.m_product mp ON mp.m_product_id = a.m_product_id
WHERE
    a.m_attributesetinstance_id != 0
-- AND a.expirydate <= CURRENT_DATE
-- AND a.expirydate <= (CURRENT_DATE - INTERVAL '4 months')
GROUP BY
    wh.value,mp.name, a.ad_client_id, a.ad_org_id, a.created, a.m_product_id, a.createdby, a.updated, a.updatedby, a.expirydate, wh.m_warehouse_id, e.qtyonhand;



-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
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



-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to Alter table for m_inout to mark MR qc completed
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ALTER TABLE adempiere.m_inout ADD COLUMN pickStatus VARCHAR(255);

/**Currently not using**/--->ALTER TABLE adempiere.c_order ADD COLUMN putStatus VARCHAR(255);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                     generate Qr in locator tab
---------------------------------------------------------------------------------------------------------------------------------------------------------------

 generate Qr in locator tab


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to Alter table for c_orderline
---------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE adempiere.C_Orderline ADD COLUMN ExpiryDate DATE;

ALTER TABLE adempiere.C_Orderline ADD COLUMN BatchDate DATE;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Date Format (dd/MM/yyyy) and By default country name show India for Addresss
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Login System and go to language window 
search record (English (India))
date Pattern - dd/MM/yyyy
System Language and Login Locale check box selected

search record (English)
date Pattern - dd/MM/yyyy

Go to tenant login and search tenant
Language - English (India) 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Added Expiry and near Expiry Product details Report
---------------------------------------------------------------------------------------------------------------------------------------------------------------
Expiry Product Details View:-

CREATE VIEW adempiere.ExpiryProductDetails AS
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
  WHERE f.issotrx = 'N' AND a.expirydate < CURRENT_DATE;
  
 1. login system and go to table and column window
    create new records and fill Mandatory  field
    DB Table Name - ExpiryProductDetails
    name - ExpiryProductDetails
    Data Access Lavel - Client+Organization
    select view and Show In Drill Options check box and save
    
    there in top press Setting button and select create column from DB
    
 2. Go to Report View window in search bar
    create new records and fill Mandatory  field
    Name - ExpiryProductDetails
    Entity Type - Dictionary
    Table - choose table name
    and Save
    
 3. Go to Report & Process window in search bar 
    create new records and fill Mandatory  field
    Name - Expiry Product Details
    Entity Type - Dictionary
    Data Access Lavel - Client+Organization
    Select View Check box
    Report View - select report view
    and save
    
 4. Go to Menu window in search bar
    create new records and fill Mandatory  field
    Name - Expiry Product Details
    Entity Type - Dictionary
    Action - report
    Process - select process
    unSelect Sales transaction and Save 
  
  
Near Expiry Product List View:-  

CREATE VIEW adempiere.NearExpiryProductLists
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
  WHERE f.issotrx = 'N' AND a.expirydate >= CURRENT_DATE;





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Sales Report using Jasper Report
---------------------------------------------------------------------------------------------------------------------------------------------------------------
1. Party Wise Sales Report :-

    Go to Report & Process window in search bar 
    create new records and fill Mandatory  field
    Name - Party Wise Sales Report
    Entity Type - Dictionary
    Data Access Lavel - Client+Organization
    classname - org.adempiere.report.jasper.ReportStarter
    Jasper Report - attachment:bPartnerWiseSalesReport.jrxml 
    and save
    there in top press Attachment Button and added jrxml file
    
    There in Bottom press Parameter Tab and create new Records fill mandatory field
    
        Name - FromDate
        Entity Type - Dictionary
        DB Column name  - FromDate
        SystemElement - dataInvoiced
        Reference - Date
        Dafault Logic - @SQL=SELECT created FROM adempiere.c_invoice WHERE issotrx='Y' AND AD_CLIENT_ID =@#AD_Client_ID@ limit 1
        and Save
        
        Name - ToDate
        Entity Type - Dictionary
        DB Column name  - ToDate
        SystemElement - dataInvoiced
        Reference - Date
        Dafault Logic - @#Date@
        and Save
        
        Name - Business Partner
        Entity Type - Dictionary
        DB Column name  - BPartnerId
        SystemElement - bpartner_iscustomer
        Reference - Chosen Multiple Selection Table
        Reference Key - C_BPartner Customers
        and Save
        
        same added three another Report
        
 2. Party Wise Detailed Sales Report
 
 3. Sales Rep Wise Sales Report 
 
 4. Sales & Stock Analysis
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------






-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                          Query to create table for pi_qrRelations to store pallete data
---------------------------------------------------------------------------------------------------------------------------------------------------------------