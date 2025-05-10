 Create Table:-
 CREATE TABLE adempiere.p_employer (
    p_employer_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    p_employer_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    name VARCHAR(25) NOT NULL,value varchar(25) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() not null,
    createdby numeric(10,0) not null,
    updated TIMESTAMP without time zone DEFAULT now() not null,
    updatedby NUMERIC(10,0) not null,
    description VARCHAR(255),
    isactive CHAR(1) not null DEFAULT 'Y'::bpchar,
    isdefault CHAR(1) NOT NULL DEFAULT 'N'::bpchar,
	villageName VARCHAR(25),
    block VARCHAR(20),
    District VARCHAR(10),
    City VARCHAR(20),
    State VARCHAR(20),
    pinCode VARCHAR(6),
    mobileNo VARCHAR(10)
	);

Alter Table:-
Alter table adempiere.p_employer
Add column Role VARCHAR(20);

ALTER TABLE adempiere.p_employer
ADD COLUMN ad_image_id NUMERIC(10,0);

ALTER TABLE adempiere.p_employer
ADD CONSTRAINT p_employer_ad_image_id_fkey
FOREIGN KEY (ad_image_id)
REFERENCES adempiere.ad_image(ad_image_id);   

Create Table View:-
CREATE OR REPLACE VIEW adempiere.pv_employerView AS
SELECT p_employer_id AS Id,name AS Name,mobileNo AS MobileNo,villageName AS VillageName,block AS Block,City AS City,District AS District,
State AS State,pincode AS PinCode,ad_client_id AS ad_client_id,ad_org_id AS ad_org_id,created AS Date FROM adempiere.p_employer;




net.sf.jasperreports.engine.util.JRImageLoader.getInstance(new SimpleJasperReportsContext()).loadAwtImageFromBytes(javax.xml.bind.DatatypeConverter.parseBase64Binary($F{image_binarydata}))



select iv.c_invoice_id, iv.documentno as Invoice_No, to_char(iv.DateInvoiced, 'DD-Mon-YYYY') as Date_Invoiced, org.name as OrgName, org_loc.address as org_address, org_loc.city as org_city, org_loc.regionname as org_regionname,
org_loc.countryname as org_countryname, org_loc.postal as org_postal, bp_loc.address as bp_address, bp_loc.city as bp_city, bp_loc.regionname as bp_regionname,
bp_loc.countryname as bp_countryname, bp_loc.postal as bp_postal,ivl.description,
(case when ivl.m_product_id>0 then mp.name else cha.name end) as item,
iv.totallines as SubTotal, iv.grandtotal as Total_Amount, (iv.grandtotal-iv.totallines) as Tax_Amount,
ivl.line as Product_SNo, mp.name as Product_Name, ivl.qtyinvoiced as Product_Qty_Invoiced, round(ivl.priceentered,2) as Product_Price_Entered,
cr.iso_code as Product_Currency_Name, tax.name as Product_Tax_Name, tax.rate as Product_Tax_Rate, ivl.taxamt as Product_Tax_Amount, mp.hsncode as Product_HSN,
ivl.linenetamt as Product_Line_Amount, iv.description, iv.poreference, bp.name as customer_name,
fnNumberToWords(iv.grandtotal::BIGINT) as AmountInWord,
   cr.description as currency_name,
wh.name as wareName, ware_loc.address as ware_address, ware_loc.city as ware_city, ware_loc.regionname as ware_regionname, io.documentno as InOutNo, to_char(io.movementdate, 'DD-Mon-YYYY') as InOutDate,
ware_loc.countryname as ware_countryname, ware_loc.postal as ware_postal, orginfo.Phone,
cli.gstno client_gstno, cli.panno as client_panno, bp.gstno as bp_gstno, bp.panno as bp_panno, cr.cursymbol, encode(org_img.binarydata,'base64') as logo_binarydata, cli.Name as companyname
from adempiere.c_invoice iv
left join adempiere.c_invoiceline ivl on (iv.c_invoice_id=ivl.c_invoice_id)
left join adempiere.c_order cor On (cor.c_order_id = iv.c_order_id)  
left join adempiere.m_inout io on (cor.c_order_id=io.c_order_id)
left join adempiere.c_bpartner bp on (bp.c_bpartner_id=iv.c_bpartner_id)
left join adempiere.ad_org org on (org.AD_Org_ID=iv.AD_Org_ID)
left join adempiere.ad_orginfo orginfo on (orginfo.AD_Org_ID=iv.AD_Org_ID)
left join adempiere.ad_image org_img on (orginfo.Logo_ID=org_img.ad_image_id)
left join adempiere.m_warehouse wh on (wh.m_warehouse_id=orginfo.m_warehouse_id)
left join adempiere.ad_client cli on (cli.ad_client_id=iv.ad_client_id)
left join adempiere.location_details ware_loc on (ware_loc.c_location_id=wh.c_location_id)
left join adempiere.location_details org_loc on (org_loc.c_location_id=orginfo.c_location_id)
left join adempiere.c_bpartner_location bpl on (bpl.c_bpartner_location_id=iv.c_bpartner_location_id)
left join adempiere.location_details bp_loc on (bp_loc.c_location_id=bpl.c_location_id)
left join adempiere.m_product mp on (mp.m_product_id=ivl.m_product_id)
left join adempiere.c_charge cha on (cha.c_charge_id=ivl.c_charge_id)
left join adempiere.c_uom uom on (uom.c_uom_id=ivl.c_uom_id)
left join adempiere.c_tax tax on (tax.c_tax_id=ivl.c_tax_id)
left join adempiere.c_currency cr on (cr.c_currency_id=iv.c_currency_id)
where (iv.C_Invoice_ID =  $P{C_Invoice_ID}  OR iv.C_Invoice_ID =  $P{Record_ID} ) AND iv.ad_client_id =  $P{AD_CLIENT_ID} 
Order by ivl.line




	