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
	private int p_product_ID = 1000029;
	private int p_OrderLineQty = 50;
	private int p_Org_ID = 1000003;
	private int productQty,orderQTY;
	private int sum = 0;
	private int miniumQty = 500;
	
	@Override
	protected void prepare() {
	}

	@Override
	protected String doIt() throws Exception {
		MOrder mOrder = null;
		try {
			String query = "SELECT SUM(qtyonhand) AS quantity FROM adempiere.M_StorageOnHand WHERE M_Product_ID = 1000029";
			PreparedStatement pstmt = null;
			ResultSet RS = null;
			pstmt = DB.prepareStatement(query.toString(), null);
			RS = pstmt.executeQuery();
			
			String sql = "select sum(qtyordered) AS orderQty from adempiere.C_Orderline ci\n"
					+ "join adempiere.c_order co on co.c_order_id = ci.c_order_id where ci.M_Product_ID = 1000029 and co.issotrx = 'N'";
			PreparedStatement pstm = null;
			ResultSet rss = null;
			pstm = DB.prepareStatement(sql.toString(), null);
			rss = pstm.executeQuery();
			
			while(RS.next()) {
				productQty = RS.getInt("quantity");
				if(productQty < miniumQty) {
					
					while(rss.next()) {
						orderQTY = rss.getInt("orderQty");
						sum = productQty + orderQTY ;
						productQty = sum;
						
						if(sum < miniumQty) {
							mOrder = createPOOrder();
						}else {
							return "order Qty and on hand qty both added is enough";
						}
					}					
				}else {
					return "Product Qty is enough";
				}
			}
		}catch(Exception e) {
			return "some thing error" +e.getMessage();
		}	
		return "order created successfully" + mOrder.toString() +"";
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
