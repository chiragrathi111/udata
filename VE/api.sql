@Override
	public Response getMRComponents() {
		Map<String, Object> responseMap = new HashMap<>();
	    responseMap.put("IsError", false);

	    try {
	    	Properties ctx = Env.getCtx();
	        int clientId = Env.getAD_Client_ID(ctx);

	        List<MWarehouse> warehouses = new Query(ctx, MWarehouse.Table_Name, "IsActive='Y' AND ad_client_id=?", null)
	        								.setParameters(clientId)
	                                        .setOrderBy("Name ASC")
	                                        .list();
	        List<Map<String, Object>> warehouseList = new ArrayList<>();
	        for (MWarehouse wh : warehouses) {
	            Map<String, Object> whMap = new HashMap<>();
	            whMap.put("warehouseId", wh.get_ID());
	            whMap.put("warehouse", wh.getName());
	            // Default locator example
	            int defaultLocatorId = 0;
	            List<MLocator> locators = MLocatorType_Custom.getLocatorsByType(ctx, null, wh.get_ID(), "receiving", "Y");
	            if (locators != null && !locators.isEmpty()) {
	                defaultLocatorId = locators.get(0).get_ID();
	            }
	            whMap.put("defaultLocatorId", defaultLocatorId);

	            warehouseList.add(whMap);
	        }
	        responseMap.put("warehouse", warehouseList);

	        List<MProductCategory> categories = new Query(ctx, MProductCategory.Table_Name, "IsActive='Y' AND ad_client_id=?", null)
	        										.setParameters(clientId)
	        										.setOrderBy("Name ASC")
	                                                .list();
	        List<Map<String, Object>> categoryList = new ArrayList<>();
	        for (MProductCategory cat : categories) {
	            Map<String, Object> catMap = new HashMap<>();
	            catMap.put("productCategoryId", cat.getM_Product_Category_ID());
	            catMap.put("productCategoryName", cat.getName());
	            categoryList.add(catMap);
	        }
	        responseMap.put("productCategory", categoryList);

	        List<PO> products = new Query(ctx, MProduct_Custom.Table_Name, "IsActive='Y' AND ad_client_id=?", null)
	        								.setParameters(clientId)
	                                        .setOrderBy("Name ASC")
	                                        .list();
	        List<Map<String, Object>> productList = new ArrayList<>();
	        for (PO prds : products) {
	        	MProduct_Custom prd = new MProduct_Custom(ctx, prds.get_ID(), null);
	            Map<String, Object> prdMap = new HashMap<>();
	            prdMap.put("productId", prd.get_ID());
	            prdMap.put("productName", prd.getName());
	            prdMap.put("uomId", prd.getC_UOM_ID());
	            prdMap.put("uomName", prd.getC_UOM() != null ? prd.getC_UOM().getName() : "");
	            prdMap.put("labelQnty", prd.getLabelQnty() != null ? prd.getLabelQnty().intValue() : 0);
	            prdMap.put("productCategoryId", prd.getM_Product_Category_ID());
	            prdMap.put("productCategoryName", prd.getM_Product_Category() != null ? prd.getM_Product_Category().getName() : "");
	            productList.add(prdMap);
	        }
	        responseMap.put("product", productList);

	        List<MBPartner> bpartners = new Query(ctx, MBPartner.Table_Name, "IsActive='Y' AND ad_client_id=?", null)
	        								.setParameters(clientId)
	                                        .setOrderBy("Name ASC")
	                                        .list();
	        List<Map<String, Object>> bpList = new ArrayList<>();
	        for (MBPartner bp : bpartners) {
	            Map<String, Object> bpMap = new HashMap<>();
	            bpMap.put("businessPartnerID", bp.get_ID());
	            bpMap.put("businessPartnerName", bp.getName());
	            bpMap.put("address", bp.getPrimaryC_BPartner_Location() != null ? bp.getPrimaryC_BPartner_Location().getName() : "");
	            bpList.add(bpMap);
	        }
	        responseMap.put("businessPartner", bpList);

	        return Response.ok(Collections.singletonMap("GetMRComponentsResponse", responseMap)).build();

	    } catch (Exception e) {
	        Map<String, Object> errorResp = new HashMap<>();
	        errorResp.put("IsError", true);
	        errorResp.put("ErrorMessage", e.getMessage());
	        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
	                       .entity(Collections.singletonMap("GetMRComponentsResponse", errorResp))
	                       .build();
	    }
	}


	@Override
	public Response roleConfig(String deviceToken) {
		 Map<String, Object> responseMap = new HashMap<>();
		    List<Map<String, Object>> appAccessList = new ArrayList<>();

		    Trx trx = null;

		    try {
		        Properties ctx = Env.getCtx();
		        int userId = Env.getAD_User_ID(ctx);
		        int roleId = Env.getAD_Role_ID(ctx);

		        String trxName = Trx.createTrxName("roleConfig_");
		        trx = Trx.get(trxName, true);
		        trx.start();

		        AdRole_Custom adRole = new AdRole_Custom(ctx, roleId, trxName, null);

		        appAccessList.add(Map.of("appName", "recieveApp", "appAcess", adRole.isPurchaseOrder()));
		        appAccessList.add(Map.of("appName", "materialReceipt", "appAcess", adRole.isMaterialReceipt()));
		        appAccessList.add(Map.of("appName", "stockCheckApp", "appAcess", adRole.isPhysicalInventory()));
		        appAccessList.add(Map.of("appName", "pickList", "appAcess", adRole.isSaleOrder()));
		        appAccessList.add(Map.of("appName", "dispatchApp", "appAcess", adRole.isShipmentCustomer()));
		        appAccessList.add(Map.of("appName", "addInward", "appAcess", adRole.isAddInward()));
		        appAccessList.add(Map.of("appName", "ispickbyorder", "appAcess", adRole.ispickbyorder()));
		        appAccessList.add(Map.of("appName", "mergeApp", "appAcess", adRole.ismergeapp()));
		        appAccessList.add(Map.of("appName", "splitApp", "appAcess", adRole.issplitapp()));
		        appAccessList.add(Map.of("appName", "labourPutaway", "appAcess", adRole.isLabourPutaway()));
		        appAccessList.add(Map.of("appName", "labourPicklist", "appAcess", adRole.isLabourPicklist()));
		        appAccessList.add(Map.of("appName", "labourInventorymove", "appAcess", adRole.isLabourInventorymove()));
		        appAccessList.add(Map.of("appName", "qcCheckApp", "appAcess", adRole.isQcCheckApp()));

		        responseMap.put("appAcess", appAccessList);

		        // Save device token if not exists
		        boolean flag = true;
		        if (deviceToken != null && !deviceToken.isEmpty()) {
		            flag = PiUserToken.checkTokenExistForuser(deviceToken, userId, ctx, trxName);
		        }
		        if (!flag) {
		            PiUserToken piUserToken = new PiUserToken(ctx, 0, trxName);
		            piUserToken.setAD_User_ID(userId);
		            piUserToken.setdevicetoken(deviceToken);
		            piUserToken.saveEx();
		        }

		        trx.commit();
		        return Response.ok(Collections.singletonMap("RoleConfigureResponse", responseMap)).build();

		    } catch (Exception e) {
		        if (trx != null) trx.rollback();
		        Map<String, Object> errorResp = new HashMap<>();
		        errorResp.put("IsError", true);
		        errorResp.put("ErrorMessage", e.getMessage());
		        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
		                       .entity(Collections.singletonMap("RoleConfigureResponse", errorResp))
		                       .build();
		    } finally {
		        if (trx != null) trx.close();
		    }


@POST
	@Path("getmrcomponents")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response getMRComponents();
	
	@POST
	@Path("roleconfig")
	@Produces(MediaType.APPLICATION_JSON)
	public Response roleConfig(@QueryParam("deviceToken") String deviceToken);
