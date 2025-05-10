package com.pipra.rwpl.model;

import java.util.ArrayList;
import java.util.List;

import org.adempiere.util.ProcessUtil;
import org.adempiere.webui.apps.AEnv;
import org.adempiere.webui.component.Grid;
import org.adempiere.webui.component.Rows;
import org.adempiere.webui.panel.ADForm;
import org.compiere.model.GridTab;
import org.compiere.model.MProcess;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.process.ProcessInfo;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.util.CLogger;
import org.compiere.util.Env;
import org.compiere.util.Msg;
import org.compiere.util.Trx;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.Events;
import org.zkoss.zul.Button;
import org.zkoss.zul.Checkbox;
import org.zkoss.zul.Label;
import org.zkoss.zul.Messagebox;
import org.zkoss.zul.Row;
import org.zkoss.zul.Textbox;
import org.zkoss.zul.Vbox;

public class Form_Custom extends ADForm {

	private static final long serialVersionUID = 1L;
	private List<Checkbox> checkboxes = new ArrayList<>();
	private List<Integer> childIDs = new ArrayList<>();
	private List<Textbox> quantityFields = new ArrayList<>();
	private int m_parentID;
	private Button ok;
	private Button cancel;
	CLogger log = CLogger.getCLogger(Form_Custom.class);
	Trx trx = Trx.get(Trx.createTrxName(), true);

	@Override
	protected void initForm() {

		try {
			GridTab gridTab = getGridTab();
			if (gridTab != null) {
			    Object value = gridTab.getValue("M_Inward_Window_Process_ID");
			    if (value != null && value instanceof Integer) {
			    	m_parentID = (Integer) value;
			    }
			}
			
			if (m_parentID <= 0) {
                m_parentID = Env.getContextAsInt(Env.getCtx(), getWindowNo(), "Record_ID");
            }
            
            if (m_parentID <= 0) {
                Messagebox.show("No parent record selected!", "Error", Messagebox.OK, Messagebox.ERROR);
                detach();
                return;
            }

			Vbox vbox = new Vbox();
			this.appendChild(vbox);
			
			// Add title
            Label title = new Label(Msg.getMsg(Env.getCtx(), "SelectItemsToProcess"));
            vbox.appendChild(title);
            
            Grid grid = new Grid();
            grid.setWidth("100%");
            Rows rows = new Rows();
            grid.appendChild(rows);
            vbox.appendChild(grid);
            
         // Add column headers
            Row headerRow = new Row();
            headerRow.appendChild(new Label("SelectProduct"));
            headerRow.appendChild(new Label("ProductQty"));
            headerRow.appendChild(new Label("Quantity"));
            rows.appendChild(headerRow);
            

			// Get child records for the parent
			Query query = new Query(Env.getCtx(), X_m_inward_window_processline.Table_Name,
					"m_inward_window_process_ID=?", null);

			List<PO> children = query.setParameters(m_parentID).list();

			// Create checkboxes for each child
			for (PO child : children) {
				Row row = new Row(); 
				X_m_inward_window_processline line = new X_m_inward_window_processline(Env.getCtx(), child.get_ID(), trx.getTrxName());
				MProduct_Custom product = new MProduct_Custom(Env.getCtx(), line.getM_Product_ID(), trx.getTrxName());
				Checkbox cb = new Checkbox(product.getName());
				checkboxes.add(cb);
				childIDs.add(child.get_ID());
				
				Label productQty = new Label(line.getquantity().toString());
				
				 // Create quantity textbox
			    Textbox qtyTextbox = new Textbox();
			    qtyTextbox.setValue(line.getquantity().toString()); // Set initial quantity
			    qtyTextbox.setWidth("80px");
			    qtyTextbox.setConstraint("no empty, no negative");
			    
			    quantityFields.add(qtyTextbox);
			    
			    row.appendChild(cb);
			    row.appendChild(productQty);
			    row.appendChild(qtyTextbox);
			    rows.appendChild(row);
			}

			ok = new Button(Msg.getMsg(Env.getCtx(), "OK"));
			ok.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
				public void onEvent(Event event) {
					processSelection();
				}
			});

			cancel = new Button(Msg.getMsg(Env.getCtx(), "Cancel"));
			cancel.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
				public void onEvent(Event event) {
                    detach();
                }
			});

			vbox.appendChild(ok);
			vbox.appendChild(cancel);

		} catch (Exception e) {
			log.severe("error: " + e.getMessage());
			Messagebox.show("Error: " + e.getMessage(), "Error", Messagebox.OK, Messagebox.ERROR);
			detach();
		}
	}
	
	 private void processSelection() {
	        try {
	        	
	            StringBuilder selectedIDs = new StringBuilder();
	            StringBuilder quantities = new StringBuilder();
	            
	            for (int i = 0; i < checkboxes.size(); i++) {
	                if (checkboxes.get(i).isChecked()) {
	                    if (selectedIDs.length() > 0) {
	                        selectedIDs.append(",");
	                        quantities.append(",");
	                    }
	                    selectedIDs.append(childIDs.get(i));
	                    quantities.append(quantityFields.get(i).getValue());
	                }
	            }
	            
	            if (selectedIDs.length() == 0) {
	                Messagebox.show("Please select at least one item", "Warning", Messagebox.OK, Messagebox.EXCLAMATION);
	                return;
	            }

	            ProcessInfo pi = getProcessInfo();
	            pi.setClassName("com.pipra.rwpl.factory.Custom_Sales_Process");
	            pi.setRecord_ID(m_parentID);
	            pi.setParameter(new ProcessInfoParameter[] {
	                new ProcessInfoParameter("SelectedChildRecords", selectedIDs.toString(), null, null, null),
	                new ProcessInfoParameter("Quantities", quantities.toString(), null, null, null)
	            });

	            MProcess process = MProcess.get(Env.getCtx(), pi.getAD_Process_ID());
	            if (process == null || process.getAD_Process_ID() == 0) {
	                Messagebox.show("Process not found", "Error", Messagebox.OK, Messagebox.ERROR);
	                return;
	            }
	            
	            log.info("Executing Process - ID: " + process.getAD_Process_ID() + 
	                    ", Name: " + process.getName() + 
	                    ", Procedure: " + process.getProcedureName());

	           if (process.isDatabaseProcedure()) {
	               if (process.getProcedureName() == null || process.getProcedureName().trim().isEmpty()) {
	                   Messagebox.show("Process procedure is not defined", "Error", Messagebox.OK, Messagebox.ERROR);
	                   return;
	               }
	           }
	           
	           boolean success = false;
	           if (process.isDatabaseProcedure()) {
	               if (process.getProcedureName() == null || process.getProcedureName().trim().isEmpty()) {
	                   Messagebox.show("Process procedure is not defined", "Error", Messagebox.OK, Messagebox.ERROR);
	                   return;
	               }
	               
	               success = ProcessExecuter.executeProcess(process, pi);
	           } else {
	        	   success = ProcessUtil.startJavaProcess(Env.getCtx(),pi, trx,true);
	           }
	            
	            if (success) {
	            	 trx.commit();
	                Messagebox.show("Process completed successfully", "Success", Messagebox.OK, Messagebox.INFORMATION);
	            } else {
	            	trx.rollback();
	                String errorMsg = pi.getSummary() != null ? pi.getSummary() : "Unknown error occurred";
	                Messagebox.show("Process failed: " + errorMsg, "Error", Messagebox.OK, Messagebox.ERROR);
	                log.severe("Process failed: " + errorMsg);
	                System.out.println(pi.getSummary());
	            }	
	            detach();
	        } catch (Exception e) {
	        	e.printStackTrace();
	        	if (trx != null) {
	                trx.rollback();
	            }
	            log.severe("Process error: " + e.getMessage());
	            Messagebox.show("Processing failed: " + e.getMessage(), "Error", Messagebox.OK, Messagebox.ERROR);
	        }finally {
	            if (trx != null) {
	                trx.close();
	            }
	        }
	    }
}
=======================================================================================
Working:-

package com.pipra.rwpl.factory;

import java.math.BigDecimal;

import org.compiere.model.MBPartner;
import org.compiere.model.MDocType;
import org.compiere.model.MOrder;
import org.compiere.model.MOrderLine;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.process.SvrProcess;
import org.compiere.util.Env;
import org.compiere.util.Msg;
import org.compiere.util.Trx;
import com.pipra.rwpl.model.MProduct_Custom;
import com.pipra.rwpl.model.X_m_inward_window_process;
import com.pipra.rwpl.model.X_m_inward_window_processline;
import com.pipra.rwpl.model.X_pi_planitem;
import com.pipra.rwpl.model.X_pi_salesplanline;

import javassist.bytecode.stackmap.BasicBlock.Catch;

@org.adempiere.base.annotation.Process
public class SalesOrderProcess extends SvrProcess {
	private int[] m_childRecordIDs = null;
	private String[] m_quantities = null;
	private int parentID = 0;

	@Override
	protected void prepare() {
		ProcessInfoParameter[] para = getParameter();
		for (ProcessInfoParameter p : para) {
			if ("SelectedChildRecords".equals(p.getParameterName())) {
				String selectedIDs = (String) p.getParameter();
				if (selectedIDs != null && !selectedIDs.isEmpty()) {
					String[] ids = selectedIDs.split(",");
					m_childRecordIDs = new int[ids.length];
					for (int i = 0; i < ids.length; i++) {
						m_childRecordIDs[i] = Integer.parseInt(ids[i].trim());
					}
				}
			} else if ("Quantities".equals(p.getParameterName())) {
				String quantities = (String) p.getParameter();
				if (quantities != null && !quantities.isEmpty()) {
					m_quantities = quantities.split(",");
				}
			}
		}
	}

	@Override
	protected String doIt() throws Exception {
		if (m_childRecordIDs == null || m_childRecordIDs.length == 0) {
			return "No child records selected";
		}
		parentID = getRecord_ID();

		if (parentID <= 0) {
			return Msg.getMsg(Env.getCtx(), "NoParentRecord");
		}

		Trx trx = Trx.get(get_TrxName(), true);
//		if (trx == null) {
//			trx = Trx.get(Trx.createTrxName(), true);
//		}
		try {
			int clientID = Env.getAD_Client_ID(getCtx());
			int orgID = Env.getAD_Org_ID(getCtx());
			int userID = Env.getAD_User_ID(getCtx());

			MTable mDocType = MTable.get(Env.getCtx(), "c_doctype");
			PO mDocTypePo = mDocType.getPO("name = 'Standard Order' and ad_client_id = " + clientID + "",
					trx.getTrxName());
			MDocType mDocTypee = (MDocType) mDocTypePo;
			int docTypeId = mDocTypee.get_ID();

//		X_m_inward_window_process process = new X_m_inward_window_process(getCtx(), parentID, get_TrxName());
			X_pi_salesplanline process = new X_pi_salesplanline(getCtx(), parentID, trx.getTrxName());
			MBPartner busi = new MBPartner(getCtx(), process.getC_BPartner_ID(), trx.getTrxName());
			int warehouseID = process.getM_Warehouse_ID();

			MOrder order = new MOrder(Env.getCtx(), 0, trx.getTrxName());
			order.setAD_Org_ID(orgID);
			order.setC_DocTypeTarget_ID(docTypeId);
			order.setM_Warehouse_ID(warehouseID);
			order.setAD_User_ID(userID);
			order.setC_BPartner_ID(busi.getC_BPartner_ID());
			order.setIsSOTrx(true);
			order.setPaymentRule("B");

			if (order.save()) {

				for (int i = 0; i < m_childRecordIDs.length; i++) {
					try {
						BigDecimal qty = new BigDecimal(m_quantities[i]);
						if (qty.compareTo(BigDecimal.ZERO) <= 0) {
							addLog(0, null, qty, "Invalid quantity for line " + (i + 1));
							continue;
						}

//                    X_m_inward_window_processline lines = new X_m_inward_window_processline(getCtx(), m_childRecordIDs[i], trx.getTrxName());
						X_pi_planitem planItem = new X_pi_planitem(getCtx(), m_childRecordIDs[i], trx.getTrxName());
						MProduct_Custom product = new MProduct_Custom(getCtx(), planItem.getM_Product_ID(),
								trx.getTrxName());
						MOrderLine line = new MOrderLine(order);
						line.setM_Product_ID(product.getM_Product_ID());
						line.setQty(qty);
						line.saveEx();
						
						BigDecimal completedQty = planItem.getcompletedqnty().add(qty);
						 
						planItem.setcompletedqnty(completedQty);
						planItem.saveEx();

					} catch (Exception e) {
						addLog(0, null, null, "Error processing line " + (i + 1) + ": " + e.getMessage());
						log.severe("Process error: " + e.getMessage());
					}
				}
			}
			trx.commit();
			return "Sales Order #" + " Created with " + m_childRecordIDs.length;
		} catch (Exception e) {
			if (trx != null)
				trx.rollback();
			log.severe("Error in Custom_Sales_Process: " + e.getMessage());
			throw e;
		} finally {
			if (trx != null)
				trx.close();
		}
	}

}
--------------------------------------------
package com.pipra.rwpl.model;

import java.util.ArrayList;
import java.util.List;
import org.adempiere.util.ProcessUtil;
import org.adempiere.webui.component.Grid;
import org.adempiere.webui.component.Rows;
import org.adempiere.webui.panel.ADForm;
import org.compiere.model.GridTab;
import org.compiere.model.MProcess;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.process.ProcessInfo;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.util.CLogger;
import org.compiere.util.Env;
import org.compiere.util.Msg;
import org.compiere.util.Trx;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.Events;
import org.zkoss.zul.Button;
import org.zkoss.zul.Checkbox;
import org.zkoss.zul.Label;
import org.zkoss.zul.Messagebox;
import org.zkoss.zul.Row;
import org.zkoss.zul.Textbox;
import org.zkoss.zul.Vbox;

public class SalesOrderForm extends ADForm {

	private static final long serialVersionUID = 1L;
	private List<Checkbox> checkboxes = new ArrayList<>();
	private List<Integer> childIDs = new ArrayList<>();
	private List<Textbox> quantityFields = new ArrayList<>();
	private int m_parentID;
	private Button ok;
	private Button cancel;
	CLogger log = CLogger.getCLogger(SalesOrderForm.class);
	@Override
	protected void initForm() {
		try {
			GridTab gridTab = getGridTab();
			if (gridTab != null) {
//			    Object value = gridTab.getValue("M_Inward_Window_Process_ID");
				Object value = gridTab.getValue("pi_salesplanline_id");
				if (value != null && value instanceof Integer) {
					m_parentID = (Integer) value;
				}
			}

			if (m_parentID <= 0) {
				m_parentID = Env.getContextAsInt(Env.getCtx(), getWindowNo(), "Record_ID");
			}

			if (m_parentID <= 0) {
				Messagebox.show("No parent record selected!", "Error", Messagebox.OK, Messagebox.ERROR);
				detach();
				return;
			}

			Vbox vbox = new Vbox();
			this.appendChild(vbox);

			Label title = new Label(Msg.getMsg(Env.getCtx(), "SelectItemsToProcess"));
			vbox.appendChild(title);

			Grid grid = new Grid();
			grid.setWidth("100%");
			Rows rows = new Rows();
			grid.appendChild(rows);
			vbox.appendChild(grid);

			Row headerRow = new Row();
			headerRow.appendChild(new Label("SelectProduct"));
			headerRow.appendChild(new Label("ProductQty"));
			headerRow.appendChild(new Label("Quantity"));
			rows.appendChild(headerRow);

//			Query query = new Query(Env.getCtx(), X_m_inward_window_processline.Table_Name,
//					"m_inward_window_process_ID=?", null);

			Query query = new Query(Env.getCtx(), X_pi_planitem.Table_Name, "pi_salesplanline_id=? AND totalQnty != completedQnty", null);

			List<PO> children = query.setParameters(m_parentID).list();

			for (PO child : children) {
				Row row = new Row();
//				X_m_inward_window_processline line = new X_m_inward_window_processline(Env.getCtx(), child.get_ID(), trx.getTrxName());
//				MProduct_Custom product = new MProduct_Custom(Env.getCtx(), line.getM_Product_ID(), trx.getTrxName());
				X_pi_planitem planItem = new X_pi_planitem(Env.getCtx(), child.get_ID(), null);
				MProduct_Custom product = new MProduct_Custom(Env.getCtx(), planItem.getM_Product_ID(), null);
				Checkbox cb = new Checkbox(product.getName());
				checkboxes.add(cb);
				childIDs.add(child.get_ID());

//				Label productQty = new Label(line.getquantity().toString());

				Label productQty = new Label(planItem.gettotalqnty().toString());

				// Create quantity textbox
//				Textbox qtyTextbox = new Textbox();
////			    qtyTextbox.setValue(line.getquantity().toString()); // Set initial quantity
//				qtyTextbox.setValue(planItem.gettotalqnty().toString());
//				qtyTextbox.setWidth("80px");
//				qtyTextbox.setConstraint("no empty, no negative");
				
				String quantity = planItem.gettotalqnty().toString();
				Textbox qtyTextbox = new Textbox();
				qtyTextbox.setValue(quantity); // Set initial quantity
				qtyTextbox.setWidth("80px");

				// Set constraints for integer values and maximum value
//				qtyTextbox.setConstraint("no empty, no negative, no greater than 10");

				// Add a listener to ensure only integer values are accepted
				qtyTextbox.addEventListener("onChange", event -> {
				    try {
				        int value = Integer.parseInt(qtyTextbox.getValue());
				        if (value < 0 || value > planItem.gettotalqnty().intValue()) {
				            qtyTextbox.setValue(quantity); // Reset to a valid default value
				            // Optionally, display an error message
				            Messagebox.show("Please enter a value between 0 and "+ quantity +".");
				        }
				    } catch (NumberFormatException e) {
				        qtyTextbox.setValue("0"); // Reset to a valid default value
				        // Optionally, display an error message
				        Messagebox.show("Please enter a valid integer.");
				    }
				});

				quantityFields.add(qtyTextbox);

				row.appendChild(cb);
				row.appendChild(productQty);
				row.appendChild(qtyTextbox);
				rows.appendChild(row);
			}

			ok = new Button(Msg.getMsg(Env.getCtx(), "OK"));
			ok.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
				public void onEvent(Event event) {
					processSelection();
				}
			});

			cancel = new Button(Msg.getMsg(Env.getCtx(), "Cancel"));
			cancel.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
				public void onEvent(Event event) {
					detach();
				}
			});

			vbox.appendChild(ok);
			vbox.appendChild(cancel);

		} catch (Exception e) {
			log.severe("error: " + e.getMessage());
			Messagebox.show("Error: " + e.getMessage(), "Error", Messagebox.OK, Messagebox.ERROR);
			detach();
		}
	}

	private void processSelection() {
		Trx localTrx = null;
		try {
//			localTrx = Trx.get(Trx.createTrxName(), true);
			localTrx = Trx.get(Trx.createTrxName("Custom_Sales_Process"), true);
	         Env.setContext(Env.getCtx(), "#AD_TrxName", localTrx.getTrxName());

			StringBuilder selectedIDs = new StringBuilder();
			StringBuilder quantities = new StringBuilder();

			for (int i = 0; i < checkboxes.size(); i++) {
				if (checkboxes.get(i).isChecked()) {
					if (selectedIDs.length() > 0) {
						selectedIDs.append(",");
						quantities.append(",");
					}
					selectedIDs.append(childIDs.get(i));
					quantities.append(quantityFields.get(i).getValue());
				}
			}

			if (selectedIDs.length() == 0) {
				Messagebox.show("Please select at least one item", "Warning", Messagebox.OK, Messagebox.EXCLAMATION);
				return;
			}

			ProcessInfo pi = getProcessInfo();
			pi.setClassName("com.pipra.rwpl.factory.Custom_Sales_Process");
			pi.setRecord_ID(m_parentID);
//			pi.setTransactionName(localTrx.getTrxName());
			pi.setParameter(new ProcessInfoParameter[] {
					new ProcessInfoParameter("SelectedChildRecords", selectedIDs.toString(), null, null, null),
					new ProcessInfoParameter("Quantities", quantities.toString(), null, null, null) });

			MProcess process = MProcess.get(Env.getCtx(), pi.getAD_Process_ID());
			if (process == null || process.getAD_Process_ID() == 0) {
				Messagebox.show("Process not found", "Error", Messagebox.OK, Messagebox.ERROR);
				return;
			}

			log.info("Executing Process - ID: " + process.getAD_Process_ID() + ", Name: " + process.getName()
					+ ", Procedure: " + process.getProcedureName());

			if (process.isDatabaseProcedure()) {
				if (process.getProcedureName() == null || process.getProcedureName().trim().isEmpty()) {
					Messagebox.show("Process procedure is not defined", "Error", Messagebox.OK, Messagebox.ERROR);
					return;
				}
			}

			boolean success = false;
			if (process.isDatabaseProcedure()) {
				if (process.getProcedureName() == null || process.getProcedureName().trim().isEmpty()) {
					Messagebox.show("Process procedure is not defined", "Error", Messagebox.OK, Messagebox.ERROR);
					return;
				}
				success = ProcessExecuter.executeProcess(process, pi);
			} else {
				success = ProcessUtil.startJavaProcess(Env.getCtx(), pi, localTrx, true);
			}
			if (success) {
				localTrx.commit();
				Messagebox.show("Process completed successfully", "Success", Messagebox.OK, Messagebox.INFORMATION);
			} else {
				localTrx.rollback();
				String errorMsg = pi.getSummary() != null ? pi.getSummary() : "Unknown error occurred";
				Messagebox.show("Process failed: " + errorMsg, "Error", Messagebox.OK, Messagebox.ERROR);
				log.severe("Process failed: " + errorMsg);
				System.out.println(pi.getSummary());
			}
			detach();
		} catch (Exception e) {
			if (localTrx != null)
				localTrx.rollback();
			e.printStackTrace();
			log.severe("Process error: " + e.getMessage());
			Messagebox.show("Processing failed: " + e.getMessage(), "Error", Messagebox.OK, Messagebox.ERROR);
		} finally {
			if (localTrx != null)
				localTrx.close();
		}
	}
}
================================================