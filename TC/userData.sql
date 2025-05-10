User Data:-

Report:-

1 Stagewise productvity:-

stage (product), Quantity, locator (tc_out)

2 Technician wise productvity:-

whole tc_order table using sales_rep wise 
sales_rep,tc_order_id,out_Qty,out_product,out_locator


========================================================================================================
package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.adempiere.webui.component.Label;
import org.adempiere.webui.theme.ITheme;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.EventQueue;
import org.zkoss.zk.ui.event.EventQueues;
import org.zkoss.zul.Div;

public class DPCultureDistribution extends DashboardPanel implements EventListener<Event> {

    private static final long serialVersionUID = 1L;

    private List<String> categories = new ArrayList<>();
    private Map<String, Integer> categoryQuantities = new HashMap<>();

    public DPCultureDistribution() {
        super();
        this.setSclass("activities-box");
        initOptions();
        this.appendChild(createActivitiesPanel());
    }

    private Div createActivitiesPanel() {
        Div div = new Div();
        div.setSclass(ITheme.WARE_HOUSE_DATA_WIDGET);

        // Create a parent div for the labels
        Div labelsDiv = new Div();
        labelsDiv.setSclass(ITheme.DASHBOARD_WIDGET_Text_COUNT_CONT);
        div.appendChild(labelsDiv);

        // Create a parent div for the quantities
        Div quantitiesDiv = new Div();
        quantitiesDiv.setSclass(ITheme.DASHBOARD_WIDGET_Text_COUNT_CONT);
        div.appendChild(quantitiesDiv);

        // Add labels and quantities dynamically
        for (String category : categories) {
            Label categoryLabel = new Label();
            categoryLabel.setSclass(ITheme.DASHBOARD_WIDGET_LABELS);
            categoryLabel.setValue(category);
            labelsDiv.appendChild(categoryLabel);

            Label countLabel = new Label();
            countLabel.setSclass(ITheme.DASHBOARD_WIDGET_COUNT);
            countLabel.setValue(" " + categoryQuantities.getOrDefault(category, 0));
            quantitiesDiv.appendChild(countLabel);
        }

        return div;
    }

    private void initOptions() {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);
        PreparedStatement pstmt = null;
        ResultSet RS = null;
        try {
            String sql = "SELECT Category, SUM(TotalQuantity) AS TotalQuantity FROM (\n"
                    + "    SELECT\n"
                    + "        CASE\n"
                    + "            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'\n"
                    + "            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'\n"
                    + "            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'\n"
                    + "            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'\n"
                    + "            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Harding'\n"
                    + "            ELSE 'Other'\n"
                    + "        END AS Category,\n"
                    + "        o.quantity AS TotalQuantity\n"
                    + "    FROM adempiere.tc_out o\n"
                    + "    JOIN adempiere.m_product pr ON pr.m_product_id = o.m_product_id\n"
                    + ") AS Subquery\n"
                    + "WHERE Category <> 'Other' GROUP BY Category ORDER BY Category;";
            pstmt = DB.prepareStatement(sql, null);
            RS = pstmt.executeQuery();
            while (RS.next()) {
                String category = RS.getString("Category");
                int totalQuantity = RS.getInt("TotalQuantity");
                categories.add(category);
                categoryQuantities.put(category, totalQuantity);
            }
            DB.close(RS, pstmt);
            RS = null;
            pstmt = null;
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void refresh(ServerPushTemplate template) {
        initOptions();
        template.executeAsync(this);
    }

    @Override
    public void updateUI() {
        // No need to update UI here, as the UI is dynamically created in createActivitiesPanel()
    }

    @Override
    public void onEvent(Event event) throws Exception {
        // No event handling needed in this context
    }
}
===============================================================================================
Active MQ producer class:-
package org.realmeds.tissue.activemq;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.compiere.util.CLogger;

public class ActiveMQProducer{

    private String brokerUrl = "tcp://127.0.0.1:61616";
    private String topicName = "tissueculture-queue";
    protected static final CLogger  log = CLogger.getCLogger (ActiveMQProducer.class);
    
    private static boolean activeMqStarted = false; 

    public void sendMessage(String table, int recordId) throws JMSException {
        // Create a connection factory
        ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(brokerUrl);

        // Create a connection
        Connection connection = factory.createConnection();
        connection.start();

        // Create a session
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        // Create a topic
//        Topic topic = session.createTopic(topicName);
        //Create q Queue
        
        Destination destination = session.createQueue(topicName);

        // Create a message producer
        MessageProducer producer = session.createProducer(destination);

        // Construct the message content
        String messageContent = "{\"table\": \"" + table + "\", \"recordId\": " + recordId + "}";

        // Create a text message
        TextMessage message = session.createTextMessage(messageContent);

        // Send the message
        producer.send(message);

        // Clean up
        producer.close();
        session.close();
        connection.close();
        if(!activeMqStarted) {
            ActiveMQConsumer consumer = new ActiveMQConsumer();
            consumer.run();
            activeMqStarted = true;
        }
    }
}

=================================================================================================================================================================
Consumer Class:-
package org.realmeds.tissue.activemq;

import javax.jms.BytesMessage;
import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.Session;
import javax.jms.TextMessage;
import org.apache.activemq.ActiveMQConnectionFactory;
import org.codehaus.jettison.json.JSONObject;
import org.compiere.util.DB;

public class ActiveMQConsumer implements Runnable {

    private String brokerUrl = "tcp://127.0.0.1:61616";
    private String topicName = "tissueculture-update-queue";

    @Override
    public void run() {
        try {
            ActiveMQConnectionFactory factory = new ActiveMQConnectionFactory(brokerUrl);
            Connection connection = factory.createConnection();
            connection.start();

            Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
//            Topic topic = session.createTopic(topicName);
            Destination destination = session.createQueue(topicName);

            MessageConsumer consumer = session.createConsumer(destination);
            consumer.setMessageListener(message -> {
                try {
                    if (message instanceof TextMessage) {
                        String text = ((TextMessage) message).getText();
                        processMessage(text);
                        System.out.println("Received TextMessage: " + text);
                    } else if (message instanceof BytesMessage) {
                        BytesMessage bytesMessage = (BytesMessage) message;
                        byte[] data = new byte[(int) bytesMessage.getBodyLength()];
                        bytesMessage.readBytes(data);
                        String text = new String(data);
                        processMessage(text);
                        System.out.println("Received BytesMessage: " + text);
                    } else {
                        System.out.println("Received unsupported message type: " + message.getClass());
                    }
                } catch (JMSException e) {
                    e.printStackTrace();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void processMessage(String message) {
        try {
            JSONObject json = new JSONObject(message);
            String table = json.getString("tableName");
            String recordId = json.getString("recordId");
            String uuid = json.getString("uuid");
            String tablecolumn = (table + "_id");
            int recordIdInt = Integer.parseInt(recordId);

            String sql = "UPDATE " + table + " SET c_uuid = ? WHERE " + tablecolumn + " = ?";
            DB.executeUpdate(sql, new Object[] { uuid, recordIdInt }, false, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

====================================================================================================================
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0
--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"
#cloud-config
cloud_final_modules:
[scripts-user, always]
--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"
#!/bin/bash
sudo ufw disable
iptables -L
iptables -F
--//

==================================================================================================

package org.adempiere.webui.dashboard;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.adempiere.webui.component.Label;
import org.adempiere.webui.theme.ITheme;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.DB;
import org.compiere.util.Env;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.EventQueue;
import org.zkoss.zk.ui.event.EventQueues;
import org.zkoss.zul.Div;

public class DPCultureDistributionWithRoomWise extends DashboardPanel implements EventListener<Event> {

    private static final long serialVersionUID = 1L;

    private List<String> categories = new ArrayList<>();
    private Map<String, Integer> categoryQuantities = new HashMap<>();

    public DPCultureDistributionWithRoomWise() {
        super();
        this.setSclass("activities-box");
        initOptions();
        this.appendChild(createActivitiesPanel());
    }

    private Div createActivitiesPanel() {
        Div mainDiv = new Div();
        mainDiv.setSclass(ITheme.WARE_HOUSE_DATA_WIDGET);

        // Create separate boxes for each category
        for (String category : categories) {
            Div categoryBox = new Div();
            categoryBox.setSclass(ITheme.DASHBOARD_WIDGET_Text_COUNT_CONT);

            // Label for category name
            Label categoryLabel = new Label();
            categoryLabel.setSclass(ITheme.DASHBOARD_WIDGET_LABELS);
            categoryLabel.setValue(category);
            categoryBox.appendChild(categoryLabel);

            // Label for category quantity
            Label countLabel = new Label();
            countLabel.setSclass(ITheme.DASHBOARD_WIDGET_COUNT);
            countLabel.setValue(" " + categoryQuantities.getOrDefault(category, 0));
            categoryBox.appendChild(countLabel);

            mainDiv.appendChild(categoryBox);
        }

        return mainDiv;
    }

    private void initOptions() {
        Properties ctx = Env.getCtx();
        int clientId = Env.getAD_Client_ID(ctx);
        PreparedStatement pstmt = null;
        ResultSet RS = null;
        try {
            String sql = "WITH categories AS (\n"
                    + "    SELECT 'Initiation' AS Category\n"
                    + "    UNION ALL SELECT 'Callusing'\n"
                    + "    UNION ALL SELECT 'Multiplication'\n"
                    + "    UNION ALL SELECT 'Elongation'\n"
                    + "    UNION ALL SELECT 'Rooting'\n"
                    + "    UNION ALL SELECT 'Hardening'\n"
                    + "),\n"
                    + "category_counts AS (\n"
                    + "    SELECT\n"
                    + "        lt.name AS RoomType,\n"
                    + "        CASE\n"
                    + "            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'\n"
                    + "            WHEN pr.name LIKE 'BC%' THEN 'Callusing'\n"
                    + "            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'\n"
                    + "            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'\n"
                    + "            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'\n"
                    + "            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Hardening'\n"
                    + "            ELSE 'Other'\n"
                    + "        END AS Category,\n"
                    + "        SUM(o.qtyonhand)::int AS TotalQuantity\n"
                    + "    FROM \n"
                    + "        adempiere.m_storageonhand o\n"
                    + "    JOIN \n"
                    + "        adempiere.m_product pr ON pr.m_product_id = o.m_product_id\n"
                    + "    JOIN \n"
                    + "        adempiere.m_locator l ON l.m_locator_id = o.m_locator_id\n"
                    + "    JOIN \n"
                    + "        adempiere.m_locatortype lt ON lt.m_locatortype_id = l.m_locatortype_id\n"
                    + "    WHERE \n"
                    + "        o.ad_client_id = "+clientId+"\n"
                    + "        AND lt.description LIKE 'Room'\n"
                    + "    GROUP BY \n"
                    + "        lt.name,\n"
                    + "        CASE\n"
                    + "            WHEN pr.name LIKE 'BI%' OR pr.name LIKE 'N%' THEN 'Initiation'\n"
                    + "            WHEN pr.name LIKE 'BC%' THEN 'Callusing'\n"
                    + "            WHEN pr.name LIKE 'BM%' OR pr.name LIKE 'M%' THEN 'Multiplication'\n"
                    + "            WHEN pr.name LIKE 'BE%' OR pr.name LIKE 'E%' THEN 'Elongation'\n"
                    + "            WHEN pr.name LIKE 'BR%' OR pr.name LIKE 'R%' THEN 'Rooting'\n"
                    + "            WHEN pr.name LIKE 'BH%' OR pr.name LIKE 'H%' THEN 'Hardening'\n"
                    + "            ELSE 'Other'\n"
                    + "        END\n"
                    + ")\n"
                    + "SELECT \n"
                    + "    r.RoomType As RoomType, \n"
                    + "    c.Category AS Category, \n"
                    + "    COALESCE(cc.TotalQuantity, 0) AS TotalQuantity\n"
                    + "FROM \n"
                    + "    (SELECT DISTINCT lt.name AS RoomType \n"
                    + "     FROM adempiere.m_locatortype lt \n"
                    + "     WHERE lt.description LIKE 'Room') r\n"
                    + "CROSS JOIN \n"
                    + "    categories c\n"
                    + "LEFT JOIN \n"
                    + "    category_counts cc ON r.RoomType = cc.RoomType AND c.Category = cc.Category\n"
                    + "ORDER BY \n"
                    + "    r.RoomType,\n"
                    + "    CASE c.Category\n"
                    + "        WHEN 'Initiation' THEN 1\n"
                    + "        WHEN 'Callusing' THEN 2\n"
                    + "        WHEN 'Multiplication' THEN 3\n"
                    + "        WHEN 'Elongation' THEN 4\n"
                    + "        WHEN 'Rooting' THEN 5\n"
                    + "        WHEN 'Hardening' THEN 6\n"
                    + "        ELSE 7\n"
                    + "    END;\n"
                    + "";
            pstmt = DB.prepareStatement(sql, null);
            RS = pstmt.executeQuery();
            while (RS.next()) {
                String category = RS.getString("Category");
                int totalQuantity = RS.getInt("TotalQuantity");
                categories.add(category);
                categoryQuantities.put(category, totalQuantity);
            }
            DB.close(RS, pstmt);
            RS = null;
            pstmt = null;
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void refresh(ServerPushTemplate template) {
        initOptions();
        template.executeAsync(this);
    }

    @Override
    public void updateUI() {
        // No need to update UI here, as the UI is dynamically created in createActivitiesPanel()
    }

    @Override
    public void onEvent(Event event) throws Exception {
        // No event handling needed in this context
    }
}
==================================================================================================
Get visit:-
public GetVisitResponseDocument getVisit(GetVisitRequestDocument req) {
        GetVisitResponseDocument getVisitResponseDocument = GetVisitResponseDocument.Factory.newInstance();
        GetVisitResponse getVisitResponse = getVisitResponseDocument.addNewGetVisitResponse();
        GetVisitRequest loginRequest = req.getGetVisitRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String serviceType = loginRequest.getServiceType();
        int client = login.getClientID();
        Trx trx = null;
        String base64 = "";
        int tableId = MTable.getTable_ID("TC_visit");
        MAttachment attachment = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        String searchKey = loginRequest.getSearchKey();
//      String selectedColumn = loginRequest.getSelectedColumn();
        
        try {
            getCompiereService().connect();
            CompiereService m_cs = getCompiereService();
            Properties ctx = m_cs.getCtx();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "getVisitList", serviceType);
            if (err != null && err.length() > 0) {
                getVisitResponse.setError(err);
                getVisitResponse.setIsError(true);
                return getVisitResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("getVisitList")) {
                getVisitResponse.setError("Service type " + serviceType + " not configured");
                getVisitResponse.setIsError(true);
                return getVisitResponseDocument;
            }
            List<String> farmerList = new ArrayList<>();
            List<String> statusList = new ArrayList<>();
            List<String> dateList = new ArrayList<>();
            List<String> visittypeList = new ArrayList<>();
            List<String> mobilenoList = new ArrayList<>();

            for (Filter filter : loginRequest.getFiltersArray()) {
                switch (filter.getKey().toLowerCase()) {
                    case "farmername":
                        farmerList.add("'" + filter.getValue() + "'");
                        break;
                    case "status":
                        statusList.add("'" + filter.getValue() + "'");
                        break;
                    case "date":
                        dateList.add("'" + filter.getValue() + "'");
                        break;
                    case "visittype":
                        visittypeList.add("'" + filter.getValue() + "'");
                        break;
                    case "mobileno":
                        mobilenoList.add("'" + filter.getValue() + "'");
                        break;
                }
            }
            
            StringBuilder sql = new StringBuilder("SELECT f.name AS Name, vt.name AS VisitType, v.date AS Date, f.mobileno AS MobileNo,"
                    + "v.tc_visit_id AS ID, s.name AS status FROM adempiere.tc_visit v "
                    + "JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id"
                    + "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id"
                    + "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id"
                    + "WHERE v.ad_client_id = "+client+"");

            if (!farmerList.isEmpty()) {
                sql.append(" AND name IN (").append(String.join(", ", farmerList)).append(")");
            }
            if (!statusList.isEmpty()) {
                sql.append(" AND status IN (").append(String.join(", ", statusList)).append(")");
            }
            if (!dateList.isEmpty()) {
                sql.append(" AND date IN (").append(String.join(", ", dateList)).append(")");
            }
            if (!visittypeList.isEmpty()) {
                sql.append(" AND visittype IN (").append(String.join(", ", visittypeList)).append(")");
            }
            if (!mobilenoList.isEmpty()) {
                sql.append(" AND mobileno IN (").append(String.join(", ", mobilenoList)).append(")");
            }
         // Add conditions for searchKey
            if (searchKey != null && !searchKey.trim().isEmpty()) {
                sql.append(" AND (name ILIKE ? OR status ILIKE ? OR date ILIKE ? OR visittype ILIKE ? OR mobileno ILIKE ?)");
            }
            pstm = DB.prepareStatement(sql.toString(), null);

            // Set searchKey parameters
            int parameterIndex = 1;
            if (searchKey != null && !searchKey.trim().isEmpty()) {
                for (int i = 0; i < 5; i++) {
                    pstm.setString(parameterIndex++, "%" + searchKey + "%");
                }
            }
            rs = pstm.executeQuery();
//          StringBuilder sql = new StringBuilder("SELECT f.name AS Name, vt.name AS VisitType, v.date AS Date, f.mobileno AS MobileNo, ")
//                  .append("v.tc_visit_id AS ID, s.name AS status FROM adempiere.tc_visit v ")
//                  .append("JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id ")
//                  .append("JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id ")
//                  .append("JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id ")
//                  .append("WHERE v.ad_client_id = ? ");

//          List<String> searchKeys = new ArrayList<>();
//
//          if (searchKey != null && !searchKey.trim().isEmpty()) {
//              if (selectedColumn != null && !selectedColumn.trim().isEmpty()) {
//                  switch (selectedColumn.toLowerCase()) {
//                      case "name":
//                          sql.append("AND f.name ILIKE '%' || ? || '%' ");
//                          searchKeys.add(searchKey);
//                          break;
//                      case "status":
//                          sql.append("AND s.name ILIKE '%' || ? || '%' ");
//                          searchKeys.add(searchKey);
//                          break;
//                      case "mobileno":
//                          sql.append("AND f.mobileno ILIKE '%' || ? || '%' ");
//                          searchKeys.add(searchKey);
//                          break;
//                      case "date":
//                          sql.append("AND v.date::text ILIKE '%' || ? || '%' ");
//                          searchKeys.add(searchKey);
//                          break;
//                      case "visittype":
//                          sql.append("AND vt.name ILIKE '%' || ? || '%' ");
//                          searchKeys.add(searchKey);
//                          break;    
//                      default:
//                          sql.append("AND (f.name ILIKE '%' || ? || '%' ")
//                             .append("OR s.name ILIKE '%' || ? || '%' ")
//                             .append("OR f.mobileno ILIKE '%' || ? || '%' ")
//                             .append("OR v.date::text ILIKE '%' || ? || '%' ")
//                             .append("OR vt.name ILIKE '%' || ? || '%') ");
//                          for (int i = 0; i < 5; i++) {
//                              searchKeys.add(searchKey);
//                          }
//                          break;
//                  }
//              } else {
//                  sql.append("AND (f.name ILIKE '%' || ? || '%' ")
//                     .append("OR s.name ILIKE '%' || ? || '%' ")
//                     .append("OR f.mobileno ILIKE '%' || ? || '%' ")
//                     .append("OR v.date::text ILIKE '%' || ? || '%' ")
//                     .append("OR vt.name ILIKE '%' || ? || '%') ");
//                  for (int i = 0; i < 5; i++) {
//                      searchKeys.add(searchKey);
//                  }
//              }
//          }
//          sql.append("ORDER BY v.date");
//
//          pstm = DB.prepareStatement(sql.toString(), null);
//          pstm.setInt(1, client);
//
//          for (int i = 0; i < searchKeys.size(); i++) {
//              pstm.setString(i + 2, searchKeys.get(i)); // Parameters for searchKeys start from index 2
//          }
//          rs = pstm.executeQuery();
            while (rs.next()) {
                ListOfVisit listOfVisits = getVisitResponse.addNewListOfVisit();
                String Name = rs.getString("Name");
                String VisitType = rs.getString("VisitType");
                String Date = rs.getString("Date");
                String MobileNo = rs.getString("MobileNo");
                int VisitId = rs.getInt("ID");
                String Status = rs.getString("status");

                listOfVisits.setVisitId(VisitId);
                listOfVisits.setName(Name);
                listOfVisits.setVisitType(VisitType);
                listOfVisits.setDate(Date);
                listOfVisits.setMobileNo(MobileNo);
                listOfVisits.setStatus(Status);

                attachment = MAttachment.get(ctx, tableId, VisitId);
                if (attachment != null) {
                    MAttachmentEntry[] entries = attachment.getEntries();
                    for (MAttachmentEntry entry : entries) {
                        byte[] data = entry.getData();
                        base64 = Base64.getEncoder().encodeToString(data);
                        ImageArray imageArray = listOfVisits.addNewImageArray1();
                        imageArray.setImage64(base64);
                    }
                } else {
                    listOfVisits.addNewImageArray1();
                }
            }
            trx.commit();
        } catch (Exception e) {
            if (trx != null) {
                trx.rollback();
            }
            getVisitResponse.setError(e.getMessage());
            getVisitResponse.setIsError(true);
        } finally {
            DB.close(rs, pstm);
            if (trx != null) {
                trx.close();
            }
        }
        return getVisitResponseDocument;
    }
==================================================================================================
Avarage Time:-
WITH InitialCollection AS (
    SELECT pt.tc_planttag_id, pt.c_uuid, pt.created AS initial_collection_date 
    FROM adempiere.tc_planttag pt
),
PlantDetailsDates AS (
    SELECT cs.tc_plantdetails_id, cs.plantTagUUId, cs.created AS plantDetails_date 
    FROM adempiere.tc_plantdetails cs
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = cs.plantTagUUId 
    WHERE cs.plantTagUUId = pt.c_uuid
),    
SuckerCollectionDates AS (
    SELECT sc.tc_plantdetails_id, sc.suckerNo, sc.created AS sucker_collection_date 
    FROM adempiere.tc_collectionjoinplant sc
    JOIN adempiere.tc_plantdetails pt ON pt.tc_plantdetails_id = sc.tc_plantdetails_id
),
ExplantDates AS (
    SELECT el.c_uuid AS explantuuid, el.parentuuid AS parentuuid, el.created AS explant_date 
    FROM adempiere.tc_explantlabel el
    JOIN adempiere.tc_planttag pt ON pt.c_uuid = el.parentuuid
),
CultureDates AS (
    SELECT cl.c_uuid AS cultureuuid, cl.parentuuid AS parentuuid, cl.created AS culture_date 
    FROM adempiere.tc_culturelabel cl
),
LatestCultureDates AS (
    SELECT cl2.c_uuid AS cultureuuid2, cl2.parentuuid AS parentuuid2, cl2.created AS culture_date2 
    FROM adempiere.tc_culturelabel cl2
),
LatestCultureDates3 AS (
    SELECT cl3.c_uuid AS cultureuuid3, cl3.parentuuid AS parentuuid3, cl3.created AS culture_date3 
    FROM adempiere.tc_culturelabel cl3
),
LatestCultureDates4 AS (
    SELECT cl4.c_uuid AS cultureuuid4, cl4.parentuuid AS parentuuid4, cl4.created AS culture_date4 
    FROM adempiere.tc_culturelabel cl4
),
LatestCultureDates5 AS (
    SELECT cl5.c_uuid AS cultureuuid5, cl5.parentuuid AS parentuuid5, cl5.created AS culture_date5 
    FROM adempiere.tc_culturelabel cl5
)  
SELECT 
    ic.c_uuid AS plant_tag_uuid,
    ic.initial_collection_date,
    crd.plantDetails_date,
    scd.sucker_collection_date,
    eld.explant_date,
    cld.culture_date,
    cl2d.culture_date2,cl3d.culture_date3,cl4d.culture_date4,cl5d.culture_date5,
    ROUND(EXTRACT(EPOCH FROM (scd.sucker_collection_date - ic.initial_collection_date)) / 86400, 2) AS plant_to_sucker_duration_days,
    ROUND(EXTRACT(EPOCH FROM (cl4d.culture_date4 - scd.sucker_collection_date)) / 86400, 2) AS sucker_to_rooting_duration_days
FROM InitialCollection ic
JOIN PlantDetailsDates crd ON ic.c_uuid = crd.plantTagUUId    
JOIN SuckerCollectionDates scd ON crd.tc_plantdetails_id = scd.tc_plantdetails_id
JOIN ExplantDates eld ON eld.parentuuid = crd.plantTagUUId
JOIN CultureDates cld ON cld.parentuuid = eld.explantuuid 
JOIN LatestCultureDates cl2d ON cl2d.parentuuid2 = cld.cultureuuid
JOIN LatestCultureDates3 cl3d ON cl3d.parentuuid3 = cl2d.cultureuuid2   
JOIN LatestCultureDates4 cl4d ON cl4d.parentuuid4 = cl3d.cultureuuid3   
JOIN LatestCultureDates5 cl5d ON cl5d.parentuuid5 = cl4d.cultureuuid4       
ORDER BY ic.initial_collection_date;


====================================================================================================
getUpcomingVisit:-
public GetUpcomingVisitResponseDocument getUpcomingVisit(GetUpcomingVisitRequestDocument req) {
        GetUpcomingVisitResponseDocument getUpcomingVisitResponseDocument = GetUpcomingVisitResponseDocument.Factory.newInstance();
        GetUpcomingVisitResponse getUpcomingVisitResponse = getUpcomingVisitResponseDocument.addNewGetUpcomingVisitResponse();
        GetUpcomingVisitRequest loginRequest = req.getGetUpcomingVisitRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String serviceType = loginRequest.getServiceType();
        int client = login.getClientID();
        MAttachment attachment = null;
        String base64 = "";
        int tableId = MTable.getTable_ID("tc_farmer");
        Trx trx = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        String searchKey = loginRequest.getSearchKey();
        String selectedColumn = loginRequest.getSelectedColumn(); // Get the selected column from the request
        try {
            getCompiereService().connect();
            CompiereService m_cs = getCompiereService();
            Properties ctx = m_cs.getCtx();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "getVisitList", serviceType);
            if (err != null && err.length() > 0) {
                getUpcomingVisitResponse.setError(err);
                getUpcomingVisitResponse.setIsError(true);
                return getUpcomingVisitResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("getVisitList")) {
                getUpcomingVisitResponse.setError("Service type " + serviceType + " not configured");
                getUpcomingVisitResponse.setIsError(true);
                return getUpcomingVisitResponseDocument;
            }
            StringBuilder sql = new StringBuilder("SELECT v.tc_visit_id AS id, v.mobileno AS mobileNo, v.date AS date, f.name AS farmerName, vt.name AS visitTypeName, s.name AS Status,f.tc_farmer_id as farmerId, \n"
                    + "f.villagename AS villagename, f.address AS address, f.landmark AS landmark \n"
                    + "FROM adempiere.tc_visit v \n"
                    + "JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id \n"
                    + "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id \n"
                    + "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id \n"
                    + "WHERE v.ad_client_id = " + client + " \n"
                    + "AND s.name <> 'Cancelled' \n"
                    + "AND v.date >= CURRENT_DATE \n");
            
            // List to store search keys
            List<String> searchKeys = new ArrayList<>();

            // Check if search key is provided and append the corresponding conditions
            if (searchKey != null && !searchKey.trim().isEmpty()) {
                if (selectedColumn != null && !selectedColumn.trim().isEmpty()) {
                    // Add condition based on selected column
                    switch (selectedColumn.toLowerCase()) {
                        case "name":
                            sql.append("AND f.name ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "villagename":
                            sql.append("AND f.villagename ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "address":
                            sql.append("AND f.address ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "landmark":
                            sql.append("AND f.landmark ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "mobileno":
                            sql.append("AND v.mobileno ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "date":
                            sql.append("AND v.date::text ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "visittype":
                            sql.append("AND vt.name ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;    
                        default:
                            sql.append("AND (f.name ILIKE '%' || ? || '%' \n"
                                    + "OR f.villagename ILIKE '%' || ? || '%' \n"
                                    + "OR f.address ILIKE '%' || ? || '%' \n"
                                    + "OR v.mobileno ILIKE '%' || ? || '%' \n"
                                    + "OR v.date::text ILIKE '%' || ? || '%' \n"
                                    + "OR vt.name ILIKE '%' || ? || '%' \n"
                                    + "OR f.landmark ILIKE '%' || ? || '%') ");
                            // Add searchKey multiple times for each placeholder
                            for (int i = 0; i < 7; i++) {
                                searchKeys.add(searchKey);
                            }
                            break;
                    }
                } else {
                    // If no specific column is selected, search all columns
                    sql.append("AND (f.name ILIKE '%' || ? || '%' \n"
                            + "OR f.villagename ILIKE '%' || ? || '%' \n"
                            + "OR f.address ILIKE '%' || ? || '%' \n"
                            + "OR v.mobileno ILIKE '%' || ? || '%' \n"
                            + "OR v.date::text ILIKE '%' || ? || '%' \n"
                            + "OR vt.name ILIKE '%' || ? || '%' \n"
                            + "OR f.landmark ILIKE '%' || ? || '%') ");
                    // Add searchKey multiple times for each placeholder
                    for (int i = 0; i < 7; i++) {
                        searchKeys.add(searchKey);
                    }
                }
            }
            sql.append("ORDER BY v.date");

            // Prepare the statement and set parameters
            pstm = DB.prepareStatement(sql.toString(), null);

            // Set parameters for the prepared statement
            for (int i = 0; i < searchKeys.size(); i++) {
                pstm.setString(i + 1, searchKeys.get(i));
            }

            // Execute the query
            rs = pstm.executeQuery();

            while(rs.next()) {
                GetUpcomingVisitData listOfVisits = getUpcomingVisitResponse.addNewGetUpcomingVisitData();
                int VisitId = rs.getInt("id");
                String Name = rs.getString("farmerName");
                String VisitType = rs.getString("visitTypeName");
                String Date = rs.getString("date");
                String MobileNo = rs.getString("mobileNo");
                String villageNumber = rs.getString("villagename");
                String address = rs.getString("address");
                String landmark = rs.getString("landmark");
                int farmerId = rs.getInt("farmerId");

                listOfVisits.setVisitId(VisitId);
                listOfVisits.setFarmerName(Name);
                listOfVisits.setVisitTypeName(VisitType);
                listOfVisits.setDate(Date);
                listOfVisits.setMobileNo(MobileNo);
                listOfVisits.setAddress(address);
                listOfVisits.setVillageNumber(villageNumber != null ? villageNumber : "");
                listOfVisits.setLandmark(landmark != null ? landmark : "");
                
                attachment = MAttachment.get(ctx, tableId, farmerId);
                if(attachment != null) {
                    MAttachmentEntry[] entries = attachment.getEntries();
                    for (int i = entries.length - 1; i >= 0; i--) {
                        MAttachmentEntry entry = entries[i];
                        byte[] data = entry.getData();
                        base64 = Base64.getEncoder().encodeToString(data);
                        ImageArray1 imageArray =  listOfVisits.addNewImageArray1();
                        imageArray.setImage64(base64);
                    }   
                }else
                    listOfVisits.addNewImageArray1();
            }
            trx.commit();           
        }catch (Exception e) {
            getUpcomingVisitResponse.setError(e.getMessage());
            getUpcomingVisitResponse.setIsError(true);
        }finally {
            trx.close();
            getCompiereService().disconnect();
            closeDbCon(pstm, rs);
        }
        return getUpcomingVisitResponseDocument;
    }


    get Visit Api:-
    GetVisitResponseDocument getVisitResponseDocument = GetVisitResponseDocument.Factory.newInstance();
        GetVisitResponse getVisitResponse = getVisitResponseDocument.addNewGetVisitResponse();
        GetVisitRequest loginRequest = req.getGetVisitRequest();
        ADLoginRequest login = loginRequest.getADLoginRequest();
        String serviceType = loginRequest.getServiceType();
        int client = login.getClientID();
        Trx trx = null;
        String base64 = "";
        int tableId = MTable.getTable_ID("tc_farmer");
        MAttachment attachment = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        String searchKey = loginRequest.getSearchKey();
        String selectedColumn = loginRequest.getSelectedColumn();
        try {
            getCompiereService().connect();
            CompiereService m_cs = getCompiereService();
            Properties ctx = m_cs.getCtx();
            String trxName = Trx.createTrxName(getClass().getName() + "_");
            trx = Trx.get(trxName, true);
            trx.start();
            String err = login(login, webServiceName, "getVisitList", serviceType);
            if (err != null && err.length() > 0) {
                getVisitResponse.setError(err);
                getVisitResponse.setIsError(true);
                return getVisitResponseDocument;
            }
            if (!serviceType.equalsIgnoreCase("getVisitList")) {
                getVisitResponse.setError("Service type " + serviceType + " not configured");
                getVisitResponse.setIsError(true);
                return getVisitResponseDocument;
            }
            StringBuilder sql = new StringBuilder("SELECT f.name AS Name, vt.name AS VisitType, v.date AS Date, f.mobileno AS MobileNo,f.tc_farmer_id As farmerId, ")
                    .append("v.tc_visit_id AS ID, s.name AS status FROM adempiere.tc_visit v ")
                    .append("JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id ")
                    .append("JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id ")
                    .append("JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id ")
                    .append("WHERE v.ad_client_id = ? ");

            List<String> searchKeys = new ArrayList<>();

            if (searchKey != null && !searchKey.trim().isEmpty()) {
                if (selectedColumn != null && !selectedColumn.trim().isEmpty()) {
                    switch (selectedColumn.toLowerCase()) {
                        case "name":
                            sql.append("AND f.name ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "status":
                            sql.append("AND s.name ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "mobileno":
                            sql.append("AND f.mobileno ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "date":
                            sql.append("AND v.date::text ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;
                        case "visittype":
                            sql.append("AND vt.name ILIKE '%' || ? || '%' ");
                            searchKeys.add(searchKey);
                            break;    
                        default:
                            sql.append("AND (f.name ILIKE '%' || ? || '%' ")
                               .append("OR s.name ILIKE '%' || ? || '%' ")
                               .append("OR f.mobileno ILIKE '%' || ? || '%' ")
                               .append("OR v.date::text ILIKE '%' || ? || '%' ")
                               .append("OR vt.name ILIKE '%' || ? || '%') ");
                            for (int i = 0; i < 5; i++) {
                                searchKeys.add(searchKey);
                            }
                            break;
                    }
                } else {
                    sql.append("AND (f.name ILIKE '%' || ? || '%' ")
                       .append("OR s.name ILIKE '%' || ? || '%' ")
                       .append("OR f.mobileno ILIKE '%' || ? || '%' ")
                       .append("OR v.date::text ILIKE '%' || ? || '%' ")
                       .append("OR vt.name ILIKE '%' || ? || '%') ");
                    for (int i = 0; i < 5; i++) {
                        searchKeys.add(searchKey);
                    }
                }
            }
            sql.append("ORDER BY v.date");

            pstm = DB.prepareStatement(sql.toString(), null);
            pstm.setInt(1, client);

            for (int i = 0; i < searchKeys.size(); i++) {
                pstm.setString(i + 2, searchKeys.get(i)); // Parameters for searchKeys start from index 2
            }
            rs = pstm.executeQuery();
            while (rs.next()) {
                ListOfVisit listOfVisits = getVisitResponse.addNewListOfVisit();
                String Name = rs.getString("Name");
                String VisitType = rs.getString("VisitType");
                String Date = rs.getString("Date");
                String MobileNo = rs.getString("MobileNo");
                int VisitId = rs.getInt("ID");
                String Status = rs.getString("status");
                int farmerId = rs.getInt("farmerId");

                listOfVisits.setVisitId(VisitId);
                listOfVisits.setFarmerId(farmerId);
                listOfVisits.setName(Name);
                listOfVisits.setVisitType(VisitType);
                listOfVisits.setDate(Date);
                listOfVisits.setMobileNo(MobileNo);
                listOfVisits.setStatus(Status);

                attachment = MAttachment.get(ctx, tableId, farmerId);
                if (attachment != null) {
                    MAttachmentEntry[] entries = attachment.getEntries();
                    for (int i = entries.length - 1; i >= 0; i--) {
                        MAttachmentEntry entry = entries[i];
                        byte[] data = entry.getData();
                        base64 = Base64.getEncoder().encodeToString(data);
                        ImageArray imageArray = listOfVisits.addNewImageArray1();
                        imageArray.setImage64(base64);
                    }
                } else {
                    listOfVisits.addNewImageArray1();
                }
            }
            trx.commit();
        } catch (Exception e) {
            if (trx != null) {
                trx.rollback();
            }
            getVisitResponse.setError(e.getMessage());
            getVisitResponse.setIsError(true);
        } finally {
            DB.close(rs, pstm);
            if (trx != null) {
                trx.close();
            }
        }
        return getVisitResponseDocument;

        qedi ovmc ddho rxgr


==================================================================================================