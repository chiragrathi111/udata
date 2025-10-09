Reporyt Replacement & ReIssue:-

CREATE OR REPLACE VIEW adempiere.pi_productlabelview_reason_replacement AS
SELECT pr.name AS product_name,pr.m_product_id,l.m_locator_id,u.name AS supervisor,
d.value AS department,TO_CHAR(p.updated::date, 'DD-MM-YYYY') AS date,p.updated,p.reason,p.quantity,p.labeluuid,p.ad_client_id,p.ad_org_id 
FROM adempiere.pi_productlabel p JOIN adempiere.m_locator l ON l.m_locator_id = p.m_locator_id
JOIN adempiere.m_product pr ON pr.m_product_id = p.m_product_id
JOIN adempiere.PI_Deptartment d ON d.PI_Deptartment_id = pr.PI_Deptartment_id
JOIN adempiere.ad_user u ON u.ad_user_id = p.updatedby
WHERE p.reason IS NOT NULL 
AND p.reason <> 'LabelArrange';

===================================================================================
External Report:-
SELECT TO_CHAR(r.updated::date, 'DD-MM-YYYY') AS date,u.ad_user_id,r.updated::date AS dates,rl.qtytotal AS QTY,
rl.qtyissued AS qtyissue,rl.qtytotal - rl.qtyissued AS Credit_note,r.status AS return_status,r.c_bpartner_id,
p.name AS product_name,p.m_product_id,
p.PI_Deptartment_id,d.value AS department_name,u.name AS user_name,pa.name AS bpartner_name FROM adempiere.pi_return r
JOIN adempiere.pi_returnline rl ON rl.pi_return_id = r.pi_return_id
JOIN adempiere.c_bpartner pa ON pa.c_bpartner_id = r.c_bpartner_id
JOIN adempiere.m_product p ON p.m_product_id = rl.m_product_id
JOIN adempiere.ad_user u ON u.ad_user_id = r.updatedby
JOIN adempiere.PI_Deptartment d ON d.PI_Deptartment_id = p.PI_Deptartment_id
WHERE r.AD_Client_ID = $P{AD_CLIENT_ID} AND r.updated >= $P{FromDate} 
AND r.updated < ($P{ToDate}::timestamp + INTERVAL '1 day')
AND ($P{CustomerId}  IS NULL OR pa.c_bpartner_id IN ($P!{CustomerId}))
AND ( $P{DepartmentId}  IS NULL OR d.PI_Deptartment_id IN ($P!{DepartmentId}))
AND ($P{UserId} IS NULL OR u.ad_user_id IN ($P!{UserId}))
AND ($P{ProductId} IS NULL OR p.m_product_id IN ($P!{ProductId}));

===================================================================================
CREATE OR REPLACE VIEW adempiere.pi_returnreport AS
SELECT TO_CHAR(r.updated::date, 'DD-MM-YYYY') AS date,u.ad_user_id,r.updated::date AS dates,rl.qtytotal AS QTY,
rl.qtyissued AS replacementQty,rl.qtytotal - rl.qtyissued AS Credit_note,r.status AS return_status,r.c_bpartner_id,
p.name AS product_name,p.m_product_id,
p.PI_Deptartment_id,d.value AS department,u.name AS user_name,pa.name AS bpartner_name 
FROM adempiere.pi_return r 
JOIN adempiere.pi_returnline rl ON rl.pi_return_id = r.pi_return_id
JOIN adempiere.c_bpartner pa ON pa.c_bpartner_id = r.c_bpartner_id
JOIN adempiere.m_product p ON p.m_product_id = rl.m_product_id
JOIN adempiere.PI_Deptartment d ON d.PI_Deptartment_id = p.PI_Deptartment_id
JOIN adempiere.ad_user u ON u.ad_user_id = r.updatedby;

===================================================================================
Working and using Report view:-
CREATE OR REPLACE VIEW adempiere.pi_returnreportnew AS
SELECT 
    TO_CHAR(r.updated::date, 'DD-MM-YYYY') AS date,
    u.ad_user_id,
    r.updated::date AS dates,
    rl.qtytotal AS qty,
    rl.qtyissued AS replacementqty,
    rl.qtytotal - rl.qtyissued AS credit_note,
    r.status AS return_status,
    r.c_bpartner_id,
    p.name AS product_name,
    p.m_product_id,
    r.ad_client_id,
    r.ad_org_id,
    p.pi_deptartment_id,
    d.value AS department,
    u.name AS user_name,
    pa.name AS bpartner_name
FROM adempiere.pi_return r
JOIN adempiere.pi_returnline rl ON rl.pi_return_id = r.pi_return_id
JOIN adempiere.c_bpartner pa ON pa.c_bpartner_id = r.c_bpartner_id
JOIN adempiere.m_product p ON p.m_product_id = rl.m_product_id
JOIN adempiere.pi_deptartment d ON d.pi_deptartment_id = p.pi_deptartment_id
JOIN adempiere.ad_user u ON u.ad_user_id = r.updatedby
ORDER BY department, user_name, bpartner_name, date, product_name;

===================================================================================



===================================================================================



===================================================================================
