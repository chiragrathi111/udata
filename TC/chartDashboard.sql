package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.adempiere.webui.component.Button;
import org.adempiere.webui.component.Grid;
import org.adempiere.webui.component.Row;
import org.adempiere.webui.component.Rows;
import org.adempiere.webui.theme.ThemeManager;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.model.MQuery;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.idempiere.zk.billboard.Billboard;
import org.zkoss.json.JSONObject;
import org.zkoss.zk.ui.Component;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.Events;
import org.zkoss.zul.CategoryModel;
import org.zkoss.zul.ChartModel;
import org.zkoss.zul.Div;
import org.zkoss.zul.SimpleCategoryModel;

public class DPUserWiseLTPerformance extends DashboardPanel {

	private static final long serialVersionUID = 1L;

	private Billboard userDatas;

	private LinkedHashMap<String, Integer> UserIdAndName = new LinkedHashMap<String, Integer>();
	private LinkedHashMap<String, Integer> userData = null;

	private static String User_Data = "userName";

	public DPUserWiseLTPerformance() {
		super();
		this.setSclass("activities-box");
		initOptions();

		buildChart(userData, User_Data);

		ZoomListener listener = new ZoomListener(null, userDatas.getModel());
		userDatas.addEventListener("onDataClick", listener);

		this.appendChild(createActivitiesPanel());
	}

	private Grid createActivitiesPanel() {

		Grid grid = new Grid();
		grid.setSclass("pipra-charts-title-indicator");
		appendChild(grid);
		grid.makeNoStrip();

		Rows rows = new Rows();
		grid.appendChild(rows);

		Row row = null;
		List<Billboard> list = new ArrayList<>();

		list.add(userDatas);

		for (int i = 0; i < list.size(); i++) {
			if (row == null || i % 2 == 0) {
				row = new Row();
				rows.appendChild(row);
			}

			Div div = new Div();
			row.appendCellChild(div, 5);
			div.setSclass("pipra-charts-title-indicator");

			div.appendChild(list.get(i));
			Div titleDiv = new Div();
			titleDiv.setSclass("pipra-charts-title-indicator");

			div.appendChild(titleDiv);

			Button btnNotice = new Button();
			if (i == 0) {
				btnNotice.setLabel("ALL");
				btnNotice.setTooltiptext("ALl Warehouse");
				btnNotice.setImage(ThemeManager.getThemeResource("images/StepBack24.png"));
				btnNotice.setName("All");
				btnNotice.setStyle("float: right;");

				ZoomListener listener = new ZoomListener(null, userDatas.getModel());
				btnNotice.addEventListener(Events.ON_CLICK, listener);
			}
			div.appendChild(btnNotice);
			
		}	

		return grid;
	}

	private void initOptions() {

		Properties ctx = Env.getCtx();
		int clientId = Env.getAD_Client_ID(ctx);

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			String sql = null;
				
				sql = "select sr.name AS UserName,o.salesrep_id AS UserId,pr.name As Pname,ou.quantity As quantity  from adempiere.tc_order o\n"
						+ "join adempiere.ad_user sr ON o.salesrep_id = sr.ad_user_id\n"
						+ "join adempiere.tc_out ou ON ou.tc_order_id = o.tc_order_id\n"
						+ "join adempiere.m_product pr ON pr.m_product_id = ou.m_product_id\n"
						+ "where o.ad_client_id = "+clientId+" order by sr.name;";
			
			pstmt = DB.prepareStatement(sql.toString(), null);
			rs = pstmt.executeQuery();
			userData = new LinkedHashMap<String, Integer>();
			while (rs.next()) {
				int UserId = rs.getInt("UserId");
				String UserName = rs.getString("UserName");
				int Qnty = rs.getInt("quantity");
				String locatorTypeName = rs.getString("Pname");
				userData.put(locatorTypeName, Qnty);
				
				if(!UserIdAndName.containsKey(UserName))
					UserIdAndName.put(UserName, UserId);

			}
			DB.close(rs, pstmt);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void updateUI() {
		userDatas.setModel(initChartModel(userData, User_Data));
		userDatas.invalidate();
	}

	@Override
	public void refresh(ServerPushTemplate template) {
		initOptions();

		template.executeAsync(this);
	}

	private void buildChart(LinkedHashMap<String, Integer> data, String type) {

		String barColor = "#2563EB";

		Set<String> wNames = data.keySet();
		Billboard billboard = new Billboard();
		billboard.setLegend(true, false);
		billboard.addLegendOptions("location", "bottom");
		billboard.setTickAxisLabel(type + " Name");
		billboard.setValueAxisLabel("Qauntity");
		billboard.setType("bar");
//		billboard.setType("pi");
		

		String[] rgbColors = new String[wNames.size()];
		Arrays.fill(rgbColors, barColor);		
		billboard.addRendererOptions("intervalColors", rgbColors);
		
		billboard.setModel(initChartModel(data, type));
		billboard.setOrient("vertical");

		if (type.equalsIgnoreCase(User_Data))
			userDatas = billboard;

	}

	private ChartModel initChartModel(LinkedHashMap<String, Integer> data, String type) {
		Set<String> wNames = data.keySet();
		ChartModel chartModel = new SimpleCategoryModel();
		for (String key : wNames) {
			((CategoryModel) chartModel).setValue(type, key, data.get(key));

		}
		return chartModel;
	}

	private class ZoomListener implements EventListener<Event> {
		private org.zkoss.zul.ChartModel model;

		private ZoomListener(Map<String, MQuery> queries, org.zkoss.zul.ChartModel model) {
			this.model = model;
		}

		@Override
		public void onEvent(Event event) throws Exception {

			Component comp = event.getTarget();
			String eventName = event.getName();

			int userId = 0;
			if (eventName.equals(Events.ON_CLICK)) {
				if (comp instanceof Button)
					userId = 0;

			} else {

				JSONObject json = (JSONObject) event.getData();
				Number seriesIndex = (Number) json.get("seriesIndex");
				Number pointIndex = (Number) json.get("pointIndex");
				if (pointIndex == null)
					pointIndex = Integer.valueOf(0);
				
				if (model instanceof CategoryModel) {
					CategoryModel categoryModel = (CategoryModel) model;
					Object series = categoryModel.getSeries(seriesIndex.intValue());
					Object category = categoryModel.getCategory(pointIndex.intValue());

					userId = UserIdAndName.get(category);
				}
			}
			Env.setContext(Env.getCtx(), Env.AD_USER_ID, userId);
			DashboardRunnable dashboardRunnable = DPWarehouseSelection.refreshDashboardPanels(getDesktop());
			dashboardRunnable.refreshDashboard(false);
		}
	}

}
