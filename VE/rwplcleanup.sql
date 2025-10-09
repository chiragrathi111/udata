-- Reset the header record
UPDATE adempiere.m_inout
SET docstatus = 'DR',
    docaction = 'CO',
    processed = 'N'
WHERE m_inout_id = 1000616;

-- Delete related match PO lines
DELETE FROM adempiere.m_matchpo
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete related match inv lines
DELETE FROM adempiere.m_matchinv
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete related transactions
DELETE FROM adempiere.m_transaction
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete related inout line MA
DELETE FROM adempiere.m_inoutlinema
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete related pack lines
DELETE FROM adempiere.m_packline
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete related product labels
DELETE FROM adempiere.pi_productlabel
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000616
);

-- Delete inout lines
DELETE FROM adempiere.m_inoutline
WHERE m_inout_id = 1000616;

-- Delete inout header
DELETE FROM adempiere.m_inout
WHERE m_inout_id = 1000616;
