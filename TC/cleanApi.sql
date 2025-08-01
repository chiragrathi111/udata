@Override
	public AddOrderLabelResponseDocument addOrderlabel(AddOrderLabelRequestDocument req) {
		AddOrderLabelResponseDocument addOrderLabelResponseDocument = AddOrderLabelResponseDocument.Factory
				.newInstance();
		AddOrderLabelResponse addOrderLabelResponse = addOrderLabelResponseDocument.addNewAddOrderLabelResponse();
		AddOrderLabelRequest loginRequest = req.getAddOrderLabelRequest();
		ADLoginRequest login = loginRequest.getADLoginRequest();
		String serviceType = loginRequest.getServiceType().trim();
		Trx trx = null;
		int client_id = login.getClientID();
		try {
			getCompiereService().connect();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			String err = login(login, webServiceName, "addOrder", serviceType);
			if (err != null && err.length() > 0) {
				addOrderLabelResponse.setError(err);
				addOrderLabelResponse.setIsError(true);
				return addOrderLabelResponseDocument;
			}
			if (!serviceType.equalsIgnoreCase("addOrder")) {
				addOrderLabelResponse.setError("Service type " + serviceType + " not configured");
				addOrderLabelResponse.setIsError(true);
				return addOrderLabelResponseDocument;
			}

			String sqlUpdateInvoices = "UPDATE adempiere.c_invoice SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteInvoiceLines = "DELETE FROM adempiere.c_invoiceline WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
			String sqlDeleteAllocationLines = "DELETE FROM adempiere.c_allocationline WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
			String sqlDeleteInvoiceTaxes = "DELETE FROM adempiere.c_invoicetax WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
			String sqlUpdatePayments = "UPDATE adempiere.c_invoice SET c_payment_id = NULL WHERE AD_Client_ID = ?";
			String sqlDeletePayments = "DELETE FROM adempiere.c_payment WHERE c_invoice_id IN (SELECT c_invoice_id FROM adempiere.c_invoice WHERE AD_Client_ID = ?)";
			String sqlDeleteInvoices = "DELETE FROM adempiere.c_invoice WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdateInvoices, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInvoiceLines, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteAllocationLines, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInvoiceTaxes, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlUpdatePayments, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePayments, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInvoices, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlUpdateInOut = "UPDATE adempiere.m_inout SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteTransactions = "DELETE FROM adempiere.m_transaction WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))";
			String sqlDeleteInOutLineMA = "DELETE FROM adempiere.m_inoutlinema WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))";
			String sqlDeleteInOutLine = "DELETE FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?)";
			String sqlDeleteInOut = "DELETE FROM adempiere.m_inout WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdateInOut, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteTransactions, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInOutLineMA, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInOutLine, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteInOut, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlUpdateOrders = "UPDATE adempiere.c_order SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteOrderLines = "DELETE FROM adempiere.c_orderline WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
			String sqlDeleteOrderTax = "DELETE FROM adempiere.c_ordertax WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
			String sqlDeleteOrders = "DELETE FROM adempiere.c_order WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdateOrders, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrderLines, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrderTax, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrders, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteSecondaryHardeningLabel = "DELETE FROM adempiere.tc_secondaryhardeningLabel WHERE AD_Client_ID = ?";
			String sqlDeletePrimaryHardeningCultureS = "DELETE FROM adempiere.tc_primaryHardeningcultureS WHERE AD_Client_ID = ?";
			String sqlDeletePrimaryHardeningLabel = "DELETE FROM adempiere.tc_primaryhardeningLabel WHERE AD_Client_ID = ?";
			String sqlDeleteCultureLabel = "DELETE FROM adempiere.tc_culturelabel WHERE AD_Client_ID = ?";
			String sqlDeleteExplantLabel = "DELETE FROM adempiere.tc_explantlabel WHERE AD_Client_ID = ?";
			String sqlDeletePlantTag = "DELETE FROM adempiere.tc_planttag WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteSecondaryHardeningLabel, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePrimaryHardeningCultureS, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePrimaryHardeningLabel, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteCultureLabel, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteExplantLabel, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePlantTag, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlUpdateOrder = "UPDATE adempiere.TC_Order SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteMediaOutline = "DELETE FROM adempiere.tc_mediaoutline WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
			String sqlDeleteOut = "DELETE FROM adempiere.tc_out WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
			String sqlDeleteIn = "DELETE FROM adempiere.tc_in WHERE TC_order_id IN (SELECT TC_order_id FROM adempiere.TC_Order WHERE AD_Client_ID = ?)";
			String sqlDeleteOrder = "DELETE FROM adempiere.TC_Order WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdateOrder, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteMediaOutline, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOut, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteIn, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrder, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteCollectionJoinPlant = "DELETE FROM adempiere.tc_collectionjoinplant WHERE tc_collectiondetails_id IN (SELECT tc_collectiondetails_id FROM adempiere.tc_collectiondetails WHERE AD_Client_ID = ?)";
			String sqlDeleteCollectionDetails = "DELETE FROM adempiere.tc_collectiondetails WHERE AD_Client_ID = ?";

			String sqlDeleteIntermediateJoinPlant = "DELETE FROM adempiere.tc_intermediatejoinplant WHERE tc_intermediatevisit_id IN (SELECT tc_intermediatevisit_id FROM adempiere.tc_intermediatevisit WHERE AD_Client_ID = ?)";
			String sqlDeleteIntermediateVisit = "DELETE FROM adempiere.tc_intermediatevisit WHERE AD_Client_ID = ?";

			String sqlDeleteFirstJoinPlant = "DELETE FROM adempiere.tc_firstjoinplant WHERE tc_firstvisit_id IN (SELECT tc_firstvisit_id FROM adempiere.tc_firstvisit WHERE AD_Client_ID = ?)";
			String sqlDeleteFirstVisit = "DELETE FROM adempiere.tc_firstvisit WHERE AD_Client_ID = ?";

			String sqlDeleteVisit = "DELETE FROM adempiere.TC_visit WHERE AD_Client_ID = ?";
			String sqlDeletePlantDetails = "DELETE FROM adempiere.tc_plantdetails WHERE AD_Client_ID = ?";
			String sqlDeleteFarmer = "DELETE FROM adempiere.TC_farmer WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteCollectionJoinPlant, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteCollectionDetails, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteIntermediateJoinPlant, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteIntermediateVisit, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteFirstJoinPlant, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteFirstVisit, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteVisit, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePlantDetails, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteFarmer, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteMediaLabelQR = "DELETE FROM adempiere.TC_medialabelqr WHERE AD_Client_ID = ?";
			String sqlUpdateMediaOrder = "UPDATE adempiere.TC_MediaOrder SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteMediaLine = "DELETE FROM adempiere.TC_MediaLine WHERE TC_MediaOrder_id IN (SELECT TC_MediaOrder_id FROM adempiere.TC_MediaOrder WHERE AD_Client_ID = ?)";
			String sqlDeleteMediaOrder = "DELETE FROM adempiere.TC_MediaOrder WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteMediaLabelQR, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlUpdateMediaOrder, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteMediaLine, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteMediaOrder, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteTransaction = "DELETE FROM adempiere.M_Transaction WHERE AD_Client_ID = ?";
			String sqlDeleteStorage = "DELETE FROM adempiere.M_StorageOnHand WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteTransaction, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteStorage, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteMovementLine = "DELETE FROM adempiere.M_MovementLine WHERE M_Movement_ID IN (SELECT M_Movement_ID FROM adempiere.M_Movement WHERE AD_Client_ID = ?)";
			String sqlDeleteMovement = "DELETE FROM adempiere.M_Movement WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteMovementLine, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteMovement, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteTemperatureStatus = "DELETE FROM adempiere.tc_temperatureStatus WHERE AD_Client_ID = ?";
			String sqlDeleteLight = "DELETE FROM adempiere.tc_light WHERE AD_Client_ID = ?";
//			String sqlDeleteDeviceData = "DELETE FROM adempiere.TC_devicedata WHERE AD_Client_ID = ?";
			DB.executeUpdateEx(sqlDeleteTemperatureStatus, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteLight, new Object[] { client_id }, trxName);
//			DB.executeUpdateEx(sqlDeleteDeviceData, new Object[] { client_id }, trxName);
			trx.commit();

			addOrderLabelResponse.setIsError(false);
			addOrderLabelResponse.setError("Deleted Successfully");
		} catch (Exception e) {
			e.printStackTrace();
			addOrderLabelResponse.setError(e.getMessage());
			addOrderLabelResponse.setIsError(true);
		} finally {
			if (trx != null) {
				trx.close();
			}
			getCompiereService().disconnect();
		}
		return addOrderLabelResponseDocument;
	}