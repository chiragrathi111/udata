***************************************************************
M_Inout :-
-- Reset shipments
UPDATE adempiere.m_inout 
SET docstatus = 'DR', docaction = 'CO', processed = 'N' 
WHERE AD_Client_ID = 1000000;

-- Delete related lines & transactions
DELETE FROM adempiere.m_matchpo 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000));

DELETE FROM adempiere.m_matchinv 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000));

DELETE FROM adempiere.m_transaction 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000));

DELETE FROM adempiere.m_inoutlinema 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000));

DELETE FROM adempiere.pi_productlabel 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000));

DELETE FROM adempiere.m_costhistory 
WHERE m_costdetail_id IN (
    SELECT cd.m_costdetail_id 
    FROM adempiere.m_costdetail cd
    JOIN adempiere.m_inoutline iol ON cd.m_inoutline_id = iol.m_inoutline_id
    WHERE iol.AD_Client_ID = 1000000
);

DELETE FROM adempiere.m_costdetail 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE AD_Client_ID = 1000000);

UPDATE adempiere.m_inoutline 
SET m_rmaline_id = NULL 
WHERE m_rmaline_id IN (
    SELECT rma.m_rmaline_id 
    FROM adempiere.m_rmaline rma
    JOIN adempiere.m_inoutline iol ON rma.m_inoutline_id = iol.m_inoutline_id
    WHERE iol.AD_Client_ID = 1000000
) AND AD_Client_ID = 1000000;

DELETE FROM adempiere.m_rmaline 
WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE AD_Client_ID = 1000000);

DELETE FROM adempiere.m_rmatax 
WHERE m_rma_id IN (SELECT m_rma_id FROM adempiere.m_rma WHERE AD_Client_ID = 1000000);

UPDATE adempiere.m_inout 
SET m_rma_id = NULL 
WHERE m_rma_id IN (
    SELECT m_rma_id 
    FROM adempiere.m_rma 
    WHERE AD_Client_ID = 1000000
) AND AD_Client_ID = 1000000;

DELETE FROM adempiere.m_rma WHERE AD_Client_ID = 1000000;

DELETE FROM adempiere.m_inoutline 
WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = 1000000);

DELETE FROM adempiere.m_inout WHERE AD_Client_ID = 1000000;

************************************************************************
========================================================================
************************************************************************
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
			
			String sqlUpdatePAOrder = "UPDATE adempiere.pi_paorder SET processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteReceiveQty = "DELETE FROM adempiere.pi_paorderreceiveqty WHERE AD_Client_ID = ?";
			String sqlDeletePackingQty = "DELETE FROM adempiere.pi_paorderpackingqty WHERE AD_Client_ID = ?";
			String sqlDeleteProductLabel2 = "DELETE FROM adempiere.pi_productlabel WHERE AD_Client_ID = ?";
			String sqlDeletePAOrder = "DELETE FROM adempiere.pi_paorder WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdatePAOrder, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteReceiveQty, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePackingQty, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteProductLabel2, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePAOrder, new Object[] { client_id }, trxName);

			trx.commit();
			
			// 1. Reset m_inout status for the client
			DB.executeUpdateEx(
			    "UPDATE adempiere.m_inout SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?",
			    new Object[]{client_id},
			    trxName
			);

			// 2. All delete / update statements
			String[] deleteStatements = {
			    "DELETE FROM adempiere.m_matchpo WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))",
			    "DELETE FROM adempiere.m_matchinv WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))",
			    "DELETE FROM adempiere.m_transaction WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))",
			    "DELETE FROM adempiere.m_inoutlinema WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))",
			    "DELETE FROM adempiere.pi_productlabel WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?))",
			    "DELETE FROM adempiere.m_costhistory WHERE m_costdetail_id IN (SELECT cd.m_costdetail_id FROM adempiere.m_costdetail cd JOIN adempiere.m_inoutline iol ON cd.m_inoutline_id = iol.m_inoutline_id WHERE iol.AD_Client_ID = ?)",
			    "DELETE FROM adempiere.m_costdetail WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE AD_Client_ID = ?)",
			    // This one has 2 placeholders
			    "UPDATE adempiere.m_inoutline SET m_rmaline_id = NULL WHERE m_rmaline_id IN (SELECT rma.m_rmaline_id FROM adempiere.m_rmaline rma JOIN adempiere.m_inoutline iol ON rma.m_inoutline_id = iol.m_inoutline_id WHERE iol.AD_Client_ID = ?) AND AD_Client_ID = ?",
			    "DELETE FROM adempiere.m_rmaline WHERE m_inoutline_id IN (SELECT m_inoutline_id FROM adempiere.m_inoutline WHERE AD_Client_ID = ?)",
			    "DELETE FROM adempiere.m_rmatax WHERE m_rma_id IN (SELECT m_rma_id FROM adempiere.m_rma WHERE AD_Client_ID = ?)",
			    // This one has 2 placeholders
			    "UPDATE adempiere.m_inout SET m_rma_id = NULL WHERE m_rma_id IN (SELECT m_rma_id FROM adempiere.m_rma WHERE AD_Client_ID = ?) AND AD_Client_ID = ?",
			    "DELETE FROM adempiere.m_rma WHERE AD_Client_ID = ?",
			    "DELETE FROM adempiere.m_inoutline WHERE m_inout_id IN (SELECT m_inout_id FROM adempiere.m_inout WHERE AD_Client_ID = ?)",
			    "DELETE FROM adempiere.m_inout WHERE AD_Client_ID = ?"
			};

			// 3. Execute all statements
			for (String sql : deleteStatements) {
			    int count = sql.length() - sql.replace("?", "").length(); // count placeholders
			    if (count == 1) {
			        DB.executeUpdateEx(sql, new Object[]{client_id}, trxName);
			    } else if (count == 2) {
			        DB.executeUpdateEx(sql, new Object[]{client_id, client_id}, trxName);
			    }
			}
			trx.commit();
			
			String sqlUpdateOrders = "UPDATE adempiere.c_order SET docstatus = 'DR', docaction = 'CO', processed = 'N' WHERE AD_Client_ID = ?";
			String sqlDeleteCostHistory = "DELETE FROM adempiere.m_costhistory WHERE m_costdetail_id IN (" +
			        "SELECT m_costdetail_id FROM adempiere.m_costdetail " +
			        "WHERE c_orderline_id IN (" +
			        "SELECT c_orderline_id FROM adempiere.c_orderline " +
			        "WHERE c_order_id IN (" +
			        "SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)))";
			String sqlDeleteCostDetail = "DELETE FROM adempiere.m_costdetail WHERE c_orderline_id IN (SELECT c_orderline_id FROM adempiere.c_orderline WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?))";
			String sqlDeleteOrderTax = "DELETE FROM adempiere.c_ordertax WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
			String sqlDeleteProductLabelFromOrder = "DELETE FROM adempiere.pi_productlabel " +
				    "WHERE c_orderline_id IN (SELECT c_orderline_id FROM adempiere.c_orderline WHERE ad_client_id = ?)";
			String sqlDeletePPCostCollectorMA = "DELETE FROM pp_cost_collectorma " +
			        "WHERE pp_cost_collector_id IN (" +
			        "   SELECT pp_cost_collector_id FROM pp_cost_collector " +
			        "   WHERE pp_order_id IN (" +
			        "       SELECT pp_order_id FROM pp_order " +
			        "       WHERE c_orderline_id IN (" +
			        "           SELECT c_orderline_id FROM c_orderline " +
			        "           WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPCostCollector = "DELETE FROM pp_cost_collector " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeleteProductLAbel = "DELETE FROM adempiere.pi_productlabel\n"
					+ "WHERE pi_orderreceipt_id IN (SELECT pi_orderreceipt_id FROM adempiere.pi_orderreceipt WHERE ad_client_id = ?)";
			
			String sqlDeletePIOrderReceipt = "DELETE FROM pi_orderreceipt " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeletePPMRP = "DELETE FROM pp_mrp " +
			        "WHERE pp_order_bomline_id IN (" +
			        "   SELECT pp_order_bomline_id FROM pp_order_bomline " +
			        "   WHERE pp_order_bom_id IN (" +
			        "       SELECT pp_order_bom_id FROM pp_order_bom " +
			        "       WHERE pp_order_id IN (" +
			        "           SELECT pp_order_id FROM pp_order " +
			        "           WHERE c_orderline_id IN (" +
			        "               SELECT c_orderline_id FROM c_orderline " +
			        "               WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "           )" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderBOMLineTrl = "DELETE FROM pp_order_bomline_trl " +
			        "WHERE pp_order_bomline_id IN (" +
			        "   SELECT pp_order_bomline_id FROM pp_order_bomline " +
			        "   WHERE pp_order_bom_id IN (" +
			        "       SELECT pp_order_bom_id FROM pp_order_bom " +
			        "       WHERE pp_order_id IN (" +
			        "           SELECT pp_order_id FROM pp_order " +
			        "           WHERE c_orderline_id IN (" +
			        "               SELECT c_orderline_id FROM c_orderline " +
			        "               WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "           )" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderBOMLine = "DELETE FROM pp_order_bomline " +
			        "WHERE pp_order_bom_id IN (" +
			        "   SELECT pp_order_bom_id FROM pp_order_bom " +
			        "   WHERE pp_order_id IN (" +
			        "       SELECT pp_order_id FROM pp_order " +
			        "       WHERE c_orderline_id IN (" +
			        "           SELECT c_orderline_id FROM c_orderline " +
			        "           WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderBOMTrl = "DELETE FROM pp_order_bom_trl " +
			        "WHERE pp_order_bom_id IN (" +
			        "   SELECT pp_order_bom_id FROM pp_order_bom " +
			        "   WHERE pp_order_id IN (" +
			        "       SELECT pp_order_id FROM pp_order " +
			        "       WHERE c_orderline_id IN (" +
			        "           SELECT c_orderline_id FROM c_orderline " +
			        "           WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderBOM = "DELETE FROM pp_order_bom " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeletePPMRPFromOrder = "DELETE FROM pp_mrp " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderCost = "DELETE FROM pp_order_cost " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderNodeTrl = "DELETE FROM pp_order_node_trl " +
			        "WHERE pp_order_node_id IN (" +
			        "   SELECT pp_order_node_id FROM pp_order_node " +
			        "   WHERE pp_order_id IN (" +
			        "       SELECT pp_order_id FROM pp_order " +
			        "       WHERE c_orderline_id IN (" +
			        "           SELECT c_orderline_id FROM c_orderline " +
			        "           WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderWorkflowTrl = "DELETE FROM pp_order_workflow_trl " +
			        "WHERE pp_order_workflow_id IN (" +
			        "   SELECT pp_order_workflow_id FROM pp_order_workflow " +
			        "   WHERE pp_order_node_id IN (" +
			        "       SELECT pp_order_node_id FROM pp_order_node " +
			        "       WHERE pp_order_id IN (" +
			        "           SELECT pp_order_id FROM pp_order " +
			        "           WHERE c_orderline_id IN (" +
			        "               SELECT c_orderline_id FROM c_orderline " +
			        "               WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "           )" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderWorkflow = "DELETE FROM pp_order_workflow " +
			        "WHERE pp_order_node_id IN (" +
			        "   SELECT pp_order_node_id FROM pp_order_node " +
			        "   WHERE pp_order_id IN (" +
			        "       SELECT pp_order_id FROM pp_order " +
			        "       WHERE c_orderline_id IN (" +
			        "           SELECT c_orderline_id FROM c_orderline " +
			        "           WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "       )" +
			        "   )" +
			        ")";
			String sqlDeletePPOrderNode = "DELETE FROM pp_order_node " +
			        "WHERE pp_order_id IN (" +
			        "   SELECT pp_order_id FROM pp_order " +
			        "   WHERE c_orderline_id IN (" +
			        "       SELECT c_orderline_id FROM c_orderline " +
			        "       WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        "   )" +
			        ")";
			String sqlDeletePPOrder = "DELETE FROM pp_order " +
			        "WHERE c_orderline_id IN (" +
			        "   SELECT c_orderline_id FROM c_orderline " +
			        "   WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        ")";
			String sqlDeletePPMRPFromOrderLine = "DELETE FROM pp_mrp " +
			        "WHERE c_orderline_id IN (" +
			        "    SELECT c_orderline_id FROM c_orderline " +
			        "    WHERE c_order_id IN (SELECT c_order_id FROM c_order WHERE ad_client_id = ?)" +
			        ")";
			String sqlDeletePPMRPs = "DELETE FROM adempiere.pp_mrp\n"
					+ "WHERE c_orderline_id IN (\n"
					+ "    SELECT c_orderline_id \n"
					+ "    FROM adempiere.c_orderline \n"
					+ "    WHERE AD_Client_ID = ? \n"
					+ ");";
			String sqlDeleteOrderLines = "DELETE FROM adempiere.c_orderline WHERE c_order_id IN (SELECT c_order_id FROM adempiere.c_order WHERE AD_Client_ID = ?)";
			String sqlDeleteOrders = "DELETE FROM adempiere.c_order WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlUpdateOrders, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteCostHistory, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteCostDetail, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrderTax, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteProductLabelFromOrder, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeletePPCostCollectorMA, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPCostCollector, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeleteProductLAbel, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePIOrderReceipt, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPMRP, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrderBOMLineTrl, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrderBOMLine, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPOrderBOMTrl, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrderBOM, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPMRPFromOrder, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPOrderCost, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPOrderNodeTrl, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPOrderWorkflowTrl, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrderWorkflow, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrderNode, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPOrder, new Object[]{client_id}, trxName);
			DB.executeUpdateEx(sqlDeletePPMRPFromOrderLine, new Object[]{client_id}, trxName);

			DB.executeUpdateEx(sqlDeletePPMRPs, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrderLines, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteOrders, new Object[] { client_id }, trxName);
			trx.commit();
			
			String sqlDeleteUserToken = "DELETE FROM adempiere.pi_userToken WHERE AD_Client_ID = ?";
			String sqlDeleteProductLabel = "DELETE FROM adempiere.pi_productLabel WHERE AD_Client_ID = ?";
			DB.executeUpdateEx(sqlDeleteUserToken, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteProductLabel, new Object[] { client_id }, trxName);
			trx.commit();

			String deleteCostHistory = "DELETE FROM adempiere.M_CostHistory " + "WHERE M_CostDetail_ID IN ("
					+ "SELECT M_CostDetail_ID FROM adempiere.M_CostDetail WHERE AD_Client_ID = ?" + ")";
			String deleteCostDetail = "DELETE FROM adempiere.M_CostDetail WHERE AD_Client_ID = ?";
			String deleteAllocations = "DELETE FROM adempiere.M_TransactionAllocation WHERE AD_Client_ID = ?";
			String sqlDeleteTransaction = "DELETE FROM adempiere.M_Transaction WHERE AD_Client_ID = ?";
			String sqlDeleteStorage = "DELETE FROM adempiere.M_StorageOnHand WHERE AD_Client_ID = ?";
			String sqlDeleteStorageReservation = "DELETE FROM adempiere.m_storagereservation WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(deleteCostHistory, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(deleteCostDetail, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(deleteAllocations, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteTransaction, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteStorage, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteStorageReservation, new Object[] { client_id }, trxName);
			trx.commit();

			String sqlDeleteMovementLine = "DELETE FROM adempiere.M_MovementLine WHERE M_Movement_ID IN (SELECT M_Movement_ID FROM adempiere.M_Movement WHERE AD_Client_ID = ?)";
			String sqlDeleteMovement = "DELETE FROM adempiere.M_Movement WHERE AD_Client_ID = ?";

			DB.executeUpdateEx(sqlDeleteMovementLine, new Object[] { client_id }, trxName);
			DB.executeUpdateEx(sqlDeleteMovement, new Object[] { client_id }, trxName);
			trx.commit();
			
			DB.executeUpdateEx(
				    "DELETE FROM pi_orderreceipt WHERE ad_client_id=?",
				    new Object[]{ client_id }, trxName
				);
			
			DB.executeUpdateEx(
				    "DELETE FROM pi_machineconf WHERE ad_client_id=?",
				    new Object[]{ client_id }, trxName
				);
			
			String[] ppOrderStatements = {
					"UPDATE ad_clientinfo SET m_productfreight_id = NULL WHERE m_productfreight_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    
					"DELETE FROM fact_acct WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
					
				    // Delete cost records
				    "DELETE FROM m_cost WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",				    
				    // De
					"DELETE FROM m_storageonhand WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_storagereservation WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_transaction WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Pricing / Purchase / Replenishment
				    "DELETE FROM m_productprice WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_product_po WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_replenish WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Order / Invoice Lines
				    "DELETE FROM c_orderline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM c_invoiceline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Material Transactions
				    "DELETE FROM m_inoutline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_matchpo WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_matchinv WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // PI Return Lines
				    "DELETE FROM pi_returnline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Accounting Schema Elements
				    "DELETE FROM c_acctschema_element WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_inventoryline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_storagereservationlog WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM pp_product_planning WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM pp_mrp WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM pp_product_bomline_trl WHERE pp_product_bomline_id IN (SELECT pp_product_bomline_id FROM pp_product_bomline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?))",

				    "DELETE FROM pp_product_bomline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM pp_product_bom_trl WHERE pp_product_bom_id IN (SELECT pp_product_bom_id FROM pp_product_bom WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?))",

				    "DELETE FROM pp_product_bom WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Finally delete product
				    "DELETE FROM m_product WHERE ad_client_id=?",

				    // First delete translation records
				    "DELETE FROM pp_cost_collectorma WHERE pp_cost_collector_id IN (SELECT pp_cost_collector_id FROM pp_cost_collector WHERE pp_order_workflow_id IN (SELECT pp_order_workflow_id FROM pp_order_workflow WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)))",

				    "DELETE FROM pp_cost_collector WHERE pp_order_workflow_id IN (SELECT pp_order_workflow_id FROM pp_order_workflow WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?))",
				    
				    "DELETE FROM pp_order_workflow_trl WHERE pp_order_workflow_id IN (SELECT pp_order_workflow_id FROM pp_order_workflow WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?))",
				    
				    // Then delete workflow related records
				    "DELETE FROM pp_order_workflow WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)",
				    
				    // Delete other dependent tables (removed pp_order_transaction as it doesn't exist)
				    "DELETE FROM pp_order_cost WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)",
				    "DELETE FROM pp_order_bomline_trl WHERE pp_order_bomline_id IN (SELECT pp_order_bomline_id FROM pp_order_bomline WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?))",

				    "DELETE FROM pp_order_bomline WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)",
				    "DELETE FROM pp_order_bom_trl WHERE pp_order_bom_id IN (SELECT pp_order_bom_id FROM pp_order_bom WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?))",

				    "DELETE FROM pp_order_bom WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)",
				    "DELETE FROM pp_order_node_trl\n"
				    + "WHERE pp_order_node_id IN (\n"
				    + "    SELECT pp_order_node_id\n"
				    + "    FROM pp_order_node\n"
				    + "    WHERE ad_client_id = ?)",
				    "DELETE FROM pp_order_node WHERE pp_order_id IN (SELECT pp_order_id FROM pp_order WHERE ad_client_id=?)",
				    
				    // Finally delete the main order
				    "DELETE FROM pp_order WHERE ad_client_id=?"
				};
			
			for (String sql : ppOrderStatements) {
		        DB.executeUpdateEx(sql, new Object[]{client_id}, trxName);
		    }
			
			String[] sqlStatements = {
				    // Delete storage, reservations, etc.
				    "DELETE FROM m_storageonhand WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_storagereservation WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_transaction WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Pricing / Purchase / Replenishment
				    "DELETE FROM m_productprice WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_product_po WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_replenish WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Order / Invoice Lines
				    "DELETE FROM c_orderline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM c_invoiceline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Delete Material Transactions
				    "DELETE FROM m_inoutline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_matchpo WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",
				    "DELETE FROM m_matchinv WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // PI Return Lines
				    "DELETE FROM pi_returnline WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // *** NEW: Accounting Schema Elements ***
				    "DELETE FROM c_acctschema_element WHERE m_product_id IN (SELECT m_product_id FROM m_product WHERE ad_client_id=?)",

				    // Finally delete product
				    "DELETE FROM m_product WHERE ad_client_id=?"
				};
			
			for (String sql : sqlStatements) {
		        DB.executeUpdateEx(sql, new Object[]{client_id}, trxName);
		    }

			trx.commit();



************************************************************************
========================================================================
************************************************************************





************************************************************************
========================================================================
************************************************************************




************************************************************************
========================================================================
************************************************************************






************************************************************************
========================================================================
************************************************************************