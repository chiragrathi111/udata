Modify PO record Dreft to completed:-

SELECT * FROM adempiere.c_order 
WHERE ad_client_id = 1000000 
AND issotrx = 'N' 
AND docstatus = 'DR' 
ORDER BY c_order_id DESC;


UPDATE adempiere.c_order
SET docstatus = 'CO',
    docaction = 'CL',
    processed = 'Y'
WHERE ad_client_id = 1000000
  AND issotrx = 'N'
  AND docstatus = 'DR';

---------------------------------------------------------------  