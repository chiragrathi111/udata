Search method one field search and result show multiple fields:-
		int clientID = 1000002;
		String docno = "";
		String doc = "800022";
		PreparedStatement pstm = null;
		ResultSet rs  = null;
		
		String sql = "SELECT DISTINCT\n"
				+ "    po.documentno AS purchase_order,\n"
				+ "    bp.name AS Supplier,\n"
				+ "    TO_CHAR(po.dateordered, 'DD-MM-YYYY') AS Order_Date,\n"
				+ "    wh.name AS Warehouse_Name,\n"
				+ "    po.description,\n"
				+ "    CASE\n"
				+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NULL THEN false\n"
				+ "        WHEN po.docstatus = 'CO' AND mr.m_inout_id IS NOT NULL THEN true \n"
				+ "    END AS status\n"
				+ "FROM adempiere.c_order po\n"
				+ "JOIN adempiere.c_orderline pol ON po.c_order_id = pol.c_order_id\n"
				+ "LEFT JOIN adempiere.m_inout mr ON po.c_order_id = mr.c_order_id\n"
				+ "JOIN adempiere.c_bpartner bp ON po.c_bpartner_id = bp.c_bpartner_id \n"
				+ "JOIN adempiere.m_warehouse wh ON po.m_warehouse_id = wh.m_warehouse_id\n"
				+ "WHERE pol.qtyordered > (\n"
				+ "    SELECT COALESCE(SUM(iol.qtyentered), 0)\n"
				+ "    FROM adempiere.m_inoutline iol\n"
				+ "    WHERE iol.c_orderline_id = pol.c_orderline_id\n"
				+ ") AND po.ad_client_id = 1000002 AND po.docstatus = 'CO' AND po.issotrx = 'N'\n"
				+ "and po.documentno ILIKE '%' || COALESCE(?,po.documentno) || '%' OR bp.name ILIKE '%' \n"
				+ "|| COALESCE(?,bp.name) || '%' OR wh.name ILIKE '%' || COALESCE(?,wh.name) || '%' OR po.description ILIKE '%' || COALESCE(?,po.description) || '%'\n"
				+ "ORDER BY po.documentno DESC;\n"
				+ "";
		
		pstm = DB.prepareStatement(sql.toString(), null);
		pstm.setString(1, doc);
		pstm.setString(2, doc);
		pstm.setString(3, doc);
		pstm.setString(4, doc);
		rs = pstm.executeQuery();
		
		while(rs.next()) {
			docno = rs.getString("purchase_order");
			System.out.println(docno);
		}
		
		return docno;

============================================================================================================================================================
