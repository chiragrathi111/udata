package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Properties;

//import org.adempiere.webui.component.Button;
import org.adempiere.webui.component.Combobox;
//import org.adempiere.webui.desktop.IDesktop;
import org.adempiere.webui.theme.ITheme;
import org.adempiere.webui.util.ZKUpdateUtil;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.Events;
import org.zkoss.zul.Box;
import org.zkoss.zul.Div;
import org.zkoss.zul.Vbox;

public class DPWarehouseSelection extends DashboardPanel implements EventListener<Event> {

	private Combobox comboboxWarehouseNames;
	private String warehouseDefaultName = "HQ Warehouse";
	public Combobox comboboxProductsData;

	private static final long serialVersionUID = 1L;
	public LinkedHashMap<String, Integer> warehouseNames = new LinkedHashMap<>();
	public LinkedHashMap<String, Integer> productNames = new LinkedHashMap<>();//

	public static List<DashboardPanel> dashboardPanels = new ArrayList<DashboardPanel>();

	public DPWarehouseSelection() {
		super();
		this.setSclass("activities-box");
		initOptions();
		this.appendChild(createActivitiesPanel());
	}

	private Box createActivitiesPanel() {
		Vbox vbox = new Vbox();
		vbox.setSclass(ITheme.WARE_HOUSE_SELECT_WIDGET);

		Div div = new Div();
		div.setSclass(ITheme.WARE_HOUSE_SELECT_WIDGET_CONT);
		vbox.appendChild(div);

		comboboxProductsData = new Combobox();
		div.appendChild(comboboxProductsData);
		comboboxProductsData.setAutocomplete(true);
		comboboxProductsData.setSclass(ITheme.PRODUCT_SELECTION);//
		comboboxProductsData.setAutodrop(true);
		comboboxProductsData.setPlaceholder("Select Product");
		comboboxProductsData.setId("comboboxProductsData");
		comboboxProductsData.addEventListener(Events.ON_SELECT, this);
		ZKUpdateUtil.setWidth(comboboxProductsData, "25%");

		Collection<String> wNames = warehouseNames.keySet();
		Collection<String> pNames = productNames.keySet();//
		for (String langName : pNames) {
			comboboxProductsData.appendItem(langName);
		}

		comboboxWarehouseNames = new Combobox();
		div.appendChild(comboboxWarehouseNames);
		comboboxWarehouseNames.setAutocomplete(true);

		comboboxWarehouseNames.setAutodrop(true);
		comboboxWarehouseNames.setPlaceholder("Select Ware House");
		comboboxWarehouseNames.setId("comboboxWarehouseNames");
		comboboxWarehouseNames.addEventListener(Events.ON_SELECT, this);
		ZKUpdateUtil.setWidth(comboboxWarehouseNames, "25%");

		for (String langName : wNames) {
			comboboxWarehouseNames.appendItem(langName);
		}
		return vbox;
	}

	private void initOptions() {

		Properties ctx = Env.getCtx();
		int clientId = Env.getAD_Client_ID(ctx);
		int RoleId = Env.getAD_Role_ID(ctx);

		String wareHouseCountSql = "SELECT mw.name, mw.m_warehouse_id FROM adempiere.m_warehouse mw \n"
				+ "join adempiere.ad_role ar on ar.ad_client_id = mw.ad_client_id \n"
				+ "join adempiere.ad_role_orgaccess aro on aro.ad_role_id = ar.ad_role_id \n"
				+ "and aro.ad_client_id= ar.ad_client_id and aro.ad_org_id= mw.ad_org_id \n" + "where ar.ad_client_id="
				+ clientId + " and aro.ad_role_id=" + RoleId + ";";
		
		
		String productSql = "SELECT name,m_product_id FROM adempiere.m_product\n"
				+ "WHERE ad_client_id = "+ clientId +" ";
		
		
		PreparedStatement pstmtp = null;
		ResultSet RSP = null;
		try {
			
			pstmtp = DB.prepareStatement(productSql.toString(),null);
			RSP = pstmtp.executeQuery();
			while(RSP.next()) {
				String name = RSP.getString("name");
				int m_product_id = RSP.getInt("m_product_id");
				if(name != null && !productNames.containsValue(name))
					productNames.put(name, m_product_id);
			}
			DB.close(RSP,pstmtp);
			RSP = null;
			pstmtp = null;
			
		}catch(SQLException e) {
			e.printStackTrace();
		}

		PreparedStatement pstmt = null;
		ResultSet RS = null;
		try {

			pstmt = DB.prepareStatement(wareHouseCountSql.toString(), null);
			RS = pstmt.executeQuery();
			while (RS.next()) {
				String name = RS.getString("name");
				int m_warehouse_id = RS.getInt("m_warehouse_id");
				if (name != null && !warehouseNames.containsValue(name))
					warehouseNames.put(name, m_warehouse_id);
			}
			DB.close(RS, pstmt);
			RS = null;
			pstmt = null;

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void onEvent(Event event) throws Exception {
		warehouseDefaultName = comboboxWarehouseNames.getSelectedItem().getLabel();
		int m_warehouse_id = warehouseNames.get(warehouseDefaultName);
		Env.setContext(Env.getCtx(), Env.M_WAREHOUSE_ID, m_warehouse_id);
		Properties ctx = Env.getCtx();
		int w = Env.getWareHouse_ID(ctx);
		
		String productNamesEvent = comboboxProductsData.getSelectedItem().getLabel();
		int m_product_id = productNames.get(productNamesEvent);
		Env.setContext(Env.getCtx(), Env.M_PRODUCT_ID, m_product_id);
		
		
		DashboardRunnable dashboardRunnable = new DashboardRunnable(getDesktop());
		for (DashboardPanel dp : dashboardPanels) {
			dashboardRunnable.add(dp);
		}
		dashboardRunnable.refreshDashboard(false);
	}

	public static void add(DashboardPanel dashboardPanel) {
		boolean remove = false;
		DashboardPanel name = null;
		if (dashboardPanels != null) {
		String[] parts = dashboardPanel.toString().split(" ");
		String panel = parts[0].replace("<", "");
		for(DashboardPanel dp : dashboardPanels) {
		String[] listParts = dp.toString().split(" ");
			String listPanel = listParts[0].replace("<", "");
			if(listPanel.equalsIgnoreCase(panel)) {
				remove = true;
				name = dp;
			}
		}
		if(remove) {
			dashboardPanels.remove(name);

		}
		dashboardPanels.add(dashboardPanel);
		}
	}

}
