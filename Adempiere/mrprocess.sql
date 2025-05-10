package com.pipra.rwpl.process;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.compiere.model.I_AD_User;
import org.compiere.model.MBPartner;
import org.compiere.model.MBPartnerLocation;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutLine;
import org.compiere.model.MLocator;
import org.compiere.model.MProduct;
import org.compiere.model.MWarehouse;
import org.compiere.model.X_AD_User;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.process.SvrProcess;
import org.compiere.util.Env;

public class CreateMaterialReceiptProcess extends SvrProcess{

	private int mProductCategoryId = 0;
	private int mProductId = 0;
	private BigDecimal quantity = Env.ZERO;
//	com.pipra.rwpl.process.CreateMaterialReceiptProcess
	@Override
	protected void prepare() {
			for (ProcessInfoParameter param : getParameter()) {
				if (param.getParameter() == null) continue;

				String name = param.getParameterName();
				switch (name) {
					case "M_Product_Category_ID":
						mProductCategoryId = param.getParameterAsInt();
						break;
					case "M_Product_ID":
						mProductId = param.getParameterAsInt();
						break;
					case "quantity":
						quantity = (BigDecimal) param.getParameter();
						break;
					default:
						log.warning("Unknown Parameter: " + name);
				}
			}
	}
	@Override
	protected String doIt() throws Exception {
		if (mProductId <= 0 || quantity.compareTo(Env.ZERO) <= 0) {
			throw new IllegalArgumentException("Invalid product or quantity");
		}

		// Load product
		MProduct product = new MProduct(getCtx(), mProductId, get_TrxName());
		if (product == null || product.get_ID() == 0) {
			throw new Exception("Product not found");
		}

		I_AD_User user = new X_AD_User(getCtx(), getAD_User_ID(), get_TrxName());
		
		int AD_Org_ID = user.getAD_Org_ID();
		int C_BPartner_ID = user.getC_BPartner_ID(); 
		int M_Warehouse_ID = 1000000; 
		int C_DocType_ID = 1000014; 
		MWarehouse wh = new MWarehouse(getCtx(), M_Warehouse_ID, get_TrxName());
		
		MBPartner bp = new MBPartner(getCtx(), C_BPartner_ID, get_TrxName());
        MBPartnerLocation[] locations = bp.getLocations(false);
        if (locations == null || locations.length == 0) {
            throw new Exception("No locations found for Business Partner ID: " + C_BPartner_ID);
        }
        int C_BPartner_Location_ID = locations[0].getC_BPartner_Location_ID();

		MInOut receipt = new MInOut(getCtx(), 0, get_TrxName());
		receipt.setAD_Org_ID(AD_Org_ID);
		receipt.setC_DocType_ID(C_DocType_ID);
		receipt.setMovementDate(new Timestamp(System.currentTimeMillis()));
		receipt.setDateAcct(new Timestamp(System.currentTimeMillis()));
		receipt.setIsSOTrx(false);
		receipt.setC_BPartner_ID(C_BPartner_ID);
		receipt.setC_BPartner_Location_ID(C_BPartner_Location_ID);
		receipt.setM_Warehouse_ID(M_Warehouse_ID);
		receipt.setDescription("Material Receipt created through process");
		receipt.saveEx();

		MLocator locator = wh.getDefaultLocator();
		if (locator == null) {
			throw new Exception("No default locator for warehouse");
		}

		MInOutLine line = new MInOutLine(receipt);
		line.setM_Product_ID(mProductId);
		line.setQty(quantity);
		line.setM_Locator_ID(locator.get_ID());
		line.saveEx();

		return "Material Receipt Created Successfully: " + receipt.getDocumentNo();
	}
	
}


==================================================================
package com.pipra.rwpl.process;

import org.adempiere.base.IProcessFactory;
import org.compiere.process.ProcessCall;


public class MRFactory implements IProcessFactory{

	@Override
	public ProcessCall newProcessInstance(String className) {
		if (className.equalsIgnoreCase("com.pipra.rwpl.process.CreateMaterialReceiptProcess")) {
			return new CreateMaterialReceiptProcess();
		}
		return null;
	}

}
