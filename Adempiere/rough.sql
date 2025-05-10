//				System.out.println(datas.toString());
//				if(datas.equals(purchase_order)) {
//					Roles rss = Roles.Factory.newInstance();
//					receive = true;
//					rss.setRoles("purchase_order");
//					rss.setRoleAccess(true);
//					rsList.add(rss);
//					
//				}
//				if (datas.equals(material_receipt)) {
//					Roles rss = Roles.Factory.newInstance();
//					qcCheck = true;
//					rss.setRoles("material_receipt");
//					rss.setRoleAccess(true);
//					rsList.add(rss);
//				}
//				if (datas.equals(store_provider)) {
//					Roles rss = Roles.Factory.newInstance();
//					stockCheck = true;
//					rss.setRoles("store_provider");
//					rss.setRoleAccess(true);
//					rsList.add(rss);
//				}
//				if (datas.equals(sales_order)) {
//					Roles rss = Roles.Factory.newInstance();
//					dispatch = true;
//					rss.setRoles("sales_order");
//					rss.setRoleAccess(true);
//					rsList.add(rss);
////					break;
//				}	
//			}

===================================================================================================================================================
Adempiere API

package org.pipra.webservices.custom;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.jws.WebService;

import org.compiere.util.DB;
import org.compiere.util.KeyNamePair;
import org.compiere.util.Login;
import org.compiere.util.Trx;
import org.idempiere.adInterface.x10.ADLoginRequest;
import org.idempiere.adInterface.x10.Client;
import org.idempiere.adInterface.x10.LoginApiRequest;
import org.idempiere.adInterface.x10.LoginApiRequestDocument;
import org.idempiere.adInterface.x10.LoginApiResponse;
import org.idempiere.adInterface.x10.LoginApiResponseDocument;
import org.idempiere.adInterface.x10.Organization;
import org.idempiere.adInterface.x10.POListAccess;
import org.idempiere.adInterface.x10.POListRequest;
import org.idempiere.adInterface.x10.POListRequestDocument;
import org.idempiere.adInterface.x10.POListResponse;
import org.idempiere.adInterface.x10.POListResponseDocument;
import org.idempiere.adInterface.x10.Role;
import org.idempiere.adInterface.x10.RoleAppAcess;
import org.idempiere.adInterface.x10.RoleConfigureRequest;
import org.idempiere.adInterface.x10.RoleConfigureRequestDocument;
import org.idempiere.adInterface.x10.RoleConfigureResponse;
import org.idempiere.adInterface.x10.RoleConfigureResponseDocument;
import org.idempiere.adInterface.x10.Warehouse;
import org.idempiere.adinterface.CompiereService;
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
		LoginApiRequest loginRequest = loginRequestDocument.getLoginApiRequest();
		LoginApiResponse loginApiResponse = LoginApiResponse.Factory.newInstance();
		List<Client> clientList = new ArrayList<>();
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

				Client clientName = Client.Factory.newInstance();
				KeyNamePair[] roles = login.getRoles(loginRequest.getUser(), client, ROLE_TYPES_WEBSERVICE);
				List<Role> roleList = new ArrayList<>();

				if (roles != null) {
					for (KeyNamePair role : roles) {
						Role roleName = Role.Factory.newInstance();
						roleName.setRoleId(role.getID());
						roleName.setRole(role.getName());

						KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(role.getKey(), ""));
						List<Organization> orgList = new ArrayList<>();
						if (orgs != null) {
							for (KeyNamePair org : orgs) {
								Organization orgName = Organization.Factory.newInstance();
								orgName.setOrgId(org.getID());
								orgName.setOrg(org.getName());

								List<Warehouse> wList = new ArrayList<>();
								KeyNamePair[] warehouses = login.getWarehouses(new KeyNamePair(org.getKey(), ""));
								if (warehouses != null) {
									for (KeyNamePair warehouse : warehouses) {
										Warehouse wName = Warehouse.Factory.newInstance();
										wName.setWarehouseId(warehouse.getID());
										wName.setWarehouse(warehouse.getName());
										wList.add(wName);
									}
								}
								Warehouse[] wArray = wList.toArray(new Warehouse[wList.size()]);
								orgName.setWarehouseArray(wArray);
								orgList.add(orgName);
							}
						}
						Organization[] orgArray = orgList.toArray(new Organization[orgList.size()]);
						roleName.setOrgListArray(orgArray);
						roleList.add(roleName);
					}
				}

				Role[] roleArray = roleList.toArray(new Role[roleList.size()]);
				clientName.setClientId(client.getID());
				clientName.setClient(client.getName());
				clientName.setRoleListArray(roleArray);
				clientList.add(clientName);
			}
//			authenticate(webServiceName, "openLoginApi", serviceType, m_cs);

			Client[] clientArray = clientList.toArray(new Client[clientList.size()]);
			loginApiResponse.setClientArray(clientArray);

		} finally {
			if (manageTrx && trx != null)
				trx.close();

			getCompiereService().disconnect();
		}
		loginApiResponseDocument.setLoginApiResponse(loginApiResponse);
		return loginApiResponseDocument;
	}

	@Override
	public RoleConfigureResponseDocument roleConfig(RoleConfigureRequestDocument roleConfigureRequestDocument) {
		String purchase_order = "Purchase Order";
		String sales_order = "Sales Order";
		String material_receipt = "Material Receipt";
		String physical_inventory = "Physical Inventory";

		Trx trx = null;
		RoleConfigureResponseDocument roleConfigureResponseDocument = RoleConfigureResponseDocument.Factory
				.newInstance();
		RoleConfigureResponse roleResponse = RoleConfigureResponse.Factory.newInstance();
		List<String> roleAccess = new ArrayList<>();

		RoleConfigureRequest roleRequest = roleConfigureRequestDocument.getRoleConfigureRequest();
		ADLoginRequest loginReq = roleRequest.getADLoginRequest();
		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			int roleIds = loginReq.getRoleID();
			int clientIds = loginReq.getClientID();
			String serviceType = roleRequest.getServiceType();

			String err = login(loginReq, webServiceName, "roleConfig", serviceType);
			if (err != null && err.length() > 0) {
				roleResponse.setError(err);
				roleResponse.setIsError(true);
				roleConfigureResponseDocument.setRoleConfigureResponse(roleResponse);
				return roleConfigureResponseDocument;
			}

			if (!serviceType.equalsIgnoreCase("roleConfig")) {
				roleResponse.setIsError(true);
				roleResponse.setError("Service type " + serviceType + " not configured");
				roleConfigureResponseDocument.setRoleConfigureResponse(roleResponse);
				return roleConfigureResponseDocument;
			}

			String query = "select e.name as Access_Window from ad_user_roles a\n"
					+ "join ad_role b on a.ad_role_id = b.ad_role_id\n"
					+ "join ad_user c on a.ad_user_id = c.ad_user_id\n"
					+ "join ad_window_access d on a.ad_role_id = d.ad_role_id\n"
					+ "join ad_window e on d.ad_window_id = e.ad_window_id\n" + "where b.ad_role_id = "
					+ roleIds + " and c.ad_client_id = " + clientIds + "";

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

			RoleAppAcess[] roleAppAccessArray = rsList.toArray(new RoleAppAcess[rsList.size()]);
			roleResponse.setAppAcessArray(roleAppAccessArray);

		} catch (Exception e) {

		} finally {
			if (manageTrx && trx != null) {
				trx.close();
			}
			getCompiereService().disconnect();
		}
		roleConfigureResponseDocument.setRoleConfigureResponse(roleResponse);
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
			int client_id = loginReq.getClientID();

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

			String query = "SELECT\n" + "    po.documentno AS purchase_order,\n" + "	bp.name AS Supplier,\n"
					+ "	TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n" + "	wh.name AS Warehouse_Name,\n"
					+ "	po.description,\n" + "	pr.name AS Product_Name,\n" + "    pol.qtyordered AS po_qty_ordered,\n"
					+ "    CASE\n" + "		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
					+ "		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n" + "    END AS status\n"
					+ "FROM c_order po\n"
					+ "JOIN c_orderline pol ON po.c_order_id = pol.c_order_id\n"
					+ "LEFT JOIN m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id	\n"
					+ "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN m_product pr ON pr.m_product_id = pol.m_product_id\n"
					+ "WHERE pol.qtyordered > (\n" + "        SELECT COALESCE(SUM(iol.qtyentered), 0)\n"
					+ "        FROM m_inoutline iol\n"
					+ "        WHERE iol.c_orderline_id = pol.c_orderline_id\n" + "    ) and po.ad_client_id = "
					+ client_id + " and po.docstatus = 'CO';";
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
				String productName = rs.getString("Product_Name");
				int PO_QTY = rs.getInt("po_qty_ordered");
				boolean Status = rs.getBoolean("status");

				poLists.add(createPOList(documentNo, supplier, date, warehouseName, description, productName, PO_QTY,
						Status));

			}
			POListAccess[] polistArray = poLists.toArray(new POListAccess[poLists.size()]);
			listResponse.setListAccessArray(polistArray);

		} catch (Exception e) {
			listResponse.setError(e.getMessage());
			return pOListResponseDocument;

		} finally {
			if (manageTrx && trx != null) {
				trx.close();
			}
		}
		pOListResponseDocument.setPOListResponse(listResponse);
		return pOListResponseDocument;
	}

	private POListAccess createPOList(String docNo, String supplier, String date, String warehouseName,
			String description, String productName, int poQTY, boolean status) {
		POListAccess poListAccess = POListAccess.Factory.newInstance();
		poListAccess.setDocumentNumber(docNo);
		poListAccess.setSupplierName(supplier);
		poListAccess.setOrderDate(date);
		poListAccess.setWarehouseName(warehouseName);
		poListAccess.setDescription(description);
		poListAccess.setProductName(productName);
		poListAccess.setOrderQTY(poQTY);
		poListAccess.setOrderStatus(status);

		return poListAccess;
	}
}

