select * from adempiere.pi_productlabel where labeluuid = 'e1442d49-1ea9-44a2-93b6-1b3b62e9236e';

Show the all columns :-

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'pi_productlabel'
ORDER BY ordinal_position;

Show last records id:-

SELECT MAX(pi_productlabel_id) AS last_id
FROM adempiere.pi_productlabel;

Added new records :-

INSERT INTO adempiere.pi_productlabel (
pi_productlabel_id,ad_client_id,ad_org_id,created,createdby,updated,updatedby,qcpassed,quantity,m_product_id,m_locator_id,
m_inoutline_id,issotrx,isactive,labeluuid,finaldispatch,reserved,sales_return,isrestricted,actualqty)
VALUES (
1082795,1000000,1000000,NOW(),1000012,NOW(),1000012,'Y',46,1000523,1001066,1049744,
'N','Y','a1442d49-1ea9-44a2-ab98-1b3b62e923cr','N','N','N','N',46);

Updated the locator data:-

UPDATE adempiere.pi_productlabel
SET m_locator_id = 1000512
WHERE labeluuid = 'e1442d49-1ea9-44a2-93b6-1b3b62e9236e';

UPDATE adempiere.pi_productlabel
SET m_locator_id = 1000512,finaldispatch = 'Y'
WHERE labeluuid = 'e1442d49-1ea9-44a2-93b6-1b3b62e9236e';

--------------------------------------------------------------------------------
Material Receipt Print option access process :-

Delivery Note / Shipment Print _Rpt M_InOut