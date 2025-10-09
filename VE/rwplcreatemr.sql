@POST
	@Path("createmr")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public Response createMR(Map<String, Object> requestBody);
	

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
	        Timestamp movementDate = new Timestamp((long) requestBody.get("movementdate"));
	        
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

======================
Payload:-

{
  "warehouseId": 1000000,
  "bPartnerId": 1000004,
  "movementdate": "2025-01-05T00:00:00.000",
  "description": "bj",
  "cOrderId": 0,
  "mRLines": [
    {
      "productId": 1000001,
      "uomId": 100,
      "qnty": 400,
      "locator": 1000001,
      "packLine": [
        {
          "PackCount": 100
        },
        {
          "PackCount": 200
        }
      ]
    },
    {
      "productId": 1000002,
      "uomId": 100,
      "qnty": 200,
      "locator": 1000001,
      "packLine": [
        {
          "PackCount": 50
        },
        {
          "PackCount": 70
        }
      ]
    }
  ]
}		