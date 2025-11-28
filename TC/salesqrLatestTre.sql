Sales Qr Latest Query:-

WITH RECURSIVE cte AS (
    SELECT 
        cl.parentuuid,
        cl.c_uuid,
        cl.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.tc_culturelabel cl
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(cl.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')

    UNION ALL
    SELECT 
        phs.cultureuuid AS parentuuid,
        cl.c_uuid,
        cl.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.TC_PrimaryHardeningLabel ph 
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')

    UNION ALL
    SELECT 
        phs.cultureuuid AS parentuuid,
        cl.c_uuid,
        cl.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.TC_SecondaryHardeningLabel sh 
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')

    UNION ALL
    SELECT 
        cl2.parentuuid,
        cl2.c_uuid,
        cl2.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM cte 
    JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
    JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id
),

culture_result AS (
    SELECT 
        cte.parentuuid,
        cte.c_uuid,
        cte.created,
        cte.variety,
        cte.village,
        cte.talukname,
        cte.district,cte.collection_updated_date
    FROM cte
    GROUP BY cte.parentuuid, cte.c_uuid, cte.created, cte.variety, cte.village, cte.talukname, cte.district,cte.collection_updated_date

    UNION ALL
    SELECT DISTINCT 
        tcc.parentuuid,
        tcc.c_uuid,
        tcc.created,
        cte.variety,
        cte.village,
        cte.talukname,
        cte.district,NULL AS collection_updated_date
    FROM cte 
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid

    UNION ALL
    SELECT DISTINCT 
        NULL,
        tpt.c_uuid,
        tpt.created,
        cte.variety,
        f.villagename2 AS village,
        f.talukname,
        f.district,TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date
    FROM cte 
    LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
    LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
	JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
    JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
    WHERE tpt.c_uuid IS NOT NULL
),

explant_result AS (
    SELECT DISTINCT 
        tcc.parentuuid,
        tcc.c_uuid,
        tcc.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.tc_explantlabel tcc 
    JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')

    UNION ALL
    SELECT DISTINCT 
        NULL,
        tpt.c_uuid,
        tpt.created,
        var.name AS variety,
        f.villagename2 AS village,
        f.talukname,
        f.district,TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date
    FROM adempiere.tc_planttag tpt 
    JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
	JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
    JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tcc.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
      AND tpt.c_uuid IS NOT NULL
),

plant_tag_result AS (
    SELECT DISTINCT 
        NULL,
        tpt.c_uuid,
        tpt.created,
        var.name AS variety,
        f.villagename2 AS village,
        f.talukname,
        f.district,TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date
    FROM adempiere.tc_planttag tpt 
    JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
	JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
    JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
    WHERE TRIM(tpt.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
),

primary_result AS (
    SELECT 
        phs.cultureuuid AS parentuuid,
        ph.c_uuid,
        ph.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.TC_PrimaryHardeningLabel ph 
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(ph.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
),

secondary_result AS (
    SELECT 
        sh.parentuuid,
        sh.c_uuid,
        sh.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.TC_SecondaryHardeningLabel sh 
    JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')

    UNION ALL
    SELECT 
        phs.cultureuuid AS parentuuid,
        ph.c_uuid,
        ph.created,
        var.name AS variety,
        NULL AS village,
        NULL AS talukname,
        NULL AS district,NULL AS collection_updated_date
    FROM adempiere.TC_SecondaryHardeningLabel sh 
    JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
    JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
    JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id
    WHERE TRIM(sh.c_uuid) = TRIM('b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
)

SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result
WHERE NOT EXISTS (SELECT 1 FROM explant_result) 
  AND NOT EXISTS (SELECT 1 FROM culture_result)
ORDER BY created ASC 
LIMIT 1;
=================================================================================================================
Final Short Query;-

WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE cl.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE ph.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE sh.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'
UNION ALL
SELECT cl2.parentuuid,cl2.c_uuid,cl2.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM cte JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id),
culture_result AS (
SELECT cte.parentuuid,cte.c_uuid,cte.created,cte.variety,cte.village,cte.talukname,cte.district,cte.collection_updated_date
FROM cte GROUP BY cte.parentuuid, cte.c_uuid, cte.created, cte.variety, cte.village, cte.talukname, cte.district, cte.collection_updated_date
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,cte.variety,cte.village,cte.talukname,cte.district,NULL AS collection_updated_date
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,cte.variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id WHERE tpt.c_uuid IS NOT NULL),
explant_result AS (
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id WHERE tcc.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tcc.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8' AND tpt.c_uuid IS NOT NULL),
plant_tag_result AS (
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tpt.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'),
primary_result AS (
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE ph.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'),
secondary_result AS (
SELECT sh.parentuuid,sh.c_uuid,sh.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
WHERE sh.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8'
UNION ALL
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh
JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE sh.c_uuid = 'b451dfaf-f068-4e31-beaf-6fa18e9bbae8')
SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result) ORDER BY created ASC LIMIT 1;
========================================================================================================================================
INVOICE <=> SALES QR:-

SELECT 
    -- All fields of Query-1
    iv.c_invoice_id,
    iv.documentno AS Invoice_No,
    TO_CHAR(iv.DateInvoiced, 'DD-Mon-YYYY') AS Date_Invoiced,
    org.name AS OrgName,
    org_loc.address AS org_address,
    org_loc.city AS org_city,
    org_loc.regionname AS org_regionname,
    org_loc.countryname AS org_countryname,
    org_loc.postal AS org_postal,
    bp_loc.address AS bp_address,
    bp_loc.city AS bp_city,
    bp_loc.regionname AS bp_regionname,
    bp_loc.countryname AS bp_countryname,
    bp_loc.postal AS bp_postal,
    ivl.description,
    (CASE WHEN ivl.m_product_id>0 THEN mp.name ELSE cha.name END) AS item,
    iv.totallines AS SubTotal,
    iv.grandtotal AS Total_Amount,
    (iv.grandtotal-iv.totallines) AS Tax_Amount,
    ivl.line AS Product_SNo,
    mp.name AS Product_Name,
    ivl.qtyinvoiced AS Product_Qty_Invoiced,
    ROUND(ivl.priceentered,2) AS Product_Price_Entered,
    cr.iso_code AS Product_Currency_Name,
    tax.name AS Product_Tax_Name,
    tax.rate AS Product_Tax_Rate,
    ivl.taxamt AS Product_Tax_Amount,
    mp.hsncode AS Product_HSN,
    ivl.linenetamt AS Product_Line_Amount,
    iv.description,
    iv.poreference,
    bp.name AS customer_name,

    -- Hardening values
    TO_CHAR(
        CASE 
            WHEN sh.created IS NOT NULL THEN sh.created
            WHEN ph.created IS NOT NULL THEN ph.created
            ELSE NULL
        END,
        'DD/MM/YYYY'
    ) AS date_of_hardening,

    CASE 
        WHEN sh.parentcultureline IS NOT NULL THEN sh.parentcultureline
        WHEN ph.parentcultureline IS NOT NULL THEN ph.parentcultureline
        ELSE NULL
    END AS parentcultureline,

    CASE 
        WHEN sh.tc_variety_id IS NOT NULL THEN tv_sh.name
        WHEN ph.tc_variety_id IS NOT NULL THEN tv_ph.name
    END AS variety,

    cor.secondaryhardeninguuid,

    -- ***** ADDING 4 FIELDS FROM QUERY-2 HERE *****
    q2.village,
    q2.talukname,
    q2.district,
    q2.collection_updated_date,

    -- remaining fields
    cr.description AS currency_name,
    wh.name AS wareName,
    ware_loc.address AS ware_address,
    ware_loc.city AS ware_city,
    ware_loc.regionname AS ware_regionname,
    io.documentno AS InOutNo,
    TO_CHAR(io.movementdate, 'DD-Mon-YYYY') AS InOutDate,
    ware_loc.countryname AS ware_countryname,
    ware_loc.postal AS ware_postal,
    orginfo.Phone,
    cli.gstno AS client_gstno,
    cli.panno AS client_panno,
    bp.gstno AS bp_gstno,
    bp.panno AS bp_panno,
    cr.cursymbol,
    ENCODE(org_img.binarydata,'base64') AS logo_binarydata,
    cli.Name AS companyname

FROM adempiere.c_invoice iv
LEFT JOIN adempiere.c_invoiceline ivl ON (iv.c_invoice_id=ivl.c_invoice_id)
LEFT JOIN adempiere.c_order cor ON (cor.c_order_id = iv.c_order_id)
LEFT JOIN adempiere.m_inout io ON (cor.c_order_id=io.c_order_id)
LEFT JOIN adempiere.c_bpartner bp ON (bp.c_bpartner_id=iv.c_bpartner_id)
LEFT JOIN adempiere.ad_org org ON (org.AD_Org_ID=iv.AD_Org_ID)
LEFT JOIN adempiere.ad_orginfo orginfo ON (orginfo.AD_Org_ID=iv.AD_Org_ID)
LEFT JOIN adempiere.ad_image org_img ON (orginfo.Logo_ID=org_img.ad_image_id)
LEFT JOIN adempiere.m_warehouse wh ON (wh.m_warehouse_id=orginfo.m_warehouse_id)
LEFT JOIN adempiere.ad_client cli ON (cli.ad_client_id=iv.ad_client_id)
LEFT JOIN adempiere.location_details ware_loc ON (ware_loc.c_location_id=wh.c_location_id)
LEFT JOIN adempiere.location_details org_loc ON (org_loc.c_location_id=orginfo.c_location_id)
LEFT JOIN adempiere.c_bpartner_location bpl ON (bpl.c_bpartner_location_id=iv.c_bpartner_location_id)
LEFT JOIN adempiere.location_details bp_loc ON (bp_loc.c_location_id=bpl.c_location_id)
LEFT JOIN adempiere.m_product mp ON (mp.m_product_id=ivl.m_product_id)
LEFT JOIN adempiere.c_charge cha ON (cha.c_charge_id=ivl.c_charge_id)
LEFT JOIN adempiere.c_uom uom ON (uom.c_uom_id=ivl.c_uom_id)
LEFT JOIN adempiere.c_tax tax ON (tax.c_tax_id=ivl.c_tax_id)
LEFT JOIN adempiere.c_currency cr ON (cr.c_currency_id=iv.c_currency_id)

LEFT JOIN adempiere.TC_SecondaryHardeningLabel sh ON sh.c_uuid = cor.secondaryhardeninguuid
LEFT JOIN adempiere.TC_PrimaryHardeningLabel ph ON ph.c_uuid = cor.secondaryhardeninguuid
LEFT JOIN adempiere.tc_variety tv_sh ON tv_sh.tc_variety_id = sh.tc_variety_id
LEFT JOIN adempiere.tc_variety tv_ph ON tv_ph.tc_variety_id = ph.tc_variety_id

-- ************ QUERY-2 AS CORRELATED SUBQUERY ************
LEFT JOIN LATERAL (

	WITH RECURSIVE cte AS (
SELECT cl.parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.tc_culturelabel cl JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE cl.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE ph.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,cl.c_uuid,cl.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_culturelabel cl ON phs.cultureuuid = cl.c_uuid JOIN adempiere.tc_variety var ON var.tc_variety_id = cl.tc_variety_id
WHERE sh.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT cl2.parentuuid,cl2.c_uuid,cl2.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM cte JOIN adempiere.tc_culturelabel cl2 ON cte.parentuuid = cl2.c_uuid
JOIN adempiere.tc_variety var ON var.tc_variety_id = cl2.tc_variety_id),
culture_result AS (
SELECT cte.parentuuid,cte.c_uuid,cte.created,cte.variety,cte.village,cte.talukname,cte.district,cte.collection_updated_date
FROM cte GROUP BY cte.parentuuid, cte.c_uuid, cte.created, cte.variety, cte.village, cte.talukname, cte.district, cte.collection_updated_date
UNION ALL
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,cte.variety,cte.village,cte.talukname,cte.district,NULL AS collection_updated_date
FROM cte LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,cte.variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM cte
LEFT JOIN adempiere.tc_explantlabel tcc ON cte.parentuuid = tcc.c_uuid LEFT JOIN adempiere.tc_planttag tpt ON tcc.parentuuid = tpt.c_uuid
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id WHERE tpt.c_uuid IS NOT NULL),
explant_result AS (
SELECT DISTINCT tcc.parentuuid,tcc.c_uuid,tcc.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.tc_explantlabel tcc
JOIN adempiere.tc_variety var ON var.tc_variety_id = tcc.tc_variety_id WHERE tcc.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_explantlabel tcc ON tcc.parentuuid = tpt.c_uuid JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid
JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tcc.c_uuid = cor.secondaryhardeninguuid AND tpt.c_uuid IS NOT NULL),
plant_tag_result AS (
SELECT DISTINCT NULL,tpt.c_uuid,tpt.created,var.name AS variety,f.villagename2 AS village,f.talukname,f.district,
TO_CHAR(cp.updated, 'DD/MM/YYYY') AS collection_updated_date FROM adempiere.tc_planttag tpt
JOIN adempiere.tc_plantdetails pd ON pd.planttaguuid = tpt.c_uuid JOIN adempiere.TC_collectionjoinplant cp ON cp.TC_PlantDetails_ID = pd.TC_PlantDetails_ID
JOIN adempiere.tc_farmer f ON pd.tc_farmer_id = f.tc_farmer_id JOIN adempiere.tc_variety var ON var.tc_variety_id = pd.tc_variety_id
WHERE tpt.c_uuid = cor.secondaryhardeninguuid),
primary_result AS (
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_PrimaryHardeningLabel ph
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE ph.c_uuid = cor.secondaryhardeninguuid),
secondary_result AS (
SELECT sh.parentuuid,sh.c_uuid,sh.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,NULL AS collection_updated_date
FROM adempiere.TC_SecondaryHardeningLabel sh JOIN adempiere.tc_variety var ON var.tc_variety_id = sh.tc_variety_id
WHERE sh.c_uuid = cor.secondaryhardeninguuid
UNION ALL
SELECT phs.cultureuuid AS parentuuid,ph.c_uuid,ph.created,var.name AS variety,NULL AS village,NULL AS talukname,NULL AS district,
NULL AS collection_updated_date FROM adempiere.TC_SecondaryHardeningLabel sh
JOIN adempiere.TC_PrimaryHardeningLabel ph ON sh.parentuuid = ph.c_uuid
JOIN adempiere.tc_primaryHardeningcultureS phs ON phs.TC_PrimaryHardeningLabel_id = ph.TC_PrimaryHardeningLabel_id
JOIN adempiere.tc_variety var ON var.tc_variety_id = ph.tc_variety_id WHERE sh.c_uuid = cor.secondaryhardeninguuid)
SELECT * FROM secondary_result
UNION ALL
SELECT * FROM primary_result
UNION ALL
SELECT * FROM culture_result
WHERE (parentuuid IS NULL OR parentuuid <> c_uuid)
UNION ALL
SELECT * FROM explant_result WHERE NOT EXISTS (SELECT 1 FROM culture_result)
UNION ALL
SELECT * FROM plant_tag_result
WHERE NOT EXISTS (SELECT 1 FROM explant_result) AND NOT EXISTS (SELECT 1 FROM culture_result) ORDER BY created ASC LIMIT 1
	
) q2 ON TRUE

WHERE (iv.C_Invoice_ID = 1000034) 
  AND iv.ad_client_id = 1000002

ORDER BY ivl.line;
==============================================================================================================