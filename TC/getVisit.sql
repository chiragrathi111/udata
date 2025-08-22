@Override
public GetVisitResponseDocument getVisit(GetVisitRequestDocument req) {
    GetVisitResponseDocument getVisitResponseDocument = GetVisitResponseDocument.Factory.newInstance();
    GetVisitResponse getVisitResponse = getVisitResponseDocument.addNewGetVisitResponse();
    GetVisitRequest loginRequest = req.getGetVisitRequest();
    ADLoginRequest login = loginRequest.getADLoginRequest();
    String serviceType = loginRequest.getServiceType().trim();
    int clientId = login.getClientID();

    int count = 0;
    int tableId = MTable.getTable_ID(TABLE_FARMER);
    String searchKey = loginRequest.getSearchKey();
    int pageSize = loginRequest.getPageSize();
    int pageNumber = loginRequest.getPageNumber();
    int offset = (pageNumber - 1) * pageSize;

    Trx trx = null;

    try {
        // Connect to Compiere service
        getCompiereService().connect();
        CompiereService m_cs = getCompiereService();
        Properties ctx = m_cs.getCtx();

        // Create transaction
        String trxName = Trx.createTrxName(getClass().getName() + "_");
        trx = Trx.get(trxName, true);
        trx.start();

        // Login validation
        String err = login(login, webServiceName, "getVisitList", serviceType);
        if (err != null && !err.isEmpty()) {
            getVisitResponse.setError(err);
            getVisitResponse.setIsError(true);
            return getVisitResponseDocument;
        }

        if (!serviceType.equalsIgnoreCase("getVisitList")) {
            getVisitResponse.setError("Service type " + serviceType + " not configured");
            getVisitResponse.setIsError(true);
            return getVisitResponseDocument;
        }

        // Prepare filter lists
        List<String> farmerList = new ArrayList<>();
        List<String> statusList = new ArrayList<>();
        List<String> mobilenoList = new ArrayList<>();
        List<String> dateList = new ArrayList<>();
        List<String> visitTypeList = new ArrayList<>();

        for (Filter filter : loginRequest.getFiltersArray()) {
            switch (filter.getKey().toLowerCase()) {
                case "farmername":
                    farmerList.add(filter.getValue());
                    break;
                case "status":
                    statusList.add(filter.getValue());
                    break;
                case "mobileno":
                    mobilenoList.add(filter.getValue());
                    break;
                case "date":
                    dateList.add(filter.getValue());
                    break;
                case "visittypename":
                    visitTypeList.add(filter.getValue());
                    break;
            }
        }

        // Build SQL
        StringBuilder sql = new StringBuilder(
            "SELECT v.cycleNo AS cycleNo, f.name AS farmerName, vt.name AS VisitType, " +
            "v.date AS Date, f.mobileno AS MobileNo, f.tc_farmer_id AS farmerId, " +
            "v.tc_visit_id AS ID, s.name AS status, COUNT(*) OVER () AS totalCount, " +
            "v.visitdone AS visitdone " +
            "FROM adempiere.tc_visit v " +
            "JOIN adempiere.tc_farmer f ON f.tc_farmer_id = v.tc_farmer_id " +
            "JOIN adempiere.tc_status s ON s.tc_status_id = v.tc_status_id " +
            "JOIN adempiere.tc_visittype vt ON vt.tc_visittype_id = v.tc_visittype_id " +
            "JOIN adempiere.ad_user u ON u.ad_user_id = v.createdby " +
            "WHERE v.ad_client_id = ? AND s.name <> 'Cancelled' AND u.name = ? "
        );

        // Append filters with placeholders
        if (!farmerList.isEmpty()) {
            sql.append(" AND f.name IN (").append(String.join(",", Collections.nCopies(farmerList.size(), "?"))).append(")");
        }
        if (!statusList.isEmpty()) {
            sql.append(" AND s.name IN (").append(String.join(",", Collections.nCopies(statusList.size(), "?"))).append(")");
        }
        if (!mobilenoList.isEmpty()) {
            sql.append(" AND f.mobileno IN (").append(String.join(",", Collections.nCopies(mobilenoList.size(), "?"))).append(")");
        }
        if (!dateList.isEmpty()) {
            sql.append(" AND v.date IN (").append(String.join(",", Collections.nCopies(dateList.size(), "?"))).append(")");
        }
        if (!visitTypeList.isEmpty()) {
            sql.append(" AND vt.name IN (").append(String.join(",", Collections.nCopies(visitTypeList.size(), "?"))).append(")");
        }

        // Search key
        if (searchKey != null && !searchKey.trim().isEmpty()) {
            sql.append(" AND (f.name ILIKE ? OR s.name ILIKE ? OR v.mobileno ILIKE ? OR vt.name ILIKE ?)");
        }

        sql.append(" ORDER BY v.tc_visit_id DESC LIMIT ? OFFSET ?");

        // Prepare and execute query safely
        try (PreparedStatement pstm = DB.prepareStatement(sql.toString(), trx.getTrxName())) {
            int paramIndex = 1;
            pstm.setInt(paramIndex++, clientId);
            pstm.setString(paramIndex++, login.getUser());

            // Bind filter values
            for (String val : farmerList) pstm.setString(paramIndex++, val);
            for (String val : statusList) pstm.setString(paramIndex++, val);
            for (String val : mobilenoList) pstm.setString(paramIndex++, val);
            for (String val : dateList) pstm.setString(paramIndex++, val);
            for (String val : visitTypeList) pstm.setString(paramIndex++, val);

            // Bind search key
            if (searchKey != null && !searchKey.trim().isEmpty()) {
                for (int i = 0; i < 4; i++) {
                    pstm.setString(paramIndex++, "%" + searchKey + "%");
                }
            }

            // Pagination params
            pstm.setInt(paramIndex++, pageSize);
            pstm.setInt(paramIndex++, offset);

            try (ResultSet rs = pstm.executeQuery()) {
                if (!rs.isBeforeFirst()) {
                    getVisitResponse.setIsError(false);
                    getVisitResponse.setCount(0);
                    getVisitResponse.addNewListOfVisit();
                    return getVisitResponseDocument;
                }

                while (rs.next()) {
                    ListOfVisit listOfVisits = getVisitResponse.addNewListOfVisit();
                    listOfVisits.setVisitId(rs.getInt("ID"));
                    listOfVisits.setFarmerId(rs.getInt("farmerId"));
                    listOfVisits.setName(rs.getString("farmerName"));
                    listOfVisits.setVisitType(rs.getString("VisitType"));
                    listOfVisits.setDate(rs.getString("Date"));
                    listOfVisits.setMobileNo(rs.getString("MobileNo"));
                    listOfVisits.setStatus(rs.getString("status"));
                    listOfVisits.setVisitDone(rs.getBoolean("visitdone"));
                    listOfVisits.setCycleNo(rs.getInt("cycleNo"));

                    count = rs.getInt("totalCount");

                    // Attachment fetching
                    MAttachment attachment = MAttachment.get(ctx, tableId, rs.getInt("farmerId"));
                    if (attachment != null && attachment.getEntries().length > 0) {
                        ImageArray imageArray = listOfVisits.addNewImageArray1();
                        imageArray.setImageIndexId(attachment.getEntries().length - 1);
                    } else {
                        listOfVisits.addNewImageArray1();
                    }
                }
            }
        }

        trx.commit();
        getVisitResponse.setCount(count);
        getVisitResponse.setTableId(tableId);

    } catch (Exception e) {
        if (trx != null) {
            trx.rollback();
        }
        getVisitResponse.setError(e.getMessage());
        getVisitResponse.setIsError(true);
    } finally {
        if (trx != null) {
            trx.close();
        }
        getCompiereService().disconnect();
    }

    return getVisitResponseDocument;
}
