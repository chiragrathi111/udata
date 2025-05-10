Sales plan completed & pending list:-

CREATE VIEW adempiere.pir_salesplanreport AS
SELECT spl.status AS Status,sp.salesplandate AS salesDate,TO_CHAR(sp.salesplandate, 'DD-MM-YYYY') AS Date,
spl.c_bpartner_id,spl.m_warehouse_id,u.name AS userName,spl.ad_client_id,spl.ad_org_id
FROM adempiere.pi_salesplanline spl
JOIN adempiere.pi_salesplan sp ON sp.pi_salesplan_id = spl.pi_salesplan_id
JOIN adempiere.ad_user u ON u.ad_user_id = spl.createdby
WHERE spl.status IN ('IP', 'CO');

=======================================================================
Total dispatch materials in qty & tons, value (With price)

-- CREATE OR REPLACE VIEW adempiere.pir_daily_product_labels AS
SELECT 
    DATE(pl.updated) AS report_date,
    TO_CHAR(pl.updated, 'DD-MM-YYYY') AS formatted_date,
    pl.m_product_id,
    pr.name AS product_name,pl.issotrx,
    SUM(pl.quantity) AS total_quantity,
    pp.pricelist,
    ROUND(SUM(pp.pricelist * pl.quantity), 2) AS total_price, -- Total price calculation
    pr.weight AS unit_weight_kg,
    ROUND(SUM(pr.weight * pl.quantity)/1000, 3) AS total_weight_ton, -- Convert kg to tons
    pl.ad_client_id,
    pl.ad_org_id
FROM 
    adempiere.pi_productlabel pl
JOIN 
    adempiere.M_InOutLine il ON il.M_InOutLine_id = pl.M_InOutLine_id
JOIN 
    adempiere.M_Product pr ON pr.M_Product_id = pl.M_product_id
JOIN 
    adempiere.M_ProductPrice pp ON pp.M_product_id = pr.M_product_id 
WHERE 
    pp.m_pricelist_version_id = 1000001
GROUP BY 
    DATE(pl.updated),
    TO_CHAR(pl.updated, 'DD-MM-YYYY'),
    pl.m_product_id,
    pr.name,pl.issotrx,
    pp.pricelist,
    pr.weight,
    pl.ad_client_id,
    pl.ad_org_id
ORDER BY 
    DATE(pl.updated) DESC,
    pr.name,pl.issotrx;

========================================================================= OR
Total dispatch materials in qty & tons, value (Without Price)

CREATE OR REPLACE VIEW adempiere.pir_totalmaterials AS
SELECT 
    DATE(pl.updated) AS report_date,
    pl.m_product_id,
    pr.name AS product_name,pl.issotrx,
    SUM(pl.quantity) AS total_quantity,
    pr.weight AS unit_weight_kg,
    ROUND(SUM(pr.weight * pl.quantity)/1000, 3) AS total_weight_ton,
    pl.ad_client_id,
    pl.ad_org_id
FROM 
    adempiere.pi_productlabel pl
JOIN 
    adempiere.M_InOutLine il ON il.M_InOutLine_id = pl.M_InOutLine_id
JOIN 
    adempiere.M_Product pr ON pr.M_Product_id = pl.M_product_id
	
GROUP BY 
    DATE(pl.updated),
    pl.m_product_id,
    pr.name,pl.issotrx,
    pr.weight,
    pl.ad_client_id,
    pl.ad_org_id
ORDER BY 
    DATE(pl.updated) DESC,
    pr.name,pl.issotrx;

======================================================================================
Total tons in warehouse:-
Not come 0 and nagetive value:-


CREATE OR REPLACE VIEW adempiere.pir_totaltons AS
SELECT sh.qtyonhand,l.m_warehouse_id,l.m_locator_id,l.value,pr.M_Product_id,pr.weight AS unit_weight_kg,
ROUND(SUM(pr.weight * sh.qtyonhand)/1000, 3) AS total_weight_ton,sh.ad_client_id,sh.ad_org_id
FROM adempiere.M_storageonhand sh
JOIN adempiere.M_locator l ON l.M_locator_id = sh.M_locator_id
JOIN adempiere.M_product pr ON pr.M_product_id = sh.M_product_id
GROUP BY 
l.m_warehouse_id,l.m_locator_id,l.value,pr.M_Product_id,sh.qtyonhand,pr.weight,sh.ad_client_id,sh.ad_org_id
HAVING SUM(sh.qtyonhand) > 0
ORDER BY l.m_warehouse_id,l.m_locator_id;	


OR 
Not come zero value:-

SELECT sh.qtyonhand,l.m_warehouse_id,l.m_locator_id,l.value,pr.M_Product_id,pr.weight AS unit_weight_kg,
ROUND(SUM(pr.weight * sh.qtyonhand)/1000, 3) AS total_weight_ton,sh.ad_client_id,sh.ad_org_id
FROM adempiere.M_storageonhand sh
JOIN adempiere.M_locator l ON l.M_locator_id = sh.M_locator_id
JOIN adempiere.M_product pr ON pr.M_product_id = sh.M_product_id
GROUP BY 
l.m_warehouse_id,l.m_locator_id,l.value,pr.M_Product_id,sh.qtyonhand,pr.weight,sh.ad_client_id,sh.ad_org_id; 

================================================================== OR
Without Product:-

SELECT 
    l.m_warehouse_id,
    l.m_locator_id,
    l.value AS locator_name, 
    ROUND(SUM(sh.qtyonhand), 2) AS total_qty,
    ROUND(SUM(pr.weight * sh.qtyonhand) / 1000, 3) AS total_weight_ton,
    sh.ad_client_id,
    sh.ad_org_id
FROM adempiere.M_storageonhand sh
JOIN adempiere.M_locator l ON l.M_locator_id = sh.M_locator_id
JOIN adempiere.M_product pr ON pr.M_product_id = sh.M_product_id
GROUP BY 
    l.m_warehouse_id,
    l.m_locator_id,
    l.value,
    sh.ad_client_id,
    sh.ad_org_id
HAVING ROUND(SUM(sh.qtyonhand), 2) <> 0.00
ORDER BY 
    l.m_warehouse_id, 
    l.m_locator_id;



=========================================================================
CREATE OR REPLACE VIEW adempiere.sales_plan_detail_view AS
SELECT spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id,sp.salesplandate,
SUM(pi.totalqnty) AS total_quantity,
SUM(pi.completedqnty) AS completed_quantity,
SUM(pi.totalqnty - pi.completedqnty) AS pending_quantity,
CASE WHEN pi.totalqnty = pi.completedqnty THEN 'Completed'
ELSE 'In Progress' END AS status,spl.ad_client_id,spl.ad_org_id
FROM adempiere.pi_salesplanline spl
JOIN adempiere.pi_salesplan sp ON sp.pi_salesplan_id = spl.pi_salesplan_id
JOIN adempiere.pi_planitem pi ON pi.pi_salesplanline_id = spl.pi_salesplanline_id
GROUP BY spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id,sp.salesplandate,
spl.ad_client_id,spl.ad_org_id,pi.totalqnty,pi.completedqnty
ORDER BY sp.salesplandate DESC,spl.m_warehouse_id,spl.c_bpartner_id,pi.m_product_id;


========================================================================    

CREATE TABLE adempiere.pi_email(
    pi_email_id NUMERIC(10,0) NOT NULL PRIMARY KEY,
    pi_email_uu VARCHAR(36) DEFAULT NULL::bpchar,
    ad_client_id NUMERIC(10, 0) NOT NULL,
    ad_org_id NUMERIC(10, 0) NOT NULL,
    created TIMESTAMP without time zone DEFAULT now() NOT NULL,
    createdby NUMERIC(10,0) NOT NULL,
    updated TIMESTAMP without time zone DEFAULT now() NOT NULL,
    updatedby NUMERIC(10,0) NOT NULL,
	name VARCHAR(25) NOT NULL,
	email VARCHAR(25) NOT NULL,
    description VARCHAR(255),
    isactive CHAR(1) NOT NULL DEFAULT 'Y'::bpchar
    );

========================================================

MClient client = MClient.get(getCtx());
	        if (client.getSMTPHost() == null || client.getSMTPHost().isEmpty()) {
	            throw new Exception("SMTP Host not configured in Request Management");
	        }
	        
	        MUser user = new MUser(getCtx(), Env.getAD_User_ID(getCtx()), get_TrxName());
	        if (user.getEMail() == null || user.getEMail().isEmpty()) {
	            return "User email not configured: " + user.getName();
	        }
	        
	        String recipientEmail = user.getEMail().trim();
	        String senderEmail = client.getRequestEMail();
	        
	        if (!EMail.validate(recipientEmail)) {
	            return "Invalid recipient email format: " + recipientEmail;
	        }
	        
	        if (senderEmail == null || senderEmail.isEmpty()) {
	            return "Sender email not configured in Request Management";
	        }
	        
	        String subject = Msg.getMsg(getCtx(), "TestEmailSubject");
	        String message = Msg.getMsg(getCtx(), "TestEmailBody");
	        
	        EMail email = client.createEMailFrom(senderEmail, recipientEmail, subject, message,false);
	        if (email == null) {
	            return "Failed to create email object";
	        }
	        
	        try {
	            String status = email.send();
	            
	            if (EMail.SENT_OK.equals(status)) {
	                addLog("Email sent successfully to: " + recipientEmail);
	                return "Email sent successfully";
	            } else {
	                addLog("Email failed with status: " + status);
	                return "Failed to send email: " + status + 
	                       "\nSMTP Error: " ;
	            }
	        } catch (Exception e) {
	            log.severe("Email Exception: " + e.getMessage());
	            return "Email exception: " + e.getMessage();
	        }


====================================================================
Sent Report pdf to multiple user at a same time:-

package com.pipra.rwpl.factory;

import java.io.File;
import java.sql.Timestamp;
import java.util.List;
import org.compiere.model.MClient;
import org.compiere.model.MProcess;
import org.compiere.model.MQuery;
import org.compiere.model.MUser;
import org.compiere.model.PO;
import org.compiere.model.PrintInfo;
import org.compiere.model.Query;
import org.compiere.print.MPrintFormat;
import org.compiere.print.ReportEngine;
import org.compiere.process.SvrProcess;
import org.compiere.util.EMail;
import org.compiere.util.Env;
import org.compiere.util.Msg;
import com.pipra.rwpl.model.X_pi_multiusermail;

@org.adempiere.base.annotation.Process
public class RWPLMailProcess extends SvrProcess {

	@Override
	protected void prepare() {

	}

	@Override
	protected String doIt() throws Exception {
		StringBuilder result = new StringBuilder();
		int successCount = 0;
		int failureCount = 0;

		MClient client = MClient.get(getCtx());
		if (client.getSMTPHost() == null || client.getSMTPHost().isEmpty()) {
			throw new Exception("SMTP Host not configured in Request Management");
		}

		String senderEmail = client.getRequestEMail();
		if (senderEmail == null || senderEmail.isEmpty()) {
			throw new Exception("Sender email not configured in Request Management");
		}

		File pdfFile = generateReportPDF();
		if (pdfFile == null || !pdfFile.exists()) {
			throw new Exception("Failed to generate PDF report");
		}

		String subject = "Sales Plan List Report";
		String message = "Please find attached the Sales Plan List report.";

		MUser user = new MUser(getCtx(), Env.getAD_User_ID(getCtx()), get_TrxName());
		List<PO> recipientEmailList = new Query(getCtx(), X_pi_multiusermail.Table_Name, "AD_User_ID=?", get_TrxName())
				.setParameters(user.getAD_User_ID()).list();

		if (recipientEmailList.isEmpty()) {
			return "No recipients found in pi_multiusermail for current user";
		}

		for (PO userlist : recipientEmailList) {
			X_pi_multiusermail userList = new X_pi_multiusermail(getCtx(), userlist.get_ID(), get_TrxName());
			String recipientEmail = userList.getEMail() != null ? userList.getEMail().trim() : "";
			if (recipientEmail.isEmpty()) {
				result.append("Skipped: Empty email for record ID ").append(userlist.get_ID()).append("\n");
				failureCount++;
				continue;
			}

			if (!EMail.validate(recipientEmail)) {
				result.append("Skipped: Invalid email format '").append(recipientEmail).append("'\n");
				failureCount++;
				continue;
			}

			EMail email = null;
			try {
				email = client.createEMailFrom(senderEmail, recipientEmail, subject, message, false);

				if (email == null) {
					throw new Exception("Failed to create email object");
				}
				email.addAttachment(pdfFile);
				String status = email.send();
				if (EMail.SENT_OK.equals(status)) {
					result.append("Email status for '").append(recipientEmail).append("': ").append(status)
							.append("\n");
					successCount++;
				} else {
					result.append("Failed: Delivery to '").append(recipientEmail).append("\n");
					failureCount++;
				}
			} catch (Exception e) {
				result.append("Error: Exception sending to '").append(recipientEmail).append("' - ")
						.append(e.getMessage()).append("\n");
				failureCount++;
				log.severe("Email Exception for " + recipientEmail + ": " + e.getMessage());
			}
		}
		try {
			if (pdfFile != null && pdfFile.exists()) {
				pdfFile.delete();
			}
		} catch (Exception e) {
			log.warning("Error deleting temporary file: " + e.getMessage());
		}

		String summary = String.format("Email sending completed. Success: %d, Failed: %d\nDetails:\n%s", successCount,
				failureCount, result.toString());

		addLog(summary);
		return summary;
	}

	private File generateReportPDF() throws Exception {
		PO process = new Query(getCtx(), MProcess.Table_Name, "name = 'Sales plan list' ", get_TrxName()).firstOnly();
		int report_ID = process.get_ID();

		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = 'Sales plan list' ", get_TrxName()).firstOnly();
		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());

		Timestamp yesterday = new Timestamp(System.currentTimeMillis() - 86400000);
		java.sql.Date yesterdayDate = new java.sql.Date(yesterday.getTime());

		MQuery query = new MQuery();
		This below line use for validation:-
		query.addRestriction("salesdate = TO_DATE('" + yesterdayDate + "','YYYY-MM-DD')");

		PrintInfo info = new PrintInfo(Msg.getMsg(getCtx(), "SalesPlanList"), pf.getAD_Table_ID(), report_ID);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

		File pdfFile = File.createTempFile("SalesPlan_", ".pdf");
		if (!re.createPDF(pdfFile)) {
			throw new Exception("Failed to generate PDF report");
		}
		return pdfFile;
	}

}
====================================================================
Multiple Report pdf send multiple user at a same time:-

@Override
	protected String doIt() throws Exception {
	    StringBuilder result = new StringBuilder();
	    int successCount = 0;
	    int failureCount = 0;

	    MClient client = MClient.get(getCtx());
	    if (client.getSMTPHost() == null || client.getSMTPHost().isEmpty()) {
	        throw new Exception("SMTP Host not configured in Request Management");
	    }

	    String senderEmail = client.getRequestEMail();
	    if (senderEmail == null || senderEmail.isEmpty()) {
	        throw new Exception("Sender email not configured in Request Management");
	    }

	    File[] pdfFiles = {
	        generateReportPDF("Sales plan list", "SalesPlan","salesdate"),
	        generateReportPDF("Total Received/Dispatch Materials", "Material","report_date")
	    };

	    String subject = "Daily Reports Package";
	    String message = "Please find attached the daily reports package.";

	    MUser user = new MUser(getCtx(), Env.getAD_User_ID(getCtx()), get_TrxName());
	    List<PO> recipientEmailList = new Query(getCtx(), X_pi_multiusermail.Table_Name, "AD_User_ID=?", get_TrxName())
	            .setParameters(user.getAD_User_ID()).list();

	    if (recipientEmailList.isEmpty()) {
	        return "No recipients found in pi_multiusermail for current user";
	    }

	    for (PO userlist : recipientEmailList) {
	        X_pi_multiusermail userList = new X_pi_multiusermail(getCtx(), userlist.get_ID(), get_TrxName());
	        String recipientEmail = userList.getEMail() != null ? userList.getEMail().trim() : "";
	        
	        if (recipientEmail.isEmpty()) {
	            result.append("Skipped: Empty email for record ID ").append(userlist.get_ID()).append("\n");
	            failureCount++;
	            continue;
	        }

	        if (!EMail.validate(recipientEmail)) {
	            result.append("Skipped: Invalid email format '").append(recipientEmail).append("'\n");
	            failureCount++;
	            continue;
	        }

	        EMail email = null;
	        try {
	            email = client.createEMailFrom(senderEmail, recipientEmail, subject, message, false);

	            if (email == null) {
	                throw new Exception("Failed to create email object");
	            }
	            for (File pdfFile : pdfFiles) {
	                if (pdfFile != null && pdfFile.exists()) {
	                    email.addAttachment(pdfFile);
	                }
	            }

	            String status = email.send();
	            if (EMail.SENT_OK.equals(status)) {
	                result.append("Email with reports sent to '").append(recipientEmail).append("'\n");
	                successCount++;
	            } else {
	                result.append("Failed: Delivery to '").append(recipientEmail).append("'\n");
	                failureCount++;
	            }
	        } catch (Exception e) {
	            result.append("Error sending to '").append(recipientEmail)
	                  .append("' - ").append(e.getMessage()).append("\n");
	            failureCount++;
	            log.severe("Email Exception for " + recipientEmail + ": " + e.getMessage());
	        }
	    }

	    for (File pdfFile : pdfFiles) {
	        try {
	            if (pdfFile != null && pdfFile.exists()) {
	                pdfFile.delete();
	            }
	        } catch (Exception e) {
	            log.warning("Error deleting temporary file: " + e.getMessage());
	        }
	    }

	    String summary = String.format(
	        "Email sending completed. Success: %d, Failed: %d\nDetails:\n%s",
	        successCount, 
	        failureCount, 
	        result.toString()
	    );
	    
	    addLog(summary);
	    return summary;
	}

	private File generateReportPDF(String reportName, String filePrefix,String filter) throws Exception {
	    PO process = new Query(getCtx(), MProcess.Table_Name, 
	                          "name = ?", get_TrxName())
	                .setParameters(reportName)
	                .firstOnly();
	    
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, 
	                     "name = ?", get_TrxName())
	           .setParameters(reportName)
	           .firstOnly();
	    
	    if (po == null) {
	        log.warning("Print format not found for: " + reportName);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());

	    Timestamp yesterday = new Timestamp(System.currentTimeMillis() - 86400000);
	    java.sql.Date yesterdayDate = new java.sql.Date(yesterday.getTime());

	    MQuery query = new MQuery();
	    query.addRestriction(""+filter+" = TO_DATE('" + yesterdayDate + "','YYYY-MM-DD')");

	    PrintInfo info = new PrintInfo(
	        Msg.getMsg(getCtx(), reportName.replace(" ", "")), 
	        pf.getAD_Table_ID(), 
	        process != null ? process.get_ID() : 0
	    );

	    ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

	    File pdfFile = File.createTempFile(filePrefix + "_" + yesterdayDate, ".pdf");
	    if (!re.createPDF(pdfFile)) {
	        log.warning("Failed to generate PDF for: " + reportName);
	        return null;
	    }
	    return pdfFile;
	}

====================================================================================
At a time 4 pdf sent:-

protected String doIt() throws Exception {
	    StringBuilder result = new StringBuilder();
	    int successCount = 0;
	    int failureCount = 0;

	    MClient client = MClient.get(getCtx());
	    if (client.getSMTPHost() == null || client.getSMTPHost().isEmpty()) {
	        throw new Exception("SMTP Host not configured in Request Management");
	    }

	    String senderEmail = client.getRequestEMail();
	    if (senderEmail == null || senderEmail.isEmpty()) {
	        throw new Exception("Sender email not configured in Request Management");
	    }
	    Timestamp yesterday = new Timestamp(System.currentTimeMillis() - 86400000);
	    java.sql.Date yesterdayDate = new java.sql.Date(yesterday.getTime());

	    File[] pdfFiles = {
	        generateSalesPlanReport(yesterdayDate),                // Only date filter
	        generateReceivedDispatchReport(yesterdayDate, true),   // Date + IsSOTrx=Y
	        generateReceivedDispatchReport(yesterdayDate, false),  // Date + IsSOTrx=N
	        generateWarehouseReport()                              // No filters
	    };

	    String subject = "Daily Operations Reports";
	    String message = "Please find attached the daily operations reports package.";

	    MUser user = new MUser(getCtx(), Env.getAD_User_ID(getCtx()), get_TrxName());
	    List<PO> recipientEmailList = new Query(getCtx(), X_pi_multiusermail.Table_Name, "AD_User_ID=?", get_TrxName())
	            .setParameters(user.getAD_User_ID()).list();

	    if (recipientEmailList.isEmpty()) {
	        return "No recipients found in pi_multiusermail for current user";
	    }

	    for (PO userlist : recipientEmailList) {
	        X_pi_multiusermail userList = new X_pi_multiusermail(getCtx(), userlist.get_ID(), get_TrxName());
	        String recipientEmail = userList.getEMail() != null ? userList.getEMail().trim() : "";
	        
	        if (recipientEmail.isEmpty()) {
	            result.append("Skipped: Empty email for record ID ").append(userlist.get_ID()).append("\n");
	            failureCount++;
	            continue;
	        }

	        if (!EMail.validate(recipientEmail)) {
	            result.append("Skipped: Invalid email format '").append(recipientEmail).append("'\n");
	            failureCount++;
	            continue;
	        }

	        EMail email = null;
	        try {
	            email = client.createEMailFrom(senderEmail, recipientEmail, subject, message, false);

	            if (email == null) {
	                throw new Exception("Failed to create email object");
	            }

	            for (File pdfFile : pdfFiles) {
	                if (pdfFile != null && pdfFile.exists()) {
	                    email.addAttachment(pdfFile);
	                }
	            }

	            String status = email.send();
	            if (EMail.SENT_OK.equals(status)) {
	                result.append("Email with reports sent to '").append(recipientEmail).append("'\n");
	                successCount++;
	            } else {
	                result.append("Failed: Delivery to '").append(recipientEmail).append("'\n");
	                failureCount++;
	            }
	        } catch (Exception e) {
	            result.append("Error sending to '").append(recipientEmail)
	                  .append("' - ").append(e.getMessage()).append("\n");
	            failureCount++;
	            log.severe("Email Exception for " + recipientEmail + ": " + e.getMessage());
	        }
	    }
	    for (File pdfFile : pdfFiles) {
	        try {
	            if (pdfFile != null && pdfFile.exists()) {
	                pdfFile.delete();
	            }
	        } catch (Exception e) {
	            log.warning("Error deleting temporary file: " + e.getMessage());
	        }
	    }
	    String summary = String.format(
	        "Email sending completed. Success: %d, Failed: %d\nDetails:\n%s",
	        successCount, 
	        failureCount, 
	        result.toString());
	    
//	    addLog(summary);
	    return summary;
	}

	private File generateSalesPlanReport(java.sql.Date reportDate) throws Exception {
	    PO process = new Query(getCtx(), MProcess.Table_Name, 
	                         "name = 'Sales plan list'", get_TrxName())
	               .firstOnly();
	    
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, 
	                     "name = 'Sales plan list'", get_TrxName())
	           .firstOnly();
	    
	    if (po == null) {
	        log.warning("Print format not found for: Sales plan list");
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    MQuery query = new MQuery();
	    query.addRestriction("salesdate = TO_DATE('" + reportDate + "','YYYY-MM-DD')");

	    PrintInfo info = new PrintInfo("Sales Plan List", pf.getAD_Table_ID(), 
	                                 process != null ? process.get_ID() : 0);

	    ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());
	    File pdfFile = File.createTempFile("SalesPlan_"+reportDate, ".pdf");
	    if (!re.createPDF(pdfFile)) {
	        log.warning("Failed to generate Sales Plan report");
	        return null;
	    }
	    return pdfFile;
	}

	private File generateReceivedDispatchReport(java.sql.Date reportDate, boolean isSOTrx) throws Exception {
	    String reportName = "Total Received/Dispatch Materials";
	    
	    PO process = new Query(getCtx(), MProcess.Table_Name, 
	                         "name = ?", get_TrxName())
	               .setParameters(reportName)
	               .firstOnly();
	    
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, 
	                     "name = ?", get_TrxName())
	           .setParameters(reportName)
	           .firstOnly();
	    
	    if (po == null) {
	        log.warning("Print format not found for: " + reportName);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    MQuery query = new MQuery();
	    query.addRestriction("report_date = TO_DATE('" + reportDate + "','YYYY-MM-DD')");
	    query.addRestriction("IsSOTrx = '" + (isSOTrx ? "Y" : "N") + "'");

	    PrintInfo info = new PrintInfo(reportName, pf.getAD_Table_ID(), 
	                                 process != null ? process.get_ID() : 0);

	    ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());
	    String filePrefix = isSOTrx ? "Total_Dispatch_" : "Total_Received_";
	    File pdfFile = File.createTempFile(filePrefix, ".pdf");
	    if (!re.createPDF(pdfFile)) {
	        log.warning("Failed to generate " + reportName + " report");
	        return null;
	    }
	    return pdfFile;
	}

	private File generateWarehouseReport() throws Exception {
	String reportName = "Total tons in Warehouse";
	    
	    PO process = new Query(getCtx(), MProcess.Table_Name, 
	                         "name = ?", get_TrxName())
	               .setParameters(reportName)
	               .firstOnly();
	    
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, 
	                     "name = ?", get_TrxName())
	           .setParameters(reportName)
	           .firstOnly();
	    
	    if (po == null) {
	        log.warning("Print format not found for: " + reportName);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    MQuery query = new MQuery();

	    PrintInfo info = new PrintInfo(reportName, pf.getAD_Table_ID(), 
	                                 process != null ? process.get_ID() : 0);

	    ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());
	    File pdfFile = File.createTempFile("Total_Tons_In_Warehouse_", ".pdf");
	    if (!re.createPDF(pdfFile)) {
	        log.warning("Failed to generate Warehouse report");
	        return null;
	    }
	    return pdfFile;
	}

	-- This is for csv file:-

	private File generateCSVFromPrintFormat(String reportName) throws Exception {
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
	            .setParameters(reportName)
	            .firstOnly();

	    if (po == null) {
	        log.warning("Print format not found for: " + reportName);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    
	    MQuery query = new MQuery();
//	    If you use added restriction for query according:-
//	    query.addRestriction("report_date = TO_DATE('" + reportDate + "','YYYY-MM-DD')");
//	    if (reportName.equals("Total Received/Dispatch Materials")) {
//	        query.addRestriction("IsSOTrx = '" + (isSOTrx ? "Y" : "N") + "'");
//	    }

	    PrintInfo info = new PrintInfo(reportName, pf.getAD_Table_ID(), po != null ? po.get_ID() : 0);
	    
	    ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());
	    File csvFile = File.createTempFile(reportName.replace(" ", "_") + "_", ".csv");
	    
	    boolean success = re.createCSV(
	            csvFile,          
	            ',',             
	            Env.getLanguage(getCtx())
	        );
	    if (!success) {
	        log.warning("Failed to generate CSV for: " + reportName);
	        return null;
	    }
	    return csvFile;
	}

============================================================
Excel generate without Header and with Header:-

private File generateExcelReportWithHeaders() throws Exception {
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
	            .setParameters(REPORT_TOTAL_TONS_IN_WAREHOUSE)
	            .firstOnly();
	    if (po == null) {
	        log.warning("Print format not found: " + REPORT_TOTAL_TONS_IN_WAREHOUSE);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    MQuery query = new MQuery();
	    
	    PrintInfo info = new PrintInfo(REPORT_TOTAL_TONS_IN_WAREHOUSE, pf.getAD_Table_ID(), po != null ? po.get_ID() : 0);
	    
	    ReportEngine re = new ReportEngine(getCtx(), pf, query,info,get_TrxName());

	    File excelFile = File.createTempFile(REPORT_TOTAL_TONS_IN_WAREHOUSE.replace(" ", "_") + "_", ".xlsx");
	    
	    re.createXLSX(excelFile, Env.getLanguage(getCtx()));
	        return excelFile;
	}

	++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	With Header:-
	
	private File generateExcelReport() throws Exception {
	    PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
	            .setParameters(REPORT_TOTAL_TONS_IN_WAREHOUSE)
	            .firstOnly();
	    if (po == null) {
	        log.warning("Print format not found: " + REPORT_TOTAL_TONS_IN_WAREHOUSE);
	        return null;
	    }

	    MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
	    ReportEngine re = new ReportEngine(getCtx(), pf, new MQuery(),
	            new PrintInfo(REPORT_TOTAL_TONS_IN_WAREHOUSE, pf.getAD_Table_ID(), po.get_ID()),
	            get_TrxName());

	    File excelFile = File.createTempFile(REPORT_TOTAL_TONS_IN_WAREHOUSE.replace(" ", "_") + "_", ".xlsx");
	    
	    re.createXLSX(excelFile, Env.getLanguage(getCtx()));
	    
	    File finalFile = File.createTempFile(REPORT_TOTAL_TONS_IN_WAREHOUSE.replace(" ", "_") + "_", ".xlsx");
	    FileInputStream fis = null;
	    FileOutputStream fos = null;
	    XSSFWorkbook workbook = null;
	    
	    try {
	    	fis = new FileInputStream(excelFile);
	        workbook = new XSSFWorkbook(fis);
	        Sheet sheet = workbook.getSheetAt(0);
	        if (sheet.getLastRowNum() >= 0) {
	            sheet.shiftRows(0, sheet.getLastRowNum(), 2, true, false);
	        }
	        
	        CellStyle headerStyle = workbook.createCellStyle();
	        headerStyle.setAlignment(HorizontalAlignment.CENTER);
	        Font headerFont = workbook.createFont();
	        headerFont.setBold(true);
	        headerFont.setFontHeightInPoints((short)14);
	        headerFont.setColor(IndexedColors.WHITE.getIndex());
	        headerStyle.setFont(headerFont);

//	        CellStyle titleStyle = workbook.createCellStyle();
//	        titleStyle.setAlignment(HorizontalAlignment.CENTER);
//	        Font titleFont = workbook.createFont();
//	        titleFont.setBold(true);
//	        titleFont.setFontHeightInPoints((short)14);
//	        titleStyle.setFont(titleFont);
	        
//	        titleStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
//	        titleStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
	        headerStyle.setFillForegroundColor(IndexedColors.BLACK.getIndex());
	        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
	        
	        int lastCol = 0;
	        if (sheet.getRow(2) != null) { // Row 3 is the original header row (now shifted down)
	            lastCol = sheet.getRow(2).getLastCellNum() - 1;
	            if (lastCol < 0) lastCol = 0; 

	        }
	       
//	        Row companyRow = sheet.createRow(0);
//	        Cell companyCell = companyRow.createCell(0);
////	        companyCell.setCellValue("RWPL");
//	        companyCell.setCellStyle(titleStyle);
//	        if (lastCol > 0) {
//	            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, lastCol));
//	        }
	        if (lastCol > 0) {
	        Row titleRow = sheet.createRow(0);
	        Cell titleCell = titleRow.createCell(0);
	        titleCell.setCellValue(REPORT_TOTAL_TONS_IN_WAREHOUSE.toUpperCase());
	        titleCell.setCellStyle(headerStyle);
	        if (lastCol > 0) {
	            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, lastCol));
	        }
	        
	        sheet.createRow(1);
	        }
	        
	        for (int i = 0; i <= lastCol; i++) {
	            sheet.autoSizeColumn(i);
	        }
	        
	        fos = new FileOutputStream(finalFile);
	        workbook.write(fos);
	        
	        return finalFile;
	    } catch (Exception e) {
	        log.log(Level.SEVERE, "Error adding headers", e);
	        return excelFile;
	    } finally {
	    	try { if (fos != null) fos.close(); } catch (Exception e) {}
	        try { if (workbook != null) workbook.close(); } catch (Exception e) {}
	        try { if (fis != null) fis.close(); } catch (Exception e) {}
	        excelFile.delete();
	    }
===========================================================================================
Working excel code 
package com.pipra.rwpl.factory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.sql.Timestamp;
import java.util.List;
import java.util.logging.Level;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.compiere.model.MClient;
import org.compiere.model.MQuery;
import org.compiere.model.PO;
import org.compiere.model.PrintInfo;
import org.compiere.model.Query;
import org.compiere.print.MPrintFormat;
import org.compiere.print.ReportEngine;
import org.compiere.process.SvrProcess;
import org.compiere.util.EMail;
import org.compiere.util.Env;
import com.pipra.rwpl.model.X_pi_email;

@org.adempiere.base.annotation.Process
public class RWPLMailProcess extends SvrProcess {
	private static final String REPORT_SALES_PLAN_REPORT = "Sales Plan Detail View";
	private static final String REPORT_TOTAL_TONS_IN_WAREHOUSE = "Total Tons In Warehouse";
	private static final String REPORT_TOTAL_TRANSACTION_MATERIALS = "Total Received/Dispatch Materials";
	private static final String REPORT_INVENTORY_VIEW_FOR_EMAIL = "Inventory View For Email";
	private static final String REPORT_EMPTY_LOCATOR = "Empty Locator View";
	private static final String REPORT_TOTAL_RECEIVED_MATERIALS = "Total Received Materials";
	private static final String REPORT_TOTAL_DISPATCH_MATERIALS = "Total Dispatch Materials";

	@Override
	protected void prepare() {
	}

	@Override
	protected String doIt() throws Exception {
		StringBuilder result = new StringBuilder();
		int successCount = 0;
		int failureCount = 0;

		MClient client = MClient.get(getCtx());
		if (client.getSMTPHost() == null || client.getSMTPHost().isEmpty()) {
			throw new Exception("SMTP Host not configured in Request Management");
		}

		String senderEmail = client.getRequestEMail();
		if (senderEmail == null || senderEmail.isEmpty()) {
			throw new Exception("Sender email not configured in Request Management");
		}
		Timestamp yesterday = new Timestamp(System.currentTimeMillis() - 86400000);
		java.sql.Date yesterdayDate = new java.sql.Date(yesterday.getTime());

		File[] pdfFiles = { 
				generateReceivedDispatchReport(yesterdayDate, true),
				generateReceivedDispatchReport(yesterdayDate, false),
				generateWarehouseReport(),
				generateInventoryReport(),
				generateEmpytyLocatorReport(),
				generateSalesPlanDetailViewReport(yesterdayDate)
				};

		String subject = "Daily Operations Reports";
		String message = "Please find attached the daily operations reports package.";

		List<PO> recipientEmailList = new Query(getCtx(), X_pi_email.Table_Name, "AD_Client_ID=?", get_TrxName())
				.setParameters(Env.getAD_Client_ID(getCtx())).list();

		if (recipientEmailList.isEmpty()) {
			return "No recipients found in pi_multiusermail for current user";
		}

		for (PO userlist : recipientEmailList) {
			X_pi_email userList = new X_pi_email(getCtx(), userlist.get_ID(), get_TrxName());
			String recipientEmail = userList.getEMail() != null ? userList.getEMail().trim() : "";

			if (recipientEmail.isEmpty()) {
				result.append("Skipped: Empty email for record ID ").append(userlist.get_ID()).append("\n");
				failureCount++;
				continue;
			}

			if (!EMail.validate(recipientEmail)) {
				result.append("Skipped: Invalid email format '").append(recipientEmail).append("'\n");
				failureCount++;
				continue;
			}

			EMail email = null;
			try {
				email = client.createEMailFrom(senderEmail, recipientEmail, subject, message, false);

				if (email == null) {
					throw new Exception("Failed to create email object");
				}

				for (File pdfFile : pdfFiles) {
					if (pdfFile != null && pdfFile.exists()) {
						email.addAttachment(pdfFile);
					}
				}

				String status = email.send();
				if (EMail.SENT_OK.equals(status)) {
					result.append("Email with reports sent to '").append(recipientEmail).append("'\n");
					successCount++;
				} else {
					result.append("Failed: Delivery to '").append(recipientEmail).append("'\n");
					failureCount++;
				}
			} catch (Exception e) {
				result.append("Error sending to '").append(recipientEmail).append("' - ").append(e.getMessage())
						.append("\n");
				failureCount++;
				log.severe("Email Exception for " + recipientEmail + ": " + e.getMessage());
			}
		}
		for (File pdfFile : pdfFiles) {
			try {
				if (pdfFile != null && pdfFile.exists()) {
					pdfFile.delete();
				}
			} catch (Exception e) {
				log.warning("Error deleting temporary file: " + e.getMessage());
			}
		}
		String summary = String.format("Email sending completed. Success: %d, Failed: %d\nDetails:\n%s", successCount,
				failureCount, result.toString());

		return summary;
	}
	
	private File generateWarehouseReport() throws Exception {
		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
				.setParameters(REPORT_TOTAL_TONS_IN_WAREHOUSE).firstOnly();
		if (po == null) {
			log.warning("Print format not found: " + REPORT_TOTAL_TONS_IN_WAREHOUSE);
			return null;
		}

		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
		MQuery query = new MQuery();
		PrintInfo info = new PrintInfo(REPORT_TOTAL_TONS_IN_WAREHOUSE, pf.getAD_Table_ID(),
				po != null ? po.get_ID() : 0);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

		File excelFile = File.createTempFile(REPORT_TOTAL_TONS_IN_WAREHOUSE.replace(" ", "_") + "_", ".xlsx");

		re.createXLSX(excelFile, Env.getLanguage(getCtx()));

		File finalFile = File.createTempFile(REPORT_TOTAL_TONS_IN_WAREHOUSE.replace(" ", "_") + "_", ".xlsx");
		FileInputStream fis = null;
		FileOutputStream fos = null;
		XSSFWorkbook workbook = null;

		try {
			fis = new FileInputStream(excelFile);
			workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);
			if (sheet.getLastRowNum() >= 0) {
				sheet.shiftRows(0, sheet.getLastRowNum(), 3, true, false);
			}
			sheet.createRow(0);

			CellStyle headerStyle = workbook.createCellStyle();
			headerStyle.setAlignment(HorizontalAlignment.CENTER);
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerFont.setFontHeightInPoints((short) 16);
			headerFont.setColor(IndexedColors.WHITE.getIndex());
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

			int lastCol = 0;
			if (sheet.getRow(3) != null) {
				lastCol = sheet.getRow(3).getLastCellNum() - 1;
				if (lastCol < 0)
					lastCol = 0;
			}
			if (lastCol > 0) {
				Row titleRow = sheet.createRow(1);
				Cell titleCell = titleRow.createCell(0);
				titleCell.setCellValue(REPORT_TOTAL_TONS_IN_WAREHOUSE.toUpperCase());
				titleCell.setCellStyle(headerStyle);
				if (lastCol > 0) {
					sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, lastCol));
				}
				sheet.createRow(2);
			}
			for (int i = 0; i <= lastCol; i++) {
				sheet.autoSizeColumn(i);
			}
			fos = new FileOutputStream(finalFile);
			workbook.write(fos);

			return finalFile;
		} catch (Exception e) {
			log.log(Level.SEVERE, "Error adding headers", e);
			return excelFile;
		} finally {
			try {
				if (fos != null)
					fos.close();
			} catch (Exception e) {
			}
			try {
				if (workbook != null)
					workbook.close();
			} catch (Exception e) {
			}
			try {
				if (fis != null)
					fis.close();
			} catch (Exception e) {
			}
			excelFile.delete();
		}
	
	
	    
	}
	
	private File generateEmpytyLocatorReport() throws Exception {
		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
				.setParameters(REPORT_EMPTY_LOCATOR).firstOnly();
		if (po == null) {
			log.warning("Print format not found: " + REPORT_EMPTY_LOCATOR);
			return null;
		}

		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
		MQuery query = new MQuery();
		PrintInfo info = new PrintInfo(REPORT_EMPTY_LOCATOR, pf.getAD_Table_ID(),
				po != null ? po.get_ID() : 0);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

		File excelFile = File.createTempFile(REPORT_EMPTY_LOCATOR.replace(" ", "_") + "_", ".xlsx");

		re.createXLSX(excelFile, Env.getLanguage(getCtx()));

		File finalFile = File.createTempFile(REPORT_EMPTY_LOCATOR.replace(" ", "_") + "_", ".xlsx");
		FileInputStream fis = null;
		FileOutputStream fos = null;
		XSSFWorkbook workbook = null;

		try {
			fis = new FileInputStream(excelFile);
			workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);
			if (sheet.getLastRowNum() >= 0) {
				sheet.shiftRows(0, sheet.getLastRowNum(), 3, true, false);
			}
			sheet.createRow(0);

			CellStyle headerStyle = workbook.createCellStyle();
			headerStyle.setAlignment(HorizontalAlignment.CENTER);
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerFont.setFontHeightInPoints((short) 16);
			headerFont.setColor(IndexedColors.WHITE.getIndex());
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

			int lastCol = 0;
			if (sheet.getRow(3) != null) {
				lastCol = sheet.getRow(3).getLastCellNum() - 1;
				if (lastCol < 0)
					lastCol = 0;
			}
			if (lastCol > 0) {
				Row titleRow = sheet.createRow(1);
				Cell titleCell = titleRow.createCell(0);
				titleCell.setCellValue(REPORT_EMPTY_LOCATOR.toUpperCase());
				titleCell.setCellStyle(headerStyle);
				if (lastCol > 0) {
					sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, lastCol));
				}
				sheet.createRow(2);
			}
			for (int i = 0; i <= lastCol; i++) {
				sheet.autoSizeColumn(i);
			}
			fos = new FileOutputStream(finalFile);
			workbook.write(fos);

			return finalFile;
		} catch (Exception e) {
			log.log(Level.SEVERE, "Error adding headers", e);
			return excelFile;
		} finally {
			try {
				if (fos != null)
					fos.close();
			} catch (Exception e) {
			}
			try {
				if (workbook != null)
					workbook.close();
			} catch (Exception e) {
			}
			try {
				if (fis != null)
					fis.close();
			} catch (Exception e) {
			}
			excelFile.delete();
		}
	}

	private File generateInventoryReport() throws Exception {
		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
				.setParameters(REPORT_INVENTORY_VIEW_FOR_EMAIL).firstOnly();
		if (po == null) {
			log.warning("Print format not found: " + REPORT_INVENTORY_VIEW_FOR_EMAIL);
			return null;
		}

		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
		MQuery query = new MQuery();
		PrintInfo info = new PrintInfo(REPORT_INVENTORY_VIEW_FOR_EMAIL, pf.getAD_Table_ID(),
				po != null ? po.get_ID() : 0);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

		File excelFile = File.createTempFile(REPORT_INVENTORY_VIEW_FOR_EMAIL.replace(" ", "_") + "_", ".xlsx");

		re.createXLSX(excelFile, Env.getLanguage(getCtx()));

		File finalFile = File.createTempFile(REPORT_INVENTORY_VIEW_FOR_EMAIL.replace(" ", "_") + "_", ".xlsx");
		FileInputStream fis = null;
		FileOutputStream fos = null;
		XSSFWorkbook workbook = null;

		try {
			fis = new FileInputStream(excelFile);
			workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);
			if (sheet.getLastRowNum() >= 0) {
				sheet.shiftRows(0, sheet.getLastRowNum(), 3, true, false);
			}
			sheet.createRow(0);

			CellStyle headerStyle = workbook.createCellStyle();
			headerStyle.setAlignment(HorizontalAlignment.CENTER);
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerFont.setFontHeightInPoints((short) 16);
			headerFont.setColor(IndexedColors.WHITE.getIndex());
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

			int lastCol = 0;
			if (sheet.getRow(3) != null) {
				lastCol = sheet.getRow(3).getLastCellNum() - 1;
				if (lastCol < 0)
					lastCol = 0;
			}
			if (lastCol > 0) {
				Row titleRow = sheet.createRow(1);
				Cell titleCell = titleRow.createCell(0);
				titleCell.setCellValue(REPORT_INVENTORY_VIEW_FOR_EMAIL.toUpperCase());
				titleCell.setCellStyle(headerStyle);
				if (lastCol > 0) {
					sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, lastCol));
				}
				sheet.createRow(2);
			}
			for (int i = 0; i <= lastCol; i++) {
				sheet.autoSizeColumn(i);
			}
			fos = new FileOutputStream(finalFile);
			workbook.write(fos);

			return finalFile;
		} catch (Exception e) {
			log.log(Level.SEVERE, "Error adding headers", e);
			return excelFile;
		} finally {
			try {
				if (fos != null)
					fos.close();
			} catch (Exception e) {
			}
			try {
				if (workbook != null)
					workbook.close();
			} catch (Exception e) {
			}
			try {
				if (fis != null)
					fis.close();
			} catch (Exception e) {
			}
			excelFile.delete();
		}
	}
	
	private File generateReceivedDispatchReport(java.sql.Date reportDate, boolean isSOTrx) throws Exception {
		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
				.setParameters(REPORT_TOTAL_TRANSACTION_MATERIALS).firstOnly();
		if (po == null) {
			log.warning("Print format not found: " + REPORT_TOTAL_TRANSACTION_MATERIALS);
			return null;
		}

		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
		MQuery query = new MQuery();
		query.addRestriction("report_date = TO_DATE('" + reportDate + "','YYYY-MM-DD')");
		query.addRestriction("IsSOTrx = '" + (isSOTrx ? "Y" : "N") + "'");
		
		PrintInfo info = new PrintInfo(REPORT_TOTAL_TRANSACTION_MATERIALS, pf.getAD_Table_ID(),
				po != null ? po.get_ID() : 0);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());
		
		String filePrefix = isSOTrx ? REPORT_TOTAL_DISPATCH_MATERIALS : REPORT_TOTAL_RECEIVED_MATERIALS;

		File excelFile = File.createTempFile(filePrefix.replace(" ", "_") + "_", ".xlsx");

		re.createXLSX(excelFile, Env.getLanguage(getCtx()));

		File finalFile = File.createTempFile(filePrefix.replace(" ", "_") + "_", ".xlsx");
		FileInputStream fis = null;
		FileOutputStream fos = null;
		XSSFWorkbook workbook = null;

		try {
			fis = new FileInputStream(excelFile);
			workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);
			if (sheet.getLastRowNum() >= 0) {
				sheet.shiftRows(0, sheet.getLastRowNum(), 3, true, false);
			}
			sheet.createRow(0);

			CellStyle headerStyle = workbook.createCellStyle();
			headerStyle.setAlignment(HorizontalAlignment.CENTER);
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerFont.setFontHeightInPoints((short) 16);
			headerFont.setColor(IndexedColors.WHITE.getIndex());
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

			int lastCol = 0;
			if (sheet.getRow(5) != null) {
				lastCol = sheet.getRow(5).getLastCellNum() - 1;
				if (lastCol < 0)
					lastCol = 0;
			}
			if (lastCol > 0) {
				Row titleRow = sheet.createRow(1);
				Cell titleCell = titleRow.createCell(0);
				titleCell.setCellValue(filePrefix.toUpperCase());
				titleCell.setCellStyle(headerStyle);
				if (lastCol > 0) {
					sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, lastCol));
				}
				sheet.createRow(2);
			}
			for (int i = 0; i <= lastCol; i++) {
				sheet.autoSizeColumn(i);
			}
			fos = new FileOutputStream(finalFile);
			workbook.write(fos);

			return finalFile;
		} catch (Exception e) {
			log.log(Level.SEVERE, "Error adding headers", e);
			return excelFile;
		} finally {
			try {
				if (fos != null)
					fos.close();
			} catch (Exception e) {
			}
			try {
				if (workbook != null)
					workbook.close();
			} catch (Exception e) {
			}
			try {
				if (fis != null)
					fis.close();
			} catch (Exception e) {
			}
			excelFile.delete();
		}
	}
	
	private File generateSalesPlanDetailViewReport(java.sql.Date reportDate) throws Exception {
		PO po = new Query(getCtx(), MPrintFormat.Table_Name, "name = ?", get_TrxName())
				.setParameters(REPORT_SALES_PLAN_REPORT).firstOnly();
		if (po == null) {
			log.warning("Print format not found: " + REPORT_SALES_PLAN_REPORT);
			return null;
		}

		MPrintFormat pf = new MPrintFormat(getCtx(), po.get_ID(), get_TrxName());
		MQuery query = new MQuery();
		query.addRestriction("salesplandate = TO_DATE('" + reportDate + "','YYYY-MM-DD')");
		
		PrintInfo info = new PrintInfo(REPORT_SALES_PLAN_REPORT, pf.getAD_Table_ID(),
				po != null ? po.get_ID() : 0);

		ReportEngine re = new ReportEngine(getCtx(), pf, query, info, get_TrxName());

		File excelFile = File.createTempFile(REPORT_SALES_PLAN_REPORT.replace(" ", "_") + "_", ".xlsx");
		
		if (re.getRowCount() == 0) {
	        log.warning("No data found for date: " + reportDate);
	        return null;
	    }

		re.createXLSX(excelFile, Env.getLanguage(getCtx()));

		File finalFile = File.createTempFile(REPORT_SALES_PLAN_REPORT.replace(" ", "_") + "_", ".xlsx");
		FileInputStream fis = null;
		FileOutputStream fos = null;
		XSSFWorkbook workbook = null;

		try {
			fis = new FileInputStream(excelFile);
			workbook = new XSSFWorkbook(fis);
			Sheet sheet = workbook.getSheetAt(0);
			if (sheet.getLastRowNum() >= 0) {
				sheet.shiftRows(0, sheet.getLastRowNum(), 3, true, false);
			}
			sheet.createRow(0);

			CellStyle headerStyle = workbook.createCellStyle();
			headerStyle.setAlignment(HorizontalAlignment.CENTER);
			Font headerFont = workbook.createFont();
			headerFont.setBold(true);
			headerFont.setFontHeightInPoints((short) 16);
			headerFont.setColor(IndexedColors.WHITE.getIndex());
			headerStyle.setFont(headerFont);
			headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
			headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

			int lastCol = 0;
			if (sheet.getRow(6) != null) {
				lastCol = sheet.getRow(6).getLastCellNum() - 1;
				if (lastCol < 0)
					lastCol = 0;
			}
			if (lastCol > 0) {
				Row titleRow = sheet.createRow(1);
				Cell titleCell = titleRow.createCell(0);
				titleCell.setCellValue(REPORT_SALES_PLAN_REPORT.toUpperCase());
				titleCell.setCellStyle(headerStyle);
				if (lastCol > 0) {
					sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, lastCol));
				}
				sheet.createRow(2);
			}
			for (int i = 0; i <= lastCol; i++) {
				sheet.autoSizeColumn(i);
			}
			fos = new FileOutputStream(finalFile);
			workbook.write(fos);

			return finalFile;
		} catch (Exception e) {
			log.log(Level.SEVERE, "Error adding headers", e);
			return excelFile;
		} finally {
			try {
				if (fos != null)
					fos.close();
			} catch (Exception e) {
			}
			try {
				if (workbook != null)
					workbook.close();
			} catch (Exception e) {
			}
			try {
				if (fis != null)
					fis.close();
			} catch (Exception e) {
			}
			excelFile.delete();
		}
	}
	
}
==============================================================================================

