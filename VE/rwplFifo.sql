SELECT 
    pp.m_locator_id,
    pp.m_product_id,
    pp.quantity,
    pp.created
FROM adempiere.pi_productlabel pp
JOIN adempiere.m_locator ml ON ml.m_locator_id = pp.m_locator_id
JOIN adempiere.m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id
WHERE 
    pp.ad_client_id = 1000000
    AND NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales
        WHERE pp_sales.labeluuid = pp.labeluuid
        AND pp_sales.issotrx = 'Y'
    )
    AND mt.storage = 'Y'
    AND pp.m_product_id = 1001564
ORDER BY pp.created ASC

Better below one

SELECT 
    pp.m_locator_id,ml.value,
    pp.m_product_id,
    pp.quantity AS Remaining_Count,
    ino.movementdate
FROM adempiere.pi_productlabel pp
JOIN adempiere.m_locator ml ON ml.m_locator_id = pp.m_locator_id
JOIN adempiere.m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id
JOIN adempiere.M_InOutLine line ON line.M_InOutLine_id = pp.M_InOutLine_id
JOIN adempiere.M_InOut ino ON ino.M_InOut_ID = line.M_InOut_ID
WHERE 
    pp.ad_client_id = 1000000
    AND NOT EXISTS (
        SELECT 1 
        FROM adempiere.pi_productlabel pp_sales
        WHERE pp_sales.labeluuid = pp.labeluuid
        AND pp_sales.issotrx = 'Y'
    )
    AND mt.storage = 'Y' 
    AND pp.reserved = 'N' 
    AND pp.isrestricted = 'N'
    AND pp.finaldispatch = 'N'
    AND pp.issotrx = 'N'
    AND pp.m_product_id = 1001564
ORDER BY 
ino.movementdate ASC,
pp.created ASC,
pp.pi_productlabel_id ASC;


Latest Query:-

SELECT pp.m_locator_id,ml.value,
       pp.quantity AS remaining_count, 
       ino.movementdate
FROM adempiere.pi_productlabel pp
JOIN adempiere.m_locator ml ON ml.m_locator_id = pp.m_locator_id
JOIN adempiere.m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id
LEFT JOIN adempiere.M_InOutLine line ON line.M_InOutLine_id = pp.M_InOutLine_id
LEFT JOIN adempiere.M_InOut ino ON ino.M_InOut_ID = line.M_InOut_ID
WHERE pp.ad_client_id = 1000000
  AND pp.m_product_id = 1001564
  AND mt.storage = 'Y' 
  AND pp.reserved = 'N' 
  AND pp.isrestricted = 'N' 
  AND pp.finaldispatch = 'N' 
  AND pp.m_locator_id IS NOT NULL 
  AND NOT EXISTS (
      SELECT 1 
      FROM adempiere.pi_productlabel pp_sales
      WHERE pp_sales.labeluuid = pp.labeluuid 
        AND pp_sales.issotrx = 'Y'
  )
ORDER BY COALESCE(ino.movementdate, pp.created) ASC, 
         pp.created ASC, 
         pp.pi_productlabel_id ASC;

---------------------------------------------------------------------------------------------
Alter table and add new column :-

ALTER TABLE adempiere.pi_productlabel ADD COLUMN isscanned character(1) NOT NULL DEFAULT 'N'::bpchar;


@POST
@Path("labels/validate-fifo")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response validateFifo(LabelValidationRequest request);

public class FifoValidationRequest {
    private String labelUUID;

    public String getLabelUUID() {
        return labelUUID;
    }

    public void setLabelUUID(String labelUUID) {
        this.labelUUID = labelUUID;
    }
}

public class FifoValidationResponse {
    private boolean error;
    private String message;

    public boolean isError() {
        return error;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

@Override
public Response validateFifoLabel(FifoValidationRequest request) {

    FifoValidationResponse response = new FifoValidationResponse();
    String trxName = null;

    try {
        Properties ctx = Env.getCtx();
        String scannedUUID = request.getLabelUUID();

        // 🔹 Step 1: Get scanned label
        List<PO> poList = PiProductLabel.getPiProductLabel("labelUUId", scannedUUID, ctx, trxName, false);

        if (poList == null || poList.isEmpty()) {
            response.setError(true);
            response.setMessage("Invalid Label");
            return Response.ok(response).build();
        }

        PiProductLabel scannedLabel = new PiProductLabel(ctx, poList.get(0).get_ID(), trxName);

        int productId = scannedLabel.getM_Product_ID();
        int clientId = Env.getAD_Client_ID(ctx);

        // 🔹 Step 2: Get OLDEST FIFO label for this product
        String sql = "SELECT pp.labeluuid " +
                     "FROM pi_productlabel pp " +
                     "JOIN m_locator ml ON ml.m_locator_id = pp.m_locator_id " +
                     "JOIN m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id " +
                     "WHERE pp.ad_client_id = ? " +
                     "AND pp.m_product_id = ? " +
                     "AND mt.storage = 'Y' " +
                     "AND NOT EXISTS ( " +
                     "   SELECT 1 FROM pi_productlabel pp2 " +
                     "   WHERE pp2.labeluuid = pp.labeluuid " +
                     "   AND pp2.issotrx = 'Y' " +
                     ") " +
                     "ORDER BY pp.created ASC LIMIT 1";   // 🔥 FIFO

        String expectedUUID = DB.getSQLValueString(trxName, sql, clientId, productId);

        if (expectedUUID == null) {
            response.setError(true);
            response.setMessage("No available stock for FIFO validation");
            return Response.ok(response).build();
        }

        // 🔴 Step 3: Compare
        if (!scannedUUID.equals(expectedUUID)) {
            response.setError(true);
            response.setMessage("Invalid scan. Please pick older stock first (FIFO violation)");
            return Response.ok(response).build();
        }

        // ✅ Valid FIFO
        response.setError(false);
        response.setMessage("Valid FIFO label");

        return Response.ok(response).build();

    } catch (Exception e) {
        e.printStackTrace();
        response.setError(true);
        response.setMessage("Error: " + e.getMessage());
        return Response.status(Status.INTERNAL_SERVER_ERROR).entity(response).build();
    }
}

----------------------------------------------------------------------

@Override
public Response validateFifoLabel(FifoValidationRequest request) {

    FifoValidationResponse response = new FifoValidationResponse();
    String trxName = Trx.createTrxName("ScanFIFO");
    Trx trx = Trx.get(trxName, true);

    try {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);

        String scannedUUID = request.getLabelUUID();

        // ✅ FIXED variable
        PiProductLabel scannedLabel = PiProductLabel.getByUUID(ctx, scannedUUID, trxName);

        if (scannedLabel == null) {
            trx.rollback();
            return error(response, "Invalid Label");
        }

        // Already used
        if (scannedLabel.isSOTrx()) {
            trx.rollback();
            return error(response, "Label already consumed");
        }

        // Already scanned
        String isScanned = scannedLabel.get_ValueAsString("isscanned");
        if ("Y".equals(isScanned)) {
            trx.rollback();
            return error(response, "Label already scanned");
        }

        int productId = scannedLabel.getM_Product_ID();

        // 🔹 FIFO Query
        String fifoSql =
            "SELECT pp.labeluuid " +
            "FROM pi_productlabel pp " +
            "JOIN m_locator ml ON ml.m_locator_id = pp.m_locator_id " +
            "JOIN m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id " +
            "JOIN M_InOutLine line ON line.M_InOutLine_id = pp.M_InOutLine_id " +
            "JOIN M_InOut ino ON ino.M_InOut_ID = line.M_InOut_ID " +
            "WHERE pp.ad_client_id = ? " +
            "AND NOT EXISTS ( " +
            "   SELECT 1 FROM pi_productlabel pp_sales " +
            "   WHERE pp_sales.labeluuid = pp.labeluuid " +
            "   AND pp_sales.issotrx = 'Y' " +
            ") " +
            "AND mt.storage = 'Y' " +
            "AND pp.reserved = 'N' " +
            "AND pp.isrestricted = 'N' " +
            "AND pp.isscanned = 'N' " +
            "AND pp.m_product_id = ? " +
            "ORDER BY ino.movementdate ASC, pp.created ASC " +
            "LIMIT 1";

        String expectedUUID = DB.getSQLValueString(trxName, fifoSql, clientId, productId);

        if (expectedUUID == null) {
            trx.rollback();
            return error(response, "No available stock");
        }

        // FIFO validation
        if (!scannedUUID.equals(expectedUUID)) {
            trx.rollback();
            return error(response, "FIFO violation: Scan older stock first");
        }

        // ✅ Mark scanned
        scannedLabel.set_ValueOfColumn("isscanned", "Y");
        scannedLabel.saveEx(trxName);

        trx.commit();

        response.setError(false);
        response.setMessage("Valid FIFO label");

        return Response.ok(response).build();

    } catch (Exception e) {
        if (trx != null) trx.rollback();

        e.printStackTrace();
        response.setError(true);
        response.setMessage("Error: " + e.getMessage());

        return Response.status(Status.INTERNAL_SERVER_ERROR).entity(response).build();

    } finally {
        if (trx != null) trx.close();
    }
}

=========================================================================

public Response scanLabelFIFO(ScanLabelRequest request) {

    ScanLabelResponse response = new ScanLabelResponse();
    String trxName = Trx.createTrxName("ScanFIFO");
    Trx trx = Trx.get(trxName, true);

    try {
        Properties ctx = Env.getCtx();
        String labelUUID = request.getLabelUUID();

        // Step 1: Get label
        PiProductLabel label = PiProductLabel.getByUUID(ctx, labelUUID, trxName);

        if (label == null) {
            return error(response, "Invalid Label");
        }

        // Step 2: Already used
        if (label.isSOTrx()) {
            return error(response, "Label already consumed");
        }

        // Step 3: Already scanned
        String isScanned = label.get_ValueAsString("isscanned");
        if ("Y".equals(isScanned)) {
            return error(response, "Label already scanned");
        }

        int productId = label.getM_Product_ID();

        // Step 4: Get OLDEST label (FIFO)
        String sql = 
            "SELECT pp.labeluuid " +
            "FROM pi_productlabel pp " +
            "JOIN m_locator ml ON ml.m_locator_id = pp.m_locator_id " +
            "JOIN m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id " +
            "JOIN m_inoutline line ON line.m_inoutline_id = pp.m_inoutline_id " +
            "JOIN m_inout ino ON ino.m_inout_id = line.m_inout_id " +
            "WHERE pp.m_product_id=? " +
            "AND mt.storage = 'Y' AND pp.reserved = 'N' AND pp.isrestricted = 'N' " +
            "AND pp.issotrx='N' " +
            "AND pp.isscanned='N' " +
            "ORDER BY ino.movementdate ASC, pp.created ASC " +
            "LIMIT 1";

        String oldestUUID = DB.getSQLValueString(trxName, sql, productId);

        if (oldestUUID == null || !oldestUUID.equals(labelUUID)) {
            return error(response, "Not FIFO label. Scan older stock first.");
        }

        // Step 5: Mark as scanned
        label.set_ValueOfColumn("isscanned", "Y");
        label.saveEx(trxName);

        trx.commit();

        response.setError(false);
        response.setMessage("Label accepted (FIFO correct)");
        return Response.ok(response).build();

    } catch (Exception e) {
        trx.rollback();
        return error(response, e.getMessage());
    } finally {
        trx.close();
    }
}