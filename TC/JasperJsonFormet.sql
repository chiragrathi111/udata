Jasper Qr show Json formet data with seperate line:-

"{" + System.getProperty("line.separator") +
  "\"CropType\": \"" + $F{croptype} + "\"," + System.getProperty("line.separator") +
  "\"Variety\": \"" + $F{variety} + "\"," + System.getProperty("line.separator") +
  "\"ParentCultureLine\": \"" + $F{parentcultureline} + "\"," + System.getProperty("line.separator") +
  "\"Date\": \"" + $F{date} + "\"," + System.getProperty("line.separator") +
  "\"NatureOfSample\": \"" + $F{naturesample} + "\"," + System.getProperty("line.separator") +
  "\"CultureSubStage\": \"" + $F{culturestage} + "\"," + System.getProperty("line.separator") +
  "\"CycleNumber\": \"" + $F{cycleno} + "\"," + System.getProperty("line.separator") +
  "\"VirusTestingResult\": \"" + $F{virusresult} + "\"" + System.getProperty("line.separator") +
"}"


Jasper data in same line:-

"{" +
  "\"Crop Type\": \"" + $F{croptype} + "\"," +
  "\"Variety\": \"" + $F{variety} + "\"" +
"}"



===========================================================================================================================================
<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Jaspersoft Studio version 6.20.6.final using JasperReports Library version 6.20.6-5c96b6aa8a39ac1dc6b6bea4b81168e16dd39231  -->
<jasperReport xmlns="http://jasperreports.sourceforge.net/jasperreports" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports http://jasperreports.sourceforge.net/xsd/jasperreport.xsd" name="traNew" pageWidth="595" pageHeight="842" columnWidth="555" leftMargin="20" rightMargin="20" topMargin="20" bottomMargin="20" uuid="25a5b912-be7e-4364-9bb4-0e9f122a26de">
  <property name="com.jaspersoft.studio.data.sql.tables" value=""/>
  <property name="com.jaspersoft.studio.data.defaultdataadapter" value="Tissue.jrdax"/>
  <parameter name="AD_CLIENT_ID" class="java.lang.Integer"/>
  <parameter name="CultureLabelUUId" class="java.lang.String"/>
  <queryString language="SQL">
    <![CDATA[WITH RECURSIVE cte AS (
  -- Anchor query
  SELECT l.parentuuid, l.tc_in_id, l.tc_out_id, l.c_uuid, lo.value AS location, l.created, l.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         l.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 1 AS level
  FROM adempiere.tc_culturelabel l
  JOIN adempiere.tc_out o ON o.tc_out_id = l.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = l.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = l.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = l.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
  WHERE l.c_uuid = '32f0ba8d-1c87-49e0-b2d8-970634eb5732' AND l.ad_client_id = 1000000

  UNION ALL

  -- Recursive query
  SELECT t2.parentuuid, t2.tc_in_id, t2.tc_out_id, t2.c_uuid, lo.value AS location, t2.created, t2.cycleno, ps.name AS cropType, cs.name AS stage, v.name AS variety,
         t2.personal_code, ts.temperature AS temp, ts.humidity AS humidity, 2 AS level
  FROM cte t1
  JOIN adempiere.tc_culturelabel t2 ON t1.parentuuid = t2.c_uuid
  JOIN adempiere.tc_out o ON o.tc_out_id = t2.tc_out_id
  JOIN adempiere.m_locator lo ON lo.m_locator_id = o.m_locator_id
  JOIN adempiere.tc_plantspecies ps ON ps.tc_plantspecies_id = t2.tc_species_id
  JOIN adempiere.tc_culturestage cs ON cs.tc_culturestage_id = t2.tc_culturestage_id
  JOIN adempiere.tc_variety v ON v.tc_variety_id = t2.tc_species_ids
  JOIN adempiere.m_locatortype lt ON lt.m_locatortype_id = lo.m_locatortype_id
  JOIN (SELECT ts.m_locatortype_id, MAX(ts.created) AS max_created
       FROM adempiere.tc_temperaturestatus ts
       GROUP BY ts.m_locatortype_id) max_ts ON max_ts.m_locatortype_id = lo.m_locatortype_id
  JOIN adempiere.tc_temperaturestatus ts ON ts.m_locatortype_id = lo.m_locatortype_id AND ts.created = max_ts.max_created
)
SELECT * FROM cte;]]>
  </queryString>
  <field name="parentuuid" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="parentuuid"/>
    <property name="com.jaspersoft.studio.field.label" value="parentuuid"/>
  </field>
  <field name="tc_in_id" class="java.math.BigDecimal">
    <property name="com.jaspersoft.studio.field.name" value="tc_in_id"/>
    <property name="com.jaspersoft.studio.field.label" value="tc_in_id"/>
  </field>
  <field name="tc_out_id" class="java.math.BigDecimal">
    <property name="com.jaspersoft.studio.field.name" value="tc_out_id"/>
    <property name="com.jaspersoft.studio.field.label" value="tc_out_id"/>
  </field>
  <field name="c_uuid" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="c_uuid"/>
    <property name="com.jaspersoft.studio.field.label" value="c_uuid"/>
  </field>
  <field name="location" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="location"/>
    <property name="com.jaspersoft.studio.field.label" value="location"/>
  </field>
  <field name="created" class="java.sql.Timestamp">
    <property name="com.jaspersoft.studio.field.name" value="created"/>
    <property name="com.jaspersoft.studio.field.label" value="created"/>
  </field>
  <field name="cycleno" class="java.math.BigDecimal">
    <property name="com.jaspersoft.studio.field.name" value="cycleno"/>
    <property name="com.jaspersoft.studio.field.label" value="cycleno"/>
  </field>
  <field name="croptype" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="croptype"/>
    <property name="com.jaspersoft.studio.field.label" value="croptype"/>
  </field>
  <field name="stage" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="stage"/>
    <property name="com.jaspersoft.studio.field.label" value="stage"/>
  </field>
  <field name="variety" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="variety"/>
    <property name="com.jaspersoft.studio.field.label" value="variety"/>
  </field>
  <field name="personal_code" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="personal_code"/>
    <property name="com.jaspersoft.studio.field.label" value="personal_code"/>
  </field>
  <field name="temp" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="temp"/>
    <property name="com.jaspersoft.studio.field.label" value="temp"/>
  </field>
  <field name="humidity" class="java.lang.String">
    <property name="com.jaspersoft.studio.field.name" value="humidity"/>
    <property name="com.jaspersoft.studio.field.label" value="humidity"/>
  </field>
  <field name="level" class="java.lang.Integer">
    <property name="com.jaspersoft.studio.field.name" value="level"/>
    <property name="com.jaspersoft.studio.field.label" value="level"/>
  </field>
  <background>
    <band splitType="Stretch"/>
  </background>
  <title>
    <band height="34" splitType="Stretch">
      <rectangle>
        <reportElement mode="Opaque" x="0" y="3" width="528" height="30" forecolor="#298F60" backcolor="#298F60" uuid="d1ec235c-d8a7-45bc-aed8-fef72f96cf67">
          <property name="com.jaspersoft.studio.unit.width" value="px"/>
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
          <property name="com.jaspersoft.studio.unit.y" value="px"/>
          <property name="com.jaspersoft.studio.unit.x" value="px"/>
        </reportElement>
      </rectangle>
      <staticText>
        <reportElement x="23" y="5" width="450" height="22" forecolor="#FFFFFF" backcolor="#FFFFFF" uuid="6b4cab65-b9d5-4f79-8019-35afce2463de">
          <property name="com.jaspersoft.studio.unit.width" value="px"/>
          <property name="com.jaspersoft.studio.unit.y" value="px"/>
        </reportElement>
        <textElement verticalAlignment="Middle">
          <font size="18" isBold="true"/>
        </textElement>
        <text><![CDATA[Traceability]]></text>
      </staticText>
    </band>
  </title>
  <detail>
    <band height="197" splitType="Stretch">
      <rectangle>
        <reportElement x="208" y="0" width="202" height="171" backcolor="#FCF74C" uuid="922b4b24-68b5-4350-a529-f91e614cf90a">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
      </rectangle>
      <textField>
        <reportElement x="212" y="39" width="60" height="12" uuid="0aff3d87-ea83-413b-a0a2-752d51a3119f">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
          <property name="com.jaspersoft.studio.unit.width" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA[$F{croptype}]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="52" width="60" height="12" uuid="91b8b7c2-1d2b-49f5-b7d7-0cfe3ca4b744">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
          <property name="com.jaspersoft.studio.unit.width" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA[$F{variety}]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="109" width="100" height="12" uuid="e22221fe-1260-468e-922a-f0a041bdab84">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA[new SimpleDateFormat("dd/MM/yyyy").format($F{created})]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement style="Stage1Style" x="212" y="66" width="124" height="12" uuid="648d977e-3762-4f6b-b13e-9fda498b104a">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["Stage: "+$F{stage}]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="80" width="100" height="12" uuid="734c2a81-6541-436f-8d1e-168d7039cc43">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["Cycle: "+$F{cycleno}]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="95" width="100" height="12" uuid="213558b3-9b75-4aff-97cd-dd7bec41fdda">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["User: "+$F{personal_code}]]></textFieldExpression>
      </textField>
      <componentElement>
        <reportElement x="210" y="1" width="60" height="39" uuid="3cca4daf-da9d-4d8e-ba5c-dd3c2059db21">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
          <property name="com.jaspersoft.studio.unit.y" value="px"/>
          <property name="com.jaspersoft.studio.unit.width" value="px"/>
        </reportElement>
        <jr:QRCode xmlns:jr="http://jasperreports.sourceforge.net/jasperreports/components" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports/components http://jasperreports.sourceforge.net/xsd/components.xsd">
          <jr:codeExpression><![CDATA["CultureLabelUUId: "+$F{c_uuid}]]></jr:codeExpression>
        </jr:QRCode>
      </componentElement>
      <textField>
        <reportElement x="212" y="123" width="100" height="12" uuid="7919b278-e02e-4833-b7f0-b80594bfcbfb">
          <printWhenExpression><![CDATA[$V{REPORT_COUNT} == 1]]></printWhenExpression>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["Location: "+$F{location}]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="137" width="142" height="12" uuid="3627caa7-5965-439c-99e6-0953e93c0fb9">
          <printWhenExpression><![CDATA[$V{REPORT_COUNT} == 1]]></printWhenExpression>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["Temperature: " + $F{temp} + " °C"]]></textFieldExpression>
      </textField>
      <textField>
        <reportElement x="212" y="151" width="142" height="12" uuid="8cc90705-f5bc-4190-8dbd-d00be49518c8">
          <printWhenExpression><![CDATA[$V{REPORT_COUNT} == 1]]></printWhenExpression>
        </reportElement>
        <textElement textAlignment="Left"/>
        <textFieldExpression><![CDATA["Humidity: "+$F{humidity}+" g/kg"]]></textFieldExpression>
      </textField>
      <line>
        <reportElement x="301" y="171" width="1" height="24" uuid="dfbb478f-2399-4029-af0c-e8acb7f75572">
          <property name="com.jaspersoft.studio.unit.height" value="px"/>
        </reportElement>
      </line>
      <textField>
        <reportElement x="265" y="4" width="125" height="30" uuid="0e4475aa-f924-464f-9d08-18f91b7ff00d"/>
        <textElement verticalAlignment="Middle">
          <font isBold="true"/>
        </textElement>
        <textFieldExpression><![CDATA[$F{c_uuid}]]></textFieldExpression>
      </textField>
    </band>
  </detail>
</jasperReport>
