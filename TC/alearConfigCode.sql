ALTER TABLE adempiere.tc_currentconfig ADD COLUMN alertDuration INTEGER;

@Override
protected String doIt() throws Exception {
    int clientId = Env.getAD_Client_ID(getCtx());
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int count = 0;
    
    try {
        // ============================================
        // QUERY 1: Temperature Status (with config)
        // ============================================
        String sql1 =
            "WITH config AS ( "
          + "    SELECT COALESCE(cc.alertDuration, 3) AS alert_hours "
          + "    FROM adempiere.tc_currentconfig cc "
          + "    WHERE cc.ad_client_id = ? "
          + "    LIMIT 1 "
          + ") "
          + "SELECT "
          + "    t.tc_devicedata_id AS device_id, "
          + "    MAX(t.custom_timestamp) AS last_time "
          + "FROM adempiere.tc_temperatureStatus t "
          + "CROSS JOIN config c "
          + "WHERE t.isactive = 'Y' AND t.ad_client_id = ? "
          + "GROUP BY t.tc_devicedata_id "
          + "HAVING MAX(t.custom_timestamp) < NOW() - (c.alert_hours || ' HOURS')::INTERVAL";

        pstmt = DB.prepareStatement(sql1, get_TrxName());
        pstmt.setInt(1, clientId);
        pstmt.setInt(2, clientId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            int deviceId = rs.getInt("device_id");
            Timestamp lastTime = rs.getTimestamp("last_time");
            insertAlert(deviceId, lastTime, "Temperature");
            count++;
        }
        
        DB.close(rs, pstmt);

        // ============================================
        // QUERY 2: Light (Night Mode Logic with config)
        // ============================================
        String sql2 =
            "WITH params AS ( "
          + "    SELECT "
          + "        COALESCE(cc.night_mode_start_time, '18:00:00'::time) AS nm_start, "
          + "        COALESCE(cc.night_mode_end_time, '08:00:00'::time) AS nm_end, "
          + "        COALESCE(cc.alertDuration, 3) AS alert_hours "
          + "    FROM adempiere.tc_currentconfig cc "
          + "    WHERE cc.ad_client_id = ? "
          + "    LIMIT 1 "
          + "), "
          + "time_check AS ( "
          + "    SELECT "
          + "        now() AS current_time, "
          + "        date_trunc('day', now()) + p.nm_end AS today_8am, "
          + "        p.nm_start, "
          + "        p.nm_end, "
          + "        p.alert_hours "
          + "    FROM params p "
          + "), "
          + "device_last AS ( "
          + "    SELECT "
          + "        t.tc_devicedata_id AS device_id, "
          + "        MAX(t.custom_timestamp) AS last_time "
          + "    FROM adempiere.tc_light t "
          + "    WHERE t.isactive = 'Y' "
          + "      AND t.ad_client_id = ? "
          + "    GROUP BY t.tc_devicedata_id "
          + ") "
          + "SELECT d.device_id, d.last_time "
          + "FROM device_last d "
          + "CROSS JOIN time_check tc "
          + "WHERE "
          + "    NOT ( "
          + "        tc.current_time::time >= tc.nm_start "
          + "        OR tc.current_time::time <= tc.nm_end "
          + "    ) "
          + "    AND tc.current_time >= tc.today_8am + (tc.alert_hours || ' HOURS')::INTERVAL "
          + "    AND d.last_time < tc.current_time - (tc.alert_hours || ' HOURS')::INTERVAL "
          + "ORDER BY d.last_time DESC";

        pstmt = DB.prepareStatement(sql2, get_TrxName());
        pstmt.setInt(1, clientId);
        pstmt.setInt(2, clientId);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            int deviceId = rs.getInt("device_id");
            Timestamp lastTime = rs.getTimestamp("last_time");
            insertAlert(deviceId, lastTime, "Light");
            count++;
        }

    } finally {
        DB.close(rs, pstmt);
    }

    return "Total Alerts Created: " + count;
}

// Update insertAlert method to include sensor type
private void insertAlert(int deviceId, Timestamp lastTime, String sensorType) throws Exception {
    
    int clientId = Env.getAD_Client_ID(getCtx());
    
    // Check if alert already exists for this device
    String checkSql = 
        "SELECT tc_alertdevices_id FROM adempiere.tc_alertdevices " +
        "WHERE tc_devicedata_id = ? AND isacknowledge = 'N' AND ad_client_id = ?";
    
    PreparedStatement checkStmt = null;
    ResultSet checkRs = null;
    
    try {
        checkStmt = DB.prepareStatement(checkSql, get_TrxName());
        checkStmt.setInt(1, deviceId);
        checkStmt.setInt(2, clientId);
        checkRs = checkStmt.executeQuery();
        
        if (checkRs.next()) {
            // Alert already exists, skip
            return;
        }
        
    } finally {
        DB.close(checkRs, checkStmt);
    }
    
    // Get device details
    String deviceSql = 
        "SELECT d.value, d.m_locatortype_id " +
        "FROM adempiere.tc_devicedata d " +
        "WHERE d.tc_devicedata_id = ?";
    
    PreparedStatement deviceStmt = null;
    ResultSet deviceRs = null;
    
    String deviceName = "";
    int locatorTypeId = 0;
    
    try {
        deviceStmt = DB.prepareStatement(deviceSql, get_TrxName());
        deviceStmt.setInt(1, deviceId);
        deviceRs = deviceStmt.executeQuery();
        
        if (deviceRs.next()) {
            deviceName = deviceRs.getString("value");
            locatorTypeId = deviceRs.getInt("m_locatortype_id");
        }
        
    } finally {
        DB.close(deviceRs, deviceStmt);
    }
    
    // Insert new alert
    String insertSql = 
        "INSERT INTO adempiere.tc_alertdevices " +
        "(tc_alertdevices_id, ad_client_id, ad_org_id, isactive, created, createdby, " +
        "updated, updatedby, tc_devicedata_id, m_locatortype_id, sensortype, " +
        "isacknowledge, tc_alertdevices_uu) " +
        "VALUES (nextval('tc_alertdevices_sq'), ?, 0, 'Y', now(), ?, now(), ?, ?, ?, ?, 'N', uuid_generate_v4())";
    
    PreparedStatement insertStmt = null;
    
    try {
        insertStmt = DB.prepareStatement(insertSql, get_TrxName());
        insertStmt.setInt(1, clientId);
        insertStmt.setInt(2, Env.getAD_User_ID(getCtx()));
        insertStmt.setInt(3, Env.getAD_User_ID(getCtx()));
        insertStmt.setInt(4, deviceId);
        insertStmt.setInt(5, locatorTypeId);
        insertStmt.setString(6, sensorType);  // "Temperature" or "Light"
        
        insertStmt.executeUpdate();
        
    } finally {
        DB.close(insertStmt);
    }
}