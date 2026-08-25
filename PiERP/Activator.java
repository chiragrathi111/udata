package com.pipra.webservices.custom;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

public class Activator implements BundleActivator {
    @Override
    public void start(BundleContext context) throws Exception {
        System.out.println("Custom CXF REST Services bundle starting (WAB mode)...");
        new Thread(() -> {
            while (true) {
                try {
                    java.sql.Connection conn = org.compiere.util.DB.getConnectionRO();
                    if (conn != null) {
                        conn.close();
                        break;
                    }
                } catch (Exception e) {
                    // ignore
                }
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ie) {}
            }
            registerWebServices();
        }).start();
    }

    @Override
    public void stop(BundleContext context) throws Exception {
        System.out.println("Custom CXF REST Services bundle stopping...");
    }

    private void registerWebServices() {
        System.out.println("Registering custom web services in Application Dictionary...");
        String[][] pairs = {
            {"roleConfig", "roleConfig"},
            {"poList", "poli"},
            {"poData", "poData"},
            {"createMR", "createMR"},
            {"mrList", "mrList"},
            {"mrData", "mrData"},
            {"mrFailed", "mrFailed"},
            {"pIList", "pIList"},
            {"pIDetails", "pIDetails"},
            {"pIQtyChange", "pIQtyChange"},
            {"sOList", "sOList"},
            {"sODetail", "sODetail"},
            {"createSC", "createSC"},
            {"generatePalletDetails", "generatePalletDetails"},
            {"getQRData", "getQRData"},
            {"linkOrUnlinkPallet", "linkOrUnlinkPallet"},
            {"locatorSuggestion", "locatorSuggestion"},
            {"qcCheckedList", "qcCheckedList"},
            {"qcCheckedData", "qcCheckedData"},
            {"markMRQcChecked", "markMRQcChecked"},
            {"updateMr", "updateMr"},
            {"directToCustomer", "directToCustomer"},
            {"wareList", "wareList"},
            {"soOrderStatus", "soOrderStatus"},
            {"getMInoutForCOrder", "getMInoutForCOrder"},
            {"generateProductLabel", "generateProductLabel"},
            {"getLabelData", "getLabelData"},
            {"putAway", "putAway"},
            {"getLocatorDeatilsById", "getLocatorDeatilsById"},
            {"putAwayList", "putAwayList"},
            {"putAwayLabour", "putAwayLabour"},
            {"pickListLabour", "pickListLabour"},
            {"pickDetailLabour", "pickDetailLabour"},
            {"markSOReadyToPick", "markSOReadyToPick"},
            {"getShipperForClient", "getShipperForClient"},
            {"updateShipmentCustomer", "updateShipmentCustomer"},
            {"createNotice", "createNotice"},
            {"putAwayDetail", "putAwayDetail"},
            {"getMrComponents", "getMrComponents"},
            {"CompleteOrder", "CompleteOrder"},
            {"getUsersList", "getUsersList"},
            {"uploadfile", "uploadfile"},
            {"switchState", "switchState"},
            {"itemInout", "itemInout"}
        };

        int webserviceId = org.compiere.util.DB.getSQLValue(null,
            "SELECT ws_webservice_id FROM ws_webservice WHERE value = 'PipraCustomWebservice'");
        if (webserviceId <= 0) {
            webserviceId = 200002; // fallback
        }

        int methodSeqId = org.compiere.util.DB.getSQLValue(null,
            "SELECT ad_sequence_id FROM ad_sequence WHERE name = 'WS_WebServiceMethod'");
        if (methodSeqId <= 0) {
            methodSeqId = 53257; // fallback
        }

        int typeSeqId = org.compiere.util.DB.getSQLValue(null,
            "SELECT ad_sequence_id FROM ad_sequence WHERE name = 'WS_WebServiceType'");
        if (typeSeqId <= 0) {
            typeSeqId = 53258; // fallback
        }

        String[] roleNames = {"GardenWorld Admin", "Web Service Execution"};

        for (String[] pair : pairs) {
            String methodVal = pair[0];
            String typeVal = pair[1];
            try {
                // 1. Get or create ws_webservicemethod
                int methodId = org.compiere.util.DB.getSQLValue(null,
                    "SELECT ws_webservicemethod_id FROM ws_webservicemethod WHERE ws_webservice_id = ? AND value = ?",
                    webserviceId, methodVal);
                
                if (methodId <= 0) {
                    methodId = org.compiere.util.DB.getSQLValue(null, "SELECT nextidfunc(?, 'N')", methodSeqId);
                    String uuid = java.util.UUID.randomUUID().toString();
                    org.compiere.util.DB.executeUpdateEx(
                        "INSERT INTO ws_webservicemethod (ad_client_id, ad_org_id, isactive, created, createdby, updated, updatedby, ws_webservice_id, ws_webservicemethod_id, ws_webservicemethod_uu, name, value) VALUES (0, 0, 'Y', now(), 100, now(), 100, ?, ?, ?, ?, ?)",
                        new Object[]{webserviceId, methodId, uuid, methodVal, methodVal},
                        null);
                }

                // 2. Get or create ws_webservicetype
                int typeId = org.compiere.util.DB.getSQLValue(null,
                    "SELECT ws_webservicetype_id FROM ws_webservicetype WHERE ws_webservice_id = ? AND ws_webservicemethod_id = ? AND value = ?",
                    webserviceId, methodId, typeVal);

                if (typeId <= 0) {
                    typeId = org.compiere.util.DB.getSQLValue(null, "SELECT nextidfunc(?, 'N')", typeSeqId);
                    String uuid = java.util.UUID.randomUUID().toString();
                    org.compiere.util.DB.executeUpdateEx(
                        "INSERT INTO ws_webservicetype (ad_client_id, ad_org_id, isactive, created, createdby, updated, updatedby, ws_webservice_id, ws_webservicemethod_id, ws_webservicetype_id, ws_webservicetype_uu, name, value) VALUES (0, 0, 'Y', now(), 100, now(), 100, ?, ?, ?, ?, ?)",
                        new Object[]{webserviceId, methodId, typeId, uuid, typeVal, typeVal},
                        null);
                }

                // 3. Grant access to roles
                for (String roleName : roleNames) {
                    int roleId = org.compiere.util.DB.getSQLValue(null,
                        "SELECT ad_role_id FROM ad_role WHERE name = ? AND isactive = 'Y' ORDER BY ad_role_id LIMIT 1", roleName);
                    if (roleId <= 0) {
                        continue;
                    }
                    
                    int roleClientId = org.compiere.util.DB.getSQLValue(null,
                        "SELECT ad_client_id FROM ad_role WHERE ad_role_id = ?", roleId);
                    if (roleClientId < 0) {
                        roleClientId = 0;
                    }

                    boolean hasAccess = org.compiere.util.DB.getSQLValue(null,
                        "SELECT 1 FROM ws_webservicetypeaccess WHERE ad_role_id = ? AND ws_webservicetype_id = ?",
                        roleId, typeId) > 0;
                    
                    if (!hasAccess) {
                        String uuid = java.util.UUID.randomUUID().toString();
                        org.compiere.util.DB.executeUpdateEx(
                            "INSERT INTO ws_webservicetypeaccess (ad_client_id, ad_org_id, ad_role_id, isactive, isreadwrite, created, createdby, updated, updatedby, ws_webservicetype_id, ws_webservicetypeaccess_uu) VALUES (?, 0, ?, 'Y', 'Y', now(), 100, now(), 100, ?, ?)",
                            new Object[]{roleClientId, roleId, typeId, uuid},
                            null);
                    }
                }
            } catch (Exception e) {
                System.err.println("Error registering web service method " + methodVal + ": " + e.getMessage());
            }
        }
        System.out.println("Custom web services registration complete.");
    }
}
