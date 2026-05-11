Table view with primary key :-

CREATE OR REPLACE VIEW adempiere.pp_pipeline_view12 AS

SELECT
	ROW_NUMBER() OVER (ORDER BY c.ad_client_id, s.seqno) AS pp_pipeline_view12_id,
    s.seqno,
    s.name,
    'P2P Pipeline' AS seriesname,
    COALESCE(b.doccount, 0) AS doccount,
    COALESCE(b.totalvalue, 0) AS totalvalue,
    c.ad_client_id,
    0 AS ad_org_id
FROM (
    VALUES
        (1,'1. Requisitions Pending Approval'),
        (2,'2. POs Awaiting Acknowledgment'),
        (3,'3. GRN Pending Invoice'),
        (4,'4. Invoices in Verification'),
        (5,'5. Ready for Payment')
) AS s(seqno, name)

-- 🔥 Get current client dynamically
CROSS JOIN (
    SELECT DISTINCT ad_client_id FROM adempiere.ad_client
) c

LEFT JOIN (

    -- 1
    SELECT ad_client_id, 1 AS seqno,
           COUNT(*) AS doccount,
           COALESCE(SUM(totallines), 0) AS totalvalue
    FROM adempiere.m_requisition
    WHERE docstatus IN ('DR','IP')
    GROUP BY ad_client_id

    UNION ALL

    -- 2
    SELECT ad_client_id, 2,
           COUNT(*),
           COALESCE(SUM(grandtotal), 0)
    FROM adempiere.c_order
    WHERE issotrx='N'
      AND docstatus='CO'
      AND isdelivered='N'
      AND isinvoiced='N'
    GROUP BY ad_client_id

    UNION ALL

    -- 3
    SELECT ad_client_id, 3,
           COUNT(DISTINCT m_inout_id),
           0
    FROM adempiere.m_inout
    WHERE issotrx='N'
      AND docstatus IN ('CO','CL')
    GROUP BY ad_client_id

    UNION ALL

    -- 4
    SELECT ad_client_id, 4,
           COUNT(*),
           COALESCE(SUM(grandtotal), 0)
    FROM adempiere.c_invoice
    WHERE issotrx='N'
      AND docstatus='IP'
    GROUP BY ad_client_id

    UNION ALL

    -- 5
    SELECT i.ad_client_id, 5,
           COUNT(*),
           COALESCE(SUM(i.grandtotal - COALESCE(p.paidamt, 0)), 0)
    FROM adempiere.c_invoice i
    LEFT JOIN (
        SELECT c_invoice_id, SUM(amount) AS paidamt
        FROM adempiere.c_paymentallocate
        GROUP BY c_invoice_id
    ) p ON p.c_invoice_id = i.c_invoice_id
    WHERE i.issotrx='N'
      AND i.docstatus='CO'
      AND i.ispaid='N'
    GROUP BY i.ad_client_id

) b 
ON b.seqno = s.seqno 
AND b.ad_client_id = c.ad_client_id;









=====================================================================
Java code fix :-
ChartBuilder.java

// REPLACE WITH THIS:
//              String[] keyCols = MTable.get(Env.getCtx(), ds.getAD_Table_ID()).getKeyColumns();
//              String keyCol = (keyCols != null && keyCols.length > 0) ? keyCols[0] : "";
//
//              if (!keyCol.isEmpty()) {
//                  MQuery query1 = new MQuery(ds.getAD_Table_ID());
//                  String whereClause = keyCol + " IN (SELECT " + ds.getKeyColumn() 
//                      + " FROM " + ds.getFromClause() + " WHERE " + queryWhere + ")";
//                  query1.addRestriction(whereClause);
//                  query1.setRecordCount(1);
//                  HashMap<String, MQuery> map = getQueries();
//                  if (dataset instanceof DefaultPieDataset) {
//                      ((DefaultPieDataset) dataset).setValue(key, rs.getBigDecimal(1));
//                      map.put(key, query1);
//                  } else if (dataset instanceof DefaultCategoryDataset) {
//                      ((DefaultCategoryDataset) dataset).addValue(rs.getBigDecimal(1), seriesName, key);
//                      map.put(seriesName + "__" + key, query1);
//                  }
//              } else {
//                  // No key column - just add data without drill-down
//                  if (dataset instanceof DefaultPieDataset) {
//                      ((DefaultPieDataset) dataset).setValue(key, rs.getBigDecimal(1));
//                  } else if (dataset instanceof DefaultCategoryDataset) {
//                      ((DefaultCategoryDataset) dataset).addValue(rs.getBigDecimal(1), seriesName, key);
//                  }
//              }

--------------------------------------------------------------------------

without primary ket table view :-

CREATE OR REPLACE VIEW adempiere.pp_pipeline_view11 AS

SELECT
    s.seqno,
    s.name,
    'P2P Pipeline' AS seriesname,
    COALESCE(b.doccount, 0) AS doccount,
    COALESCE(b.totalvalue, 0) AS totalvalue,
    c.ad_client_id,
    0 AS ad_org_id
FROM (
    VALUES
        (1,'1. Requisitions Pending Approval'),
        (2,'2. POs Awaiting Acknowledgment'),
        (3,'3. GRN Pending Invoice'),
        (4,'4. Invoices in Verification'),
        (5,'5. Ready for Payment')
) AS s(seqno, name)

-- 🔥 Get current client dynamically
CROSS JOIN (
    SELECT DISTINCT ad_client_id FROM adempiere.ad_client
) c

LEFT JOIN (

    -- 1
    SELECT ad_client_id, 1 AS seqno,
           COUNT(*) AS doccount,
           COALESCE(SUM(totallines), 0) AS totalvalue
    FROM adempiere.m_requisition
    WHERE docstatus IN ('DR','IP')
    GROUP BY ad_client_id

    UNION ALL

    -- 2
    SELECT ad_client_id, 2,
           COUNT(*),
           COALESCE(SUM(grandtotal), 0)
    FROM adempiere.c_order
    WHERE issotrx='N'
      AND docstatus='CO'
      AND isdelivered='N'
      AND isinvoiced='N'
    GROUP BY ad_client_id

    UNION ALL

    -- 3
    SELECT ad_client_id, 3,
           COUNT(DISTINCT m_inout_id),
           0
    FROM adempiere.m_inout
    WHERE issotrx='N'
      AND docstatus IN ('CO','CL')
    GROUP BY ad_client_id

    UNION ALL

    -- 4
    SELECT ad_client_id, 4,
           COUNT(*),
           COALESCE(SUM(grandtotal), 0)
    FROM adempiere.c_invoice
    WHERE issotrx='N'
      AND docstatus='IP'
    GROUP BY ad_client_id

    UNION ALL

    -- 5
    SELECT i.ad_client_id, 5,
           COUNT(*),
           COALESCE(SUM(i.grandtotal - COALESCE(p.paidamt, 0)), 0)
    FROM adempiere.c_invoice i
    LEFT JOIN (
        SELECT c_invoice_id, SUM(amount) AS paidamt
        FROM adempiere.c_paymentallocate
        GROUP BY c_invoice_id
    ) p ON p.c_invoice_id = i.c_invoice_id
    WHERE i.issotrx='N'
      AND i.docstatus='CO'
      AND i.ispaid='N'
    GROUP BY i.ad_client_id

) b 
ON b.seqno = s.seqno 
AND b.ad_client_id = c.ad_client_id;
-----------------------------------------------------------------------------------------------
