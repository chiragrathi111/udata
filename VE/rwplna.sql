
package org.pipra.webservices.model;

import java.util.List;

public class GenerateAndCompleteRequest {
    
    private int mInoutId;
    private String docAction;  // Usually "CO" for Complete
    private List<ProductLabelLine> productLabelLines;
    
    // Getters and Setters
    public int getmInoutId() {
        return mInoutId;
    }
    
    public void setmInoutId(int mInoutId) {
        this.mInoutId = mInoutId;
    }
    
    public String getDocAction() {
        return docAction;
    }
    
    public void setDocAction(String docAction) {
        this.docAction = docAction;
    }
    
    public List<ProductLabelLine> getProductLabelLines() {
        return productLabelLines;
    }
    
    public void setProductLabelLines(List<ProductLabelLine> productLabelLines) {
        this.productLabelLines = productLabelLines;
    }
}

-------------------------------------------------------------------------------------------------------
2. Response Model

package org.pipra.webservices.model;

import java.util.List;

public class GenerateAndCompleteResponse {
    
    private boolean error;
    private String errorMessage;
    private int recordId;
    private String docStatus;
    private List<ProductLabelLine> productLabelLines;
    
    // Getters and Setters
    public boolean isError() {
        return error;
    }
    
    public void setError(boolean error) {
        this.error = error;
    }
    
    public String getErrorMessage() {
        return errorMessage;
    }
    
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    public int getRecordId() {
        return recordId;
    }
    
    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }
    
    public String getDocStatus() {
        return docStatus;
    }
    
    public void setDocStatus(String docStatus) {
        this.docStatus = docStatus;
    }
    
    public List<ProductLabelLine> getProductLabelLines() {
        return productLabelLines;
    }
    
    public void setProductLabelLines(List<ProductLabelLine> productLabelLines) {
        this.productLabelLines = productLabelLines;
    }
}

-------------------------------------------------------------------------
3. New Combined API Method

/**
 * ✅ NEW API: Generate Sales Labels AND Complete Document in ONE transaction
 * This prevents data leak if network fails between two separate API calls
 */
@Override
public Response generateSalesLabelsAndComplete(GenerateAndCompleteRequest request) {
    
    GenerateAndCompleteResponse response = new GenerateAndCompleteResponse();
    Trx trx = null;

    try {
        Properties ctx = Env.getCtx();
        String trxName = Trx.createTrxName(getClass().getName() + "_generateAndComplete");
        trx = Trx.get(trxName, true);
        trx.start();

        int mInoutId = request.getmInoutId();
        String docAction = request.getDocAction();
        List<ProductLabelLine> productLabelLines = request.getProductLabelLines();

        // ========================================
        // STEP 1: Validate Request
        // ========================================
        if (mInoutId <= 0) {
            response.setError(true);
            response.setErrorMessage("Invalid M_InOut_ID");
            return Response.status(Status.BAD_REQUEST).entity(response).build();
        }

        if (productLabelLines == null || productLabelLines.isEmpty()) {
            response.setError(true);
            response.setErrorMessage("Product label lines are required");
            return Response.status(Status.BAD_REQUEST).entity(response).build();
        }

        if (docAction == null || docAction.isEmpty()) {
            docAction = "CO"; // Default to Complete
        }

        // ========================================
        // STEP 2: Validate Shipment Exists
        // ========================================
        MInOut_Custom inOut = new MInOut_Custom(ctx, mInoutId, trxName);
        if (inOut.get_ID() <= 0) {
            response.setError(true);
            response.setErrorMessage("Shipment not found with ID: " + mInoutId);
            return Response.status(Status.NOT_FOUND).entity(response).build();
        }

        // ========================================
        // STEP 3: Validate Quantities Match
        // ========================================
        int scannedQty = productLabelLines.stream()
                .mapToInt(ProductLabelLine::getQuantity)
                .sum();
        
        int orderQty = 0;
        MInOutLine[] inoutLines = inOut.getLines();
        
        for (MInOutLine inoutLine : inoutLines) {
            orderQty += inoutLine.getQtyEntered().intValue();
        }

        if (orderQty != scannedQty) {
            response.setError(true);
            response.setErrorMessage(
                "Scanned quantity (" + scannedQty + ") does not match " +
                "shipment quantity (" + orderQty + ")"
            );
            return Response.status(Status.BAD_REQUEST).entity(response).build();
        }

        // ========================================
        // STEP 4: Generate Sales Labels
        // ========================================
        System.out.println("=== Generating " + productLabelLines.size() + " sales labels ===");
        
        for (ProductLabelLine line : productLabelLines) {
            try {
                createSalesLabel(line, ctx, trxName, mInoutId);
                
                System.out.println("✅ Label created for product: " + line.getProductId() + 
                                 ", Qty: " + line.getQuantity());
                
            } catch (Exception e) {
                System.err.println("❌ Failed to create label for product: " + line.getProductId());
                throw new Exception("Failed to create sales label for product " + 
                                  line.getProductId() + ": " + e.getMessage(), e);
            }
        }

        // ========================================
        // STEP 5: Complete Document (Doc Action)
        // ========================================
        System.out.println("=== Processing Doc Action: " + docAction + " ===");
        
        try {
            // Set DocAction to avoid automatic process
            inOut.set_ValueOfColumn("DocAction", docAction);
            
            if (!inOut.save(trxName)) {
                throw new Exception("Failed to save before doc action");
            }

            // Process the document
            if (!((DocAction) inOut).processIt(docAction)) {
                String errorMsg = inOut.getProcessMsg();
                throw new Exception("Doc action failed: " + 
                                  (errorMsg != null ? errorMsg : "Unknown error"));
            }

            // Save after processing
            if (!inOut.save(trxName)) {
                throw new Exception("Failed to save after doc action");
            }

            System.out.println("✅ Doc action completed successfully");

        } catch (Exception e) {
            System.err.println("❌ Doc action failed: " + e.getMessage());
            throw new Exception("Failed to complete document: " + e.getMessage(), e);
        }

        // ========================================
        // STEP 6: Commit Transaction
        // ========================================
        trx.commit();
        
        System.out.println("=== ✅ Transaction committed successfully ===");

        // ========================================
        // STEP 7: Build Success Response
        // ========================================
        response.setError(false);
        response.setRecordId(mInoutId);
        response.setDocStatus(inOut.getDocStatus());
        response.setProductLabelLines(productLabelLines);
        
        return Response.ok(response).build();

    } catch (Exception e) {
        // ========================================
        // ERROR HANDLING: Rollback Everything
        // ========================================
        System.err.println("❌ ERROR: Rolling back transaction");
        e.printStackTrace();
        
        if (trx != null) {
            trx.rollback();
        }

        response.setError(true);
        response.setErrorMessage("Transaction failed: " + e.getMessage());
        
        return Response.status(Status.INTERNAL_SERVER_ERROR).entity(response).build();

    } finally {
        // ========================================
        // CLEANUP: Always Close Transaction
        // ========================================
        if (trx != null) {
            trx.close();
        }
    }
}

/**
 * ✅ REUSE: Same createSalesLabel method (no changes needed)
 */
private void createSalesLabel(ProductLabelLine line, Properties ctx, String trxName, int mInoutId) {

    MInOut_Custom inOut = new MInOut_Custom(ctx, mInoutId, trxName);
    MInOutLine[] inoutLines = inOut.getLines();
    PiProductLabel piProductLabel = new PiProductLabel(ctx, 0, trxName);

    piProductLabel.setQcpassed(true);

    if (line.getProductId() != 0) {
        piProductLabel.setquantity(BigDecimal.valueOf(line.getQuantity()));
        piProductLabel.setM_Product_ID(line.getProductId());

        for (MInOutLine inoutLine : inoutLines) {
            if (inoutLine.getM_Product_ID() == line.getProductId()) {
                piProductLabel.setM_InOutLine_ID(inoutLine.get_ID());
                piProductLabel.setC_OrderLine_ID(inoutLine.getC_OrderLine_ID());
                break;
            }
        }
    }

    piProductLabel.setM_Locator_ID(line.getLocatorId());
    piProductLabel.setIsSOTrx(true);
    
    List<PO> poList = PiProductLabel.getPiProductLabel("labelUUId", 
            line.getProductLabelUUId(), ctx, trxName, false);
    
    if (!poList.isEmpty()) {
        PiProductLabel originalLabel = new PiProductLabel(ctx, poList.get(0).get_ID(), trxName);
        int previousLocator = 0;
        
        if (originalLabel.getM_Locator_ID() != 0) {
            MLocator locator = new MLocator(ctx, originalLabel.getM_Locator_ID(), trxName);
            MLocatorType_Custom locatorType_Custom = new MLocatorType_Custom(ctx, 
                    locator.getM_LocatorType_ID(), trxName);
            
            if (!locatorType_Custom.isdispatch()) {
                previousLocator = originalLabel.getM_Locator_ID();
            } else {
                MLocator pl = new MLocator(ctx, originalLabel.getPreviouslocator(), trxName);
                MLocatorType_Custom plt = new MLocatorType_Custom(ctx, 
                        pl.getM_LocatorType_ID(), trxName);
                if (!plt.isdispatch()) {
                    previousLocator = pl.getM_Locator_ID();
                }
            }
        }

        if (previousLocator != 0) {
            piProductLabel.setPreviouslocator(previousLocator);
        }
    }
    
    piProductLabel.setlabeluuid(line.getProductLabelUUId());
    piProductLabel.setIsActive(true);
    piProductLabel.saveEx(trxName);
}

====================================================================================================
* POSTMAN:-
{
  "mInoutId": 1000123,
  "docAction": "CO",
  "productLabelLines": [
    {
      "productId": 5001,
      "quantity": 10,
      "locatorId": 2001,
      "productLabelUUId": "uuid-abc-123",
      "salesTransaction": true
    },
    {
      "productId": 5002,
      "quantity": 5,
      "locatorId": 2001,
      "productLabelUUId": "uuid-def-456",
      "salesTransaction": true
    }
  ]
}
