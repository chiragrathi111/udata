-- 1. Reset InOut
UPDATE adempiere.m_inout 
SET docstatus = 'DR', docaction = 'CO', processed = 'N' 
WHERE ad_client_id = 1000002;

-----------------------------------------------------

-- 2. Delete Match PO
DELETE FROM adempiere.m_matchpo 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE ad_client_id = 1000002
);

-- 3. Delete Match Inv
DELETE FROM adempiere.m_matchinv 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE ad_client_id = 1000002
);

-- 4. Delete Transactions
DELETE FROM adempiere.m_transaction 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE ad_client_id = 1000002
);

-- 5. Delete InOutLine MA
DELETE FROM adempiere.m_inoutlinema 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE ad_client_id = 1000002
);

-- 6. Delete child table (pi_inventorydetail)
DELETE FROM adempiere.pi_inventorydetail
WHERE pi_productlabel_id IN (
    SELECT pi_productlabel_id 
    FROM adempiere.pi_productlabel 
    WHERE ad_client_id = 1000002
);

-- 7. Delete Product Labels
DELETE FROM adempiere.pi_productlabel 
WHERE ad_client_id = 1000002;

-----------------------------------------------------

-- 8. Delete Cost History
DELETE FROM adempiere.m_costhistory 
WHERE m_costdetail_id IN (
    SELECT cd.m_costdetail_id 
    FROM adempiere.m_costdetail cd
    JOIN adempiere.m_inoutline iol 
        ON cd.m_inoutline_id = iol.m_inoutline_id
    WHERE iol.ad_client_id = 1000002
);

-- 9. Delete Cost Detail
DELETE FROM adempiere.m_costdetail 
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id 
    FROM adempiere.m_inoutline 
    WHERE ad_client_id = 1000002
);

-----------------------------------------------------

-- 10. Remove RMA links
UPDATE adempiere.m_inoutline 
SET m_rmaline_id = NULL 
WHERE ad_client_id = 1000002;

-- 11. Delete RMA Lines
DELETE FROM adempiere.m_rmaline 
WHERE ad_client_id = 1000002;

-- 12. Remove RMA header link
UPDATE adempiere.m_inout 
SET m_rma_id = NULL 
WHERE ad_client_id = 1000002;

-- 13. Delete RMA Tax (IMPORTANT 🔥)
DELETE FROM adempiere.m_rmatax 
WHERE ad_client_id = 1000002;

-- 14. Delete RMA Header
DELETE FROM adempiere.m_rma 
WHERE ad_client_id = 1000002;

-----------------------------------------------------
-- 15. Delete Pack Lines

DELETE FROM adempiere.pi_qrrelations
WHERE minoutlineid IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE ad_client_id = 1000002
);

UPDATE adempiere.c_invoiceline
SET m_inoutline_id = NULL
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE ad_client_id = 1000002
);

DELETE FROM adempiere.c_invoiceline
WHERE m_inoutline_id IN (
    SELECT m_inoutline_id
    FROM adempiere.m_inoutline
    WHERE ad_client_id = 1000002
);

-----------------------------------------------------

-- 15. Delete InOut Lines
DELETE FROM adempiere.m_inoutline 
WHERE ad_client_id = 1000002;

-- 16. Delete InOut Header
DELETE FROM adempiere.m_inout 
WHERE ad_client_id = 1000002;

--------------------------------------------------------
--------------------------------------------------------
-- STEP 1: Reset Orders
UPDATE adempiere.c_order 
SET docstatus = 'DR', docaction = 'CO', processed = 'N' 
WHERE ad_client_id = 1000002;

-- STEP 2: Delete Cost History
DELETE FROM adempiere.m_costhistory 
WHERE m_costdetail_id IN (
    SELECT m_costdetail_id 
    FROM adempiere.m_costdetail 
    WHERE c_orderline_id IN (
        SELECT c_orderline_id 
        FROM adempiere.c_orderline 
        WHERE ad_client_id = 1000002
    )
);

-- STEP 3: Delete Cost Details
DELETE FROM adempiere.m_costdetail 
WHERE c_orderline_id IN (
    SELECT c_orderline_id 
    FROM adempiere.c_orderline 
    WHERE ad_client_id = 1000002
);

-- STEP 4: Delete Order Tax
DELETE FROM adempiere.c_ordertax 
WHERE c_order_id IN (
    SELECT c_order_id 
    FROM adempiere.c_order 
    WHERE ad_client_id = 1000002
);

UPDATE adempiere.c_invoiceline
SET c_orderline_id = NULL
WHERE c_orderline_id IN (
    SELECT c_orderline_id
    FROM adempiere.c_orderline
    WHERE ad_client_id = 1000002
);

DELETE FROM adempiere.c_invoiceline
WHERE c_orderline_id IN (
    SELECT c_orderline_id
    FROM adempiere.c_orderline
    WHERE ad_client_id = 1000002
);

-- STEP 6: Delete Order Lines
DELETE FROM adempiere.c_orderline 
WHERE ad_client_id = 1000002;

UPDATE adempiere.c_invoice
SET c_order_id = NULL
WHERE c_order_id IN (
    SELECT c_order_id
    FROM adempiere.c_order
    WHERE ad_client_id = 1000002
);

DELETE FROM adempiere.c_invoice
WHERE c_order_id IN (
    SELECT c_order_id
    FROM adempiere.c_order
    WHERE ad_client_id = 1000002
);

UPDATE adempiere.c_allocationline
SET c_order_id = NULL
WHERE c_order_id IN (
    SELECT c_order_id
    FROM adempiere.c_order
    WHERE ad_client_id = 1000002
);

DELETE FROM adempiere.c_allocationline
WHERE c_order_id IN (
    SELECT c_order_id
    FROM adempiere.c_order
    WHERE ad_client_id = 1000002
);

-- STEP 7: Delete Orders
DELETE FROM adempiere.c_order 
WHERE ad_client_id = 1000002;

-- Step 1: Delete transactions
DELETE FROM adempiere.m_transaction
WHERE ad_client_id = 1000002;

-- Step 2: Delete storage
DELETE FROM adempiere.m_storageonhand
WHERE ad_client_id = 1000002;

DELETE FROM adempiere.m_storagereservation
WHERE ad_client_id = 1000002;

DELETE FROM adempiere.m_attributeinstance
WHERE ad_client_id = 1000002;