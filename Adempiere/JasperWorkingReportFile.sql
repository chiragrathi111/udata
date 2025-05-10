bPartner Wise Sales Reports:-

select i.dateinvoiced, i.c_bpartner_id,ac.name as clientName,i.c_invoice_id As InvoiceId,bp.name AS BPartnerName,pr.name AS ProductName,il.m_product_id,ROUND(COALESCE(il.pricelist, 0), 2) AS PriceList,il.qtyinvoiced,ROUND(COALESCE(il.linenetamt, 0), 2) AS lineNetAmt from adempiere.c_invoice i
join adempiere.c_invoiceline il on i.c_invoice_id = il.c_invoice_id
join adempiere.c_bpartner bp on bp.c_bpartner_id = i.c_bpartner_id
join adempiere.m_product pr on pr.m_product_id = il.m_product_id 
join adempiere.ad_client ac on ac.ad_client_id = i.ad_client_id
where i.ad_client_id =  $P{AD_CLIENT_ID}  and i.dateinvoiced >  $P{FromDate} and i.dateinvoiced <   $P{ToDate} and i.issotrx = 'Y'
AND ($P{BPartnerId} IS NULL OR i.c_bpartner_id IN ($P!{BPartnerId})) order by c_bpartner_id, m_product_id

==================================================================================================================================================================
bPartner Wise detailed Sales Reports:-
SELECT c_bpartner_id,clientName,BPartnerName,c_invoice_id,
date,ProductName,m_product_id,ROUND(pricelist, 2) AS pricelist,
qtyinvoiced AS IndividualQuantity,ROUND(linenetamt, 2) AS IndividualNetAmount,
SUM(qtyinvoiced) OVER(PARTITION BY c_bpartner_id, m_product_id) AS TotalQuantity,
ROUND(SUM(linenetamt) OVER(PARTITION BY c_bpartner_id, m_product_id), 2) AS TotalNetAmount
FROM (SELECT i.c_bpartner_id,bp.name AS BPartnerName,cl.name as clientName,
i.c_invoice_id,DATE(i.dateinvoiced) AS date,pr.name AS ProductName,
il.m_product_id,il.pricelist,il.qtyinvoiced,il.linenetamt
FROM adempiere.c_invoice i
JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
JOIN adempiere.c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
JOIN adempiere.m_product pr ON pr.m_product_id = il.m_product_id
join adempiere.ad_client cl on cl.ad_client_id = i.ad_client_id
WHERE i.ad_client_id = $P{AD_CLIENT_ID} AND i.issotrx = 'Y'
AND i.dateinvoiced >   $P{FromDate} AND i.dateinvoiced <   $P{ToDate} 
AND ($P{BPartnerId} IS NULL OR i.c_bpartner_id IN ($P!{BPartnerId}))) AS subquery
ORDER BY c_bpartner_id,m_product_id

==================================================================================================================================================================
Sales Representative Wise Sales Reports:-

SELECT i.documentno AS invoice_number,bp.name AS Customer,
br.ad_user_id,i.c_bpartner_id,i.salesrep_id,
il.m_product_id,ad.name AS clientName,p.name AS productName,
il.qtyinvoiced AS quantity,ROUND(linenetamt, 2) AS netAmt,
br.name AS SalesRep,i.dateinvoiced FROM adempiere.c_invoice i
JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
JOIN adempiere.m_product p ON il.m_product_id = p.m_product_id
JOIN adempiere.ad_user br ON i.salesrep_id = br.ad_user_id 
JOIN adempiere.c_bpartner bp ON i.c_bpartner_id = bp.c_bpartner_id
JOIN adempiere.ad_client ad ON ad.ad_client_id = i.ad_client_id
WHERE i.issotrx = 'Y' AND p.ad_client_id = $P{AD_CLIENT_ID}  
AND i.dateinvoiced > $P{FromDate} AND i.dateinvoiced < $P{ToDate}  
AND (br.ad_user_id IN ($P!{SalesRep_ID}) OR $P{SalesRep_ID} IS NULL) 
ORDER BY i.salesrep_id, i.c_bpartner_id

==================================================================================================================================================================
Sales & Stock Analysis:-

WITH InvoiceLineTotals AS (
SELECT il.m_product_id,SUM(il.qtyinvoiced) AS TotalQty,
SUM(il.linenetamt) AS TotalNetAmount FROM adempiere.c_invoice i
JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
WHERE i.ad_client_id =  $P{AD_CLIENT_ID} AND i.issotrx = 'Y'
AND i.dateinvoiced >  $P{FromDate} AND i.dateinvoiced <  $P{ToDate} 
GROUP BY il.m_product_id),
StorageOnHandTotals AS (
SELECT m_product_id,SUM(qtyonhand) AS AvailableQty
FROM adempiere.m_storageonhand
WHERE DATE(datematerialpolicy) <  $P{ToDate} GROUP BY m_product_id),
BasePrice AS (
SELECT ol.m_product_id, MAX(ol.pricelimit) AS MaxPriceLimit
FROM adempiere.c_orderline ol
JOIN adempiere.c_order o ON o.c_order_id = ol.c_order_id
WHERE ol.ad_client_id =  $P{AD_CLIENT_ID} AND o.issotrx = 'N'
GROUP BY m_product_id),
PreviousMonth AS (
SELECT il.m_product_id,SUM(il.qtyinvoiced) AS TotalPQty,
SUM(il.linenetamt) AS TotalPNetAmount FROM adempiere.c_invoice i
JOIN adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
WHERE i.ad_client_id =  $P{AD_CLIENT_ID} AND i.issotrx = 'Y'
AND i.dateinvoiced >  $P{FromDate} ::DATE  -  INTERVAL '30 days'
AND i.dateinvoiced <  $P{ToDate} ::DATE -  INTERVAL '30 days' GROUP BY il.m_product_id)
SELECT pr.name AS ProductName,pr.m_product_id,COALESCE(i.TotalQty, 0) AS TotalQty,
ROUND(COALESCE(i.TotalNetAmount, 0), 2) AS TotalNetAmount,
ROUND(COALESCE(s.AvailableQty, 0), 0) AS AQty,cl.name AS ClientName,
ROUND(COALESCE(b.MaxPriceLimit * s.AvailableQty, 0), 2) AS AValue,
ROUND(COALESCE(pp.TotalPQty, 0), 0) AS PQty,ROUND(COALESCE(pp.TotalPNetAmount,0),2) AS PNetAmt
FROM adempiere.m_product pr
LEFT JOIN InvoiceLineTotals i ON pr.m_product_id = i.m_product_id
LEFT JOIN StorageOnHandTotals s ON pr.m_product_id = s.m_product_id
LEFT JOIN BasePrice b ON pr.m_product_id = b.m_product_id
LEFT JOIN PreviousMonth pp ON pr.m_product_id = pp.m_product_id
JOIN adempiere.ad_client cl ON cl.ad_client_id = pr.ad_client_id
WHERE pr.ad_client_id =  $P{AD_CLIENT_ID} 
AND ($P{ProductId} IS NULL OR pr.m_product_id IN ($P!{ProductId}))
ORDER BY pr.name



==================================================================================================================================================================
Design Part:- 

Q.If you convert your Report HTML to Pdf then show statis text different place 

Solution:- This problem only one solution not provide any space or tab you provide differenr static tab created and provude actual looking
			you see your problem is solve




==================================================================================================================================================================







==================================================================================================================================================================





==================================================================================================================================================================






==================================================================================================================================================================




==================================================================================================================================================================
Sales Representative Wise Sales Reports with Source code:-

<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Jaspersoft Studio version 6.20.6.final using JasperReports Library version 6.20.6-5c96b6aa8a39ac1dc6b6bea4b81168e16dd39231  -->
<jasperReport xmlns="http://jasperreports.sourceforge.net/jasperreports" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports http://jasperreports.sourceforge.net/xsd/jasperreport.xsd" name="AustrakReportWithSalesRep" pageWidth="595" pageHeight="842" columnWidth="555" leftMargin="20" rightMargin="20" topMargin="20" bottomMargin="20" uuid="1afa494a-8c22-41df-b4e2-488433d398a5">
	<property name="com.jaspersoft.studio.data.sql.tables" value=""/>
	<property name="com.jaspersoft.studio.data.defaultdataadapter" value="Idempiere Database Connection"/>
	<style name="AlternateRowColorStyle" mode="Opaque" backcolor="#FFFFFF" pattern="" isBlankWhenNull="false">
		<conditionalStyle>
			<conditionExpression><![CDATA[$V{REPORT_COUNT} % 2 == 0]]></conditionExpression>
			<style mode="Opaque" backcolor="#D4E3F4"/>
		</conditionalStyle>
	</style>
	<style name="AlternateRowColorStyle2" mode="Opaque" backcolor="#D4E3F4" pattern="" isBlankWhenNull="false">
		<conditionalStyle>
			<conditionExpression><![CDATA[$V{REPORT_COUNT} % 2 == 0]]></conditionExpression>
			<style mode="Opaque" forecolor="#0F0303" backcolor="#FFFFFF"/>
		</conditionalStyle>
	</style>
	<parameter name="AD_CLIENT_ID" class="java.lang.Integer"/>
	<parameter name="FromDate" class="java.sql.Timestamp"/>
	<parameter name="ToDate" class="java.sql.Timestamp"/>
	<parameter name="SalesRep_ID" class="java.lang.String"/>
	<queryString language="SQL">
		<![CDATA[SELECT 
    i.documentno AS invoice_number,
    bp.name AS Customer,
    br.ad_user_id,
    i.c_bpartner_id,
    i.salesrep_id,
    il.m_product_id,
    ad.name AS clientName,
    p.name AS productName,
    il.qtyinvoiced AS quantity,
    ROUND(linenetamt, 2) AS netAmt,
    br.name AS SalesRep,
    i.dateinvoiced 
FROM 
    adempiere.c_invoice i
JOIN 
    adempiere.c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
JOIN 
    adempiere.m_product p ON il.m_product_id = p.m_product_id
JOIN 
    adempiere.ad_user br ON i.salesrep_id = br.ad_user_id 
JOIN 
    adempiere.c_bpartner bp ON i.c_bpartner_id = bp.c_bpartner_id
JOIN 
    adempiere.ad_client ad ON ad.ad_client_id = i.ad_client_id
WHERE 
    i.issotrx = 'Y'  
    AND p.ad_client_id = $P{AD_CLIENT_ID}  
    AND i.dateinvoiced > $P{FromDate}     
    AND i.dateinvoiced < $P{ToDate}  
    AND (
       br.ad_user_id IN ($P!{SalesRep_ID}) OR $P{SalesRep_ID} IS NULL
    ) 
ORDER BY 
    i.salesrep_id, i.c_bpartner_id]]>
	</queryString>
	<field name="invoice_number" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="invoice_number"/>
		<property name="com.jaspersoft.studio.field.label" value="invoice_number"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoice"/>
	</field>
	<field name="customer" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="customer"/>
		<property name="com.jaspersoft.studio.field.label" value="customer"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_bpartner"/>
	</field>
	<field name="ad_user_id" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="ad_user_id"/>
		<property name="com.jaspersoft.studio.field.label" value="ad_user_id"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="ad_user"/>
	</field>
	<field name="c_bpartner_id" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="c_bpartner_id"/>
		<property name="com.jaspersoft.studio.field.label" value="c_bpartner_id"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoice"/>
	</field>
	<field name="salesrep_id" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="salesrep_id"/>
		<property name="com.jaspersoft.studio.field.label" value="salesrep_id"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoice"/>
	</field>
	<field name="m_product_id" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="m_product_id"/>
		<property name="com.jaspersoft.studio.field.label" value="m_product_id"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoiceline"/>
	</field>
	<field name="clientname" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="clientname"/>
		<property name="com.jaspersoft.studio.field.label" value="clientname"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="ad_client"/>
	</field>
	<field name="productname" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="productname"/>
		<property name="com.jaspersoft.studio.field.label" value="productname"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="m_product"/>
	</field>
	<field name="quantity" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="quantity"/>
		<property name="com.jaspersoft.studio.field.label" value="quantity"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoiceline"/>
	</field>
	<field name="netamt" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="netamt"/>
		<property name="com.jaspersoft.studio.field.label" value="netamt"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoiceline"/>
	</field>
	<field name="salesrep" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="salesrep"/>
		<property name="com.jaspersoft.studio.field.label" value="salesrep"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="ad_user"/>
	</field>
	<field name="dateinvoiced" class="java.sql.Timestamp">
		<property name="com.jaspersoft.studio.field.name" value="dateinvoiced"/>
		<property name="com.jaspersoft.studio.field.label" value="dateinvoiced"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="c_invoice"/>
	</field>
	<variable name="QtyusingCustmer" class="java.math.BigDecimal" resetType="Group" resetGroup="ProductGroup" calculation="Sum">
		<variableExpression><![CDATA[$F{quantity}]]></variableExpression>
	</variable>
	<variable name="AmtusingCustomer" class="java.math.BigDecimal" resetType="Group" resetGroup="ProductGroup" calculation="Sum">
		<variableExpression><![CDATA[$F{netamt}]]></variableExpression>
	</variable>
	<group name="SalesGroup">
		<groupExpression><![CDATA[$F{salesrep_id}]]></groupExpression>
		<groupHeader>
			<band height="21">
				<property name="com.jaspersoft.studio.unit.height" value="px"/>
				<staticText>
					<reportElement style="AlternateRowColorStyle" x="10" y="2" width="5" height="19" backcolor="#D4E3F4" uuid="c2128f88-7ac4-4b48-9c39-18f5d6e72e53">
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
					</reportElement>
					<text><![CDATA[]]></text>
				</staticText>
				<textField>
					<reportElement style="AlternateRowColorStyle" x="15" y="2" width="472" height="19" backcolor="#D4E3F4" uuid="ea4820b3-3638-4953-9dd9-9fd1e7879a40">
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
					</reportElement>
					<textElement verticalAlignment="Middle">
						<font size="12" isBold="true"/>
					</textElement>
					<textFieldExpression><![CDATA[$F{salesrep}]]></textFieldExpression>
				</textField>
			</band>
		</groupHeader>
	</group>
	<group name="ProductGroup">
		<groupExpression><![CDATA[$F{c_bpartner_id}]]></groupExpression>
		<groupHeader>
			<band height="22">
				<property name="com.jaspersoft.studio.unit.height" value="px"/>
				<staticText>
					<reportElement style="AlternateRowColorStyle2" x="10" y="2" width="5" height="20" backcolor="#FFFFFF" uuid="1eb467cd-baa2-468b-9bd1-e39bf3d1efa8">
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
					</reportElement>
					<text><![CDATA[]]></text>
				</staticText>
				<textField>
					<reportElement style="AlternateRowColorStyle2" x="15" y="2" width="472" height="20" backcolor="#FFFFFF" uuid="cda2f2f9-9eb7-4bce-99e2-8267113224e1">
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
					</reportElement>
					<textElement verticalAlignment="Middle" markup="none">
						<font fontName="Arial" size="10" isBold="true" isStrikeThrough="false"/>
					</textElement>
					<textFieldExpression><![CDATA[$F{customer}]]></textFieldExpression>
				</textField>
			</band>
		</groupHeader>
		<groupFooter>
			<band height="33">
				<staticText>
					<reportElement x="220" y="10" width="60" height="15" uuid="576f82ff-bd7c-455a-8a96-1ecef6c21c24">
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
					</reportElement>
					<textElement textAlignment="Right">
						<font isBold="true"/>
					</textElement>
					<text><![CDATA[TOTAL: ]]></text>
				</staticText>
				<textField>
					<reportElement x="270" y="10" width="80" height="15" uuid="18d5d666-616e-406a-aaa4-c490c27453f4">
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
					</reportElement>
					<textElement textAlignment="Right"/>
					<textFieldExpression><![CDATA[$V{QtyusingCustmer}]]></textFieldExpression>
				</textField>
				<textField>
					<reportElement x="360" y="10" width="80" height="15" uuid="973425d7-7feb-4344-ba1a-5502d1570928">
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.height" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
					</reportElement>
					<textElement textAlignment="Right"/>
					<textFieldExpression><![CDATA[$V{AmtusingCustomer}]]></textFieldExpression>
				</textField>
				<line>
					<reportElement x="230" y="27" width="220" height="1" forecolor="#000000" uuid="cd49a6dc-957f-4190-b539-46674b8a4cb7">
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
					</reportElement>
					<graphicElement>
						<pen lineWidth="1.5"/>
					</graphicElement>
				</line>
				<line>
					<reportElement x="230" y="5" width="220" height="1" forecolor="#000000" uuid="f531de9a-3b02-491f-b54e-c01fbe1db8de">
						<property name="com.jaspersoft.studio.unit.width" value="px"/>
						<property name="com.jaspersoft.studio.unit.y" value="px"/>
						<property name="com.jaspersoft.studio.unit.x" value="px"/>
					</reportElement>
					<graphicElement>
						<pen lineWidth="1.5"/>
					</graphicElement>
				</line>
			</band>
		</groupFooter>
	</group>
	<background>
		<band splitType="Stretch"/>
	</background>
	<title>
		<band height="50" splitType="Stretch">
			<property name="com.jaspersoft.studio.unit.height" value="px"/>
			<rectangle>
				<reportElement mode="Opaque" x="10" y="0" width="477" height="50" forecolor="#2563EB" backcolor="#2563EB" uuid="c91a0356-ce1e-4ace-8d0f-0581e3b47e13">
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
			</rectangle>
			<staticText>
				<reportElement x="15" y="5" width="275" height="14" forecolor="#FFFFFF" uuid="52b0de7a-98be-4a62-af68-75eb67452844">
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
				</reportElement>
				<textElement textAlignment="Left" verticalAlignment="Top" rotation="None">
					<font fontName="SansSerif" size="12" isBold="true"/>
				</textElement>
				<text><![CDATA[SALES REP WISE SALE SUMMARY FROM                ]]></text>
			</staticText>
			<textField>
				<reportElement x="288" y="5" width="180" height="14" forecolor="#FFFFFF" uuid="918e5b1d-305c-4b41-9234-0f87159993cd">
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement textAlignment="Left" verticalAlignment="Top">
					<font size="12" isBold="true"/>
				</textElement>
				<textFieldExpression><![CDATA[new SimpleDateFormat("dd/MM/yyyy").format($P{FromDate}) + " - " + new SimpleDateFormat("dd/MM/yyyy").format($P{ToDate})]]></textFieldExpression>
			</textField>
			<staticText>
				<reportElement x="15" y="18" width="75" height="14" forecolor="#FFFFFF" uuid="d67a5b22-b281-4b54-8e19-6a3e8176e887">
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
				</reportElement>
				<textElement textAlignment="Left" verticalAlignment="Middle">
					<font size="12" isBold="true"/>
				</textElement>
				<text><![CDATA[Company :  ]]></text>
			</staticText>
			<textField>
				<reportElement x="88" y="18" width="100" height="14" forecolor="#FFFFFF" uuid="4ac8bc98-35e8-42ec-80e8-c7a4f74b3329">
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement verticalAlignment="Middle">
					<font size="12" isBold="true"/>
				</textElement>
				<textFieldExpression><![CDATA[$F{clientname}]]></textFieldExpression>
			</textField>
			<staticText>
				<reportElement mode="Transparent" x="15" y="33" width="450" height="14" forecolor="#FFFFFF" uuid="6dee8050-17ba-4070-9191-ae7f4daa1b7c">
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
				</reportElement>
				<textElement verticalAlignment="Middle" markup="none">
					<font size="12" isBold="false"/>
				</textElement>
				<text><![CDATA[Description                                                         Quantity         NetAmount       ]]></text>
			</staticText>
		</band>
	</title>
	<detail>
		<band height="20" splitType="Stretch">
			<property name="com.jaspersoft.studio.unit.height" value="px"/>
			<staticText>
				<reportElement style="AlternateRowColorStyle" x="10" y="0" width="10" height="20" uuid="9d3ce2a2-74ca-4696-802a-83a11bd2d2b5">
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
				</reportElement>
				<text><![CDATA[]]></text>
			</staticText>
			<textField>
				<reportElement style="AlternateRowColorStyle" x="20" y="0" width="85" height="20" uuid="15551dd4-76be-4bee-9eaf-e6053c8adc9f">
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[$F{productname}]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement style="AlternateRowColorStyle" x="105" y="0" width="70" height="20" uuid="884ab001-909f-4e27-889e-2f5563f1cf15">
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[$F{invoice_number}]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement style="AlternateRowColorStyle" x="175" y="0" width="90" height="20" uuid="a7ad6fa8-4917-4a86-9483-777b0a7c5c8c">
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement textAlignment="Left" verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[new SimpleDateFormat("dd/MM/yyyy").format($F{dateinvoiced})]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement style="AlternateRowColorStyle" x="265" y="0" width="85" height="20" uuid="acfca24c-b4a9-4f52-838e-6a4b91ca72de">
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
				</reportElement>
				<textElement textAlignment="Right" verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[$F{quantity}]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement style="AlternateRowColorStyle" x="350" y="0" width="90" height="20" uuid="955ee758-7960-4f10-b1a2-38e862edfc5e">
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
				</reportElement>
				<textElement textAlignment="Right" verticalAlignment="Middle"/>
				<textFieldExpression><![CDATA[$F{netamt}]]></textFieldExpression>
			</textField>
			<staticText>
				<reportElement style="AlternateRowColorStyle" x="440" y="0" width="47" height="20" uuid="27539e87-97b8-48e0-b47f-13a2fef5b49a">
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
				</reportElement>
				<text><![CDATA[]]></text>
			</staticText>
		</band>
	</detail>
	<pageFooter>
		<band height="20">
			<property name="com.jaspersoft.studio.unit.height" value="px"/>
			<textField>
				<reportElement x="230" y="10" width="100" height="10" uuid="a5bef761-8624-4286-8603-5780490fd63f">
					<property name="com.jaspersoft.studio.unit.x" value="px"/>
					<property name="com.jaspersoft.studio.unit.y" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
				</reportElement>
				<textElement>
					<font size="8" isBold="true"/>
				</textElement>
				<textFieldExpression><![CDATA[$V{PAGE_NUMBER}]]></textFieldExpression>
			</textField>
		</band>
	</pageFooter>
</jasperReport>






==================================================================================================================================================================






==================================================================================================================================================================






==================================================================================================================================================================
