UPDATE adempiere.m_inout 
SET docstatus = 'DR', docaction = 'CO', processed = 'N' 
WHERE m_inout_id = 1001661;

DELETE FROM adempiere.m_matchpo 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

DELETE FROM adempiere.m_matchinv 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

DELETE FROM adempiere.m_transaction 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

DELETE FROM adempiere.m_inoutlinema 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

DELETE FROM adempiere.pi_productlabel 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

DELETE FROM adempiere.m_costhistory 
WHERE m_costdetail_id IN (
    SELECT cd.m_costdetail_id 
    FROM adempiere.m_costdetail cd
    JOIN adempiere.m_inoutline iol ON cd.m_inoutline_id = iol.m_inoutline_id
    WHERE iol.m_inout_id = 1001661
);

DELETE FROM adempiere.m_costdetail 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

UPDATE adempiere.m_inoutline 
SET m_rmaline_id = NULL 
WHERE m_rmaline_id IN (
    SELECT rma.m_rmaline_id 
    FROM adempiere.m_rmaline rma
    JOIN adempiere.m_inoutline iol ON rma.m_inoutline_id = iol.m_inoutline_id
    WHERE iol.m_inout_id = 1001661
);

DELETE FROM adempiere.m_rmaline 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE m_inout_id = 1001661
);

-- DELETE FROM adempiere.m_rmatax 
-- WHERE m_rma_id IN (
--     SELECT m_rma_id 
--     FROM adempiere.m_rma 
--     WHERE m_inout_id = 1001661
-- );

UPDATE adempiere.m_inout 
SET m_rma_id = NULL 
WHERE m_rma_id IN (
    SELECT m_rma_id 
    FROM adempiere.m_rma 
    WHERE m_inout_id = 1001661
)
AND m_inout_id = 1001661

-- DELETE FROM adempiere.m_rma 
-- WHERE m_inout_id = 1001661;

DELETE FROM adempiere.m_packline
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1010540
);

DELETE FROM adempiere.m_inoutline 
WHERE m_inout_id = 1001661;

DELETE FROM adempiere.m_inout 
WHERE m_inout_id = 1001661;