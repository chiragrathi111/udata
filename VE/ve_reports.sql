* Storage Details By Locator:-

CREATE OR REPLACE VIEW adempiere.pi_storageDetailByLocator AS 
SELECT w.m_warehouse_id,pr.m_product_category_id,pp.m_product_id,uom.name AS uom,pbom.PP_Product_BOM_ID,l.m_locatortype_id,pp.m_locator_id,
SUM(CASE WHEN pp.issotrx = 'N' THEN pp.quantity ELSE 0 END) AS availableCount,d.pi_deptartment_id,
pr.value,pr.created As m_product_created,pr.createdby AS m_product_createdby,pr.updated AS m_product_updated,pr.updatedby AS m_product_updatedby,
pr.isactive AS product_isactive,l.isactive AS locator_isactive,pp.ad_client_id,pp.ad_org_id
FROM adempiere.pi_productlabel pp JOIN adempiere.m_product pr ON pr.m_product_id = pp.m_product_id LEFT JOIN adempiere.PP_Product_BOM pbom ON pbom.m_product_id = pr.m_product_id
JOIN adempiere.m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id JOIN adempiere.c_uom uom ON uom.c_uom_id = pr.c_uom_id
JOIN adempiere.m_locator l ON l.m_locator_id = pp.m_locator_id JOIN adempiere.m_warehouse w ON w.m_warehouse_id = l.m_warehouse_id
LEFT JOIN adempiere.pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id LEFT JOIN adempiere.m_locatortype ltt ON ltt.m_locatortype_id = l.m_locatortype_id
WHERE pp.islabeldiscarded = 'N' AND ltt.returns = 'N' AND  NOT EXISTS (SELECT 1 FROM adempiere.pi_productlabel pp_sales WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y')
GROUP BY pp.m_product_id,w.m_warehouse_id,uom.name,pp.ad_client_id,pp.ad_org_id,pr.isactive,l.isactive,l.m_locatortype_id, 
pp.m_locator_id,pr.m_product_category_id,d.pi_deptartment_id,pbom.PP_Product_BOM_ID,pr.value,pr.created,pr.createdby,pr.updated,pr.updatedby Order BY pp.m_locator_id desc;


--------------------------------------------------------------------------------------------------------------
* Reprint for Packing & Assembly:-

SELECT pl.pi_productlabel_id,pl.quantity,pl.labeluuid,pl.m_product_id,pl.pi_paorder_id,pr.name AS productName
FROM adempiere.pi_productlabel pl
JOIN adempiere.m_product pr ON pr.m_product_id = pl.m_product_id
JOIN adempiere.pi_paorder pa ON pa.pi_paorder_id = pl.pi_paorder_id
WHERE pl.AD_Client_ID = $P{AD_CLIENT_ID} AND pl.islabeldiscarded = 'N'
AND pl.pi_paorder_id =  $P{RECORD_ID};


-----------------------------------------------------------------------------------------------------------------
 SELECT pr.m_product_category_id,
    pp.m_product_id,
    uom.name AS uom,
    pbom.pp_product_bom_id,
    sum(
        CASE
            WHEN pp.issotrx = 'N'::bpchar THEN pp.quantity
            ELSE 0::numeric
        END) AS availablecount,
    pr.value,
    pr.created AS m_product_created,
    pr.createdby AS m_product_createdby,
    pr.updated AS m_product_updated,
    pr.updatedby AS m_product_updatedby,
    pr.isactive AS product_isactive,
    pp.ad_client_id,
    pp.ad_org_id,
    d.pi_deptartment_id,
    l.m_warehouse_id
   FROM pi_productlabel pp
     JOIN m_product pr ON pr.m_product_id = pp.m_product_id
     LEFT JOIN pp_product_bom pbom ON pbom.m_product_id = pr.m_product_id
     JOIN m_product_category pc ON pc.m_product_category_id = pr.m_product_category_id
     JOIN c_uom uom ON uom.c_uom_id = pr.c_uom_id
     LEFT JOIN pi_deptartment d ON pr.pi_deptartment_id = d.pi_deptartment_id
     JOIN m_locator l ON l.m_locator_id = pp.m_locator_id
  WHERE NOT (EXISTS ( SELECT 1
           FROM pi_productlabel pp_sales
          WHERE pp_sales.labeluuid = pp.labeluuid AND pp_sales.issotrx = 'Y'::bpchar))
  GROUP BY pp.m_product_id, uom.name, pp.ad_client_id, pp.ad_org_id, pr.isactive, pr.m_product_category_id, d.pi_deptartment_id, pbom.pp_product_bom_id, pr.value, pr.created, pr.createdby, pr.updated, pr.updatedby, l.m_warehouse_id
  ORDER BY pp.m_product_id DESC;


  -------------------------------------------------------------------------------
  TC validation:-

  public static boolean containsEncoded(String input) {
	    return TCUtills.isBase64(input) || TCUtills.isURLEncoded(input) || TCUtills.isUnicodeEscaped(input);
	}

if (containsEncoded(name)) {
			    farmerRegisterResponse.setError("Invalid input: Base64 or URL-encoded text not allowed in Name");
			    farmerRegisterResponse.setStatus("Registration Failed");
			    farmerRegisterResponse.setIsError(true);
			    return farmerRegisterResponseDocument;
			}

			if (containsEncoded(landmark)) {
			    farmerRegisterResponse.setError("Invalid input: Base64 or URL-encoded text not allowed in Landmark");
			    farmerRegisterResponse.setStatus("Registration Failed");
			    farmerRegisterResponse.setIsError(true);
			    return farmerRegisterResponseDocument;
			}



---------------------------------------------------------------
TCUtills:-

 public static boolean isBase64(String input) {
		    if (input == null || input.trim().isEmpty()) return false;

		    String base64Pattern = "^[A-Za-z0-9+/]+={0,2}$";

		    // Base64 length must be divisible by 4
		    if (input.length() % 4 != 0) return false;

		    return input.matches(base64Pattern);
		}

		public static boolean isURLEncoded(String input) {
		    if (input == null) return false;
		    return input.contains("%20") || input.contains("%2F") || input.contains("%3A") 
		        || input.matches(".*%[0-9A-Fa-f]{2}.*");
		}

		public static boolean isUnicodeEscaped(String input) {
    if (input == null) return false;
    // Example: \u003c, \u0061 etc.
    return input.matches(".*\\\\u[0-9A-Fa-f]{4}.*");
}

-----------------------------------------------------------------							