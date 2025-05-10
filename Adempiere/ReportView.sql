1.) create a new Pgsql View:-
	this is use select query for using specific record seen. 

CREATE VIEW adempiere.ch_Expirydetails AS 
SELECT b.name AS Product_Name,
a.expirydate as Expiry_Date,
e.qtyonhand AS Quantity,
att.lot AS Lot_No,
wh.value AS Warehouse_Name,
ll.value AS Locator_Name,
f.ad_client_id,
f.ad_org_id 
FROM adempiere.c_orderline a
JOIN adempiere.m_product b ON a.m_product_id = b.m_product_id 
JOIN adempiere.m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
JOIN adempiere.m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN adempiere.m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN adempiere.c_order f ON f.c_order_id = a.c_order_id
JOIN adempiere.m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
JOIN adempiere.m_locator ll ON ll.m_locator_id = e.m_locator_id
WHERE f.issotrx = 'N' 
AND e.qtyonhand != 0 --Empty qty product not show 
AND a.expirydate < CURRENT_DATE

(First you create a view working pgsql but adempiere application is not working
 If you add two field client and org then display you adempiere application)

 2.) Login System Administrator and go to Table and Column window:-
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		DB Table Name :-
		Name:- (ex.- chirag)
		select view checkbox
		unSelect Maintain Change Log checkbox
		Data Access Level :- Client+Organization
		Entity Type :- Dictionary
		select Show in drill option checkbox
		save and go to process button in middle top
		Create Column for DB 
		(All Cloumn is coming)
		If any Date field you see Date+Time you remove Time then show only Date 

3.) go to report View Window in search tab 
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- (Ex. - ra)
		Entity Type :- Dictionary
		Table:- enter above table name (ex.- chirag)
		save

4.) go to Report and Process window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Search Key :-
		Name:- (Ex.- ta)
		Entity Type :- Dictionary
		Multiple Execution :- Disallow multiple executions with the same parameters
		Data Access Level :- Client + Organization
		select Report checkbox
		Report View :- 	(Ex. - ra)	
		save 

5.) go to Menu window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- 
		Entity Type :- Dictionary
		unSelect Sales Transation checkbox
		Action :- report
		Process :- (ex.- ta)
		save

		change Role and login for your Tenant and show your reports View


==================================================================================================================================================================
Some Restriction View created:-

1.) Create a View:-
	
	 SELECT il.ad_client_id,
    il.ad_org_id,
    il.c_bpartner_id,
    il.m_product_id,
    adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying) AS dateinvoiced,
    sum(il.linenetamt) AS linenetamt,
    sum(il.linelistamt) AS linelistamt,
    sum(il.linelimitamt) AS linelimitamt,
    sum(il.linediscountamt) AS linediscountamt,
        CASE
            WHEN sum(il.linelistamt) = 0::numeric THEN 0::numeric
            ELSE adempiere.currencyround((sum(il.linelistamt) - sum(il.linenetamt)) / sum(il.linelistamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS linediscount,
    sum(il.lineoverlimitamt) AS lineoverlimitamt,
        CASE
            WHEN sum(il.linenetamt) = 0::numeric THEN 0::numeric
            ELSE 100::numeric - adempiere.currencyround((sum(il.linenetamt) - sum(il.lineoverlimitamt)) / sum(il.linenetamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS lineoverlimit,
    sum(il.qtyinvoiced) AS qtyinvoiced,
    il.issotrx
   FROM adempiere.rv_c_invoiceline il
     JOIN adempiere.c_invoice i ON i.c_invoice_id = il.c_invoice_id
  GROUP BY il.ad_client_id, il.ad_org_id, il.m_product_id, il.c_bpartner_id, (adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying)), il.issotrx, i.c_currency_id;

2.) Create a Table and Column :-
	Login System Administrator and go to Table and Column window:-
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		DB Table Name :-
		Name:- (ex.- chirag)
		select view checkbox
		unSelect Maintain Change Log checkbox
		Data Access Level :- Client+Organization
		Entity Type :- Dictionary
		select Show in drill option checkbox
		save and go to process button in middle top
		Create Column for DB 
		(All Cloumn is coming)
		 Client_id and Org_id two field only Mandatory and other field always Updatable

3.) go to report View Window in search tab 
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- (Ex. - ra)
		Entity Type :- Dictionary
		Table:- enter above table name (ex.- chirag)
		save


4.) go to Report and Process window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Search Key :-
		Name:- (Ex.- ta)
		Entity Type :- Dictionary
		Multiple Execution :- Disallow multiple executions with the same parameters
		Data Access Level :- Client + Organization
		select Report checkbox
		Report View :- 	(Ex. - ra)	
		save 

		Create a parameter it is very important:-

		If created date field with Period:-
		Name :-
		DB Column Name :- table Column Name 
		SystemKey:-
		Reference :- date 
		Select Range checkbox
		Date Range Option:- Date Editor and Range Picker
		PlaceHolder :- To
		save

		Sales Transation :- If only sales
		Name :-
		DB Column Name :- table Column Name 
		SystemKey:-
		Reference :- Yes-No
		Default Logic :- Y means only Sales Transation and N only Purchase Transation


		Product:-
		Name :-
		DB Column Name :- table Column Name 
		System Element:-
		Reference :- Chosen Multiple Selection Search
		Reference key :- M_Product(no summary) (this is very important if choose any other then show wrong results)


		BPartner:-
		Name :-
		DB Column Name :- table Column Name
		Reference :- Chosen Multiple Selection Search
		Reference Key :- C_Bartner(trx)


		Parameter value provide is very important other wise you get wrong results


5.) go to Menu window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- 
		Entity Type :- Dictionary
		unSelect Sales Transation checkbox
		Action :- report
		Process :- (ex.- ta)
		save

		change Role and login for your Tenant and show your reports View	


===========================================================================================================================================================
Create View Sales Representative and Product wise:-

 CREATE VIEW adempiere.chMonthlySalesProduct AS
 SELECT il.ad_client_id,
    il.ad_org_id,
    il.salesrep_id,
    il.m_product_id,
    adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying) AS dateinvoiced,
    sum(il.linenetamt) AS linenetamt,
    sum(il.linelistamt) AS linelistamt,
    sum(il.linelimitamt) AS linelimitamt,
    sum(il.linediscountamt) AS linediscountamt,
        CASE
            WHEN sum(il.linelistamt) = 0::numeric THEN 0::numeric
            ELSE adempiere.currencyround((sum(il.linelistamt) - sum(il.linenetamt)) / sum(il.linelistamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS linediscount,
    sum(il.lineoverlimitamt) AS lineoverlimitamt,
        CASE
            WHEN sum(il.linenetamt) = 0::numeric THEN 0::numeric
            ELSE 100::numeric - adempiere.currencyround((sum(il.linenetamt) - sum(il.lineoverlimitamt)) / sum(il.linenetamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS lineoverlimit,
    il.issotrx
   FROM adempiere.rv_c_invoiceline il
     JOIN adempiere.c_invoice i ON i.c_invoice_id = il.c_invoice_id
  GROUP BY il.ad_client_id, il.ad_org_id, il.salesrep_id,il.m_product_id, (adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'MM'::character varying)), il.issotrx, i.c_currency_id;

  that above query easily created view

  2.) Create a Table and Column :-
	Login System Administrator and go to Table and Column window:-
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		DB Table Name :-
		Name:- (ex.- chirag)
		select view checkbox
		unSelect Maintain Change Log checkbox
		Data Access Level :- Client+Organization
		Entity Type :- Dictionary
		select Show in drill option checkbox
		save and go to process button in middle top
		Create Column for DB 
		(All Cloumn is coming)
		 Client_id , Org_id and IsSOTrx field only Mandatory 
		 M_Product Updatable and SalesRep_ID not Updatable and not Mandatory


  3.) go to report View Window in search tab 
	  create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- (Ex. - ra)
		Entity Type :- Dictionary
		Table:- enter above table name (ex.- chirag)
		save	


4.) go to Report and Process window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Search Key :-
		Name:- (Ex.- ta)
		Entity Type :- Dictionary
		Multiple Execution :- Disallow multiple executions with the same parameters
		Data Access Level :- Client + Organization
		select Report checkbox
		Report View :- 	(Ex. - ra)	
		save 

		Create a parameter it is very important:-

		If created date field with Period:-
		Name :-
		DB Column Name :- table Column Name (DateInvoiced)
		SystemKey:-
		Reference :- date 
		Select Range checkbox
		Date Range Option:- Date Editor and Range Picker
		PlaceHolder :- To
		save

		Sales Transation :- If only sales
		Name :-
		DB Column Name :- table Column Name (IsSOTrx)
		SystemElement:- IsSOTrx
		Reference :- Yes-No
		Default Logic :- Y means only Sales Transation and N only Purchase Transation
		Select Negate Button checkbox


		Product:-
		Name :- Product(any name)
		DB Column Name :- table Column Name (M_Product_ID)
		System Element:- M_Product_ID
		Reference :- Chosen Multiple Selection Search
		Reference key :- M_Product(no summary) (this is very important if choose any other then show wrong results)
		Select Negate Button checkbox


		Sales Representative:-
		Name :- Sales Representative(any name)
		DB Column Name :- table Column Name (SalesRep_ID)
		System Element:- SalesRep_ID
		Reference :- Chosen Multiple Selection Search
		Reference Key :- AD_User - SalesRep
		Select Negate Button checkbox


		Parameter value provide is very important other wise you get wrong results


5.) go to Menu window in search tab
	create a new Table and Column click + symbol
		Fill Required field for create a new records
		Name :- 
		Entity Type :- Dictionary
		unSelect Sales Transation checkbox
		Action :- report
		Process :- (ex.- ta)
		save

		change Role and login for your Tenant and show your reports View


===========================================================================================================================================================
Daily Bases Data :-


 CREATE VIEW adempiere.chDailySalesProductAndBPartner AS
 SELECT il.ad_client_id,
    il.ad_org_id,
    il.m_product_id,
    il.c_bpartner_id,
    adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'DD'::character varying) AS dateinvoiced,
    sum(il.linenetamt) AS linenetamt,
    sum(il.linelistamt) AS linelistamt,
    sum(il.linelimitamt) AS linelimitamt,
    sum(il.linediscountamt) AS linediscountamt,
        CASE
            WHEN sum(il.linelistamt) = 0::numeric THEN 0::numeric
            ELSE adempiere.currencyround((sum(il.linelistamt) - sum(il.linenetamt)) / sum(il.linelistamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS linediscount,
    sum(il.lineoverlimitamt) AS lineoverlimitamt,
        CASE
            WHEN sum(il.linenetamt) = 0::numeric THEN 0::numeric
            ELSE 100::numeric - adempiere.currencyround((sum(il.linenetamt) - sum(il.lineoverlimitamt)) / sum(il.linenetamt) * 100::numeric, i.c_currency_id, 'N'::character varying)
        END AS lineoverlimit,
    il.issotrx
   FROM adempiere.rv_c_invoiceline il
     JOIN adempiere.c_invoice i ON i.c_invoice_id = il.c_invoice_id
  GROUP BY il.ad_client_id, il.ad_org_id, il.m_product_id,il.c_bpartner_id, (adempiere.firstof(il.dateinvoiced::timestamp with time zone, 'DD'::character varying)), il.issotrx, i.c_currency_id;


===========================================================================================================================================================
CREATE VIEW adempiere.NearExpiryProductLists AS
SELECT
    b.name AS product_name,
    a.expirydate AS date,
    e.qtyonhand AS expiryqty,
    att.lot AS lot_no,
    wh.value AS warehouse_name,
    ll.value AS locator_name,
    f.ad_client_id,
    f.ad_org_id
FROM
    adempiere.c_orderline a
JOIN
    adempiere.m_product b ON a.m_product_id = b.m_product_id
JOIN
    adempiere.m_inoutline mil ON mil.c_orderline_id = a.c_orderline_id
JOIN
    adempiere.m_storageonhand e ON mil.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN
    adempiere.m_attributesetinstance att ON att.m_attributesetinstance_id = e.m_attributesetinstance_id
JOIN
    adempiere.c_order f ON f.c_order_id = a.c_order_id
JOIN
    adempiere.m_warehouse wh ON wh.m_warehouse_id = f.m_warehouse_id
JOIN
    adempiere.m_locator ll ON ll.m_locator_id = e.m_locator_id
WHERE
    f.issotrx = 'N'::bpchar
    AND a.expirydate >= CURRENT_DATE;


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================


===========================================================================================================================================================
