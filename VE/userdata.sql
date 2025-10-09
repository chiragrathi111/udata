M_Product[Value], PP_Product_BOM>M_Product_ID[Value], PP_Product_BOMLine>Line, PP_Product_BOMLine>ComponentType,
PP_Product_BOM>PP_Product_BOMLine.M_Product_ID[Value], PP_Product_BOM>PP_Product_BOMLine.Line, PP_Product_BOM>PP_Product_BOMLine.ComponentType

-------------------------------------------------------------------------------------


ALTER TABLE adempiere.pi_productlabel ADD COLUMN ismanufacturing CHAR(1) NOT NULL DEFAULT 'N'::bpchar;

ALTER TABLE adempiere.pi_productlabel ADD COLUMN pp_order_id INTEGER;

ALTER TABLE adempiere.pi_productlabel
ADD CONSTRAINT pi_productlabel_pp_order_id_fkey
FOREIGN KEY (pp_order_id)
REFERENCES adempiere.pp_order(pp_order_id);

=========================================================================
return:-
public GetReturnComponentsResponseDocument getReturnComponents(GetReturnComponentsRequestDocument req) {
		GetReturnComponentsResponseDocument res = GetReturnComponentsResponseDocument.Factory.newInstance();
		GetReturnComponentsResponse response = res.addNewGetReturnComponentsResponse();
		GetReturnComponentsRequest request = req.getGetReturnComponentsRequest();
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

			org.idempiere.adInterface.x10.ADLoginRequest adLoginReq = VeUtils.convertAdLogin(loginReq);
			String err = login(adLoginReq, webServiceName, "returnOrderList", serviceType);
			if (err != null && err.length() > 0) {
				response.setError(err);
				response.setIsError(true);
				return res;
			}

			if (!serviceType.equalsIgnoreCase("returnOrderList")) {
				response.setIsError(true);
				response.setError("Service type " + serviceType + " not configured");
				return res;
			}

			int orgId = loginReq.getOrgID();
			int clientId = loginReq.getClientID();

			int userId = Env.getAD_User_ID(ctx);
			MUser_Custom user = new MUser_Custom(ctx, userId, trxName);
			X_PI_Deptartment dept = null;
			
			dept = new X_PI_Deptartment(ctx, user.getPI_DEPARTMENT_ID(), trxName);
			
			List<MLocator> mLocatorArray = VeUtils.getLocatorsByDepartment(ctx, trxName, loginReq.getWarehouseID(),
					dept.getPI_Deptartment_ID(), "returns", "Y");
			int returnceivingLocatorId = 0;
			if (mLocatorArray != null && mLocatorArray.size() != 0)
				returnceivingLocatorId = mLocatorArray.get(0).get_ID();
			response.setLocatorId(returnceivingLocatorId);
			
			List<PO> poList = MProduct_Custom.getProducts(clientId, orgId, ctx, trxName, dept.get_ID());
			if (poList != null && poList.size() != 0) {
				for (PO po : poList) {
					MProduct_Custom product = new MProduct_Custom(ctx, po.get_ID(), trxName);
					Product productBom = response.addNewProduct();
					productBom.setProductId(product.getM_Product_ID());
					productBom.setProductName(product.getName());
				}
			}

			poList = VeUtils.getBusinessPartnerList(clientId, orgId, ctx, trxName);
			if (poList != null && poList.size() != 0) {
				for (PO po : poList) {
					MBPartner partner = new MBPartner(ctx, po.get_ID(), trxName);
					BusinessPartner bPartner = response.addNewBusinessPartner();
					bPartner.setBPartnerId(partner.getC_BPartner_ID());
					bPartner.setBPartnerName(partner.getName());
				}
			}
			response.setIsError(false);
			trx.commit();
		} catch (Exception e) {
			response.setIsError(true);
			response.setError(e.getMessage());
			return res;
		} finally {
			getCompiereService().disconnect();
			trx.close();
		}
		return res;
	}
public static List<PO> getProducts(int clientId, int orgId, Properties ctx, String trxName, int deptId) {
		List<PO> list = new Query(ctx, Table_Name,
				"ad_client_ID =? AND ad_org_ID = ? AND pi_deptartment_ID = ?", trxName)
				.setParameters(clientId, orgId, deptId).setOrderBy(COLUMNNAME_M_Product_ID + " desc").list();
		return list;
	}
		