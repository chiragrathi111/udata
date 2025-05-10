protected String doIt() throws Exception {
    List<MOrder> purchaseOrders = new ArrayList<>();
    try {
        // Retrieve the list of products for which you want to check the quantity
        List<Integer> productIDs = getProductIDs();

        for (int productID : productIDs) {
            // Perform the quantity check for each product
            int productQty = getProductQuantity(productID);

            if (productQty < miniumQty) {
                // Create a purchase order for products with quantity below the minimum
                MOrder mOrder = createPOOrder(productID);
                purchaseOrders.add(mOrder);
            }
        }
    } catch (Exception e) {
        log.info("Error: " + e.getMessage());
    }

    if (!purchaseOrders.isEmpty()) {
        // Return success message with details of created purchase orders
        return "Purchase orders created successfully: " + purchaseOrders.toString();
    } else {
        // Return message indicating that all products have enough quantity
        return "All products have enough quantity";
    }
}

private List<Integer> getProductIDs() {
    // TODO: Retrieve the list of product IDs from your data source
    // Example: return Arrays.asList(1000028, 1000030, 1000032);
    return Collections.emptyList();
}

private int getProductQuantity(int productID) {
    int quantity = 0;
    try {
        String query = "SELECT SUM(qtyonhand) AS quantity FROM adempiere.M_StorageOnHand WHERE M_Product_ID = ?";
        PreparedStatement pstmt = DB.prepareStatement(query, null);
        pstmt.setInt(1, productID);
        ResultSet RS = pstmt.executeQuery();
        if (RS.next()) {
            quantity = RS.getInt("quantity");
        }
    } catch (SQLException e) {
        log.info("Error: " + e.getMessage());
    }
    return quantity;
}

private MOrder createPOOrder(int productID) throws Exception {
    // TODO: Implement the creation of purchase order for a specific product
    // using the provided productID and other necessary information
    return null;
}


private MOrder createPOOrder() throws Exception {
    MOrder po = new MOrder(getCtx(), 0, null);
    po.setC_DocTypeTarget_ID();
    
    // Set the organization ID, warehouse ID, and business partner ID
    po.setAD_Org_ID(p_Org_ID);
    po.setM_Warehouse_ID(p_Warehouse_ID);
    po.setC_BPartner_ID(p_Vendor_ID);
    
    po.setIsSOTrx(false);  // Set IsSOTrx to false for purchase orders
    
    // Rest of the code...
}

// Retrieve the default organization ID
int defaultOrgID = Env.getAD_Org_ID(getCtx());

// Retrieve the default warehouse ID
int defaultWarehouseID = Env.getContextAsInt(getCtx(), "#M_Warehouse_ID");