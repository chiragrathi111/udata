@Override
	public AddPrimaryHardeningDetailResponseDocument addPrimaryHardeningDetail(
			AddPrimaryHardeningDetailRequestDocument req) {
		AddPrimaryHardeningDetailResponseDocument addPrimaryHardeningDetailResponseDocument = AddPrimaryHardeningDetailResponseDocument.Factory
				.newInstance();
		AddPrimaryHardeningDetailResponse addPrimaryHardeningDetailResponse = addPrimaryHardeningDetailResponseDocument
				.addNewAddPrimaryHardeningDetailResponse();
		AddPrimaryHardeningDetailRequest loginRequest = req.getAddPrimaryHardeningDetailRequest();
		AddHardeningDetail addHardeningDetail = loginRequest.getAddHardeningDetail();
		String outUUId = safeTrim(loginRequest.getOutUUId());
		String cultureProcessedNumber = safeTrim(loginRequest.getCultureProcessedNo());
		String yearCode = safeTrim(addHardeningDetail.getYearCode());
		String cultureUUId = "";
		int cultureLabelId = 0;
		int cropTypeId = 0;
		int varietyId = 0;
		int actualPrimaryQuantity = 0;
		String parentCultureLine = safeTrim(addHardeningDetail.getParentCultureLine());
		String plotNumberTray = safeTrim(addHardeningDetail.getPlotNumberTray());
		String lotNumber = safeTrim(addHardeningDetail.getLotNumber());
		int cultureStageId = 0;
		String operationDate = safeTrim(addHardeningDetail.getOperationDate());
		int orderId = 0;
		int acceptedRootingQty = 0;
		int productId = 0;
		int inId = 0;
		int UOMId = 0;
		int totalQtyRootingTransfer = 0;
		int discardQty = 0;
		int oldProductId = 0;
		SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
		Trx trx = null;
		int fromLocatorId = 0;
		int toLocatorId = 0;
		PreparedStatement pstm1 = null;
		ResultSet rs1 = null;
		int documentType = 0;
		String tcpf = "";
		String personalCode = "";
		String discardReason = "Culture label discarded during primary hardening phase";

		// [CHANGE-1] Tracking variables declared OUTSIDE try so catch block can revert primarycheck
		List<Integer> discardedInIds = new ArrayList<>();          // tc_in ids marked 'Discarded' in THIS call
		List<Integer> processedInIds = new ArrayList<>();          // ALL tc_in ids (accepted + discarded) whose primarycheck we set to 'Y' in THIS call
		Map<Integer, String> originalDescMap = new HashMap<>();    // original description of discarded records (to restore on revert)
		boolean labelDiscardDone = false;                          // true once culture label discard SQL executed
		boolean flowCompleted = false;                             // true only when whole flow finished successfully
		Properties revertCtx = null;                               // ctx used in catch for revert

		try {
			initializeProps(Env.getCtx());
			getCompiereService().connect();
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			revertCtx = ctx; // [CHANGE-1] keep ctx for revert in catch
			setCtxProp(ctx);
			int orgId = Env.getAD_Org_ID(ctx);
			int clientId = Env.getAD_Client_ID(ctx);
			int userId = Env.getAD_User_ID(ctx);

			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			cropTypeId = addHardeningDetail.getPlantSpeciesId();
			varietyId = addHardeningDetail.getVarietyId();
			cultureStageId = addHardeningDetail.getCultureStageId();
			orderId = loginRequest.getOrderId();
			acceptedRootingQty = loginRequest.getQuantity();
			totalQtyRootingTransfer = Integer.parseInt(loginRequest.getCultureProcessedNo());
			actualPrimaryQuantity = loginRequest.getPrimaryQuantity();
			BigDecimal primaryQty = new BigDecimal(actualPrimaryQuantity);
			int recordId = TCUtills.getId(TABLE_TC_OUT, outUUId, clientId);
			if (recordId == 0) {
				addPrimaryHardeningDetailResponse.setError("Out Label UUId not found in table record " + outUUId + "");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (containsMaliciousPattern(parentCultureLine)) {
				addPrimaryHardeningDetailResponse.setError("Invalid input: Base64 or URL-encoded text not allowed");
				addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (containsMaliciousPattern(operationDate)) {
				addPrimaryHardeningDetailResponse.setError("Invalid input: Base64 or URL-encoded text not allowed");
				addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (containsMaliciousPattern(yearCode)) {
				addPrimaryHardeningDetailResponse.setError("Invalid input: Base64 or URL-encoded text not allowed");
				addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (containsMaliciousPattern(lotNumber)) {
				addPrimaryHardeningDetailResponse.setError("Invalid input: Base64 or URL-encoded text not allowed");
				addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (containsMaliciousPattern(plotNumberTray)) {
				addPrimaryHardeningDetailResponse.setError("Invalid input: Base64 or URL-encoded text not allowed");
				addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			
			if (!TCUtills.isValidNameNumber(parentCultureLine)) {
				addPrimaryHardeningDetailResponse.setError("Invalid Parent Culture Line format");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
	        }
			
			if (!TCUtills.isValidLocationName(plotNumberTray)) {
				addPrimaryHardeningDetailResponse.setError("Invalid Plot Number Tray format");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
	        }
			
			if (!TCUtills.isValidLocationName(lotNumber)) {
				addPrimaryHardeningDetailResponse.setError("Invalid Lot Number format");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
	        }
			
//			if (!TCUtills.isValidLocationName(cultureProcessedNumber)) {
//				addPrimaryHardeningDetailResponse.setError("Invalid Culture Processed Number format");
//				addPrimaryHardeningDetailResponse.setIsError(true);
//				return addPrimaryHardeningDetailResponseDocument;
//	        }
			
			if (!TCUtills.isValidLocationName(yearCode)) {
				addPrimaryHardeningDetailResponse.setError("Invalid Year Code format");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
	        }
			
			TCOut outOld = new TCOut(ctx, recordId, trx.getTrxName());
			fromLocatorId = outOld.getM_Locator_ID();
			oldProductId = outOld.getM_Product_ID();
			UOMId = outOld.getC_UOM_ID();

			int primaryLocatorId = TCUtills.getLocatorId(clientId, TABLE_LOCATOR, DEFAULT_LOCATOR_PH);
			if (primaryLocatorId == 0) {
				addPrimaryHardeningDetailResponse
						.setError("Locator serachKey not found in table record " + DEFAULT_LOCATOR_PH + "");
				addPrimaryHardeningDetailResponse.setIsError(true);
				return addPrimaryHardeningDetailResponseDocument;
			}
			toLocatorId = TCUtills.getLocatorId(clientId, TABLE_LOCATOR, DEFAULT_LOCATOR_HD);
			documentType = TCUtills.getDocTypeId(clientId, DOCUMENT_MATERIAL_MOVEMENT);

			// primarycheck = 'N' means REMAINING (not yet used) rooting quantity for this order
			List<PO> inIdList = new Query(ctx, TCIn.Table_Name,
					"tc_order_id = ? AND ad_client_id = ? AND primarycheck = 'N' AND EXISTS ("
							+ "SELECT 1 FROM M_Product p WHERE p.M_Product_ID = tc_in.M_Product_ID AND p.Description = 'Rooting')",
					trxName).setParameters(orderId, clientId).setOrderBy("tc_in_id ASC").list();
			// [OPTIONAL - concurrency] uncomment .setForUpdate(true) to lock rows so 2 parallel calls can't both pass validation:
			// .setParameters(orderId, clientId).setOrderBy("tc_in_id ASC").setForUpdate(true).list();
//			totalQty = inIdList.size();
//			discardQty = totalQtyRootingTransfer - acceptedRootingQty;
//			if (discardQty < 0) {
//				addPrimaryHardeningDetailResponse
//						.setError("Enter Quantity : " + rootingQty + " and available Quantity : " + totalQty + "");
//				addPrimaryHardeningDetailResponse.setIsError(true);
//				return addPrimaryHardeningDetailResponseDocument;
//			}

			// [CHANGE-2] NEW VALIDATION START (runs BEFORE any DB write, so nothing is affected if it fails)
			int availableQty = inIdList.size(); // remaining quantity (primarycheck = 'N')
			discardQty = loginRequest.getDiscardedQuantity(); // discard qty now comes from user input

			if (acceptedRootingQty < 0 || discardQty < 0) {
			    addPrimaryHardeningDetailResponse.setError("Quantity and discarded quantity cannot be negative");
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			if (availableQty == 0) {
			    addPrimaryHardeningDetailResponse.setError("No remaining Rooting quantity available for this order");
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			// accepted qty 0 would create out/label with tc_in_id = 0 (bad reference). Remove this block if you want to allow it.
			if (acceptedRootingQty == 0) {
			    addPrimaryHardeningDetailResponse.setError("Quantity must be greater than 0");
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			// accepted qty alone more than remaining. Example: remaining 3, user enters 4
			if (acceptedRootingQty > availableQty) {
			    addPrimaryHardeningDetailResponse.setError("Quantity (" + acceptedRootingQty
			            + ") is more than available Rooting quantity : " + availableQty);
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			// discard qty alone more than remaining. Example: remaining 3, discard 4
			if (discardQty > availableQty) {
			    addPrimaryHardeningDetailResponse.setError("Discarded quantity (" + discardQty
			            + ") is more than available Rooting quantity : " + availableQty);
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			// accepted + discard together more than remaining. Example: remaining 3, accepted 2 + discard 2
			if (acceptedRootingQty + discardQty > availableQty) {
			    addPrimaryHardeningDetailResponse.setError("Quantity (" + acceptedRootingQty + ") + Discarded quantity ("
			            + discardQty + ") exceeds available Rooting quantity : " + availableQty);
			    addPrimaryHardeningDetailResponse.setIsError(true);
			    return addPrimaryHardeningDetailResponseDocument;
			}
			// [CHANGE-2] NEW VALIDATION END

			BigDecimal discardQtys = new BigDecimal(discardQty);

			// accepted loop: marks first acceptedRootingQty records as used (primarycheck = 'Y')
			for (int i = 0; i < Math.min(inIdList.size(), acceptedRootingQty); i++) {
				PO inlist = inIdList.get(i);
				TCIn in = new TCIn(ctx, inlist.get_ID(), trx.getTrxName());
				in.setprimarycheck(true);
				in.saveEx();
//				trx.commit();
				inId = inlist.get_ID();
				processedInIds.add(inlist.get_ID()); // [CHANGE-3] track for revert
			}
			// [CHANGE-3] OLD LOOP (kept for reference): it marked ALL remaining records as Discarded, which is wrong now
//			for (int i = acceptedRootingQty; i < inIdList.size(); i++) {
//				PO inlist = inIdList.get(i);
//				TCIn in = new TCIn(ctx, inlist.get_ID(), trx.getTrxName());
//				in.setprimarycheck(true);
//				in.setDescription("Discarded");
//				in.saveEx();
////				trx.commit();
//			}

			// [CHANGE-3] NEW discard loop: mark ONLY the next discardQty records as Discarded.
			// Remaining records stay primarycheck = 'N' so they can be used in the next API call.
			for (int i = acceptedRootingQty; i < acceptedRootingQty + discardQty; i++) {
			    PO inlist = inIdList.get(i);
			    TCIn in = new TCIn(ctx, inlist.get_ID(), trx.getTrxName());
			    originalDescMap.put(inlist.get_ID(), in.getDescription()); // save original description for revert
			    in.setprimarycheck(true);
			    in.setDescription("Discarded");
			    in.saveEx();
			    discardedInIds.add(inlist.get_ID()); // used in label discard SQL (CHANGE-4)
			    processedInIds.add(inlist.get_ID()); // track for revert
			}
			
			PO culturedata = new Query(ctx, TABLE_TC_CULTURE, "tc_out_id= ? ", trxName)
					.setParameters(recordId).first();		
			
			TCCultureLabel culturelabel = new TCCultureLabel(ctx, culturedata.get_ID(), trxName);
			tcpf = culturelabel.gettcpf();
			cultureUUId = culturelabel.getc_uuid();
			cultureLabelId = culturelabel.get_ID();
			
			ADUser_Custom user = new ADUser_Custom(ctx, userId, trxName);
			personalCode= user.getpersonalcode();
			
			PO discardType = new Query(ctx, TABLE_DISCARD_TYPE, "AD_Client_ID = ? AND name = ?", trxName)
					.setParameters(clientId,OTHER_CULTURE_DISCARD_TYPE).first();
			
			int discardTypeId= discardType.get_ID();		
			
			String updateSql =
				    "UPDATE adempiere.tc_culturelabel cl " +
				    "SET isdiscarded = 'Y', " +
				    "    discarddate = NOW(), " +
				    "    tcpf2 = ?, " +
				    "    personalcode2 = ?, " +
				    "    discardreason = ?, " +
				    "    updated = NOW(), " +
				    "    updatedby = ? , tc_discardtype_id = ? " +
				    "FROM adempiere.tc_out o, adempiere.tc_in i " +
				    "WHERE cl.tc_out_id = o.tc_out_id " +
				    "AND o.c_uuid = i.parentuuid " +
				    "AND i.primarycheck = 'Y' " +
				    "AND i.description = 'Discarded' " +
				    "AND i.tc_order_id = ?";
			
			int updatedCount = 0;

			// [CHANGE-4] OLD BLOCK (kept for reference): matched ALL discarded records of the order,
			// so on 2nd call it re-updated labels discarded in 1st call (overwrote discarddate/personalcode2)
//			if (discardQty > 0) {
//
//			    try (PreparedStatement pstmt = DB.prepareStatement(updateSql, trx.getTrxName())) {
//
//			        pstmt.setString(1, tcpf);
//			        pstmt.setString(2, personalCode);
//			        pstmt.setString(3, discardReason);
//			        pstmt.setInt(4, userId);
//			        pstmt.setInt(5, discardTypeId);
//			        pstmt.setInt(6, orderId);
//
//			        updatedCount = pstmt.executeUpdate();
//
//			        log.info("Discarded culture labels updated: " + updatedCount);
//			    }
//			}

			// [CHANGE-4] NEW BLOCK: same SQL + "AND i.tc_in_id IN (...)" so ONLY records discarded in THIS call are updated
			if (discardQty > 0 && !discardedInIds.isEmpty()) {

			    StringBuilder inClause = new StringBuilder();
			    for (int i = 0; i < discardedInIds.size(); i++) {
			        inClause.append(i == 0 ? "?" : ",?");
			    }
			    String updateSqlFinal = updateSql + " AND i.tc_in_id IN (" + inClause + ")";

			    try (PreparedStatement pstmt = DB.prepareStatement(updateSqlFinal, trx.getTrxName())) {

			        pstmt.setString(1, tcpf);
			        pstmt.setString(2, personalCode);
			        pstmt.setString(3, discardReason);
			        pstmt.setInt(4, userId);
			        pstmt.setInt(5, discardTypeId);
			        pstmt.setInt(6, orderId);
			        int idx = 7; // [CHANGE-4] tc_in_id parameters start after the first 6
			        for (Integer discId : discardedInIds) {
			            pstmt.setInt(idx++, discId);
			        }

			        updatedCount = pstmt.executeUpdate();
			        labelDiscardDone = true; // [CHANGE-6] so catch can revert label discard

			        log.info("Discarded culture labels updated: " + updatedCount);
			    }
			}

			Date date = (Date) dateFormat.parse(operationDate);
			long timestampValue = date.getTime();
			Timestamp timestamp = new Timestamp(timestampValue);

			String sql1 = "SELECT name,m_product_id AS pId FROM adempiere.m_product WHERE name = ?"
					+ " AND ad_client_id = ?;";
			pstm1 = DB.prepareStatement(sql1, null);
			pstm1.setString(1, DEFAULT_PRODUCT_PH);
			pstm1.setInt(2, clientId);
			rs1 = pstm1.executeQuery();
			while (rs1.next()) {
				productId = rs1.getInt("pId");
			}

			TCOut out = new TCOut(ctx, 0, trx.getTrxName());
			out.setTC_order_ID(orderId);
			out.setAD_Org_ID(orgId);
			out.setTC_in_ID(inId);
			out.setM_Locator_ID(primaryLocatorId);
			out.setM_Product_ID(productId);
			out.setQuantity(primaryQty);
			out.setdiscardqty(discardQtys);
			out.setC_UOM_ID(UOMId);
			out.setcycle(1);
			if (!out.save()) {
				throw new Exception("Failed to add out data: " + out);
			}
			trx.commit();
			int outId = out.get_ID();

			TCPrimaryHardeningLabel hLabel = new TCPrimaryHardeningLabel(ctx, 0, trx.getTrxName());
			hLabel.setAD_Org_ID(orgId);
			hLabel.setcultureprocessednumber(cultureProcessedNumber);
			hLabel.setyearcode(yearCode);
			hLabel.settc_species_id(cropTypeId);
			hLabel.setTC_Variety_ID(varietyId);
			hLabel.setparentcultureline(parentCultureLine);
			hLabel.setlotnumber(lotNumber);
			hLabel.setplotnumbertray(plotNumberTray);
			hLabel.setTC_CultureStage_ID(cultureStageId);
			hLabel.setoperationdate(timestamp);
			hLabel.setTC_in_ID(inId);
			hLabel.setTC_out_ID(outId);
			if (!hLabel.save()) {
				throw new Exception("Failed to add Primary Hardening Label data: " + hLabel);
			}
			trx.commit();
			int pHLabelId = hLabel.get_ID();
			trx.commit();

			int retryCount = 0;
			String pHLUUid = null, newOutUUId = null;
			while (pHLUUid == null && newOutUUId == null && retryCount < 10) {
				pHLUUid = DB.getSQLValueString(null,
						"SELECT c_uuid FROM " + TABLE_PH + " WHERE " + TABLE_PH + "_id = ?", pHLabelId);
				newOutUUId = DB.getSQLValueString(null,
						"SELECT c_uuid FROM " + TABLE_TC_OUT + " WHERE " + TABLE_TC_OUT + "_id = ?", outId);
				if (pHLUUid == null && newOutUUId == null) {
					Thread.sleep(900); // Wait for 900ms before retrying (comment corrected, was 500ms)
					retryCount++;
				}
			}
			if (pHLUUid == null) {
				throw new Exception("Failed to get UUID for Primary Hardening ID: " + pHLabelId);
			}
			trx.commit();
			addPrimaryHardeningDetailResponse.setTCOrderId(orderId);
			addPrimaryHardeningDetailResponse.setOutUUId(newOutUUId);
			addPrimaryHardeningDetailResponse.setPrimaryHardeningLabelId(pHLabelId);
			addPrimaryHardeningDetailResponse.setPrimaryHardeningLabelUUId(pHLUUid);
			
			X_tc_primaryHardeningcultureS joinCulture = new X_tc_primaryHardeningcultureS(ctx, 0, trx.getTrxName());
			joinCulture.setTC_PrimaryHardeningLabel_ID(pHLabelId);
			joinCulture.setTC_cultureLabel_ID(cultureLabelId);
			joinCulture.setcultureuuid(cultureUUId);
			joinCulture.saveEx();
			trx.commit();

//			for (int i = 0; i < Math.min(inIdList.size(), acceptedRootingQty); i++) {
//				PO inlist = inIdList.get(i);
//				TCIn ins = new TCIn(ctx, inlist.get_ID(), trx.getTrxName());
//				List<PO> result = new Query(ctx, TABLE_TC_OUT,
//						"c_uuid IN (SELECT parentuuid FROM TC_In WHERE ad_client_id = ? AND tc_in_id = ?)", trxName)
//						.setParameters(clientId, ins.get_ID()).list();
//				for (PO outs : result) {
//					PO cultureLabel = new Query(ctx, TABLE_TC_CULTURE, "tc_out_id = ?", trxName)
//							.setParameters(outs.get_ID()).first();
//					if (cultureLabel != null) {
//						String cUuid = (String) cultureLabel.get_Value("c_uuid");
//						Integer cultureLabelId = (Integer) cultureLabel.get_Value("tc_culturelabel_id");
//
//						X_tc_primaryHardeningcultureS joinCulture = new X_tc_primaryHardeningcultureS(ctx, 0,
//								trx.getTrxName());
//						joinCulture.setTC_PrimaryHardeningLabel_ID(pHLabelId);
//						joinCulture.setTC_cultureLabel_ID(cultureLabelId);
//						joinCulture.setcultureuuid(cUuid);
//						joinCulture.saveEx();
//						trx.commit();
//					}
//				}
//			}
			
			if (discardQty > 0) {
				MMovement move = new MMovement(ctx, 0, trx.getTrxName());
				move.setAD_Org_ID(orgId);
				move.setDateReceived(timestamp);
				move.setC_DocType_ID(documentType);
				move.setM_Warehouse_ID(Env.getContextAsInt(ctx, Env.M_WAREHOUSE_ID));
				move.setM_WarehouseTo_ID(Env.getContextAsInt(ctx, Env.M_WAREHOUSE_ID));
				if (!move.save()) {
					throw new Exception("Failed to add Internal move data: " + move);
				}
				trx.commit();

				moveInventory(ctx, trxName, move, discardQtys, oldProductId, fromLocatorId, toLocatorId);

				move.saveEx();
				move.setDocStatus(DocAction.ACTION_Complete);
				move.setDocAction(DocAction.ACTION_Close);
				move.setPosted(true);
				move.setProcessed(true);
				move.setIsApproved(true);
				move.completeIt();
				move.saveEx();
			}
			flowCompleted = true; // [CHANGE-5] whole flow finished, so NO revert needed in catch
			addPrimaryHardeningDetailResponse.setIsError(false);

		} catch (Exception e) {
			if (trx != null) trx.rollback();

			// [CHANGE-6] REVERT primarycheck if flow did not complete.
			// Reason: trx.commit() is called in the middle of the flow, so primarycheck = 'Y' may already be committed
			// and trx.rollback() cannot undo it. We revert manually (outside trx, autocommit) so quantity is not lost.
			if (!flowCompleted && !processedInIds.isEmpty()) {
				try {
					// Step 1: revert culture label discard (must be BEFORE step 2, because the join uses tc_in_id)
					if (labelDiscardDone && !discardedInIds.isEmpty()) {
						StringBuilder discIds = new StringBuilder();
						for (int i = 0; i < discardedInIds.size(); i++) {
							discIds.append(i == 0 ? "" : ",").append(discardedInIds.get(i));
						}
						DB.executeUpdate(
								"UPDATE adempiere.tc_culturelabel cl " +
								"SET isdiscarded = 'N', discarddate = NULL, tcpf2 = NULL, personalcode2 = NULL, " +
								"    discardreason = NULL, tc_discardtype_id = NULL, updated = NOW() " +
								"FROM adempiere.tc_out o, adempiere.tc_in i " +
								"WHERE cl.tc_out_id = o.tc_out_id " +
								"AND o.c_uuid = i.parentuuid " +
								"AND i.tc_in_id IN (" + discIds + ")", null);
					}
					// Step 2: restore original description of discarded records
					for (Integer discId : discardedInIds) {
						String origDesc = originalDescMap.get(discId);
						if (origDesc == null) {
							DB.executeUpdate("UPDATE adempiere.tc_in SET description = NULL WHERE tc_in_id = " + discId, null);
						} else {
							DB.executeUpdate("UPDATE adempiere.tc_in SET description = ? WHERE tc_in_id = ?",
									new Object[] { origDesc, discId }, false, null);
						}
					}
					// Step 3: revert primarycheck back to 'N' for ALL records processed in this call
					StringBuilder allIds = new StringBuilder();
					for (int i = 0; i < processedInIds.size(); i++) {
						allIds.append(i == 0 ? "" : ",").append(processedInIds.get(i));
					}
					DB.executeUpdate("UPDATE adempiere.tc_in SET primarycheck = 'N' WHERE tc_in_id IN (" + allIds + ")", null);
					log.warning("primarycheck reverted for tc_in ids: " + allIds);
				} catch (Exception revertEx) {
					log.saveError("Error while reverting primarycheck : ", revertEx);
				}
			}

			addPrimaryHardeningDetailResponse.setError(INTERNAL_SERVER_ERROR);
			addPrimaryHardeningDetailResponse.setIsError(true);
			log.saveError("Error : " , e);
		} finally {
			closeDbCon(pstm1, rs1);
			if (trx != null) {
				trx.close();
			}

			getCompiereService().disconnect();
		}
		return addPrimaryHardeningDetailResponseDocument;
	}