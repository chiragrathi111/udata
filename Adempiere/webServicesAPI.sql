If you pull the code from the git and pull code class through error means some dependency or jar file not complete coming in your project,
This problem solving two method:-
	1 cd idempiereNewChangesUI/wms/idempiere-release-10 
		and type the code 
		mvn verify (all dependency add your project but this method take show much time)

	2 cd idempiereNewChangesUI/wms/idempiere-release-10/org.idempiere.webservices (plug in name, means pulling the code changes plug in name)
	  scomp -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd (webservices mai already existing .xsd file ko hi 
	  code ke through .jar mai convert karte hai)
	  all error gone.


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Create a new API interface

	@POST (generally post using because post is secure)
	@Path("/role_configure")   (api last path link generally using call the api)
	public RoleConfigureResponce loginApi(RoleConfigureRequest req);  
	(start using public then provide login responce and provide method which show your postman or soapUI and last is give some request method)

	This RoleConfigureResponce and RoleConfigureRequest method create in idempiere_schema.xsd file
	like examples:-
	{
		<xsd:complexType name="RoleConfigureRequest">
  		<xsd:sequence>
  			<xsd:element name="serviceType" type="xsd:string" />
  			<xsd:element name="roleID" type="xsd:int" />
  			<xsd:element name="clientID" type="xsd:int" />
  		</xsd:sequence>
  	</xsd:complexType>
  	
  	
  	<xsd:complexType name="RoleConfigureResponce">
  		<xsd:sequence>
			<xsd:element name="Error" type="xsd:string" minOccurs="0" />
		<xsd:element name="Roles" type="tns:Role" minOccurs="0" maxOccurs="unbounded"></xsd:element>  			
  		</xsd:sequence>
 			<xsd:attribute name="IsError" type="xsd:boolean" /> 		
  	</xsd:complexType>
  		
 	<xsd:complexType name="Roles">
 	<xsd:sequence>
 		<xsd:element name="roles" type="xsd:string" />
 		<xsd:element name="roleAccessList" type="tns:Role" minOccurs="0" maxOccurs="unbounded"/>
 	</xsd:sequence>	
 	</xsd:complexType>  


 	replace mahendra sir

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
 	
	}

	and first completed create this 2 method then remove inside jar file in lib folder then go to terminal and run the command
	cd idempiereNewChangesUI/wms/idempiere-relese-10/org.idempiere.webservices 
	scomp -javasource 11 -out lib/idempiere-xmlbeans.jar WEB-INF/xsd/idempiere-schema.xsd (webservices mai already existing .xsd file ko hi 
	  code ke through .jar mai convert karte hai)
	  all error gone.

	This method complete then interface page mai both method add in import 
	import org.idempiere.adInterface.x10.RoleConfigureRequest;
	import org.idempiere.adInterface.x10.RoleConfigureResponce; 

	this interface class all method is done then go to implement your interface 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Create a new API implement method

	First implement put the api name and show error blub click and unimplement method execute then all error has gone


public RoleConfigureResponseDocument roleConfig(RoleConfigureRequestDocument roleConfigureRequestDocument) {
		String purchase_order = "Purchase Order";
		String sales_order = "Sales Order";
		String material_receipt = "Material Receipt";
		String store_provider = "Storage Provider";

		Trx trx = null;
		RoleConfigureResponseDocument roleConfigureResponseDocument = RoleConfigureResponseDocument.Factory
				.newInstance();
		RoleConfigureResponse roleResponse = RoleConfigureResponse.Factory.newInstance();
		List<String> roleAccess = new ArrayList<>();

		RoleConfigureRequest roleRequest = roleConfigureRequestDocument.getRoleConfigureRequest();
		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			int roleIds = roleRequest.getRoleID();
			int clientIds = roleRequest.getClientID();
			String serviceType = roleRequest.getServiceType();

			if (!serviceType.equalsIgnoreCase("roleConfig")) {
				roleResponse.setIsError(true);
				roleResponse.setError("Service type " + serviceType + " not configured");
				roleConfigureResponseDocument.setRoleConfigureResponse(roleResponse);
				return roleConfigureResponseDocument;
			}

			String query = "select e.name as Access_Window from adempiere.ad_user_roles a\n"
					+ "join adempiere.ad_role b on a.ad_role_id = b.ad_role_id\n"
					+ "join adempiere.ad_user c on a.ad_user_id = c.ad_user_id\n"
					+ "join adempiere.ad_window_access d on a.ad_role_id = d.ad_role_id\n"
					+ "join adempiere.ad_window e on d.ad_window_id = e.ad_window_id\n"
					+ "where b.ad_role_id = "+ roleIds + " and c.ad_client_id = " + clientIds + "";

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
			rsList.add(createRoleAppAcess(store_provider, false));

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


==================================================================================================================================================
  
  <xsd:complexType name="POListRequest">
  	<xsd:sequence>
  		<xsd:element name="serviceType" type="xsd:string" />
  		<xsd:element name="clientID" type="xsd:int" />
  	</xsd:sequence>
  </xsd:complexType>
  
  <xsd:complexType name="POLostResponce">
  	<xsd:sequence>
  		<xsd:element name="Error" type="xsd:string" minOccurs="0"/>
  		<xsd:element name="POList" type="tns:POList" minOccurs="0" maxOccurs="unbounded" />
  	</xsd:sequence>
  		<xsd:attribute name="IsError" type="xsd:boolean" />
  </xsd:complexType>
  
  <xsd:complexType name="POList">
  	<xsd:sequence>
  		
  	</xsd:sequence>
  </xsd:complexType>

=============================================================================================================================================================
   	 	<xsd:complexType name="POListRequest">
  		<xsd:sequence>
  			<xsd:element name="serviceType" type="xsd:string" />
  			<xsd:element name="ADLoginRequest" type="tns:ADLoginRequest" minOccurs="1" maxOccurs="1"/>
  		</xsd:sequence>
  	</xsd:complexType>
  	
  	<xsd:complexType name="POListResponce">
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
  			<xsd:element name="ProductName" type="xsd:string" />
  			<xsd:element name="OrderQTY" type="xsd:string" />
  			<xsd:element name="orderStatus" type="xsd:string" />
  		</xsd:sequence>
  	</xsd:complexType>

=============================++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=====================================================
  	@Override
	public POListResponse poList(POListRequest req) {
		// TODO Auto-generated method stub
		Trx trx = null;
		List<POListAccess> poLists = new ArrayList<>();
		POListResponse listResponse = POListResponse.Factory.newInstance();
		ADLoginRequest loginReq = req.getADLoginRequest();
		String serviceType = req.getServiceType();
		try {
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			int client_id = loginReq.getClientID();

			String err = login(loginReq, webServiceName, "poList", serviceType);  
			Explins:- First is loginRequset obj name, Second is webServicesName, Third is System method name 
			keyValue this is very important otherwise every time face error,and last is serviceType name)
			if (err != null && err.length() > 0) {
				listResponse.setError(err);
				listResponse.setIsError(true);
				return listResponse;
			}

			if (!serviceType.equalsIgnoreCase("polistr")) {
				listResponse.setIsError(true);
				listResponse.setError("Service type " + serviceType + " not configured");
				return listResponse;
			}

			String query = "SELECT\n" + "    po.documentno AS purchase_order,\n" + "	bp.name AS Supplier,\n"
					+ "	TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n" + "	wh.name AS Warehouse_Name,\n"
					+ "	pr.name AS Product_Name,\n" + "    pol.qtyordered AS po_qty_ordered,\n" + "    CASE\n"
					+ "        WHEN po.docstatus = 'DR' AND mr.m_inout_id IS NULL THEN 'Drafted, No Material Receipt'\n"
					+ "		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN 'Completed, No Material Receipt'\n"
					+ "		WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN 'Material Receipt Created because some qty are pendding'\n"
					+ "        ELSE 'Not Completed or Material Receipt Exists'\n" + "    END AS status \n"
					+ "FROM adempiere.c_order po\n"
					+ "JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id\n"
					+ "LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id\n"
					+ "JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id	\n"
					+ "JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
					+ "JOIN adempiere.m_product pr ON pr.m_product_id = pol.m_product_id\n"
					+ "WHERE pol.qtyordered > (\n" + "        SELECT COALESCE(SUM(iol.qtyentered), 0)\n"
					+ "        FROM adempiere.m_inoutline iol\n"
					+ "        WHERE iol.c_orderline_id = pol.c_orderline_id\n" + "    ) and po.ad_client_id = "
					+ client_id + ";";

			PreparedStatement pstm = null;
			ResultSet rs = null;

			pstm = DB.prepareStatement(query.toString(), null);
			rs = pstm.executeQuery();

			while (rs.next()) {
				String documentNo = rs.getString("Purchase_Order");
				String supplier = rs.getString("Supplier");
				String date = rs.getString("Order_Date");
				String warehouseName = rs.getString("Warehouse_Name");
				String productName = rs.getString("Product_Name");
				int PO_QTY = rs.getInt("po_qty_ordered");
				String Status = rs.getString("status");

				poLists.add(createPOList(documentNo, supplier, date, warehouseName, productName, PO_QTY, Status));

			}

			POListAccess[] polistArray = poLists.toArray(new POListAccess[poLists.size()]);
			listResponse.setListAccessArray(polistArray);

		} catch (Exception e) {
			System.out.println("some thing went wrong");
			
		} finally {
			if (manageTrx && trx != null) {
				trx.close();
			}
			getCompiereService().disconnect();
		}
		return listResponse;
	}

	private POListAccess createPOList(String docNo, String supplier, String date, String warehouseName,
			String productName, int poQTY, String status) {
		POListAccess poListAccess = POListAccess.Factory.newInstance();
		poListAccess.setDocumentNumber(docNo);
		poListAccess.setSupplierName(supplier);
		poListAccess.setOrderDate(date);
		poListAccess.setWarehouseName(warehouseName);
		poListAccess.setProductName(productName);
		poListAccess.setOrderQTY(poQTY);
		poListAccess.setOrderStatus(status);

		return poListAccess;

	}

	===============================++++++++++++++++++++++++++++++==========================+++++++++++==================================================

	import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.*;
import org.compiere.process.DocAction;
import org.compiere.util.Env;
import org.compiere.util.Trx;

public class MaterialReceiptCreator {
    public static void main(String[] args) {
        // Replace these with your specific values
        String poDocumentNo = "PO000001";
        
        // Create a new transaction
        Trx trx = Trx.get(Trx.createTrxName("MaterialReceiptCreator"), true);
        
        try {
            // Load the Purchase Order by document number
            MOrder purchaseOrder = new MOrder(Env.getCtx(), 0, trx);
            if (!purchaseOrder.load(poDocumentNo, null)) {
                throw new AdempiereException("Purchase Order not found: " + poDocumentNo);
            }
            
            // Create a Material Receipt based on the Purchase Order
            MInOut materialReceipt = new MInOut(purchaseOrder, MDocType.DOCTYPE_CustomerShipment, 
                                                purchaseOrder.getDateOrdered());
            
            // Set additional information if needed
            // materialReceipt.setXXX(...);
            
            // Save the Material Receipt
            if (!materialReceipt.save()) {
                throw new AdempiereException("Failed to save Material Receipt.");
            }
            
            // Create lines for the Material Receipt based on the PO lines
            for (MOrderLine poLine : purchaseOrder.getLines()) {
                MInOutLine receiptLine = new MInOutLine(materialReceipt);
                receiptLine.setOrderLine(poLine, 0, poLine.getQtyOrdered());
                receiptLine.setQty(poLine.getQtyOrdered());
                receiptLine.saveEx();
            }
            
            // Complete the Material Receipt
            if (!materialReceipt.processIt(DocAction.ACTION_Complete)) {
                throw new AdempiereException("Failed to complete Material Receipt: " +
                                            materialReceipt.getProcessMsg());
            }
            
            // Commit the transaction
            trx.commit();
            
            System.out.println("Material Receipt created and completed successfully.");
        } catch (Exception e) {
            trx.rollback();
            e.printStackTrace();
        } finally {
            trx.close();
        }
    }
}

====================================================================================================================================================
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
