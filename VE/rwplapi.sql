putAway:- 
@Override
public Response putAway(PutAwayRequest request) {

    PutAwayResponse responseModel = new PutAwayResponse();
    Trx trx = null;

    try {
        Properties ctx = Env.getCtx();
        String trxName = Trx.createTrxName(getClass().getName() + "_");
        trx = Trx.get(trxName, true);
        trx.start();

        int clientId = Env.getAD_Client_ID(ctx);
        int orgId = Env.getAD_Org_ID(ctx);
        boolean finalDispatch = request.isFinalDispatch();
        List<PutAwayLineRequest> putAwayLines = request.getPutAwayLines();

        if (putAwayLines == null || putAwayLines.isEmpty()) {
            responseModel.setIsError(true);
            responseModel.setError("No putaway lines provided");
            return Response.status(Status.BAD_REQUEST).entity(responseModel).build();
        }

        /* ----------------------------------------------------
         * STEP 1: DETERMINE WAREHOUSE (ONCE)
         * ---------------------------------------------------- */
        int mWarehouseId = 0;

        for (PutAwayLineRequest line : putAwayLines) {
            String labelUUID = line.getProductLabelUUId();

            List<PO> poList = PiProductLabel.getPiProductLabel(
                    "labelUUId", labelUUID, ctx, trxName, false);

            if (poList.isEmpty()) {
                throw new AdempiereException("Product label not found: " + labelUUID);
            }

            PiProductLabel label = new PiProductLabel(ctx, poList.get(0).get_ID(), trxName);

            if (label.getM_InOutLine() == null ||
                label.getM_InOutLine().getM_Locator() == null) {
                throw new AdempiereException(
                        "Warehouse not found for label: " + labelUUID);
            }

            mWarehouseId = label.getM_InOutLine()
                                .getM_Locator()
                                .getM_Warehouse_ID();
            break;
        }

        /* ----------------------------------------------------
         * STEP 2: CREATE MOVEMENT HEADER (ONCE)
         * ---------------------------------------------------- */
        MMovement mMovement = new MMovement(ctx, 0, trxName);
        mMovement.setAD_Org_ID(orgId);
        mMovement.setM_Warehouse_ID(mWarehouseId);
        mMovement.setM_WarehouseTo_ID(mWarehouseId);
        mMovement.saveEx();

        /* ----------------------------------------------------
         * STEP 3: PROCESS PUTAWAY LINES
         * ---------------------------------------------------- */
        for (PutAwayLineRequest line : putAwayLines) {

            String labelUUID = line.getProductLabelUUId();
            int newLocatorId = line.getLocatorId();
            int splitQty = line.getNewLabelQnty();

            List<PO> poList = PiProductLabel.getPiProductLabel(
                    "labelUUId", labelUUID, ctx, trxName, false);

            PiProductLabel piProductLabel =
                    new PiProductLabel(ctx, poList.get(0).get_ID(), trxName);

            int currentLocatorId = piProductLabel.getM_Locator_ID();

            /* ---------- FULL MOVE ---------- */
            if (splitQty <= 0) {

                if (currentLocatorId != newLocatorId) {
                    moveInventory(
                            ctx, trxName, mMovement,
                            piProductLabel.getC_OrderLine_ID(),
                            piProductLabel.getquantity(),
                            piProductLabel.getM_Product_ID(),
                            currentLocatorId,
                            newLocatorId,
                            clientId,
                            orgId
                    );
                }

                if (finalDispatch) {
                    piProductLabel.setfinaldispatch(true);
                }

                piProductLabel.setM_Locator_ID(newLocatorId);
                piProductLabel.saveEx();

            } else {

                /* ---------- SPLIT LABEL ---------- */
                PiProductLabel newLabel = new PiProductLabel(
                        ctx,
                        trxName,
                        clientId,
                        orgId,
                        piProductLabel.getM_Product_ID(),
                        newLocatorId,
                        piProductLabel.getC_OrderLine_ID(),
                        piProductLabel.getM_InOutLine_ID(),
                        false,
                        BigDecimal.valueOf(splitQty),
                        null
                );

                if (finalDispatch) {
                    newLabel.setfinaldispatch(true);
                }

                newLabel.saveEx();

                BigDecimal remainingQty =
                        piProductLabel.getquantity().subtract(BigDecimal.valueOf(splitQty));

                piProductLabel.setquantity(remainingQty);
                piProductLabel.saveEx();

                moveInventory(
                        ctx, trxName, mMovement,
                        piProductLabel.getC_OrderLine_ID(),
                        BigDecimal.valueOf(splitQty),
                        piProductLabel.getM_Product_ID(),
                        currentLocatorId,
                        newLocatorId,
                        clientId,
                        orgId
                );
            }
        }

        /* ----------------------------------------------------
         * STEP 4: COMPLETE MOVEMENT (CORRECT WAY)
         * ---------------------------------------------------- */
        if (mMovement.getLines(true).length > 0) {
            if (!mMovement.processIt(DocAction.ACTION_Complete)) {
                throw new AdempiereException(mMovement.getProcessMsg());
            }
            mMovement.saveEx();
        }

        trx.commit();
        responseModel.setIsError(false);
        return Response.ok(responseModel).build();

    } catch (Exception e) {
        if (trx != null) {
            trx.rollback();
        }
        responseModel.setIsError(true);
        responseModel.setError("Error processing putaway: " + e.getMessage());
        return Response.status(Status.INTERNAL_SERVER_ERROR)
                .entity(responseModel).build();

    } finally {
        if (trx != null) {
            trx.close();
        }
    }
}
===============================================================================
3183:

String trxName = Trx.createTrxName("GetLocatorDetails");
        trx = Trx.get(trxName, false); // read-only transaction

finally {
        if (trx != null) {
            trx.close(); // <-- silences Amazon Q
        }
    }

================================================================================
2695:

if (!currentShipment.processIt(DocAction.ACTION_Complete)) {
    throw new AdempiereException(currentShipment.getProcessMsg());
}
currentShipment.saveEx();
            