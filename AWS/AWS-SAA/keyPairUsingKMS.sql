Key-pair using KMS:-

This topic learn 








package com.pipra.rwpl.process;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.compiere.model.I_AD_Org;
import org.compiere.model.I_AD_User;
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
                    case "Qty":
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
        // Set defaults (you can modify these IDs as needed)
        int AD_Org_ID = user.getAD_Org_ID();
        int C_BPartner_ID = user.getC_BPartner_ID(); // Default Business Partner
        int M_Warehouse_ID = 1000000; // Default Warehouse
        int C_DocType_ID = 1000014; // Default Material Receipt DocType (depends on your system)
        MWarehouse wh = new MWarehouse(getCtx(), M_Warehouse_ID, get_TrxName());

        // Create InOut (Material Receipt)
        MInOut receipt = new MInOut(getCtx(), 0, get_TrxName());
        receipt.setAD_Org_ID(AD_Org_ID);
        receipt.setC_DocType_ID(C_DocType_ID);
        receipt.setMovementDate(new Timestamp(System.currentTimeMillis()));
        receipt.setDateAcct(new Timestamp(System.currentTimeMillis()));
        receipt.setIsSOTrx(false);
        receipt.setC_BPartner_ID(C_BPartner_ID);
        receipt.setM_Warehouse_ID(M_Warehouse_ID);
        receipt.setDescription("Auto Material Receipt for PlantTag Product");
        receipt.saveEx();

        // Create Line
        MLocator locator = wh.getDefaultLocator();
        if (locator == null) {
            throw new Exception("No default locator for warehouse");
        }

        MInOutLine line = new MInOutLine(receipt);
        line.setM_Product_ID(mProductId);
        line.setQty(quantity);
        line.setM_Locator_ID(locator.get_ID());
        line.saveEx();

        return "Material Receipt Created: " + receipt.getDocumentNo();
    }
    
===========================================================================================
package com.pipra.rwpl.factory;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.compiere.model.MDocType;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutLine;
import org.compiere.model.MProduct;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.process.SvrProcess;
import org.compiere.util.Env;

import com.pipra.rwpl.model.MInOut_Custom;
import com.pipra.rwpl.model.PiProductLabel;
import com.pipra.rwpl.utils.RwplUtils;


@org.adempiere.base.annotation.Process
public class AddInwardProcess extends SvrProcess {

    private int M_Product_Category_ID = 0;
    private int M_Warehouse_ID = 0;
    private int C_BPartner_ID = 0;
    private int AD_Org_ID = 0;
    private int AD_Client_ID = 0;

    private String Description = null;

    private BigDecimal Quantity = Env.ZERO;
    private Timestamp Movement_Date;
    
    private List<Integer> productIds = new ArrayList<>();
    private List<BigDecimal> quantities = new ArrayList<>();

    @Override
    protected void prepare() {
        for (ProcessInfoParameter para : getParameter()) {
            String name = para.getParameterName();

            if ("M_Product_ID".equals(name)) {
                String value = (String) para.getParameter();
                if (value != null) {
                    for (String idStr : value.split(",")) {
                        productIds.add(Integer.parseInt(idStr.trim()));
                    }
                }
            } else if ("Quantity".equals(name)) {
                String value = (String) para.getParameter();
                if (value != null) {
                    for (String qtyStr : value.split(",")) {
                        quantities.add(new BigDecimal(qtyStr.trim()));
                    }
                }
            } else {

                switch (name) {
                case "M_Product_Category_ID":
                    M_Product_Category_ID = para.getParameterAsInt();
                    break;
                case "M_Warehouse_ID":
                    M_Warehouse_ID = para.getParameterAsInt();
                    break;
                case "C_BPartner_ID":
                    C_BPartner_ID = para.getParameterAsInt();
                    break;
                case "Description":
                    Description = para.getParameterAsString();
                    break;
                case "Movement_Date":
                    Movement_Date = para.getParameterAsTimestamp();
                    break;
                case "AD_Org_ID":
                    AD_Org_ID = para.getParameterAsInt();
                    break;
                case "AD_Client_ID":
                    AD_Client_ID = para.getParameterAsInt();
                    break;
                }
            }
        }
    }

    @Override
    protected String doIt() throws Exception {

        /**
         *
         **/


//      CreateMRRequest createMRRequest = createMRRequestDocument.getCreateMRRequest();


        Properties ctx = getCtx();
        String trxName = null;

        int mInoutId = 0;
        try {

//          MRLines[] MRLinesArray = createMRRequest.getMRLinesArray();

            MTable docTypeTable = MTable.get(ctx, "c_doctype");
            PO docTypePO = docTypeTable.getPO("name = 'MM Receipt' and ad_client_id = " + AD_Client_ID + "", trxName);
            MDocType mDocType = (MDocType) docTypePO;

            MInOut inout = null;
            int userId = Env.getAD_User_ID(ctx);

            inout = new MInOut_Custom(ctx, trxName, AD_Client_ID, AD_Org_ID, userId, C_BPartner_ID, M_Warehouse_ID, mDocType,
                    Movement_Date, Description);
            inout.saveEx();

            mInoutId = inout.getM_InOut_ID();
            int M_Locator_ID = RwplUtils.getDefaultLocatorType(ctx, trxName, AD_Client_ID);
            M_Locator_ID = 1000001;
            
            for (int i = 0; i < productIds.size(); i++) {
                int productId = productIds.get(i);
                BigDecimal qty = quantities.size() > i ? quantities.get(i) : Env.ZERO;

                MProduct product = new MProduct(ctx, productId, trxName);
                int C_UOM_ID = product.getC_UOM_ID();

                MInOutLine iol = new MInOutLine(ctx, 0, trxName);
                iol.setAD_Org_ID(AD_Org_ID);
                iol.setM_InOut_ID(mInoutId);
                iol.setM_Product_ID(productId, C_UOM_ID);
                iol.setQty(qty);
                iol.setMovementQty(qty);
                iol.setC_UOM_ID(C_UOM_ID);
                iol.setM_Warehouse_ID(M_Warehouse_ID);
                iol.setM_Locator_ID(M_Locator_ID);
                iol.saveEx();

                PiProductLabel label = new PiProductLabel(ctx, trxName, AD_Client_ID, AD_Org_ID, productId, M_Locator_ID, 0,
                        iol.get_ID(), false, qty);
                label.saveEx();

                if (label.get_ID() == 0) {
                    return "Material receipt line not created for Product ID: " + productId;
                }
            }
//              }

            Map<String, String> data = new HashMap<>();
            data.put("recordId", String.valueOf(inout.getM_InOut_ID()));
            data.put("documentNo", String.valueOf(inout.getDocumentNo()));
            data.put("path1", "/put_away_screen");
            data.put("path2", "/put_away_detail_screen");

//          RwplUtils.sendNotificationAsync(true, false, inout.get_Table_ID(), inout.getM_InOut_ID(), ctx, trxName,
//                  "New Inward: " + inout.getDocumentNo() + "",
//                  " Inward - " + inout.getDocumentNo() + " added to process", inout.get_TableName(), data, clientID,
//                  "MaterialReciptCreated");

        } catch (Exception e) {
            e.printStackTrace();
            MTable table = MTable.get(ctx, "m_inout");
            PO po = table.getPO(mInoutId, trxName);
            po.delete(true);
            return "Failed to create Material Receipt: " + e.getMessage();
        }

        return "Payment Link Sent Succesfully";
    }

}
==================================================================================================================
package com.pipra.rwpl.factory;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Properties;

import org.compiere.model.MDocType;
import org.compiere.model.MInOut;
import org.compiere.model.MInOutLine;
import org.compiere.model.MProduct;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.process.SvrProcess;
import org.compiere.util.Env;

import com.pipra.rwpl.model.I_m_inward_window_process;
import com.pipra.rwpl.model.MInOut_Custom;
import com.pipra.rwpl.model.PiProductLabel;
import com.pipra.rwpl.model.X_m_inward_window_process;

@org.adempiere.base.annotation.Process
public class AddInwardProcess extends SvrProcess {

    private int mInwardId = 0, mInoutId = 0;
//  private int M_Product_Category_ID = 0;
//  private int M_Warehouse_ID = 0;
//  private int C_BPartner_ID = 0;
//  private int AD_Org_ID = 0;
//  private int AD_Client_ID = 0;
//
//  private String Description = null;
//
//  private BigDecimal Quantity = Env.ZERO;
//  private Timestamp Movement_Date;
//  
//  private List<Integer> productIds = new ArrayList<>();
//  private List<BigDecimal> quantities = new ArrayList<>();

    @Override
    protected void prepare() {
//      for (ProcessInfoParameter para : getParameter()) {
//          String name = para.getParameterName();
//
//          if ("M_Product_ID".equals(name)) {
//              String value = (String) para.getParameter();
//              if (value != null) {
//                  for (String idStr : value.split(",")) {
//                      productIds.add(Integer.parseInt(idStr.trim()));
//                  }
//              }
//          } else if ("Quantity".equals(name)) {
//              String value = (String) para.getParameter();
//              if (value != null) {
//                  for (String qtyStr : value.split(",")) {
//                      quantities.add(new BigDecimal(qtyStr.trim()));
//                  }
//              }
//          } else {
//
//              switch (name) {
//              case "M_Product_Category_ID":
//                  M_Product_Category_ID = para.getParameterAsInt();
//                  break;
//              case "M_Warehouse_ID":
//                  M_Warehouse_ID = para.getParameterAsInt();
//                  break;
//              case "C_BPartner_ID":
//                  C_BPartner_ID = para.getParameterAsInt();
//                  break;
//              case "Description":
//                  Description = para.getParameterAsString();
//                  break;
//              case "Movement_Date":
//                  Movement_Date = para.getParameterAsTimestamp();
//                  break;
//              case "AD_Org_ID":
//                  AD_Org_ID = para.getParameterAsInt();
//                  break;
//              case "AD_Client_ID":
//                  AD_Client_ID = para.getParameterAsInt();
//                  break;
//              }
//          }
//      }
        mInwardId = getRecord_ID();
    }

    @Override
    protected String doIt() throws Exception {

//      /**
//       *
//       **/
//
//
////        CreateMRRequest createMRRequest = createMRRequestDocument.getCreateMRRequest();
//
//
//      Properties ctx = getCtx();
//      String trxName = null;
//
//      int mInoutId = 0;
//      try {
//
////            MRLines[] MRLinesArray = createMRRequest.getMRLinesArray();
//
//          MTable docTypeTable = MTable.get(ctx, "c_doctype");
//          PO docTypePO = docTypeTable.getPO("name = 'MM Receipt' and ad_client_id = " + AD_Client_ID + "", trxName);
//          MDocType mDocType = (MDocType) docTypePO;
//
//          MInOut inout = null;
//          int userId = Env.getAD_User_ID(ctx);
//
//          inout = new MInOut_Custom(ctx, trxName, AD_Client_ID, AD_Org_ID, userId, C_BPartner_ID, M_Warehouse_ID, mDocType,
//                  Movement_Date, Description);
//          inout.saveEx();
//
//          mInoutId = inout.getM_InOut_ID();
//          int M_Locator_ID = RwplUtils.getDefaultLocatorType(ctx, trxName, AD_Client_ID);
//          M_Locator_ID = 1000001;
//          
//          for (int i = 0; i < productIds.size(); i++) {
//              int productId = productIds.get(i);
//              BigDecimal qty = quantities.size() > i ? quantities.get(i) : Env.ZERO;
//
//              MProduct product = new MProduct(ctx, productId, trxName);
//              int C_UOM_ID = product.getC_UOM_ID();
//
//              MInOutLine iol = new MInOutLine(ctx, 0, trxName);
//              iol.setAD_Org_ID(AD_Org_ID);
//              iol.setM_InOut_ID(mInoutId);
//              iol.setM_Product_ID(productId, C_UOM_ID);
//              iol.setQty(qty);
//              iol.setMovementQty(qty);
//              iol.setC_UOM_ID(C_UOM_ID);
//              iol.setM_Warehouse_ID(M_Warehouse_ID);
//              iol.setM_Locator_ID(M_Locator_ID);
//              iol.saveEx();
//
//              PiProductLabel label = new PiProductLabel(ctx, trxName, AD_Client_ID, AD_Org_ID, productId, M_Locator_ID, 0,
//                      iol.get_ID(), false, qty);
//              label.saveEx();
//
//              if (label.get_ID() == 0) {
//                  return "Material receipt line not created for Product ID: " + productId;
//              }
//          }
////                }
//
//          Map<String, String> data = new HashMap<>();
//          data.put("recordId", String.valueOf(inout.getM_InOut_ID()));
//          data.put("documentNo", String.valueOf(inout.getDocumentNo()));
//          data.put("path1", "/put_away_screen");
//          data.put("path2", "/put_away_detail_screen");
//
////            RwplUtils.sendNotificationAsync(true, false, inout.get_Table_ID(), inout.getM_InOut_ID(), ctx, trxName,
////                    "New Inward: " + inout.getDocumentNo() + "",
////                    " Inward - " + inout.getDocumentNo() + " added to process", inout.get_TableName(), data, clientID,
////                    "MaterialReciptCreated");
//
//      } catch (Exception e) {
//          e.printStackTrace();
//          MTable table = MTable.get(ctx, "m_inout");
//          PO po = table.getPO(mInoutId, trxName);
//          po.delete(true);
//          return "Failed to create Material Receipt: " + e.getMessage();
//      }
//
//      return "Payment Link Sent Succesfully";
        
        Properties ctx = getCtx();
        String trxName = get_TrxName();
        
        if (mInwardId <= 0)
            return "Invalid RW_Inward_ID";
        
        I_m_inward_window_process process = new X_m_inward_window_process(ctx, mInwardId, trxName);
        
        int AD_Client_ID = process.getAD_Client_ID();
        int AD_Org_ID = process.getAD_Org_ID();
        int M_Warehouse_ID = process.getM_Warehouse_ID();
        int C_BPartner_ID = process.getC_BPartner_ID();
        int M_Locator_ID = process.getM_Locator_ID();
        String Description = process.getDescription();
        Timestamp Movement_Date = process.getMovementDate();
        
        MTable docTypeTable = MTable.get(ctx, "c_doctype");
        PO docTypePO = docTypeTable.getPO("name = 'MM Receipt' and ad_client_id = " + AD_Client_ID + "", trxName);
        MDocType mDocType = (MDocType) docTypePO;
        
        MInOut inout = null;
        int userId = Env.getAD_User_ID(ctx);
        
        try {
            
        inout = new MInOut_Custom(ctx, trxName, AD_Client_ID, AD_Org_ID, userId, C_BPartner_ID, M_Warehouse_ID, mDocType,
                Movement_Date, Description);
        inout.saveEx();
        
        mInoutId = inout.getM_InOut_ID();
        
        List<PO> lines = new Query(ctx,Inwardmodel.Table_Name,"m_inward_window_process_id=?",trxName)
                .setParameters(mInwardId).list();

        for (PO line : lines) {
            Inwardmodel model = new Inwardmodel(ctx, line.get_ID(), trxName);
            int productId = model.getM_Product_ID();
            BigDecimal qty = model.getquantity();

            MProduct product = new MProduct(ctx, productId, trxName);
            int C_UOM_ID = product.getC_UOM_ID();

            MInOutLine iol = new MInOutLine(ctx, 0, trxName);
            iol.setAD_Org_ID(AD_Org_ID);
            iol.setM_InOut_ID(mInoutId);
            iol.setM_Product_ID(productId, C_UOM_ID);
            iol.setQty(qty);
            iol.setMovementQty(qty);
            iol.setC_UOM_ID(C_UOM_ID);
            iol.setM_Warehouse_ID(M_Warehouse_ID);
            iol.setM_Locator_ID(M_Locator_ID);
            iol.saveEx();

            PiProductLabel label = new PiProductLabel(ctx, trxName, AD_Client_ID, AD_Org_ID, productId, M_Locator_ID, 0,
                    iol.get_ID(), false, qty);
            label.saveEx();

            if (label.get_ID() == 0) {
                return "Material receipt line not created for Product ID: " + productId;
            }
        }
        }catch (Exception e) {
            e.printStackTrace();
            MTable table = MTable.get(ctx, "m_inout");
            PO po = table.getPO(mInoutId, trxName);
            po.delete(true);
            return "Failed to create Material Receipt: " + e.getMessage();
        }
        return "Payment Link Sent Succesfully";
    }
    }

============================================================================================================
if (newRecord) {
            int parentLineId = get_ValueAsInt("M_InOutLine_ID");
            if (parentLineId > 0) {
                // Count existing pack lines
                String whereClause = "M_InOutLine_ID = ?";
                int count = new Query(getCtx(), get_TableName(), whereClause, get_TrxName())
                    .setParameters(parentLineId)
                    .count();

                // Set label
                set_ValueOfColumn("PackLabel", "Pack " + (count + 1));
            }
        }
        return true;


@Override
protected boolean afterDelete(boolean success) {
    if (!success) return false;

    int parentLineId = get_ValueAsInt("M_InOutLine_ID");

    List<PO> packLines = new Query(getCtx(), get_TableName(), 
        "M_InOutLine_ID = ?", get_TrxName())
        .setParameters(parentLineId)
        .setOrderBy("Created") // or any field to define the order
        .list();

    int counter = 1;
    for (PO line : packLines) {
        line.set_ValueOfColumn("PackLabel", "Pack " + counter++);
        line.saveEx(); // Save updated label
    }

    return true;
}

===========================================================
int parentLineId = get_ValueAsInt("M_InOutLine_ID");

        if (parentLineId > 0) {
            BigDecimal parentQty = DB.getSQLValueBD(
                get_TrxName(),
                "SELECT qtyentered FROM M_InOutLine WHERE M_InOutLine_ID = ?",
                parentLineId
            );

            if (parentQty == null)
                parentQty = Env.ZERO;

            BigDecimal existingQty = Env.ZERO;

            String whereClause = "M_InOutLine_ID = ?";
            List<PO> existingLines = new Query(getCtx(), get_TableName(), whereClause, get_TrxName())
                .setParameters(parentLineId)
                .list();

            for (PO line : existingLines) {
                Packlinenew pLine = new Packlinenew(p_ctx, line.get_ID(), whereClause);
                if (!newRecord && pLine.get_ID() == get_ID()) {
                    continue;
                }
                BigDecimal qty = (BigDecimal) line.get_Value("quantity");
                if (qty != null)
                    existingQty = existingQty.add(qty);
            }

            BigDecimal currentQty = (BigDecimal) get_Value("quantity");
            if (currentQty.intValue() == 0) {
                log.saveError("Error", "Entered quantity 0 not possible");
                return false;
            }
                existingQty = existingQty.add(currentQty);

            if (existingQty.compareTo(parentQty) > 0) {
                log.saveError("Error", "Entered quantity exceeds the available quantity (" + parentQty + ")");
                return false;
            }

            if (newRecord) {
                int count = existingLines.size();
                set_ValueOfColumn("label", "Pack " + (count + 1));
            }
        }

        return true;

