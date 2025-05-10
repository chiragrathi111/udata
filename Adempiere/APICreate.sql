package org.pipra.webservices.custom;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.stream.Collectors;

import javax.jws.WebService;

import org.compiere.model.MDocType;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutConfirm;
import org.compiere.model.MInOutLine;
import org.compiere.model.MInOutLineConfirm;
import org.compiere.model.MInvoice;
import org.compiere.model.MOrder;
import org.compiere.model.MRMA;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.process.DocAction;
import org.compiere.util.DB;
import org.compiere.util.KeyNamePair;
import org.compiere.util.Login;
import org.compiere.util.Trx;
import org.idempiere.adInterface.x10.ADLoginRequest;
import org.idempiere.adInterface.x10.Client;
import org.idempiere.adInterface.x10.CreateMRRequest;
import org.idempiere.adInterface.x10.CreateMRRequestDocument;
import org.idempiere.adInterface.x10.CreateMRResponse;
import org.idempiere.adInterface.x10.CreateMRResponseDocument;
import org.idempiere.adInterface.x10.LoginApiRequest;
import org.idempiere.adInterface.x10.LoginApiRequestDocument;
import org.idempiere.adInterface.x10.LoginApiResponse;
import org.idempiere.adInterface.x10.LoginApiResponseDocument;
import org.idempiere.adInterface.x10.MRDataResponse;
import org.idempiere.adInterface.x10.MRDataResponseDocument;
import org.idempiere.adInterface.x10.MRFailedRequest;
import org.idempiere.adInterface.x10.MRFailedRequestDocument;
import org.idempiere.adInterface.x10.MRFailedResponce;
import org.idempiere.adInterface.x10.MRFailedResponceDocument;
import org.idempiere.adInterface.x10.MRLine;
import org.idempiere.adInterface.x10.MRLines;
import org.idempiere.adInterface.x10.MRList;
import org.idempiere.adInterface.x10.MRListResponse;
import org.idempiere.adInterface.x10.MRListResponseDocument;
import org.idempiere.adInterface.x10.Organization;
import org.idempiere.adInterface.x10.PODataRequest;
import org.idempiere.adInterface.x10.PODataRequestDocument;
import org.idempiere.adInterface.x10.PODataResponse;
import org.idempiere.adInterface.x10.PODataResponseDocument;
import org.idempiere.adInterface.x10.POListAccess;
import org.idempiere.adInterface.x10.POListRequest;
import org.idempiere.adInterface.x10.POListRequestDocument;
import org.idempiere.adInterface.x10.POListResponse;
import org.idempiere.adInterface.x10.POListResponseDocument;
import org.idempiere.adInterface.x10.ProductData;
import org.idempiere.adInterface.x10.Role;
import org.idempiere.adInterface.x10.RoleAppAcess;
import org.idempiere.adInterface.x10.RoleConfigureRequest;
import org.idempiere.adInterface.x10.RoleConfigureRequestDocument;
import org.idempiere.adInterface.x10.RoleConfigureResponse;
import org.idempiere.adInterface.x10.RoleConfigureResponseDocument;
import org.idempiere.adInterface.x10.Warehouse;
import org.idempiere.adinterface.CompiereService;
import org.idempiere.customization.model.MInOutLineConfirm_Custom;
import org.idempiere.webservices.AbstractService;

@WebService(endpointInterface = "org.pipra.webservices.custom.PipraCustomWebservice", serviceName = "PipraCustomWebservice", targetNamespace = "http://idempiere.org/ADInterface/1_0")
public class PipraCustomWebserviceImpl extends AbstractService implements PipraCustomWebservice {

	public static final String ROLE_TYPES_WEBSERVICE = "NULL,WS,SS";
	private static String webServiceName = new String("PipraCustomWebservice");

	private boolean manageTrx = true;

	public boolean isManageTrx() {
		return manageTrx;
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
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return loginApiResponseDocument;
	}

	@Override
	public RoleConfigureResponseDocument roleConfig(RoleConfigureRequestDocument roleConfigureRequestDocument) {
		String purchase_order = "Purchase Order";
		String material_receipt = "Material Receipt";
		String physical_inventory = "Physical Inventory";
		String sales_order = "Sales Order";

		RoleConfigureResponseDocument roleConfigureResponseDocument = RoleConfigureResponseDocument.Factory
				.newInstance();
		RoleConfigureResponse roleResponse = roleConfigureResponseDocument.addNewRoleConfigureResponse();
		List<String> roleAccess = new ArrayList<>();

		RoleConfigureRequest roleRequest = roleConfigureRequestDocument.getRoleConfigureRequest();
		ADLoginRequest loginReq = roleRequest.getADLoginRequest();
		try {
			getCompiereService().connect();
			int roleIds = loginReq.getRoleID();
			int clientIds = loginReq.getClientID();
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

			String query = "select e.name as Access_Window from ad_user_roles a\n"
					+ "join ad_role b on a.ad_role_id = b.ad_role_id\n"
					+ "join ad_user c on a.ad_user_id = c.ad_user_id\n"
					+ "join ad_window_access d on a.ad_role_id = d.ad_role_id\n"
					+ "join ad_window e on d.ad_window_id = e.ad_window_id\n" + "where b.ad_role_id = " + roleIds
					+ " and c.ad_client_id = " + clientIds + "";

			PreparedStatement pstm = null;
			ResultSet rs = null;

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String roleAccessWindow = rs.getString("Access_Window");
				roleAccess.add(roleAccessWindow);
			}
			rs.close();
			pstm.close();

			List<RoleAppAcess> rsList = new ArrayList<>();
			rsList.add(createRoleAppAcess(purchase_order, false));
			rsList.add(createRoleAppAcess(sales_order, false));
			rsList.add(createRoleAppAcess(material_receipt, false));
			rsList.add(createRoleAppAcess(physical_inventory, false));

			for (String roleData : roleAccess) {
				for (RoleAppAcess existingRole : rsList) {
					if (existingRole.getAppName().equals(roleData)) {
						existingRole.setAppAcess(true);
						break;
					}
				}
			}

			for (RoleAppAcess existingRole : rsList) {
				existingRole.setAppName(existingRole.getAppName().equalsIgnoreCase("Purchase Order") ? "recieveApp"
						: existingRole.getAppName());
				existingRole.setAppName(existingRole.getAppName().equalsIgnoreCase("Material Receipt") ? "qcCheckApp"
						: existingRole.getAppName());
				existingRole
						.setAppName(existingRole.getAppName().equalsIgnoreCase("Physical Inventory") ? "stockCheckApp"
								: existingRole.getAppName());
				existingRole.setAppName(existingRole.getAppName().equalsIgnoreCase("Sales Order") ? "dispatchApp"
						: existingRole.getAppName());

			}
			RoleAppAcess[] roleAppAccessArray = rsList.toArray(new RoleAppAcess[rsList.size()]);
			roleResponse.setAppAcessArray(roleAppAccessArray);

		} catch (Exception e) {
			roleResponse.setError(e.getMessage());
			roleResponse.setIsError(true);
			return roleConfigureResponseDocument;
		} finally {
			getCompiereService().disconnect();
		}
		return roleConfigureResponseDocument;
	}

	private RoleAppAcess createRoleAppAcess(String appName, boolean appAccess) {
		RoleAppAcess roleAppAccess = RoleAppAcess.Factory.newInstance();
		roleAppAccess.setAppName(appName);
		roleAppAccess.setAppAcess(appAccess);
		return roleAppAccess;
	}

	@Override
	public POListResponseDocument poList(POListRequestDocument pOListRequestDocument) {
		Trx trx = null;
		List<POListAccess> poLists = new ArrayList<>();
		POListResponseDocument pOListResponseDocument = POListResponseDocument.Factory.newInstance();
		POListResponse listResponse = pOListResponseDocument.addNewPOListResponse();

		POListRequest pOListRequest = pOListRequestDocument.getPOListRequest();
		ADLoginRequest loginReq = pOListRequest.getADLoginRequest();
		String serviceType = pOListRequest.getServiceType();
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
			
			String query = "SELECT\n"
					+ "    DISTINCT(po.documentno) AS purchase_order,\n"
					+ "    bp.name AS Supplier,\n"
					+ "    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name,\n"
					+ "    po.description,\n"
					+ "    po.ad_org_id,\n"
					+ "    CASE\n"
					+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n"
					+ "    END AS status\n"
					+ "FROM c_order po\n"
					+ "JOIN c_orderline pol ON po.c_order_id = pol.c_order_id\n"
					+ "LEFT JOIN m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "WHERE pol.qtyordered > (\n"
					+ "        SELECT COALESCE(SUM(iol.qtyentered), 0)\n"
					+ "        FROM m_inoutline iol\n"
					+ "        WHERE iol.c_orderline_id = pol.c_orderline_id\n"
					+ "    ) and po.ad_client_id = "+client_id+" and po.docstatus = 'CO' and po.ad_org_id IN ("+orgIds+");\n"
					+ "";
			PreparedStatement pstm = null;
			ResultSet rs = null;

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String documentNo = rs.getString("Purchase_Order");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				boolean Status = rs.getBoolean("status");

				poLists.add(createPOList(documentNo, supplier, date, warehouseName, description, Status));
			}
			POListAccess[] polistArray = poLists.toArray(new POListAccess[poLists.size()]);
			listResponse.setListAccessArray(polistArray);

		} catch (Exception e) {
			listResponse.setError(e.getMessage());
			return pOListResponseDocument;

		} finally {
			if (manageTrx && trx != null) {
				trx.close();
				getCompiereService().disconnect();
			}
		}
		pOListResponseDocument.setPOListResponse(listResponse);
		return pOListResponseDocument;
	}

	private POListAccess createPOList(String docNo, String supplier, String date, String warehouseName,
			String description, boolean status) {
		POListAccess poListAccess = POListAccess.Factory.newInstance();
		poListAccess.setDocumentNumber(docNo);
		poListAccess.setSupplierName(supplier);
		poListAccess.setOrderDate(date);
		poListAccess.setWarehouseName(warehouseName);
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
			query = "SELECT (a.qtyordered - COALESCE(SUM(c.qtyentered), 0)) AS outstanding_qty, e.m_product_id as productId, a.c_order_id, a.c_uom_id, a.c_orderline_id, e.name AS product_name\n"
					+ "FROM c_orderline a \n" + "JOIN c_order d ON d.c_order_id = a.c_order_id \n"
					+ "LEFT JOIN m_inout b ON a.c_order_id = b.c_order_id \n"
					+ "LEFT JOIN m_inoutline c ON c.m_inout_id = b.m_inout_id AND c.m_product_id = a.m_product_id\n"
					+ "JOIN m_product e ON e.m_product_id = a.m_product_id \n" + "WHERE d.documentno = '" + documentNo
					+ "' AND d.ad_client_id = '" + client_ID + "' AND a.c_order_id = (\n"
					+ "  SELECT c_order_id FROM c_order WHERE documentno = '" + documentNo + "' AND ad_client_id = '"
					+ client_ID + "'\n" + ")\n"
					+ "GROUP BY e.m_product_id, e.name, a.qtyordered, a.c_orderline_id, a.c_uom_id, a.c_order_id;\n"
					+ "";
			PreparedStatement pstm = null;
			ResultSet rs = null;

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int qnty = 0;
			int cOrderId = 0;
			while (rs.next()) {
				ProductData productData = pODataResponse.addNewProductData();
				int outstandingQty = rs.getInt("outstanding_qty");
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
				qnty += Integer.valueOf(outstandingQty);

			}
			pODataResponse.setCOrderId(cOrderId);
			pODataResponse.setOverallQnty(qnty);
			pstm.close();
			rs.close();

			query = "SELECT\n" + "	TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n" + "	bp.name AS Supplier,\n"
					+ "	wh.name AS Warehouse_Name,\n" + "	po.description,\n" + "	ml.m_locator_id\n"
					+ "FROM adempiere.c_order po\n"
					+ "JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id	\n"
					+ "JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "join adempiere.m_locator ml on ml.m_warehouse_id = wh.m_warehouse_id\n"
					+ "WHERE po.documentno = '" + documentNo + "' and isDefault = 'Y';";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String orderDate = rs.getString("Order_Date");
				String supplier = rs.getString("Supplier");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				int mLocatorId = rs.getInt("m_locator_id");
				pODataResponse.setOrderDate(orderDate);
				pODataResponse.setSupplier(supplier);
				pODataResponse.setWarehouseName(warehouseName);
				pODataResponse.setDescription(description);
				pODataResponse.setDefaultLocatorId(mLocatorId);
			}
			pstm.close();
			rs.close();
		} catch (Exception e) {
			pODataResponse.setError(e.getMessage());
			pODataResponse.setIsError(true);
			return pODataResponseDocument;

		} finally {
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
		try {
			CompiereService m_cs = getCompiereService();
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

			Properties ctx = m_cs.getCtx();
			MTable table = MTable.get(ctx, "c_order");
			PO po = table.getPO(cOrderId, trx.getTrxName());
			if (po == null) {
				createMRResponse.setError("order not found for " + cOrderId + "");
				createMRResponse.setIsError(true);
				return createMRResponseDocument;
			}
			MOrder order = (MOrder) po;
			MTable docTypeTable = MTable.get(ctx, "c_doctype");
			PO docTypePO = docTypeTable.getPO("name = 'MM Receipt' and ad_client_id = " + clientID + "",
					trx.getTrxName());
			MDocType mDocType = (MDocType) docTypePO;

			MInOut receipt = new MInOut(order, mDocType.get_ID(), order.getDateOrdered());
			receipt.setDocStatus(DocAction.STATUS_Drafted);
			receipt.saveEx();

			MInOut inout = new MInOut(ctx, receipt.getM_InOut_ID(), trx.getTrxName());
			MRLines[] MRLinesArray = createMRRequest.getMRLinesArray();
			for (MRLines data : MRLinesArray) {
				int C_InvoiceLine_ID = 0;
				int M_RMALine_ID = 0;
				int M_Product_ID = data.getProductId();
				int C_UOM_ID = data.getUomId();
				int C_OrderLine_ID = data.getCOrderlineId();
				BigDecimal QtyEntered = BigDecimal.valueOf(data.getQnty());
				int M_Locator_ID = data.getLocator();

				inout.createLineFrom(C_OrderLine_ID, C_InvoiceLine_ID, M_RMALine_ID, M_Product_ID, C_UOM_ID, QtyEntered,
						M_Locator_ID);
			}
			inout.updateFrom(order, m_invoice, m_rma);
			trx.commit();
			createMRResponse.setIsError(false);
			createMRResponse.setMrDocumentNumber(inout.getDocumentNo());
			createMRResponse.setMrId(inout.get_ID());
		} catch (Exception e) {
			createMRResponse.setError(e.getMessage());
			createMRResponse.setIsError(true);
			return createMRResponseDocument;

		} finally {
			getCompiereService().disconnect();
			trx.close();
		}

		return createMRResponseDocument;
	}

	@Override
	public MRListResponseDocument getMrList(POListRequestDocument pOListRequestDocument) {

		MRListResponseDocument mRListResponseDocument = MRListResponseDocument.Factory.newInstance();
		MRListResponse listResponse = mRListResponseDocument.addNewMRListResponse();
		POListRequest pOListRequest = pOListRequestDocument.getPOListRequest();
		ADLoginRequest loginReq = pOListRequest.getADLoginRequest();
		String serviceType = pOListRequest.getServiceType();
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
			PreparedStatement pstm = null;
			ResultSet rs = null;

			String query ="SELECT\n"
					+ "    DISTINCT(po.documentno) AS documentNo,\n"
					+ "    bp.name AS Supplier,\n"
					+ "    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n"
					+ "    wh.name AS Warehouse_Name,\n"
					+ "    po.description,\n"
					+ "	co.documentno as orderDocumentno\n"
					+ "FROM m_inout po\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
					+ "JOIN c_order co on co.c_order_id = po.c_order_id\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "WHERE po.ad_client_id = "+clientId+" AND po.docstatus = 'DR' AND po.ad_org_id IN ("+orgIds+");";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int count = 0;
			while (rs.next()) {
				MRList mRList = listResponse.addNewMRList();
				String documentNo = rs.getString("documentNo");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String orderDocumentno = rs.getString("orderDocumentno");
				String warehouseName = rs.getString("Warehouse_Name");
				String description = rs.getString("description");
				mRList.setDocumentNo(documentNo);
				mRList.setSupplier(supplier);
				mRList.setOrderDate(date);
				mRList.setWarehouseName(warehouseName);
				mRList.setOrderDocumentno(orderDocumentno);
				mRList.setDescription(description);
				count++;
			}
			listResponse.setCount(count);
		} catch (SQLException e) {
			listResponse.setIsError(true);
			listResponse.setError(e.getMessage());
			return mRListResponseDocument;
			} finally {
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
		try {
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
			PreparedStatement pstm = null;
			ResultSet rs = null;

			String query = "SELECT\n"
					+ "    bp.name AS Supplier,\n"
					+ "    TO_CHAR(mi.dateordered, 'DD-MM-YYYY') AS Order_Date,\n"
					+ "    ml.movementqty,\n"
					+ "    wh.name AS Warehouse_Name,\n"
					+ "    mi.description,\n"
					+ "    ml.m_inoutline_id,\n"
					+ "	co.documentno as orderDocumentno\n"
					+ "FROM m_inoutline ml\n"
					+ "JOIN m_inout mi ON mi.m_inout_id = ml.m_inout_id\n"
					+ "JOIN c_bpartner bp ON mi.c_bpartner_id = bp.c_bpartner_id\n"
					+ "JOIN m_warehouse wh ON mi.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN c_order co on mi.c_order_id = co.c_order_id\n"
					+ "WHERE mi.documentNo = '"+documentNo+"' AND mi.ad_client_id = "+clientId+";";

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			int count = 0;
			String supplier = null;
			String description = null;
			String warehouseName = null;
			String orderDocumentno = null;
			String date = null;
			if(!rs.next()) {
				listResponse.setIsError(true);
				listResponse.setError("Invalid Document No : "+documentNo+"");
				return mRDataResponseDocument;
			}
			while (rs.next()) {
				MRLine mRLine = listResponse.addNewMRLines();
				supplier = rs.getString("Supplier");
				date = rs.getString("Order_Date");
				warehouseName = rs.getString("Warehouse_Name");
				description = rs.getString("description");
				int receivedQnty = rs.getInt("movementqty");
				int mInoutlineId = rs.getInt("m_inoutline_id");
				orderDocumentno = rs.getString("orderDocumentno");
				mRLine.setMRLineId(mInoutlineId);
				mRLine.setRecievedQnty(receivedQnty);
				count += receivedQnty;
			}
			listResponse.setDocumentNo(documentNo);
			listResponse.setOrderDocumentno(orderDocumentno);
			listResponse.setSupplier(supplier);
			listResponse.setOrderDate(date);
			listResponse.setWarehouseName(warehouseName);
			listResponse.setDescription(description);
			listResponse.setOverallQnty(count);

		} catch (SQLException e) {
			listResponse.setIsError(true);
			listResponse.setError(e.getMessage());
			return mRDataResponseDocument;
			} finally {
			getCompiereService().disconnect();
		}
		return mRDataResponseDocument;
	}

	@Override
	public MRFailedResponceDocument createFailedQty(MRFailedRequestDocument mRFailedRequestDocument) {
		MRFailedResponceDocument mRFailedResponceDocument = MRFailedResponceDocument.Factory.newInstance();
		MRFailedResponce mRFailedResponce = mRFailedResponceDocument.addNewMRFailedResponce();
		MRFailedRequest mRFailedRequest = mRFailedRequestDocument.getMRFailedRequest();
		ADLoginRequest loginReq = mRFailedRequest.getADLoginRequest();
		String serviceType = mRFailedRequest.getServiceType();
		int mInOutID = mRFailedRequest.getMInOutID();
		int failedQty = mRFailedRequest.getFaieldQty();
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
			if (po == null) {
				mRFailedResponce.setError("order not found for " + mInOutID + "");
				mRFailedResponce.setIsError(true);
				return mRFailedResponceDocument;
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
				
				int confirmID = lineConfirm.get_ID();
				MInOutLineConfirm_Custom custom = new MInOutLineConfirm_Custom(ctx, confirmID, trx.getTrxName());
				BigDecimal failedB = new BigDecimal(failedQty);
				custom.processLine(false, "PC");
				custom.setQCFailedQty(failedB);
				custom.saveEx();
				lineConfirm.saveEx();	
			}
			mInOutConfirm.setDocStatus(MInOutConfirm.DOCSTATUS_Completed);
			mInOutConfirm.saveEx();
			trx.commit();
			
			mRFailedResponce.setIsError(false);
			mRFailedResponce.setCreateConfirmationDocumentNumber(mInOutConfirm.getDocumentNo());
			mRFailedResponce.setCreateConfirmationId(mInOutConfirm.get_ID());
				
		}catch(Exception e) {
			mRFailedResponce.setIsError(true);
			mRFailedResponce.setError(e.getMessage());
			return mRFailedResponceDocument;	
		}finally {
			getCompiereService().disconnect();
			trx.close();
		}
		return mRFailedResponceDocument;
	}
}
=======================================
package org.pipra.webservices.custom;

import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.ParameterStyle;
import javax.jws.soap.SOAPBinding.Style;
import javax.jws.soap.SOAPBinding.Use;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;

import org.idempiere.adInterface.x10.CreateMRRequestDocument;
import org.idempiere.adInterface.x10.CreateMRResponseDocument;
import org.idempiere.adInterface.x10.LoginApiRequestDocument;
import org.idempiere.adInterface.x10.LoginApiResponseDocument;
import org.idempiere.adInterface.x10.MRDataResponseDocument;
import org.idempiere.adInterface.x10.MRListResponseDocument;
import org.idempiere.adInterface.x10.PODataRequestDocument;
import org.idempiere.adInterface.x10.PODataResponseDocument;
import org.idempiere.adInterface.x10.POListRequestDocument;
import org.idempiere.adInterface.x10.POListResponseDocument;
import org.idempiere.adInterface.x10.RoleConfigureRequestDocument;
import org.idempiere.adInterface.x10.RoleConfigureResponseDocument;
import org.idempiere.adInterface.x10.MRFailedRequestDocument;
import org.idempiere.adInterface.x10.MRFailedResponceDocument;

@Path("/pipra_customservice/")
@Consumes({ "application/xml", "application/json" })
@Produces({ "application/xml", "application/json" })
@WebService(targetNamespace = "http://idempiere.org/ADInterface/1_0")
@SOAPBinding(style = Style.RPC, use = Use.LITERAL, parameterStyle = ParameterStyle.WRAPPED)
public interface PipraCustomWebservice {

	@POST
	@Path("/login_api")
	public LoginApiResponseDocument loginApi(LoginApiRequestDocument req);

	@POST
	@Path("/role_configure")
	public RoleConfigureResponseDocument roleConfig(RoleConfigureRequestDocument req);

	@POST
	@Path("/po_list")
	public POListResponseDocument poList(POListRequestDocument req);

	@POST
	@Path("/po_data")
	public PODataResponseDocument poData(PODataRequestDocument req);

	@POST
	@Path("/create_mr")
	public CreateMRResponseDocument createMR(CreateMRRequestDocument req);
	
	@POST
	@Path("/mr_list")
	public MRListResponseDocument getMrList(POListRequestDocument req);
	
	@POST
	@Path("/mr_data")
	public MRDataResponseDocument getMrData(PODataRequestDocument req);
	
	@POST
	@Path("/mr_failed")
	public MRFailedResponceDocument createFailedQty(MRFailedRequestDocument req);
}
==================================================================
<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  targetNamespace="http://idempiere.org/ADInterface/1_0"
  xmlns:tns="http://idempiere.org/ADInterface/1_0"
  elementFormDefault="qualified">

   <xsd:element name="WindowTabData" type="tns:WindowTabData"/>

   <xsd:complexType name="WindowTabData">
   	<xsd:sequence>
   		<xsd:element name="DataSet" type="tns:DataSet" minOccurs="0" maxOccurs="1"/>
   		<xsd:element name="RowCount" type="xsd:int" minOccurs="0" maxOccurs="1"/>   		
   		<xsd:element name="Success" type="xsd:boolean" minOccurs="0" maxOccurs="1"/>
   		<xsd:element name="Error" type="xsd:string" minOccurs="0" maxOccurs="1"/>
   		<xsd:element name="ErrorInfo" type="xsd:string" minOccurs="0" maxOccurs="1"/>
   		<xsd:element name="Status" type="xsd:string" minOccurs="0" maxOccurs="1"/>
   		<xsd:element name="StatusError" type="xsd:boolean" minOccurs="0" maxOccurs="1"/>
   	</xsd:sequence>
   	<xsd:attribute name="NumRows" type="xsd:int" />
   	<xsd:attribute name="TotalRows" type="xsd:int" />   	
   	<xsd:attribute name="StartRow" type="xsd:int" />    	
   </xsd:complexType>

   <xsd:complexType name="DataSet">
   	<xsd:sequence>
   		<xsd:element name="DataRow" type="tns:DataRow" minOccurs="0" maxOccurs="unbounded"/>
   	</xsd:sequence>
   </xsd:complexType>


   <xsd:complexType name="DataRow">
   	<xsd:sequence>
   		<xsd:element name="field" type="tns:DataField" minOccurs="0" maxOccurs="unbounded"/>
   	</xsd:sequence>
   </xsd:complexType>

   <xsd:complexType name="DataField">
   	<xsd:sequence>
 	  		<xsd:element name="val" type="xsd:string" />
 	  		<xsd:element name="lookup" type="tns:LookupValues" minOccurs="0" maxOccurs="1"/>
   	</xsd:sequence>
   	<xsd:attribute name="type" type="xsd:string" use="optional"/>
   	<xsd:attribute name="column" type="xsd:string" />   	
   	<xsd:attribute name="lval" type="xsd:string" use="optional"/>
   	<xsd:attribute name="disp" type="xsd:boolean" use="optional"/>
   	<xsd:attribute name="edit" type="xsd:boolean" use="optional"/>
   	<xsd:attribute name="error" type="xsd:boolean" use="optional"/>
   	<xsd:attribute name="errorVal" type="xsd:string" use="optional"/>
   </xsd:complexType>

   <xsd:complexType name="LookupValues">
   	<xsd:sequence>
   		<xsd:element name="lv" type="tns:LookupValue" minOccurs="0" maxOccurs="unbounded"/>
   	</xsd:sequence>
   </xsd:complexType>

   <xsd:complexType name="LookupValue">
   	<xsd:sequence>
   	</xsd:sequence>
   	<xsd:attribute name="val" type="xsd:string"/>
   	<xsd:attribute name="key" type="xsd:string"/>
   </xsd:complexType>

   <xsd:element name="GetProcessParams" type="tns:GetProcessParams"/>
   <xsd:element name="ProcessParams" type="tns:ProcessParams"/>
   <xsd:element name="RunProcess" type="tns:RunProcess"/>
   <xsd:element name="RunProcessResponse" type="tns:RunProcessResponse"/>

   <xsd:complexType name="ProcessParams">
   	<xsd:sequence>
   	  <xsd:element name="Params" type="tns:ProcessParamList" />
	  <xsd:element name="Description" type="xsd:string"/>   	
	  <xsd:element name="Name" type="xsd:string"/>   	
	  <xsd:element name="Help" type="xsd:string"/>   	  	
   	</xsd:sequence>
   	<xsd:attribute name="AD_Process_ID" type="xsd:int"/>
   </xsd:complexType>

   <xsd:complexType name="GetProcessParams">
   	<xsd:sequence>
   	</xsd:sequence>
   	<xsd:attribute name="AD_Process_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Menu_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Record_ID" type="xsd:int"/> 	
   </xsd:complexType>

   <xsd:complexType name="RunProcess">
   <xsd:sequence>
   	<xsd:element name="ParamValues" type="tns:DataRow"/>
   </xsd:sequence>
   	<xsd:attribute name="AD_Process_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Menu_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Record_ID" type="xsd:int"/> 	
   	<xsd:attribute name="DocAction" type="xsd:string"/>
   </xsd:complexType>

   <xsd:complexType name="RunProcessResponse">
   <xsd:sequence>
   	<xsd:element name="Error" type="xsd:string"/>   	
   	<xsd:element name="Summary" type="xsd:string"/>
   	<xsd:element name="LogInfo" type="xsd:string"/>
   	<xsd:element name="Data" type="xsd:hexBinary"/>
   </xsd:sequence>
   <xsd:attribute name="IsError" type="xsd:boolean"/>
   <xsd:attribute name="IsReport" type="xsd:boolean"/>
   <xsd:attribute name="ReportFormat" type="xsd:string"/>
   </xsd:complexType>


   <xsd:complexType name="ProcessParamList">
   	<xsd:sequence>
   		<xsd:element name="Param" type="tns:ProcessParam" minOccurs="0" maxOccurs="unbounded"/>
   	</xsd:sequence>
   </xsd:complexType>

   <xsd:complexType name="ProcessParam">
   	<xsd:sequence>
   		<xsd:element name="Description" type="xsd:string"/>
	   	<xsd:element name="Help" type="xsd:string"/>   	
 		<xsd:element name="lookup" type="tns:LookupValues" minOccurs="0" maxOccurs="1"/>
   	</xsd:sequence>
   	<xsd:attribute name="Name" type="xsd:string"/>
   	<xsd:attribute name="DefaultValue" type="xsd:string"/>	
   	<xsd:attribute name="DefaultValue2" type="xsd:string"/>	
   	<xsd:attribute name="IsMandatory" type="xsd:boolean"/>
   	<xsd:attribute name="IsRange" type="xsd:boolean"/>   	
   	<xsd:attribute name="FieldLength" type="xsd:int"/>
   	<xsd:attribute name="DisplayType" type="xsd:int"/>   	   	
	<xsd:attribute name="ColumnName" type="xsd:string"/>    	
   </xsd:complexType>


<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest"/>
<xsd:element name="ADLoginResponse" type="tns:ADLoginResponse"/>

<xsd:complexType name="ADLoginRequest">
<xsd:sequence>
  <xsd:element name="user" type="xsd:string"/>
  <xsd:element name="pass" type="xsd:string"/>
  <xsd:element name="lang" type="xsd:string"/>
  <xsd:element name="ClientID" type="xsd:int"/>
  <xsd:element name="RoleID" type="xsd:int"/>
  <xsd:element name="OrgID" type="xsd:int"/>
  <xsd:element name="WarehouseID" type="xsd:int"/>
  <xsd:element name="stage" type="xsd:int" />
</xsd:sequence>
</xsd:complexType>

<xsd:complexType name="ADLoginResponse">
<xsd:sequence>
  <xsd:element name="status" type="xsd:int"/>
  <xsd:element name="roles" type="tns:LookupValues"/>
  <xsd:element name="langs" type="tns:LookupValues"/>
  <xsd:element name="orgs" type="tns:LookupValues"/>
  <xsd:element name="clients" type="tns:LookupValues"/>
  <xsd:element name="warehouses" type="tns:LookupValues"/>
</xsd:sequence>
</xsd:complexType>

	<xsd:complexType name="StandardResponse">
		<xsd:sequence>
			<xsd:element name="Error" type="xsd:string" minOccurs="0" />
			<xsd:element name="outputFields" type="tns:outputFields" minOccurs="0" maxOccurs="unbounded"/>
			<xsd:element name="RunProcessResponse" type="tns:RunProcessResponse"  minOccurs="0"/>
			<xsd:element name="WindowTabData" type="tns:WindowTabData"   minOccurs="0"/>
		</xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
		<xsd:attribute name="IsRolledBack" type="xsd:boolean" />
		<xsd:attribute name="RecordID" type="xsd:int" />
	</xsd:complexType>

	<xsd:complexType name="outputFields">
		<xsd:sequence>
			<xsd:element name="outputField" type="tns:outputField" maxOccurs="unbounded"/>
		</xsd:sequence>
	</xsd:complexType>
	<xsd:complexType name="outputField">
		<xsd:attribute name="column" type="xsd:string" />
		<xsd:attribute name="value" type="xsd:string" />
		<xsd:attribute name="Text" type="xsd:string" />
	</xsd:complexType>


<xsd:element name="StandardResponse" type="tns:StandardResponse"/>

<!-- Elements added for model web services -->

   <xsd:element name="ModelSetDocActionRequest" type="tns:ModelSetDocActionRequest"/>

   <xsd:complexType name="ModelSetDocAction">
   <xsd:sequence>
     <xsd:element name="serviceType" type="xsd:string"/>
     <xsd:element name="tableName" type="xsd:string"/>
     <xsd:element name="recordID" type="xsd:int"/>
     <xsd:element name="recordIDVariable" type="xsd:string" minOccurs="0"/>
     <xsd:element name="docAction" type="xsd:string"/>
   </xsd:sequence>
   </xsd:complexType>
 
   <xsd:complexType name="ModelSetDocActionRequest">
   <xsd:sequence>
     <xsd:element name="ModelSetDocAction" type="tns:ModelSetDocAction" minOccurs="1" maxOccurs="1"/>
     <xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
   </xsd:sequence>
   </xsd:complexType>

   <xsd:element name="ModelRunProcess" type="tns:ModelRunProcess"/>

   <xsd:complexType name="ModelRunProcess">
    <xsd:sequence>
      <xsd:element name="serviceType" type="xsd:string"/>
   	  <xsd:element name="ParamValues" type="tns:DataRow"/>
    </xsd:sequence>
   	<xsd:attribute name="AD_Process_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Menu_ID" type="xsd:int"/>
   	<xsd:attribute name="AD_Record_ID" type="xsd:int"/> 	
   	<xsd:attribute name="DocAction" type="xsd:string"/>
   </xsd:complexType>

   <xsd:element name="ModelRunProcessRequest" type="tns:ModelRunProcessRequest"/>

   <xsd:complexType name="ModelRunProcessRequest">
   <xsd:sequence>
     <xsd:element name="ModelRunProcess" type="tns:ModelRunProcess" minOccurs="1" maxOccurs="1"/>
     <xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
   </xsd:sequence>
   </xsd:complexType>

   <xsd:element name="ModelGetListRequest" type="tns:ModelGetListRequest"/>

   <xsd:complexType name="ModelGetList">
   <xsd:sequence>
     <xsd:element name="serviceType" type="xsd:string"/>
     <xsd:element name="AD_Reference_ID" type="xsd:int"/>
     <xsd:element name="Filter" type="xsd:string"/>
   </xsd:sequence>
   </xsd:complexType>

   <xsd:complexType name="ModelGetListRequest">
   <xsd:sequence>
     <xsd:element name="ModelGetList" type="tns:ModelGetList" minOccurs="1" maxOccurs="1"/>
     <xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
   </xsd:sequence>
   </xsd:complexType>

   <xsd:element name="ModelCRUDRequest" type="tns:ModelCRUDRequest"/>

   <xsd:complexType name="ModelCRUD">
   <xsd:sequence>
     <xsd:element name="serviceType" type="xsd:string"/>
     <xsd:element name="TableName" type="xsd:string"/>
     <xsd:element name="RecordID" type="xsd:int"/>
     <xsd:element name="recordIDVariable" type="xsd:string" minOccurs="0"/>
     <xsd:element name="Filter" type="xsd:string"  minOccurs="0" maxOccurs="1"/>
     <xsd:element name="Action">
     	<xsd:simpleType>
     		<xsd:restriction base="xsd:string">
     			<xsd:enumeration value="Create"></xsd:enumeration>
     			<xsd:enumeration value="Read"></xsd:enumeration>
     			<xsd:enumeration value="Update"></xsd:enumeration>
     			<xsd:enumeration value="Delete"></xsd:enumeration>
     			<xsd:enumeration value="CreateUpdate"></xsd:enumeration>
     		</xsd:restriction>
     	</xsd:simpleType>
     </xsd:element>
     <xsd:element name="Offset" type="xsd:int" maxOccurs="1" minOccurs="0"/>
     <xsd:element name="Limit" type="xsd:int" maxOccurs="1" minOccurs="0"/>
     <xsd:element name="DataRow" type="tns:DataRow" minOccurs="0" maxOccurs="1"/>
   </xsd:sequence>
   </xsd:complexType>

   <xsd:complexType name="ModelCRUDRequest">
   <xsd:sequence>
     <xsd:element name="ModelCRUD" type="tns:ModelCRUD" minOccurs="1" maxOccurs="1"/>
     <xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
   </xsd:sequence>
 </xsd:complexType>


	<xsd:complexType name="operations">
		<xsd:sequence>
			<xsd:element name="operation" type="tns:operation" minOccurs="1" maxOccurs="unbounded"></xsd:element>
		</xsd:sequence>
	</xsd:complexType>
	
	<xsd:complexType name="operation">
		<xsd:sequence>
			<xsd:element name="TargetPort">
		     	<xsd:simpleType>
		     		<xsd:restriction base="xsd:string">
		     			<xsd:enumeration value="createData"></xsd:enumeration>
		     			<xsd:enumeration value="readData"></xsd:enumeration>
		     			<xsd:enumeration value="updateData"></xsd:enumeration>
		     			<xsd:enumeration value="deleteData"></xsd:enumeration>
		     			<xsd:enumeration value="runProcess"></xsd:enumeration>
		     			<xsd:enumeration value="setDocAction"></xsd:enumeration>
		     			<xsd:enumeration value="createUpdateData"></xsd:enumeration>
		     			<xsd:enumeration value="loginApi"></xsd:enumeration>
		     		</xsd:restriction>
		     	</xsd:simpleType>
		     </xsd:element>
			<xsd:element name="ModelCRUD" type="tns:ModelCRUD" minOccurs="0"></xsd:element>
			<xsd:element name="ModelSetDocAction" type="tns:ModelSetDocAction" minOccurs="0"></xsd:element>
			<xsd:element name="LoginApiRequest" type="tns:LoginApiRequest" minOccurs="0"></xsd:element>
			<xsd:element name="LoginApiResponse" type="tns:LoginApiResponse" minOccurs="0"></xsd:element>			
			<xsd:element name="ModelRunProcess" type="tns:ModelRunProcess" minOccurs="0"></xsd:element>
		</xsd:sequence>
		<xsd:attribute name="preCommit" type="xsd:boolean" default="false"></xsd:attribute>
		<xsd:attribute name="postCommit" type="xsd:boolean" default="false"></xsd:attribute>
	</xsd:complexType>
	<xsd:element name="CompositeRequest" type="tns:CompositeRequest"></xsd:element>
	<xsd:complexType name="CompositeRequest">
		<xsd:sequence>
			<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest"></xsd:element>
		     <xsd:element name="serviceType" type="xsd:string"/>
			<xsd:element name="operations" type="tns:operations" maxOccurs="unbounded"></xsd:element>
		</xsd:sequence>
	</xsd:complexType>


<xsd:element name="CompositeResponses" type="tns:CompositeResponses"></xsd:element>

<xsd:complexType name="CompositeResponses">
	<xsd:sequence>
		<xsd:element name="CompositeResponse" type="tns:CompositeResponse" minOccurs="0" maxOccurs="unbounded"></xsd:element>
	</xsd:sequence>
</xsd:complexType>


<xsd:complexType name="CompositeResponse">
	<xsd:sequence>
		<xsd:element name="StandardResponse" type="tns:StandardResponse" minOccurs="1" maxOccurs="unbounded"></xsd:element>
	</xsd:sequence>
</xsd:complexType>

<xsd:element name="LoginApiRequest" type="tns:LoginApiRequest"></xsd:element>
<xsd:element name="LoginApiResponse" type="tns:LoginApiResponse"></xsd:element>
<xsd:element name="RoleConfigureRequest" type="tns:RoleConfigureRequest"></xsd:element>
<xsd:element name="RoleConfigureResponse" type="tns:RoleConfigureResponse"></xsd:element>
<xsd:element name="POListRequest" type="tns:POListRequest"></xsd:element>
<xsd:element name="POListResponse" type="tns:POListResponse"></xsd:element>
<xsd:element name="PODataRequest" type="tns:PODataRequest"></xsd:element>
<xsd:element name="PODataResponse" type="tns:PODataResponse"></xsd:element>
<xsd:element name="CreateMRRequest" type="tns:CreateMRRequest"></xsd:element>
<xsd:element name="CreateMRResponse" type="tns:CreateMRResponse"></xsd:element>
<xsd:element name="MRListResponse" type="tns:MRListResponse"></xsd:element>
<xsd:element name="MRDataResponse" type="tns:MRDataResponse"></xsd:element>
<xsd:element name="MRFailedRequest" type="tns:MRFailedRequest"></xsd:element>
<xsd:element name="MRFailedResponce" type="tns:MRFailedResponce"></xsd:element>
	
<xsd:complexType name="LoginApiRequest">
  <xsd:sequence>
    <xsd:element name="serviceType" type="xsd:string"/>
    <xsd:element name="user" type="xsd:string" />
    <xsd:element name="password" type="xsd:string" />
  </xsd:sequence>
</xsd:complexType>

  <xsd:complexType name="LoginApiResponse">
    <xsd:sequence>
		<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="Client" type="tns:Client" minOccurs="0" maxOccurs="unbounded"></xsd:element>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  </xsd:complexType>
  
 <xsd:element name="Client" type="tns:Client"></xsd:element>	
 <xsd:element name="Role" type="tns:Role"></xsd:element>	
 <xsd:element name="Organization" type="tns:Organization"></xsd:element>			
 <xsd:element name="Warehouse" type="tns:Warehouse"></xsd:element>			
  
      <xsd:complexType name="Client">
    <xsd:sequence>
      <xsd:element name="clientId" type="xsd:string" />
      <xsd:element name="client" type="xsd:string" />
     <xsd:element name="roleList" type="tns:Role" minOccurs="0" maxOccurs="unbounded"/>
        </xsd:sequence>
  </xsd:complexType>
  
    <xsd:complexType name="Role">
    <xsd:sequence>
      <xsd:element name="roleId" type="xsd:string" />
      <xsd:element name="role" type="xsd:string" />
     <xsd:element name="orgList" type="tns:Organization" minOccurs="0" maxOccurs="unbounded"/>
        </xsd:sequence>
  </xsd:complexType>
  
    <xsd:complexType name="Organization">
    <xsd:sequence>
      <xsd:element name="orgId" type="xsd:string" />
      <xsd:element name="org" type="xsd:string" />
     <xsd:element name="Warehouse" type="tns:Warehouse" minOccurs="0" maxOccurs="unbounded"/>
        </xsd:sequence>
  </xsd:complexType>
  
    <xsd:complexType name="Warehouse">
    <xsd:sequence>
      <xsd:element name="warehouseId" type="xsd:string" />
      <xsd:element name="warehouse" type="xsd:string" />
        </xsd:sequence>
  </xsd:complexType>
  
  	
  	<xsd:complexType name="RoleConfigureRequest">
  		<xsd:sequence>
  			<xsd:element name="serviceType" type="xsd:string" />
  			<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
  		</xsd:sequence>
  	</xsd:complexType>
  	
  	
  	<xsd:complexType name="RoleConfigureResponse">
  		<xsd:sequence>
			<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="appAcess" type="tns:RoleAppAcess" minOccurs="0" maxOccurs="unbounded"></xsd:element>  			
  		</xsd:sequence>
 			<xsd:attribute name="IsError" type="xsd:boolean" /> 		
  	</xsd:complexType>
  		
 	<xsd:complexType name="RoleAppAcess">
 	<xsd:sequence>
 		<xsd:element name="appName" type="xsd:string" />
 		<xsd:element name="appAcess" type="xsd:boolean"/>
 	</xsd:sequence>	
 	</xsd:complexType>  
 	
 	 	<xsd:complexType name="POListRequest">
  		<xsd:sequence>
  			<xsd:element name="serviceType" type="xsd:string" />
  			<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
  		</xsd:sequence>
  	</xsd:complexType>
  	
  	<xsd:complexType name="POListResponse">
  		<xsd:sequence>
  			<xsd:element name="Error" type="xsd:string" minOccurs="0" />
  			<xsd:element name ="ListAccess" type="tns:POListAccess" minOccurs="0" maxOccurs="unbounded"/>
  		</xsd:sequence>
  			<xsd:attribute name="IsError" type="xsd:boolean" /> 
  	</xsd:complexType>
  	
  	<xsd:complexType name="POListAccess">
  		<xsd:sequence>
  			<xsd:element name="documentNumber" type="xsd:string" />
  			<xsd:element name="supplierName" type="xsd:string" />
  			<xsd:element name="orderDate" type="xsd:string" />
  			<xsd:element name="WarehouseName" type="xsd:string" />
  			<xsd:element name="Description" type="xsd:string"/>
  			<xsd:element name="ProductName" type="xsd:string" />
  			<xsd:element name="OrderQTY" type="xsd:int" />
  			<xsd:element name="orderStatus" type="xsd:boolean" />
  		</xsd:sequence>
  	</xsd:complexType>

 	 <xsd:complexType name="PODataRequest">
  		<xsd:sequence>
  			<xsd:element name="serviceType" type="xsd:string" />
  			<xsd:element name="documentNo" type="xsd:string" />
  			<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
  		</xsd:sequence>
  	</xsd:complexType>
  	
  	 <xsd:complexType name="PODataResponse">
  		<xsd:sequence>
		<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="cOrderId" type="xsd:int" />
		<xsd:element name="orderDate" type="xsd:string"/>
		<xsd:element name="supplier" type="xsd:string"/>
		<xsd:element name="warehouseName" type="xsd:string"/>
		<xsd:element name="description" type="xsd:string"/>
  		<xsd:element name="overallQnty" type="xsd:int" />
  		<xsd:element name="defaultLocatorId" type="xsd:int" />
		<xsd:element name="ProductData" type="tns:ProductData" minOccurs="0" maxOccurs="unbounded"></xsd:element>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  	</xsd:complexType>
  	
 <xsd:complexType name="ProductData">
    <xsd:sequence>
       <xsd:element name="productId" type="xsd:int" />
      <xsd:element name="productName" type="xsd:string" />
      <xsd:element name="cOrderlineId" type="xsd:int" />
      <xsd:element name="uomId" type="xsd:int" />
      <xsd:element name="OutstandingQnty" type="xsd:int" />
      </xsd:sequence>
  </xsd:complexType>
  
   <xsd:complexType name="CreateMRRequest">
    <xsd:sequence>
      <xsd:element name="serviceType" type="xsd:string" />
  	  <xsd:element name="cOrderId" type="xsd:int" />
    	<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
      <xsd:element name="mRLines" type="tns:MRLines" minOccurs="0" maxOccurs="unbounded"></xsd:element>
      </xsd:sequence>
  </xsd:complexType>

 <xsd:complexType name="MRLines">
    <xsd:sequence>
       <xsd:element name="productId" type="xsd:int" />
      <xsd:element name="productName" type="xsd:string" />
      <xsd:element name="cOrderlineId" type="xsd:int" />
      <xsd:element name="uomId" type="xsd:int" />
      <xsd:element name="qnty" type="xsd:int" />
      <xsd:element name="locator" type="xsd:int" />
      </xsd:sequence>
  </xsd:complexType>
  
  <xsd:complexType name="CreateMRResponse">
  		<xsd:sequence>
		<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="mrDocumentNumber" type="xsd:string"/>
		<xsd:element name="mrId" type="xsd:int"/>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  	</xsd:complexType>
  	
  	  	<xsd:complexType name="MRListResponse">
  		<xsd:sequence>
  			<xsd:element name="Error" type="xsd:string" minOccurs="0" />
  			<xsd:element name="count" type="xsd:int" minOccurs="0" />
  			<xsd:element name ="MRList" type="tns:MRList" minOccurs="0" maxOccurs="unbounded"/>
  		</xsd:sequence>
  			<xsd:attribute name="IsError" type="xsd:boolean" /> 
  	</xsd:complexType>
  	
  	 <xsd:complexType name="MRList">
  		<xsd:sequence>
		<xsd:element name="documentNo" type="xsd:string" />
		<xsd:element name="orderDate" type="xsd:string"/>
		<xsd:element name="orderDocumentno" type="xsd:string"/>
		<xsd:element name="supplier" type="xsd:string"/>
		<xsd:element name="warehouseName" type="xsd:string"/>
		<xsd:element name="description" type="xsd:string"/>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  	</xsd:complexType>
  	
    	<xsd:complexType name="MRDataResponse">
  		<xsd:sequence>
		<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="documentNo" type="xsd:string"/>
		<xsd:element name="orderDate" type="xsd:string"/>
		<xsd:element name="supplier" type="xsd:string"/>
		<xsd:element name="warehouseName" type="xsd:string"/>
		<xsd:element name="description" type="xsd:string"/>
  		<xsd:element name="overallQnty" type="xsd:int" />
  		<xsd:element name="orderDocumentno" type="xsd:string"/>
		<xsd:element name="MRLines" type="tns:MRLine" minOccurs="0" maxOccurs="unbounded"></xsd:element>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  	</xsd:complexType>
  	
  	 <xsd:complexType name="MRLine">
    <xsd:sequence>
       <xsd:element name="mRLineId" type="xsd:int" />
      <xsd:element name="recievedQnty" type="xsd:int" />
      </xsd:sequence>
  </xsd:complexType>
  
     <xsd:complexType name="MRFailedRequest">
    <xsd:sequence>
      <xsd:element name="serviceType" type="xsd:string" />
  	  <xsd:element name="mInOutID" type="xsd:int" />
  	  <xsd:element name="faieldQty" type="xsd:int" />
    	<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
      </xsd:sequence>
  </xsd:complexType>
  
  <xsd:complexType name="MRFailedResponce">
  		<xsd:sequence>
		<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="createConfirmationDocumentNumber" type="xsd:string"/>
		<xsd:element name="createConfirmationId" type="xsd:int"/>
    </xsd:sequence>
		<xsd:attribute name="IsError" type="xsd:boolean" />
  	</xsd:complexType>
  
</xsd:schema>

