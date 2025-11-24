C_Invoice :-

UPDATE adempiere.c_invoice
SET docstatus = 'DR',
    docaction = 'CO',
    processed = 'N'
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

DELETE FROM adempiere.c_invoiceline
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

DELETE FROM adempiere.c_allocationline
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

DELETE FROM adempiere.c_invoicetax
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

UPDATE adempiere.c_invoice
SET c_payment_id = NULL
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

DELETE FROM adempiere.c_payment
WHERE c_invoice_id IN (1000032, 1000031, 1000029);

DELETE FROM adempiere.c_invoice
WHERE c_invoice_id IN (1000032, 1000031, 1000029);


--------------------------------------------------
M_Inout:-

UPDATE adempiere.m_inout
SET docstatus = 'DR',
    docaction = 'CO',
    processed = 'N'
WHERE m_inout_id = 1000034;

DELETE FROM adempiere.m_transaction
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000034
);

DELETE FROM adempiere.m_inoutlinema
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE m_inout_id = 1000034
);

DELETE FROM adempiere.m_inoutline
WHERE m_inout_id = 1000034;


DELETE FROM adempiere.m_inout
WHERE m_inout_id = 1000034;


------------------------------------------------------
C_Order:-

UPDATE adempiere.c_order
SET docstatus = 'DR',
    docaction = 'CO',
    processed = 'N'
WHERE c_order_id IN (1000030, 1000032);

DELETE FROM adempiere.c_orderline
WHERE c_order_id IN (1000030, 1000032);

DELETE FROM adempiere.c_ordertax
WHERE c_order_id IN (1000030, 1000032);

DELETE FROM adempiere.c_order
WHERE c_order_id IN (1000030, 1000032);
