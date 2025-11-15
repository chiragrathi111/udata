@POST
	@Path("createmr")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response createMR(Map<String, Object> requestBody);
	
	@POST
	@Path("mrlist")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getMRList(
	    @QueryParam("searchKey") String searchKey,
	    @QueryParam("status") String status,
	    @QueryParam("isSalesTransaction") String isSalesTransaction);
	
	@POST
	@Path("/getMrData")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getMrData(@QueryParam("documentNo") String documentNo);


	@Override
	public Response createMR(Map<String, Object> requestBody) {

		Map<String, Object> responseMap = new HashMap<>();
	    Properties ctx = Env.getCtx();
	    Trx trx = null;
	    MInOut inout = null;
	    
	    try {
	    	int warehouseId = (Integer) requestBody.get("warehouseId");
	        int bPartnerId = (Integer) requestBody.get("bPartnerId");
	        int cOrderId = requestBody.containsKey("cOrderId") ? (Integer) requestBody.get("cOrderId") : 0;
	        String description = requestBody.containsKey("description") ? (String) requestBody.get("description") : "";
	        String movementDateStr = (String) requestBody.get("movementdate");
	        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-dd-MM'T'HH:mm:ss.SSS");
	        Date parsedDate = dateFormat.parse(movementDateStr);
	        Timestamp movementDate = new Timestamp(parsedDate.getTime());
	        
	        List<Map<String, Object>> mrLinesList = (List<Map<String, Object>>) requestBody.get("mRLines");
	        
	        // Start transaction
	        String trxName = Trx.createTrxName(getClass().getName() + "_");
	        trx = Trx.get(trxName, true);
	        trx.start();
	        
	        int clientId = Env.getAD_Client_ID(ctx);
	        int orgId = Env.getAD_Org_ID(ctx);
	        int userId = Env.getAD_User_ID(ctx);
	        
	        // Get DocType
	        MDocType mDocType = new Query(ctx, MDocType.Table_Name, 
	            "name = 'MM Receipt' AND ad_client_id = ?", trxName)
	            .setParameters(clientId)
	            .first();
	        
	        if (mDocType == null) {
	            throw new Exception("Document Type 'MM Receipt' not found");
	        }
	        
	        List<Map<String, Object>> responseLines = new ArrayList<>();
	        
	        if (cOrderId == 0) {
	            // Create MR without Order
	            inout = new MInOut_Custom(ctx, trxName, clientId, orgId, userId, 
	                bPartnerId, warehouseId, mDocType, movementDate, description);
	            inout.saveEx();
	            
	            int mInoutId = inout.getM_InOut_ID();
	            
	            // Process each MR Line
	            for (Map<String, Object> lineData : mrLinesList) {
	                int productId = (Integer) lineData.get("productId");
	                int uomId = (Integer) lineData.get("uomId");
	                int qnty = (Integer) lineData.get("qnty");
	                int locator = (Integer) lineData.get("locator");
	                
	                BigDecimal qtyEntered = BigDecimal.valueOf(qnty);
	                
	                // Create InOut Line
	                MInOutLine iol = new MInOutLine(ctx, 0, trxName);
	                iol.setM_InOut_ID(mInoutId);
	                iol.setM_Product_ID(productId, uomId);
	                iol.setQty(qtyEntered);
	                iol.setMovementQty(qtyEntered);
	                iol.setC_UOM_ID(uomId);
	                iol.setM_Warehouse_ID(warehouseId);
	                iol.setM_Locator_ID(locator);
	                iol.saveEx();
	                
	                List<Map<String, Object>> packLines = (List<Map<String, Object>>) lineData.get("packLine");
	                if (packLines != null && !packLines.isEmpty()) {
	                    createPackLineforInoutLine(ctx, trxName, packLines, qnty, iol.get_ID());
	                }
	                
	                // Add to response
	                Map<String, Object> responseLine = new HashMap<>();
	                responseLine.put("mrLineId", iol.get_ID());
	                responseLine.put("productId", productId);
	                responseLine.put("uomId", uomId);
	                responseLine.put("qnty", qnty);
	                responseLine.put("locator", locator);
	                responseLines.add(responseLine);
	            }
	        } else {
	            // Create MR with Order
	            MOrder order = new MOrder(ctx, cOrderId, trxName);
	            
	            if (order.get_ID() == 0) {
	                throw new Exception("Order not found with ID: " + cOrderId);
	            }
	            
	            MInOut receipt = new MInOut(order, mDocType.get_ID(), order.getDateOrdered());
	            receipt.setDocStatus(DocAction.STATUS_Drafted);
	            receipt.saveEx();
	            
	            int mInoutId = receipt.getM_InOut_ID();
	            inout = new MInOut(ctx, mInoutId, trxName);
	            
	            // Process each MR Line
	            for (Map<String, Object> lineData : mrLinesList) {
	                int productId = (Integer) lineData.get("productId");
	                int uomId = (Integer) lineData.get("uomId");
	                int qnty = (Integer) lineData.get("qnty");
	                int locator = (Integer) lineData.get("locator");
	                int cOrderlineId = lineData.containsKey("cOrderlineId") ? (Integer) lineData.get("cOrderlineId") : 0;
	                
	                BigDecimal qtyEntered = BigDecimal.valueOf(qnty);
	                
	                // Create line from order
	                inout.createLineFrom(cOrderlineId, 0, 0, productId, uomId, qtyEntered, locator);
	                
	                // Get the created line
	                MInOutLine[] lineArray = MInOutLine.get(ctx, cOrderlineId, trxName);
	                MInOutLine line = lineArray[lineArray.length - 1];
	                
	                // Delete existing packlines and create new ones
	                Packline.deletepackLine(ctx, trxName, line.get_ID());
	                
	                List<Map<String, Object>> packLines = (List<Map<String, Object>>) lineData.get("packLine");
	                if (packLines != null && !packLines.isEmpty()) {
	                    createPackLineforInoutLine(ctx, trxName, packLines, qnty, line.get_ID());
	                }
	                
	                // Add to response
	                Map<String, Object> responseLine = new HashMap<>();
	                responseLine.put("mrLineId", line.get_ID());
	                responseLine.put("productId", productId);
	                responseLine.put("uomId", uomId);
	                responseLine.put("qnty", qnty);
	                responseLine.put("locator", locator);
	                responseLines.add(responseLine);
	            }
	            
	            inout.updateFrom(order, null, null);
	        }
	        
	        trx.commit();
	        
	        responseMap.put("IsError", false);
	        responseMap.put("mrDocumentNumber", inout.getDocumentNo());
	        responseMap.put("mrId", inout.get_ID());
	        responseMap.put("mRLines", responseLines);
	        
	        Map<String, String> data = new HashMap<>();
			data.put("recordId", String.valueOf(inout.getM_InOut_ID()));
			data.put("documentNo", String.valueOf(inout.getDocumentNo()));
			data.put("path1", "/put_away_screen");
			data.put("path2", "/put_away_detail_screen");

			RwplUtils.sendNotificationAsync(true, false, inout.get_Table_ID(), inout.getM_InOut_ID(), ctx, trxName,
					"New Inward: " + inout.getDocumentNo() + "",
					" Inward - " + inout.getDocumentNo() + " added to process", inout.get_TableName(), data,
					clientId, "MaterialReciptCreated");
	        
	        return Response.ok(Collections.singletonMap("CreateMRResponse", responseMap)).build();
	    	
	    }catch (Exception e) {
	    	if (trx != null) {
	            trx.rollback();
	        }
	        
	        Map<String, Object> errorResp = new HashMap<>();
	        errorResp.put("IsError", true);
	        errorResp.put("ErrorMessage", e.getMessage());
	        
	        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
	                       .entity(Collections.singletonMap("CreateMRResponse", errorResp))
	                       .build();
		}finally {
			if (trx != null) {
	            trx.close();
	        }
		}
	}
	
	private void createPackLineforInoutLine(Properties ctx, String trxName, 
		    List<Map<String, Object>> packlineArray, int qnty, int inoutLineId) {
		    
		    int packCount = 1;
		    int remainingQty = qnty;
		    
		    for (Map<String, Object> packline : packlineArray) {
		        int packQty = (Integer) packline.get("PackCount");
		        createPackLine(ctx, trxName, inoutLineId, packCount, packQty);
		        remainingQty -= packQty;
		        packCount++;
		    }
		    
		    // Create pack line for remaining quantity
		    if (remainingQty > 0) {
		        createPackLine(ctx, trxName, inoutLineId, packCount, remainingQty);
		    }
		}
	
	private void createPackLine(Properties ctx, String trxName, int minoutLineId, 
		    int packCount, int qnty) {
		    
		    Packline lineNew = new Packline(ctx, 0, trxName);
		    lineNew.setM_InOutLine_ID(minoutLineId);
		    lineNew.setAD_Org_ID(Env.getAD_Org_ID(ctx));
		    lineNew.setlabel("Pack " + packCount);
		    lineNew.setquantity(BigDecimal.valueOf(qnty));
		    lineNew.saveEx();
		}


	@Override
	public Response getMRList(String searchKey, String status, String isSalesTransaction) {
		Map<String, Object> responseMap = new HashMap<>();
	    responseMap.put("IsError", false);

	    try {
	        Properties ctx = Env.getCtx();
	        int clientId = Env.getAD_Client_ID(ctx);

	        String query = "SELECT po.m_inout_id, po.documentno, bp.name AS supplier, wh.name AS warehouseName, po.pickStatus "
	                     + "FROM m_inout po "
	                     + "JOIN c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id "
	                     + "JOIN m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id "
	                     + "WHERE po.ad_client_id = ? "
	                     + "AND (? IS NULL OR po.pickStatus = ?) "
	                     + "AND (? IS NULL OR po.issotrx = ?) "
	                     + "AND (? IS NULL OR po.documentno ILIKE '%' || ? || '%')";

	        PreparedStatement pstmt = DB.prepareStatement(query, null);
	        pstmt.setInt(1, clientId);
	        pstmt.setString(2, status);
	        pstmt.setString(3, status);
	        pstmt.setString(4, isSalesTransaction);
	        pstmt.setString(5, isSalesTransaction);
	        pstmt.setString(6, searchKey);
	        pstmt.setString(7, searchKey);

	        ResultSet rs = pstmt.executeQuery();
	        List<Map<String, Object>> mrList = new ArrayList<>();

	        while (rs.next()) {
	            Map<String, Object> mr = new HashMap<>();
	            mr.put("mInoutID", rs.getInt("m_inout_id"));
	            mr.put("documentNo", rs.getString("documentno"));
	            mr.put("supplier", rs.getString("supplier"));
	            mr.put("warehouseName", rs.getString("warehouseName"));
	            mr.put("pickStatus", rs.getString("pickStatus"));
	            mrList.add(mr);
	        }

	        responseMap.put("mrList", mrList);
	        responseMap.put("count", mrList.size());

	        return Response.ok(Collections.singletonMap("GetMRListResponse", responseMap)).build();

	    } catch (Exception e) {
	        Map<String, Object> errorResp = new HashMap<>();
	        errorResp.put("IsError", true);
	        errorResp.put("ErrorMessage", e.getMessage());
	        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
	                       .entity(Collections.singletonMap("GetMRListResponse", errorResp))
	                       .build();
	    }
	}


	@Override
	public Response getMrData(String documentNo) {
		Map<String, Object> responseMap = new HashMap<>();
	    responseMap.put("IsError", false);

	    if (documentNo == null || documentNo.trim().isEmpty()) {
	        responseMap.put("IsError", true);
	        responseMap.put("ErrorMessage", "Document number is required");
	        return Response.status(Response.Status.BAD_REQUEST)
	                       .entity(Collections.singletonMap("GetMRDataResponse", responseMap))
	                       .build();
	    }
	    
	    try {
	    	Properties ctx = Env.getCtx();
	        int clientId = Env.getAD_Client_ID(ctx);

	        List<MInOut> mrList = new Query(ctx, MInOut.Table_Name, "DocumentNo=? AND AD_Client_ID=?", null)
	                .setParameters(documentNo, clientId)
	                .setOrderBy("Created DESC")
	                .list();

	        if (mrList.isEmpty()) {
	            responseMap.put("IsError", true);
	            responseMap.put("ErrorMessage", "No MR found for DocumentNo: " + documentNo);
	            return Response.status(Response.Status.NOT_FOUND)
	                           .entity(Collections.singletonMap("GetMRDataResponse", responseMap))
	                           .build();
	        }

	        MInOut mr = mrList.get(0);
	        Map<String, Object> mrHeader = new HashMap<>();

	        mrHeader.put("documentNo", mr.getDocumentNo());
	        mrHeader.put("description", mr.getDescription() != null ? mr.getDescription() : "");
	        mrHeader.put("docStatus", mr.getDocStatus());
	        mrHeader.put("movementDate", mr.getMovementDate());
	        mrHeader.put("mInoutID", mr.getM_InOut_ID());

	        if (mr.getC_BPartner_ID() > 0) {
	            MBPartner bp = new MBPartner(ctx, mr.getC_BPartner_ID(), null);
	            mrHeader.put("supplier", bp.getName());
	        }

	        if (mr.getM_Warehouse_ID() > 0) {
	            MWarehouse wh = new MWarehouse(ctx, mr.getM_Warehouse_ID(), null);
	            mrHeader.put("warehouseName", wh.getName());
	        }

	        List<MInOutLine> lines = new Query(ctx, MInOutLine.Table_Name, "M_InOut_ID=?", null)
	                .setParameters(mr.getM_InOut_ID())
	                .setOrderBy("Line")
	                .list();

	        List<Map<String, Object>> lineList = new ArrayList<>();
	        int totalQty = 0;

	        for (MInOutLine line : lines) {
	            Map<String, Object> lineData = new HashMap<>();

	            MProduct product = new MProduct(ctx, line.getM_Product_ID(), null);
	            lineData.put("productID", line.getM_Product_ID());
	            lineData.put("productName", product.getName());

	            MLocator locator = new MLocator(ctx, line.getM_Locator_ID(), null);
	            lineData.put("locatorID", line.getM_Locator_ID());
	            lineData.put("locatorName", locator.getValue());

	            lineData.put("mInoutLineID", line.getM_InOutLine_ID());
	            lineData.put("movementQty", line.getMovementQty());
	            lineData.put("uomID", line.getC_UOM_ID());
	            lineData.put("cOrderLineID", line.getC_OrderLine_ID());

	            totalQty += line.getMovementQty().intValue();

	            lineList.add(lineData);
	        }

	        mrHeader.put("totalQty", totalQty);
	        mrHeader.put("lines", lineList);
	        mrHeader.put("lineCount", lineList.size());

	        responseMap.put("MRData", mrHeader);

	        return Response.ok(Collections.singletonMap("GetMRDataResponse", responseMap)).build();

	    } catch (Exception e) {
	        responseMap.put("IsError", true);
	        responseMap.put("ErrorMessage", e.getMessage());
	        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
	                       .entity(Collections.singletonMap("GetMRDataResponse", responseMap))
	                       .build();
	    }
	}



	