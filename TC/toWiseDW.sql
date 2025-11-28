package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

import org.adempiere.webui.component.Label;
import org.adempiere.webui.theme.ITheme;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zul.*;

public class DPTOWise extends DashboardPanel implements EventListener<Event> {

    private static final long serialVersionUID = 1L;

    private Map<String, Map<String, Integer>> data = new LinkedHashMap<>();
    private Datebox startDateBox;
    private Datebox endDateBox;
    private Button okButton;

    public DPTOWise() {
        super();
        this.setSclass("activities-box");
        this.appendChild(createDatePanel());
        this.appendChild(createTablePanel());
        updateDashboardData();
    }

    private Div createDatePanel() {
        Div dateRangeDiv = new Div();
        dateRangeDiv.setSclass("date-range-panel");

        Hbox dateBoxContainer = new Hbox();
        dateBoxContainer.setSpacing("10px");

        // From
        Vbox fromBox = new Vbox();
//        fromBox.appendChild(new Label("From"));
        startDateBox = new Datebox();
        startDateBox.setValue(new Date(System.currentTimeMillis() - (7L * 24 * 60 * 60 * 1000)));
        fromBox.appendChild(startDateBox);

        // To
        Vbox toBox = new Vbox();
//        toBox.appendChild(new Label("To"));
        endDateBox = new Datebox();
        endDateBox.setValue(new Date());
        toBox.appendChild(endDateBox);

        // Button
        okButton = new Button("Refresh");
        okButton.setStyle("margin-top: 5px; background: green; color: white; font-weight: bold;");
        okButton.addEventListener("onClick", this);

        dateBoxContainer.appendChild(fromBox);
        dateBoxContainer.appendChild(toBox);
        dateBoxContainer.appendChild(okButton);

        dateRangeDiv.appendChild(dateBoxContainer);
        return dateRangeDiv;
    }

    private Div createTablePanel() {
        Div tableDiv = new Div();
        tableDiv.setSclass("dashboard-table-box");

        Grid grid = new Grid();
        grid.setSclass("dashboard-table");
        Columns columns = new Columns();

        columns.appendChild(createColumn("Name", "150px"));
        columns.appendChild(createColumn("First Visit", "100px"));
        columns.appendChild(createColumn("Intermediate Visit", "140px"));
        columns.appendChild(createColumn("Collection Visit", "120px"));

        grid.appendChild(columns);

        Rows rows = new Rows();

        for (String user : data.keySet()) {
            Map<String, Integer> visitMap = data.get(user);

            Row row = new Row();
            row.appendChild(new Label(user));
            row.appendChild(new Label(String.valueOf(visitMap.getOrDefault("First Visit", 0))));
            row.appendChild(new Label(String.valueOf(visitMap.getOrDefault("Intermediate Visit", 0))));
            row.appendChild(new Label(String.valueOf(visitMap.getOrDefault("Collection Visit", 0))));
            rows.appendChild(row);
        }

        grid.appendChild(rows);
        tableDiv.appendChild(grid);
        return tableDiv;
    }

    private Column createColumn(String title, String width) {
        Column col = new Column(title);
        col.setWidth(width);
        col.setStyle("font-weight:bold; font-size:14px;");
        return col;
    }

    private void fetchData() {

        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);

        data.clear();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT u.name,\n"
            		+ "                       vt.name AS visittype,\n"
            		+ "                       COUNT(v.tc_visit_id) AS cnt\n"
            		+ "                FROM adempiere.ad_user u\n"
            		+ "                JOIN adempiere.ad_user_roles ur ON u.ad_user_id = ur.ad_user_id\n"
            		+ "                JOIN adempiere.ad_role r ON ur.ad_role_id = r.ad_role_id\n"
            		+ "                CROSS JOIN adempiere.tc_visittype vt\n"
            		+ "                LEFT JOIN adempiere.tc_visit v\n"
            		+ "                       ON v.createdby = u.ad_user_id\n"
            		+ "                       AND v.tc_visittype_id = vt.tc_visittype_id\n"
            		+ "                       AND v.created::date BETWEEN ? AND ?\n"
            		+ "                WHERE r.name = 'TO'\n"
            		+ "                AND u.ad_client_id = ?\n"
            		+ "                AND vt.ad_client_id = ?  AND vt.name <> 'All' \n"
            		+ "                GROUP BY u.name, vt.name\n"
            		+ "                ORDER BY u.name";

            pstmt = DB.prepareStatement(sql, null);
            pstmt.setDate(1, new java.sql.Date(startDateBox.getValue().getTime()));
            pstmt.setDate(2, new java.sql.Date(endDateBox.getValue().getTime()));
            pstmt.setInt(3, clientId);
            pstmt.setInt(4, clientId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                String user = rs.getString("name");
                String visitType = rs.getString("visittype");
                int count = rs.getInt("cnt");

                data.computeIfAbsent(user, k -> new HashMap<>());
                data.get(user).put(visitType, count);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DB.close(rs, pstmt);
        }
    }

    @Override
    public void refresh(ServerPushTemplate template) {
        fetchData();
        template.executeAsync(this);
    }

    @Override
    public void updateUI() {
        this.removeChild(this.getLastChild());
        this.appendChild(createTablePanel());
    }

    @Override
    public void onEvent(Event event) throws Exception {
        if (event.getTarget() == okButton) {
            updateDashboardData();
        }
    }

    private void updateDashboardData() {
        fetchData();
        updateUI();
    }
}


//package org.adempiere.webui.dashboard;
//
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.SQLException;
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.LinkedHashMap;
//import java.util.List;
//import java.util.Map;
//import java.util.Properties;
//
//import org.adempiere.webui.component.Label;
//import org.adempiere.webui.theme.ITheme;
//import org.adempiere.webui.util.ServerPushTemplate;
//import org.compiere.util.DB;
//import org.compiere.util.Env;
//import org.zkoss.zk.ui.event.Event;
//import org.zkoss.zk.ui.event.EventListener;
//import org.zkoss.zul.Button;
//import org.zkoss.zul.Datebox;
//import org.zkoss.zul.Div;
//import org.zkoss.zul.Hbox;
//import org.zkoss.zul.Vbox;
//
//public class DPTOWise extends DashboardPanel implements EventListener<Event> {
//
//    private static final long serialVersionUID = 1L;
//
//    private Map<String, Map<String, List<Object[]>>> data = new LinkedHashMap<>();
//    private Datebox startDateBox;
//    private Datebox endDateBox;
//    private Button okButton;
//
//    public DPTOWise() {
//        super();
//        this.setSclass("activities-box");
//        this.appendChild(createDatePanel());  // Add date panel
//        this.appendChild(createActivitiesPanel());
//        updateDashboardData();
//    }
//    
//    private Div createDatePanel() {
//    	Div dateRangeDiv = new Div();
//        dateRangeDiv.setSclass("date-range-panel");
//
//        // Create a vertical layout for "From" date
//        Vbox fromBox = new Vbox();
//        Label fromLabel = new Label("From");
//        fromLabel.setStyle("font-weight: bold;"); 
//        startDateBox = new Datebox();
//        startDateBox.setValue(new Date(System.currentTimeMillis() - (7L * 24 * 60 * 60 * 1000))); // Default: last 60 days
//        startDateBox.setStyle("margin-bottom: 10px;"); // Add space below
//        fromBox.appendChild(fromLabel);
//        fromBox.appendChild(startDateBox);
//
//        // Create a vertical layout for "To" date
//        Vbox toBox = new Vbox();
//        Label toLabel = new Label("To");
//        toLabel.setStyle("font-weight: bold;"); 
//        endDateBox = new Datebox();
//        endDateBox.setValue(new Date()); // Default: today
//        toBox.appendChild(toLabel);
//        toBox.appendChild(endDateBox);
//
//        // Refresh button
//        okButton = new Button("Refresh");
//        okButton.addEventListener("onClick", this);
//        okButton.setStyle("margin-top: 23px; font-weight: bold;  background-color: green; color: white;");
//
//        // Use Hbox for horizontal layout with spacing
//        Hbox dateBoxContainer = new Hbox();
//        dateBoxContainer.setSpacing("10px"); // Space between date fields
//        dateBoxContainer.appendChild(fromBox);
//        dateBoxContainer.appendChild(toBox);
//        dateBoxContainer.appendChild(okButton);
//
//        // Add components to the main div
//        dateRangeDiv.appendChild(dateBoxContainer);
//        return dateRangeDiv;
//    }
//
//    private Div createActivitiesPanel() {
//        Div mainDiv = new Div();
//        mainDiv.setSclass(ITheme.WARE_HOUSE_DATA_WIDGET);
//
//        // Create separate boxes for each category
//        for (Map.Entry<String, Map<String, List<Object[]>>> entry : data.entrySet()) {
//            String userName = entry.getKey();
//            Map<String, List<Object[]>> visitTypeData = entry.getValue();
//
//            Div userBox = new Div();
//            userBox.setSclass(ITheme.DASHBOARD_WIDGET_Text_COUNT_CONT);
//
//            // Label for user name
//            Label userLabel = new Label();
//            userLabel.setSclass(ITheme.DASHBOARD_WIDGET_LABELS);
//            userLabel.setStyle("font-size: 20px; font-weight: bold;");
//            userLabel.setValue(userName);
//            userBox.appendChild(userLabel);
//
//            for (Map.Entry<String, List<Object[]>> visitTypeEntry : visitTypeData.entrySet()) {
//                String visitType = visitTypeEntry.getKey();
//                List<Object[]> visitRecords = visitTypeEntry.getValue();
//
//                Div visitTypeBox = new Div();
//                visitTypeBox.setSclass(ITheme.DASHBOARD_WIDGET_Text_COUNT_CONT);
//
//                // Label for visit type
//                Label visitTypeLabel = new Label();
//                visitTypeLabel.setSclass(ITheme.DASHBOARD_WIDGET_LABELS);
//                visitTypeLabel.setValue(visitType);
//                visitTypeBox.appendChild(visitTypeLabel);
//
//                // Show three records with quantity for the visit type
//                for (Object[] record : visitRecords) {
//                    Label recordLabel = new Label();
//                    recordLabel.setSclass(ITheme.DASHBOARD_WIDGET_COUNT);
//                    recordLabel.setValue(" " + record[1]);
//                    visitTypeBox.appendChild(recordLabel);
//                }
//                userBox.appendChild(visitTypeBox);
//            }
//            mainDiv.appendChild(userBox);
//        }
//        return mainDiv;
//    }
//
//    private void fetchData() {
//        Properties ctx = Env.getCtx();
//        int clientId = Env.getAD_Client_ID(ctx);
//        PreparedStatement pstmt = null;
//        ResultSet rs = null;
//        try {
//        	Date startDate = startDateBox.getValue();
//            Date endDate = endDateBox.getValue();   
//            data.clear();
//            
//            String sql = "SELECT vt.name AS VisitType,COALESCE(COUNT(v.tc_visittype_id), 0) AS VisitCount,u.name AS UserName,\n"
//            		+ "CASE \n"
//            		+ "    WHEN vt.name = 'First Visit' THEN 1 \n"
//            		+ "    WHEN vt.name = 'Intermediate Visit' THEN 2 \n"
//            		+ "    WHEN vt.name = 'Collection Visit' THEN 3 \n"
//            		+ "    ELSE 4\n"
//            		+ "  END AS VisitOrder\n"
//            		+ "FROM adempiere.tc_visittype vt CROSS JOIN adempiere.ad_user u\n"
//            		+ "LEFT JOIN adempiere.tc_visit v ON vt.tc_visittype_id = v.tc_visittype_id AND u.ad_user_id = v.createdby \n"
//            		+ "AND v.created::DATE BETWEEN ? AND ?\n"
//            		+ "WHERE u.ad_user_id IN (SELECT ur.ad_user_id FROM adempiere.ad_user_roles ur JOIN adempiere.ad_role r ON r.ad_role_id = ur.ad_role_id \n"
//            		+ "WHERE r.name = 'TO' AND ur.ad_client_id = ?) AND vt.ad_client_id = ? AND vt.name <> 'All'\n"
//            		+ "GROUP BY vt.name, vt.tc_visittype_id, u.name ORDER BY u.name,VisitOrder,vt.tc_visittype_id;";
//            pstmt = DB.prepareStatement(sql, null);
//            pstmt.setDate(1, new java.sql.Date(startDate.getTime()));
//            pstmt.setDate(2, new java.sql.Date(endDate.getTime()));
//            pstmt.setInt(3, clientId);
//            pstmt.setInt(4, clientId);
//            rs = pstmt.executeQuery();
//            while (rs.next()) {
//                String userName = rs.getString("UserName");
//                String visitType = rs.getString("VisitType");
//                int visitCount = rs.getInt("VisitCount");
//
//                if (!data.containsKey(userName)) {
//                    data.put(userName, new LinkedHashMap<>());
//                }
//                Map<String, List<Object[]>> userData = data.get(userName);
//                if (!userData.containsKey(visitType)) {
//                    userData.put(visitType, new ArrayList<>());
//                }
//                List<Object[]> visitTypeData = userData.get(visitType);
//                visitTypeData.add(new Object[] { visitType, visitCount });
//            }
//            DB.close(rs, pstmt);
//        } catch (SQLException e) {
//            e.printStackTrace();
//        } finally {
//            DB.close(rs, pstmt);
//        }
//    }
//    @Override
//    public void refresh(ServerPushTemplate template) {
//    	fetchData();
//    	template.executeAsync(this);
//    }
//    
//    @Override
//    public void updateUI() {
//    	this.removeChild(this.getLastChild()); // Remove previous activities panel
//        this.appendChild(createActivitiesPanel());
//    }
//    
//    @Override
//    public void onEvent(Event event) throws Exception {
//    	if (event.getTarget() == okButton) {
//            updateDashboardData();  // Update dashboard data based on date range
//        }
//    }
//    private void updateDashboardData() {
//        fetchData(); // Refresh data based on date range
//        updateUI();    // Update UI to reflect new data
//    }
//}