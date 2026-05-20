select * from adempiere.AD_Document_Action_Access
where ad_client_id = 1000000 
and ad_ref_list_id = 182
and C_DocType_ID IN (1000014,1000032,1000031);

UPDATE adempiere.AD_Document_Action_Access
SET IsActive = 'N',
    Updated = now()
WHERE ad_client_id = 1000000
  AND ad_ref_list_id = 182
  and C_DocType_ID IN (1000014,1000032,1000031);