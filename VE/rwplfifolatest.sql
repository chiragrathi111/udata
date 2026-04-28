Request :-

public class FifoValidationRequest {

    // UUID of scanned label (barcode value)
    private String labelUUID;

    // Required quantity for this product (from Sales Order line)
    private int requiredQty;

    // (Optional but recommended) Order ID for future tracking
    private int orderId;

    // Getters & Setters
    public String getLabelUUID() {
        return labelUUID;
    }

    public void setLabelUUID(String labelUUID) {
        this.labelUUID = labelUUID;
    }

    public int getRequiredQty() {
        return requiredQty;
    }

    public void setRequiredQty(int requiredQty) {
        this.requiredQty = requiredQty;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
}

Response:-

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

api:-

@Override
public Response validateFifoLabel(FifoValidationRequest request) {

    FifoValidationResponse response = new FifoValidationResponse();

    String trxName = Trx.createTrxName("FIFO_VALIDATE");
    Trx trx = Trx.get(trxName, true);

    try {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);

        String scannedUUID = request.getLabelUUID();
        int requiredQty = request.getRequiredQty();

        // ---------------------------------------------------
        // 1. GET SCANNED LABEL
        // ---------------------------------------------------
        PiProductLabel scannedLabel = PiProductLabel.getByUUID(ctx, scannedUUID, trxName);

        if (scannedLabel == null) {
            return error(response, trx, "Invalid Label");
        }

        // Already used in sales
        if (scannedLabel.isSOTrx()) {
            return error(response, trx, "Label already consumed");
        }

        // Already scanned in current picking
        if ("Y".equals(scannedLabel.get_ValueAsString("isscanned"))) {
            return error(response, trx, "Label already scanned");
        }

        int productId = scannedLabel.getM_Product_ID();

        // ---------------------------------------------------
        // 2. FETCH FIFO LABELS (ORDERED BY OLDEST FIRST)
        // ---------------------------------------------------
        String fifoSql =
            "SELECT pp.labeluuid, pp.quantity, ino.movementdate " +
            "FROM pi_productlabel pp " +
            "JOIN m_locator ml ON ml.m_locator_id = pp.m_locator_id " +
            "JOIN m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id " +
            "JOIN M_InOutLine line ON line.M_InOutLine_id = pp.M_InOutLine_id " +
            "JOIN M_InOut ino ON ino.M_InOut_ID = line.M_InOut_ID " +
            "WHERE pp.ad_client_id = ? " +
            "AND NOT EXISTS ( " +
            "   SELECT 1 FROM pi_productlabel x " +
            "   WHERE x.labeluuid = pp.labeluuid AND x.issotrx = 'Y' " +
            ") " +
            "AND mt.storage = 'Y' " +
            "AND pp.reserved = 'N' " +
            "AND pp.isrestricted = 'N' " +
            "AND pp.isscanned = 'N' " +
            "AND pp.m_product_id = ? " +
            "ORDER BY ino.movementdate ASC, pp.created ASC";

        PreparedStatement ps = DB.prepareStatement(fifoSql, trxName);
        ps.setInt(1, clientId);
        ps.setInt(2, productId);

        ResultSet rs = ps.executeQuery();

        // ---------------------------------------------------
        // 3. BUILD FIFO ALLOWED LIST (CORE LOGIC)
        // ---------------------------------------------------
        List<String> allowedUUIDs = new ArrayList<>();
        int remainingQty = requiredQty;

        while (rs.next()) {

            String uuid = rs.getString("labeluuid");
            int qty = rs.getInt("quantity");

            // Stop when required qty fulfilled
            if (remainingQty <= 0) {
                break;
            }

            // Add to allowed FIFO list
            allowedUUIDs.add(uuid);

            // Reduce remaining quantity
            remainingQty -= qty;
        }

        DB.close(rs, ps);

        // ---------------------------------------------------
        // 4. VALIDATE SCANNED LABEL
        // ---------------------------------------------------
        if (!allowedUUIDs.contains(scannedUUID)) {
            return error(response, trx, "FIFO violation: Scan older stock first");
        }

        // ---------------------------------------------------
        // 5. MARK LABEL AS SCANNED
        // ---------------------------------------------------
        scannedLabel.set_ValueOfColumn("isscanned", "Y");
        scannedLabel.saveEx(trxName);

        trx.commit();

        // ---------------------------------------------------
        // 6. SUCCESS RESPONSE
        // ---------------------------------------------------
        response.setError(false);
        response.setMessage("Valid FIFO label");

        return Response.ok(response).build();

    } catch (Exception e) {

        if (trx != null) trx.rollback();

        e.printStackTrace();

        response.setError(true);
        response.setMessage("Error: " + e.getMessage());

        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response).build();

    } finally {
        if (trx != null) trx.close();
    }
}

=======================================================================

private void getSuggestedLocatorForProduct(SODetailProductData productData, Properties ctx, String trxName,
        int warehouseId, int clientId) {

    List<SODetailLocator> suggestedLocators = productData.getQntyAvailableInLocator() != null
            ? productData.getQntyAvailableInLocator()
            : new ArrayList<>();

    productData.setQntyAvailableInLocator(suggestedLocators);

    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        int productId = productData.getProductId();
        int quantityRemaining = productData.getRemainingQuantityToPick();

        String sql =
                "SELECT " +
                " pp.m_locator_id, " +
                " pp.quantity AS remaining_count, " +
                " ino.movementdate " +
                "FROM adempiere.pi_productlabel pp " +
                "JOIN adempiere.m_locator ml ON ml.m_locator_id = pp.m_locator_id " +
                "JOIN adempiere.m_locatortype mt ON mt.m_locatortype_id = ml.m_locatortype_id " +
                "LEFT JOIN adempiere.M_InOutLine line ON line.M_InOutLine_id = pp.M_InOutLine_id " +
                "LEFT JOIN adempiere.M_InOut ino ON ino.M_InOut_ID = line.M_InOut_ID " +
                "WHERE pp.ad_client_id = ? " +
                "AND pp.m_product_id = ? " +
                "AND mt.storage = 'Y' " +
                "AND pp.issotrx = 'N' " +
                "AND pp.reserved = 'N' " +
                "AND pp.isrestricted = 'N' " +
                "AND pp.finaldispatch = 'N' " +
                "AND pp.m_locator_id IS NOT NULL " +
                "AND NOT EXISTS ( " +
                "   SELECT 1 FROM adempiere.pi_productlabel pp_sales " +
                "   WHERE pp_sales.labeluuid = pp.labeluuid " +
                "   AND pp_sales.issotrx = 'Y' " +
                ") " +
                "ORDER BY ino.movementdate ASC NULLS LAST, pp.created ASC, pp.pi_productlabel_id ASC";

        pstm = DB.prepareStatement(sql, trxName);
        pstm.setInt(1, clientId);
        pstm.setInt(2, productId);

        rs = pstm.executeQuery();

        while (rs.next()) {

            if (quantityRemaining <= 0)
                break;

            int locatorId = rs.getInt("m_locator_id");
            int qty = rs.getInt("remaining_count");

            // Safety checks
            if (locatorId <= 0 || qty <= 0)
                continue;

            MLocator locator = new MLocator(ctx, locatorId, trxName);
            MLocatorType_Custom type = new MLocatorType_Custom(ctx, locator.getM_LocatorType_ID(), trxName);

            // Skip unwanted locator types
            if (type.isdispatch() || type.isPacking() || type.isReturns())
                continue;

            int pickQty = Math.min(qty, quantityRemaining);

            // Check if locator already exists in list → merge
            SODetailLocator existing = null;
            for (SODetailLocator line : suggestedLocators) {
                if (line.getLocatorId() == locatorId) {
                    existing = line;
                    break;
                }
            }

            if (existing != null) {
                existing.setQuantityAvailable(existing.getQuantityAvailable() + pickQty);
            } else {
                SODetailLocator newLine = new SODetailLocator();
                newLine.setLocatorId(locatorId);
                newLine.setLocatorName(locator.getValue());
                newLine.setQuantityAvailable(pickQty);
                suggestedLocators.add(newLine);
            }

            quantityRemaining -= pickQty;
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DB.close(rs, pstm);
    }
}