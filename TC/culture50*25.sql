<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Jaspersoft Studio version 6.20.6.final using JasperReports Library version 6.20.6-5c96b6aa8a39ac1dc6b6bea4b81168e16dd39231  -->
<jasperReport xmlns="http://jasperreports.sourceforge.net/jasperreports" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports http://jasperreports.sourceforge.net/xsd/jasperreport.xsd" name="PlantTag" pageWidth="142" pageHeight="71" columnWidth="138" leftMargin="2" rightMargin="2" topMargin="2" bottomMargin="2" uuid="4d0089cc-2cfa-4dea-9c26-1787bb8cb7b2">
	<property name="com.jaspersoft.studio.data.sql.tables" value=""/>
	<property name="com.jaspersoft.studio.data.defaultdataadapter" value="TCDev.jrdax"/>
	<parameter name="RECORD_ID" class="java.lang.Integer"/>
	<parameter name="AD_CLIENT_ID" class="java.lang.Integer"/>
	<queryString language="SQL">
		<![CDATA[SELECT cl.tc_virustesting_id AS virusId,cl.tc_culturestage_id AS cultureStageId,cl.tc_in_id AS inId,cl.tc_CultureLabel_id,cl.c_uuid AS UUId,cl.parentcultureline AS parentCultureLine,cl.cycleno AS cycleNo,cl.tcpf AS TCPF,cl.personal_code AS personalCode,
ps.codeno AS cropType,v.codeno AS Variety,ns.codeno AS natureSample,cs.codeno AS cultureStage,vt.codeno AS virusResult,mt.name AS mediaType,
mat.codeNo AS machineName,cl.tc_out_id AS outId,o.c_uuid AS outUUid,
cl.culturedate AS cultureDate,cl.isdiscarded As discard,cl.cultureoperationdate AS cultureOperationDate FROM adempiere.tc_cultureLabel cl
JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = cl.tc_species_id
JOIN adempiere.tc_variety v ON v.tc_variety_id = cl.tc_variety_id
JOIN adempiere.tc_naturesample ns ON ns.tc_naturesample_id = cl.tc_naturesample_id
JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = cl.tc_culturestage_id
JOIN adempiere.tc_virustesting vt ON vt.tc_virustesting_id = cl.tc_virustesting_id
JOIN adempiere.tc_mediatype mt ON mt.tc_mediatype_id = cl.tc_mediatype_id
JOIN adempiere.tc_out o ON o.tc_out_id = cl.tc_out_id
JOIN adempiere.tc_in i ON i.tc_in_id = cl.tc_in_id
JOIN adempiere.tc_machinetype mat ON mat.tc_machinetype_id = cl.tc_machinetype_id
WHERE cl.ad_client_id =  $P{AD_CLIENT_ID}  AND cl.tc_CultureLabel_id =  $P{RECORD_ID}]]>
	</queryString>
	<field name="virusid" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="virusid"/>
		<property name="com.jaspersoft.studio.field.label" value="virusid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="culturestageid" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="culturestageid"/>
		<property name="com.jaspersoft.studio.field.label" value="culturestageid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="inid" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="inid"/>
		<property name="com.jaspersoft.studio.field.label" value="inid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="tc_culturelabel_id" class="java.lang.Integer">
		<property name="com.jaspersoft.studio.field.name" value="tc_culturelabel_id"/>
		<property name="com.jaspersoft.studio.field.label" value="tc_culturelabel_id"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="uuid" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="uuid"/>
		<property name="com.jaspersoft.studio.field.label" value="uuid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="parentcultureline" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="parentcultureline"/>
		<property name="com.jaspersoft.studio.field.label" value="parentcultureline"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="cycleno" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="cycleno"/>
		<property name="com.jaspersoft.studio.field.label" value="cycleno"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="tcpf" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="tcpf"/>
		<property name="com.jaspersoft.studio.field.label" value="tcpf"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="personalcode" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="personalcode"/>
		<property name="com.jaspersoft.studio.field.label" value="personalcode"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="croptype" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="croptype"/>
		<property name="com.jaspersoft.studio.field.label" value="croptype"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_plantspecies"/>
	</field>
	<field name="variety" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="variety"/>
		<property name="com.jaspersoft.studio.field.label" value="variety"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_variety"/>
	</field>
	<field name="naturesample" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="naturesample"/>
		<property name="com.jaspersoft.studio.field.label" value="naturesample"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_naturesample"/>
	</field>
	<field name="culturestage" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="culturestage"/>
		<property name="com.jaspersoft.studio.field.label" value="culturestage"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturestage"/>
	</field>
	<field name="virusresult" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="virusresult"/>
		<property name="com.jaspersoft.studio.field.label" value="virusresult"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_virustesting"/>
	</field>
	<field name="mediatype" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="mediatype"/>
		<property name="com.jaspersoft.studio.field.label" value="mediatype"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_mediatype"/>
	</field>
	<field name="machinename" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="machinename"/>
		<property name="com.jaspersoft.studio.field.label" value="machinename"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_machinetype"/>
	</field>
	<field name="outid" class="java.math.BigDecimal">
		<property name="com.jaspersoft.studio.field.name" value="outid"/>
		<property name="com.jaspersoft.studio.field.label" value="outid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="outuuid" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="outuuid"/>
		<property name="com.jaspersoft.studio.field.label" value="outuuid"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_out"/>
	</field>
	<field name="culturedate" class="java.sql.Date">
		<property name="com.jaspersoft.studio.field.name" value="culturedate"/>
		<property name="com.jaspersoft.studio.field.label" value="culturedate"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="discard" class="java.lang.String">
		<property name="com.jaspersoft.studio.field.name" value="discard"/>
		<property name="com.jaspersoft.studio.field.label" value="discard"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<field name="cultureoperationdate" class="java.sql.Date">
		<property name="com.jaspersoft.studio.field.name" value="cultureoperationdate"/>
		<property name="com.jaspersoft.studio.field.label" value="cultureoperationdate"/>
		<property name="com.jaspersoft.studio.field.tree.path" value="tc_culturelabel"/>
	</field>
	<background>
		<band splitType="Stretch"/>
	</background>
	<pageHeader>
		<band height="67" splitType="Stretch">
			<property name="com.jaspersoft.studio.unit.height" value="px"/>
			<componentElement>
				<reportElement x="20" y="17" width="43" height="43" uuid="e6f739f2-e335-452c-af47-a0e11d8903f2">
					<property name="com.jaspersoft.studio.unit.width" value="px"/>
					<property name="com.jaspersoft.studio.unit.height" value="px"/>
				</reportElement>
				<jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
					<jr:codeExpression><![CDATA["{\"o\":\"$F{outuuid}\",\"m\":\"$F{machinename}\",\"c\":\"$F{uuid}\"}"]]></jr:codeExpression>
				</jr:QRCode>
			</componentElement>
			<textField>
				<reportElement x="5" y="2" width="128" height="13" uuid="568854d5-6f25-4ce8-8595-ab3c69937dd2"/>
				<textElement textAlignment="Center" verticalAlignment="Middle">
					<font size="2"/>
				</textElement>
				<textFieldExpression><![CDATA[$F{croptype} + " " + $F{variety} + " " +  $F{parentcultureline}  + " "+ new SimpleDateFormat("ddMMyy").format($F{culturedate}) + " "  + $F{naturesample} + " " + $F{culturestage} + " " + $F{cycleno} + " " + $F{virusresult}]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement x="70" y="26" width="63" height="23" uuid="870da6f3-11b3-4b48-934f-28a143ebe54f"/>
				<textElement textAlignment="Center" verticalAlignment="Middle">
					<font size="2"/>
				</textElement>
				<textFieldExpression><![CDATA[$F{tcpf} + " " + new SimpleDateFormat("ddMMyy").format($F{cultureoperationdate})+ " " + $F{machinename} + " " + $F{personalcode}]]></textFieldExpression>
			</textField>
			<textField>
				<reportElement x="4" y="28" width="14" height="17" uuid="079da823-40ce-4107-960d-cf75b4a82fd2"/>
				<textElement textAlignment="Center" verticalAlignment="Middle">
					<font size="2"/>
				</textElement>
				<textFieldExpression><![CDATA[$F{mediatype}]]></textFieldExpression>
			</textField>
		</band>
	</pageHeader>
</jasperReport>
