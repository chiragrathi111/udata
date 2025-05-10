1. create a query for jasper reports:-

select i.dateinvoiced, i.c_bpartner_id,ac.name as clientName,i.c_invoice_id As InvoiceId,bp.name AS BPartnerName,pr.name AS ProductName,il.m_product_id,ROUND(COALESCE(il.pricelist, 0), 0) AS PriceList,il.qtyinvoiced,il.linenetamt from adempiere.c_invoice i
join adempiere.c_invoiceline il on i.c_invoice_id = il.c_invoice_id
join adempiere.c_bpartner bp on bp.c_bpartner_id = i.c_bpartner_id
join adempiere.m_product pr on pr.m_product_id = il.m_product_id 
join adempiere.ad_client ac on ac.ad_client_id = i.ad_client_id
where i.ad_client_id =  $P{AD_CLIENT_ID}  and i.dateinvoiced >  $P{FromDate} and i.dateinvoiced <   $P{ToDate} and i.issotrx = 'Y'
AND ($P{BPartnerId} IS NULL OR i.c_bpartner_id IN ($P!{BPartnerId}))  
order by c_bpartner_id, m_product_id

2. Added Parameter:-

	(1) AD_CLIENT_ID data type - integer
	(2) FromDate data type - timeStamp
	(3) ToDate data type - timeStamp
	(4) BPartnerId data type - String(this is very important if you use Big decimal or integer then not proper work for multiple name)

3. go to System login and enter search bar Report & Process	:-

	Mandotory field:-
		searchkey,name,entitytype - Dictionary,data access level - All,
		if you see html view then click report check box
		class name - org.adempiere.report.jasper.ReportStarter(if you use jasper then class is required)

		last added jasper report file name 
		jasper report - attachment:bPartnerWiseSalesReport.jrxml (file name your according)

		and save 
		then Attchment your jrxml file .

4.Parameter :-
	Mandotory field:-
		Name,DB Column Name - FromDate(depend on Parameter filed)
		SystemElement - DateInvoiced(c_invoice filed)
		Reference - Date,
		Default logic (if you thing by default show any date then put a logic)
		(@SQL=SELECT created FROM adempiere.c_invoice WHERE issotrx='Y' AND AD_CLIENT_ID =@#AD_Client_ID@ limit 1)
			this query logic means cleint id created first invoice records

		Current Date Default logic:- @#Date@
		

		Business Partner or Customer or salesRep parameter i enter line by line data:-

		Business Partner:-

5. If design your Report in jasper then follow steps:-
	First go to stype and added new style (If your requirement alternet color change then use below code)
	<style name="AlternateRowColorStyle" mode="Opaque" backcolor="#FFFFFF" pattern="" isBlankWhenNull="false">
		<conditionalStyle>
			<conditionExpression><![CDATA[$V{REPORT_COUNT} % 2 == 0]]></conditionExpression>
			<style mode="Opaque" backcolor="#D4E3F4"/>
		</conditionalStyle>
	</style>

	and which field you need alternate color then choose field style name 

6. PDF to HTML place chnage problem:-

Solution:- This problem only one solution not provide any space or tab you provide differenr static tab created and provude actual looking
			you see your problem is solve.




	
