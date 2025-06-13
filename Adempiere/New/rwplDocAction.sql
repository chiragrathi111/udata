@Override
	public String completeIt() {
		MInOutLine[] lines = getLines();
		for (MInOutLine line : lines) {
			int clientId = line.getAD_Client_ID();
			int OrgId = line.getAD_Org_ID();
			int productId = line.getM_Product_ID();
			int locatorId = line.getM_Locator_ID();
			BigDecimal Quantity = line.getQtyEntered();
			BigDecimal remainingQty = Quantity;


			String whereClause = "M_InOutLine_ID = ?";
			List<PO> packLines = new Query(getCtx(), Packline.Table_Name, whereClause, get_TrxName())
					.setParameters(line.get_ID()).list();

			if (packLines.isEmpty()) {
				Packline newPackLine = new Packline(getCtx(), 0, get_TrxName());
				newPackLine.setAD_Org_ID(OrgId);
				newPackLine.setM_InOutLine_ID(line.get_ID());
				newPackLine.setlabel("Pack 1");
				newPackLine.setquantity(Quantity);
				newPackLine.saveEx();

				PiProductLabel label = new PiProductLabel(getCtx(), get_TrxName(), clientId, OrgId, productId,
						locatorId, 0, line.get_ID(), false, Quantity, null);
				label.saveEx();

				if (label.get_ID() == 0) {
					return "Material receipt line not created for Product ID: " + productId;
				}
			}
			else {
				BigDecimal allocatedQty = BigDecimal.ZERO;
		        int maxPackNumber = 0;
		        
		        for (PO pack : packLines) {
		            BigDecimal packQty = (BigDecimal)pack.get_Value("Quantity");
		            allocatedQty = allocatedQty.add(packQty);
		            
		            String label = (String)pack.get_Value("Label");
		            if (label != null && label.startsWith("Pack ")) {
		                try {
		                    int num = Integer.parseInt(label.substring(5).trim());
		                    if (num > maxPackNumber) {
		                        maxPackNumber = num;
		                    }
		                } catch (NumberFormatException e) {
		                    System.out.println("");
		                }
		            }
		        }
		        remainingQty = Quantity.subtract(allocatedQty);
		        
		        if (remainingQty.compareTo(BigDecimal.ZERO) > 0) {
		            PO newPackLine = new Packline(getCtx(), 0, get_TrxName());
		            newPackLine.set_ValueOfColumn("AD_Org_ID", OrgId);
		            newPackLine.set_ValueOfColumn("M_InOutLine_ID", line.get_ID());
		            newPackLine.set_ValueOfColumn("Label", "Pack " + (maxPackNumber + 1));
		            newPackLine.set_ValueOfColumn("Quantity", remainingQty);
		            newPackLine.saveEx();
		            
		            PiProductLabel label = new PiProductLabel(getCtx(), get_TrxName(), clientId, OrgId, productId,
							locatorId, 0, line.get_ID(), false, remainingQty, null);
					label.saveEx();
		            
		            if (label.get_ID() == 0) {
		                return "Material receipt line not created for Product ID: " + productId;
		            }
		        }
			}

			for (PO pack : packLines) {
				Packline lineNew = new Packline(p_ctx, pack.get_ID(), get_TrxName());

				PiProductLabel label = new PiProductLabel(getCtx(), get_TrxName(), clientId, OrgId, productId,
						locatorId, 0, line.get_ID(), false, lineNew.getquantity(), null);
				label.saveEx();

				if (label.get_ID() == 0) {
					return "Material receipt line not created for Product ID: " + productId;
				}
			}
		}