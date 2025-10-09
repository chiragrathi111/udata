Product window have two changes:-
	UPC           => HsnSac
	M_PartType_ID => Type

ALTER TABLE adempiere.pi_productLabel 
ADD reason VARCHAR(25);

ALTER TABLE adempiere.PI_Deptartment 
ADD value VARCHAR(25);	

============================================================
Report for Replacement and ReIssue:-

SELECT l.pi_productLabel_id,TO_CHAR(l.created, 'DD/MM/YYYY') AS Date,l.created,u.ad_user_id,l.quantity,l.issotrx,
d.PI_Deptartment_id,d.value AS Departmemt,l.labeluuid,l.reason,pr.m_product_id,l.ad_client_id,l.ad_org_id 
FROM adempiere.pi_productLabel l
JOIN adempiere.m_product pr ON pr.m_product_id = l.m_product_id
JOIN adempiere.m_locator ll ON ll.m_locator_id = l.m_locator_id
JOIN adempiere.ad_user u ON u.ad_user_id = l.updatedby
LEFT JOIN adempiere.PI_Deptartment d ON d.PI_Deptartment_id = pr.PI_Deptartment_id
WHERE l.reason is not null AND (l.reason = 'Replacement' OR l.reason = 'ReIssue')
ORDER BY l.pi_productLabel_id,pr.m_product_id;
==================================================================