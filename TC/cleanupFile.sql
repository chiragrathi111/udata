SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'c_invoice';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.c_invoice'::regclass;  

select * from adempiere.c_invoice where c_invoice_id = 1000023    

Table name:-
adempiere.a_asset_addition
adempiere.a_asset_disposed
adempiere.c_allocationline
adempiere.c_bankstatementline
adempiere.c_cashline
adempiere.c_commissionrun
adempiere.c_dunningrunline
adempiere.c_invoicebatchline
adempiere.c_invoiceline
adempiere.c_invoicepayschedule
adempiere.c_invoicetax
adempiere.c_payment
adempiere.c_paymentallocate
adempiere.c_paymenttransaction
adempiere.c_payselectionline
adempiere.c_recurring
adempiere.c_recurring_run
adempiere.c_taxdeclarationline
adempiere.dd_order
adempiere.i_bankstatement
adempiere.i_invoice
adempiere.i_payment
adempiere.m_inout
adempiere.m_inoutconfirm
adempiere.m_shippingtransaction
adempiere.c_invoice         ref_invoice_id   X
adempiere.r_requestaction
adempiere.t_invoicegl
adempiere.r_request
adempiere.c_invoice         relatedinvoice_id   X
adempiere.c_invoice         reversal_id         X

Test on postgres and if not have any data enter X:-
select * from adempiere.c_invoice where c_invoice_id = 1000023 

select * from adempiere.c_allocationline where c_invoice_id = 1000023
select * from adempiere.c_invoiceline where c_invoice_id = 1000023
select * from adempiere.c_invoicetax where c_invoice_id = 1000023    
select * from adempiere.c_payment where c_invoice_id = 1000023

select * from adempiere.a_asset_addition where c_invoice_id = 1000023       X
select * from adempiere.a_asset_disposed where c_invoice_id = 1000023       X  
select * from adempiere.c_bankstatementline where c_invoice_id = 1000023    X 
select * from adempiere.c_cashline where c_invoice_id = 1000023             X
select * from adempiere.c_commissionrun where c_invoice_id = 1000023        X
select * from adempiere.c_dunningrunline where c_invoice_id = 1000023       X
select * from adempiere.c_invoicebatchline where c_invoice_id = 1000023     X   
select * from adempiere.c_invoicepayschedule where c_invoice_id = 1000023   X
select * from adempiere.c_paymentallocate where c_invoice_id = 1000023      X
select * from adempiere.c_paymenttransaction where c_invoice_id = 1000023   X
select * from adempiere.c_payselectionline where c_invoice_id = 1000023     X
select * from adempiere.c_recurring where c_invoice_id = 1000023            X
select * from adempiere.c_recurring_run where c_invoice_id = 1000023        X
select * from adempiere.c_taxdeclarationline where c_invoice_id = 1000023   X
select * from adempiere.dd_order where c_invoice_id = 1000023               X
select * from adempiere.i_bankstatement where c_invoice_id = 1000023        X
select * from adempiere.i_invoice where c_invoice_id = 1000023              X
select * from adempiere.i_payment where c_invoice_id = 1000023              X
select * from adempiere.m_inout where c_invoice_id = 1000023                X
select * from adempiere.m_inoutconfirm where c_invoice_id = 1000023         X
select * from adempiere.m_shippingtransaction where c_invoice_id = 1000023  X
select * from adempiere.r_requestaction where c_invoice_id = 1000023        X
select * from adempiere.t_invoicegl where c_invoice_id = 1000023            X
select * from adempiere.r_request where c_invoice_id = 1000023              X


=============================================================================================
invoiceline:-
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'c_invoiceline';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.c_invoiceline'::regclass; 

adempiere.i_invoice
adempiere.a_asset_addition
adempiere.a_asset_disposed
adempiere.a_asset_retirement
adempiere.c_commissiondetail
adempiere.c_invoicebatchline
adempiere.c_landedcost
adempiere.c_landedcostallocation
adempiere.c_revenuerecognition_plan
adempiere.c_taxdeclarationline
adempiere.m_inoutlineconfirm
adempiere.m_matchpo
adempiere.s_timeexpenseline
adempiere.m_matchinv
adempiere.c_invoiceline       ref_invoiceline_id null
adempiere.m_costdetail   

select * from adempiere.c_invoiceline where c_invoiceline_id = 1000026


select * from adempiere.i_invoice where c_invoiceline_id = 1000026                  X
select * from adempiere.a_asset_addition where c_invoiceline_id = 1000026           X
select * from adempiere.a_asset_disposed where c_invoiceline_id = 1000026           X
select * from adempiere.a_asset_retirement where c_invoiceline_id = 1000026         X
select * from adempiere.c_commissiondetail where c_invoiceline_id = 1000026         X
select * from adempiere.c_invoicebatchline where c_invoiceline_id = 1000026         X
select * from adempiere.c_landedcost where c_invoiceline_id = 1000026               X
select * from adempiere.c_landedcostallocation where c_invoiceline_id = 1000026     X
select * from adempiere.c_revenuerecognition_plan where c_invoiceline_id = 1000026  X
select * from adempiere.c_taxdeclarationline where c_invoiceline_id = 1000026       X
select * from adempiere.m_inoutlineconfirm where c_invoiceline_id = 1000026         X
select * from adempiere.m_matchpo where c_invoiceline_id = 1000026                  X
select * from adempiere.s_timeexpenseline where c_invoiceline_id = 1000026          X
select * from adempiere.m_matchinv where c_invoiceline_id = 1000026                 X
select * from adempiere.m_costdetail where c_invoiceline_id = 1000026               X

==============================================================================================================
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'c_payment';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.c_payment'::regclass; 

adempiere.b_buyerfunds
adempiere.b_sellerfunds
adempiere.c_allocationline
adempiere.c_bankstatementline
adempiere.c_cashline
adempiere.c_depositbatchline
adempiere.c_dunningrunline
adempiere.c_invoice
adempiere.c_order
adempiere.c_paymentallocate
adempiere.c_paymenttransaction
adempiere.c_payselectioncheck
adempiere.c_pospayment
adempiere.c_recurring
adempiere.c_recurring_run
adempiere.i_bankstatement
adempiere.i_payment
adempiere.r_request
adempiere.r_requestaction    

select * from adempiere.c_payment where c_payment_id = 1000017

select * from adempiere.b_buyerfunds where c_payment_id = 1000017
select * from adempiere.b_sellerfunds where c_payment_id = 1000017
select * from adempiere.c_allocationline where c_payment_id = 1000017
select * from adempiere.c_bankstatementline where c_payment_id = 1000017
select * from adempiere.c_cashline where c_payment_id = 1000017
select * from adempiere.c_depositbatchline where c_payment_id = 1000017
select * from adempiere.c_invoice where c_payment_id = 1000017
select * from adempiere.c_order where c_payment_id = 1000017
select * from adempiere.c_dunningrunline where c_payment_id = 1000017
select * from adempiere.c_paymenttransaction where c_payment_id = 1000017
select * from adempiere.c_payselectioncheck where c_payment_id = 1000017
select * from adempiere.c_paymentallocate where c_payment_id = 1000017
select * from adempiere.c_pospayment where c_payment_id = 1000017
select * from adempiere.c_recurring where c_payment_id = 1000017
select * from adempiere.c_recurring_run where c_payment_id = 1000017
select * from adempiere.i_bankstatement where c_payment_id = 1000017
select * from adempiere.i_payment where c_payment_id = 1000017
select * from adempiere.r_request where c_payment_id = 1000017
select * from adempiere.r_requestaction where c_payment_id = 1000017


===============================================================================================================
This below query remove c_invoice records:-

UPDATE adempiere.c_invoice
SET docstatus = 'DR', docaction = 'CO', processed = 'N'
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;

-- 2. Delete dependent records
DELETE FROM adempiere.c_invoiceline
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.c_allocationline
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.c_invoicetax
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;

UPDATE adempiere.c_invoice
SET c_payment_id = NULL
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.c_payment
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;
-- 3. Delete the invoice itself
DELETE FROM adempiere.c_invoice
WHERE c_invoice_id BETWEEN 1000000 AND 1001500;
===============================================================================================================
m_inout

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'm_inout';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.m_inout'::regclass; 

adempiere.c_invoice
adempiere.c_landedcost
adempiere.m_inoutconfirm
adempiere.m_inoutline
adempiere.m_movement
adempiere.m_package
adempiere.r_requestaction
adempiere.m_rma
adempiere.m_shippingtransaction
adempiere.r_request
adempiere.m_inout    ref_inout_id   null
adempiere.m_inout    reversal_id    null

select * from adempiere.m_inout where m_inout_id = 1000028

select * from adempiere.m_inoutline where m_inout_id = 1000028
select * from adempiere.c_invoice where m_inout_id = 1000028            X 
select * from adempiere.c_landedcost where m_inout_id = 1000028         X
select * from adempiere.m_inoutconfirm where m_inout_id = 1000028       X
select * from adempiere.m_movement where m_inout_id = 1000028           X
select * from adempiere.m_package where m_inout_id = 1000028            X
select * from adempiere.r_requestaction where m_inout_id = 1000028      X
select * from adempiere.m_rma where m_inout_id = 1000028                X
select * from adempiere.m_shippingtransaction where m_inout_id = 1000028 X
select * from adempiere.r_request where m_inout_id = 1000028            X



SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'm_inoutline';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.m_inoutline'::regclass;  

adempiere.a_asset
adempiere.a_asset_addition
adempiere.c_invoiceline
adempiere.c_landedcost
adempiere.c_landedcostallocation
adempiere.c_projectissue
adempiere.m_costdetail
adempiere.m_inoutlineconfirm
adempiere.m_inoutlinema
adempiere.m_matchinv
adempiere.m_matchpo
adempiere.m_packageline
adempiere.m_production
adempiere.m_rmaline
adempiere.m_transaction
adempiere.m_transactionallocation
adempiere.m_inoutline
adempiere.t_transaction
adempiere.m_transactionallocation
adempiere.a_asset_delivery
adempiere.pi_productlabel
adempiere.pi_qrrelations
adempiere.m_inoutline   reversalline_id

select * from adempiere.m_inoutline where m_inoutline_id = 1000028

select * from adempiere.m_transaction where m_inoutline_id = 1000028
select * from adempiere.m_inoutlinema where m_inoutline_id = 1000028

select * from adempiere.a_asset where m_inoutline_id = 1000028
select * from adempiere.a_asset_addition where m_inoutline_id = 1000028
select * from adempiere.c_invoiceline where m_inoutline_id = 1000028
select * from adempiere.c_landedcost where m_inoutline_id = 1000028
select * from adempiere.c_landedcostallocation where m_inoutline_id = 1000028
select * from adempiere.c_projectissue where m_inoutline_id = 1000028
select * from adempiere.m_costdetail where m_inoutline_id = 1000028
select * from adempiere.m_inoutlineconfirm where m_inoutline_id = 1000028
select * from adempiere.m_matchinv where m_inoutline_id = 1000028
select * from adempiere.m_matchpo where m_inoutline_id = 1000028
select * from adempiere.m_packageline where m_inoutline_id = 1000028
select * from adempiere.m_production where m_inoutline_id = 1000028
select * from adempiere.m_rmaline where m_inoutline_id = 1000028
select * from adempiere.m_transactionallocation where m_inoutline_id = 1000028
select * from adempiere.t_transaction where m_inoutline_id = 1000028
select * from adempiere.a_asset_delivery where m_inoutline_id = 1000028
select * from adempiere.pi_productlabel where m_inoutline_id = 1000028


SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'm_transaction';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.m_transaction'::regclass;  


=======================================================================================================
M_inout cleanup:-

UPDATE adempiere.m_inout
SET docstatus = 'DR', docaction = 'CO', processed = 'N'
WHERE m_inout_id BETWEEN 1000000 AND 1001500;

-- 1. Delete dependent records from M_Transaction
DELETE FROM adempiere.m_transaction
WHERE m_inoutline_id BETWEEN 1000000 AND 1001500;

-- 2. Delete dependent records from M_InOutLineMA
DELETE FROM adempiere.m_inoutlinema
WHERE m_inoutline_id BETWEEN 1000000 AND 1001500;

-- 3. Delete dependent M_InOutLine records
DELETE FROM adempiere.m_inoutline
WHERE m_inout_id BETWEEN 1000000 AND 1001500;

-- 4. Delete the main M_InOut record
DELETE FROM adempiere.m_inout
WHERE m_inout_id BETWEEN 1000000 AND 1001500;

-- 5. Validate the cleanup
SELECT * FROM adempiere.m_inout WHERE m_inout_id = 1000028;
SELECT * FROM adempiere.m_inoutline WHERE m_inout_id = 1000028;

=======================================================================================================
c_order table :-

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'c_order';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.c_order'::regclass;  


adempiere.b_buyerfunds
adempiere.b_sellerfunds
adempiere.c_allocationline
adempiere.c_invoice
adempiere.c_opportunity
adempiere.c_orderlandedcost
adempiere.c_orderline
adempiere.c_orderpayschedule
adempiere.c_ordertax
adempiere.c_payment
adempiere.c_paymenttransaction
adempiere.c_pospayment
adempiere.c_projectline
adempiere.c_projectphase
adempiere.c_recurring
adempiere.c_recurring_run
adempiere.c_rfq
adempiere.c_rfqresponse
adempiere.dd_order
adempiere.i_order
adempiere.m_inout
adempiere.m_rma
adempiere.m_shippingtransaction
adempiere.pp_mrp
adempiere.c_order      ref_order_id
adempiere.r_request
adempiere.r_requestaction
adempiere.c_projectline
adempiere.c_order       link_order_id
adempiere.c_order       quotationorder_id
adempiere.dd_order

select * from adempiere.b_buyerfunds where c_order_id = 1000022
select * from adempiere.b_sellerfunds where c_order_id = 1000022
select * from adempiere.c_allocationline where c_order_id = 1000022
select * from adempiere.c_invoice where c_order_id = 1000022
select * from adempiere.c_opportunity where c_order_id = 1000022
select * from adempiere.c_orderlandedcost where c_order_id = 1000022
select * from adempiere.c_orderline where c_order_id = 1000022         R
select * from adempiere.c_orderpayschedule where c_order_id = 1000022
select * from adempiere.c_ordertax where c_order_id = 1000022          R    
select * from adempiere.c_payment where c_order_id = 1000022
select * from adempiere.c_paymenttransaction where c_order_id = 1000022
select * from adempiere.c_pospayment where c_order_id = 1000022
select * from adempiere.c_projectline where c_order_id = 1000022
select * from adempiere.c_projectphase where c_order_id = 1000022
select * from adempiere.c_recurring where c_order_id = 1000022
select * from adempiere.c_recurring_run where c_order_id = 1000022
select * from adempiere.c_rfq where c_order_id = 1000022
select * from adempiere.c_rfqresponse where c_order_id = 1000022
select * from adempiere.dd_order where c_order_id = 1000022
select * from adempiere.i_order where c_order_id = 1000022
select * from adempiere.m_inout where c_order_id = 1000022
select * from adempiere.m_rma where c_order_id = 1000022
select * from adempiere.m_shippingtransaction where c_order_id = 1000022
select * from adempiere.pp_mrp where c_order_id = 1000022
select * from adempiere.r_request where c_order_id = 1000022
select * from adempiere.r_requestaction where c_order_id = 1000022
select * from adempiere.dd_order where c_order_id = 1000022


c_orderline

adempiere.c_commissiondetail
adempiere.c_invoiceline
adempiere.c_orderlandedcostallocation
adempiere.i_order
adempiere.m_costdetail
adempiere.m_demanddetail
adempiere.m_inoutline
adempiere.m_matchpo
adempiere.m_production
adempiere.m_requisitionline
adempiere.pp_mrp
adempiere.pp_order
adempiere.c_orderline
adempiere.s_timeexpenseline
adempiere.c_orderline
adempiere.pi_productlabel
adempiere.pi_qrrelations

select * from adempiere.c_commissiondetail where c_orderline_id = 1000023
select * from adempiere.c_invoiceline where c_orderline_id = 1000023
select * from adempiere.c_orderlandedcostallocation where c_orderline_id = 1000023
select * from adempiere.i_order where c_orderline_id = 1000023
select * from adempiere.m_costdetail where c_orderline_id = 1000023
select * from adempiere.m_demanddetail where c_orderline_id = 1000023
select * from adempiere.m_inoutline where c_orderline_id = 1000023
select * from adempiere.m_matchpo where c_orderline_id = 1000023
select * from adempiere.m_production where c_orderline_id = 1000023
select * from adempiere.m_requisitionline where c_orderline_id = 1000023
select * from adempiere.pp_mrp where c_orderline_id = 1000023
select * from adempiere.pp_order where c_orderline_id = 1000023
select * from adempiere.c_orderline where c_orderline_id = 1000023   R
select * from adempiere.s_timeexpenseline where c_orderline_id = 1000023
select * from adempiere.pi_productlabel where c_orderline_id = 1000023


-----------------------------------------------
DELETE c_order records;-

UPDATE adempiere.c_order
SET docstatus = 'DR', docaction = 'CO', processed = 'N'
WHERE c_order_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.c_orderline
WHERE c_order_id BETWEEN 1000000 AND 1001500;

-- 2. Delete dependent records from M_InOutLineMA
DELETE FROM adempiere.c_ordertax
WHERE c_order_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.c_order
WHERE c_order_id BETWEEN 1000000 AND 1001500;

select * from adempiere.c_order where c_order_id = 1000020
====================================================================================

Tc Order:-

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'TC_order';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.TC_order'::regclass; 

select * from adempiere.tc_order WHERE ad_client_id = 1000002;  


DELETE FROM adempiere.tc_secondaryhardeningLabel
WHERE tc_secondaryhardeningLabel_id BETWEEN 1000001 AND 1001490;

DELETE FROM adempiere.tc_primaryHardeningcultureS
WHERE tc_primaryhardeningLabel_id BETWEEN 1000001 AND 1001490;

DELETE FROM adempiere.tc_primaryhardeningLabel
WHERE tc_primaryhardeningLabel_id BETWEEN 1000001 AND 1001490;

DELETE FROM adempiere.tc_culturelabel
WHERE tc_culturelabel_id BETWEEN 1000001 AND 1001490;

DELETE FROM adempiere.tc_explantlabel
WHERE tc_explantlabel_id BETWEEN 1000001 AND 1001490;

DELETE FROM adempiere.tc_planttag
WHERE tc_planttag_id BETWEEN 1000001 AND 1001490;


UPDATE adempiere.TC_Order
SET docstatus = 'DR', docaction = 'CO', processed = 'N'
WHERE TC_order_id BETWEEN 1000001 AND 1001470;

-- 2. Delete dependent records from tc_mediaoutline
DELETE FROM adempiere.tc_mediaoutline
WHERE TC_order_id BETWEEN 1000001 AND 1001470;

-- 3. Delete dependent records from tc_out
DELETE FROM adempiere.tc_out
WHERE TC_order_id BETWEEN 1000001 AND 1001470;

-- 4. Delete dependent records from tc_in
DELETE FROM adempiere.tc_in
WHERE TC_order_id BETWEEN 1000001 AND 1001470;

-- 5. Finally, delete records from TC_Order
DELETE FROM adempiere.TC_Order
WHERE TC_order_id BETWEEN 1000001 AND 1001470;

If you want remove client according then added ad_client_id = 1000000 in where clause otherwise all records remove at a time 

DELETE FROM adempiere.tc_collectionjoinplant
WHERE tc_collectiondetails_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_collectiondetails
WHERE tc_collectiondetails_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_intermediatejoinplant
WHERE tc_intermediatevisit_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_intermediatevisit
WHERE tc_intermediatevisit_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_firstjoinplant
WHERE tc_firstvisit_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_firstvisit
WHERE tc_firstvisit_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.TC_visit
WHERE TC_visit_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.tc_plantdetails
WHERE tc_plantdetails_id BETWEEN 1000000 AND 1001500;

DELETE FROM adempiere.TC_farmer
WHERE TC_farmer_id BETWEEN 1000000 AND 1000500;

================================================================================
TC Media order 

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'TC_MediaOrder';

SELECT
    conname AS constraint_name,
    conrelid::regclass AS referencing_table,
    a.attname AS referencing_column,
    confrelid::regclass AS referenced_table,
    af.attname AS referenced_column
FROM
    pg_constraint
JOIN pg_attribute a ON a.attnum = ANY (conkey) AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = ANY (confkey) AND af.attrelid = confrelid
WHERE
    confrelid = 'adempiere.TC_MediaOrder'::regclass; 

DELETE FROM adempiere.TC_medialabelqr
WHERE TC_medialabelqr_id BETWEEN 1000000 AND 1000258;    

-- 1. Update TC_Order status for all IDs in the range
UPDATE adempiere.TC_MediaOrder
SET docstatus = 'DR', docaction = 'CO', processed = 'N'
WHERE TC_MediaOrder_id BETWEEN 1000000 AND 1000258;

-- 2. Delete dependent records from tc_mediaoutline
DELETE FROM adempiere.TC_MediaLine
WHERE TC_MediaOrder_id BETWEEN 1000000 AND 1000258;

-- 3. Delete dependent records from tc_out
DELETE FROM adempiere.TC_MediaOrder
WHERE TC_MediaOrder_id BETWEEN 1000000 AND 1000258;

==============================================================================================================================================
If we want to remove all tc_order and tc_media order data so below query use client wise all records deleted.

SELECT * FROM adempiere.m_transaction WHERE ad_client_id = 1000002;

-- 1. Delete from M_Transaction
DELETE FROM adempiere.m_transaction 
WHERE ad_client_id = 1000002;

-- 2. Delete from M_StorageOnHand (if storage needs to be cleared)
DELETE FROM adempiere.m_storageonhand 
WHERE ad_client_id = 1000002;

==============================================================================================================================================
Delete m_movement table:-

SELECT * FROM adempiere.m_movement WHERE ad_client_id = 1000002;

-- 1. Delete from M_MovementLine (Child Table)
DELETE FROM adempiere.m_movementline 
WHERE m_movement_id IN (
    SELECT m_movement_id FROM adempiere.m_movement WHERE ad_client_id = 1000002
);

-- 2. Delete from M_Movement (Main Table)
DELETE FROM adempiere.m_movement 
WHERE ad_client_id = 1000002;




==============================================================================================================================================
----------------------------------------------------------------------------------------------------------------------------------------------
==============================================================================================================================================
One Api created deletd all Tissue Culture Data:-

    @Override
    public AddOrderLabelResponseDocument addOrderlabel(AddOrderLabelRequestDocument req) {
        AddOrderLabelResponseDocument addOrderLabelResponseDocument = AddOrderLabelResponseDocument.Factory
                .newInstance();
        AddOrderLabelResponse addOrderLabelResponse = addOrderLabelResponseDocument.addNewAddOrderLabelResponse();
        AddOrderLabelRequest loginRequest = req.getAddOrderLabelRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String serviceType = loginRequest.getServiceType();
        Trx trx = null;
        int client_id = login.getClientID();
        try {
            getCompiereService().connect();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "addOrder", serviceType);
            if (err != null && err.length() > 0) {
                addOrderLabelResponse.setError(err);
                addOrderLabelResponse.setIsError(true);
                return addOrderLabelResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("addOrder")) {
                addOrderLabelResponse.setError("Service type " + serviceType + " not configured");
                addOrderLabelResponse.setIsError(true);
                return addOrderLabelResponseDocument;
            }
            
            String sqlUpdateInvoices = "UPDATE adempiere.c_invoice SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
            String sqlDeleteInvoiceLines = "DELETE FROM adempiere.c_invoiceline WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
            String sqlDeleteAllocationLines = "DELETE FROM adempiere.c_allocationline WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
            String sqlDeleteInvoiceTaxes = "DELETE FROM adempiere.c_invoicetax WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
            String sqlUpdatePayments = "UPDATE adempiere.c_invoice SET c_payment_id = NULL WHERE AD_Client_ID = ?";
            String sqlDeletePayments = "DELETE FROM adempiere.c_payment WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
            String sqlDeleteInvoices = "DELETE FROM adempiere.c_invoice WHERE AD_Client_ID = ?";

            DB.executeUpdateEx(sqlUpdateInvoices, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInvoiceLines, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteAllocationLines, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInvoiceTaxes, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlUpdatePayments, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeletePayments, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInvoices, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlUpdateInOut = "UPDATE adempiere.m_inout SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
            String sqlDeleteTransactions = "DELETE FROM adempiere.m_transaction WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))";
            String sqlDeleteInOutLineMA = "DELETE FROM adempiere.m_inoutlinema WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))";
            String sqlDeleteInOutLine = "DELETE FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?)";
            String sqlDeleteInOut = "DELETE FROM adempiere.m_inout WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlUpdateInOut, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteTransactions, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInOutLineMA, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInOutLine, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteInOut, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlUpdateOrders = "UPDATE adempiere.c_order SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
            String sqlDeleteOrderLines = "DELETE FROM adempiere.c_orderline WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
            String sqlDeleteOrderTax = "DELETE FROM adempiere.c_ordertax WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
            String sqlDeleteOrders = "DELETE FROM adempiere.c_order WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlUpdateOrders, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteOrderLines, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteOrderTax, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteOrders, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlDeleteSecondaryHardeningLabel = "DELETE FROM adempiere.tc_secondaryhardeningLabel WHERE AD_Client_ID = ?";
            String sqlDeletePrimaryHardeningCultureS = "DELETE FROM adempiere.tc_primaryHardeningcultureS WHERE AD_Client_ID = ?";
            String sqlDeletePrimaryHardeningLabel = "DELETE FROM adempiere.tc_primaryhardeningLabel WHERE AD_Client_ID = ?";
            String sqlDeleteCultureLabel = "DELETE FROM adempiere.tc_culturelabel WHERE AD_Client_ID = ?";
            String sqlDeleteExplantLabel = "DELETE FROM adempiere.tc_explantlabel WHERE AD_Client_ID = ?";
            String sqlDeletePlantTag = "DELETE FROM adempiere.tc_planttag WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlDeleteSecondaryHardeningLabel, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeletePrimaryHardeningCultureS, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeletePrimaryHardeningLabel, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteCultureLabel, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteExplantLabel, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeletePlantTag, new Object[]{client_id}, trxName);

            trx.commit();
            
            String sqlUpdateOrder = "UPDATE adempiere.TC_Order SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
            String sqlDeleteMediaOutline = "DELETE FROM adempiere.tc_mediaoutline WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
            String sqlDeleteOut = "DELETE FROM adempiere.tc_out WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
            String sqlDeleteIn = "DELETE FROM adempiere.tc_in WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
            String sqlDeleteOrder = "DELETE FROM adempiere.TC_Order WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlUpdateOrder, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteMediaOutline, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteOut, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteIn, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteOrder, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlDeleteCollectionJoinPlant = "DELETE FROM adempiere.tc_collectionjoinplant WHERE tc_collectiondetails_id IN (SELECT tc_collectiondetails_id FROM adempiere.tc_collectiondetails WHERE AD_Client_ID = ?)";
            String sqlDeleteCollectionDetails = "DELETE FROM adempiere.tc_collectiondetails WHERE AD_Client_ID = ?";

            String sqlDeleteIntermediateJoinPlant = "DELETE FROM adempiere.tc_intermediatejoinplant WHERE tc_intermediatevisit_id IN (SELECT tc_intermediatevisit_id FROM adempiere.tc_intermediatevisit WHERE AD_Client_ID = ?)";
            String sqlDeleteIntermediateVisit = "DELETE FROM adempiere.tc_intermediatevisit WHERE AD_Client_ID = ?";

            String sqlDeleteFirstJoinPlant = "DELETE FROM adempiere.tc_firstjoinplant WHERE tc_firstvisit_id IN (SELECT tc_firstvisit_id FROM adempiere.tc_firstvisit WHERE AD_Client_ID = ?)";
            String sqlDeleteFirstVisit = "DELETE FROM adempiere.tc_firstvisit WHERE AD_Client_ID = ?";

            String sqlDeleteVisit = "DELETE FROM adempiere.TC_visit WHERE AD_Client_ID = ?";
            String sqlDeletePlantDetails = "DELETE FROM adempiere.tc_plantdetails WHERE AD_Client_ID = ?";
            String sqlDeleteFarmer = "DELETE FROM adempiere.TC_farmer WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlDeleteCollectionJoinPlant, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteCollectionDetails, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteIntermediateJoinPlant, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteIntermediateVisit, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteFirstJoinPlant, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteFirstVisit, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteVisit, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeletePlantDetails, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteFarmer, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlDeleteMediaLabelQR = "DELETE FROM adempiere.TC_medialabelqr WHERE AD_Client_ID = ?";
            String sqlUpdateMediaOrder = "UPDATE adempiere.TC_MediaOrder SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
            String sqlDeleteMediaLine = "DELETE FROM adempiere.TC_MediaLine WHERE TC_MediaOrder_id IN (SELECT TC_MediaOrder_id FROM adempiere.TC_MediaOrder WHERE AD_Client_ID = ?)";
            String sqlDeleteMediaOrder = "DELETE FROM adempiere.TC_MediaOrder WHERE AD_Client_ID = ?";
            
            DB.executeUpdateEx(sqlDeleteMediaLabelQR, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlUpdateMediaOrder, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteMediaLine, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteMediaOrder, new Object[]{client_id}, trxName);
            trx.commit();

            String sqlDeleteMovementLine = "DELETE FROM adempiere.M_MovementLine WHERE M_Movement_ID IN (SELECT M_Movement_ID FROM adempiere.M_Movement WHERE AD_Client_ID = ?)";
            String sqlDeleteMovement = "DELETE FROM adempiere.M_Movement WHERE AD_Client_ID = ?";

            DB.executeUpdateEx(sqlDeleteMovementLine, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteMovement, new Object[]{client_id}, trxName);
            trx.commit();
            
            String sqlDeleteTransaction = "DELETE FROM adempiere.M_Transaction WHERE AD_Client_ID = ?";
            String sqlDeleteStorage = "DELETE FROM adempiere.M_StorageOnHand WHERE AD_Client_ID = ?";

            DB.executeUpdateEx(sqlDeleteTransaction, new Object[]{client_id}, trxName);
            DB.executeUpdateEx(sqlDeleteStorage, new Object[]{client_id}, trxName);
            trx.commit();

            String sqlDeleteTemperatureStatus = "DELETE FROM adempiere.tc_temperatureStatus WHERE AD_Client_ID = ?";
            DB.executeUpdateEx(sqlDeleteTemperatureStatus, new Object[]{client_id}, trxName);
            trx.commit();
            
            addOrderLabelResponse.setIsError(false);
            addOrderLabelResponse.setError("Deleted Successfully"); 
        } catch (Exception e) {
            e.printStackTrace();
            addOrderLabelResponse.setError(e.getMessage());
            addOrderLabelResponse.setIsError(true);
        } finally {
            trx.close();
            getCompiereService().disconnect();
        }
        return addOrderLabelResponseDocument;
    }

=============================================================================================================================================
----------------------------------------------------------------------------------------------------------------------------------------------
==============================================================================================================================================    
1st java code
package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Properties;

import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.Component;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zul.Div;

import tools.dynamia.zk.addons.chartjs.Axe;
import tools.dynamia.zk.addons.chartjs.CategoryChartjsData;
import tools.dynamia.zk.addons.chartjs.Chartjs;
import tools.dynamia.zk.addons.chartjs.ChartjsData;
import tools.dynamia.zk.addons.chartjs.ChartjsOptions;
import tools.dynamia.zk.addons.chartjs.Dataset;
import tools.dynamia.zk.addons.chartjs.ScaleLabel;
import tools.dynamia.zk.addons.chartjs.Scales;
import tools.dynamia.zk.addons.chartjs.Ticks;

public class InventoryMoveChart extends DashboardPanel implements EventListener<Event> {

    private static final long serialVersionUID = 1L;
    private ChartjsData lineModel;
    private Chartjs chartjs;
    private Div div;
    private List<Integer> dataList;
    private List<Integer> dispatch ;
    private List<Integer> internalMove;
    private Component parent;
    CategoryChartjsData data;

    public InventoryMoveChart() {
        super();
        this.setSclass("activities-box");
        initLineModel();
        this.appendChild(createActivitiesPanel());
    }

    private Div createActivitiesPanel() {
        div = new Div();
        
        chartjs = new Chartjs(Chartjs.TYPE_LINE);
        chartjs.setData(data);
                
        chartjs.setOptions(ChartjsOptions.Builder.init()
                .scales(new Scales().addY(Axe.Builder.init().scaleLabel(ScaleLabel.Builder.init().display(true).build())
                        .ticks(Ticks.Builder.init().min(0).max(100).build()).build()))
                .build());
        chartjs.setWidth("90%");
        chartjs.setParent(parent);
        div.appendChild(chartjs);
        return div;
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
    private void initLineModel() {

        int januaryIn = 0;
        int febrauryIn = 0;
        int marchIn = 0;
        int aprilIn = 0;
        int mayIn = 0;
        int juneIn = 0;
        int julyIn = 0;
        int augustIn = 0;
        int septempberIn = 0;
        int octoberIn = 0;
        int novemberIn = 0;
        int decemberIn = 0;

        int januarySales = 0;
        int febraurySales = 0;
        int marchSales = 0;
        int aprilSales = 0;
        int maySales = 0;
        int juneSales = 0;
        int julySales = 0;
        int augustSales = 0;
        int septempberSales = 0;
        int octoberSales = 0;
        int novemberSales = 0;
        int decemberSales = 0;

        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);
        int wareHouseId = DPWarehouseSelection.getWareHouse_ID(ctx);
        int productId = DPWarehouseSelection.getProduct_ID(ctx);

        try {
            String sqlIn = null;
            String salesSql = null;
            if (wareHouseId == 0 && productId == 0) {
                sqlIn = "SELECT TO_CHAR(mr.created, 'Month') AS month_name, COUNT(mr) AS returnCount \n"
                        + "FROM m_rma mr WHERE mr.ad_client_id = " + clientId
                        + " AND mr.created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";

                salesSql = "SELECT TO_CHAR(created, 'Month') AS month_name, count(distinct c_order_id) from m_inout where ad_client_id ="
                        + clientId + " and \n"
                        + "issotrx ='Y' AND created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";
            } else if (wareHouseId != 0 && productId == 0) {
                sqlIn = "SELECT TO_CHAR(mr.created, 'Month') AS month_name, COUNT(mr) AS returnCount \n"
                        + "FROM m_rma mr JOIN m_inout mi ON mi.m_inout_id = mr.inout_id\n"
                        + "WHERE mr.isactive = 'Y' AND mi.m_warehouse_id=" + wareHouseId
                        + " AND mr.ad_client_id = 11 AND mr.created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";
                salesSql = "SELECT TO_CHAR(created, 'Month') AS month_name, count(distinct c_order_id) from m_inout where ad_client_id ="
                        + clientId + " and \n" + "issotrx ='Y' AND m_warehouse_id = " + wareHouseId
                        + " AND created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";
            } else if (wareHouseId == 0 && productId != 0) {
                sqlIn = "SELECT TO_CHAR(mr.created, 'Month') AS month_name, COUNT(mr) AS returnCount \n"
                        + "FROM m_rma mr JOIN m_rmaline mrl on mrl.m_rma_id = mr.m_rma_id\n"
                        + "WHERE mr.ad_client_id = " + clientId + " AND mrl.m_product_id=" + productId
                        + " AND mr.created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";
                salesSql = "SELECT TO_CHAR(mi.created, 'Month') AS month_name, count(distinct mi.c_order_id) from m_inout mi \n"
                        + "join m_inoutline ml on ml.m_inout_id = mi.m_inout_id where mi.ad_client_id =" + clientId
                        + " and \n" + "ml.m_product_id = " + productId
                        + " and mi.issotrx ='Y' AND mi.created BETWEEN (CURRENT_DATE - INTERVAL '6 MONTH') \n"
                        + "AND CURRENT_DATE GROUP BY month_name;";
            }

            PreparedStatement pstmtIn = DB.prepareStatement(sqlIn.toString(), null);
            ResultSet listIn = pstmtIn.executeQuery();

            while (listIn.next()) {
                int returnCount = listIn.getInt("returncount");
                String monthNameDB = listIn.getString("month_name");
                String monthName = monthNameDB.trim();
                if (monthName.equalsIgnoreCase("January"))
                    januaryIn = returnCount;
                else if (monthName.equalsIgnoreCase("Febraury"))
                    febrauryIn = returnCount;
                else if (monthName.equalsIgnoreCase("March"))
                    marchIn = returnCount;
                else if (monthName.equalsIgnoreCase("April"))
                    aprilIn = returnCount;
                else if (monthName.equalsIgnoreCase("May"))
                    mayIn = returnCount;
                else if (monthName.equalsIgnoreCase("June"))
                    juneIn = returnCount;
                else if (monthName.equalsIgnoreCase("July"))
                    julyIn = returnCount;
                else if (monthName.equalsIgnoreCase("August"))
                    augustIn = returnCount;
                else if (monthName.equalsIgnoreCase("September"))
                    septempberIn = returnCount;
                else if (monthName.equalsIgnoreCase("October"))
                    octoberIn = returnCount;
                else if (monthName.equalsIgnoreCase("November"))
                    novemberIn = returnCount;
                else if (monthName.equalsIgnoreCase("December"))
                    decemberIn = returnCount;
            }
            DB.close(listIn, pstmtIn);
            listIn = null;
            pstmtIn = null;

            pstmtIn = DB.prepareStatement(salesSql.toString(), null);
            listIn = pstmtIn.executeQuery();

            while (listIn.next()) {
                int count = listIn.getInt("count");
                String monthNameDB = listIn.getString("month_name");
                String monthName = monthNameDB.trim();
                if (monthName.equalsIgnoreCase("January"))
                    januarySales = count;
                else if (monthName.equalsIgnoreCase("Febraury"))
                    febraurySales = count;
                else if (monthName.equalsIgnoreCase("March"))
                    marchSales = count;
                else if (monthName.equalsIgnoreCase("April"))
                    aprilSales = count;
                else if (monthName.equalsIgnoreCase("May"))
                    maySales = count;
                else if (monthName.equalsIgnoreCase("June"))
                    juneSales = count;
                else if (monthName.equalsIgnoreCase("July"))
                    julySales = count;
                else if (monthName.equalsIgnoreCase("August"))
                    augustSales = count;
                else if (monthName.equalsIgnoreCase("September"))
                    septempberSales = count;
                else if (monthName.equalsIgnoreCase("October"))
                    octoberSales = count;
                else if (monthName.equalsIgnoreCase("November"))
                    novemberSales = count;
                else if (monthName.equalsIgnoreCase("December"))
                    decemberSales = count;
            }
            DB.close(listIn, pstmtIn);
            listIn = null;
            pstmtIn = null;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        LocalDateTime localDate = LocalDateTime.now();
        Month currentMonth = localDate.getMonth();
        currentMonth.minus(1);
        List<Integer> monthReturnsList = new ArrayList<>(Arrays.asList(januaryIn, febrauryIn, marchIn, aprilIn, mayIn,
                juneIn, julyIn, augustIn, septempberIn, octoberIn, novemberIn, decemberIn));

        List<Integer> monthSalesList = new ArrayList<>(
                Arrays.asList(januarySales, febraurySales, marchSales, aprilSales, maySales, juneSales, julySales,
                        augustSales, septempberSales, octoberSales, novemberSales, decemberSales));

        dataList =  new ArrayList<>(
                Arrays.asList(30, 50, 30, 40, 70, 50));
        
        dispatch =  new ArrayList<>(
                Arrays.asList(80, 30, 60, 50, 35, 80));
        
        internalMove = new ArrayList<>(
                Arrays.asList(30, 10, 40, 25,50, 40));
        
        if (data == null || data.isEmpty()) {
            data = new CategoryChartjsData();
            data.setLabels(currentMonth.getDisplayName(TextStyle.SHORT, Locale.ENGLISH),
                    currentMonth.minus(1).getDisplayName(TextStyle.SHORT, Locale.ENGLISH),
                    currentMonth.minus(2).getDisplayName(TextStyle.SHORT, Locale.ENGLISH),
                    currentMonth.minus(3).getDisplayName(TextStyle.SHORT, Locale.ENGLISH),
                    currentMonth.minus(4).getDisplayName(TextStyle.SHORT, Locale.ENGLISH),
                    currentMonth.minus(5).getDisplayName(TextStyle.SHORT, Locale.ENGLISH));

            data.addDataset(Dataset.Builder.init().fill(false).borderColor("#2563EB").label("Receiving")
                    .backgroundColor("#2563EB").data(dataList).build());
            
            data.addDataset(Dataset.Builder.init().fill(false).borderColor("#A0D7E7").label("Dsipacth")
                    .backgroundColor("#A0D7E7").data(dispatch).build());
            
            data.addDataset(Dataset.Builder.init().fill(false).borderColor("#8F95B2").label("Internal Move")
                    .backgroundColor("#8F95B2").data(internalMove).build());
            
            data.getDatasets().remove(0);
        } else {
            Dataset dataset1 = data.getDatasets().get(0);
            dataset1.setData(dataList);
            data.getDatasets().set(0, dataset1);
            
            Dataset dataset2 = data.getDatasets().get(1);
            dataset2.setData(dispatch);
            data.getDatasets().set(1, dataset2);
            
            Dataset dataset3 = data.getDatasets().get(2);
            dataset3.setData(dataList);
            data.getDatasets().set(2, dataset3);
        }
    }

    @Override
    public void updateUI() {
        initLineModel();
        chartjs.setData(data);
        chartjs.invalidate();
    }

    @Override
    public void refresh(ServerPushTemplate template) {
        template.executeAsync(this);
    }

    @Override
    public void onEvent(Event event) throws Exception {
    }
}


2nd java code
package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.adempiere.webui.component.Button;
import org.adempiere.webui.component.Grid;
import org.adempiere.webui.component.Label;
import org.adempiere.webui.component.Row;
import org.adempiere.webui.component.Rows;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.idempiere.zk.billboard.Billboard;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zul.Datebox;
import org.zkoss.zul.Div;
import org.zkoss.zul.PieModel;
import org.zkoss.zul.SimplePieModel;

public class DPFirstVisit extends DashboardPanel implements EventListener<Event> {

    private static final long serialVersionUID = 1L;
    private Billboard userDatas;
    private LinkedHashMap<String, Integer> userData = null;
    private static String User_Data = "userName";
    private Datebox startDateBox;
    private Datebox endDateBox;
    private Button refreshButton;

    public DPFirstVisit() {
        super();
        this.setSclass("activities-box");
        this.appendChild(createDateRangePanel());
        initOptions();
        buildChart(userData, User_Data);
        this.appendChild(createActivitiesPanel());
    }
    
    private Div createDateRangePanel() {
        Div dateRangeDiv = new Div();
        dateRangeDiv.setSclass("date-range-panel");

        Label startDateLabel = new Label("From Date:");
        startDateBox = new Datebox();
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_YEAR, -60);  // Set start date to current date minus 30 days
        startDateBox.setValue(calendar.getTime());

        Label endDateLabel = new Label("To Date:");
        endDateBox = new Datebox();
        endDateBox.setValue(new Date()); // Default to today
        
        refreshButton = new Button("Refresh");
        refreshButton.addEventListener("onClick", this);
        
        dateRangeDiv.appendChild(startDateLabel);
        dateRangeDiv.appendChild(startDateBox);
        dateRangeDiv.appendChild(endDateLabel);
        dateRangeDiv.appendChild(endDateBox);
        dateRangeDiv.appendChild(refreshButton);
        return dateRangeDiv;
    }

    private Grid createActivitiesPanel() {
        Grid grid = new Grid();
        appendChild(grid);
        grid.makeNoStrip();
        
        Rows rows = new Rows();
        grid.appendChild(rows);

        Row row = new Row();
        rows.appendChild(row);

        Div div = new Div();
        row.appendCellChild(div, 5);
        div.appendChild(userDatas);
        userDatas.removeSclass();
        div.setWidth("400px");
        div.setHeight("200px");
        return grid;
    }

    private void initOptions() {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);
        String visitTypeName = "First Visit";

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Date startDate = startDateBox.getValue();
            Date endDate = endDateBox.getValue();
            String sql = "SELECT 'Completed' AS Status, COUNT(CASE WHEN s.name = 'Completed' THEN 1 END) AS Count " +
                         "FROM adempiere.tc_visit v " +
                         "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                         "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                         "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"' AND v.updated::DATE BETWEEN ? AND ?  " +
                         "UNION ALL " +
                         "SELECT 'Cancelled' AS Status, COUNT(CASE WHEN s.name = 'Cancelled' THEN 1 END) AS Count " +
                         "FROM adempiere.tc_visit v " +
                         "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                         "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                         "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"' AND v.updated::DATE BETWEEN ? AND ?" +
                         "UNION ALL " +
                         "SELECT 'Upcoming' AS Status, COUNT(CASE WHEN s.name = 'In Progress' THEN 1 END) AS Count " +
                         "FROM adempiere.tc_visit v " +
                         "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                         "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                         "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"'AND v.created::DATE BETWEEN ? AND ?;";

            pstmt = DB.prepareStatement(sql, null);
            pstmt.setDate(1, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(2, new java.sql.Date(endDate.getTime()));
            pstmt.setDate(3, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(4, new java.sql.Date(endDate.getTime()));
            pstmt.setDate(5, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(6, new java.sql.Date(endDate.getTime()));
            rs = pstmt.executeQuery();
            userData = new LinkedHashMap<>();
            int totalCount = 0;
            while (rs.next()) {
                String status = rs.getString("Status");
                int count = rs.getInt("Count");
                userData.put(status, count);
                totalCount += count;
            }
            if (totalCount == 0) {
                userData.clear();
                userData.put("No Record Found", 0);
            }
            DB.close(rs, pstmt);
        } catch (SQLException e) {
            e.printStackTrace();
        }finally {
            DB.close(rs, pstmt);
        }
    }
    
    private void refreshChartData() {
        initOptions();
        updateUI();
    }

    @Override
    public void updateUI() {
        initOptions();
        userDatas.setModel(initChartModel(userData, User_Data));
        userDatas.invalidate();  
    }

    @Override
    public void refresh(ServerPushTemplate template) {
        template.executeAsync(this);
    }

    @Override
    public void onEvent(Event event) throws Exception {
        if (event.getTarget() == refreshButton) {
            initOptions();  
            userDatas.setModel(initChartModel(userData, User_Data));
            userDatas.invalidate();
        }
    }

    private void buildChart(LinkedHashMap<String, Integer> data, String type) {
        String completedColor = "#4CAF50"; // Green color for completed
        String cancelColor = "#F44336"; // Red color for cancel
        String inProgressColor = "#FFC107"; // Orange color for in progress
        String defaultColor = "#808080"; // Grey color for no records found

        userDatas = new Billboard();
        userDatas.setWidth("90%");

        PieModel model = initChartModel(data, type);
        userDatas.setModel(model);
        Set<String> wNames = data.keySet();
        Billboard billboard = new Billboard();
        billboard.setLegend(true, false);
        billboard.addLegendOptions("location", "bottom");
        billboard.setTickAxisLabel("Name");
        billboard.setValueAxisLabel("Quantity");
        billboard.setType("pie");
        billboard.setWidth("400px");
        billboard.setHeight("200px"); // Adjust height as needed
        billboard.setStyle("max-width:100%;");

        String[] rgbColors = new String[wNames.size()];
        Arrays.fill(rgbColors, defaultColor);
        int i = 0;
        for (String status : wNames) {
            switch (status) {
                case "Completed":
                    rgbColors[i++] = completedColor;
                    break;
                case "Cancelled":
                    rgbColors[i++] = cancelColor;
                    break;
                case "Upcoming":
                    rgbColors[i++] = inProgressColor;
                    break;
                case "No Record Found":
                    rgbColors[i++] = defaultColor;
                    break;
                default:
                    rgbColors[i++] = "#000000"; // Default color
                    break;
            }
        }
        billboard.addRendererOptions("intervalColors", rgbColors);
        billboard.setModel(initChartModel(data, type));
        billboard.setOrient("vertical");
        if (type.equalsIgnoreCase(User_Data))
            userDatas = billboard;
    }

    private PieModel initChartModel(LinkedHashMap<String, Integer> data, String type) {
        PieModel model = new SimplePieModel();
        for (Map.Entry<String, Integer> entry : data.entrySet()) {
            model.setValue(entry.getKey(), entry.getValue());
        }
        return model;
    }
}
