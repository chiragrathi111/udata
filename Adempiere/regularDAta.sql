Regular data for Process:--


=====================================================================================================================================================================

package org.wms.createMR;

import java.math.BigDecimal;
import java.util.Properties;
import org.idempiere.customization.model.MInOutLineConfirm_Custom;
import org.idempiere.customization.model.MInOutLine_Custom;
import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MDocType;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutConfirm;
import org.compiere.model.MInOutLine;
import org.compiere.model.MInOutLineConfirm;
import org.compiere.model.MOrder;
import org.compiere.model.MOrderLine;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.process.DocAction;
import org.compiere.process.SvrProcess;
import org.compiere.util.Env;
import org.compiere.util.Trx;

public class MR extends SvrProcess {

	@Override
	protected void prepare() {
	}

	@Override
	protected String doIt() throws Exception {

		Trx trx = null;
		int mInOutID = 1000184;
		String data = "";
		int failedQty = 2;
		try {
			String trx_Name = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trx_Name, true);
			trx.start();
			Properties ctx = getCtx();

			MTable table = MTable.get(ctx, "m_inout");
			PO po = table.getPO(mInOutID, trx.getTrxName());
			if (po == null) {
				System.out.println("table details is not correct");
			}
			MInOut mInOut = (MInOut) po;

			MInOutConfirm mInOutConfirm = new MInOutConfirm(mInOut, "PC");
			mInOutConfirm.setDocStatus(DocAction.STATUS_Drafted);
			mInOutConfirm.saveEx();

			MInOutLine[] lines = mInOut.getLines(false);
			for (MInOutLine line : lines) {
				MInOutLineConfirm lineConfirm = new MInOutLineConfirm(mInOutConfirm);
				lineConfirm.setM_InOutLine_ID(line.get_ID());
				lineConfirm.setTargetQty(line.getMovementQty());
				lineConfirm.setConfirmedQty(line.getMovementQty());

				lineConfirm.saveEx();

				System.out.println(lineConfirm.get_ID());
				int confirmID = lineConfirm.get_ID();
				MInOutLineConfirm_Custom custom = new MInOutLineConfirm_Custom(ctx, confirmID, trx.getTrxName());
				BigDecimal bigFail = new BigDecimal(failedQty);
				custom.processLine(false, "PC");
				custom.setQCFailedQty(bigFail);
				custom.saveEx();
				System.out.println(custom.getQCFailedQty());
				lineConfirm.saveEx();
			}
			mInOutConfirm.setDocStatus(MInOutConfirm.DOCSTATUS_Completed);
			mInOutConfirm.saveEx();
			trx.commit();
			data = (mInOutConfirm.getDocumentNo());

		} catch (Exception e) {
			System.out.println("some thing went wrong");
		}

//		String poDocNo = "ch800013";
//		int poQTY = 10;
//		int docID = 1000111;
//		String mrDocNo = "";
//		int cl_id = 1000002;
//		int currentClientId = Env.getAD_Client_ID(Env.getCtx());
////		Env.setContext(Env.getCtx(), "#AD_Client_ID", cl_id);
//		
////		Trx trx = Trx.get(Trx.createTrxName(), true);
////		trx.setDisplayName(getClass().getName()+"_");
//		
//		
//		BigDecimal poQTYB = new BigDecimal(poQTY);
////		Trx trx = Trx.get(Trx.createTrxName("MaterialReceiptCreator"), true);
//		MOrder purchaseOrder = null;
//		MInOut materialReceipt = null;
//		int docTypeId = MDocType.getDocType("Material Receipt");
//		try {
//			trx.start();
//			purchaseOrder = new Query(Env.getCtx(), MOrder.Table_Name, "DocumentNo=?", trx.getTrxName())
//					.setParameters(poDocNo)
////					.setClient_ID()
//					.first();
//
//			System.out.println(purchaseOrder.getAD_Client_ID());
//
//			if (purchaseOrder == null) {
//				throw new AdempiereException("Purchase Order not found: " + poDocNo);
//			}
//			int wareID = purchaseOrder.getM_Warehouse_ID();
//			int orgID = purchaseOrder.getAD_Org_ID();
//			int busiID = purchaseOrder.getBill_BPartner_ID();
//			int busiLoca = purchaseOrder.getBill_Location_ID();
//			int orderID = purchaseOrder.getC_Order_ID();
//			int salesRepID = purchaseOrder.getSalesRep_ID();
//			System.out.println(purchaseOrder.getProcessedOn());
//			
//			System.out.println(purchaseOrder.getAD_Client_ID());
//
////			System.out.println(wareID + " "+ orgID+ " "+ busiID+" "+busiLoca);
//
//			materialReceipt = new MInOut(purchaseOrder.getCtx(), 0, purchaseOrder.get_TrxName());
//			materialReceipt.setC_DocType_ID(docID);
//			materialReceipt.setAD_Org_ID(purchaseOrder.getAD_Org_ID());
//			materialReceipt.setM_Warehouse_ID(purchaseOrder.getM_Warehouse_ID());
//			materialReceipt.setMovementDate(purchaseOrder.getDatePromised());
//			materialReceipt.setC_BPartner_ID(busiID);
//			materialReceipt.setC_BPartner_Location_ID(busiLoca);
//			materialReceipt.setC_Order_ID(orderID);
//			materialReceipt.setDateOrdered(purchaseOrder.getDateOrdered());
//			materialReceipt.setSalesRep_ID(salesRepID);
//			materialReceipt.saveEx();
//
//			mrDocNo = materialReceipt.getDocumentNo();
//			System.out.println(mrDocNo);
//
//			for (MOrderLine poLine : purchaseOrder.getLines()) {
//				MInOutLine receiptLine = new MInOutLine(materialReceipt);
//				receiptLine.setOrderLine(poLine, 0, poLine.getQtyOrdered());
////				receiptLine.setQty(poQTYB);
//				receiptLine.setQtyEntered(poQTYB);
//				receiptLine.saveEx();
//			}
//			trx.commit();
//
//		} catch (Exception e) {
//			System.out.println("some thing went wrong");
//			trx.rollback();
//		} finally {
//			trx.close();
//		}
		return data;
	}
}

====================================================================================================================================================================
package org.wms.NearExpiry.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class NearExpiryProduct extends SvrProcess{
	
	private CLogger log = CLogger.getCLogger(NearExpiryProduct.class);
	private Properties ctx = Env.getCtx();
	private int clientId = Env.getAD_Client_ID(ctx);
	private StringBuilder result = new StringBuilder();

	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}
	
	@Override
	protected String doIt() throws Exception {
		// TODO Auto-generated method stub
		try {
			String query = "select b.name as Product_Name, a.expirydate, e.qtyonhand as ExpiryQTY, g.value as Warehouse_Name from adempiere.c_orderline a\n"
					+ "join adempiere.m_product b on a.m_product_id = b.m_product_id \n"
					+ "join adempiere.m_lot c on b.m_product_id = c.m_product_id\n"
					+ "join adempiere.m_attributesetinstance d on c.m_lot_id = d.m_lot_id\n"
					+ "join adempiere.m_storageonhand e on d.m_attributesetinstance_id = e.m_attributesetinstance_id\n"
					+ "join adempiere.c_order f on f.c_order_id = a.c_order_id\n"
					+ "join adempiere.m_locator g on g.m_locator_id = e.m_locator_id\n"
					+ "where a.ad_client_id = 1000002 and a.expirydate >= CURRENT_DATE and a.expirydate <= (CURRENT_DATE + INTERVAL '1 month')";
			
			PreparedStatement pstm = null;
			ResultSet rs = null;
			
			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();
			
			while(rs.next()) {
				String productName = rs.getString("Product_Name");
				String qty = rs.getString("ExpiryQTY");
				String expiryDate = rs.getString("expirydate");
				String warehouseName = rs.getString("Warehouse_Name");
				
				result.append(productName);
				result.append("\t");
				result.append(qty);
				result.append("\t");
				result.append(warehouseName);
				result.append("\t");
				result.append(expiryDate+",");
				result.append("\n");
			}
			pstm.close();
			rs.close();
			System.out.println(result.toString());
			
		}catch(Exception e) {
			System.out.println("some thing went wrong");
		}
		return result.toString();
	}

}



====================================================================================================================================================================
package org.wms.ProductExpiryNoti.Model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Properties;
import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class ExpiryNotification extends SvrProcess{
	
	private CLogger log = CLogger.getCLogger(ExpiryNotification.class);
	private Properties ctx = Env.getCtx();
	private int clientId = Env.getAD_Client_ID(ctx);
	private ArrayList<String> productList = new ArrayList<>();
	private ArrayList<String> dateList = new ArrayList<>();
	private ArrayList<String> qtyList = new ArrayList<>();
	private StringBuilder result = new StringBuilder();

	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}

	@Override
	protected String doIt() throws Exception {
		// TODO Auto-generated method stub
		
		try {
			String query = "select b.name as Product_Name, a.expirydate, e.qtyonhand as ExpiryQTY,g.value as Warehouse_Name from adempiere.c_orderline a\n"
					+ "join adempiere.m_product b on a.m_product_id = b.m_product_id \n"
					+ "join adempiere.m_lot c on b.m_product_id = c.m_product_id\n"
					+ "join adempiere.m_attributesetinstance d on c.m_lot_id = d.m_lot_id\n"
					+ "join adempiere.m_storageonhand e on d.m_attributesetinstance_id = e.m_attributesetinstance_id\n"
					+ "join adempiere.c_order f on f.c_order_id = a.c_order_id\n"
					+ "join adempiere.m_locator g on g.m_locator_id = e.m_locator_id\n"	
					+ "where a.ad_client_id = " + clientId + " and f.issotrx = 'N' and  a.expirydate < CURRENT_DATE";
			
			PreparedStatement pstm = null;
			ResultSet rs = null;
			
			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();
			
			while(rs.next()) {
				String productName = rs.getString("Product_Name");
				String date = rs.getString("expirydate");
				String wareName = rs.getString("Warehouse_Name");
				String qty = rs.getString("ExpiryQTY");
				
				result.append(productName);
				result.append("\t");
				result.append(qty);
				result.append("\t");
				result.append(wareName);
				result.append("\t");
				result.append(date+",");
				result.append("\n");	
			}
			pstm.close();
			rs.close();
			System.out.println(result.toString());	
		}catch(Exception e) {
			System.out.println("some thing went wrong");
		}
		return result.toString();
	}
}





====================================================================================================================================================================
package org.idempiere.web.testing.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Properties;
import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class WebTesting extends SvrProcess{
	
	private CLogger log = CLogger.getCLogger(WebTesting.class);
	private Properties ctx = Env.getCtx();
	private int clientId = Env.getAD_Client_ID(ctx);
	private ArrayList<String> accessebleWindows = new ArrayList<>();
	private String pur = "Purchase Order";
	private String sale = "Sales Order";
	private String mate = "Material Receipt";
	private String store = "Storage Provider";
	private boolean condtion1 = false;
	private boolean condtion2 = false;
	private boolean condtion3 = false;
	private boolean condtion4 = false;

	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}

	@Override
	protected String doIt() throws Exception {
		// TODO Auto-generated method stub
		StringBuilder resultData =  new StringBuilder();
		try {	
		String query = "select e.name as Access_Window from adempiere.ad_user_roles a\n"
				+ "join adempiere.ad_role b on a.ad_role_id = b.ad_role_id\n"
				+ "join adempiere.ad_user c on a.ad_user_id = c.ad_user_id\n"
				+ "join adempiere.ad_window_access d on a.ad_role_id = d.ad_role_id\n"
				+ "join adempiere.ad_window e on d.ad_window_id = e.ad_window_id\n"
				+ "where b.ad_role_id = 1000008 and a.ad_client_id = " + clientId + ";";
		
		PreparedStatement pstm = null;
		ResultSet rs = null;
		
		pstm = DB.prepareStatement(query.toString(), null);
		rs = pstm.executeQuery();
		
		while(rs.next()) {
			String AccessWindowsName = rs.getString("Access_Window");
			accessebleWindows.add(AccessWindowsName);
		}
		rs.close();
		pstm.close();
		
		for(String aw : accessebleWindows) {
			if (aw.equals(pur)) {
				condtion1 = true;
			}
			if(aw.equals(sale)) {
				condtion2 = true;
			}
			if(aw.equals(mate)) {
				condtion3 = true;
			}
			if(aw.equals(store)) {
				condtion4 = true;
				break;
			}
		}
		if(condtion1) 
			resultData.append("Receiving : true");
		else 
			resultData.append("Receiving : false");
		resultData.append("\n");
		
		if(condtion3) 
			resultData.append("QC Check : true");
		else 
			resultData.append("QC Check : false");
		resultData.append("\n");
		
		if(condtion4) 
			resultData.append("Physical Stock : true");
		else 
			resultData.append("Physical Stock : false");
		resultData.append("\n");
		
		if(condtion2) 
			resultData.append("Dispatch : ture");
		else 
			resultData.append("Dispatch : false");
		resultData.append("\n");
		
		System.out.println(resultData);
		
//		if(condtion1) {
//			System.out.println("Purchase Order is Available");
//		}else {
//			System.out.println("Purchase Order is not Available");
//		}
//		if(condtion2) {
//			System.out.println("Sales Order is Available");
//		}else {
//			System.out.println("Sales Order is not Available");
//		}
//		if(condtion3) {
//			System.out.println("Material Recipt is Available");
//		}else {
//			System.out.println("Material Recipt is not Available");
//		}
//		if(condtion4) {
//			System.out.println("Storage provider is Available");
//		}else {
//			System.out.println("Storage provider is not Available");
//		}		
		}catch(Exception e) {
			System.out.println("somethime error occured");
		}
		return "datas : "+resultData.toString();
	}
}






====================================================================================================================================================================

package org.wms.plugIn.pogen;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import org.compiere.model.MOrder;
import org.compiere.model.MOrderLine;
import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class POAutoGenerate extends SvrProcess{

	CLogger log = CLogger.getCLogger(POAutoGenerate.class);
	private Properties ctx = Env.getCtx();
	private int client_ID = Env.getAD_Client_ID(ctx);
	private int org_ID = Env.getAD_Org_ID(ctx);
	
	private int	p_Vendor_ID = 1000015;	
	private int p_Warehouse_ID = 1000016;	
	private int p_product_ID = 1000028;
	private int p_OrderLineQty = 50;
	private int p_Org_ID = 1000003;
	private int productQty;
	private int miniumQty = 100;
	
	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}

	@Override
	protected String doIt() throws Exception {
		// TODO Auto-generated method stub
		MOrder mOrder = null;
		try {
			String query = "SELECT SUM(qtyonhand) AS quantity FROM adempiere.M_StorageOnHand WHERE M_Product_ID = 1000028";
			PreparedStatement pstmt = null;
			ResultSet RS = null;
			pstmt = DB.prepareStatement(query.toString(), null);
			RS = pstmt.executeQuery();
			
			while(RS.next()) {
				productQty = RS.getInt("quantity");
				
				if(productQty < miniumQty) {
					mOrder = createPOOrder();					
				}else {
					log.info("PO Order not required");
				}
			}
		}catch(Exception e) {
			log.info("some error " + e);
		}	
		return "order created successfully "+mOrder.toString()+"";
	}
	
	private MOrder createPOOrder() throws Exception {
		
		MOrder po = new MOrder(getCtx(), 0, null);
		po.setC_DocTypeTarget_ID();
		po.setAD_Org_ID(p_Org_ID);
		po.setC_BPartner_ID(p_Vendor_ID);
		po.setM_Warehouse_ID(p_Warehouse_ID);
		po.setIsSOTrx(false);  //This line is provide using Purchase Order
		
		if(po.save()) {
			MOrderLine mOrderLine = new MOrderLine(po);
			mOrderLine.setM_Product_ID(p_product_ID);
			mOrderLine.setQty(BigDecimal.valueOf(p_OrderLineQty));
			mOrderLine.save();
			
			po.setDocAction(MOrder.DOCACTION_Complete);
			po.processIt(MOrder.DOCACTION_Complete);
			po.save();
			
			System.out.println("Order is SuccessFully");
		}else {
			System.out.println("Error data");
		}
		return po;
	}
}



====================================================================================================================================================================package org.notification.duebill.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;
import org.compiere.model.MBPartner;
import org.compiere.model.MClient;
import org.compiere.model.MUser;
import org.compiere.process.SvrProcess;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.EMail;
import org.compiere.util.Env;

public class AccountHold extends SvrProcess{
	private CLogger log = CLogger.getCLogger(AccountHold.class);
	private Properties ctx = Env.getCtx();
	private int clientId = Env.getAD_Client_ID(ctx);
	private String Hold = "H";
	private String Subject = "Account Payment Reminder";
    private String message = "Your account payment is overdue by 21 days. Please make the payment.";

	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}
	@Override
	protected String doIt() throws Exception {
		try {
			String sql = "SELECT C_BPartner_ID FROM adempiere.C_Invoice "
					+ "WHERE dateinvoiced + INTERVAL '21 days' <= current_date "
					+ "AND IsPaid='N' AND issotrx = 'Y'"
					+ "AND ad_client_id =" +clientId+ ";";
			
			PreparedStatement pstm = null;
			ResultSet rs = null;
			
			pstm = DB.prepareStatement(sql.toString(),null);
			rs = pstm.executeQuery();
			
			while(rs.next()) {
				
				int bPartnerID = rs.getInt("C_BPartner_ID");

				MBPartner bp = new MBPartner(getCtx(), bPartnerID,get_TrxName());
				
				String bpStatus = bp.getSOCreditStatus(); //check credit Status
				
				if(bpStatus != Hold) {

				bp.setSOCreditStatus(Hold);  //set Credit Status
				
				bp.saveEx();
				commitEx();
				System.out.println("BPartner Hold is SuccessFully, Id is :- "+bPartnerID);

				customMail(bPartnerID);
				
				}else {
					System.out.println("BPartner Already Hold");
				}	
			}	
		}catch(Exception e) {
			e.printStackTrace();
			log.warning("Some Error Occured");
		}
		return "Billing accounts placed on hold for overdue invoices.";
	}

	private void customMail(int bPartnerID) throws Exception {
		try {
		MBPartner bp = new MBPartner(getCtx(), bPartnerID,get_TrxName());
		MUser user = bp.getContact(bPartnerID);
		MClient client = MClient.get(Env.getCtx(), user.getAD_Client_ID());
		EMail mail = client.createEMail(user.getEMailUser(), Subject, message);
		System.out.println(mail);
		mail.sendEx();
		
		}catch(Exception e) {
			System.out.println("Email Problem");
		}
	}
}

