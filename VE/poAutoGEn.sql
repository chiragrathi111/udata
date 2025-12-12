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



------------------------------------------------------
@Override
	public CustomerListResponseDocument customerList(CustomerListRequestDocument customerListRequestDocument) {
		Trx trx = null;
		CustomerListResponseDocument customerListResponseDocument = CustomerListResponseDocument.Factory.newInstance();
		CustomerListResponse listResponse = customerListResponseDocument.addNewCustomerListResponse();
		CustomerListRequest customerListRequest = customerListRequestDocument.getCustomerListRequest();
		ADLoginRequest loginReq = customerListRequest.getADLoginRequest();
		String serviceType = customerListRequest.getServiceType();

		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			Properties ctx = m_cs.getCtx();

			int client_id = loginReq.getClientID();
			org.idempiere.adInterface.x10.ADLoginRequest adLoginReq = VeUtils.convertAdLogin(loginReq);
			String err = login(adLoginReq, webServiceName, "sOList", serviceType);
			if (err != null && err.length() > 0) {
				listResponse.setError(err);
				listResponse.setIsError(true);
				return customerListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("sOList")) {
				listResponse.setIsError(true);
				listResponse.setError("Service type " + serviceType + " not configured");
				return customerListResponseDocument;
			}
			int pageNo  = customerListRequest.getPageNo() > 0 ? customerListRequest.getPageNo() : 1;
	        int pageSize = customerListRequest.getPageSize() > 0 ? customerListRequest.getPageSize() : 20;
	        
	        String searchKey = customerListRequest.getSearchKey(); 
	        boolean hasSearch = (searchKey != null && searchKey.trim().length() > 0);
	        
	        StringBuilder sql = new StringBuilder("AD_Client_ID=? AND IsActive='Y'");

	        Boolean type = customerListRequest.getIsVendor();

	        if (type) {
	            sql.append(" AND IsVendor='Y'");
	        } else { 
	            sql.append(" AND IsCustomer='Y'");
	        }

	        if (hasSearch) {
	            sql.append(" AND (UPPER(Value) LIKE ? OR UPPER(Name) LIKE ?)");
	        }
	        	        
	        Query q = new Query(ctx, MBPartner.Table_Name, sql.toString(), trxName)
	                .setParameters(client_id);

	        if (hasSearch) {
	            String like = "%" + searchKey.trim().toUpperCase() + "%";
	            q.setParameters(client_id, like, like);
	        }
	        
	        List<PO> customers = q.list();

	        int fromIndex = (pageNo - 1) * pageSize;
	        if (fromIndex >= customers.size()) {
	            fromIndex = 0;
	        }
	        int toIndex = Math.min(fromIndex + pageSize, customers.size());

	        List<PO> listOfCustomer = customers.subList(fromIndex, toIndex);

	        if (listOfCustomer == null || customers.size() == 0) {
	            listResponse.setIsError(true);
	            listResponse.setError("Customers not found");
	            return customerListResponseDocument;
	        }

			for (PO po : listOfCustomer) {
				MBPartner customer = new MBPartner(ctx, po.get_ID(), trxName);
				Customer cust = listResponse.addNewCustomer();
				cust.setCustomerId(customer.getC_BPartner_ID());
				cust.setCustomerName(customer.getName());
			}

			trx.commit();
			listResponse.setIsError(false);
		} catch (Exception e) {
			e.printStackTrace();
			listResponse.setError(e.getMessage());
			listResponse.setIsError(true);
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return customerListResponseDocument;
	}

	----------------------

@Override
	public BPartnerListResponseDocument customerList(BPartnerListRequestDocument customerListRequestDocument) {
		Trx trx = null;
		BPartnerListResponseDocument bPartnerListResponseDocument = BPartnerListResponseDocument.Factory.newInstance();
		BPartnerListResponse listResponse = bPartnerListResponseDocument.addNewBPartnerListResponse();
		BPartnerListRequest customerListRequest = customerListRequestDocument.getBPartnerListRequest();
		ADLoginRequest loginReq = customerListRequest.getADLoginRequest();
		String serviceType = customerListRequest.getServiceType();

		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			Properties ctx = m_cs.getCtx();

			int client_id = loginReq.getClientID();
			org.idempiere.adInterface.x10.ADLoginRequest adLoginReq = VeUtils.convertAdLogin(loginReq);
			String err = login(adLoginReq, webServiceName, "sOList", serviceType);
			if (err != null && err.length() > 0) {
				listResponse.setError(err);
				listResponse.setIsError(true);
				return bPartnerListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("sOList")) {
				listResponse.setIsError(true);
				listResponse.setError("Service type " + serviceType + " not configured");
				return bPartnerListResponseDocument;
			}
			int pageNo  = customerListRequest.getPageNo() > 0 ? customerListRequest.getPageNo() : 1;
	        int pageSize = customerListRequest.getPageSize() > 0 ? customerListRequest.getPageSize() : 20;
	        
	        String searchKey = customerListRequest.getSearchKey(); 
	        boolean hasSearch = (searchKey != null && searchKey.trim().length() > 0);
	        
	        StringBuilder sql = new StringBuilder("AD_Client_ID=? AND IsActive='Y'");

	        Boolean type = customerListRequest.getIsVendor();

	        if (type) {
	            sql.append(" AND IsVendor='Y'");
	        } else { 
	            sql.append(" AND IsCustomer='Y'");
	        }

	        if (hasSearch) {
	            sql.append(" AND (UPPER(Value) LIKE ? OR UPPER(Name) LIKE ?)");
	        }
	        	        
	        Query q = new Query(ctx, MBPartner.Table_Name, sql.toString(), trxName)
	                .setParameters(client_id);

	        if (hasSearch) {
	            String like = "%" + searchKey.trim().toUpperCase() + "%";
	            q.setParameters(client_id, like, like);
	        } else {
	            q.setParameters(client_id);
	        }
	        
	        List<PO> bpartners = q.list();

	        int fromIndex = (pageNo - 1) * pageSize;
	        if (fromIndex >= bpartners.size()) {
	        	listResponse.setIsError(false);
	            return bPartnerListResponseDocument;
	        }
	        int toIndex = Math.min(fromIndex + pageSize, bpartners.size());

	        List<PO> listOfBPartner = bpartners.subList(fromIndex, toIndex);

	        if (listOfBPartner.isEmpty()) {
	            listResponse.setIsError(true);
	            listResponse.setError("Business Partner not found");
	            return bPartnerListResponseDocument;
	        }

			for (PO po : listOfBPartner) {
				MBPartner bpartner = (MBPartner) po;
				BusinessPartners cust = listResponse.addNewBusinessPartners();
				cust.setBPartnerId(bpartner.getC_BPartner_ID());
				cust.setBusinessPartnerName(bpartner.getName());
			}

			trx.commit();
			listResponse.setIsError(false);
		} catch (Exception e) {
			e.printStackTrace();
			listResponse.setError(e.getMessage());
			listResponse.setIsError(true);
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return bPartnerListResponseDocument;
	}	