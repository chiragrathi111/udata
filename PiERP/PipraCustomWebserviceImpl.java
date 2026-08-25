package org.pipra.webservices.custom;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TimeZone;
import java.util.stream.Collectors;

import javax.imageio.ImageIO;
import javax.jws.WebService;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.adempiere.exceptions.AdempiereException;
import org.codehaus.jettison.json.JSONObject;
import org.compiere.model.IAttachmentStore;
import org.compiere.model.I_M_InOut;
import org.compiere.model.MAcctSchema;
import org.compiere.model.MAttachment;
import org.compiere.model.MAttachmentEntry;
import org.compiere.model.MBPartner;
import org.compiere.model.MBPartnerLocation;
import org.compiere.model.MDocType;
import org.compiere.model.MElementValue;
import org.compiere.model.MFactAcct;
import org.compiere.model.MGLCategory;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutConfirm;
import org.compiere.model.MInOutLine;
import org.compiere.model.MInOutLineConfirm;
import org.compiere.model.MInventoryLine;
import org.compiere.model.MInvoice;
import org.compiere.model.MLocation;
import org.compiere.model.MLocator;
import org.compiere.model.MMessage;
import org.compiere.model.MMovement;
import org.compiere.model.MMovementLine;
import org.compiere.model.MMovementLineMA;
import org.compiere.model.MNote;
import org.compiere.model.MOrder;
import org.compiere.model.MOrderLine;
import org.compiere.model.MPeriod;
import org.compiere.model.MProduct;
import org.compiere.model.MRMA;
import org.compiere.model.MRMALine;
import org.compiere.model.MShipper;
import org.compiere.model.MStorageOnHand;
import org.compiere.model.MStorageProvider;
import org.compiere.model.MTable;
import org.compiere.model.MTransaction;
import org.compiere.model.MUser;
import org.compiere.model.MWarehouse;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.model.X_M_RMAType;
import org.compiere.process.DocAction;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.compiere.util.KeyNamePair;
import org.compiere.util.Login;
import org.compiere.util.Trx;
import org.idempiere.adInterface.x10.*;
import org.idempiere.adinterface.CompiereService;
import org.idempiere.webservices.AbstractService;
import org.pipra.custom.fcm.FCMService;
import org.pipra.model.custom.AdRole_Custom;
import org.pipra.model.custom.MProduct_Custom;
import org.pipra.model.custom.PiProductLabel;
import org.pipra.model.custom.PiQrRelations;
import org.pipra.model.custom.PiUserToken;
import org.pipra.model.custom.PipraUtils;
import org.pipra.model.custom.X_pi_InventoryDetail;
import org.pipra.model.custom.X_pi_InventoryLine;
import org.pipra.model.custom.X_pi_LabelInventory;
import org.pipra.model.custom.X_pi_items_inout;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebService(endpointInterface = "org.pipra.webservices.custom.PipraCustomWebservice", serviceName = "PipraCustomWebservice", targetNamespace = "http://idempiere.org/ADInterface/1_0")
public class PipraCustomWebserviceImpl extends AbstractService implements PipraCustomWebservice {

	public static final String ROLE_TYPES_WEBSERVICE = "NULL,WS,SS";
	private static String webServiceName = new String("PipraCustomWebservice");
	private static final String TABLE_WAREHOUSE = "M_Warehouse";

	private boolean manageTrx = true;

	public boolean isManageTrx() {
		return manageTrx;
	}

	public void setJaxrsContext(org.apache.cxf.jaxrs.ext.MessageContext context) {
		this.jaxrsContext = context;
	}

	public void setManageTrx(boolean manageTrx) {
		this.manageTrx = manageTrx;
	}

	@Override
	public LoginApiResponseDocument loginApi(LoginApiRequestDocument loginRequestDocument) {
		Trx trx = null;
		LoginApiResponseDocument loginApiResponseDocument = LoginApiResponseDocument.Factory.newInstance();
		LoginApiResponse loginApiResponse = loginApiResponseDocument.addNewLoginApiResponse();
		LoginApiRequest loginRequest = loginRequestDocument.getLoginApiRequest();
		try {

			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			Login login = new Login(m_cs.getCtx());
			String serviceType = loginRequest.getServiceType();
			if (!serviceType.equalsIgnoreCase("openLoginApi")) {
				loginApiResponse.setIsError(true);
				loginApiResponse.setError("Service type " + serviceType + " not configured");
				loginApiResponseDocument.setLoginApiResponse(loginApiResponse);
				return loginApiResponseDocument;
			}

			KeyNamePair[] clients = login.getClients(loginRequest.getUser(), loginRequest.getPassword(),
					ROLE_TYPES_WEBSERVICE);
			if (clients == null) {
				loginApiResponse.setIsError(true);
				loginApiResponse.setError("Invalid User ID or Password");
				loginApiResponseDocument.setLoginApiResponse(loginApiResponse);
				return loginApiResponseDocument;
			}

			String userType = null;
			List<PO> poList = MInOut_Custom.getUserByName(loginRequest.getUser(), ctx, trxName);
			if (poList.size() != 0) {
				MUser mUser = new MUser(ctx, poList.get(0).get_ID(), trxName);
				userType = mUser.getC_Job().getName();
			}
			if (userType == null)
				loginApiResponse.setUserType("");
			else
				loginApiResponse.setUserType(userType);

			for (KeyNamePair client : clients) {

				Client clientName = loginApiResponse.addNewClient();
				KeyNamePair[] roles = login.getRoles(loginRequest.getUser(), client, ROLE_TYPES_WEBSERVICE);

				if (roles != null) {
					for (KeyNamePair role : roles) {
						Role roleName = clientName.addNewRoleList();
						roleName.setRoleId(role.getID());
						roleName.setRole(role.getName());

						KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(role.getKey(), ""));
						if (orgs != null) {
							for (KeyNamePair org : orgs) {
								Organization orgName = roleName.addNewOrgList();
								orgName.setOrgId(org.getID());
								orgName.setOrg(org.getName());

								KeyNamePair[] warehouses = login.getWarehouses(new KeyNamePair(org.getKey(), ""));
								if (warehouses != null) {
									for (KeyNamePair warehouse : warehouses) {
										Warehouse wName = orgName.addNewWarehouse();
										wName.setWarehouseId(warehouse.getID());
										wName.setWarehouse(warehouse.getName());
									}
								}
							}
						}
					}
				}
				clientName.setClientId(client.getID());
				clientName.setClient(client.getName());
			}
			trx.commit();
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return loginApiResponseDocument;
	}

	@Override
	public RoleConfigureResponseDocument roleConfig(RoleConfigureRequestDocument roleConfigureRequestDocument) {

		RoleConfigureResponseDocument roleConfigureResponseDocument = RoleConfigureResponseDocument.Factory
				.newInstance();
		RoleConfigureResponse roleResponse = roleConfigureResponseDocument.addNewRoleConfigureResponse();
		RoleConfigureRequest roleRequest = roleConfigureRequestDocument.getRoleConfigureRequest();
		ADLoginRequest loginReq = roleRequest.getADLoginRequest();
		String deviceToken = roleRequest.getDeviceToken();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		Trx trx = null;
		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			Properties ctx = m_cs.getCtx();
			int roleId = loginReq.getRoleID();
			String serviceType = roleRequest.getServiceType();

			String err = login(loginReq, webServiceName, "roleConfig", serviceType);
			if (err != null && err.length() > 0) {
				roleResponse.setError(err);
				roleResponse.setIsError(true);
				return roleConfigureResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("roleConfig")) {
				roleResponse.setIsError(true);
				roleResponse.setError("Service type " + serviceType + " not configured");
				return roleConfigureResponseDocument;
			}

			AdRole_Custom adRole_Custom = new AdRole_Custom(ctx, roleId, trxName, null);
			RoleAppAcess a = roleResponse.addNewAppAcess();
			a.setAppName("recieveApp");
			a.setAppAcess(adRole_Custom.isPurchaseOrder());

			RoleAppAcess b = roleResponse.addNewAppAcess();
			b.setAppName("materialReceipt");
			b.setAppAcess(adRole_Custom.isMaterialReceipt());

			RoleAppAcess c = roleResponse.addNewAppAcess();
			c.setAppName("stockCheckApp");
			c.setAppAcess(adRole_Custom.isPhysicalInventory());

			RoleAppAcess d = roleResponse.addNewAppAcess();
			d.setAppName("pickList");
			d.setAppAcess(adRole_Custom.isSaleOrder());

			RoleAppAcess e = roleResponse.addNewAppAcess();
			e.setAppName("dispatchApp");
			e.setAppAcess(adRole_Custom.isShipmentCustomer());

			RoleAppAcess f = roleResponse.addNewAppAcess();
			f.setAppName("addInward");
			f.setAppAcess(adRole_Custom.isAddInward());

			RoleAppAcess g = roleResponse.addNewAppAcess();
			g.setAppName("ispickbyorder");
			g.setAppAcess(adRole_Custom.ispickbyorder());

			RoleAppAcess h = roleResponse.addNewAppAcess();
			h.setAppName("receiving_processed_app");
			h.setAppAcess(adRole_Custom.isReceivingProcessedApp());

			RoleAppAcess i = roleResponse.addNewAppAcess();
			i.setAppName("unauthorised_events");
			i.setAppAcess(adRole_Custom.isUnauthorisedEvents());

			RoleAppAcess j = roleResponse.addNewAppAcess();
			j.setAppName("users_app");
			j.setAppAcess(adRole_Custom.isUsersApp());

			RoleAppAcess k = roleResponse.addNewAppAcess();
			k.setAppName("itemInout");
			k.setAppAcess(adRole_Custom.isItemInout());

			RoleAppAcess l = roleResponse.addNewAppAcess();
			l.setAppName("supervisorPutaway");
			l.setAppAcess(adRole_Custom.issupervisorputawayapp());

			RoleAppAcess m = roleResponse.addNewAppAcess();
			m.setAppName("labourPutaway");
			m.setAppAcess(adRole_Custom.isLabourPutaway());

			RoleAppAcess n = roleResponse.addNewAppAcess();
			n.setAppName("qcCheckApp");
			n.setAppAcess(adRole_Custom.isQcCheckApp());

			RoleAppAcess o = roleResponse.addNewAppAcess();
			o.setAppName("customerRma");
			o.setAppAcess(true);

			boolean flag = true;
			if (deviceToken != null && !deviceToken.isEmpty())
				flag = PiUserToken.checkTokenExistForuser(deviceToken, Env.getAD_User_ID(ctx), ctx, trxName);
			if (!flag) {
				PiUserToken piUserToken = new PiUserToken(ctx, 0, trxName);
				piUserToken.setAD_User_ID(Env.getAD_User_ID(ctx));
				piUserToken.setdevicetoken(deviceToken);
				piUserToken.saveEx();
			}
			trx.commit();

		} catch (Exception e) {
			roleResponse.setError(e.getMessage());
			roleResponse.setIsError(true);
			return roleConfigureResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
			trx.close();
		}
		return roleConfigureResponseDocument;
	}

	@Override
	public POListResponseDocument poList(POListRequestDocument pOListRequestDocument) {
		List<POListAccess> poLists = new ArrayList<>();
		POListResponseDocument pOListResponseDocument = POListResponseDocument.Factory.newInstance();
		POListResponse listResponse = pOListResponseDocument.addNewPOListResponse();

		POListRequest pOListRequest = pOListRequestDocument.getPOListRequest();
		ADLoginRequest loginReq = pOListRequest.getADLoginRequest();
		String serviceType = pOListRequest.getServiceType();
		String searchKey = pOListRequest.getSearchKey();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			int client_id = loginReq.getClientID();
			int roleId = loginReq.getRoleID();
			String err = login(loginReq, webServiceName, "poList", serviceType);
			if (err != null && err.length() > 0) {
				listResponse.setError(err);
				listResponse.setIsError(true);
				return pOListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("poli")) {
				listResponse.setIsError(true);
				listResponse.setError("Service type " + serviceType + " not configured");
				return pOListResponseDocument;
			}

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "SELECT\n" + "    DISTINCT(po.documentno) AS purchase_order,\n"
					+ "    po.c_order_id AS cOrderId,\n" + "    bp.name AS Supplier, po.created,\n"
					+ "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n" + "    wh.name AS Warehouse_Name,\n"
					+ "    po.description,\n" + "    po.ad_org_id,\n" + "    CASE\n"
					+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n"
					+ "    END AS status\n" + "FROM c_order po\n"
					+ "JOIN c_orderline pol ON po.c_order_id = pol.c_order_id\n"
					+ "LEFT JOIN m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE pol.qtyordered > (\n"
					+ "        SELECT COALESCE(SUM(iol.qtyentered), 0)\n" + "        FROM m_inoutline iol\n"
					+ "        WHERE iol.c_orderline_id = pol.c_orderline_id\n" + "    ) and po.ad_client_id = "
					+ client_id + " and po.docstatus = 'CO' and po.issotrx = 'N' " + "AND (\n"
					+ "    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'\n"
					+ "    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'\n"
					+ "    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'\n"
					+ "    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'\n" + ")"
					+ "and po.ad_org_id IN (" + orgIds + ") ORDER BY po.created desc;\n" + "";

			pstm = DB.prepareStatement(query.toString(), null);
			pstm.setString(1, searchKey);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String documentNo = rs.getString("Purchase_Order");
				String cOrderId = rs.getString("cOrderId");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				boolean Status = rs.getBoolean("status");

				poLists.add(createPOList(documentNo, cOrderId, supplier, date, warehouseName, description, Status));
			}
			POListAccess[] polistArray = poLists.toArray(new POListAccess[poLists.size()]);
			listResponse.setListAccessArray(polistArray);

		} catch (Exception e) {
			listResponse.setError(e.getMessage());
			return pOListResponseDocument;

		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		pOListResponseDocument.setPOListResponse(listResponse);
		return pOListResponseDocument;
	}

	private POListAccess createPOList(String docNo, String cOrderId, String supplier, String date, String warehouseName,
			String description, boolean status) {
		POListAccess poListAccess = POListAccess.Factory.newInstance();
		poListAccess.setDocumentNumber(docNo);
		poListAccess.setCOrderId(cOrderId);
		poListAccess.setSupplierName(supplier);
		poListAccess.setOrderDate(date);
		poListAccess.setWarehouseName(warehouseName);
		if (description == null)
			poListAccess.setDescription("");
		else
			poListAccess.setDescription(description);
		poListAccess.setOrderStatus(status);
		return poListAccess;
	}

	@Override
	public PODataResponseDocument poData(PODataRequestDocument pODataRequestDocument) {
		PODataResponseDocument pODataResponseDocument = PODataResponseDocument.Factory.newInstance();
		PODataResponse pODataResponse = pODataResponseDocument.addNewPODataResponse();
		PODataRequest pODataRequest = pODataRequestDocument.getPODataRequest();
		ADLoginRequest loginReq = pODataRequest.getADLoginRequest();
		String serviceType = pODataRequest.getServiceType();
		String documentNo = pODataRequest.getDocumentNo();
		int client_ID = loginReq.getClientID();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "poData", serviceType);
			if (err != null && err.length() > 0) {
				pODataResponse.setError(err);
				pODataResponse.setIsError(true);
				return pODataResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("poData")) {
				pODataResponse.setIsError(true);
				pODataResponse.setError("Service type " + serviceType + " not configured");
				return pODataResponseDocument;
			}
			String query = null;
			query = "SELECT a.qtyordered as totalQnty, (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name\n"
					+ "FROM c_orderline a \n" + "JOIN c_order d ON d.c_order_id = a.c_order_id \n"
					+ "LEFT JOIN m_inout b ON a.c_order_id = b.c_order_id \n"
					+ "LEFT JOIN m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.c_orderline_id = a.c_orderline_id\n"
					+ "JOIN m_product e ON e.m_product_id = a.m_product_id \n" + "WHERE d.documentno = '" + documentNo
					+ "' AND d.ad_client_id = '" + client_ID + "' AND a.c_order_id = (\n"
					+ "  SELECT c_order_id FROM c_order WHERE documentno = '" + documentNo + "' AND ad_client_id = '"
					+ client_ID + "'\n" + ")\n"
					+ "GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id ORDER BY a.c_orderline_id;\n"
					+ "";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int qnty = 0;
			int cOrderId = 0;
			while (rs.next()) {
				ProductData productData = pODataResponse.addNewProductData();
				int outstandingQty = rs.getInt("outstanding_qty");
				int totalQnty = rs.getInt("totalQnty");
				String productName = rs.getString("product_name");
				int productId = rs.getInt("productId");
				cOrderId = rs.getInt("c_order_id");
				int cOrderlineId = rs.getInt("c_orderline_id");
				int uomId = rs.getInt("c_uom_id");
				productData.setProductId(productId);
				productData.setProductName(productName);
				productData.setCOrderlineId(cOrderlineId);
				productData.setUomId(uomId);
				productData.setOutstandingQnty(outstandingQty);
				productData.setTotalQuantity(totalQnty);
				qnty += Integer.valueOf(outstandingQty);
				
				MProduct_Custom product = new MProduct_Custom(Env.getCtx(), productId, null);
				
//				Integer productCount = product.getProductCount();
//				productData.setProductCount(productCount != null ? productCount : 0);
				
				Integer productCount = 0;
			    try {
			        productCount = product.getProductCount();
//			        if (productCount == null)
//			            productCount = 0;
			        
			    } catch (NullPointerException e) {
			        System.err.println("⚠️ NullPointerException in getProductCount for product " + productId);
			        productCount = 0;
			    } catch (Exception e) {
			        System.err.println("⚠️ Error getting product count for product " + productId);
			        productCount = 0;
			    }
			    
			    try {
			        java.lang.reflect.Method m = productData.getClass().getMethod("setProductCount", int.class);
			        m.invoke(productData, productCount);
			    } catch (Throwable t) {
			        System.err.println("⚠️ Warning: setProductCount not available on ProductData: " + t.getMessage());
			    }

			}
			pODataResponse.setCOrderId(cOrderId);
			pODataResponse.setOverallQnty(qnty);
			pstm.close();
			rs.close();

			query = "SELECT\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    bp.name AS Supplier,\n" + "    wh.name AS Warehouse_Name,\n" + "    po.description,\n"
					+ "    po.docstatus,\n" + "    ml.m_locator_id,\n" + "	CASE\n"
					+ "   	 WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "   	 WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n" + "  	END AS status\n"
					+ "FROM c_order po\n" + "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id\n"
					+ "LEFT JOIN m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN m_locator ml ON ml.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE\n"
					+ "    po.documentno = '" + documentNo + "'\n" + "    AND isDefault = 'Y' AND po.ad_client_id = "
					+ client_ID + ";";
			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String orderDate = rs.getString("Order_Date");
				String supplier = rs.getString("Supplier");
				String docStatus = rs.getString("docstatus");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				boolean orderStatus = rs.getBoolean("status");
				int mLocatorId = rs.getInt("m_locator_id");
				pODataResponse.setOrderDate(orderDate);
				pODataResponse.setDocstatus(docStatus);
				pODataResponse.setSupplier(supplier);
				pODataResponse.setWarehouseName(warehouseName);
				if (description == null)
					pODataResponse.setDescription("");
				else
					pODataResponse.setDescription(description);
				pODataResponse.setDefaultLocatorId(mLocatorId);
				pODataResponse.setOrderStatus(orderStatus);
			}
			pODataResponse.setDocumentNo(documentNo);
		} catch (Exception e) {
			pODataResponse.setError(e.getMessage());
			pODataResponse.setIsError(true);
			e.printStackTrace();
			return pODataResponseDocument;

		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return pODataResponseDocument;
	}

	@Override
	public CreateMRResponseDocument createMR(CreateMRRequestDocument createMRRequestDocument) {
		CreateMRResponseDocument createMRResponseDocument = CreateMRResponseDocument.Factory.newInstance();
		CreateMRResponse createMRResponse = createMRResponseDocument.addNewCreateMRResponse();
		CreateMRRequest createMRRequest = createMRRequestDocument.getCreateMRRequest();
		ADLoginRequest loginReq = createMRRequest.getADLoginRequest();
		String serviceType = createMRRequest.getServiceType();
		int cOrderId = createMRRequest.getCOrderId();
		MInvoice m_invoice = null;
		MRMA m_rma = null;
		Trx trx = null;
		int clientID = loginReq.getClientID();
		CompiereService m_cs = getCompiereService();
		Properties ctx = m_cs.getCtx();
		int mInoutId = 0;
		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "createMR", serviceType);
			if (err != null && err.length() > 0) {
				createMRResponse.setError(err);
				createMRResponse.setIsError(true);
				return createMRResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("createMR")) {
				createMRResponse.setIsError(true);
				createMRResponse.setError("Service type " + serviceType + " not configured");
				return createMRResponseDocument;
			}

			MRLines[] MRLinesArray = createMRRequest.getMRLinesArray();

			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable.getPO("name = 'MM Receipt' and ad_client_id = " + clientID + "",
					trx.getTrxName());
			MDocType mDocType = (MDocType) docTypePO;

			MTable table = MTable.get(ctx, "c_order");
			PO po = table.getPO(cOrderId, trx.getTrxName());

			MInOut inout = null;
			int clientId = loginReq.getClientID();
			int orgId = loginReq.getOrgID();
			int userId = Env.getAD_User_ID(ctx);
			if (po.get_ID() == 0) {
				int warehouseId = createMRRequest.getWarehouseId();
				int bPartnerId = createMRRequest.getBPartnerId();
				String description = createMRRequest.getDescription();
				Timestamp movementDate = new Timestamp(createMRRequest.getMovementdate().getTimeInMillis());

				inout = new MInOut_Custom(ctx, trxName, clientId, orgId, userId, bPartnerId, warehouseId, mDocType,
						movementDate, description);
				inout.saveEx();

				mInoutId = inout.getM_InOut_ID();

				for (MRLines data : MRLinesArray) {
					int M_Product_ID = data.getProductId();
					int C_UOM_ID = data.getUomId();
					BigDecimal QtyEntered = BigDecimal.valueOf(data.getQnty());
					int M_Locator_ID = data.getLocator();

					MInOutLine iol = new MInOutLine(ctx, 0, trxName);
					iol.setM_InOut_ID(mInoutId);
					iol.setM_Product_ID(M_Product_ID, C_UOM_ID); // Line UOM
					iol.setQty(QtyEntered);

					iol.setMovementQty(QtyEntered);
					iol.setC_UOM_ID(C_UOM_ID);
					iol.setM_Warehouse_ID(warehouseId);
					iol.setM_Locator_ID(M_Locator_ID);
					iol.saveEx();

					data.setMrLineId(iol.get_ID());
				}

			} else {
				MOrder order = (MOrder) po;

				MInOut receipt = new MInOut(order, mDocType.get_ID(), order.getDateOrdered());
				receipt.setDocStatus(DocAction.STATUS_Drafted);
				receipt.saveEx();

				mInoutId = receipt.getM_InOut_ID();
				inout = new MInOut(ctx, mInoutId, trx.getTrxName());
				for (MRLines data : MRLinesArray) {
					int C_InvoiceLine_ID = 0;
					int M_RMALine_ID = 0;
					int M_Product_ID = data.getProductId();
					int C_UOM_ID = data.getUomId();
					int C_OrderLine_ID = data.getCOrderlineId();
					BigDecimal QtyEntered = BigDecimal.valueOf(data.getQnty());
					int M_Locator_ID = data.getLocator();

					inout.createLineFrom(C_OrderLine_ID, C_InvoiceLine_ID, M_RMALine_ID, M_Product_ID, C_UOM_ID,
							QtyEntered, M_Locator_ID);
					MInOutLine lineArray[] = MInOutLine.get(ctx, C_OrderLine_ID, trxName);
					MInOutLine line = lineArray[lineArray.length - 1];
					data.setMrLineId(line.get_ID());
				}
				inout.updateFrom(order, m_invoice, m_rma);
			}
			trx.commit();
			createMRResponse.setMRLinesArray(MRLinesArray);
			createMRResponse.setIsError(false);
			createMRResponse.setMrDocumentNumber(inout.getDocumentNo());
			createMRResponse.setMrId(inout.get_ID());

			Map<String, String> data = new HashMap<>();
			data.put("recordId", String.valueOf(inout.getM_InOut_ID()));
			data.put("documentNo", String.valueOf(inout.getDocumentNo()));
			data.put("path1", "/put_away_screen");
			data.put("path2", "/put_away_detail_screen");

//			PipraUtils.sendNotificationAsync("Supervisor", inout.get_Table_ID(), inout.getM_InOut_ID(), ctx, trxName,
//					"New Inward: " + inout.getDocumentNo() + "",
//					" Inward - " + inout.getDocumentNo() + " added to process", inout.get_TableName(), data,
//					loginReq.getClientID(), "MaterialReciptCreated");

			PipraUtils.sendNotificationAsyncnew("Supervisor", // role name
					inout.get_Table_ID(), // table ID for MNote
					inout.getM_InOut_ID(), // record ID for MNote
					ctx, trxName, "New Inward: " + inout.getDocumentNo(), // notification title
					"Inward - " + inout.getDocumentNo() + " added to process", // notification body
					inout.get_TableName(), data, loginReq.getClientID(), // client/tenant ID
					"MaterialReciptCreated" // AD_Message value
			);

		} catch (Exception e) {
			MTable table = MTable.get(ctx, "m_inout");
			PO po = table.getPO(mInoutId, trx.getTrxName());
			po.delete(true);
			createMRResponse.setError(e.getMessage());
			createMRResponse.setIsError(true);
			return createMRResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return createMRResponseDocument;
	}

	@Override
	public MRListResponseDocument getMrList(MRListRequestDocument pOListRequestDocument) {

		MRListResponseDocument mRListResponseDocument = MRListResponseDocument.Factory.newInstance();
		MRListResponse listResponse = mRListResponseDocument.addNewMRListResponse();
		MRListRequest mRListRequest = pOListRequestDocument.getMRListRequest();
		ADLoginRequest loginReq = mRListRequest.getADLoginRequest();
		String serviceType = mRListRequest.getServiceType();
		String searchKey = mRListRequest.getSearchKey();
		String isSalesTransaction = mRListRequest.getIsSalesTransaction();
		String status = mRListRequest.getStatus();
		if (status != null && status.trim().isEmpty()) {
			status = null;
		}
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			int clientId = loginReq.getClientID();
			int roleId = loginReq.getRoleID();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				listResponse.setError(err);
				listResponse.setIsError(true);
				return mRListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				listResponse.setIsError(true);
				listResponse.setError("Service type " + serviceType + " not configured");
				return mRListResponseDocument;
			}
			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "SELECT\n" + "    DISTINCT(po.documentno) AS documentNo,\n" + "    bp.name AS Supplier,\n"
					+ "    po.m_inout_id AS mInoutID,\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name,\n" + "    po.description, po.m_inout_id,\n"
					+ "po.pickStatus,	co.documentno as orderDocumentno, po.created \n" + "FROM m_inout po\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "JOIN c_order co on co.c_order_id = po.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE po.ad_client_id = "
					+ clientId + " AND po.issotrx = '" + isSalesTransaction
					+ "' AND po.docstatus = 'DR' AND po.ad_org_id IN (" + orgIds + ") AND po.ad_orgtrx_id is null "
					+ "AND (\n" + "    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'\n"
					+ "    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'\n"
					+ "    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'\n"
					+ "    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'\n"
					+ "    OR co.documentno ILIKE '%' || COALESCE(?, co.documentno) || '%'\n" + ")\n"
					+ " ORDER BY po.created desc;";

			pstm = DB.prepareStatement(query.toString(), null);
			pstm.setString(1, searchKey);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			pstm.setString(5, searchKey);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {
				String documentNo = rs.getString("documentNo");
				String mInoutID = rs.getString("mInoutID");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String orderDocumentno = rs.getString("orderDocumentno");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				String pickStatus = rs.getString("pickStatus");
				if (pickStatus == null || !pickStatus.equalsIgnoreCase("QC")) {
					if ((status != null && status.equalsIgnoreCase(pickStatus))
							|| (status == null && pickStatus != null && !pickStatus.equalsIgnoreCase("PACK"))
							|| (status == null && pickStatus == null)) {
						MRList mRList = listResponse.addNewMRList();
						mRList.setDocumentNo(documentNo);
						mRList.setMInoutID(mInoutID);
						mRList.setSupplier(supplier);
						mRList.setOrderDate(date);
						mRList.setWarehouseName(warehouseName);
						mRList.setOrderDocumentno(orderDocumentno);
						if (description == null)
							mRList.setDescription("");
						else
							mRList.setDescription(description);
						count++;
					}
				}
			}
			listResponse.setCount(count);
		} catch (SQLException e) {
			listResponse.setIsError(true);
			listResponse.setError(e.getMessage());
			return mRListResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return mRListResponseDocument;
	}

	@Override
	public MRDataResponseDocument getMrData(PODataRequestDocument pODataRequestDocument) {

		MRDataResponseDocument mRDataResponseDocument = MRDataResponseDocument.Factory.newInstance();
		MRDataResponse listResponse = mRDataResponseDocument.addNewMRDataResponse();
		PODataRequest pODataRequest = pODataRequestDocument.getPODataRequest();
		ADLoginRequest loginReq = pODataRequest.getADLoginRequest();
		String serviceType = pODataRequest.getServiceType();
		String documentNo = pODataRequest.getDocumentNo();

		int clientId = loginReq.getClientID();
		getCompiereService().connect();
		String err = login(loginReq, webServiceName, "mrData", serviceType);
		if (err != null && err.length() > 0) {
			listResponse.setError(err);
			listResponse.setIsError(true);
			return mRDataResponseDocument;
		}

		if (!serviceType.equalsIgnoreCase("mrData")) {
			listResponse.setIsError(true);
			listResponse.setError("Service type " + serviceType + " not configured");
			return mRDataResponseDocument;
		}
		listResponse = getMInoutDataByDocumentNumber(listResponse, documentNo, clientId);
		getCompiereService().disconnect();

		return mRDataResponseDocument;
	}

	private MRDataResponse getMInoutDataByDocumentNumber(MRDataResponse listResponse, String documentNo, int clientId) {
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			String query = "SELECT\n" + "    bp.name AS Supplier,mi.c_order_id,\n" + "    mi.docstatus,\n"
					+ "    bpl.name AS bpLocation,\n" + "    TO_CHAR(mi.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    ml.movementqty,\n" + "    wh.name AS Warehouse_Name,\n" + "    mi.description,\n"
					+ "    ml.m_inoutline_id,\n" + "    ml.m_locator_id,\n" + "    mloctr.value AS locatorName,\n"
					+ "    mi.m_inout_id,\n" + "    co.documentno as orderDocumentno,\n"
					+ "    mp.name, mp.m_product_id,ml.c_uom_id, ml.c_orderline_id\n"
					+ "FROM m_inout mi\n"
					+ "LEFT JOIN m_inoutline ml ON mi.m_inout_id = ml.m_inout_id\n"
					+ "JOIN c_bpartner bp ON mi.c_bpartner_id = bp.c_bpartner_id\n"
					+ "LEFT JOIN c_bpartner_location bpl ON bpl.c_bpartner_id = bp.c_bpartner_id\n"
					+ "JOIN m_warehouse wh ON mi.m_warehouse_id = wh.m_warehouse_id\n"
					+ "LEFT JOIN m_product mp on mp.m_product_id = ml.m_product_id\n"
					+ "LEFT JOIN m_locator mloctr ON mloctr.m_locator_id = ml.m_locator_id\n"
					+ "LEFT JOIN c_order co on mi.c_order_id = co.c_order_id\n"
					+ "WHERE mi.documentNo = '" + documentNo
					+ "' AND mi.ad_client_id = " + clientId + " ORDER BY ml.m_inoutline_id;";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int count = 0;
			String supplier = null;
			String bpLocation = null;
			String description = null;
			String warehouseName = null;
			String docStatus = null;
			String orderDocumentno = null;
			String date = null;
			int lineCount = 0;
			int mInoutId = 0;
			int cOrderId = 0;
			while (rs.next()) {
				supplier = rs.getString("Supplier");
				bpLocation = rs.getString("bpLocation");
				docStatus = rs.getString("docStatus");
				date = rs.getString("Order_Date");
				warehouseName = rs.getString("Warehouse_Name");
				description = rs.getString("description");
				mInoutId = rs.getInt("m_inout_id");
				orderDocumentno = rs.getString("orderDocumentno");
				cOrderId = rs.getInt("c_order_id");

				int mInoutlineId = rs.getInt("m_inoutline_id");
				if (mInoutlineId > 0) {
					MRLine mRLine = listResponse.addNewMRLines();
					int receivedQnty = rs.getInt("movementqty");
					int mProductID = rs.getInt("m_product_id");
					int uomID = rs.getInt("c_uom_id");
					int cOrderlineID = rs.getInt("c_orderline_id");
					String productName = rs.getString("name");
					int locatorId = rs.getInt("m_locator_id");
					String locatorName = rs.getString("locatorName");
					mRLine.setProductName(productName);
					mRLine.setProductID(mProductID);
					mRLine.setMRLineId(mInoutlineId);
					mRLine.setCOrderlineId(cOrderlineID);
					mRLine.setUomID(uomID);
					mRLine.setRecievedQnty(receivedQnty);
					mRLine.setLocatorId(locatorId);
					mRLine.setLocatorName(locatorName);
					count += receivedQnty;
					lineCount++;
				}
			}

			if (mInoutId == 0) {
				listResponse.setIsError(true);
				listResponse.setError("MR with DocumentNo : " + documentNo + " not found");
				return listResponse;
			}

			listResponse.setDocumentNo(documentNo);
			listResponse.setCOrderId(cOrderId);
			listResponse.setMInoutID(mInoutId);
			listResponse.setOrderDocumentno(orderDocumentno);
			listResponse.setDocStatus(docStatus);
			listResponse.setSupplier(supplier);
			listResponse.setSupplierLocationName(bpLocation);
			listResponse.setOrderDate(date);
			listResponse.setWarehouseName(warehouseName);
			if (description == null)
				listResponse.setDescription("");
			else
				listResponse.setDescription(description);
			listResponse.setOverallQnty(count);

			if (lineCount == 0) {
				listResponse.setIsError(true);
				listResponse.setError("MR with : " + documentNo + " have no lines");
				return listResponse;
			}

		} catch (SQLException e) {
			listResponse.setIsError(true);
			listResponse.setError(e.getMessage());
			return listResponse;
		} finally {
			closeDbCon(pstm, rs);
		}
		return listResponse;
	}

	@Override
	public MRFailedResponceDocument createFailedQty(MRFailedRequestDocument mRFailedRequestDocument) {
		MRFailedResponceDocument mRFailedResponceDocument = MRFailedResponceDocument.Factory.newInstance();
		MRFailedResponce mRFailedResponce = mRFailedResponceDocument.addNewMRFailedResponce();
		MRFailedRequest mRFailedRequest = mRFailedRequestDocument.getMRFailedRequest();
		ADLoginRequest loginReq = mRFailedRequest.getADLoginRequest();
		String serviceType = mRFailedRequest.getServiceType();
		int mInOutID = mRFailedRequest.getMInOutID();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "mrFailed", serviceType);
			if (err != null && err.length() > 0) {
				mRFailedResponce.setError(err);
				mRFailedResponce.setIsError(true);
				return mRFailedResponceDocument;
			}

			if (!serviceType.equalsIgnoreCase("mrFailed")) {
				mRFailedResponce.setIsError(true);
				mRFailedResponce.setError("Service type " + serviceType + " not configured");
				return mRFailedResponceDocument;
			}

			Properties ctx = m_cs.getCtx();
			MTable table = MTable.get(ctx, "m_inout");
			PO po = table.getPO(mInOutID, trx.getTrxName());
			if (po == null || po.get_ID() == 0) {
				mRFailedResponce.setError("Material Receipt not found for ID: " + mInOutID);
				mRFailedResponce.setIsError(true);
				return mRFailedResponceDocument;
			}
			MInOut mInOut = (MInOut) po;
			MInOutConfirm mInOutConfirm = new MInOutConfirm(mInOut, "PC");
			mInOutConfirm.setDocStatus(DocAction.STATUS_Drafted);
			mInOutConfirm.saveEx();

			MRFailedLines[] mRFailedLinesArray = mRFailedRequest.getMRFailedLinesArray();
			MInOutLine[] lines = mInOut.getLines(false);
			for (MInOutLine line : lines) {
				MInOutLineConfirm lineConfirm = new MInOutLineConfirm(mInOutConfirm);
				lineConfirm.setM_InOutLine_ID(line.get_ID());
				lineConfirm.setTargetQty(line.getMovementQty());
				lineConfirm.setConfirmedQty(line.getMovementQty());
				lineConfirm.saveEx();

				for (MRFailedLines failedLine : mRFailedLinesArray) {
					int data = failedLine.getMInOutLineId();
					if (data == line.get_ID()) {
						int failedQty = failedLine.getFailedQty();
						int confirmID = lineConfirm.get_ID();
						MInOutLineConfirm_Custom custom = new MInOutLineConfirm_Custom(ctx, confirmID,
								trx.getTrxName());
						BigDecimal failedB = new BigDecimal(failedQty);
						custom.processLine(false, "PC");
						custom.setQCFailedQty(failedB);
						custom.saveEx();
						lineConfirm.saveEx();
					}
				}
			}
			mInOutConfirm.setDescription(MInOutConfirm.COLUMNNAME_Description);
			mInOutConfirm.setProcessed(true);
			mInOutConfirm.setIsApproved(true);
			mInOutConfirm.setDocStatus(MInOutConfirm.DOCSTATUS_Completed);
			mInOutConfirm.setDocAction(MInOutConfirm.DOCACTION_Close);
			mInOutConfirm.saveEx();
			trx.commit();

			mRFailedResponce.setIsError(false);
			mRFailedResponce.setCreateConfirmationDocumentNumber(mInOutConfirm.getDocumentNo());
			mRFailedResponce.setCreateConfirmationId(mInOutConfirm.get_ID());

		} catch (Exception e) {
			mRFailedResponce.setIsError(true);
			mRFailedResponce.setError(e.getMessage());
			return mRFailedResponceDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();

			getCompiereService().disconnect();

		}
		return mRFailedResponceDocument;
	}

	@Override
	public PIListResponseDocument getPhysicalInventoryList(PIListRequestDocument pIListRequestDocument) {
		PIListResponseDocument pIListResponseDocument = PIListResponseDocument.Factory.newInstance();
		PIListResponse pIListResponse = pIListResponseDocument.addNewPIListResponse();
		PIListRequest pIListRequest = pIListRequestDocument.getPIListRequest();
		ADLoginRequest loginReq = pIListRequest.getADLoginRequest();
		String serviceType = pIListRequest.getServiceType();
		String searchKey = pIListRequest.getSearchKey();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			int clientId = loginReq.getClientID();
			getCompiereService().connect();

			String err = login(loginReq, webServiceName, "pIList", serviceType);
			if (err != null && err.length() > 0) {
				pIListResponse.setError(err);
				pIListResponse.setIsError(true);
				return pIListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("pIList")) {
				pIListResponse.setIsError(true);
				pIListResponse.setError("Service type " + serviceType + " not configured");
				return pIListResponseDocument;
			}

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(ctx);
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(loginReq.getRoleID(), ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "select a.m_inventory_id,\n" + "TO_CHAR(a.movementdate, 'DD/MM/YYYY') AS Date,\n"
					+ "b.name as Warehouse_Name,\n" + "c.name as Org_Name,\n" + "a.description,\n" + "a.documentno\n"
					+ "from m_inventory a\n" + "join m_warehouse b on a.m_warehouse_id = b.m_warehouse_id\n"
					+ "join ad_org c on a.ad_org_id = c.ad_org_id\n" + "where a.ad_client_id = " + clientId
					+ " and a.docstatus = 'DR' AND a.ad_org_id IN (" + orgIds + ") AND (\n"
					+ "    a.m_inventory_id::VARCHAR ILIKE '%' || COALESCE(?, a.m_inventory_id::VARCHAR) || '%'\n"
					+ "    OR c.name ILIKE '%' || COALESCE(?, c.name) || '%'\n"
					+ "    OR b.name ILIKE '%' || COALESCE(?, b.name) || '%'\n"
					+ "    OR a.description ILIKE '%' || COALESCE(?, a.description) || '%'\n"
					+ "    OR a.documentno ILIKE '%' || COALESCE(?,a.documentno) || '%'\n" + ")\n"
					+ " ORDER BY a.created desc";

			pstm = DB.prepareStatement(query.toString(), null);
			pstm.setString(1, searchKey);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			pstm.setString(5, searchKey);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {

				PIList pIList = pIListResponse.addNewPIList();
				String m_inventory_id = rs.getString("m_inventory_id");
				String date = rs.getString("Date");
				String orgName = rs.getString("Org_Name");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				String documentno = rs.getString("documentno");
				pIList.setDocumentNo(documentno);
				pIList.setMInventoryId(m_inventory_id);
				pIList.setOrderDate(date);
				pIList.setWarehouseName(warehouseName);
				pIList.setOrgName(orgName);
				if (description == null)
					pIList.setDescription("");
				else
					pIList.setDescription(description);
				count++;
			}
			pIListResponse.setCount(count);
			trx.commit();

		} catch (Exception e) {
			pIListResponse.setIsError(true);
			pIListResponse.setError(e.getMessage());
			return pIListResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return pIListResponseDocument;
	}

	@Override
	public PIDeatilsResponseDocument getPhysicalInventoryDetailsById(
			PIDeatilsRequestDocument pIDeatilsRequestDocument) {
		PIDeatilsResponseDocument pIDeatilsResponseDocument = PIDeatilsResponseDocument.Factory.newInstance();
		PIDeatilsResponse pIDeatilsResponse = pIDeatilsResponseDocument.addNewPIDeatilsResponse();
		PIDeatilsRequest pIDeatilsRequest = pIDeatilsRequestDocument.getPIDeatilsRequest();
		ADLoginRequest loginReq = pIDeatilsRequest.getADLoginRequest();
		String serviceType = pIDeatilsRequest.getServiceType();
		String mInventoryId = pIDeatilsRequest.getMInventoryId();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			int clientId = loginReq.getClientID();
			getCompiereService().connect();

			String err = login(loginReq, webServiceName, "pIDetails", serviceType);
			if (err != null && err.length() > 0) {
				pIDeatilsResponse.setError(err);
				pIDeatilsResponse.setIsError(true);
				return pIDeatilsResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("pIDetails")) {
				pIDeatilsResponse.setIsError(true);
				pIDeatilsResponse.setError("Service type " + serviceType + " not configured");
				return pIDeatilsResponseDocument;
			}
			String query = null;
			query = "SELECT a.documentno,\n" + "       TO_CHAR(a.movementdate, 'DD/MM/YYYY') AS Date,\n"
					+ "       b.name AS Warehouse_Name,\n" + "       c.name AS Org_Name,\n" + "       a.description,\n"
					+ "       a.m_inventory_id\n" + "FROM m_inventory a\n"
					+ "JOIN m_warehouse b ON a.m_warehouse_id = b.m_warehouse_id\n"
					+ "JOIN ad_org c ON a.ad_org_id = c.ad_org_id\n" + "WHERE a.ad_client_id = " + clientId
					+ " AND a.m_inventory_id = " + mInventoryId + ";";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();
			while (rs.next()) {
				String date = rs.getString("Date");
				String orgName = rs.getString("Org_Name");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				String documentNo = rs.getString("documentno");
				pIDeatilsResponse.setDocumentNo(documentNo);
				pIDeatilsResponse.setMInventoryId(mInventoryId);
				pIDeatilsResponse.setOrderDate(date);
				pIDeatilsResponse.setWarehouseName(warehouseName);
				pIDeatilsResponse.setOrgName(orgName);
				if (description == null)
					pIDeatilsResponse.setDescription("");
				else
					pIDeatilsResponse.setDescription(description);
			}
			pstm.close();
			rs.close();

			query = "SELECT mil.m_inventoryline_id,\n" + "       mil.qtycount,mil.qtybook,\n"
					+ "       l.m_locator_id,\n" + "       l.value as locatorName,\n" + "       p.m_product_id,\n"
					+ "       p.name as productName\n" + "FROM adempiere.m_inventoryline mil\n"
					+ "JOIN adempiere.m_locator l ON l.m_locator_id = mil.m_locator_id\n"
					+ "JOIN adempiere.m_product p ON p.m_product_id = mil.m_product_id\n"
					+ "WHERE mil.m_inventory_id = " + mInventoryId + " ORDER BY mil.m_inventoryline_id;";
			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();
			while (rs.next()) {
				PIDetailsLine pIDetailsLine = pIDeatilsResponse.addNewPIDetailsLines();

				String productName = rs.getString("productName");
				String locatorName = rs.getString("locatorName");
				int m_inventoryline_id = rs.getInt("m_inventoryline_id");
				int qtycount = rs.getInt("qtycount");
				int qtybook = rs.getInt("qtybook");
				int m_locator_id = rs.getInt("m_locator_id");
				int m_product_id = rs.getInt("m_product_id");
				pIDetailsLine.setLocatorId(m_locator_id);
				pIDetailsLine.setLocatorName(locatorName);
				pIDetailsLine.setQntyBook(qtybook);
				pIDetailsLine.setQtyCount(qtycount);
				pIDetailsLine.setPiLineId(m_inventoryline_id);
				pIDetailsLine.setProductId(m_product_id);
				pIDetailsLine.setProductName(productName);

			}

		} catch (Exception e) {
			pIDeatilsResponse.setIsError(true);
			pIDeatilsResponse.setError(e.getMessage());
			return pIDeatilsResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return pIDeatilsResponseDocument;
	}

	@Override
	public PIQtyChangeResponseDocument pIQtyChange(PIQtyChangeRequestDocument pICountQtyRequestDocument) {
		PIQtyChangeResponseDocument pICountQtyResponseDocument = PIQtyChangeResponseDocument.Factory.newInstance();
		PIQtyChangeResponse pICountQtyResponse = pICountQtyResponseDocument.addNewPIQtyChangeResponse();
		PIQtyChangeRequest pICountQtyRequest = pICountQtyRequestDocument.getPIQtyChangeRequest();
		ADLoginRequest loginReq = pICountQtyRequest.getADLoginRequest();
		String serviceType = pICountQtyRequest.getServiceType();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "pIQtyChange", serviceType);
			if (err != null && err.length() > 0) {
				pICountQtyResponse.setError(err);
				pICountQtyResponse.setIsError(true);
				return pICountQtyResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("pIQtyChange")) {
				pICountQtyResponse.setIsError(true);
				pICountQtyResponse.setError("Service type " + serviceType + " not configured");
				return pICountQtyResponseDocument;
			}
			Properties ctx = m_cs.getCtx();
			PILines[] ILinesArray = pICountQtyRequest.getPILinesArray();
			for (PILines lines : ILinesArray) {
				int pILineID = lines.getMInventoryLineId();
				int countQty = lines.getCountQty();
				BigDecimal countQtyB = new BigDecimal(countQty);
				MInventoryLine line = new MInventoryLine(ctx, pILineID, trx.getTrxName());
				line.setQtyCount(countQtyB);
				line.saveEx();
			}
			trx.commit();
			pICountQtyResponse.setIsError(false);

		} catch (Exception e) {
			pICountQtyResponse.setIsError(true);
			pICountQtyResponse.setError(e.getMessage());
			return pICountQtyResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return pICountQtyResponseDocument;
	}

	@Override
	public SOListResponseDocument soList(SOListRequestDocument sOListRequestDocument) {
		SOListResponseDocument sOListResponseDocument = SOListResponseDocument.Factory.newInstance();
		SOListResponse sOListResponse = sOListResponseDocument.addNewSOListResponse();
		SOListRequest sOListRequest = sOListRequestDocument.getSOListRequest();
		ADLoginRequest loginReq = sOListRequest.getADLoginRequest();
		String serviceType = sOListRequest.getServiceType();
		String searchkey = sOListRequest.getSearchKey();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		Trx trx = null;
		try {
			int clientId = loginReq.getClientID();
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "sOList", serviceType);
			if (err != null && err.length() > 0) {
				sOListResponse.setError(err);
				sOListResponse.setIsError(true);
				return sOListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("sOList")) {
				sOListResponse.setIsError(true);
				sOListResponse.setError("Service type " + serviceType + " not configured");
				return sOListResponseDocument;
			}

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(ctx);
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(loginReq.getRoleID(), ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}

//			String locatorName = "Dispatch Locator";
//			Boolean pakingModule = sOListRequest.getPackingModule();
//			if(pakingModule)
//				locatorName = "Packing Locator";
//				

			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			rs = soListQuery(searchkey, clientId, pstm, rs, "desc", orgIds);

			int count = 0;
			while (rs.next()) {
				String documentNo = rs.getString("Sales_Order");
				String cOrderId = rs.getString("cOrderId");
				String customer = rs.getString("Customer");
				String date = rs.getString("Order_Date");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				boolean Status = rs.getBoolean("status");
				String putStatus = rs.getString("putStatus");
				int mWarehouseId = rs.getInt("m_warehouse_id");

				SOListAccess sOListAccess = sOListResponse.addNewListAccess();
				sOListAccess.setDocumentNumber(documentNo);
				sOListAccess.setCOrderId(cOrderId);
				sOListAccess.setOrderDate(date);
				sOListAccess.setCustomerName(customer);
				sOListAccess.setWarehouseName(warehouseName);
				sOListAccess.setWarehouseId(mWarehouseId);

				if (putStatus == null)
					putStatus = "";
				if (description == null)
					description = "";
				sOListAccess.setDescription(description);
				sOListAccess.setStatus(putStatus);
				sOListAccess.setSalesOrderStatus(Status);

				count++;
			}

			LinkedHashMap<Integer, LinkedHashMap<Integer, Integer>> pickedQuantity = new LinkedHashMap<Integer, LinkedHashMap<Integer, Integer>>();

			SOListAccess[] sOListAccessArray = sOListResponse.getListAccessArray();

			for (int i = sOListAccessArray.length - 1; i >= 0; i--) {
				SOListAccess listAcess = sOListAccessArray[i];
				// for(SOListAccess listAcess :sOListResponse.getListAccessList()) {
				if (listAcess.getStatus().equalsIgnoreCase("pick")) {

					if (!pickedQuantity.containsKey(listAcess.getWarehouseId())) {
						List<PO> poList = new Query(ctx, MLocator.Table_Name,
								"m_warehouse_id =? AND value = 'Dispatch Locator'", trxName)
								.setParameters(listAcess.getWarehouseId()).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID)
								.list();
						MLocator mLocator = (MLocator) poList.get(0);
						pickedQuantity.put(listAcess.getWarehouseId(),
								PiProductLabel.getAvailableLabelsByLocator(clientId, mLocator.getM_Locator_ID()));
					}

					JSONObject jsonObject = getRemainQuantityForOrder(ctx, trxName, listAcess.getCOrderId(),
							listAcess.getDocumentNumber(), clientId, pickedQuantity, listAcess.getWarehouseId());

					listAcess.setQuantityPicked(jsonObject.getInt("pickedQnty"));
					listAcess.setQuantityTotal(jsonObject.getInt("totalQnty"));
				}
			}
			sOListResponse.setCount(count);
			trx.commit();
		} catch (Exception e) {
			sOListResponse.setIsError(true);
			sOListResponse.setError(e.getMessage());
			return sOListResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return sOListResponseDocument;
	}

	private ResultSet soListQuery(String searchkey, int clientId, PreparedStatement pstm, ResultSet rs, String orderBy,
			String orgIds) {
		try {
			String query = "SELECT DISTINCT\n" + "    so.documentno as Sales_Order,\n"
					+ "    so.c_order_id AS cOrderId, so.putStatus,\n"
					+ "TO_CHAR(so.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name, wh.m_warehouse_id,\n" + "bp.name AS Customer, so.created,\n"
					+ " so.description,\n" + "    CASE\n"
					+ "        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "        WHEN so.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n"
					+ "    END AS status\n" + "FROM\n" + "    adempiere.c_order so\n" + "JOIN\n"
					+ "    adempiere.c_orderline sol ON so.c_order_id = sol.c_order_id\n" + "JOIN\n"
					+ "    adempiere.c_bpartner bp ON so.c_bpartner_id = bp.c_bpartner_id \n" + "JOIN\n"
					+ "    adempiere.m_warehouse wh ON so.m_warehouse_id = wh.m_warehouse_id\n" + "LEFT JOIN\n"
					+ "    adempiere.m_inout mr ON so.c_order_id = mr.c_order_id\n" + "WHERE\n"
					+ "    sol.qtyordered > (\n" + "        SELECT COALESCE(SUM(iol.qtyentered), 0)\n"
					+ "        FROM adempiere.m_inoutline iol\n"
					+ "        WHERE iol.c_orderline_id = sol.c_orderline_id\n" + "    )\n" + "AND\n"
					+ "    so.ad_client_id = '" + clientId + "'\n" + "AND\n" + "    so.issotrx = 'Y'\n" + "AND\n"
					+ "    so.docstatus = 'CO' " + "AND (\n"
					+ "    so.documentno ILIKE '%' || COALESCE(?, so.documentno) || '%'\n"
					+ "    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'\n"
					+ "    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'\n"
					+ "    OR so.description ILIKE '%' || COALESCE(?, so.description) || '%'\n"
					+ ") AND so.ad_org_id IN (" + orgIds + ") \n" + " ORDER BY so.created " + orderBy + ";;\n" + ";";

			pstm = DB.prepareStatement(query.toString(), null);

			pstm.setString(1, searchkey);

			pstm.setString(2, searchkey);
			pstm.setString(3, searchkey);
			pstm.setString(4, searchkey);
			rs = pstm.executeQuery();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return rs;
	}

	@Override
	public SODetailResponseDocument soDetails(SODetailRequestDocument sODetailRequestDocument) {
		SODetailResponseDocument sODetailResponseDocument = SODetailResponseDocument.Factory.newInstance();
		SODetailResponse sODetailResponse = sODetailResponseDocument.addNewSODetailResponse();
		SODetailRequest sODetailRequest = sODetailRequestDocument.getSODetailRequest();
		ADLoginRequest loginReq = sODetailRequest.getADLoginRequest();
		String serviceType = sODetailRequest.getServiceType();
		String documentNo = sODetailRequest.getDocumentNo();
		int client_ID = loginReq.getClientID();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "sODetail", serviceType);
			if (err != null && err.length() > 0) {
				sODetailResponse.setError(err);
				sODetailResponse.setIsError(true);
				return sODetailResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("sODetail")) {
				sODetailResponse.setIsError(true);
				sODetailResponse.setError("Service type " + serviceType + " not configured");
				return sODetailResponseDocument;
			}
//			
//			String locatorName = "Dispatch Locator";
//			Boolean pakingModule = sODetailRequest.getPackingModule();
//			if(pakingModule)
//				locatorName = "Packing Locator";

			String query = null;
			query = "SELECT a.qtyordered as totalQnty, (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name\n"
					+ "FROM c_orderline a \n" + "JOIN c_order d ON d.c_order_id = a.c_order_id \n"
					+ "LEFT JOIN m_inout b ON a.c_order_id = b.c_order_id \n"
					+ "LEFT JOIN m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.c_orderline_id = a.c_orderline_id\n"
					+ "JOIN m_product e ON e.m_product_id = a.m_product_id \n" + "WHERE d.documentno = '" + documentNo
					+ "' AND d.ad_client_id = '" + client_ID + "' AND a.c_order_id = (\n"
					+ "  SELECT c_order_id FROM c_order WHERE documentno = '" + documentNo + "' AND ad_client_id = '"
					+ client_ID + "'\n" + ")\n"
					+ "GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id ORDER BY a.c_orderline_id;\n"
					+ "";

			pstm = DB.prepareStatement(query.toString(), trxName);
			rs = pstm.executeQuery();

			int quantityPicked = 0;
			int quantityTotal = 0;
			int cOrderId = 0;
			MOrder mOrder = null;
			MWarehouse mWarehouse = null;
//			MLocator mLocatorArray[] = null;
			LinkedHashMap<Integer, Integer> locatorStorage = null;
			while (rs.next()) {
				ProductData productData = sODetailResponse.addNewProductData();
				int outstandingQty = rs.getInt("outstanding_qty");
				int totalQnty = rs.getInt("totalQnty");
				String productName = rs.getString("product_name");
				int productId = rs.getInt("productId");
				cOrderId = rs.getInt("c_order_id");
				int cOrderlineId = rs.getInt("c_orderline_id");
				int uomId = rs.getInt("c_uom_id");

				if (mOrder == null) {
					mOrder = new MOrder(ctx, cOrderId, trxName);
					mWarehouse = new MWarehouse(ctx, mOrder.getM_Warehouse_ID(), trxName);
//					mLocatorArray = mWarehouse.getLocators(true);
					locatorStorage = getQntyPickedBySoList(client_ID, mWarehouse.getM_Warehouse_ID(), ctx, trxName,
							documentNo, loginReq.getRoleID(), "Dispatch Locator");
				}

				MInOut[] mInout = mOrder.getShipments();
				for (MInOut inout : mInout) {
					for (MInOutLine line : inout.getLines()) {
						if (line.getM_Product_ID() == productId) {
							if (!inout.getDocStatus().equalsIgnoreCase("CO"))
								for (Integer key : locatorStorage.keySet()) {
									if (productId == key) {
										int qnty = locatorStorage.get(key);
										locatorStorage.put(key, qnty - line.getQtyEntered().intValue());
										break;
									}

								}
							totalQnty = totalQnty - line.getQtyEntered().intValue();
						}
					}
				}

				int qntyTotal = 0;
				int qntyOutstanding = 0;
				if (locatorStorage.containsKey(productId)) {

					int qntyAvailable = locatorStorage.get(productId);
					if (qntyAvailable == 0)
						qntyOutstanding = 0;
					else if (qntyAvailable >= outstandingQty) {
						qntyOutstanding = outstandingQty;
						locatorStorage.put(productId, qntyAvailable - outstandingQty);
						quantityPicked += outstandingQty;

					} else {
						qntyOutstanding = qntyAvailable;
						locatorStorage.put(productId, 0);
						quantityPicked += qntyAvailable;
					}

					qntyTotal = totalQnty;
					quantityTotal += totalQnty;
				} else {
					qntyTotal = totalQnty;
					qntyOutstanding = 0;
				}
				List<PO> poList = new Query(ctx, MLocator.Table_Name,
						"m_warehouse_id =? AND value = 'Dispatch Locator'", trxName)
						.setParameters(mOrder.getM_Warehouse_ID()).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID).list();
				MLocator mLocator = (MLocator) poList.get(0);

				productData.setProductId(productId);
				productData.setProductName(productName);
				productData.setCOrderlineId(cOrderlineId);
				productData.setUomId(uomId);
				productData.setSuggestedLocator(mLocator.getM_Locator_ID());
				productData.setLocatorName(mLocator.getValue());
				productData.setOutstandingQnty(qntyOutstanding);
				productData.setTotalQuantity(qntyTotal);
			}
			sODetailResponse.setCOrderId(cOrderId);
			sODetailResponse.setQuantityPicked(quantityPicked);
			sODetailResponse.setQuantityTotal(quantityTotal);
			closeDbCon(pstm, rs);

			query = "SELECT\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n" + "    po.docstatus,\n"
					+ "    bp.name AS customer,\n" + "    wh.name AS Warehouse_Name,\n" + "    po.description,\n"
					+ "    ml.m_locator_id,bpl.name as Location_Name,\n" + "	CASE\n"
					+ "   	 WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "   	 WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n" + "  	END AS status\n"
					+ "FROM c_order po\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id JOIN adempiere.c_bpartner_location bpl ON bpl.C_BPartner_ID = bp.C_BPartner_ID\n"
					+ "LEFT JOIN m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN m_locator ml ON ml.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE\n"
					+ "    po.documentno = '" + documentNo + "'\n" + "    AND isDefault = 'Y' AND po.ad_client_id ='"
					+ client_ID + "';";
			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String orderDate = rs.getString("Order_Date");
				String customer = rs.getString("customer");
				String docStatus = rs.getString("docstatus");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				boolean orderStatus = rs.getBoolean("status");
				// int mLocatorId = rs.getInt("m_locator_id");
				String location_Name = rs.getString("Location_Name");
				sODetailResponse.setOrderDate(orderDate);
				sODetailResponse.setDocStatus(docStatus);
				sODetailResponse.setCustomer(customer);
				sODetailResponse.setWarehouseName(warehouseName);
				if (description == null)
					sODetailResponse.setDescription("");
				else
					sODetailResponse.setDescription(description);
				sODetailResponse.setOrderStatus(orderStatus);
				sODetailResponse.setLocationName(location_Name);
			}
			sODetailResponse.setDocumentNo(documentNo);
			trx.commit();
		} catch (Exception e) {
			sODetailResponse.setError(e.getMessage());
			sODetailResponse.setIsError(true);
			return sODetailResponseDocument;

		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return sODetailResponseDocument;
	}

	@Override
	public CreateSCResponseDocument createShipment(CreateSCRequestDocument createSCRequestDocument) {
		CreateSCResponseDocument createSCResponseDocument = CreateSCResponseDocument.Factory.newInstance();
		CreateSCResponse createSCResponse = createSCResponseDocument.addNewCreateSCResponse();
		CreateSCRequest createSCRequest = createSCRequestDocument.getCreateSCRequest();
		ADLoginRequest loginReq = createSCRequest.getADLoginRequest();
		String serviceType = createSCRequest.getServiceType();
		int cOrderId = createSCRequest.getCOrderId();
		MInvoice m_invoice = null;
		MRMA s_rma = null;
		Trx trx = null;
		int clientID = loginReq.getClientID();
		CompiereService m_cs = getCompiereService();
		Properties ctx = m_cs.getCtx();
		int mInoutId = 0;
		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "createSC", serviceType);
			if (err != null && err.length() > 0) {
				createSCResponse.setError(err);
				createSCResponse.setIsError(true);
				return createSCResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("createSC")) {
				createSCResponse.setIsError(true);
				createSCResponse.setError("Service type " + serviceType + " not configured");
				return createSCResponseDocument;
			}

			MTable table = MTable.get(ctx, "c_order");
			PO po = table.getPO(cOrderId, trx.getTrxName());
			if (po == null || po.get_ID() == 0) {
				createSCResponse.setError("order not found for " + cOrderId + "");
				createSCResponse.setIsError(true);
				return createSCResponseDocument;
			}
			MOrder order = (MOrder) po;
			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable.getPO("name = 'MM Shipment' and ad_client_id = " + clientID + "",
					trx.getTrxName());
			MDocType mDocType = (MDocType) docTypePO;

			MInOut dispatch = new MInOut(order, mDocType.get_ID(), order.getDateOrdered());
			dispatch.setDocStatus(DocAction.STATUS_Drafted);
			dispatch.saveEx();

			mInoutId = dispatch.getM_InOut_ID();
			MInOut inout = new MInOut(ctx, mInoutId, trx.getTrxName());

//			List<PO> poList = new Query(ctx, MLocator.Table_Name, "m_warehouse_id =? AND value = 'Dispatch Locator'",
//					trxName).setParameters(order.getM_Warehouse_ID()).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID)
//					.list();
//			MLocator newMLocator = (MLocator) poList.get(0);

//			MMovement mMovement = new MMovement(ctx, 0, trxName);
//			mMovement.setIsActive(true);
//			mMovement.setDescription(null);
//			mMovement.setApprovalAmt(BigDecimal.valueOf(0));
//			mMovement.setChargeAmt(BigDecimal.valueOf(0));
//			mMovement.setFreightAmt(BigDecimal.valueOf(0));
//			mMovement.setM_Warehouse_ID(newMLocator.getM_Warehouse_ID());
//			mMovement.setM_WarehouseTo_ID(newMLocator.getM_Warehouse_ID());
//			mMovement.setAD_Org_ID(loginReq.getOrgID());
//			mMovement.saveEx();

			ShipmentLines[] shipmentLinesArray = createSCRequest.getShipmentLinesArray();
			for (ShipmentLines lines : shipmentLinesArray) {
				int C_InvoiceLine_ID = 0;
				int M_RMALine_ID = 0;
				int M_Product_ID = lines.getProductId();
				int C_UOM_ID = lines.getUomId();
				int C_OrderLine_ID = lines.getCOrderlineId();
				BigDecimal QtyEntered = BigDecimal.valueOf(lines.getQnty());
//				int M_Locator_ID = newMLocator.get_ID();
				int M_Locator_ID = lines.getLocator();
//				moveInventory(ctx, trxName, mMovement, loginReq, C_OrderLine_ID, QtyEntered, M_Product_ID,
//						lines.getLocator(), newMLocator.get_ID());

				inout.createLineFrom(C_OrderLine_ID, C_InvoiceLine_ID, M_RMALine_ID, M_Product_ID, C_UOM_ID, QtyEntered,
						M_Locator_ID);
				MInOutLine[] mInoutLines = inout.getLines();
				int lineId = mInoutLines[mInoutLines.length - 1].get_ID();
				lines.setMRLineId(lineId);

//				SReceiptLine[] SReceiptLineArray = lines.getSReceiptLineArray();
//				if (SReceiptLineArray.length != 0)
//					for (SReceiptLine sReceiptLine : SReceiptLineArray) {
//						List<PO> labelList = PiProductLabel.getPiProductLabel("labelUUId",
//								sReceiptLine.getProductLabelUUId(), ctx, trxName, false);
//						if (!labelList.isEmpty()) {
//							PiProductLabel label = new PiProductLabel(ctx, labelList.get(0).get_ID(), trxName);
//							PiProductLabel piProductLabel = new PiProductLabel(ctx, 0, trxName);
//						piProductLabel.setAD_Client_ID(loginReq.getClientID());
//							piProductLabel.setAD_Org_ID(loginReq.getOrgID());
//							piProductLabel.setqcpassed("Y");
//							piProductLabel.setquantity(label.getquantity());
//							piProductLabel.setM_Product_ID(label.getM_Product_ID());
//							piProductLabel.setM_Locator_ID(label.getM_Locator_ID());
//							piProductLabel.setC_OrderLine_ID(C_OrderLine_ID);
//							piProductLabel.setM_InOutLine_ID(lineId);
//							piProductLabel.setIsSOTrx(true);
//							piProductLabel.setlabeluuid(label.getlabeluuid());
//							piProductLabel.saveEx();
//						}
//					}
			}
//			mMovement.setDocStatus(DocAction.ACTION_Complete);
//			mMovement.setDocAction(DocAction.ACTION_Close);
//			mMovement.setPosted(true);
//			mMovement.setProcessed(true);
//			mMovement.setIsApproved(true);
//			mMovement.completeIt();
//			mMovement.saveEx();
			inout.updateFrom(order, m_invoice, s_rma);

			trx.commit();
			createSCResponse.setIsError(false);
			createSCResponse.setShipmentDocumentNumber(inout.getDocumentNo());
			createSCResponse.setShipmentId(mInoutId);
			createSCResponse.setShipmentLinesArray(shipmentLinesArray);

			Map<String, String> data = new HashMap<>();
			data.put("recordId", String.valueOf(inout.getM_InOut_ID()));
			data.put("documentNo", String.valueOf(inout.getDocumentNo()));
			data.put("path1", "/dispatch_screen");
			data.put("path2", "/dispatch_detail_screen");

			PipraUtils.sendNotificationAsyncnew("Supervisor", inout.get_Table_ID(), inout.getM_InOut_ID(), ctx, trxName,
					"Products ready for dispatch - " + inout.getDocumentNo() + "",
					"New products marked ready for dispatch with Shipment No: " + inout.getDocumentNo()
							+ " for Order - " + inout.getC_Order().getDocumentNo() + "",
					inout.get_TableName(), data, loginReq.getClientID(), "CustomerShipmentCreted");

		} catch (Exception e) {
			MTable table = MTable.get(ctx, "m_inout");
			PO po = table.getPO(mInoutId, trx.getTrxName());
			po.delete(true);
			createSCResponse.setError(e.getMessage());
			createSCResponse.setIsError(true);
			return createSCResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return createSCResponseDocument;
	}

	private void moveInventory(Properties ctx, String trxName, MMovement mMovement, ADLoginRequest loginReq,
			int cCOrderLineID, BigDecimal quantity, int productId, int fromLocatorId, int toLocatorId) {
		MMovementLine mMovementLine = new MMovementLine(ctx, 0, trxName);
		mMovementLine.setM_Locator_ID(fromLocatorId);
		mMovementLine.setM_LocatorTo_ID(toLocatorId);
		mMovementLine.setM_Movement_ID(mMovement.get_ID());
		mMovementLine.setM_Product_ID(productId);
		mMovementLine.setLine(10);
		mMovementLine.setMovementQty(quantity);
		mMovementLine.setDescription(null);
		mMovementLine.setProcessed(true);
		mMovementLine.saveEx();

		MMovementLineMA mMovementLineMA = new MMovementLineMA(ctx, 0, trxName);
		mMovementLineMA.setM_AttributeSetInstance_ID(0);
		mMovementLineMA.setIsActive(true);
		mMovementLineMA.setMovementQty(mMovementLine.getMovementQty());
		mMovementLineMA.setIsAutoGenerated(true);
		mMovementLineMA.setM_MovementLine_ID(mMovementLine.get_ID());
		mMovementLineMA.setDateMaterialPolicy(new Timestamp(new Date().getTime()));
		mMovementLineMA.saveEx();

		MTransaction mTransactionOut = new MTransaction(ctx, 0, trxName);
		mTransactionOut.setIsActive(true);
		mTransactionOut.setMovementType("M-");
		mTransactionOut.setM_Locator_ID(mMovementLine.getM_Locator_ID());
		mTransactionOut.setM_Product_ID(mMovementLine.getM_Product_ID());
		mTransactionOut.setMovementQty(mMovementLine.getMovementQty().negate());
		mTransactionOut.setM_MovementLine_ID(mMovementLine.get_ID());
		mTransactionOut.setM_AttributeSetInstance_ID(mMovementLine.getM_AttributeSetInstance_ID());
		mTransactionOut.saveEx();

		MTransaction mTransactionIn = new MTransaction(ctx, 0, trxName);
		mTransactionIn.setIsActive(true);
		mTransactionIn.setMovementType("M+");
		mTransactionIn.setM_Locator_ID(mMovementLine.getM_LocatorTo_ID());
		mTransactionIn.setM_Product_ID(mMovementLine.getM_Product_ID());
		mTransactionIn.setMovementQty(mMovementLine.getMovementQty());
		mTransactionIn.setM_MovementLine_ID(mMovementLine.get_ID());
		mTransactionIn.setM_AttributeSetInstance_ID(mMovementLine.getM_AttributeSetInstance_ID());
		mTransactionIn.saveEx();

		MAcctSchema[] MAcctSchemaArray = MAcctSchema.getClientAcctSchema(ctx, loginReq.getClientID());
		MAcctSchema AcctSchema = MAcctSchemaArray[0];

		List<PO> list = new Query(ctx, MElementValue.Table_Name, "name=? AND ad_client_id=?", trxName)
				.setParameters("Product asset", loginReq.getClientID())
				.setOrderBy(MElementValue.COLUMNNAME_C_ElementValue_ID).list();
		MElementValue mElementValue = (MElementValue) list.get(0);
		int mElementValueId = mElementValue.get_ID();

		MPeriod mPeriod = MPeriod.get(ctx, mMovement.getMovementDate(), loginReq.getOrgID(), trxName);

		MGLCategory mGLCategory = MGLCategory.getDefault(ctx, "M");
		MOrderLine mOrderLine = new MOrderLine(ctx, cCOrderLineID, trxName);

		MFactAcct mFactAcct = new MFactAcct(ctx, 0, trxName);
		mFactAcct.setIsActive(true);
		mFactAcct.setC_AcctSchema_ID(AcctSchema.get_ID());
		mFactAcct.setAccount_ID(mElementValueId);
		mFactAcct.setDateTrx(mMovement.getMovementDate());
		mFactAcct.setDateAcct(mMovement.getMovementDate());
		mFactAcct.setC_Period_ID(mPeriod.get_ID());
		mFactAcct.setAD_Table_ID(mMovement.get_Table_ID());
		mFactAcct.setRecord_ID(mMovement.get_ID());
		mFactAcct.setLine_ID(mMovementLine.get_ID());
		mFactAcct.setGL_Category_ID(mGLCategory.get_ID());
		mFactAcct.setM_Locator_ID(fromLocatorId);
		mFactAcct.setPostingType("A");
		mFactAcct.setC_Currency_ID(AcctSchema.getC_Currency_ID());
		mFactAcct.setAmtSourceDr(mOrderLine.getPriceActual().multiply(quantity));
		mFactAcct.setAmtSourceCr(BigDecimal.valueOf(0));
		mFactAcct.setAmtAcctCr(BigDecimal.valueOf(0));
		mFactAcct.setAmtAcctDr(mOrderLine.getPriceActual().multiply(quantity));
		mFactAcct.setC_UOM_ID(mOrderLine.getC_UOM_ID());
		mFactAcct.setQty(quantity);
		mFactAcct.setM_Product_ID(productId);
		mFactAcct.setDescription(mMovement.getDocumentNo() + "#" + mMovementLine.getLine());
		mFactAcct.saveEx();

		MFactAcct mFactAcctIn = new MFactAcct(ctx, 0, trxName);
		mFactAcctIn.setIsActive(true);
		mFactAcctIn.setC_AcctSchema_ID(AcctSchema.get_ID());
		mFactAcctIn.setAccount_ID(mElementValueId);
		mFactAcctIn.setDateTrx(mMovement.getMovementDate());
		mFactAcctIn.setDateAcct(mMovement.getMovementDate());
		mFactAcctIn.setC_Period_ID(mPeriod.get_ID());
		mFactAcctIn.setAD_Table_ID(mMovement.get_Table_ID());
		mFactAcctIn.setRecord_ID(mMovement.get_ID());
		mFactAcctIn.setLine_ID(mMovementLine.get_ID());
		mFactAcctIn.setGL_Category_ID(mGLCategory.get_ID());
		mFactAcctIn.setM_Locator_ID(toLocatorId);
		mFactAcctIn.setPostingType("A");
		mFactAcctIn.setC_Currency_ID(AcctSchema.getC_Currency_ID());
		mFactAcctIn.setAmtSourceCr(mOrderLine.getPriceActual().multiply(quantity));
		mFactAcctIn.setAmtSourceDr(BigDecimal.valueOf(0));
		mFactAcctIn.setAmtAcctDr(BigDecimal.valueOf(0));
		mFactAcctIn.setAmtAcctCr(mOrderLine.getPriceActual().multiply(quantity));
		mFactAcctIn.setC_UOM_ID(mOrderLine.getC_UOM_ID());
		mFactAcctIn.setQty(quantity);
		mFactAcctIn.setM_Product_ID(productId);
		mFactAcctIn.setDescription(mMovement.getDocumentNo() + "#" + mMovementLine.getLine());
		mFactAcctIn.saveEx();
	}

	@Override
	public GeneratePalletDetailsResponseDocument generatePalletDetails(
			GeneratePalletDetailsRequestDocument generatePalletDetailsRequestDocument) {
		GeneratePalletDetailsRequest generatePalletDetailsRequest = generatePalletDetailsRequestDocument
				.getGeneratePalletDetailsRequest();
		GeneratePalletDetailsResponseDocument generatePalletDetailsResponseDocument = GeneratePalletDetailsResponseDocument.Factory
				.newInstance();
		GeneratePalletDetailsResponse generatePalletDetailsResponse = generatePalletDetailsResponseDocument
				.addNewGeneratePalletDetailsResponse();

		ADLoginRequest loginReq = generatePalletDetailsRequest.getADLoginRequest();
		String serviceType = generatePalletDetailsRequest.getServiceType();
		Trx trx = null;
		int locatorId = 0;
		String palletUUId = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "generatePalletDetails", serviceType);
			if (err != null && err.length() > 0) {
				generatePalletDetailsResponse.setError(err);
				generatePalletDetailsResponse.setIsError(true);
				return generatePalletDetailsResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("generatePalletDetails")) {
				generatePalletDetailsResponse.setIsError(true);
				generatePalletDetailsResponse.setError("Service type " + serviceType + " not configured");
				return generatePalletDetailsResponseDocument;
			}
			PalletLines[] palletLines = generatePalletDetailsRequest.getPalletLinesArray();
			for (PalletLines line : palletLines) {
				PiQrRelations piQrRelations = new PiQrRelations(ctx, trxName, loginReq, line);
				piQrRelations.saveEx();
				if (locatorId == 0)
					locatorId = piQrRelations.getlocatorid();
				if (palletUUId == null)
					palletUUId = piQrRelations.getpalletuuid();
			}
			trx.commit();
			generatePalletDetailsResponse.setIsError(false);

		} catch (Exception e) {
			generatePalletDetailsResponse.setError(e.getMessage());
			generatePalletDetailsResponse.setIsError(true);
			return generatePalletDetailsResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return generatePalletDetailsResponseDocument;
	}

	@Override
	public GetQRDataResponseDocument getQRData(GetQRDataRequestDocument getQRDataRequestDocument) {
		GetQRDataRequest getQRDataRequest = getQRDataRequestDocument.getGetQRDataRequest();
		GetQRDataResponseDocument getQRDataResponseDocument = GetQRDataResponseDocument.Factory.newInstance();
		GetQRDataResponse getQRDataResponse = getQRDataResponseDocument.addNewGetQRDataResponse();
		String qrId = getQRDataRequest.getQrId();
		String qrType = getQRDataRequest.getQrType();
		ADLoginRequest loginReq = getQRDataRequest.getADLoginRequest();
		String serviceType = getQRDataRequest.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "getQRData", serviceType);
			if (err != null && err.length() > 0) {
				getQRDataResponse.setError(err);
				getQRDataResponse.setIsError(true);
				return getQRDataResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("getQRData")) {
				getQRDataResponse.setIsError(true);
				getQRDataResponse.setError("Service type " + serviceType + " not configured");
				return getQRDataResponseDocument;
			}

			String columnName = null;
			if (qrType.equalsIgnoreCase("pallet")) {
				columnName = "palletUUId";
			} else if (qrType.equalsIgnoreCase("locator")) {
				columnName = "loctorId";
			}

			List<PO> piQrRelations = PiQrRelations.getPiQrRelationsData(columnName, qrId, ctx, trxName);
			if (piQrRelations.isEmpty()) {
				getQRDataResponse.setIsError(true);
				getQRDataResponse.setError("Invalid QiId " + qrId + "");
				return getQRDataResponseDocument;
			}
			getQRDataResponse.setQrType(qrType);
			getQRDataResponse.setQrId(qrId);
			Map<String, Integer> palletIds = new HashMap<>();
			int count = 0;
			int palletCount = 0;
			int productsCount = 0;

			for (PO po : piQrRelations) {
				PiQrRelations pr = new PiQrRelations(ctx, po.get_ID(), trxName);
				PalletQr palletQr = null;
				if (!palletIds.containsKey(pr.getpalletuuid())) {
					palletQr = getQRDataResponse.addNewPalletQr();
					palletIds.put(pr.getpalletuuid(), count);
					palletCount++;
					count++;
				} else {
					palletQr = getQRDataResponse.getPalletQrArray(palletIds.get(pr.getpalletuuid()));
				}
				palletQr.setPalletUUId(pr.getpalletuuid());
				if (pr.getisinlocator() == 1) {
					MLocator mLocator = new MLocator(ctx, pr.getlocatorid(), trxName);
					palletQr.setLocatorName(mLocator.getValue());
					palletQr.setAisle(mLocator.getX());
					palletQr.setBin(mLocator.getY());
					palletQr.setLevel(mLocator.getZ());
					palletQr.setLocatorId(pr.getlocatorid());
				} else {
					palletQr.setLocatorId(0);
				}
				PalletLines palletQrLines = palletQr.addNewPalletLines();
				MProduct mProduct = new MProduct(ctx, pr.getproductid(), trxName);
				palletQrLines.setProductName(mProduct.getName());
				palletQrLines.setProductId(pr.getproductid());
				if (pr.getisshippedout() == 1)
					palletQrLines.setIsShippedOut(true);
				else
					palletQrLines.setIsShippedOut(false);
				palletQrLines.setStatus(pr.getpstatus());
				palletQrLines.setQnty(pr.getquantity().intValue());
				productsCount++;
			}
			getQRDataResponse.setProductCount(productsCount);
			getQRDataResponse.setPalletCount(palletCount);
			trx.commit();

		} catch (Exception e) {
			e.printStackTrace();
			getQRDataResponse.setError(e.getMessage());
			getQRDataResponse.setIsError(true);
			return getQRDataResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return getQRDataResponseDocument;
	}

	@Override
	public StandardResponseDocument linkOrUnlinkPallet(LinkOrUnlinkPalletRequestDocument req) {
		LinkOrUnlinkPalletRequest linkOrUnlinkPalletRequest = req.getLinkOrUnlinkPalletRequest();
		StandardResponseDocument standardResponseDocument = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = standardResponseDocument.addNewStandardResponse();

		Trx trx = null;
		try {
			ADLoginRequest loginReq = linkOrUnlinkPalletRequest.getADLoginRequest();
			String serviceType = linkOrUnlinkPalletRequest.getServiceType();
			String palletUUID = linkOrUnlinkPalletRequest.getPalletUUID();
			int oldLocatorId = linkOrUnlinkPalletRequest.getOldLocatorID();
			int newLocatorID = linkOrUnlinkPalletRequest.getNewLocatorID();

			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "linkOrUnlinkPallet", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return standardResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("linkOrUnlinkPallet")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return standardResponseDocument;
			}

			String columnName = "palletUUId";
			List<PO> piQrRelations = PiQrRelations.getPiQrRelationsData(columnName, palletUUID, ctx, trxName);

			MMovement mMovement = null;
			if (newLocatorID != 0) {
				MLocator mLocator = new MLocator(ctx, newLocatorID, trxName);
				mMovement = new MMovement(ctx, 0, trxName);
				mMovement.setIsActive(true);
				mMovement.setDescription(null);
				mMovement.setApprovalAmt(BigDecimal.valueOf(0));
				mMovement.setChargeAmt(BigDecimal.valueOf(0));
				mMovement.setFreightAmt(BigDecimal.valueOf(0));
				mMovement.setM_Warehouse_ID(mLocator.getM_Warehouse_ID());
				mMovement.setM_WarehouseTo_ID(mLocator.getM_Warehouse_ID());
				mMovement.setAD_Org_ID(loginReq.getOrgID());
				mMovement.saveEx();
			}

			for (PO po : piQrRelations) {
				PiQrRelations pr = new PiQrRelations(ctx, po.get_ID(), trxName);

				if (newLocatorID != 0 && newLocatorID != pr.getlocatorid()) {
					MMovementLine mMovementLine = new MMovementLine(ctx, 0, trxName);
					mMovementLine.setM_Locator_ID(pr.getlocatorid());
					mMovementLine.setM_LocatorTo_ID(newLocatorID);
					mMovementLine.setM_Movement_ID(mMovement.get_ID());
					mMovementLine.setM_Product_ID(pr.getproductid());
					mMovementLine.setLine(10);
					mMovementLine.setMovementQty(pr.getquantity());
					mMovementLine.setDescription(null);
					mMovementLine.setProcessed(true);
					mMovementLine.saveEx();

					MMovementLineMA mMovementLineMA = new MMovementLineMA(ctx, 0, trxName);
					mMovementLineMA.setM_AttributeSetInstance_ID(0);
					mMovementLineMA.setIsActive(true);
					mMovementLineMA.setMovementQty(mMovementLine.getMovementQty());
					mMovementLineMA.setIsAutoGenerated(true);
					mMovementLineMA.setM_MovementLine_ID(mMovementLine.get_ID());
					mMovementLineMA.setDateMaterialPolicy(new Timestamp(new Date().getTime()));
					mMovementLineMA.saveEx();

					MTransaction mTransactionOut = new MTransaction(ctx, 0, trxName);
					mTransactionOut.setIsActive(true);
					mTransactionOut.setMovementType("M-");
					mTransactionOut.setM_Locator_ID(mMovementLine.getM_Locator_ID());
					mTransactionOut.setM_Product_ID(mMovementLine.getM_Product_ID());
					mTransactionOut.setMovementQty(mMovementLine.getMovementQty().negate());
					mTransactionOut.setM_MovementLine_ID(mMovementLine.get_ID());
					mTransactionOut.setM_AttributeSetInstance_ID(mMovementLine.getM_AttributeSetInstance_ID());
					mTransactionOut.saveEx();

					MTransaction mTransactionIn = new MTransaction(ctx, 0, trxName);
					mTransactionIn.setIsActive(true);
					mTransactionIn.setMovementType("M+");
					mTransactionIn.setM_Locator_ID(mMovementLine.getM_LocatorTo_ID());
					mTransactionIn.setM_Product_ID(mMovementLine.getM_Product_ID());
					mTransactionIn.setMovementQty(mMovementLine.getMovementQty());
					mTransactionIn.setM_MovementLine_ID(mMovementLine.get_ID());
					mTransactionIn.setM_AttributeSetInstance_ID(mMovementLine.getM_AttributeSetInstance_ID());
					mTransactionIn.saveEx();

					MAcctSchema[] MAcctSchemaArray = MAcctSchema.getClientAcctSchema(ctx, loginReq.getClientID());
					MAcctSchema AcctSchema = MAcctSchemaArray[0];

					List<PO> list = new Query(ctx, MElementValue.Table_Name, "name=? AND ad_client_id=?", trxName)
							.setParameters("Product asset", loginReq.getClientID())
							.setOrderBy(MElementValue.COLUMNNAME_C_ElementValue_ID).list();
					MElementValue mElementValue = (MElementValue) list.get(0);
					int mElementValueId = mElementValue.get_ID();

					MPeriod mPeriod = MPeriod.get(ctx, mMovement.getMovementDate(), loginReq.getOrgID(), trxName);

					MGLCategory mGLCategory = MGLCategory.getDefault(ctx, "M");
					MOrderLine mOrderLine = new MOrderLine(ctx, pr.getcorderlineid(), trxName);

					MFactAcct mFactAcct = new MFactAcct(ctx, 0, trxName);
					mFactAcct.setIsActive(true);
					mFactAcct.setC_AcctSchema_ID(AcctSchema.get_ID());
					mFactAcct.setAccount_ID(mElementValueId);
					mFactAcct.setDateTrx(mMovement.getMovementDate());
					mFactAcct.setDateAcct(mMovement.getMovementDate());
					mFactAcct.setC_Period_ID(mPeriod.get_ID());
					mFactAcct.setAD_Table_ID(mMovement.get_Table_ID());
					mFactAcct.setRecord_ID(mMovement.get_ID());
					mFactAcct.setLine_ID(mMovementLine.get_ID());
					mFactAcct.setGL_Category_ID(mGLCategory.get_ID());
					mFactAcct.setM_Locator_ID(pr.getlocatorid());
					mFactAcct.setPostingType("A");
					mFactAcct.setC_Currency_ID(AcctSchema.getC_Currency_ID());
					mFactAcct.setAmtSourceDr(mOrderLine.getPriceActual().multiply(pr.getquantity()));
					mFactAcct.setAmtSourceCr(BigDecimal.valueOf(0));
					mFactAcct.setAmtAcctCr(BigDecimal.valueOf(0));
					mFactAcct.setAmtAcctDr(mOrderLine.getPriceActual().multiply(pr.getquantity()));
					mFactAcct.setC_UOM_ID(mOrderLine.getC_UOM_ID());
					mFactAcct.setQty(pr.getquantity());
					mFactAcct.setM_Product_ID(pr.getproductid());
					mFactAcct.setDescription(mMovement.getDocumentNo() + "#" + mMovementLine.getLine());
					mFactAcct.saveEx();

					MFactAcct mFactAcctIn = new MFactAcct(ctx, 0, trxName);
					mFactAcctIn.setIsActive(true);
					mFactAcctIn.setC_AcctSchema_ID(AcctSchema.get_ID());
					mFactAcctIn.setAccount_ID(mElementValueId);
					mFactAcctIn.setDateTrx(mMovement.getMovementDate());
					mFactAcctIn.setDateAcct(mMovement.getMovementDate());
					mFactAcctIn.setC_Period_ID(mPeriod.get_ID());
					mFactAcctIn.setAD_Table_ID(mMovement.get_Table_ID());
					mFactAcctIn.setRecord_ID(mMovement.get_ID());
					mFactAcctIn.setLine_ID(mMovementLine.get_ID());
					mFactAcctIn.setGL_Category_ID(mGLCategory.get_ID());
					mFactAcctIn.setM_Locator_ID(newLocatorID);
					mFactAcctIn.setPostingType("A");
					mFactAcctIn.setC_Currency_ID(AcctSchema.getC_Currency_ID());
					mFactAcctIn.setAmtSourceCr(mOrderLine.getPriceActual().multiply(pr.getquantity()));
					mFactAcctIn.setAmtSourceDr(BigDecimal.valueOf(0));
					mFactAcctIn.setAmtAcctDr(BigDecimal.valueOf(0));
					mFactAcctIn.setAmtAcctCr(mOrderLine.getPriceActual().multiply(pr.getquantity()));
					mFactAcctIn.setC_UOM_ID(mOrderLine.getC_UOM_ID());
					mFactAcctIn.setQty(pr.getquantity());
					mFactAcctIn.setM_Product_ID(pr.getproductid());
					mFactAcctIn.setDescription(mMovement.getDocumentNo() + "#" + mMovementLine.getLine());
					mFactAcctIn.saveEx();

				}
				oldLocatorId = pr.getlocatorid();
				if (newLocatorID == 0)
					pr.setisinlocator(0);
				else {
					pr.setlocatorid(newLocatorID);
					pr.setisinlocator(1);
				}
				pr.saveEx();
			}
			if (newLocatorID != 0 && newLocatorID != oldLocatorId) {
				mMovement.setDocStatus(DocAction.ACTION_Complete);
				mMovement.setDocAction(DocAction.ACTION_Close);
				mMovement.setPosted(true);
				mMovement.setProcessed(true);
				mMovement.setIsApproved(true);
				mMovement.completeIt();
				mMovement.saveEx();
			} else if (newLocatorID != 0)
				mMovement.deleteEx(true);
			trx.commit();
			standardResponse.setIsError(false);
		} catch (Exception e) {
			e.printStackTrace();
			standardResponse.setError(e.getMessage());
			standardResponse.setIsError(true);
			return standardResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return standardResponseDocument;
	}

	@Override
	public LocatorSuggestionResponseDocument getLocatorSuggestionForProduct(
			LocatorSuggestionRequestDocument locatorSuggestionRequestDocument) {
		LocatorSuggestionResponseDocument locatorSuggestionResponseDocument = LocatorSuggestionResponseDocument.Factory
				.newInstance();
		LocatorSuggestionResponse locatorSuggestionResponse = locatorSuggestionResponseDocument
				.addNewLocatorSuggestionResponse();
		LocatorSuggestionRequest locatorSuggestionRequest = locatorSuggestionRequestDocument
				.getLocatorSuggestionRequest();
		ADLoginRequest loginReq = locatorSuggestionRequest.getADLoginRequest();
		String serviceType = locatorSuggestionRequest.getServiceType();
		Trx trx = null;
		CompiereService m_cs = getCompiereService();
		Properties ctx = m_cs.getCtx();
		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "locatorSuggestion", serviceType);
			if (err != null && err.length() > 0) {
				locatorSuggestionResponse.setError(err);
				locatorSuggestionResponse.setIsError(true);
				return locatorSuggestionResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("locatorSuggestion")) {
				locatorSuggestionResponse.setIsError(true);
				locatorSuggestionResponse.setError("Service type " + serviceType + " not configured");
				return locatorSuggestionResponseDocument;
			}

			int warehouseId = locatorSuggestionRequest.getWarehouseID();
			MWarehouse mWarehouse = new MWarehouse(ctx, warehouseId, trxName);
			MLocator mLocatorArray[] = mWarehouse.getLocators(true);

			LocatorSLine[] locatorSLineArray = locatorSuggestionRequest.getLocatorSLineArray();
			for (LocatorSLine data : locatorSLineArray) {
				LocatorSLine line = locatorSuggestionResponse.addNewLocatorSLine();
				int M_Product_ID = data.getProductId();
				int locatorSuggested = 0;
				for (MLocator mLocator : mLocatorArray) {
					BigDecimal qnty = MStorageOnHand.getQtyOnHandForLocator(M_Product_ID, mLocator.get_ID(), 0,
							trxName);
					if (!mLocator.getValue().equalsIgnoreCase("Dispatch Locator") && qnty.intValue() <= 0) {
						locatorSuggested = mLocator.get_ID();
						break;
					}
				}
				line.setProductId(M_Product_ID);
				line.setLocatorSuggested(locatorSuggested);
			}
			trx.commit();
			locatorSuggestionResponse.setIsError(false);
		} catch (Exception e) {
			locatorSuggestionResponse.setError(e.getMessage());
			locatorSuggestionResponse.setIsError(true);
			return locatorSuggestionResponseDocument;

		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return locatorSuggestionResponseDocument;
	}

	@Override
	public QcCOListResponseDocument getQcCOMrList(QCListRequestDocument req) {

		QcCOListResponseDocument qcCOListResponseDocument = QcCOListResponseDocument.Factory.newInstance();
		QcCOListResponse qcCOListResponse = qcCOListResponseDocument.addNewQcCOListResponse();
		QCListRequest qCListRequest = req.getQCListRequest();
		ADLoginRequest loginReq = qCListRequest.getADLoginRequest();
		String serviceType = qCListRequest.getServiceType();
		String searchKey = qCListRequest.getSearchKey();
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			int clientId = loginReq.getClientID();
			int roleId = loginReq.getRoleID();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "qcCheckedList", serviceType);
			if (err != null && err.length() > 0) {
				qcCOListResponse.setError(err);
				qcCOListResponse.setIsError(true);
				return qcCOListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("qcCheckedList")) {
				qcCOListResponse.setIsError(true);
				qcCOListResponse.setError("Service type " + serviceType + " not configured");
				return qcCOListResponseDocument;
			}
			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "SELECT\n" + "    DISTINCT(po.documentno) AS documentNo,\n" + "    bp.name AS Supplier,\n"
					+ "    po.m_inout_id AS mInoutID,\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name,\n" + "    po.description, po.created, po.m_inout_id,\n"
					+ "	co.documentno as orderDocumentno\n" + "FROM m_inout po\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "JOIN c_order co on co.c_order_id = po.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE po.ad_client_id = "
					+ clientId
					+ " AND po.issotrx = 'N' AND po.pickStatus = 'QC' AND po.docstatus = 'DR' AND po.ad_org_id IN ("
					+ orgIds + ") AND po.ad_orgtrx_id is null " + "AND (\n"
					+ "    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'\n"
					+ "    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'\n"
					+ "    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'\n"
					+ "    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'\n"
					+ "    OR co.documentno ILIKE '%' || COALESCE(?, co.documentno) || '%'\n" + ")\n"
					+ " ORDER BY po.created desc;";

			pstm = DB.prepareStatement(query.toString(), null);
			pstm.setString(1, searchKey);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			pstm.setString(5, searchKey);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {
				QcCOLine qcCOLine = qcCOListResponse.addNewQcCOLine();
				String documentNo = rs.getString("documentNo");
				String mInoutID = rs.getString("mInoutID");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String orderDocumentno = rs.getString("orderDocumentno");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				qcCOLine.setDocumentNo(documentNo);
				qcCOLine.setMInoutID(mInoutID);
				qcCOLine.setSupplier(supplier);
				qcCOLine.setOrderDate(date);
				qcCOLine.setWarehouseName(warehouseName);
				qcCOLine.setOrderDocumentno(orderDocumentno);
				if (description == null)
					qcCOLine.setDescription("");
				else
					qcCOLine.setDescription(description);
				count++;
			}
			qcCOListResponse.setCount(count);
		} catch (SQLException e) {
			qcCOListResponse.setIsError(true);
			qcCOListResponse.setError(e.getMessage());
			return qcCOListResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return qcCOListResponseDocument;
	}

	@Override
	public QcDataResponseDocument getQcCOMrData(PODataRequestDocument req) {

		QcDataResponseDocument qcDataResponseDocument = QcDataResponseDocument.Factory.newInstance();
		QcDataResponse qcDataResponse = qcDataResponseDocument.addNewQcDataResponse();
		PODataRequest pODataRequest = req.getPODataRequest();
		ADLoginRequest loginReq = pODataRequest.getADLoginRequest();
		String serviceType = pODataRequest.getServiceType();
		String documentNo = pODataRequest.getDocumentNo();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			int clientId = loginReq.getClientID();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "qcCheckedData", serviceType);
			if (err != null && err.length() > 0) {
				qcDataResponse.setError(err);
				qcDataResponse.setIsError(true);
				return qcDataResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("qcCheckedData")) {
				qcDataResponse.setIsError(true);
				qcDataResponse.setError("Service type " + serviceType + " not configured");
				return qcDataResponseDocument;
			}

			String query = "SELECT\n" + "    bp.name AS Supplier,\n" + "    mi.docstatus,\n" + "    mi.c_order_id,\n"
					+ "    TO_CHAR(mi.dateordered, 'DD/MM/YYYY') AS Order_Date,\n" + "    ml.movementqty,\n"
					+ "    wh.name AS Warehouse_Name,\n" + "    wh.m_warehouse_id,\n" + "    mi.description,\n"
					+ "    ml.m_inoutline_id,\n" + "    ml.qcfailedqty,\n" + "    ml.M_inout_id,  -- Added this field\n"
					+ "    co.documentno as orderDocumentno,\n" + "    mp.m_product_id,\n" + "    mp.name\n"
					+ "FROM m_inoutline ml\n" + "JOIN m_inout mi ON mi.m_inout_id = ml.m_inout_id\n"
					+ "JOIN c_bpartner bp ON mi.c_bpartner_id = bp.c_bpartner_id\n"
					+ "JOIN m_warehouse wh ON mi.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN m_product mp on mp.m_product_id = ml.m_product_id\n"
					+ "JOIN c_order co on mi.c_order_id = co.c_order_id\n" + "WHERE mi.documentNo = '" + documentNo
					+ "' AND mi.pickStatus = 'QC' AND mi.ad_client_id = " + clientId + " ORDER BY ml.m_inoutline_id;";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int count = 0;
			String supplier = null;
			String description = null;
			String docStatus = null;
			String warehouseName = null;
			String orderDocumentno = null;
			String date = null;
			int lineCount = 0;
			int mInoutId = 0;
			int cOrderId = 0;
			List<Integer> locaorsId = new ArrayList<>();
			while (rs.next()) {
				QcLine qcLine = qcDataResponse.addNewQcLine();
				supplier = rs.getString("Supplier");
				date = rs.getString("Order_Date");
				warehouseName = rs.getString("Warehouse_Name");
				description = rs.getString("description");
				docStatus = rs.getString("docstatus");
				int receivedQnty = rs.getInt("movementqty");
				int mInoutlineId = rs.getInt("m_inoutline_id");
				mInoutId = rs.getInt("m_inout_id");
				// int productId = rs.getInt("m_product_id");
				String productName = rs.getString("name");
				orderDocumentno = rs.getString("orderDocumentno");
				int qcfailedqty = rs.getInt("qcfailedqty");
				int warehouseId = rs.getInt("m_warehouse_id");
				cOrderId = rs.getInt("c_order_id");
				qcLine.setProductName(productName);
				qcLine.setMRLineId(mInoutlineId);
				qcLine.setRecievedQnty(receivedQnty);
				qcLine.setQcFailedQnty(qcfailedqty);
				count += receivedQnty;
				lineCount++;

				int locatorSuggested = 0;
				String locatorName = null;
				pstm.close();
				rs.close();
				locaorsId.add(0);
				String ids = locaorsId.stream().map(Object::toString).collect(Collectors.joining(", "));
				String sql = "SELECT l.M_Locator_ID, l.value\n" + "FROM M_Locator l\n" + "LEFT JOIN (\n"
						+ "    SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
						+ "    FROM M_StorageOnHand\n" + "    GROUP BY M_Locator_ID\n"
						+ ") ms ON l.M_Locator_ID = ms.M_Locator_ID\n" + "WHERE l.m_warehouse_id = " + warehouseId
						+ " AND COALESCE(ms.TotalQty, 0) = 0\n"
						+ "AND l.value != 'Dispatch Locator' AND l.value != 'Receiving Locator' AND l.M_Locator_ID NOT IN ("
						+ ids + ")\n" + "ORDER BY l.M_Locator_ID\n" + "LIMIT 1;";
				pstm = DB.prepareStatement(sql, null);
				rs = pstm.executeQuery();
				while (rs.next()) {
					locatorName = rs.getString("value");
					locatorSuggested = rs.getInt("M_Locator_ID");
					locaorsId.add(locatorSuggested);
				}
				if (locatorSuggested == 0) {
					MWarehouse mWarehouse = new MWarehouse(ctx, warehouseId, trxName);
					locatorSuggested = mWarehouse.getDefaultLocator().get_ID();
					locatorName = mWarehouse.getDefaultLocator().getValue();
				}
				List<PO> piQrRelations = PiQrRelations.getPiQrRelationsData("minoutlineid",
						Integer.toString(mInoutlineId), ctx, trxName);
				PiQrRelations pr = new PiQrRelations(ctx, piQrRelations.get(0).get_ID(), trxName);
				qcLine.setMRLineId(pr.getminoutlineid());
				qcLine.setSuggestedLocator(locatorSuggested);
				qcLine.setLocatorName(locatorName);
			}
			qcDataResponse.setDocumentNo(documentNo);
			qcDataResponse.setMInoutID(mInoutId);
			qcDataResponse.setOrderDocumentno(orderDocumentno);
			qcDataResponse.setSupplier(supplier);
			qcDataResponse.setOrderDate(date);
			qcDataResponse.setWarehouseName(warehouseName);
			qcDataResponse.setDocStatus(docStatus);
			qcDataResponse.setCOrderId(cOrderId);
			if (description == null)
				qcDataResponse.setDescription("");
			else
				qcDataResponse.setDescription(description);
			qcDataResponse.setOverallQnty(count);

			if (lineCount == 0) {
				QcDataResponseDocument mRDataResponse = QcDataResponseDocument.Factory.newInstance();
				qcDataResponse = mRDataResponse.addNewQcDataResponse();
				qcDataResponse.setIsError(true);
				qcDataResponse.setError("MR with : " + documentNo + " have no lines");
				return qcDataResponseDocument;
			}

			trx.commit();
		} catch (SQLException e) {
			qcDataResponse.setIsError(true);
			qcDataResponse.setError(e.getMessage());
			return qcDataResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return qcDataResponseDocument;
	}

	@Override
	public StandardResponseDocument markMrQcChecked(MarkMRQcCheckedRequestDocument req) {

		StandardResponseDocument standardResponseDocument = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = standardResponseDocument.addNewStandardResponse();
		MarkMRQcCheckedRequest markMRQcCheckedRequest = req.getMarkMRQcCheckedRequest();
		ADLoginRequest loginReq = markMRQcCheckedRequest.getADLoginRequest();
		String serviceType = markMRQcCheckedRequest.getServiceType();
		boolean isQcChecked = markMRQcCheckedRequest.getQchChecked();
		int mInoutId = markMRQcCheckedRequest.getMInoutId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "markMRQcChecked", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return standardResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("markMRQcChecked")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return standardResponseDocument;
			}

			if (isQcChecked == true) {
				MInOut_Custom mInOut_Custom = new MInOut_Custom(ctx, mInoutId, trxName);
				mInOut_Custom.setPickStatus("QC");
				// MInOut inout = new MInOut(ctx, mInoutId, trx.getTrxName());
				// inout.setDescription("QC");
				mInOut_Custom.saveEx();
			}
			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return standardResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return standardResponseDocument;
	}

	@Override
	public StandardResponseDocument updateMr(UpdateMrRequestDocument req) {

		StandardResponseDocument standardResponseDocument = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = standardResponseDocument.addNewStandardResponse();
		UpdateMrRequest updateMrRequest = req.getUpdateMrRequest();
		ADLoginRequest loginReq = updateMrRequest.getADLoginRequest();
		String serviceType = updateMrRequest.getServiceType();
		// int mInoutId = updateMrRequest.getMInoutId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "updateMr", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return standardResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("updateMr")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return standardResponseDocument;
			}

			QcLine qcLineArray[] = updateMrRequest.getQcLineArray();
			for (QcLine line : qcLineArray) {
				int mInoutLineId = line.getMRLineId();
				MInOutLine inoutLine = new MInOutLine(ctx, mInoutLineId, trx.getTrxName());
				inoutLine.setM_Locator_ID(line.getSuggestedLocator());
				inoutLine.saveEx();

				List<PO> piQrRelationsList = PiQrRelations.getPiQrRelationsData("minoutlineid",
						Integer.toString(mInoutLineId), ctx, trxName);
				PiQrRelations pr = new PiQrRelations(ctx, piQrRelationsList.get(0).get_ID(), trxName);
				PiQrRelations piQrRelations = new PiQrRelations(ctx, pr.get_ID(), trxName);
				piQrRelations.setlocatorid(line.getSuggestedLocator());
				piQrRelations.setisinlocator(1);
				piQrRelations.saveEx();

			}
			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return standardResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return standardResponseDocument;
	}

	@Override
	public DToCResponseDocument d2cOrder(DToCRequestDocument dToCRequestDocument) {
		DToCResponseDocument dToCResponseDocument = DToCResponseDocument.Factory.newInstance();
		DToCResponse dToCResponse = dToCResponseDocument.addNewDToCResponse();
		DToCRequest dToCRequest = dToCRequestDocument.getDToCRequest();
		if (dToCRequest == null) {
			dToCResponse.setIsError(true);
			dToCResponse.setError("Invalid Request: DToCRequest is missing");
			return dToCResponseDocument;
		}
		ADLoginRequest loginReq = dToCRequest.getADLoginRequest();
		if (loginReq == null) {
			dToCResponse.setIsError(true);
			dToCResponse.setError("Invalid Request: ADLoginRequest is missing");
			return dToCResponseDocument;
		}
		int ad_client_id = loginReq.getClientID();
		int ad_org_id = loginReq.getOrgID();
		int ad_warehouse_id = loginReq.getWarehouseID();
		String serviceType = dToCRequest.getServiceType();
		String bPartnerNameN = dToCRequest.getBPartnerNameN();
		String bPartnerAddress = dToCRequest.getBPartnerAddress();
		if (bPartnerNameN == null || bPartnerNameN.trim().isEmpty()) {
			dToCResponse.setIsError(true);
			dToCResponse.setError("bPartnerNameN is missing or empty");
			return dToCResponseDocument;
		}
		if (bPartnerAddress == null) {
			bPartnerAddress = "";
		}
		String businessPartnerName = "";
		MOrder mOrder = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		Trx trx = null;
		CompiereService m_cs = getCompiereService();
		Properties ctx = m_cs.getCtx();
		ProductLines[] proLines = dToCRequest.getProductsArray();
		if (proLines == null || proLines.length == 0) {
			dToCResponse.setIsError(true);
			dToCResponse.setError("No products specified");
			return dToCResponseDocument;
		}

		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "directToCustomer", serviceType);
			if (err != null && err.length() > 0) {
				dToCResponse.setError(err);
				dToCResponse.setIsError(true);
				return dToCResponseDocument;
			}
			if (serviceType == null || !serviceType.equalsIgnoreCase("directToCustomer")) {
				dToCResponse.setIsError(true);
				dToCResponse.setError("Service type " + serviceType + " not configured");
				return dToCResponseDocument;
			}

			MTable mDocType = MTable.get(ctx, "c_doctype");
			PO mDocTypePo = mDocType.getPO("name = 'Standard Order' and ad_client_id = " + ad_client_id + "",
					trx.getTrxName());
			MDocType mDocTypee = (MDocType) mDocTypePo;
			int docTypeId = mDocTypee.get_ID();

			MTable mUser = MTable.get(ctx, "ad_user");
			PO mUserPo = mUser.getPO("name LIKE '%Admin' and ad_client_id = " + ad_client_id + "", trx.getTrxName());
			MUser mUserId = (MUser) mUserPo;
			int userId = mUserId.get_ID();

			String sql = "select name from adempiere.c_bpartner where ad_client_id = " + ad_client_id
					+ " and iscustomer = 'Y'";
			pstm = DB.prepareStatement(sql.toString(), null);
			rs = pstm.executeQuery();

			boolean nameExists = false;
			while (rs.next()) {
				businessPartnerName = rs.getString("name");
				if (bPartnerNameN.equals(businessPartnerName)) {
					nameExists = true;
					break;
				}
			}
			pstm.close();
			rs.close();
			if (!nameExists) {
				MBPartner bp = new MBPartner(Env.getCtx(), 0, trx.getTrxName());
				bp.setClientOrg(ad_client_id, ad_org_id);
				bp.setName(bPartnerNameN);
				bp.setIsCustomer(true);
				if (!bp.save()) {
					throw new Exception("Failed to save Business Partner: " + bp);
				}

				MLocation location = new MLocation(Env.getCtx(), 0, null);
				location.setAddress1(bPartnerAddress);
				// location.setPostal("491111");
				location.setC_Country_ID(208);

				if (!location.save()) {
					throw new Exception("Failed to save Location: " + location);
				}
				MBPartnerLocation bpLocation = new MBPartnerLocation(bp);
				bpLocation.setC_Location_ID(location.getC_Location_ID());

				if (!bpLocation.save()) {
					throw new Exception("Failed to save Business Partner Location: " + bpLocation);
				}
				trx.commit();
				int bPartner_ID = bp.getC_BPartner_ID();
				mOrder = createSOOrder(ad_client_id, ad_org_id, ad_warehouse_id, proLines, bPartner_ID, ctx, docTypeId,
						userId, trx);
			} else {
				MTable mbartner = MTable.get(ctx, "c_bpartner");
				PO mbartnerPo = mbartner.getPO("name = '" + bPartnerNameN + "' and ad_client_id = " + ad_client_id + "",
						trx.getTrxName());
				MBPartner mbPartner = (MBPartner) mbartnerPo;
				mOrder = createSOOrder(ad_client_id, ad_org_id, ad_warehouse_id, proLines, mbPartner.get_ID(), ctx,
						docTypeId, userId, trx);
			}

			dToCResponse.setSalesOrderDocumentNumber(mOrder.getDocumentNo());
			dToCResponse.setSalesOrderId(mOrder.get_ID());

		} catch (Exception e) {
			e.printStackTrace();
			dToCResponse.setError(e.getLocalizedMessage());
			dToCResponse.setIsError(true);
			return dToCResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return dToCResponseDocument;
	}

	private MOrder createSOOrder(int ad_client_id, int org_id, int warehouseId, ProductLines[] lines, int bPartner_ID,
			Properties ctx, int docTypeId, int userId, Trx trx) throws Exception {
		MOrder so = new MOrder(ctx, 0, null);
		so.setC_DocTypeTarget_ID(docTypeId);
		so.setAD_Org_ID(org_id);
		so.setC_BPartner_ID(bPartner_ID);
		so.setM_Warehouse_ID(warehouseId);
		so.setIsSOTrx(true);
		so.setSalesRep_ID(userId);
		so.setPaymentRule("B");

		if (!so.save()) {
			throw new Exception("Failed to save Sales Order header");
		}

		for (ProductLines line : lines) {
			if (line == null) {
				continue;
			}
			String productName = line.getProductName();
			if (productName == null || productName.trim().isEmpty()) {
				throw new Exception("Product name is missing or null in product lines");
			}
			int productQTY = line.getProductQTY();

			MTable mProduct = MTable.get(ctx, "m_product");
			PO mProductPo = mProduct.getPO("name = '" + productName + "' and ad_client_id = " + ad_client_id + "",
					trx.getTrxName());
			if (mProductPo == null) {
				throw new Exception("Product not found with name: " + productName + " for client: " + ad_client_id);
			}
			MProduct mProductt = (MProduct) mProductPo;
			int productId = mProductt.get_ID();

			MOrderLine mOrderLine = new MOrderLine(so);
			mOrderLine.setM_Product_ID(productId);
			mOrderLine.setQty(BigDecimal.valueOf(productQTY));
			mOrderLine.saveEx();
		}
		so.setDocAction(MOrder.DOCACTION_Complete);
		so.processIt(MOrder.DOCACTION_Complete);
		so.save();
		return so;
	}

	@Override
	public WarehouseLocatorListResponseDocument wareList(
			WarehouseLocatorListRequestDocument warehouseLocatorListRequestDocument) {
		WarehouseLocatorListResponseDocument warehouseLocatorListResponseDocument = WarehouseLocatorListResponseDocument.Factory
				.newInstance();
		WarehouseLocatorListResponse warehouseLocatorListResponse = warehouseLocatorListResponseDocument
				.addNewWarehouseLocatorListResponse();
		WarehouseLocatorListRequest warehouseLocatorListRequest = warehouseLocatorListRequestDocument
				.getWarehouseLocatorListRequest();
		ADLoginRequest loginReq = warehouseLocatorListRequest.getADLoginRequest();
		int ad_client_id = loginReq.getClientID();
		String serviceType = warehouseLocatorListRequest.getServiceType();
		PreparedStatement pstm = null;
		ResultSet rs = null;

		try {
			String err = login(loginReq, webServiceName, "wareList", serviceType);
			if (err != null && err.length() > 0) {
				warehouseLocatorListResponse.setError(err);
				warehouseLocatorListResponse.setIsError(true);
				return warehouseLocatorListResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("wareList")) {
				warehouseLocatorListResponse.setIsError(true);
				warehouseLocatorListResponse.setError("Service type " + serviceType + " not configured");
				return warehouseLocatorListResponseDocument;
			}

			String sql = "SELECT \n" + "    w.m_warehouse_id as warehouseID,\n" + "    w.name as warehouseName,\n"
					+ "	ml.isdefault,\n" + "    (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "     LEFT JOIN (\n"
					+ "         SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
					+ "         FROM adempiere.M_StorageOnHand\n" + "         GROUP BY M_Locator_ID\n"
					+ "     ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
					+ "     WHERE l.m_warehouse_id = w.m_warehouse_id\n"
					+ "     AND COALESCE(ms.TotalQty, 0) = 0) AS emptyCount,\n"
					+ "    (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS total_count,\n"
					+ "    lt.name AS locator_type,\n" + "    ml.value AS location_values,\n"
					+ "    ((SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) - \n"
					+ "     (SELECT COUNT(*) FROM adempiere.M_Locator l\n" + "      LEFT JOIN (\n"
					+ "          SELECT M_Locator_ID, COALESCE(SUM(QtyOnHand), 0) AS TotalQty\n"
					+ "          FROM adempiere.M_StorageOnHand\n" + "          GROUP BY M_Locator_ID\n"
					+ "      ) ms ON l.M_Locator_ID = ms.M_Locator_ID\n"
					+ "      WHERE l.m_warehouse_id = w.m_warehouse_id\n" + "      AND COALESCE(ms.TotalQty, 0) = 0) \n"
					+ "    ) * 100 / (SELECT COUNT(*) FROM adempiere.m_locator WHERE m_warehouse_id = w.m_warehouse_id) AS occupancy_percentage\n"
					+ "FROM \n" + "    adempiere.m_warehouse w\n" + "JOIN \n"
					+ "    adempiere.m_locator ml ON ml.m_warehouse_id = w.m_warehouse_id\n" + "JOIN \n"
					+ "    adempiere.m_locatortype lt ON ml.m_locatortype_id = lt.m_locatortype_id\n" + "WHERE \n"
					+ "    ml.ad_client_id = " + ad_client_id + "\n" + "GROUP BY \n"
					+ "    w.m_warehouse_id, w.name, lt.name,ml.value,ml.isdefault;";
			pstm = DB.prepareStatement(sql.toString(), null);
			rs = pstm.executeQuery();

			List<Integer> warehouseIds = new ArrayList<>();

			while (rs.next()) {
				int warehouseId = rs.getInt("warehouseID");
				String warehouseName = rs.getString("warehouseName");
				int occupancyPercents = rs.getInt("occupancy_percentage");
				String locatorType = rs.getString("locator_type");
				String locatorName = rs.getString("location_values");

				if (!warehouseIds.contains(warehouseId)) {
					WarehouseListAccess warehouseListAccess = warehouseLocatorListResponse.addNewWarehouseListAccess();
					warehouseListAccess.setWarehouseId(warehouseId);
					warehouseListAccess.setWarehouseName(warehouseName);
					warehouseListAccess.setOccupancyPercentage(occupancyPercents);

					LocationType locationType = warehouseListAccess.addNewLocations();
					locationType.setLocatorTypeName(locatorType);

					Locators locators = locationType.addNewLocators();
					locators.setLocatorName(locatorName);
					locators.setIsOccupied(false);
					warehouseIds.add(warehouseId);
				} else {
					WarehouseListAccess[] warehouseListAccessArray = warehouseLocatorListResponse
							.getWarehouseListAccessArray();
					for (WarehouseListAccess wLAcess : warehouseListAccessArray) {
						if (wLAcess.getWarehouseId() == warehouseId) {
							boolean flag = false;
							LocationType[] LocationsArray = wLAcess.getLocationsArray();
							for (LocationType lType : LocationsArray) {
								if (lType.getLocatorTypeName().equals(locatorType)) {
									Locators locators = lType.addNewLocators();
									locators.setLocatorName(locatorName);
									locators.setIsOccupied(false);
									flag = true;
									break;
								}
							}
							if (flag == false) {
								LocationType locationType = wLAcess.addNewLocations();
								locationType.setLocatorTypeName(locatorType);
								Locators locators = locationType.addNewLocators();
								locators.setLocatorName(locatorName);
								locators.setIsOccupied(false);
							}
							break;
						}
					}
				}
			}

		} catch (Exception e) {
			warehouseLocatorListResponse.setError(e.getLocalizedMessage());
			warehouseLocatorListResponse.setIsError(true);
			return warehouseLocatorListResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return warehouseLocatorListResponseDocument;
	}

	@Override
	public SOOrderStatusResponseDocument soOrderStatus(SOOrderStatusRequestDocument sOOrderStatusRequestDocument) {

		SOOrderStatusResponseDocument sOOrderStatusResponseDocument = SOOrderStatusResponseDocument.Factory
				.newInstance();
		SOOrderStatusResponse sOOrderStatusResponse = sOOrderStatusResponseDocument.addNewSOOrderStatusResponse();
		SOOrderStatusRequest sOOrderStatusRequest = sOOrderStatusRequestDocument.getSOOrderStatusRequest();
		ADLoginRequest loginReq = sOOrderStatusRequest.getADLoginRequest();
		String serviceType = sOOrderStatusRequest.getServiceType();
		int cOrderId = sOOrderStatusRequest.getCOrderID();
		int client_id = loginReq.getClientID();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "soOrderStatus", serviceType);
			if (err != null && err.length() > 0) {
				sOOrderStatusResponse.setError(err);
				sOOrderStatusResponse.setIsError(true);
				return sOOrderStatusResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("soOrderStatus")) {
				sOOrderStatusResponse.setIsError(true);
				sOOrderStatusResponse.setError("Service type " + serviceType + " not configured");
				return sOOrderStatusResponseDocument;
			}

			String sql = "SELECT C_Order_ID FROM adempiere.C_Order WHERE AD_Client_ID = " + client_id
					+ " AND issotrx = 'Y'";
			pstm = DB.prepareStatement(sql.toString(), null);
			rs = pstm.executeQuery();
			boolean record = false;
			while (rs.next()) {
				int cId = rs.getInt("C_Order_ID");
				if (cId == cOrderId) {
					record = true;
					break;
				}
			}

			MOrder mOrder = new MOrder(ctx, cOrderId, trxName);
			if (!record) {
				sOOrderStatusResponse.setError("Customer Id is not Exist");
			} else {
				if (mOrder.getDocStatus().contains("DR")) {
					sOOrderStatusResponse.setReceived("Received not done");
					sOOrderStatusResponse.setPacked("Packed is not done");

				} else {
					sOOrderStatusResponse.setReceived(mOrder.getDateOrdered().toString());
					sOOrderStatusResponse.setPacked(mOrder.getDateOrdered().toString());
				}

				MInOut mInout = mOrder.getShipments().length > 0 ? mOrder.getShipments()[0] : null;
				if (mInout == null || mInout.get_ID() == 0) {
					sOOrderStatusResponse.setShipped("Shipped is not done");
				} else {
					sOOrderStatusResponse.setShipped(mInout.getMovementDate().toString());
				}
				MInvoice mInvoice = mOrder.getInvoices().length > 0 ? mOrder.getInvoices()[0] : null;
				if (mInvoice == null || mInvoice.get_ID() == 0) {
					sOOrderStatusResponse.setDelivered("Delivered is not done");
				} else {
					sOOrderStatusResponse.setDelivered(mInvoice.getDateInvoiced().toString());
				}
				sOOrderStatusResponse.setIsError(false);
				trx.commit();
			}
		} catch (Exception e) {
			sOOrderStatusResponse.setIsError(true);
			sOOrderStatusResponse.setError(e.getMessage());
			return sOOrderStatusResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return sOOrderStatusResponseDocument;
	}

	@Override
	public GetMInoutForCOrderResponseDocument getMInoutForCOrder(GetMInoutForCOrderRequestDocument req) {
		GetMInoutForCOrderResponseDocument getMInoutForCOrderResponseDocument = GetMInoutForCOrderResponseDocument.Factory
				.newInstance();
		GetMInoutForCOrderResponse getMInoutForCOrderResponse = getMInoutForCOrderResponseDocument
				.addNewGetMInoutForCOrderResponse();
		GetMInoutForCOrderRequest getMInoutForCOrderRequest = req.getGetMInoutForCOrderRequest();
		ADLoginRequest loginReq = getMInoutForCOrderRequest.getADLoginRequest();
		String serviceType = getMInoutForCOrderRequest.getServiceType();
		int cOrderId = getMInoutForCOrderRequest.getCOrderId();
		int clientId = loginReq.getClientID();
		getCompiereService().connect();
		CompiereService m_cs = getCompiereService();
		Properties ctx = m_cs.getCtx();
		String trxName = Trx.createTrxName(getClass().getName() + "_");
		Trx trx = Trx.get(trxName, true);
		trx.start();
		String err = login(loginReq, webServiceName, "getMInoutForCOrder", serviceType);
		if (err != null && err.length() > 0) {
			getMInoutForCOrderResponse.setError(err);
			getMInoutForCOrderResponse.setIsError(true);
			return getMInoutForCOrderResponseDocument;
		}

		if (!serviceType.equalsIgnoreCase("getMInoutForCOrder")) {
			getMInoutForCOrderResponse.setIsError(true);
			getMInoutForCOrderResponse.setError("Service type " + serviceType + " not configured");
			return getMInoutForCOrderResponseDocument;
		}
		try {
			List<PO> poList = MInOut_Custom.getMInoutsByCOrderId(cOrderId, ctx, trxName);
			if (poList.isEmpty()) {
				getMInoutForCOrderResponse.setIsError(true);
				getMInoutForCOrderResponse.setError("Invalid cOrderId " + cOrderId + "");
				return getMInoutForCOrderResponseDocument;
			}
			for (PO po : poList) {
				MInOut mInOut = new MInOut(ctx, po.get_ID(), trxName);
				MRDataResponse listResponse = getMInoutForCOrderResponse.addNewMRDataResponse();
				listResponse = getMInoutDataByDocumentNumber(listResponse, mInOut.getDocumentNo(), clientId);
			}
			trx.commit();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return getMInoutForCOrderResponseDocument;
	}

	@Override
	public GenerateProductLabelResponseDocument generateProductLabel(GenerateProductLabelRequestDocument request) {
		GenerateProductLabelRequest generateProductLabelRequest = request.getGenerateProductLabelRequest();
		GenerateProductLabelResponseDocument response = GenerateProductLabelResponseDocument.Factory.newInstance();
		GenerateProductLabelResponse generateProductLabelResponse = response.addNewGenerateProductLabelResponse();

		ADLoginRequest loginReq = generateProductLabelRequest.getADLoginRequest();
		String serviceType = generateProductLabelRequest.getServiceType();
		Trx trx = null;
		int locatorId = 0;
		String palletUUId = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(loginReq, webServiceName, "generateProductLabel", serviceType);
			if (err != null && err.length() > 0) {
				generateProductLabelResponse.setError(err);
				generateProductLabelResponse.setIsError(true);
				return response;
			}
			if (!serviceType.equalsIgnoreCase("generateProductLabel")) {
				generateProductLabelResponse.setIsError(true);
				generateProductLabelResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}
			ProductLabelLine[] productLabelLine = generateProductLabelRequest.getProductLabelLineArray();
			for (ProductLabelLine line : productLabelLine) {
				PiProductLabel piProductLabel = new PiProductLabel(ctx, trxName, loginReq, line, true);
				// piProductLabel.save();
				piProductLabel.saveEx();
				if (locatorId == 0)
					locatorId = piProductLabel.getM_Locator_ID();
				if (palletUUId == null)
					palletUUId = piProductLabel.getlabeluuid();

				line.setLabelId(piProductLabel.get_ID());
				line.setProductName(piProductLabel.getM_Product().getName());
				line.setProductLabelUUId(piProductLabel.getlabeluuid());
			}
			trx.commit();
			generateProductLabelResponse.setIsError(false);
			generateProductLabelResponse.setProductLabelLineArray(productLabelLine);

		} catch (Exception e) {
			generateProductLabelResponse.setError(e.getMessage());
			generateProductLabelResponse.setIsError(true);
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public GetLabelDataResponseDocument getLabelData(GetLabelDataRequestDocument request) {
		GetLabelDataRequest getLabelDataRequest = request.getGetLabelDataRequest();
		GetLabelDataResponseDocument getLabelDataResponseDocument = GetLabelDataResponseDocument.Factory.newInstance();
		GetLabelDataResponse getLabelDataResponse = getLabelDataResponseDocument.addNewGetLabelDataResponse();
		String labelUUID = getLabelDataRequest.getLabelUUID();
		// String labelType = getLabelDataRequest.getLabelType();
		boolean isPutawy = getLabelDataRequest.getIsPutAway();
		ADLoginRequest loginReq = getLabelDataRequest.getADLoginRequest();
		String serviceType = getLabelDataRequest.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "getLabelData", serviceType);
			if (err != null && err.length() > 0) {
				getLabelDataResponse.setError(err);
				getLabelDataResponse.setIsError(true);
				return getLabelDataResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("getLabelData")) {
				getLabelDataResponse.setIsError(true);
				getLabelDataResponse.setError("Service type " + serviceType + " not configured");
				return getLabelDataResponseDocument;
			}

			String columnName = "labelUUId";
			List<PO> poList = PiProductLabel.getPiProductLabel(columnName, labelUUID, ctx, trxName, null);
			if (poList.isEmpty()) {
				getLabelDataResponse.setIsError(true);
				getLabelDataResponse.setError("Invalid labelUUID " + labelUUID + "");
				return getLabelDataResponseDocument;
			}
			int labelCount = 0;

			for (PO po : poList) {
				ProductLabelLine labelLine = getLabelDataResponse.addNewLabelLine();
				PiProductLabel label = new PiProductLabel(ctx, po.get_ID(), trxName);
				I_M_InOut mInout = label.getM_InOutLine().getM_InOut();
				if (isPutawy && !mInout.getDocStatus().equalsIgnoreCase("CO")) {
					getLabelDataResponse.setIsError(true);
					getLabelDataResponse.setError("Material recipt is not completed, cant do putaway");
					return getLabelDataResponseDocument;
				}
				labelLine.setLabelId(label.getpi_productLabel_ID());
				labelLine.setProductLabelUUId(label.getlabeluuid());
				labelLine.setCOrderlineId(label.getC_OrderLine_ID());
				labelLine.setMInoutlineId(label.getM_InOutLine_ID());
				labelLine.setProductId(label.getM_Product_ID());
				labelLine.setProductName(label.getM_Product().getName());
				labelLine.setLocatorId(label.getM_Locator_ID());
				labelLine.setLocatorName(label.getM_Locator().getValue());
				labelLine.setQuantity(label.getquantity().intValue());
				labelLine.setIsSalesTransaction(label.isSOTrx());
				labelLine.setQcPassed(label.qcpassed());
				labelLine.setWarehouseId(label.getM_Locator().getM_Warehouse_ID());
				labelLine.setWarehouseName(label.getM_Locator().getM_Warehouse().getName());
				labelCount++;
			}

			getLabelDataResponse.setProductCount(labelCount);
			getLabelDataResponse.setLabelUUID(labelUUID);
			trx.commit();

		} catch (Exception e) {
			getLabelDataResponse.setError(e.getMessage());
			getLabelDataResponse.setIsError(true);
			return getLabelDataResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return getLabelDataResponseDocument;
	}

	@Override
	public StandardResponseDocument putAway(PutAwayRequestDocument request) {

		StandardResponseDocument standardResponseDocument = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = standardResponseDocument.addNewStandardResponse();
		PutAwayRequest putAwayRequest = request.getPutAwayRequest();
		ADLoginRequest loginReq = putAwayRequest.getADLoginRequest();
		String serviceType = putAwayRequest.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "putAway", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return standardResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("putAway")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return standardResponseDocument;
			}

			MMovement mMovement = new MMovement(ctx, 0, trxName);
			mMovement.setIsActive(true);
			mMovement.setDescription(null);
			mMovement.setApprovalAmt(BigDecimal.valueOf(0));
			mMovement.setChargeAmt(BigDecimal.valueOf(0));
			mMovement.setFreightAmt(BigDecimal.valueOf(0));
//			mMovement.setAD_Org_ID(loginReq.getOrgID());

			PutAwayLine putAwayLineArray[] = putAwayRequest.getPutAwayLineArray();
			String columnName = "labelUUId";
			int mWarehouseId = 0;
			for (PutAwayLine line : putAwayLineArray) {
				List<PO> poList = PiProductLabel.getPiProductLabel(columnName, line.getProductLabelUUId(), ctx, trxName,
						false);
				if (!poList.isEmpty()) {
					PiProductLabel piProductLabel = new PiProductLabel(ctx, poList.get(0).get_ID(), trxName);
					if (mWarehouseId == 0) {
						mWarehouseId = piProductLabel.getM_InOutLine().getM_Locator().getM_Warehouse_ID();
						mMovement.setM_Warehouse_ID(mWarehouseId);
						mMovement.setM_WarehouseTo_ID(mWarehouseId);
						mMovement.saveEx();
					}

					String validationError = PipraUtils.validateProductLocator(ctx, trxName,
							piProductLabel.getM_Product_ID(), line.getLocatorId());

					if (validationError != null) {
						standardResponse.setIsError(true);
						standardResponse.setError(validationError);
						return standardResponseDocument;
					}

					moveInventory(ctx, trxName, mMovement, loginReq, piProductLabel.getC_OrderLine_ID(),
							piProductLabel.getquantity(), piProductLabel.getM_Product_ID(),
							piProductLabel.getM_Locator_ID(), line.getLocatorId());

					piProductLabel.setM_Locator_ID(line.getLocatorId());
					piProductLabel.saveEx();
				}

			}

			mMovement.setDocStatus(DocAction.ACTION_Complete);
			mMovement.setDocAction(DocAction.ACTION_Close);
			mMovement.setPosted(true);
			mMovement.setProcessed(true);
			mMovement.setIsApproved(true);
			mMovement.completeIt();
			mMovement.saveEx();

			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return standardResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return standardResponseDocument;
	}

	@Override
	public LocatorDeatilResponseDocument getLocatorDeatilsById(LocatorDeatilRequestDocument request) {

		LocatorDeatilResponseDocument locatorDeatilResponseDocument = LocatorDeatilResponseDocument.Factory
				.newInstance();
		LocatorDeatilResponse locatorDeatilResponse = locatorDeatilResponseDocument.addNewLocatorDeatilResponse();
		LocatorDeatilRequest locatorDeatilRequest = request.getLocatorDeatilRequest();
		ADLoginRequest loginReq = locatorDeatilRequest.getADLoginRequest();
		String serviceType = locatorDeatilRequest.getServiceType();
		int locatorId = locatorDeatilRequest.getLocatorId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "getLocatorDeatilsById", serviceType);
			if (err != null && err.length() > 0) {
				locatorDeatilResponse.setError(err);
				locatorDeatilResponse.setIsError(true);
				return locatorDeatilResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("getLocatorDeatilsById")) {
				locatorDeatilResponse.setIsError(true);
				locatorDeatilResponse.setError("Service type " + serviceType + " not configured");
				return locatorDeatilResponseDocument;
			}
			MLocator mLocator = new MLocator(ctx, locatorDeatilRequest.getLocatorId(), trxName);
			if (mLocator.getM_Locator_ID() == 0) {
				locatorDeatilResponse.setIsError(true);
				locatorDeatilResponse.setError("Invalid Locator ID " + locatorId + "");
				return locatorDeatilResponseDocument;
			}
			locatorDeatilResponse.setLocatorId(mLocator.getM_Locator_ID());
			locatorDeatilResponse.setLocatorName(mLocator.getValue());
			locatorDeatilResponse.setAisle(mLocator.getX());
			locatorDeatilResponse.setLevel(mLocator.getY());
			locatorDeatilResponse.setBin(mLocator.getZ());
			locatorDeatilResponse.setLocatorTypeId(mLocator.getM_LocatorType_ID());
			locatorDeatilResponse.setLocatorType(mLocator.getM_LocatorType().getName());
			locatorDeatilResponse.setWarehouseId(mLocator.getM_Warehouse_ID());
			locatorDeatilResponse.setWarehouseName(mLocator.getWarehouseName());
			locatorDeatilResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			locatorDeatilResponse.setIsError(true);
			locatorDeatilResponse.setError(e.getMessage());
			return locatorDeatilResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return locatorDeatilResponseDocument;
	}

	@Override
	public PutAwayListResponseDocument putAwayList(PutAwayListRequestDocument request) {

		PutAwayListResponseDocument response = PutAwayListResponseDocument.Factory.newInstance();
		PutAwayListResponse putAwayListResponse = response.addNewPutAwayListResponse();
		PutAwayListRequest putAwayListRequest = request.getPutAwayListRequest();
		ADLoginRequest loginReq = putAwayListRequest.getADLoginRequest();
		String serviceType = putAwayListRequest.getServiceType();
		String searchKey = putAwayListRequest.getSearchKey();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "putAwayList", serviceType);
			if (err != null && err.length() > 0) {
				putAwayListResponse.setError(err);
				putAwayListResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("putAwayList")) {
				putAwayListResponse.setIsError(true);
				putAwayListResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(loginReq.getRoleID(), ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "SELECT\n" + "    DISTINCT(po.documentno) AS documentNo,\n" + "    bp.name AS Supplier,\n"
					+ "    po.m_inout_id AS mInoutID,\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name,\n" + "    po.description, po.created, po.m_inout_id,\n"
					+ "	co.documentno as orderDocumentno\n" + "FROM m_inout po\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "LEFT JOIN c_order co on co.c_order_id = po.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE po.ad_client_id = "
					+ loginReq.getClientID() + " AND po.issotrx = 'N' AND po.docstatus = 'DR' AND po.ad_org_id IN ("
					+ orgIds + ") AND po.ad_orgtrx_id is null " + "AND (\n"
					+ "    po.documentno ILIKE '%' || COALESCE(?, po.documentno) || '%'\n"
					+ "    OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%'\n"
					+ "    OR wh.name ILIKE '%' || COALESCE(?, wh.name) || '%'\n"
					+ "    OR po.description ILIKE '%' || COALESCE(?, po.description) || '%'\n"
					+ "    OR co.documentno ILIKE '%' || COALESCE(?, co.documentno) || '%'\n" + ")\n"
					+ " ORDER BY po.created desc;";

			pstm = DB.prepareStatement(query.toString(), null);
			pstm.setString(1, searchKey);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			pstm.setString(5, searchKey);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {
				PutAwayList putAwayList = putAwayListResponse.addNewPutAwayList();
				String documentNo = rs.getString("documentNo");
				int mInoutID = rs.getInt("mInoutID");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String orderDocumentno = rs.getString("orderDocumentno") == null ? "" : rs.getString("orderDocumentno");
//				String orderDocumentno = rs.getString("orderDocumentno");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				putAwayList.setDocumentNo(documentNo);
				putAwayList.setMInoutID(mInoutID);
				putAwayList.setSupplier(supplier);
				putAwayList.setOrderDate(date);
				putAwayList.setWarehouseName(warehouseName);
				putAwayList.setOrderDocumentno(orderDocumentno);
				putAwayList.setToMarkForPutAway(true);
				if (description == null)
					putAwayList.setDescription("");
				else
					putAwayList.setDescription(description);
				count++;
			}

			List<PO> poList = new ArrayList<PO>();
//			= MInOut_Custom.getLocatorByName("Receiving Locator", null, null,
//					loginReq.getWarehouseID());
			List<Integer> ids = MInOut_Custom.getLocatorIDsByName("Receiving Locator", loginReq.getClientID(), 0);
			if (ids.size() != 0) {
				for (Integer id : ids) {
					poList.addAll(PiProductLabel.getPiProductLabel("m_locator_ID", id, ctx, trxName, false));
				}
			} else {
				putAwayListResponse.setIsError(true);
				putAwayListResponse.setError("Receiving Locator Not Found");
				return response;
			}
			for (PO po : poList) {
				PiProductLabel piProductLabel = new PiProductLabel(ctx, po.get_ID(), trxName);
				I_M_InOut mInout = piProductLabel.getM_InOutLine().getM_InOut();
				if (mInout.getDocStatus().equalsIgnoreCase("CO")) {

					if (searchKey != null) {
						if (!mInout.getDocumentNo().toLowerCase().contains(searchKey.toLowerCase())
								&& !mInout.getC_BPartner().getName().toLowerCase().contains(searchKey.toLowerCase())
								&& !mInout.getM_Warehouse().getValue().toLowerCase().contains(searchKey.toLowerCase())
								&& !(mInout.getDescription() != null && mInout.getDescription() != ""
										&& mInout.getDescription().toLowerCase().contains(searchKey.toLowerCase()))
								&& !mInout.getC_Order().getDocumentNo().toLowerCase()
										.contains(searchKey.toLowerCase())) {
							continue;
						}
					}

					PutAwayList[] list = putAwayListResponse.getPutAwayListArray();
					boolean flag = false;
					for (PutAwayList pal : list) {
						if (pal.getMInoutID() == mInout.getM_InOut_ID()) {
							pal.setQuantityToPick(pal.getQuantityToPick() + piProductLabel.getquantity().intValue());
							flag = true;
							count++;
							break;
						}
					}
					if (!flag) {
						PutAwayList putAwayList = putAwayListResponse.addNewPutAwayList();
						putAwayList.setDocumentNo(mInout.getDocumentNo());
						putAwayList.setMInoutID(mInout.getM_InOut_ID());
						putAwayList.setSupplier(mInout.getC_BPartner().getName());
						putAwayList.setOrderDate(mInout.getDateOrdered().toString());
						putAwayList.setWarehouseId(mInout.getM_Warehouse_ID());
						putAwayList.setWarehouseName(mInout.getM_Warehouse().getValue());
						putAwayList.setOrderDocumentno(
								mInout.getC_Order().getDocumentNo() == null ? "" : mInout.getC_Order().getDocumentNo());
						putAwayList.setToMarkForPutAway(false);
						putAwayList.setQuantityToPick(piProductLabel.getquantity().intValue());
						int totalQuantity = MInOut_Custom.getTotalQuantityForMInout(ctx, trxName,
								mInout.getM_InOut_ID());
						putAwayList.setTotalQuantity(totalQuantity);
						if (mInout.getDescription() == null)
							putAwayList.setDescription("");
						else
							putAwayList.setDescription(mInout.getDescription());
						count++;
					}
				}

			}
			putAwayListResponse.setCount(count);
			putAwayListResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			putAwayListResponse.setIsError(true);
			putAwayListResponse.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public PutAwayLabourResponseDocument putAwayLabour(PutAwayLabourRequestDocument request) {

		PutAwayLabourResponseDocument response = PutAwayLabourResponseDocument.Factory.newInstance();
		PutAwayLabourResponse putAwayLabourResponse = response.addNewPutAwayLabourResponse();
		PutAwayLabourRequest putAwayLabourRequest = request.getPutAwayLabourRequest();
		ADLoginRequest loginReq = putAwayLabourRequest.getADLoginRequest();
		String serviceType = putAwayLabourRequest.getServiceType();
		Trx trx = null;
		try {
			int count = 0;
			int clientId = loginReq.getClientID();
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "putAwayLabour", serviceType);
			if (err != null && err.length() > 0) {
				putAwayLabourResponse.setError(err);
				putAwayLabourResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("putAwayLabour")) {
				putAwayLabourResponse.setIsError(true);
				putAwayLabourResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			List<PO> poList = new ArrayList<PO>();
			List<Integer> ids = MInOut_Custom.getLocatorIDsByName("Receiving Locator", loginReq.getClientID(),
					loginReq.getWarehouseID());
			if (ids.size() != 0) {
				for (Integer id : ids) {
					poList.addAll(PiProductLabel.getPiProductLabel("m_locator_ID", id, ctx, trxName, false));
				}
			} else {
				putAwayLabourResponse.setIsError(true);
				putAwayLabourResponse.setError("Receiving Locator Not Found");
				return response;
			}
			MLocator[] mLocatorArray = null;
			for (PO po : poList) {

				PiProductLabel piProductLabel = new PiProductLabel(ctx, po.get_ID(), trxName);
				if (piProductLabel.getM_InOutLine().getM_InOut().getDocStatus().equalsIgnoreCase("CO")) {
					PutAwayLabour[] putAwayLabourArray = putAwayLabourResponse.getPutAwayLabourArray();

					boolean flag = false;
					for (PutAwayLabour detail : putAwayLabourArray) {
						if (detail.getProductId() == piProductLabel.getM_Product_ID()) {
							detail.setQuantity(detail.getQuantity() + piProductLabel.getquantity().intValue());
							flag = true;
							count++;
							break;
						}
					}
					if (!flag) {
						PutAwayLabour putAwayLabour = putAwayLabourResponse.addNewPutAwayLabour();
						putAwayLabour.setProductId(piProductLabel.getM_Product_ID());
						putAwayLabour.setProductName(piProductLabel.getM_Product().getName());
						putAwayLabour.setQuantity(piProductLabel.getquantity().intValue());

						int locatorId = 0;
						String locatorName = "";
						int warehouseId = piProductLabel.getM_Locator().getM_Warehouse_ID();

						try {
							MLocator suggestedLocator = getSuggestedLocatorForProduct(ctx,
									piProductLabel.getM_Product_ID(), warehouseId, clientId, trxName);

							if (suggestedLocator != null) {
								locatorId = suggestedLocator.getM_Locator_ID();
								locatorName = suggestedLocator.getValue();
							} else {

								if (mLocatorArray == null) {
									MWarehouse mWarehouse = new MWarehouse(ctx, warehouseId, trxName);
									mLocatorArray = mWarehouse.getLocators(true);
								}

								for (MLocator mLocator : mLocatorArray) {
									if (!mLocator.getValue().equalsIgnoreCase("Dispatch Locator")
											&& !mLocator.getValue().equalsIgnoreCase("Receiving Locator")) {

										Integer qtyOnHand = PipraUtils
												.getSumOfQntyonHandByLocator(mLocator.getM_Locator_ID(), clientId);

										if (locatorId == 0) {
											locatorId = mLocator.getM_Locator_ID();
											locatorName = mLocator.getValue();
										}

										if (qtyOnHand <= 0) {
											locatorId = mLocator.getM_Locator_ID();
											locatorName = mLocator.getValue();
											break;
										}
									}
								}
							}

						} catch (Exception e) {
							System.err.println("Error in suggested locator logic: " + e.getMessage());
							e.printStackTrace();

							if (mLocatorArray == null) {
								MWarehouse mWarehouse = new MWarehouse(ctx, warehouseId, trxName);
								mLocatorArray = mWarehouse.getLocators(true);
							}

							for (MLocator mLocator : mLocatorArray) {
								if (!mLocator.getValue().equalsIgnoreCase("Dispatch Locator")
										&& !mLocator.getValue().equalsIgnoreCase("Receiving Locator")) {

									Integer qtyOnHand = PipraUtils
											.getSumOfQntyonHandByLocator(mLocator.getM_Locator_ID(), clientId);

									if (locatorId == 0) {
										locatorId = mLocator.getM_Locator_ID();
										locatorName = mLocator.getValue();
									}

									if (qtyOnHand <= 0) {
										locatorId = mLocator.getM_Locator_ID();
										locatorName = mLocator.getValue();
										break;
									}
								}
							}
						}

						putAwayLabour.setLocatorId(locatorId);
						putAwayLabour.setLocatorName(locatorName);
						putAwayLabour.setWarehouseId(piProductLabel.getM_Locator().getM_Warehouse_ID());
						putAwayLabour.setWarehouseName(piProductLabel.getM_Locator().getM_Warehouse().getValue());

						count++;
					}
				}
			}

			putAwayLabourResponse.setCount(count);
			putAwayLabourResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			putAwayLabourResponse.setIsError(true);
			putAwayLabourResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	private MLocator getSuggestedLocatorForProduct(Properties ctx, int productId, int warehouseId, int clientId,
			String trxName) {

		try {
			MProduct product = new MProduct(ctx, productId, trxName);
			int categoryId = product.getM_Product_Category_ID();

			int locatorTypeId = getConfiguredLocatorType(categoryId, clientId);

			if (locatorTypeId > 0) {
				List<MLocator> locators = getLocatorsByLocatorType(ctx, locatorTypeId, warehouseId, clientId, trxName);

				return findBestLocator(locators, clientId);
			} else {
				
				int defaultLocatorTypeId = getDefaultLocatorType(clientId);

				if (defaultLocatorTypeId > 0) {
					List<MLocator> locators = getLocatorsByLocatorType(ctx, defaultLocatorTypeId, warehouseId, clientId,
							trxName);
					return findBestLocator(locators, clientId);
				}
			}

		} catch (Exception e) {
			System.err.println("Error in getSuggestedLocatorForProduct: " + e.getMessage());
			e.printStackTrace();
		}

		return null;
	}

	private int getConfiguredLocatorType(int categoryId, int clientId) {

		String sql = "SELECT M_LocatorType_ID " + "FROM adempiere.pi_Locator_Product "
				+ "WHERE M_Product_Category_ID = ? " + "  AND AD_Client_ID = ? " + "  AND IsActive = 'Y' " + "LIMIT 1";

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int locatorTypeId = 0;

		try {
			pstmt = DB.prepareStatement(sql, null);
			pstmt.setInt(1, categoryId);
			pstmt.setInt(2, clientId);

			rs = pstmt.executeQuery();

			if (rs.next()) {
				locatorTypeId = rs.getInt("M_LocatorType_ID");
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			DB.close(rs, pstmt);
		}

		return locatorTypeId;
	}

	private List<MLocator> getLocatorsByLocatorType(Properties ctx, int locatorTypeId, int warehouseId, int clientId,
			String trxName) {

		List<MLocator> locators = new ArrayList<>();

		String sql = "SELECT M_Locator_ID " + "FROM adempiere.M_Locator " + "WHERE M_LocatorType_ID = ? "
				+ "  AND M_Warehouse_ID = ? " + "  AND AD_Client_ID = ? " + "  AND IsActive = 'Y' "
				+ "  AND Value NOT IN ('Dispatch Locator', 'Receiving Locator') " + "ORDER BY Value";

		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			pstmt = DB.prepareStatement(sql, trxName);
			pstmt.setInt(1, locatorTypeId);
			pstmt.setInt(2, warehouseId);
			pstmt.setInt(3, clientId);

			rs = pstmt.executeQuery();

			while (rs.next()) {
				int locatorId = rs.getInt("M_Locator_ID");
				MLocator locator = new MLocator(ctx, locatorId, trxName);
				locators.add(locator);
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			DB.close(rs, pstmt);
		}

		return locators;
	}

	private MLocator findBestLocator(List<MLocator> locators, int clientId) {

		if (locators == null || locators.isEmpty()) {
			return null;
		}

		MLocator bestLocator = null;
		int minQty = Integer.MAX_VALUE;

		for (MLocator locator : locators) {

			int qtyOnHand = PipraUtils.getSumOfQntyonHandByLocator(locator.getM_Locator_ID(), clientId);

			if (qtyOnHand == 0) {
				return locator;
			}

			if (qtyOnHand < minQty) {
				minQty = qtyOnHand;
				bestLocator = locator;
			}
		}

		return bestLocator;
	}

	private int getDefaultLocatorType(int clientId) {

		String sql = "SELECT M_LocatorType_ID " + "FROM adempiere.M_LocatorType " + "WHERE AD_Client_ID = ? "
				+ "  AND IsActive = 'Y' " + "  AND name = 'Default' " + "LIMIT 1";

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		int locatorTypeId = 0;

		try {
			pstmt = DB.prepareStatement(sql, null);
			pstmt.setInt(1, clientId);

			rs = pstmt.executeQuery();

			if (rs.next()) {
				locatorTypeId = rs.getInt("M_LocatorType_ID");
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			DB.close(rs, pstmt);
		}

		return locatorTypeId;
	}

	@Override
	public StandardResponseDocument createShipmentReceiptConfirmByScan(ShipmentReceiptByScanRequestDocument request) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = response.addNewStandardResponse();
		ShipmentReceiptByScanRequest requestData = request.getShipmentReceiptByScanRequest();
		ADLoginRequest loginReq = requestData.getADLoginRequest();
		String serviceType = requestData.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "mrFailed", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("mrFailed")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			SReceiptLine[] sReceiptLineArray = requestData.getSReceiptLineArray();

			LinkedHashMap<Integer, LinkedHashMap<Integer, Integer>> mInoutMap = new LinkedHashMap<Integer, LinkedHashMap<Integer, Integer>>();
			if (sReceiptLineArray.length != 0) {

				/* Internal move to returns Locators */
				MMovement mMovement = new MMovement(ctx, 0, trxName);
				mMovement.setIsActive(true);
				mMovement.setDescription(null);
				mMovement.setApprovalAmt(BigDecimal.valueOf(0));
				mMovement.setChargeAmt(BigDecimal.valueOf(0));
				mMovement.setFreightAmt(BigDecimal.valueOf(0));
				mMovement.setAD_Org_ID(loginReq.getOrgID());
				mMovement.saveEx();

				/* check atleast one product moved */
				boolean inventoryMoved = false;

				for (SReceiptLine sReceiptLine : sReceiptLineArray) {
					PO po = PiProductLabel.getPiProductLabelById("labelUUId", sReceiptLine.getProductLabelUUId(), ctx,
							trxName, false);
					PiProductLabel piProductLabel = new PiProductLabel(ctx, po.get_ID(), trxName);

					MLocator mLocator = PipraUtils.getLocatorForWarehouseByName(ctx, trxName,
							piProductLabel.getM_Locator().getM_Warehouse_ID(), "Returns Locator");
					if (mLocator == null || mLocator.getM_Locator_ID() == 0) {
						standardResponse.setIsError(true);
						standardResponse.setError("Returns Locator not found for Warehouse : "
								+ piProductLabel.getM_Locator().getM_Warehouse_ID() + "");
						return response;
					}

					if (piProductLabel.qcpassed() == false)
						break;

					Set<Integer> mInoutMapKeys = mInoutMap.keySet();
					boolean flag = false;
					for (Integer minoutId : mInoutMapKeys) {
						if (minoutId == piProductLabel.getM_InOutLine().getM_InOut_ID()) {
							LinkedHashMap<Integer, Integer> lineIdAndQntyMap = mInoutMap.get(minoutId);
							Set<Integer> lineIdAndQntyMapKeys = lineIdAndQntyMap.keySet();
							boolean innerFlag = false;
							for (Integer mInoutlineId : lineIdAndQntyMapKeys) {
								if (mInoutlineId == piProductLabel.getM_InOutLine_ID()) {
									lineIdAndQntyMap.put(mInoutlineId, lineIdAndQntyMap.get(mInoutlineId)
											+ piProductLabel.getquantity().intValue());
									innerFlag = true;
									break;
								}
							}
							if (!innerFlag) {
								lineIdAndQntyMap.put(piProductLabel.getM_InOutLine_ID(),
										piProductLabel.getquantity().intValue());
								mInoutMap.put(minoutId, lineIdAndQntyMap);
							}
							flag = true;
							break;
						}
					}
					if (!flag) {
						LinkedHashMap<Integer, Integer> lineIdAndQntyMap = new LinkedHashMap<Integer, Integer>();
						lineIdAndQntyMap.put(piProductLabel.getM_InOutLine_ID(),
								piProductLabel.getquantity().intValue());
						mInoutMap.put(piProductLabel.getM_InOutLine().getM_InOut_ID(), lineIdAndQntyMap);
					}

					moveInventory(ctx, trxName, mMovement, loginReq, piProductLabel.getC_OrderLine_ID(),
							piProductLabel.getquantity(), piProductLabel.getM_Product_ID(),
							piProductLabel.getM_Locator_ID(), mLocator.getM_Locator_ID());

					piProductLabel.setQcpassed(false);
					piProductLabel.setM_Locator_ID(mLocator.getM_Locator_ID());
					piProductLabel.saveEx();

					inventoryMoved = true;
				}

				if (inventoryMoved) {
					mMovement.setDocStatus(DocAction.ACTION_Complete);
					mMovement.setDocAction(DocAction.ACTION_Close);
					mMovement.setPosted(true);
					mMovement.setProcessed(true);
					mMovement.setIsApproved(true);
					mMovement.completeIt();
					mMovement.saveEx();
				} else
					mMovement.deleteEx(true);

			}

			Set<Integer> mInoutMapKeys = mInoutMap.keySet();
			for (Integer mInoutId : mInoutMapKeys) {
				MTable table = MTable.get(ctx, "m_inout");
				PO po = table.getPO(mInoutId, trx.getTrxName());
				if (po == null || po.get_ID() == 0) {
					break;
				}
				MInOut mInOut = (MInOut) po;
				MInOutConfirm mInOutConfirm = new MInOutConfirm(mInOut, "PC");
				mInOutConfirm.setDocStatus(DocAction.STATUS_Drafted);
				mInOutConfirm.saveEx();

				LinkedHashMap<Integer, Integer> lineIdAndQntyMap = mInoutMap.get(mInoutId);
				MInOutLine[] lines = mInOut.getLines(false);
				for (MInOutLine line : lines) {
					MInOutLineConfirm lineConfirm = new MInOutLineConfirm(mInOutConfirm);
					lineConfirm.setM_InOutLine_ID(line.get_ID());
					lineConfirm.setTargetQty(line.getMovementQty());
					lineConfirm.setConfirmedQty(line.getMovementQty());
					lineConfirm.saveEx();

					Set<Integer> lineIdAndQntyMapKeys = lineIdAndQntyMap.keySet();
					for (Integer mInoutlineId : lineIdAndQntyMapKeys) {
						if (mInoutlineId == line.get_ID()) {
							MInOutLine_Custom lineCustom = new MInOutLine_Custom(ctx, mInoutlineId, trxName);
							int failedQty = lineIdAndQntyMap.get(mInoutlineId) + lineCustom.getQCFailedQty().intValue();
							int confirmID = lineConfirm.get_ID();
							MInOutLineConfirm_Custom custom = new MInOutLineConfirm_Custom(ctx, confirmID,
									trx.getTrxName());
							BigDecimal failedB = new BigDecimal(failedQty);
							custom.processLine(false, "PC");
							custom.setQCFailedQty(failedB);
							custom.saveEx();
							lineConfirm.saveEx();
						}
					}
				}
				mInOutConfirm.setDescription(MInOutConfirm.COLUMNNAME_Description);
				mInOutConfirm.setProcessed(true);
				mInOutConfirm.setIsApproved(true);
				mInOutConfirm.setDocStatus(MInOutConfirm.DOCSTATUS_Completed);
				mInOutConfirm.setDocAction(MInOutConfirm.DOCACTION_Close);
				mInOutConfirm.saveEx();
				trx.commit();

			}
			standardResponse.setIsError(false);

		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public PickListLabourResponseDocument pickListLabour(PickListLabourRequestDocument pickListLabourRequest) {
		PickListLabourResponseDocument response = PickListLabourResponseDocument.Factory.newInstance();
		PickListLabourResponse pickListLabourResponse = response.addNewPickListLabourResponse();
		PickListLabourRequest request = pickListLabourRequest.getPickListLabourRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
//		String searchKey = request.getSearchKey();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "pickListLabour", serviceType);
			if (err != null && err.length() > 0) {
				pickListLabourResponse.setError(err);
				pickListLabourResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("pickListLabour")) {
				pickListLabourResponse.setIsError(true);
				pickListLabourResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			List<PO> poList = new Query(ctx, MLocator.Table_Name, "m_warehouse_id =? AND value = 'Dispatch Locator'",
					trxName).setParameters(loginReq.getWarehouseID()).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID)
					.list();
			MLocator mLocator = (MLocator) poList.get(0);

			String sql = "SELECT \n" + "    SUM(qtyordered) as totalQnty, \n"
					+ "    SUM(outstanding_qty) AS total_outstanding_qty, \n" + "    productId, \n" + "    value\n"
					+ "FROM (\n" + "    SELECT \n" + "        SUM(a.qtyordered) AS qtyordered,\n"
					+ "        SUM(COALESCE((\n" + "            SELECT SUM(c.qtyentered)\n"
					+ "            FROM m_inoutline c\n" + "            JOIN m_inout d ON d.m_inout_id = c.m_inout_id\n"
					+ "            WHERE c.c_orderline_id = a.c_orderline_id\n"
					+ "                AND d.issotrx = 'Y'\n" + "        ), 0)) AS total_qtyentered,\n"
					+ "        SUM(a.qtyordered) - SUM(COALESCE((\n" + "            SELECT SUM(c.qtyentered)\n"
					+ "            FROM m_inoutline c\n" + "            JOIN m_inout d ON d.m_inout_id = c.m_inout_id\n"
					+ "            WHERE c.c_orderline_id = a.c_orderline_id\n"
					+ "                AND d.DocStatus = 'CO' AND d.issotrx = 'Y'\n"
					+ "        ), 0)) AS outstanding_qty,\n" + "        e.m_product_id AS productId, \n"
					+ "        e.value\n" + "    FROM \n" + "        c_orderline a \n" + "    JOIN \n"
					+ "        c_order d ON d.c_order_id = a.c_order_id \n" + "    JOIN \n"
					+ "        m_product e ON e.m_product_id = a.m_product_id \n" + "    WHERE \n"
					+ "        d.ad_client_id = " + loginReq.getClientID() + "\n" + "        AND d.m_warehouse_id = "
					+ loginReq.getWarehouseID() + " \n" + "        AND d.putStatus = 'pick' \n"
					+ "        AND d.issotrx = 'Y' \n" + "        AND d.docstatus = 'CO'\n"
					+ "    GROUP BY e.m_product_id, e.value\n" + ") AS subquery\n" + "GROUP BY \n"
					+ "    productId, value\n" + "HAVING \n" + "    SUM(outstanding_qty) > 0\n" + "ORDER BY \n"
					+ "    productId;\n" + "";

			pstm = DB.prepareStatement(sql.toString(), null);
			rs = pstm.executeQuery();

			int count = 0;
			LinkedHashMap<Integer, Integer> qntyOnLocator = PiProductLabel
					.getAvailableLabelsByLocator(loginReq.getClientID(), mLocator.getM_Locator_ID());
			while (rs.next()) {
				int mProductId = rs.getInt("productId");

				String productName = rs.getString("value");
//					int totalQtyordered = rs.getInt("totalQnty");
				int remainQuantity = rs.getInt("total_outstanding_qty");

				int qntyOnHand = 0;
				if (qntyOnLocator.containsKey(mProductId))
					qntyOnHand = qntyOnLocator.get(mProductId);
				int qntyToPutBack = 0;
				if (qntyOnHand != 0 && remainQuantity > qntyOnHand)
					remainQuantity = remainQuantity - qntyOnHand;
				else if ((qntyOnHand != 0 && qntyOnHand > remainQuantity) || qntyOnHand == remainQuantity) {
					remainQuantity = 0;
					qntyToPutBack = remainQuantity;
				}

				if (remainQuantity > 0) {
					PickLabourLines line = pickListLabourResponse.addNewPickLabourLines();
					line.setProductId(mProductId);
					line.setProductName(productName);
					line.setQuantity(remainQuantity);

					pickDetailLabour(line, ctx, trxName, mLocator.getM_Warehouse_ID(), mProductId, remainQuantity);

					qntyOnLocator.put(mProductId, qntyToPutBack);
					count++;
				}

			}
			pickListLabourResponse.setWarehouseId(mLocator.getM_Warehouse_ID());
			pickListLabourResponse.setWarehouseName(mLocator.getM_Warehouse().getValue());
			pickListLabourResponse.setLineCount(count);
			pickListLabourResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			pickListLabourResponse.setIsError(true);
			pickListLabourResponse.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	public void pickDetailLabour(PickLabourLines pickLabourLines, Properties ctx, String trxName, int warehouseId,
			int productId, int quantity) {

		MStorageOnHand[] mStorageOnHandArray = MStorageOnHand.getWarehouse(ctx, warehouseId, productId, 0, null, true,
				true, 0, trxName, false, 0);
		boolean pickFlag = false;
		for (MStorageOnHand mStorageOnHand : mStorageOnHandArray) {
			PickLabourLines[] pickLabourLinesArray = pickLabourLines.getPickLabourLinesArray();
			boolean flag = false;

			for (PickLabourLines line : pickLabourLinesArray) {
				if (line.getLocatorId() == mStorageOnHand.getM_Locator_ID()) {
					int availableQty = Math.min(mStorageOnHand.getQtyOnHand().intValue(), quantity);
					line.setQuantity(line.getQuantity() + availableQty);
					quantity -= availableQty;
					flag = true;
					if (quantity <= 0) {
						pickFlag = true;
						break;
					}
					break;
				}
			}

			if (!flag && !mStorageOnHand.getM_Locator().getValue().equalsIgnoreCase("Dispatch Locator")
					&& !mStorageOnHand.getM_Locator().getValue().equalsIgnoreCase("Receiving Locator")) {
				PickLabourLines line = pickLabourLines.addNewPickLabourLines();
//				line.setProductId(mStorageOnHand.getM_Product_ID());
//				line.setProductName(mStorageOnHand.getM_Product().getValue());
				int availableQty = Math.min(mStorageOnHand.getQtyOnHand().intValue(), quantity);
				line.setQuantity(availableQty);
				quantity -= availableQty;
				line.setLocatorId(mStorageOnHand.getM_Locator_ID());
				line.setLocatorName(mStorageOnHand.getM_Locator().getValue());
//				line.setWarehouseId(mStorageOnHand.getM_Warehouse_ID());
//				line.setWarehouseName(mStorageOnHand.getM_Locator().getM_Warehouse().getValue());
				if (quantity <= 0) {
					pickFlag = true;
					break;
				}

			}

			if (pickFlag) {
				break;
			}
		}

	}

	@Override
	public PickDetailLabourResponseDocument pickDetailLabour(PickDetailLabourRequestDocument pickDetailLabourRequest) {
		PickDetailLabourResponseDocument pickDetailLabourResponse = PickDetailLabourResponseDocument.Factory
				.newInstance();
		PickDetailLabourResponse response = pickDetailLabourResponse.addNewPickDetailLabourResponse();
		PickDetailLabourRequest request = pickDetailLabourRequest.getPickDetailLabourRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int productId = request.getProductId();
		int quantity = request.getQuantity();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "pickDetailLabour", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return pickDetailLabourResponse;
			}

			if (!serviceType.equalsIgnoreCase("pickDetailLabour")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return pickDetailLabourResponse;
			}
			MProduct mProduct = new MProduct(ctx, productId, trxName);
			if (mProduct.getM_Product_ID() == 0) {
				response.setIsError(true);
				response.setError("Invalid Product ID " + productId + "");
				return pickDetailLabourResponse;
			}

			MStorageOnHand[] mStorageOnHandArray = MStorageOnHand.getWarehouse(ctx, loginReq.getWarehouseID(),
					productId, 0, null, true, true, 0, trxName, false, 0);
			boolean pickFlag = false;
			for (MStorageOnHand mStorageOnHand : mStorageOnHandArray) {
				PickLabourLines[] pickLabourLinesArray = response.getPickLabourLinesArray();
				boolean flag = false;

				for (PickLabourLines line : pickLabourLinesArray) {
					if (line.getLocatorId() == mStorageOnHand.getM_Locator_ID()) {
						int availableQty = Math.min(mStorageOnHand.getQtyOnHand().intValue(), quantity);
						line.setQuantity(line.getQuantity() + availableQty);
						quantity -= availableQty;
						flag = true;
						if (quantity <= 0) {
							pickFlag = true;
							break;
						}
						break;
					}
				}

				if (!flag && !mStorageOnHand.getM_Locator().getValue().equalsIgnoreCase("Dispatch Locator")
						&& !mStorageOnHand.getM_Locator().getValue().equalsIgnoreCase("Receiving Locator")) {
					PickLabourLines line = response.addNewPickLabourLines();
					line.setProductId(mStorageOnHand.getM_Product_ID());
					line.setProductName(mStorageOnHand.getM_Product().getValue());
					int availableQty = Math.min(mStorageOnHand.getQtyOnHand().intValue(), quantity);
					line.setQuantity(availableQty);
					quantity -= availableQty;
					line.setLocatorId(mStorageOnHand.getM_Locator_ID());
					line.setLocatorName(mStorageOnHand.getM_Locator().getValue());
					line.setWarehouseId(mStorageOnHand.getM_Warehouse_ID());
					line.setWarehouseName(mStorageOnHand.getM_Locator().getM_Warehouse().getValue());
					if (quantity <= 0) {
						pickFlag = true;
						break;
					}

				}

				if (pickFlag) {
					break;
				}
			}

			response.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			response.setIsError(true);
			response.setError(e.getMessage());
			return pickDetailLabourResponse;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return pickDetailLabourResponse;
	}

	private JSONObject getRemainQuantityForOrder(Properties ctx, String trxName, String cOrderId, String documentNo,
			int clientId, LinkedHashMap<Integer, LinkedHashMap<Integer, Integer>> pickedQuantity, int warehouseId) {
		JSONObject jsonObject = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			int quantityPicked = 0;
			int quantityTotal = 0;
			jsonObject = new JSONObject();

			String sql = "SELECT a.qtyordered as totalQnty, (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name\n"
					+ "FROM c_orderline a \n" + "JOIN c_order d ON d.c_order_id = a.c_order_id \n"
					+ "LEFT JOIN m_inout b ON a.c_order_id = b.c_order_id \n"
					+ "LEFT JOIN m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.c_orderline_id = a.c_orderline_id\n"
					+ "JOIN m_product e ON e.m_product_id = a.m_product_id \n" + "WHERE d.documentno = '" + documentNo
					+ "' AND d.ad_client_id = '" + clientId + "' AND a.c_order_id = (\n"
					+ "  SELECT c_order_id FROM c_order WHERE documentno = '" + documentNo + "' AND ad_client_id = '"
					+ clientId + "'\n" + ")\n"
					+ "GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id ORDER BY a.c_orderline_id;\n"
					+ "";

			pstm = DB.prepareStatement(sql.toString(), null);
			rs = pstm.executeQuery();
			while (rs.next()) {
				int totalQnty = rs.getInt("totalQnty");
				int outstandingQty = rs.getInt("outstanding_qty");
				int productId = rs.getInt("productId");

				LinkedHashMap<Integer, Integer> availableQnty = pickedQuantity.get(warehouseId);
				MOrder order = new MOrder(ctx, Integer.valueOf(cOrderId), trxName);
				MInOut[] mInout = order.getShipments();
				for (MInOut inout : mInout) {
					for (MInOutLine line : inout.getLines()) {
						if (line.getM_Product_ID() == productId) {
							if (!inout.getDocStatus().equalsIgnoreCase("CO"))
								for (Integer key : availableQnty.keySet()) {
									if (productId == key) {
										int qnty = availableQnty.get(key);
										availableQnty.put(key, qnty - line.getQtyEntered().intValue());
										break;
									}

								}
							totalQnty = totalQnty - line.getQtyEntered().intValue();
						}
					}
				}

				for (Integer key : availableQnty.keySet()) {
					if (productId == key) {
						int qnty = availableQnty.get(key);

						if (qnty >= outstandingQty) {
							quantityPicked += outstandingQty;
							availableQnty.put(key, qnty - outstandingQty);
						} else if (outstandingQty != 0 && qnty != 0) {
							quantityPicked += qnty;
							availableQnty.put(key, 0);
						}
						break;
					}
				}
				quantityTotal += totalQnty;

			}
			jsonObject.put("totalQnty", quantityTotal);
			jsonObject.put("pickedQnty", quantityPicked);

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			closeDbCon(pstm, rs);
		}
		return jsonObject;
	}

	private LinkedHashMap<Integer, Integer> getQntyPickedBySoList(int clientId, int wrehouseId, Properties ctx,
			String trxName, String orderDocumentNo, int roleId, String locatorName) {
		PreparedStatement pstm = null;
		ResultSet rs = null;
		LinkedHashMap<Integer, Integer> locatorStorage = null;
		try {

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(ctx);
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			rs = soListQuery(null, clientId, pstm, rs, "Asc", orgIds);
			List<PO> poList = new Query(ctx, MLocator.Table_Name, "m_warehouse_id =? AND value = '" + locatorName + "'",
					trxName).setParameters(wrehouseId).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID).list();
			MLocator mLocator = (MLocator) poList.get(0);
			locatorStorage = PiProductLabel.getAvailableLabelsByLocator(clientId, mLocator.getM_Locator_ID());
			Set<Integer> keys = locatorStorage.keySet();

			while (rs.next()) {
				String documentNo = rs.getString("Sales_Order");
				String sql = "SELECT a.qtyordered as totalQnty, (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name\n"
						+ "FROM c_orderline a \n" + "JOIN c_order d ON d.c_order_id = a.c_order_id \n"
						+ "LEFT JOIN m_inout b ON a.c_order_id = b.c_order_id \n"
						+ "LEFT JOIN m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.c_orderline_id = a.c_orderline_id\n"
						+ "JOIN m_product e ON e.m_product_id = a.m_product_id \n" + "WHERE d.documentno = '"
						+ documentNo + "' AND d.ad_client_id = '" + clientId + "' AND a.c_order_id = (\n"
						+ "  SELECT c_order_id FROM c_order WHERE documentno = '" + documentNo
						+ "' AND ad_client_id = '" + clientId + "'\n" + ")\n"
						+ "GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id ORDER BY a.c_orderline_id;\n"
						+ "";

				PreparedStatement innerPstm = DB.prepareStatement(sql.toString(), null);
				ResultSet innerRs = innerPstm.executeQuery();
				boolean flag = false;
				while (innerRs.next()) {
					if (documentNo.equalsIgnoreCase(orderDocumentNo)) {
						flag = true;
						break;
					}
					if (rs.getString("putStatus") != null && rs.getString("putStatus").equalsIgnoreCase("pick")) {
						int outstandingQty = innerRs.getInt("outstanding_qty");
						int productId = innerRs.getInt("productId");
						for (Integer key : keys) {
							if (productId == key) {
								int availableQnty = locatorStorage.get(key);
								if (availableQnty >= outstandingQty)
									locatorStorage.put(key, availableQnty - outstandingQty);
								else if (outstandingQty >= availableQnty)
									locatorStorage.put(key, 0);
								break;
							}
						}
//					break;
					}
				}
				innerPstm.close();
				innerRs.close();
				if (flag)
					break;

			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			closeDbCon(pstm, rs);
		}
		return locatorStorage;

	}

	@Override
	public StandardResponseDocument markSOReadyToPick(MarkSOToPickRequestDocument request) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = response.addNewStandardResponse();
		MarkSOToPickRequest markSOToPickRequest = request.getMarkSOToPickRequest();
		ADLoginRequest loginReq = markSOToPickRequest.getADLoginRequest();
		String serviceType = markSOToPickRequest.getServiceType();
		int cOrderId = markSOToPickRequest.getCOrderId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "markSOReadyToPick", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("markSOReadyToPick")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}
			COrder_Custom cOrder = new COrder_Custom(ctx, cOrderId, trxName);
			if (cOrder.getC_Order_ID() == 0) {
				standardResponse.setIsError(true);
				standardResponse.setError("Invalid Order ID " + cOrderId + "");
				return response;
			}
			cOrder.setPutStatus("pick");
			cOrder.saveEx();
			standardResponse.setIsError(false);

			Map<String, String> data = new HashMap<>();
			data.put("recordId", String.valueOf(cOrder.getC_Order_ID()));
			data.put("documentNo", String.valueOf(cOrder.getDocumentNo()));

//			data.put("path1", "/labour_pick_screen");

//			PipraUtils.sendNotificationAsync("Supervisor", cOrder.get_Table_ID(), cOrder.getC_Order_ID(), ctx, trxName,
//					"PickList Updated", "Sales Order " + cOrder.getDocumentNo() + " Marked To PickList",
//					cOrder.get_TableName(), data, loginReq.getClientID(), "MarkedSalesOrderReadyToPick");

			data.put("path1", "/labour_pick_screen");

			PipraUtils.sendNotificationAsyncnew("Labour", cOrder.get_Table_ID(), cOrder.getC_Order_ID(), ctx, trxName,
					"PickList Updated", "Sales Order " + cOrder.getDocumentNo() + " Marked To PickList",
					cOrder.get_TableName(), data,
					loginReq.getClientID(), "MarkedSalesOrderReadyToPick");

			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public ShipperListResponseDocument getShipperForClient(ShipperListRequestDocument shipperListRequestDocument) {
		ShipperListResponseDocument shipperListResponseDocument = ShipperListResponseDocument.Factory.newInstance();
		ShipperListResponse response = shipperListResponseDocument.addNewShipperListResponse();
		ShipperListRequest request = shipperListRequestDocument.getShipperListRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int clientId = loginReq.getClientID();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

			String err = login(loginReq, webServiceName, "getShipperForClient", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return shipperListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("getShipperForClient")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return shipperListResponseDocument;
			}

			response = addDeliveryType(response, "shipper", true);
			response = addDeliveryType(response, "pickup", false);
			response = addDeliveryType(response, "delivery", false);

			List<PO> poList = PipraUtils.getShipperListForClient(ctx, clientId);
			if (poList != null) {
				for (PO po : poList) {
					MShipper mShipper = (MShipper) po;
					ShipperList shipperList = response.addNewShipperList();
					shipperList.setShipperName(mShipper.getName());
					shipperList.setShipperId(mShipper.getM_Shipper_ID());
				}
			}

			trx.commit();
		} catch (Exception e) {
			response.setError(e.getMessage());
			response.setIsError(true);
			return shipperListResponseDocument;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return shipperListResponseDocument;
	}

	private ShipperListResponse addDeliveryType(ShipperListResponse response, String deliveryType,
			boolean showDetails) {
		DeliveryTypes deliveryTypes = response.addNewDeliveryTypes();
		deliveryTypes.setDeliveryType(deliveryType);
		deliveryTypes.setShowDetails(showDetails);
		return response;
	}

	@Override
	public StandardResponseDocument updateShipmentCustomer(UpdateShipmentRequestDocument request) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = response.addNewStandardResponse();
		UpdateShipmentRequest updateShipmentRequest = request.getUpdateShipmentRequest();
		ADLoginRequest loginReq = updateShipmentRequest.getADLoginRequest();
		String serviceType = updateShipmentRequest.getServiceType();
		int mInoutId = updateShipmentRequest.getMInoutId();
		String deliveryType = updateShipmentRequest.getDeliveryType();
		int shipperId = updateShipmentRequest.getShipperId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "updateShipmentCustomer", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("updateShipmentCustomer")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}
			MInOut_Custom mInout = new MInOut_Custom(ctx, mInoutId, trxName);
			if (mInout.getM_InOut_ID() == 0) {
				standardResponse.setIsError(true);
				standardResponse.setError("Invalid mInout ID " + mInoutId + "");
				return response;
			}

			if (deliveryType.equalsIgnoreCase("shipper")) {
				mInout.setDeliveryViaRule("S");
				mInout.setM_Shipper_ID(shipperId);
			} else if (deliveryType.equalsIgnoreCase("pickup"))
				mInout.setDeliveryViaRule("P");
			else if (deliveryType.equalsIgnoreCase("delivery"))
				mInout.setDeliveryViaRule("D");
			mInout.saveEx();
			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	private void closeDbCon(PreparedStatement pstm, ResultSet rs) {
		try {
			if (pstm != null)
				pstm.close();
			if (rs != null)
				rs.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public StandardResponseDocument getIsUserActive(GetIsUserActiveRequestDocument request) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = response.addNewStandardResponse();
		GetIsUserActiveRequest getIsUserActiveRequest = request.getGetIsUserActiveRequest();
		String userName = getIsUserActiveRequest.getUserName();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

			PO po = new Query(ctx, MUser.Table_Name, "name =?", trxName).setParameters(userName)
					.setOrderBy(MUser.COLUMNNAME_AD_User_ID).firstOnly();

			if (po == null || po.get_ID() == 0) {
				standardResponse.setIsError(true);
				standardResponse.setError("User with name " + userName + " does not exist");
				return response;
			}
			MUser mUser = (MUser) po;
			if (mUser.isActive())
				standardResponse.setIsError(false);
			else
				standardResponse.setIsError(true);

			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public Response createNotice(List<File> files, String user, String pass, int clientId, int orgId, int roleId,
			int warehouseId, String message, String textMessage, String description, String fileName) {
		String serviceType = "createNotice";
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

			ADLoginRequest loginReq = ADLoginRequest.Factory.newInstance();
			loginReq.setUser(user);
			loginReq.setPass(pass);
			loginReq.setLang("112");
			loginReq.setClientID(clientId);
			loginReq.setRoleID(roleId);
			loginReq.setOrgID(orgId);
			loginReq.setWarehouseID(warehouseId);
			loginReq.setStage(0);

			String err = login(loginReq, webServiceName, "createNotice", serviceType);
			if (err != null && err.length() > 0)
				return Response.status(Response.Status.BAD_REQUEST).entity(err).build();

			if (!serviceType.equalsIgnoreCase("createNotice"))
				return Response.status(Response.Status.BAD_REQUEST)
						.entity("Service type " + serviceType + " not configured").build();

			MNote mNoteS = new MNote(ctx, 0, trxName);
			mNoteS.setAD_Message_ID(message);
			mNoteS.setTextMsg(textMessage);
			mNoteS.setDescription(description);
			mNoteS.setReference(message);
			mNoteS.setAD_User_ID(Env.getAD_User_ID(ctx));
			mNoteS.setProcessed(true);
			if (mNoteS.getAD_Message_ID() == 240) {
				MMessage mMessage = new MMessage(ctx, 0, trxName);
				mMessage.setValue(message);
				mMessage.setMsgText(message);
				mMessage.setMsgType("M");
				mMessage.saveEx();

				mNoteS.setAD_Message_ID(mMessage.getAD_Message_ID());
			}

			mNoteS.saveEx();

			MAttachment mAttachment = new MAttachment(ctx, 0, trxName);
			mAttachment.setAD_Table_ID(mNoteS.get_Table_ID());
			mAttachment.setRecord_ID(mNoteS.getAD_Note_ID());

//			int fileIndesx = 0;
			if (files != null && files.size() != 0)
				for (File file : files) {
					mAttachment.addEntry(fileName, convertFileToByteArray(file));
					break;
				}
			MStorageProvider newProvider = MStorageProvider.get(ctx, 0);

			IAttachmentStore prov = newProvider.getAttachmentStore();
			mAttachment.saveEx();
			if (prov != null)
				prov.save(mAttachment, newProvider);

			trx.commit();

			MUser mUser = new Query(Env.getCtx(), MUser.Table_Name, "AD_Client_ID=? AND Name=?", null)
					.setParameters(clientId, user).first();

			if (description.equalsIgnoreCase("UNAUTHORISED")) {
				List<PO> poList = new Query(Env.getCtx(), "pi_userToken", "AD_Client_ID=? AND AD_User_ID=?", null)
						.setParameters(clientId, mUser.getAD_User_ID()).list();

				for (PO po : poList) {
					PiUserToken userToken = new PiUserToken(ctx, po.get_ID(), trxName);
					String deviceToken = userToken.getdevicetoken();

					if (deviceToken != null && !deviceToken.isEmpty()) {
						Map<String, String> data = new HashMap<>();
						data.put("noticeId", String.valueOf(mNoteS.get_ID()));

						FCMService.sendFCMMessage(deviceToken, mNoteS.getTextMsg(), // title
								mNoteS.getDescription(), // body
								null, // serverKeyPath
								data);
					}
				}

//				PO po1 = new Query(Env.getCtx(), "pi_userToken", "AD_Client_Id=? AND ad_user_id=?", null)
//						.setParameters(clientId,mUser.getAD_User_ID()).first();
//				PiUserToken userToken = new PiUserToken(ctx, po1.get_ID(), trxName);
//				String deviceToken = userToken.getdevicetoken();
//				String serverKeyPath = null;
//
//				Map<String, String> data = new HashMap<>();
//				data.put("noticeId", String.valueOf(mNoteS.get_ID()));
//
//				FCMService.sendFCMMessage(deviceToken, mNoteS.getTextMsg(), // title
//						mNoteS.getDescription(),
//						serverKeyPath, data);
			}

		} catch (Exception e) {
			return Response.status(Response.Status.BAD_REQUEST).entity(e.getMessage()).build();
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return Response.status(Response.Status.OK).entity("Notice Created Successfully").build();

	}

	@Override
	public StandardResponseDocument createRoi(CreateRoiDocument request) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();

		StandardResponse standardResponse = response.addNewStandardResponse();
		org.idempiere.adInterface.x10.CreateRoi createRoi = request.getCreateRoi();
		ADLoginRequest loginReq = createRoi.getADLoginRequest();
		String serviceType = "createNotice";
		Trx trx = null;
		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "createNotice", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("createNotice")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			String msg = createRoiInServer(createRoi.getCoordinates());
			if(msg != null) {
				standardResponse.setIsError(true);
				standardResponse.setError(msg);
				return response;
			}

			standardResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			e.printStackTrace();
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			getCompiereService().disconnect();
			trx.close();
		}
		return response;}
	
	private String createRoiInServer(String coordinates) {
		String url = "https://dev.warepro.in/getRoi";

		try {
			URL obj = new URL(url);
			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
			con.setRequestMethod("POST");
			con.setRequestProperty("Content-Type", "application/json");
			con.setConnectTimeout(2000);
			con.setReadTimeout(2000);
			con.setDoOutput(true);

			try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
				wr.writeBytes(coordinates);
				wr.flush();
			}
			int responseCode = con.getResponseCode();
			System.out.println("Response Code: " + responseCode);

			if (responseCode == HttpURLConnection.HTTP_OK) {
				BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
				String inputLine;
				StringBuilder response = new StringBuilder();
				while ((inputLine = in.readLine()) != null) {
					response.append(inputLine);
				}
				in.close();
				return null;
			} else {
				BufferedReader errorReader = new BufferedReader(new InputStreamReader(con.getErrorStream()));
				StringBuilder errorResponse = new StringBuilder();
				String errorLine;
				while ((errorLine = errorReader.readLine()) != null) {
					errorResponse.append(errorLine);
				}
				errorReader.close();
				return "Error Response: " + errorResponse.toString();
			}

		} catch (Exception e) {
			return null;
		}
	}

//	@Override
//	public StandardResponseDocument createNotice(CreateNoticeRequestDocument request) {
//		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
//		StandardResponse standardResponse = response.addNewStandardResponse();
//		CreateNoticeRequest createNoticeRequest = request.getCreateNoticeRequest();
//		ADLoginRequest loginReq = createNoticeRequest.getADLoginRequest();
//		String serviceType = createNoticeRequest.getServiceType();
//		Trx trx = null;
//		try {
//			CompiereService m_cs = getCompiereService();
//			Properties ctx = m_cs.getCtx();
//			String trxName = Trx.createTrxName(getClass().getName() + "_");
//			trx = Trx.get(trxName, true);
//			trx.start();
//			getCompiereService().connect();
//			String err = login(loginReq, webServiceName, "createNotice", serviceType);
//			if (err != null && err.length() > 0) {
//				standardResponse.setError(err);
//				standardResponse.setIsError(true);
//				return response;
//			}
//
//			if (!serviceType.equalsIgnoreCase("createNotice")) {
//				standardResponse.setIsError(true);
//				standardResponse.setError("Service type " + serviceType + " not configured");
//				return response;
//			}
//
//			MNote mNoteS = new MNote(ctx, 0, trxName);
//			mNoteS.setAD_Message_ID(createNoticeRequest.getMessage());
//			mNoteS.setTextMsg(createNoticeRequest.getTextMessage());
//			mNoteS.setDescription(createNoticeRequest.getDescription());
//			mNoteS.setReference(createNoticeRequest.getReference());
//			mNoteS.setAD_User_ID(Env.getAD_User_ID(ctx));
//			mNoteS.setProcessed(true);
//			if (mNoteS.getAD_Message_ID() == 240) {
//				MMessage mMessage = new MMessage(ctx, 0, trxName);
//				mMessage.setValue(createNoticeRequest.getMessage());
//				mMessage.setMsgText(createNoticeRequest.getMessage());
//				mMessage.setMsgType("M");
//				mMessage.saveEx();
//
//				mNoteS.setAD_Message_ID(mMessage.getAD_Message_ID());
//			}
//
//			mNoteS.saveEx();
//
//			MAttachment mAttachment = new MAttachment(ctx, 0, trxName);
//			mAttachment.setAD_Table_ID(mNoteS.get_Table_ID());
//			mAttachment.setRecord_ID(mNoteS.getAD_Note_ID());
//			mAttachment.addEntry(createNoticeRequest.getFileName(), createNoticeRequest.getFileData());
//
//			MStorageProvider newProvider = MStorageProvider.get(ctx, 0);
//
//			IAttachmentStore prov = newProvider.getAttachmentStore();
//			mAttachment.saveEx();
//			if (prov != null)
//				prov.save(mAttachment, newProvider);
//
//			standardResponse.setIsError(false);
//			trx.commit();
//		} catch (Exception e) {
//			e.printStackTrace();
//			standardResponse.setIsError(true);
//			standardResponse.setError(e.getMessage());
//			return response;
//		} finally {
//			getCompiereService().disconnect();
//			trx.close();
//		}
//		return response;
//	}

	@Override
	public PutAwayDetailResponseDocument putAwayDetail(PutAwayDetailRequestDocument request) {

		PutAwayDetailResponseDocument response = PutAwayDetailResponseDocument.Factory.newInstance();
		PutAwayDetailResponse putAwayDetailResponse = response.addNewPutAwayDetailResponse();
		PutAwayDetailRequest putAwayDetailRequest = request.getPutAwayDetailRequest();
		ADLoginRequest loginReq = putAwayDetailRequest.getADLoginRequest();
		String serviceType = putAwayDetailRequest.getServiceType();
		String documentNumber = putAwayDetailRequest.getDocumentNo();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "putAwayDetail", serviceType);
			if (err != null && err.length() > 0) {
				putAwayDetailResponse.setError(err);
				putAwayDetailResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("putAwayDetail")) {
				putAwayDetailResponse.setIsError(true);
				putAwayDetailResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			String query = "SELECT\n" + "    DISTINCT(po.documentno) AS documentNo,\n" + "    bp.name AS Supplier,\n"
					+ "    po.m_inout_id AS mInoutID,\n" + "    TO_CHAR(po.dateordered, 'DD/MM/YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name, wh.m_warehouse_id,\n" + "    po.description,\n"
					+ "    po.created,\n" + "    po.m_inout_id,\n" + "	co.documentno as orderDocumentno\n"
					+ "FROM m_inout po\n" + "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "LEFT JOIN c_order co on co.c_order_id = po.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n" + "WHERE po.ad_client_id = "
					+ loginReq.getClientID() + " AND po.issotrx = 'N' AND po.documentno ='" + documentNumber + "';";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String documentNo = rs.getString("documentNo");
				int mInoutID = rs.getInt("mInoutID");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String orderDocumentno = rs.getString("orderDocumentno") == null ? "" : rs.getString("orderDocumentno");
//				String orderDocumentno = rs.getString("orderDocumentno");
				String warehouseName = rs.getString("Warehouse_Name");
				int mWarehouseId = rs.getInt("m_warehouse_id");
				String description = rs.getString("description");
				putAwayDetailResponse.setDocumentNo(documentNo);
				putAwayDetailResponse.setMInoutID(mInoutID);
				putAwayDetailResponse.setSupplier(supplier);
				putAwayDetailResponse.setOrderDate(date);
				putAwayDetailResponse.setWarehouseName(warehouseName);
				putAwayDetailResponse.setWarehouseId(mWarehouseId);
				putAwayDetailResponse.setOrderDocumentno(orderDocumentno);
				if (description == null)
					putAwayDetailResponse.setDescription("");
				else
					putAwayDetailResponse.setDescription(description);
			}

			List<PO> poList = new ArrayList<PO>();
			MLocator mLocator = PipraUtils.getLocatorForWarehouseByName(ctx, trxName,
					putAwayDetailResponse.getWarehouseId(), "Receiving Locator");
			MInOut_Custom mInout = new MInOut_Custom(ctx, putAwayDetailResponse.getMInoutID(), trxName);
			for (MInOutLine line : mInout.getLines()) {
				poList.addAll(PiProductLabel.getProductLabelForInoutLineAndLocator(mLocator.getM_Locator_ID(),
						line.getM_InOutLine_ID(), ctx, trxName));
			}

			for (PO po : poList) {
				PiProductLabel piProductLabel = new PiProductLabel(ctx, po.get_ID(), trxName);

				PutAwayDetail[] list = putAwayDetailResponse.getPutAwayDetailArray();
				boolean flag = false;
				for (PutAwayDetail detail : list) {
					if (detail.getMInoutLineId() == piProductLabel.getM_InOutLine_ID()) {
						detail.setQuantityInRecevingLocator(
								detail.getQuantityInRecevingLocator() + piProductLabel.getquantity().intValue());
						flag = true;
						break;
					}
				}
				if (!flag) {
					PutAwayDetail putAwayDetail = putAwayDetailResponse.addNewPutAwayDetail();
					putAwayDetail.setProductId(piProductLabel.getM_Product_ID());
					putAwayDetail.setProductName(piProductLabel.getM_Product().getValue());
					putAwayDetail.setCOrderlineId(piProductLabel.getC_OrderLine_ID());
					putAwayDetail.setMInoutLineId(piProductLabel.getM_InOutLine_ID());
					putAwayDetail.setQuantityInRecevingLocator(piProductLabel.getquantity().intValue());
					MInOutLine_Custom lineCustom = new MInOutLine_Custom(ctx, piProductLabel.getM_InOutLine_ID(),
							trxName);
					putAwayDetail.setTotalQuantity(piProductLabel.getM_InOutLine().getQtyEntered().intValue()
							- lineCustom.getQCFailedQty().intValue());
				}

			}

			putAwayDetailResponse.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			putAwayDetailResponse.setIsError(true);
			putAwayDetailResponse.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public GetMRComponentsResponseDocument getMrComponents(GetMRComponentsRequestDocument req) {

		GetMRComponentsResponseDocument response = GetMRComponentsResponseDocument.Factory.newInstance();
		GetMRComponentsResponse resp = response.addNewGetMRComponentsResponse();
		GetMRComponentsRequest putAwayDetailRequest = req.getGetMRComponentsRequest();
		ADLoginRequest loginReq = putAwayDetailRequest.getADLoginRequest();
		String serviceType = putAwayDetailRequest.getServiceType();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "getMrComponents", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("getMrComponents")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}
			int clientId = loginReq.getClientID();
			int orgId = loginReq.getOrgID();

			List<PO> poList = PipraUtils.getWarehousesByClientOrg(ctx, trxName, clientId, orgId);
			for (PO po : poList) {
				MWarehouse wh = new MWarehouse(ctx, po.get_ID(), trxName);
				Warehouse warehouse = resp.addNewWarehouse();
				warehouse.setWarehouseId(String.valueOf(wh.get_ID()));
				warehouse.setWarehouse(wh.getName());
				MLocator locator = MLocator.getDefault(wh);
				if (locator != null)
					warehouse.setDefaultLocatorId(locator.get_ID());

			}

			poList = PipraUtils.getProductsByClientOrg(ctx, trxName, clientId, orgId);
			for (PO po : poList) {
				MProduct prd = new MProduct(ctx, po.get_ID(), trxName);
				Product product = resp.addNewProduct();
				product.setProductId(prd.get_ID());
				product.setProductName(prd.getName());
				product.setUomId(prd.getC_UOM_ID());
				product.setUomName(prd.getC_UOM().getName());
			}

			poList = PipraUtils.getBPartnersByClientOrg(ctx, trxName, clientId, orgId);
			for (PO po : poList) {
				MBPartner bp = new MBPartner(ctx, po.get_ID(), trxName);
				BusinessPartner businessPartner = resp.addNewBusinessPartner();
				businessPartner.setBusinessPartnerID(bp.get_ID());
				businessPartner.setBusinessPartnerName(bp.getName());
				businessPartner.setAddress(bp.getPrimaryC_BPartner_Location().getName());
			}

			resp.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public StandardResponseDocument setDocAction(ModelSetDocActionRequestDocument req) {

		StandardResponseDocument res = StandardResponseDocument.Factory.newInstance();
		StandardResponse response = res.addNewStandardResponse();
		ModelSetDocActionRequest request = req.getModelSetDocActionRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		ModelSetDocAction modelSetDocAction = req.getModelSetDocActionRequest().getModelSetDocAction();
		String serviceType = modelSetDocAction.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

//			String err = login(loginReq, webServiceName, "CompleteOrder", serviceType);
			String err = login(loginReq, webServiceName, "mrList", "mrList");
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return res;
			}

			if (!serviceType.equalsIgnoreCase("CompleteOrder")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return res;
			}

			int clientId = loginReq.getClientID();

			trx = Trx.get(trxName, true);
			if (manageTrx)
				trx.setDisplayName(getClass().getName() + "_" + webServiceName + "_setDocAction");

			String tableName = modelSetDocAction.getTableName();

			int recordID = modelSetDocAction.getRecordID();

			String docAction = modelSetDocAction.getDocAction();
			response.setRecordID(recordID);

			// get the PO for the tablename and record ID
			MTable table = MTable.get(ctx, tableName);
			if (table == null) {

				response.setIsError(true);
				response.setError("No Table Found");
				return res;

			}

			PO po = table.getPO(recordID, trxName);
			if (po == null || po.get_ID() == 0) {
				response.setIsError(true);
				response.setError("No Record Found");
				return res;
			}

			String docStatus = po.get_ValueAsString("DocStatus");
			if (docStatus != null && docStatus.equalsIgnoreCase(docAction)) {
				response.setIsError(false);
				if (manageTrx && trx != null)
					trx.commit();
				return res;
			}

			// set explicitly the column DocAction to avoid automatic process of
			// default option
			po.set_ValueOfColumn("DocAction", docAction);
			if (!po.save()) {
				response.setIsError(true);
				response.setError("Cannot save before set docAction");
				return res;
			}

			// call process it
			try {
				if (!((org.compiere.process.DocAction) po).processIt(docAction)) {

					response.setIsError(true);
					response.setError("Cannot process docAction");
					return res;

				}
			} catch (Exception e) {
				response.setIsError(true);
				response.setError("Cannot process docAction");
				return res;
			}

			// close the trx
			if (!po.save()) {

				response.setIsError(true);
				response.setError("Cannot save before set docAction");
				return res;

			}

			if (manageTrx && !trx.commit()) {
				response.setIsError(true);
				response.setError("Cannot commit after docAction");
				return res;
			}

			// resp.setError("");
			response.setIsError(false);

			if (tableName.equalsIgnoreCase("m_inout")) {
				MInOut inout = new MInOut(ctx, recordID, trxName);
				Map<String, String> data = new HashMap<>();
				data.put("recordId", String.valueOf(recordID));
				data.put("documentNo", inout.getDocumentNo());
				if (!inout.isSOTrx()) {
					data.put("path1", "/put_away_screen");
					data.put("path2", "/put_away_detail_screen");

					PipraUtils.sendNotificationAsyncnew("Supervisor", inout.get_Table_ID(), recordID, ctx, trxName,
							"Products added for Put away", "New products ready for Put away " + recordID + "",
							inout.get_TableName(), data, clientId, "productsAddedForPutaway");

					data.put("path1", "/labour_put_away_screen");
					data.remove("path2");

					PipraUtils.sendNotificationAsyncnew("Labour", inout.get_Table_ID(), recordID, ctx, trxName,
							"Products added for Put away", "New products ready for Put away", inout.get_TableName(),
							data, clientId, "productsAddedForPutaway");
				} else {

					data.put("path1", "/dispatch_screen");
					data.put("path2", "/dispatch_detail_screen");

					PipraUtils.sendNotificationAsyncnew("Supervisor", inout.get_Table_ID(), recordID, ctx, trxName,
							"Products dispatched with shipment- " + inout.getDocumentNo() + "",
							"Products dispatched with Shipment No: " + inout.getDocumentNo() + " for Order - "
									+ inout.getC_Order().getDocumentNo() + "",
							inout.get_TableName(), data, clientId, "MarkedSalesOrderReadyToPick");
				}

			}
			return res;
		} finally {
			if (manageTrx && trx != null)
				trx.close();

			getCompiereService().disconnect();
		}
	}

	@Override
	public GetUsersListResponseDocument getUsersList(GetUsersListRequestDocument req) {

		GetUsersListResponseDocument response = GetUsersListResponseDocument.Factory.newInstance();
		GetUsersListResponse resp = response.addNewGetUsersListResponse();
		GetUsersListRequest getUsersListRequest = req.getGetUsersListRequest();
		ADLoginRequest loginReq = getUsersListRequest.getADLoginRequest();
		String serviceType = getUsersListRequest.getServiceType();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "getUsersList", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("getUsersList")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}
			int clientId = loginReq.getClientID();

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(loginReq.getRoleID(), ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			List<PO> poList = PipraUtils.getusersByClientOrg(ctx, trxName, clientId, orgIds);

			int tableId = 0;
			for (PO po : poList) {
				MUser mUser = new MUser(ctx, po.get_ID(), trxName);
				if (tableId == 0)
					tableId = mUser.get_Table_ID();
				UsersList user = resp.addNewUsersList();
				user.setUserId(mUser.get_ID());
				user.setUserName(mUser.getName());
			}
			resp.setTableId(tableId);
			resp.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	public StandardResponseDocument uploadfile(List<File> files, String user, String pass, int clientId, int orgId,
			int roleId, int warehouseId, int tableId, int userId) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse resp = response.addNewStandardResponse();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

			ADLoginRequest loginReq = ADLoginRequest.Factory.newInstance();
			loginReq.setUser(user);
			loginReq.setPass(pass);
			loginReq.setLang("112");
			loginReq.setClientID(clientId);
			loginReq.setRoleID(roleId);
			loginReq.setOrgID(orgId);
			loginReq.setWarehouseID(warehouseId);
			loginReq.setStage(0);

			String err = login(loginReq, webServiceName, "uploadfile", "uploadfile");
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}
//			MUser existingUser = new Query(ctx, MUser.Table_Name, "Name=? AND AD_Client_ID=?", trxName)
//	                .setParameters(userName,clientId)
//	                .first();
//
//	        if (existingUser != null) {
//	            resp.setError("User with name '" + userName + "' already exists.");
//	            resp.setIsError(true);
//	            return response;
//	        }
//	        
//	        MUser newUser = new MUser(ctx, 0, trxName);
//	        newUser.setAD_Org_ID(orgId);
//	        newUser.setName(userName);
//	        newUser.setDescription("Created via API");
//	        newUser.saveEx();
//	        trx.commit();
//	        
//	        int userId = newUser.get_ID();

			MAttachment attachment = new MAttachment(ctx, tableId, userId, trxName);
			attachment.setClientOrg(clientId, orgId);
			attachment.setTextMsg("User Photos Upload");

			MUser mUser = new MUser(ctx, userId, trxName);
			String userName = mUser.getName();

			List<BufferedImage> images = new ArrayList<>();
			int i = 1;
			for (File file : files) {

				byte[] data = convertFileToByteArray(file);

				attachment.addEntry(userName + i + ".png", data);
				BufferedImage img = ImageIO.read(new ByteArrayInputStream(data));

				if (img != null) {
					images.add(img);
				}
				i++;
			}

			boolean apiSuccess = pushFilebyAPI(userName, images);

			if (apiSuccess) {
				attachment.saveEx();
				trx.commit();
				resp.setIsError(false);
			} else {
				if (trx != null)
					trx.rollback();
				resp.setIsError(true);
				return response;
			}
		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			resp.setError(e.getMessage());
			resp.setIsError(true);
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	public static boolean pushFilebyAPI(String name, List<BufferedImage> files) {
		try {
			String url = "http://3.7.97.129:8000/upload_faces/";
//			 String url = "https://dev.warepro.in/upload/";
//			 String url ="https://dev.warepro.in/uploadFile/";
			String boundary = Long.toHexString(System.currentTimeMillis());
			String CRLF = "\r\n";

			URL obj = new URL(url);
			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
			con.setRequestMethod("POST");
			con.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
			con.setRequestProperty("Accept", "application/json");
			con.setDoOutput(true);

			// Prepare the request body
			try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
				// --- Send name ---
				wr.writeBytes("--" + boundary + CRLF);
				wr.writeBytes("Content-Disposition: form-data; name=\"name\"" + CRLF);
				wr.writeBytes(CRLF);
				wr.writeBytes(name + CRLF);

				// --- Send grayscale ---
				wr.writeBytes("--" + boundary + CRLF);
				wr.writeBytes("Content-Disposition: form-data; name=\"grayscale\"" + CRLF);
				wr.writeBytes(CRLF);
				wr.writeBytes("true" + CRLF);

				// --- Send all files ---
				for (int i = 0; i < files.size(); i++) {

					BufferedImage img = files.get(i);
					wr.writeBytes("--" + boundary + CRLF);
					wr.writeBytes("Content-Disposition: form-data; name=\"files\"; filename=\"" + name + (i + 1)
							+ ".png\"" + CRLF);
					wr.writeBytes("Content-Type: image/png" + CRLF);
					wr.writeBytes(CRLF);

					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					ImageIO.write(img, "png", baos);
					wr.write(baos.toByteArray());
					wr.writeBytes(CRLF);
				}

				wr.writeBytes("--" + boundary + "--" + CRLF);
				wr.flush();
			}

			int responseCode = con.getResponseCode();

			if (responseCode == HttpURLConnection.HTTP_OK) {
				try (BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()))) {
					String inputLine;
					StringBuilder response = new StringBuilder();
					while ((inputLine = in.readLine()) != null) {
						response.append(inputLine);
					}
					System.out.println("Response: " + response.toString());
					return true;
				}
			} else {
				try (BufferedReader errorReader = new BufferedReader(new InputStreamReader(con.getErrorStream()))) {
					StringBuilder errorResponse = new StringBuilder();
					String errorLine;
					while ((errorLine = errorReader.readLine()) != null) {
						errorResponse.append(errorLine);
					}
					System.err.println("Error Response: " + errorResponse.toString());
					return false;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

//	public static void pushFilebyAPI(String name, BufferedImage file) {
//		try {
//			String url = "http://3.7.97.129:8000/latest_frame";
////			String url = "https://dev.warepro.in/upload/";
//			String boundary = Long.toHexString(System.currentTimeMillis()); 
//			String CRLF = "\r\n";
//
//			// Open connection
//			URL obj = new URL(url);
//			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
//			con.setRequestMethod("POST");
//			con.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
//			con.setDoOutput(true);
//
//			// Prepare the request body
//			try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
//				// Send name part
//				wr.writeBytes("--" + boundary + CRLF);
//				wr.writeBytes("Content-Disposition: form-data; name=\"name\"" + CRLF);
//				wr.writeBytes(CRLF);
//				wr.writeBytes(name + CRLF);
//
//				// Send file part
//				wr.writeBytes("--" + boundary + CRLF);
//				wr.writeBytes("Content-Disposition: form-data; name=\"file\"; filename=\"" + name + ".png\"" + CRLF);
//				wr.writeBytes("Content-Type: image/png" + CRLF); // Change to the correct content type
//				wr.writeBytes(CRLF);
//
//				// Write the image data to the output stream
//				ByteArrayOutputStream baos = new ByteArrayOutputStream();
//				ImageIO.write(file, "png", baos); // Convert BufferedImage to PNG
//				byte[] imageData = baos.toByteArray();
//				wr.write(imageData);
//				wr.writeBytes(CRLF);
//				wr.writeBytes("--" + boundary + "--" + CRLF);
//				wr.flush();
//			}
//
//			int responseCode = con.getResponseCode();
//
//			if (responseCode == HttpURLConnection.HTTP_OK) {
//				BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
//				String inputLine;
//				StringBuilder response = new StringBuilder();
//				while ((inputLine = in.readLine()) != null) {
//					response.append(inputLine);
//				}
//				in.close();
//				System.out.println("Response: " + response.toString());
//			} else {
//				BufferedReader errorReader = new BufferedReader(new InputStreamReader(con.getErrorStream()));
//				StringBuilder errorResponse = new StringBuilder();
//				String errorLine;
//				while ((errorLine = errorReader.readLine()) != null) {
//					errorResponse.append(errorLine);
//				}
//				errorReader.close();
//				System.err.println("Error Response: " + errorResponse.toString());
//			}
//
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//	}

	public static byte[] convertFileToByteArray(File file) {
		byte[] fileBytes = null;
		try (FileInputStream fis = new FileInputStream(file)) {
			long fileLength = file.length();
			fileBytes = new byte[(int) fileLength];

			fis.read(fileBytes);

		} catch (IOException e) {
			throw new AdempiereException(e.getMessage());
		}
		return fileBytes;
	}

	@Override
	public String livestream() {
		return "<html>" + "<body>" + "<video width='600' controls autoplay>"
				+ "<source src='file:///home/mahe/Videos/Screencasts/Screencast%20from%202024-02-21%2006-30-55.webm'>"
				+ "Your browser does not support the video tag." + "</video>" + "</body>" + "</html>";
	}


	@Override
	public SwitchStateResponseDocument switchstate(SwitchStateRequestDocument req) {
		SwitchStateResponseDocument response = SwitchStateResponseDocument.Factory.newInstance();
		SwitchStateResponse resp = response.addNewSwitchStateResponse();
		SwitchStateRequest request = req.getSwitchStateRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Boolean switchState = request.getSwitchState();
		Trx trx = null;
		try {
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "switchState", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("switchState")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}
			if (switchState) {
				JsonNode result = callExternalSwitchApi(true);
				resp.setResult("Switch State True success: " + result);
				resp.setIsError(false);
			} else {
				JsonNode result = callExternalSwitchApi(false);
				resp.setResult("Switch State False success: " + result);
				resp.setIsError(false);
			}

		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	private JsonNode callExternalSwitchApi(boolean state) throws IOException {
		String url = "https://dev.warepro.in/switch/" + (state ? "true" : "false");

		try {
			URL obj = new URL(url);
			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
			con.setRequestMethod("POST");
			con.setConnectTimeout(2000);
			con.setReadTimeout(2000);
			con.setDoOutput(true);

			BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
			String inputLine;
			StringBuilder response = new StringBuilder();
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine);
			}
			in.close();

			ObjectMapper mapper = new ObjectMapper();
			return mapper.readTree(response.toString());
		} catch (Exception e) {
			ObjectMapper mapper = new ObjectMapper();
			return mapper.readTree("{\"status\":\"mocked_success\",\"switchState\":" + state + "}");
		}
	}

	@Override
	public Response getImage(int tableId, int id, int index) {
		try {
			MAttachment attachment = MAttachment.get(null, tableId, id);
			if (attachment != null && attachment.getEntries() != null && index >= 0 && index < attachment.getEntries().length) {
				MAttachmentEntry entry = attachment.getEntries()[index];
				String fileName = entry.getName();
				byte[] data = entry.getData();
				if (data != null && data.length > 0) {
					return Response.ok(data).type("image/png")
							.header("Content-Disposition", "inline; filename=\"" + fileName + "\"").build();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return Response.ok("Attachment image not found".getBytes()).type("text/plain").build();
	}

	@Override
	public CreateItemInoutResponseDocument createItemInout(CreateItemInoutRequestDocument req) {
		CreateItemInoutResponseDocument response = CreateItemInoutResponseDocument.Factory.newInstance();
		CreateItemInoutResponse resp = response.addNewCreateItemInoutResponse();
		CreateItemInoutRequest request = req.getCreateItemInoutRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "itemInout", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("itemInout")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}

			String operation = request.getOperation();
			X_pi_items_inout itemInout = null;
			if (operation.equals("CREATE")) {
				itemInout = new X_pi_items_inout(ctx, 0, trxName);
				itemInout.setAD_Org_ID(loginReq.getOrgID());
				itemInout.setitem_id(request.getItemInoutId());
				itemInout.setin_qty(BigDecimal.valueOf(request.getInQty()));
				itemInout.setout_qty(BigDecimal.valueOf(request.getOutQty()));
				itemInout.setIsProcessed(request.getIsProcessed());
				itemInout.saveEx();
			} else if (operation.equals("UPDATE")) {
				itemInout = new X_pi_items_inout(ctx, request.getPiItemInoutId(), trxName);

				if (itemInout.isProcess()) {
					throw new AdempiereException("Record is already processed. Update not allowed.");
				}

				itemInout.setin_qty(BigDecimal.valueOf(request.getInQty()));
				itemInout.setout_qty(BigDecimal.valueOf(request.getOutQty()));
				itemInout.setIsProcessed(request.getIsProcessed());
				itemInout.saveEx();
			}
			trx.commit();
			resp.setItemInoutId(itemInout.get_ID());
			resp.setIsError(false);
		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public GetItemInoutResponseDocument getItemInout(GetItemInoutRequestDocument req) {
		GetItemInoutResponseDocument response = GetItemInoutResponseDocument.Factory.newInstance();
		GetItemInoutResponse resp = response.addNewGetItemInoutResponse();
		GetItemInoutRequest request = req.getGetItemInoutRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "itemInout", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("itemInout")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}
			List<PO> list = new Query(ctx, "pi_items_inout", "AD_Client_ID=?", trxName)
					.setParameters(loginReq.getClientID()).setOrderBy("pi_items_inout_id DESC").list();

			for (PO itemList : list) {
				X_pi_items_inout itemInout = new X_pi_items_inout(ctx, itemList.get_ID(), trxName);
				ItemList itemLists = resp.addNewItemList();
				itemLists.setItemId(String.valueOf("" + itemInout.getitem_id() + ""));
				itemLists.setInQty(itemInout.getin_qty().intValue());
				itemLists.setOutQty(itemInout.getout_qty().intValue());
				itemLists.setItemInoutId(itemInout.getpi_items_inout_ID());
				Timestamp end_ts = itemInout.getUpdated();
				Timestamp start_ts = itemInout.getCreated();
				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
				sdf.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata")); // or your zone
				String endDateTime = sdf.format(end_ts);
				String startDateTime = sdf.format(start_ts);
				itemLists.setEndDateTime(endDateTime);
				itemLists.setStartDateTime(startDateTime);
				itemLists.setIsProcessed(itemInout.isProcess());
			}
			trx.commit();
			resp.setIsError(false);
		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public GetUnauthorisedListResponseDocument getUnauthorisedList(GetUnauthorisedListRequestDocument req) {
		GetUnauthorisedListResponseDocument response = GetUnauthorisedListResponseDocument.Factory.newInstance();
		GetUnauthorisedListResponse resp = response.addNewGetUnauthorisedListResponse();
		GetUnauthorisedListRequest request = req.getGetUnauthorisedListRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "itemInout", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("itemInout")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}
			int pageNo = request.getPageNo() > 0 ? request.getPageNo() : 1;
			int pageSize = request.getPageSize() > 0 ? request.getPageSize() : 20;

			String searchKey = request.getSearchKey();
			boolean hasSearch = (searchKey != null && searchKey.trim().length() > 0);

			StringBuilder where = new StringBuilder("AD_Client_ID=? AND Description='UNAUTHORISED'");

			if (hasSearch) {
				where.append(" AND (UPPER(TextMsg) LIKE ? " + " OR UPPER(Description) LIKE ? "
						+ " OR TO_CHAR(Created,'DD/MM/YYYY') LIKE ?)");
			}

			Query q = new Query(ctx, MNote.Table_Name, where.toString(), trxName);

			if (hasSearch) {
				String like = "%" + searchKey.trim().toUpperCase() + "%";
				q.setParameters(loginReq.getClientID(), like, like, like);
			} else {
				q.setParameters(loginReq.getClientID());
			}

			q.setOrderBy("AD_Note_ID DESC");

			List<PO> notes = q.list();

			int fromIndex = (pageNo - 1) * pageSize;
			if (fromIndex >= notes.size()) {
				resp.setIsError(false);
				return response;
			}

			int toIndex = Math.min(fromIndex + pageSize, notes.size());
			List<PO> pagedList = notes.subList(fromIndex, toIndex);

			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
			sdf.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));

			for (PO po : pagedList) {
				MNote note = (MNote) po;

				NotificationList n = resp.addNewNotificationList();
				n.setNoticeId(note.getAD_Note_ID());
				n.setNoticeDateTime(sdf.format(note.getCreated()));
				n.setDescription(note.getDescription());
				n.setMessage(note.getTextMsg());
				n.setUser(note.getAD_User() != null ? note.getAD_User().getName() : "");
			}

			resp.setIsError(false);
			trx.commit();

		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public LabelInventoryListResponseDocument getLabelInventoryList(LabelInventoryListRequestDocument req) {
		LabelInventoryListResponseDocument responseDoc = LabelInventoryListResponseDocument.Factory.newInstance();
		LabelInventoryListResponse response = responseDoc.addNewLabelInventoryListResponse();
		LabelInventoryListRequest request = req.getLabelInventoryListRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		String searchKey = request.getSearchKey();

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();

			String err = login(loginReq, webServiceName, "pIList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("pIList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			int warehouseId = loginReq.getWarehouseID();
			String whereClause = "isactive='Y' AND DocStatus = 'DR' AND m_warehouse_ID=" + warehouseId;

			if (searchKey != null && !searchKey.isEmpty()) {
				whereClause += " AND (DocumentNo ILIKE '%" + searchKey + "%' OR Description ILIKE '%" + searchKey
						+ "%')";
			}

			List<PO> inventories = new Query(ctx, X_pi_LabelInventory.Table_Name, whereClause, null)
					.setOrderBy("Created DESC").list();

			int count = 0;
			for (PO po : inventories) {
				X_pi_LabelInventory inv = new X_pi_LabelInventory(ctx, po.get_ID(), null);
				LabelInventoryList listItem = response.addNewLabelInventoryList();
				listItem.setDocumentNo(inv.getDocumentNo());
				listItem.setLabelInventoryId(inv.getpi_LabelInventory_ID());

				SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
				listItem.setMovementDate(inv.getMovementDate() != null ? sdf.format(inv.getMovementDate()) : "");

				MWarehouse warehouse = new MWarehouse(ctx, inv.getM_Warehouse_ID(), null);
				listItem.setWarehouseName(warehouse.getName());
				listItem.setDescription(inv.getDescription() != null ? inv.getDescription() : "");
				listItem.setDocStatus(inv.getDocStatus() != null ? inv.getDocStatus() : "");
				count++;
			}

			response.setCount(count);
			response.setIsError(false);

		} catch (Exception e) {
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public LabelInventoryDetailResponseDocument getLabelInventoryDetail(LabelInventoryDetailRequestDocument req) {
		LabelInventoryDetailResponseDocument responseDoc = LabelInventoryDetailResponseDocument.Factory.newInstance();
		LabelInventoryDetailResponse response = responseDoc.addNewLabelInventoryDetailResponse();
		LabelInventoryDetailRequest request = req.getLabelInventoryDetailRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int labelInventoryId = request.getLabelInventoryId();

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();

			String err = login(loginReq, webServiceName, "pIList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("pIList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			X_pi_LabelInventory header = new X_pi_LabelInventory(ctx, labelInventoryId, null);
			if (header.get_ID() == 0) {
				response.setIsError(true);
				response.setError("Label Inventory not found");
				return responseDoc;
			}

			response.setDocumentNo(header.getDocumentNo());
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			response.setMovementDate(header.getMovementDate() != null ? sdf.format(header.getMovementDate()) : "");
			MWarehouse warehouse = new MWarehouse(ctx, header.getM_Warehouse_ID(), null);
			response.setWarehouseName(warehouse.getName());
			response.setDescription(header.getDescription() != null ? header.getDescription() : "");
			response.setDocStatus(header.getDocStatus() != null ? header.getDocStatus() : "");

			List<PO> lines = new Query(ctx, X_pi_InventoryLine.Table_Name, "pi_LabelInventory_ID=?", null)
					.setParameters(labelInventoryId).setOrderBy("Line").list();

			for (PO po : lines) {
				X_pi_InventoryLine line = new X_pi_InventoryLine(ctx, po.get_ID(), null);
				InventoryLines invLine = response.addNewInventoryLines();
				invLine.setLineId(line.getpi_InventoryLine_ID());

				MLocator locator = new MLocator(ctx, line.getM_Locator_ID(), null);
				invLine.setLocatorName(locator.getValue());

				MProduct product = new MProduct(ctx, line.getM_Product_ID(), null);
				invLine.setProductName(product.getName());

				invLine.setQtyBook(line.getQtyBook().intValue());
				invLine.setQtyCount(line.getQtyCount().intValue());

				List<PO> details = new Query(ctx, X_pi_InventoryDetail.Table_Name, "pi_InventoryLine_ID=?", null)
						.setParameters(line.getpi_InventoryLine_ID()).list();

				for (PO detailInventoryDetail : details) {
					X_pi_InventoryDetail detail = new X_pi_InventoryDetail(ctx, detailInventoryDetail.get_ID(), null);
					InventoryDetails invDetail = invLine.addNewInventoryDetails();
					invDetail.setDetailId(detail.getpi_InventoryDetail_ID());
					invDetail.setLabelUUID(detail.getLabelUUID() != null ? detail.getLabelUUID() : "");
					invDetail.setQtyBook(detail.getQtyBook().intValue());
					invDetail.setQtyCount(detail.getQtyCount().intValue());
				}
			}

			response.setIsError(false);

		} catch (Exception e) {
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public UpdateInventoryCountResponseDocument updateInventoryCount(UpdateInventoryCountRequestDocument req) {
		UpdateInventoryCountResponseDocument responseDoc = UpdateInventoryCountResponseDocument.Factory.newInstance();
		UpdateInventoryCountResponse response = responseDoc.addNewUpdateInventoryCountResponse();
		UpdateInventoryCountRequest request = req.getUpdateInventoryCountRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "pIList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("pIList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			UpdateDetails[] updateDetails = request.getUpdateDetailsArray();
			Map<Integer, BigDecimal> lineTotals = new HashMap<>();

			for (UpdateDetails detail : updateDetails) {
				int detailId = detail.getDetailId();
				BigDecimal qtyCount = BigDecimal.valueOf(detail.getQtyCount());

				X_pi_InventoryDetail invDetail = new X_pi_InventoryDetail(ctx, detailId, trxName);
				if (invDetail.get_ID() == 0) {
					response.setIsError(true);
					response.setError("Detail ID " + detailId + " not found");
					return responseDoc;
				}

				invDetail.setQtyCount(qtyCount);
				invDetail.saveEx();

				int lineId = invDetail.getpi_InventoryLine_ID();
				lineTotals.put(lineId, lineTotals.getOrDefault(lineId, BigDecimal.ZERO).add(qtyCount));
			}

			for (Map.Entry<Integer, BigDecimal> entry : lineTotals.entrySet()) {
				X_pi_InventoryLine line = new X_pi_InventoryLine(ctx, entry.getKey(), trxName);
				line.setQtyCount(entry.getValue());
				line.saveEx();
			}

			trx.commit();
			response.setMessage("Updated " + updateDetails.length + " details successfully");
			response.setIsError(false);

		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			if (trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public RMAListResponseDocument getRMAList(RMAListRequestDocument rMAListRequestDocument) {
		RMAListResponseDocument rMAListResponseDocument = RMAListResponseDocument.Factory.newInstance();
		RMAListResponse rMAListResponse = rMAListResponseDocument.addNewRMAListResponse();
		RMAListRequest rMAListRequest = rMAListRequestDocument.getRMAListRequest();
		ADLoginRequest loginReq = rMAListRequest.getADLoginRequest();
		String serviceType = rMAListRequest.getServiceType();
		String searchKey = rMAListRequest.getSearchKey();
		PreparedStatement pstm = null;
		ResultSet rs = null;

		try {
			CompiereService m_cs = getCompiereService();
			int clientId = loginReq.getClientID();
			int roleId = loginReq.getRoleID();
			getCompiereService().connect();

			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				rMAListResponse.setError(err);
				rMAListResponse.setIsError(true);
				return rMAListResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				rMAListResponse.setIsError(true);
				rMAListResponse.setError("Service type " + serviceType + " not configured");
				return rMAListResponseDocument;
			}

			List<Integer> orgList = new ArrayList<>();
			Login login = new Login(m_cs.getCtx());
			KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
			if (orgs != null) {
				for (KeyNamePair org : orgs) {
					orgList.add(Integer.valueOf(org.getID()));
				}
			}
			String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

			String query = "SELECT DISTINCT r.m_rma_id, r.documentno, bp.c_bpartner_id, bp.name AS customer_name, "
					+ "r.created, TO_CHAR(r.created, 'DD/MM/YYYY') AS created_formatted, r.description, "
					+ "r.inout_id, io.documentno AS shipment_receipt_docno, "
					+ "r.c_doctype_id, dt.name AS doctype_name, " + "r.M_RMAType_id, rt.name AS rmatype_name "
					+ "FROM m_rma r " + "JOIN c_bpartner bp ON r.c_bpartner_id = bp.c_bpartner_id "
					+ "JOIN m_rmaline rl ON r.m_rma_id = rl.m_rma_id "
					+ "LEFT JOIN m_inout io ON r.inout_id = io.m_inout_id "
					+ "LEFT JOIN c_doctype dt ON r.c_doctype_id = dt.c_doctype_id "
					+ "LEFT JOIN M_RMAType rt ON r.m_rmatype_id = rt.m_rmatype_id "
					+ "WHERE r.ad_client_id = ? AND r.docstatus = 'CO' AND r.ad_org_id IN (" + orgIds + ") "
					+ "AND rl.qty > (SELECT COALESCE(SUM(iol.qtyentered), 0) FROM m_inoutline iol "
					+ "WHERE iol.m_rmaline_id = rl.m_rmaline_id) "
					+ "AND (r.documentno ILIKE '%' || COALESCE(?, r.documentno) || '%' "
					+ "OR bp.name ILIKE '%' || COALESCE(?, bp.name) || '%' "
					+ "OR r.description ILIKE '%' || COALESCE(?, r.description) || '%') " + "ORDER BY r.created DESC";

			pstm = DB.prepareStatement(query, null);
			pstm.setInt(1, clientId);
			pstm.setString(2, searchKey);
			pstm.setString(3, searchKey);
			pstm.setString(4, searchKey);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {
				RMAList rmaList = rMAListResponse.addNewRMAList();
				rmaList.setRmaId(rs.getInt("m_rma_id"));
				rmaList.setDocumentNo(rs.getString("documentno"));
				rmaList.setCustomerId(rs.getInt("c_bpartner_id"));
				rmaList.setCustomerName(rs.getString("customer_name"));
				rmaList.setCreated(rs.getString("created_formatted"));
				String description = rs.getString("description");
				rmaList.setDescription(description == null ? "" : description);
				rmaList.setShipmentReceiptId(rs.getInt("inout_id"));
				String shipmentDocNo = rs.getString("shipment_receipt_docno");
				rmaList.setShipmentReceiptDocNo(shipmentDocNo == null ? "" : shipmentDocNo);
				rmaList.setDocTypeId(rs.getInt("c_doctype_id"));
				String docTypeName = rs.getString("doctype_name");
				rmaList.setDocTypeName(docTypeName == null ? "" : docTypeName);
				rmaList.setRmaTypeId(rs.getInt("m_rmatype_id"));
				String rmaTypeName = rs.getString("rmatype_name");
				rmaList.setRmaTypeName(rmaTypeName == null ? "" : rmaTypeName);
				count++;
			}
			rMAListResponse.setCount(count);

		} catch (Exception e) {
			rMAListResponse.setIsError(true);
			rMAListResponse.setError(e.getMessage());
			return rMAListResponseDocument;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}
		return rMAListResponseDocument;
	}

	@Override
	public RMADetailResponseDocument getRMADetail(RMADetailRequestDocument rmaDetailRequestDocument) {
		RMADetailResponseDocument responseDoc = RMADetailResponseDocument.Factory.newInstance();
		RMADetailResponse response = responseDoc.addNewRMADetailResponse();
		RMADetailRequest request = rmaDetailRequestDocument.getRMADetailRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int rmaId = request.getRmaId();
		PreparedStatement pstm = null;
		ResultSet rs = null;

		try {
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			int clientId = loginReq.getClientID();

			String query = "SELECT r.m_rma_id, r.documentno, r.docstatus, bp.name as customer_name, r.description "
					+ "FROM m_rma r " + "JOIN c_bpartner bp ON r.c_bpartner_id = bp.c_bpartner_id "
					+ "WHERE r.m_rma_id = ? AND r.ad_client_id = ?";

			pstm = DB.prepareStatement(query, null);
			pstm.setInt(1, rmaId);
			pstm.setInt(2, clientId);
			rs = pstm.executeQuery();

			if (rs.next()) {
				response.setRmaId(rs.getInt("m_rma_id"));
				response.setDocumentNo(rs.getString("documentno"));
				response.setDocStatus(rs.getString("docstatus"));
				response.setCustomerName(rs.getString("customer_name"));
				String desc = rs.getString("description");
				response.setDescription(desc == null ? "" : desc);
			} else {
				response.setIsError(true);
				response.setError("RMA not found for ID: " + rmaId);
				return responseDoc;
			}
			closeDbCon(pstm, rs);

			String lineQuery = "SELECT rl.m_rmaline_id, rl.m_product_id, p.name as product_name, rl.qty, "
					+ "COALESCE(SUM(iol.movementqty), 0) as completed_qty " + "FROM m_rmaline rl "
					+ "JOIN m_product p ON rl.m_product_id = p.m_product_id "
					+ "LEFT JOIN m_inoutline iol ON iol.m_rmaline_id = rl.m_rmaline_id " + "WHERE rl.m_rma_id = ? "
					+ "GROUP BY rl.m_rmaline_id, rl.m_product_id, p.name, rl.qty";

			pstm = DB.prepareStatement(lineQuery, null);
			pstm.setInt(1, rmaId);
			rs = pstm.executeQuery();

			int totalQty = 0;
			int totalCompletedQty = 0;

			List<PO> poList = new Query(ctx, MLocator.Table_Name, "m_warehouse_id =? AND value = 'Returns Locator'",
					null).setParameters(loginReq.getWarehouseID()).setOrderBy(MLocator.COLUMNNAME_M_Locator_ID).list();
			MLocator mLocator = (MLocator) poList.get(0);

			while (rs.next()) {
				int qty = rs.getInt("qty");
				int completedQty = rs.getInt("completed_qty");
				int pendingQty = qty - completedQty;

				if (completedQty < qty) {
					RMALine line = response.addNewRMALines();
					line.setRmaLineId(rs.getInt("m_rmaline_id"));
					line.setProductId(rs.getInt("m_product_id"));
					line.setProductName(rs.getString("product_name"));
					line.setTotalQty(qty);
					line.setCompletedQty(completedQty);
					line.setPendingQty(pendingQty);
					line.setLocatorId(mLocator.get_ID());
				}

				totalQty += qty;
				totalCompletedQty += completedQty;
			}

			response.setTotalQty(totalQty);
			response.setCompletedQty(totalCompletedQty);
			response.setPendingQty(totalQty - totalCompletedQty);

		} catch (Exception e) {
			response.setIsError(true);
			response.setError(e.getMessage());
			return responseDoc;
		} finally {
			closeDbCon(pstm, rs);
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public GetRMAComponentsResponseDocument getRMAComponents(GetRMAComponentsRequestDocument req) {
		GetRMAComponentsResponseDocument response = GetRMAComponentsResponseDocument.Factory.newInstance();
		GetRMAComponentsResponse resp = response.addNewGetRMAComponentsResponse();
		GetRMAComponentsRequest request = req.getGetRMAComponentsRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		Trx trx = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				resp.setIsError(true);
				resp.setError("Service type " + serviceType + " not configured");
				return response;
			}

			int clientId = loginReq.getClientID();
			String query = "SELECT mi.m_inout_id, mi.documentno, bp.name as customer_name " + "FROM m_inout mi "
					+ "JOIN c_bpartner bp ON mi.c_bpartner_id = bp.c_bpartner_id " + "WHERE mi.ad_client_id = "
					+ clientId + " AND mi.issotrx = 'Y' AND mi.docstatus = 'CO' " + "ORDER BY mi.created DESC";

			pstm = DB.prepareStatement(query, null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				int shipmentId = rs.getInt("m_inout_id");
				String documentNo = rs.getString("documentno");
				String customerName = rs.getString("customer_name");

				ShipmentData shipmentData = resp.addNewShipmentList();
				shipmentData.setShipmentId(shipmentId);
				shipmentData.setDocumentNo(documentNo);
				shipmentData.setCustomerName(customerName);

				MInOut mInout = new MInOut(ctx, shipmentId, trxName);
				for (MInOutLine line : mInout.getLines()) {
					ShipmentLineData lineData = shipmentData.addNewShipmentLines();
					lineData.setShipmentLineId(line.getM_InOutLine_ID());
					lineData.setProductId(line.getM_Product_ID());
					lineData.setProductName(line.getM_Product().getName());
					lineData.setQty(line.getMovementQty().intValue());
				}
			}

			resp.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			resp.setIsError(true);
			resp.setError(e.getMessage());
			return response;
		} finally {
			closeDbCon(pstm, rs);
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public StandardResponseDocument createRMA(CreateRMARequestDocument req) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse standardResponse = response.addNewStandardResponse();
		CreateRMARequest request = req.getCreateRMARequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int shipmentId = request.getShipmentId();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();
			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				standardResponse.setError(err);
				standardResponse.setIsError(true);
				return response;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				standardResponse.setIsError(true);
				standardResponse.setError("Service type " + serviceType + " not configured");
				return response;
			}

			MInOut mInout = new MInOut(ctx, shipmentId, trxName);
			if (mInout.getM_InOut_ID() == 0) {
				standardResponse.setIsError(true);
				standardResponse.setError("Invalid shipment ID " + shipmentId);
				return response;
			}

			MRMA rma = new MRMA(ctx, 0, trxName);
			rma.setAD_Org_ID(loginReq.getOrgID());
			rma.setC_BPartner_ID(mInout.getC_BPartner_ID());
			rma.setM_InOut_ID(shipmentId);
			rma.setIsSOTrx(true);

			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable.getPO(
					"name = 'Customer Return Material' and ad_client_id = " + loginReq.getClientID() + "",
					trx.getTrxName());
			MDocType mDocType = (MDocType) docTypePO;
			rma.setC_DocType_ID(mDocType.get_ID());

			MTable rmaTypeTable = MTable.get(ctx, "M_RMAType");
			PO po = rmaTypeTable.getPO("name = 'Damage' and ad_client_id = " + loginReq.getClientID() + "",
					trx.getTrxName());
			X_M_RMAType rmaType = (X_M_RMAType) po;
			rma.setM_RMAType_ID(rmaType.get_ID());

			rma.setName("RMA-" + mInout.getDocumentNo());
			int salesRepId = mInout.getSalesRep_ID();
			if (salesRepId <= 0) {
				salesRepId = Env.getAD_User_ID(ctx);
			}
			if (salesRepId <= 0) {
				salesRepId = 100;
			}
			rma.setSalesRep_ID(salesRepId);
			rma.saveEx();

			rma.setIsApproved(true);
			rma.setDocStatus(MInOutConfirm.DOCSTATUS_Completed);
			rma.setDocAction(MInOutConfirm.DOCACTION_Close);
			rma.saveEx();

			RMALineData[] rmaLineDataArray = request.getRMALineDataArray();
			for (RMALineData lineData : rmaLineDataArray) {
				MRMALine rmaLine = new MRMALine(ctx, 0, trxName);
				rmaLine.setM_RMA_ID(rma.getM_RMA_ID());
				rmaLine.setM_InOutLine_ID(lineData.getShipmentLineId());
				rmaLine.setQty(BigDecimal.valueOf(lineData.getQty()));
				rmaLine.saveEx();
			}

			standardResponse.setIsError(false);
			standardResponse.setRecordID(rma.getM_RMA_ID());
			trx.commit();
		} catch (Exception e) {
			standardResponse.setIsError(true);
			standardResponse.setError(e.getMessage());
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}

	@Override
	public CustomerReturnListResponseDocument getCustomerReturnList(CustomerReturnListRequestDocument req) {
		CustomerReturnListResponseDocument responseDoc = CustomerReturnListResponseDocument.Factory.newInstance();
		CustomerReturnListResponse response = responseDoc.addNewCustomerReturnListResponse();
		CustomerReturnListRequest request = req.getCustomerReturnListRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		String searchKey = request.getSearchKey();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable
					.getPO("name = 'MM Customer Return' and ad_client_id = " + loginReq.getClientID() + "", trxName);
			if (docTypePO == null) {
				response.setIsError(true);
				response.setError("Document Type 'Customer Return Material' not found");
				return responseDoc;
			}
			MDocType mDocType = (MDocType) docTypePO;

			int warehouseId = loginReq.getWarehouseID();
			String whereClause = "C_DocType_ID=" + mDocType.get_ID() + " AND M_Warehouse_ID=" + warehouseId
					+ " AND IsActive='Y' AND docstatus = 'DR'";

			if (searchKey != null && !searchKey.isEmpty()) {
				whereClause += " AND DocumentNo ILIKE '%" + searchKey + "%'";
			}

			List<PO> inouts = new Query(ctx, MInOut.Table_Name, whereClause, trxName).setOrderBy("Created DESC").list();

			int count = 0;
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

			for (PO po : inouts) {
				MInOut inout = new MInOut(ctx, po.get_ID(), trxName);
				CustomerReturnList item = response.addNewCustomerReturnList();

				item.setDocumentNo(inout.getDocumentNo());
				item.setMInOutId(inout.getM_InOut_ID());

				int rmaId = inout.getM_RMA_ID();
				item.setRmaId(rmaId);

				if (rmaId > 0) {
					MRMA rma = new MRMA(ctx, rmaId, trxName);
					item.setRmaName(rma.getDocumentNo());
				} else {
					item.setRmaName("");
				}

				item.setMovementDate(inout.getMovementDate() != null ? sdf.format(inout.getMovementDate()) : "");

				MBPartner bp = new MBPartner(ctx, inout.getC_BPartner_ID(), trxName);
				item.setBusinessPartner(bp.getName());

				MWarehouse warehouse = new MWarehouse(ctx, inout.getM_Warehouse_ID(), trxName);
				item.setWarehouseName(warehouse.getName());

				item.setDocStatus(inout.getDocStatus());
				count++;
			}

			response.setCount(count);
			response.setIsError(false);
			trx.commit();

		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			if (trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public CustomerReturnDetailResponseDocument getCustomerReturnDetail(CustomerReturnDetailRequestDocument req) {
		CustomerReturnDetailResponseDocument responseDoc = CustomerReturnDetailResponseDocument.Factory.newInstance();
		CustomerReturnDetailResponse response = responseDoc.addNewCustomerReturnDetailResponse();
		CustomerReturnDetailRequest request = req.getCustomerReturnDetailRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int inOutId = request.getInOutId();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			MInOut inout = new MInOut(ctx, inOutId, trxName);
			if (inout.getM_InOut_ID() == 0) {
				response.setIsError(true);
				response.setError("Invalid InOut ID: " + inOutId);
				return responseDoc;
			}

			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

			response.setDocumentNo(inout.getDocumentNo());

			int rmaId = inout.getM_RMA_ID();
			response.setRmaId(rmaId);

			if (rmaId > 0) {
				MRMA rma = new MRMA(ctx, rmaId, trxName);
				response.setRmaName(rma.getDocumentNo());
			} else {
				response.setRmaName("");
			}

			response.setMovementDate(inout.getMovementDate() != null ? sdf.format(inout.getMovementDate()) : "");

			MBPartner bp = new MBPartner(ctx, inout.getC_BPartner_ID(), trxName);
			response.setBusinessPartner(bp.getName());

			MWarehouse warehouse = new MWarehouse(ctx, inout.getM_Warehouse_ID(), trxName);
			response.setWarehouseName(warehouse.getName());

			response.setDocStatus(inout.getDocStatus());

			MInOutLine[] lines = inout.getLines();
			for (MInOutLine line : lines) {
				CustomerReturnLines returnLine = response.addNewCustomerReturnLines();
				returnLine.setLineId(line.getM_InOutLine_ID());

				MProduct product = new MProduct(ctx, line.getM_Product_ID(), trxName);
				returnLine.setProductId(product.getM_Product_ID());
				returnLine.setProductName(product.getName());
				returnLine.setQuantity(line.getMovementQty().intValue());
			}

			response.setIsError(false);
			trx.commit();

		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			if (trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public CreateCustomerReturnResponseDocument createCustomerReturn(CreateCustomerReturnRequestDocument req) {
		CreateCustomerReturnResponseDocument responseDoc = CreateCustomerReturnResponseDocument.Factory.newInstance();
		CreateCustomerReturnResponse response = responseDoc.addNewCreateCustomerReturnResponse();
		CreateCustomerReturnRequest request = req.getCreateCustomerReturnRequest();
		ADLoginRequest loginReq = request.getADLoginRequest();
		String serviceType = request.getServiceType();
		int rmaId = request.getRmaId();
		Trx trx = null;

		try {
			CompiereService m_cs = getCompiereService();
			getCompiereService().connect();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();

			String err = login(loginReq, webServiceName, "mrList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return responseDoc;
			}

			if (!serviceType.equalsIgnoreCase("mrList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return responseDoc;
			}

			MRMA rma = new MRMA(ctx, rmaId, trxName);
			if (rma.getM_RMA_ID() == 0) {
				response.setIsError(true);
				response.setError("Invalid RMA ID: " + rmaId);
				return responseDoc;
			}

			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable
					.getPO("name = 'MM Customer Return' and ad_client_id = " + loginReq.getClientID() + "", trxName);
			if (docTypePO == null) {
				response.setIsError(true);
				response.setError("Document Type 'MM Customer Return' not found");
				return responseDoc;
			}
			MDocType mDocType = (MDocType) docTypePO;

			MInOut inout = new MInOut(ctx, 0, trxName);
			inout.setC_DocType_ID(mDocType.get_ID());
			inout.setM_RMA_ID(rmaId);
			inout.setC_BPartner_ID(rma.getC_BPartner_ID());
			inout.setM_Warehouse_ID(loginReq.getWarehouseID());
			inout.setIsSOTrx(true);
			inout.setMovementType("C+");
			inout.setDocStatus(DocAction.STATUS_Drafted);

			MBPartner bp = new MBPartner(ctx, rma.getC_BPartner_ID(), trxName);
			MBPartnerLocation[] locs = bp.getLocations(false);
			if (locs.length > 0) {
				inout.setC_BPartner_Location_ID(locs[0].getC_BPartner_Location_ID());
			}

			inout.saveEx();

			ReturnLines[] returnLinesArray = request.getReturnLinesArray();
			for (ReturnLines returnLine : returnLinesArray) {
				MRMALine rmaLine = new MRMALine(ctx, returnLine.getRmaLineId(), trxName);

				MInOutLine inoutLine = new MInOutLine(inout);
				inoutLine.setM_RMALine_ID(rmaLine.getM_RMALine_ID());
				inoutLine.setM_Product_ID(rmaLine.getM_Product_ID());
				inoutLine.setM_Locator_ID(returnLine.getLocatorId());
				inoutLine.setQty(BigDecimal.valueOf(returnLine.getQuantity()));
				inoutLine.saveEx();
			}

			response.setMInOutId(inout.getM_InOut_ID());
			response.setDocumentNo(inout.getDocumentNo());
			response.setIsError(false);
			trx.commit();

		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			response.setError(e.getMessage());
			response.setIsError(true);
		} finally {
			if (trx != null)
				trx.close();
			getCompiereService().disconnect();
		}

		return responseDoc;
	}

	@Override
	public Response testFCM(String jsonBody) {
		JSONObject result = new JSONObject();
		try {
			JSONObject input = new JSONObject(jsonBody);
			String user = input.getString("user");
			String pass = input.getString("pass");
			int clientId = input.getInt("clientId");
			int roleId = input.getInt("roleId");
			int orgId = input.getInt("orgId");
			int warehouseId = input.getInt("warehouseId");
			String roleName = input.optString("roleName", "Supervisor");

			getCompiereService().connect();
			ADLoginRequest loginReq = ADLoginRequest.Factory.newInstance();
			loginReq.setUser(user);
			loginReq.setPass(pass);
			loginReq.setLang("112");
			loginReq.setClientID(clientId);
			loginReq.setRoleID(roleId);
			loginReq.setOrgID(orgId);
			loginReq.setWarehouseID(warehouseId);
			loginReq.setStage(0);

//			String err = login(loginReq, webServiceName, "createMR", "createMR");
//			if (err != null && err.length() > 0) {
//				result.put("login", "FAILED — " + err);
//				return Response.status(401).entity(result.toString()).build();
//			}
			result.put("login", "OK");

			Map<String, String> data = new HashMap<>();
			data.put("recordId", "0");
			data.put("documentNo", "TEST-001");
			data.put("path1", "/put_away_screen");
			data.put("path2", "/put_away_detail_screen");

			result.put("notification", "SENDING to role: " + roleName);

			PipraUtils.sendNotificationAsyncnew("Supervisor", 319, 0, getCompiereService().getCtx(), null,
					"Test Notification", "This is a test notification from testFCM API", "M_InOut", data, clientId,
					"TestFCMNotification");

			result.put("notification", "SUBMITTED — check server logs for FCM: messages and device for notification");
			result.put("hint", "Notification runs async. If no notification on device, check logs for FCM: errors.");

			return Response.ok(result.toString()).build();

		} catch (Exception e) {
			try {
				result.put("error", e.getMessage());
			} catch (Exception ignored) {
			}
			return Response.status(500).entity(result.toString()).build();
		} finally {
			getCompiereService().disconnect();
		}
	}

//	@Override
//	public GetWarehouseResponseDocument getWarehouseAttachment(GetWarehouseRequestDocument req) {
//		GetWarehouseResponseDocument responseDoc = GetWarehouseResponseDocument.Factory.newInstance();
//		GetWarehouseResponse response = responseDoc.addNewGetWarehouseResponse();
//		GetWarehouseRequest request = req.getGetWarehouseRequest();
//		ADLoginRequest loginReq = request.getADLoginRequest();
//		String serviceType = request.getServiceType();
//		Trx trx = null;
//		MAttachment attachment = null;
//		int tableId = MTable.getTable_ID(TABLE_WAREHOUSE);
//
//		try {
//			CompiereService m_cs = getCompiereService();
//			getCompiereService().connect();
//			Properties ctx = m_cs.getCtx();
//			String trxName = Trx.createTrxName(getClass().getName() + "_");
//			trx = Trx.get(trxName, true);
//			trx.start();
//
//			String err = login(loginReq, webServiceName, "mrList", serviceType);
//			if (err != null && err.length() > 0) {
//				response.setError(err);
//				response.setIsError(true);
//				return responseDoc;
//			}
//
//			if (!serviceType.equalsIgnoreCase("mrList")) {
//				response.setIsError(true);
//				response.setError("Service type " + serviceType + " not configured");
//				return responseDoc;
//			}
//			int clientId = loginReq.getClientID();
//			int warehouseId = loginReq.getWarehouseID();
//			
//			attachment = MAttachment.get(ctx, tableId, warehouseId);
//			if(attachment != null) {
//				MAttachmentEntry[] entries = attachment.getEntries();
//				if(entries != null && entries.length > 0) {
//					
//					// Find JSON file
//	                MAttachmentEntry jsonEntry = null;
//	                for (MAttachmentEntry entry : entries) {
//	                    String name = entry.getName();
//	                    if (name != null && name.toLowerCase().endsWith(".json")) {
//	                        jsonEntry = entry;
//	                        break;
//	                    }
//	                }
//
//	                if (jsonEntry != null) {
//	                    byte[] data = jsonEntry.getData();
//	                    if (data != null && data.length > 0) {
//
//	                        // Convert bytes to JSON String
//	                        String jsonContent = new String(data, java.nio.charset.StandardCharsets.UTF_8);
//
//	                        // ✅ iDempiere standard way - set in output fields
////	                        WindowTabData tabData = response.addNewWindowTabData();
//	                        GetWarehouseData warehouseData = response.addNewGetWarehouseData();
//	                        warehouseData.setWarehouseLayout(jsonContent);
//
//	                        // Set the JSON as a field value in DataSet
////	                        DataSet dataSet = tabData.addNewDataSet();
////	                        DataRow dataRow = dataSet.addNewDataRow();
////	                        DataField field = dataRow.addNewField();
////	                        field.setColumn("WarehouseLayout");
////	                        field.setStringValue(jsonContent);
//
//	                        response.setIsError(false);
//	                        response.setError("");
//	                    } else {
//	                        response.setIsError(true);
//	                        response.setError("JSON file is empty");
//	                    }
//	                } else {
//	                    response.setIsError(true);
//	                    response.setError("No JSON file found in attachment");
//	                }
//	            } else {
//	                response.setIsError(true);
//	                response.setError("No attachments found");
//	            }
//	        } else {
//	            response.setIsError(true);
//	            response.setError("No attachment for warehouse: " + warehouseId);
//	        }
//
//		} catch (Exception e) {
//			if (trx != null)
//				trx.rollback();
//			response.setError(e.getMessage());
//			response.setIsError(true);
//		} finally {
//			if (trx != null)
//				trx.close();
//			getCompiereService().disconnect();
//		}
//
//		return responseDoc;
//	}
	
	@Override
	public Response getWarehouseLayout(int warehouseId) {

	    try {

	        Properties ctx = Env.getCtx();

	        int tableId = MTable.getTable_ID("M_Warehouse");

	        MAttachment attachment = MAttachment.get(ctx, tableId, warehouseId);

	        if (attachment == null) {
	            return Response.status(Response.Status.NOT_FOUND)
	                    .entity("{\"error\":\"No attachment found\"}")
	                    .build();
	        }

	        MAttachmentEntry[] entries = attachment.getEntries();

	        if (entries == null || entries.length == 0) {
	            return Response.status(Response.Status.NOT_FOUND)
	                    .entity("{\"error\":\"No attachment entries found\"}")
	                    .build();
	        }

	        MAttachmentEntry jsonEntry = null;

	        for (MAttachmentEntry entry : entries) {

	            String fileName = entry.getName();

	            if (fileName != null &&
	                    fileName.toLowerCase().endsWith(".json")) {

	                jsonEntry = entry;
	                break;
	            }
	        }

	        if (jsonEntry == null) {
	            return Response.status(Response.Status.NOT_FOUND)
	                    .entity("{\"error\":\"JSON file not found\"}")
	                    .build();
	        }

	        byte[] data = jsonEntry.getData();

	        String jsonContent =
	                new String(data, java.nio.charset.StandardCharsets.UTF_8);

	        return Response.ok(jsonContent, MediaType.APPLICATION_JSON).build();

	    } catch (Exception e) {

	        e.printStackTrace();

	        return Response.serverError()
	                .entity("{\"error\":\"" + e.getMessage() + "\"}")
	                .build();
	    }
	}
	
	@Override
	public Response getWarehouseAttachment(GetWarehouseRequestDocument req) {

	    GetWarehouseRequest request = req.getGetWarehouseRequest();
	    ADLoginRequest loginReq = request.getADLoginRequest();
	    String serviceType = request.getServiceType();

	    Trx trx = null;
	    MAttachment attachment = null;

	    try {

	        CompiereService m_cs = getCompiereService();
	        m_cs.connect();

	        Properties ctx = m_cs.getCtx();

	        String trxName =
	                Trx.createTrxName(getClass().getName() + "_");

	        trx = Trx.get(trxName, true);
	        trx.start();

	        String err =
	                login(loginReq,
	                        webServiceName,
	                        "mrList",
	                        serviceType);

	        if (err != null && err.length() > 0) {

	            return Response.status(Response.Status.BAD_REQUEST)
	                    .entity("{\"error\":\"" + err + "\"}")
	                    .build();
	        }

	        if (!"mrList".equalsIgnoreCase(serviceType)) {

	            return Response.status(Response.Status.BAD_REQUEST)
	                    .entity("{\"error\":\"Invalid Service Type\"}")
	                    .build();
	        }

	        int warehouseId = loginReq.getWarehouseID();

	        int tableId =
	                MTable.getTable_ID("M_Warehouse");

	        attachment =
	                MAttachment.get(ctx, tableId, warehouseId);

	        if (attachment == null) {

	            return Response.status(Response.Status.NOT_FOUND)
	                    .entity("{\"error\":\"No attachment found\"}")
	                    .build();
	        }

	        MAttachmentEntry[] entries =
	                attachment.getEntries();

	        if (entries == null || entries.length == 0) {

	            return Response.status(Response.Status.NOT_FOUND)
	                    .entity("{\"error\":\"No attachment entries found\"}")
	                    .build();
	        }

	        for (MAttachmentEntry entry : entries) {

	            String fileName = entry.getName();

	            if (fileName != null
	                    && fileName.toLowerCase().endsWith(".json")) {

	                byte[] data = entry.getData();

	                String jsonContent =
	                        new String(
	                                data,
	                                java.nio.charset.StandardCharsets.UTF_8);

	                trx.commit();

	                return Response.ok(jsonContent)
	                        .type(MediaType.APPLICATION_JSON)
	                        .build();
	            }
	        }

	        return Response.status(Response.Status.NOT_FOUND)
	                .entity("{\"error\":\"JSON file not found\"}")
	                .build();

	    } catch (Exception e) {

	        if (trx != null)
	            trx.rollback();

	        e.printStackTrace();

	        return Response.serverError()
	                .entity("{\"error\":\"" + e.getMessage() + "\"}")
	                .build();

	    } finally {

	        if (trx != null)
	            trx.close();

	        getCompiereService().disconnect();
	    }
	}
}
