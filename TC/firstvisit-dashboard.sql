package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Properties;

import org.adempiere.webui.component.Button;
import org.adempiere.webui.component.Label;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zul.Datebox;
import org.zkoss.zul.Div;
import org.zkoss.zul.Hbox;
import org.zkoss.zul.Vbox;

import tools.dynamia.zk.addons.chartjs.Chartjs;
import tools.dynamia.zk.addons.chartjs.ChartjsData;
import tools.dynamia.zk.addons.chartjs.ChartjsOptions;
import tools.dynamia.zk.addons.chartjs.Dataset;

public class DPSales extends DashboardPanel implements EventListener<Event> {
    
    private static final long serialVersionUID = 1L;
    private Chartjs chartjs;   // Pie chart component
    private Datebox startDateBox;
    private Datebox endDateBox;
    private Button refreshButton;
    private LinkedHashMap<String, Integer> visitData;  // Store visit data for pie chart
    ChartjsData chartData = new ChartjsData();
    
    public DPSales() {
        super();
        this.setSclass("activities-box");
        visitData = new LinkedHashMap<>();
        
        this.appendChild(createDateRangePanel());
        this.appendChild(createChartPanel());
        
        // Load initial data
        loadChartData();
        updateChart();
    }

    private Div createDateRangePanel() {
        Div dateRangeDiv = new Div();
        dateRangeDiv.setSclass("date-range-panel");

        // Create a vertical layout for "From" date
        Vbox fromBox = new Vbox();
        Label fromLabel = new Label("From");
        fromLabel.setStyle("font-weight: bold;"); 
        startDateBox = new Datebox();
        startDateBox.setValue(new Date(System.currentTimeMillis() - (60L * 24 * 60 * 60 * 1000))); // Default: last 60 days
        startDateBox.setStyle("margin-bottom: 10px;"); // Add space below
        fromBox.appendChild(fromLabel);
        fromBox.appendChild(startDateBox);

        // Create a vertical layout for "To" date
        Vbox toBox = new Vbox();
        Label toLabel = new Label("To");
        toLabel.setStyle("font-weight: bold;"); 
        endDateBox = new Datebox();
        endDateBox.setValue(new Date()); // Default: today
        toBox.appendChild(toLabel);
        toBox.appendChild(endDateBox);

        // Refresh button
        refreshButton = new Button("Refresh");
        refreshButton.addEventListener("onClick", this);
        refreshButton.setStyle("margin-top: 23px; font-weight: bold;  background-color: green; color: white;");

        // Use Hbox for horizontal layout with spacing
        Hbox dateBoxContainer = new Hbox();
        dateBoxContainer.setSpacing("10px"); // Space between date fields
        dateBoxContainer.appendChild(fromBox);
        dateBoxContainer.appendChild(toBox);
        dateBoxContainer.appendChild(refreshButton);

        // Add components to the main div
        dateRangeDiv.appendChild(dateBoxContainer);
        return dateRangeDiv;
    }

    private Div createChartPanel() {
        Div chartDiv = new Div();
        chartjs = new Chartjs(Chartjs.TYPE_PIE);
        chartjs.setWidth("90%");
        chartjs.setOptions(ChartjsOptions.Builder.init().responsive(true).build());

        chartDiv.appendChild(chartjs);
        return chartDiv;
    }

    private void loadChartData() {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);
        Date startDate = startDateBox.getValue();
        Date endDate = endDateBox.getValue();
        String visitTypeName = "First Visit";
        int totalCount = 0;

        String sql = "SELECT 'Completed' AS Status, COUNT(CASE WHEN s.name = 'Completed' THEN 1 END) AS Count " +
                "FROM adempiere.tc_visit v " +
                "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"' AND v.updated::DATE BETWEEN ? AND ?  " +
                "UNION ALL " +
                "SELECT 'Cancelled' AS Status, COUNT(CASE WHEN s.name = 'Cancelled' THEN 1 END) AS Count " +
                "FROM adempiere.tc_visit v " +
                "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"' AND v.updated::DATE BETWEEN ? AND ?" +
                "UNION ALL " +
                "SELECT 'Upcoming' AS Status, COUNT(CASE WHEN s.name = 'In Progress' THEN 1 END) AS Count " +
                "FROM adempiere.tc_visit v " +
                "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
                "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
                "WHERE v.ad_client_id = " + clientId + " AND vt.name = '"+visitTypeName+"'AND v.created::DATE BETWEEN ? AND ?;";

        try (PreparedStatement pstmt = DB.prepareStatement(sql, null)) {
            pstmt.setDate(1, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(2, new java.sql.Date(endDate.getTime()));
            pstmt.setDate(3, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(4, new java.sql.Date(endDate.getTime()));
            pstmt.setDate(5, new java.sql.Date(startDate.getTime()));
            pstmt.setDate(6, new java.sql.Date(endDate.getTime()));

            try (ResultSet rs = pstmt.executeQuery()) {
                visitData.clear();
                while (rs.next()) {
                    int count = rs.getInt("Count");
                    visitData.put(rs.getString("Status"), rs.getInt("Count"));
                    totalCount += count;
                }
                if (totalCount == 0) {
                    visitData.clear();
                    visitData.put("No Record Found", 0);
                }
                DB.close(rs, pstmt);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void updateChart() {
        chartData.getDatasets().clear();
        chartData.getLabels().clear();
        Dataset<Integer> dataset = new Dataset<>();
       
        if (visitData.isEmpty()) {
            visitData.put("No Record Found", 0);
        }
        dataset.setData(new ArrayList<>(visitData.values()));
        dataset.setBackgroundColors(new String[]{"#4CAF50", "#FF5733", "#FFC107"});
        dataset.setLabel("Visit Status");

        chartData.setLabels(visitData.keySet().toArray(new String[0]));
        chartData.addDataset(dataset);
        
        chartjs.setData(chartData);
        chartjs.invalidate(); // Refresh UI
    }
    
    @Override
    public void updateUI() {
        loadChartData();
        updateChart();
    }

    @Override
    public void onEvent(Event event) {
        if (event.getTarget() == refreshButton) {
            updateUI();
        }
    }
    
    @Override
    public void refresh(ServerPushTemplate template) {
        loadChartData();
        template.executeAsync(this);
    }
}