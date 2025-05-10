@Override
    public Response generateReport() {
        Connection conn = null;
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/user_images.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            System.out.println("Successfully");
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }
            conn = DB.getConnection();

            // Prepare parameters (if required)
            HashMap<String, Object> parameters = new HashMap<>();
            parameters.put("AD_Client_ID", 1000000);  // Pass iDempiere Client ID

            // Fill the report with data
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, conn);
            
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);

            return Response.ok(outputStream.toByteArray(), "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }
    }


    }


    Jasper Download through java code

    <artifactItem>
                                    <groupId>net.sf.jasperreports</groupId>
                                    <artifactId>jasperreports</artifactId>
                                    <version>6.20.6</version>
                                </artifactItem>





@Override
    public Response generateReport() {
        Connection conn = null;
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PreparedStatement pstmt = null;
        List<Imagemodel> userImages = new ArrayList<>();
        HashMap<String, Object> parameters = new HashMap<>();
       
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/user.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }
            conn = DB.getConnection();
            parameters.put("Name", "Chirag");

            // Fill the report with data
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters, conn);
            
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);

            return Response.ok(outputStream.toByteArray(), "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }
    }

    this java code is response come in blank because 
    jasper side i not use query design i assign parameter 
    key Name and value i use hardcode in my java code 
    but this data not coming i show only blank screen

    i use scenario its working in jasper or not please guide me and gave code      







====================================================================================
@Override
    public Response generateReport() {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        HashMap<String, Object> parameters = new HashMap<>();
        String base65 = "",base66 = "";       
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/user.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }
            
            String sql = "SELECT u.name,img.binarydata\n"
                    + "FROM adempiere.ad_user u\n"
                    + "JOIN adempiere.ad_attachment img ON u.ad_user_id = img.record_id AND img.ad_table_id = 114\n"
                    + "WHERE u.ad_client_id = 1000000 ORDER BY img.created deSC LIMIT 1;";
            
            pstmt = DB.prepareStatement(sql, null);
            rs = pstmt.executeQuery();

           while (rs.next()) {
               String userName = rs.getString("name");
               byte[] zipData = rs.getBytes("binarydata");
               byte[] imageData = extractImageFromZip(zipData);
               
               base65 = Base64.getEncoder().encodeToString(zipData);
                System.out.println(base65);
                
                System.out.println("++++++++++++++++++++++");
                
                base66 = Base64.getEncoder().encodeToString(imageData);
                System.out.println(base66);
               
               parameters.put("Name", userName);
               parameters.put("Img", base66);

            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters,new JREmptyDataSource());
            
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);

            return Response.ok(outputStream.toByteArray(), "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }finally {
            DB.close(rs, pstmt);
        }
    }

        public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
            ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
            ZipInputStream zis = new ZipInputStream(bis);
            ZipEntry entry;

            while ((entry = zis.getNextEntry()) != null) {
                if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) { // Extract only image files
                    ByteArrayOutputStream bos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = zis.read(buffer)) > 0) {
                        bos.write(buffer, 0, len);
                    }
                    zis.closeEntry();
                    zis.close();
                    return bos.toByteArray(); // Return extracted image
                }
            }
            zis.close();
            return null;
        }

This code is working for name and image both but i getting only one data
i have 7 data i want all 7 data
jasper report using query field show all name but not come image because image is zip format their reason i use java code
and its working but getting only one record 
i want all name and image getting
please give code or modify
then you understand my probelm why not direct use query in jasper because image not getting
please give me code and suggest curretly use map
inside map can i added list array so all data come if possible give java code or give other code your according but full fill my requirement        


============================--------------------------=======================================------------------
JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
        
        if (jasperReport == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Jasper file not found: " + jasperReport)
                    .build();
        }
        
        String sql = "SELECT u.name,img.binarydata\n"
                + "FROM adempiere.ad_user u\n"
                + "JOIN adempiere.ad_attachment img ON u.ad_user_id = img.record_id AND img.ad_table_id = 114\n"
                + "WHERE u.ad_client_id = 1000000 ORDER BY img.created deSC LIMIT 1;";
        
        pstmt = DB.prepareStatement(sql, null);
        rs = pstmt.executeQuery();

       while (rs.next()) {
           String userName = rs.getString("name");
           byte[] zipData = rs.getBytes("binarydata");
           byte[] imageData = extractImageFromZip(zipData);
           
           base65 = Base64.getEncoder().encodeToString(zipData);
            System.out.println(base65);
            
            System.out.println("++++++++++++++++++++++");
            
            base66 = Base64.getEncoder().encodeToString(imageData);
            System.out.println(base66);
           
           parameters.put("Name", userName);
           parameters.put("Img", base66);

        JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parameters,new JREmptyDataSource());
        
        JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);

        return Response.ok(outputStream.toByteArray(), "application/pdf")
                .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                .build();

    } catch (Exception e) {
        return Response.serverError()
                .entity("Error generating report: " + e.getMessage())
                .build();
    }finally {
        DB.close(rs, pstmt);
    }
}

    public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
        ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
        ZipInputStream zis = new ZipInputStream(bis);
        ZipEntry entry;

        while ((entry = zis.getNextEntry()) != null) {
            if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) { // Extract only image files
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = zis.read(buffer)) > 0) {
                    bos.write(buffer, 0, len);
                }
                zis.closeEntry();
                zis.close();
                return bos.toByteArray(); // Return extracted image
            }
        }
        zis.close();
        return null;
    }

***********************************************************************************************
User list is working fine:-

@Override
    public Response generateReport() {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> parametersList = new ArrayList<>();       
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/user.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }           
            String sql = "SELECT u.name FROM adempiere.ad_user u WHERE u.ad_client_id = 1000000 ORDER BY u.created DESC;";
            
            pstmt = DB.prepareStatement(sql, null);
            rs = pstmt.executeQuery();
           while (rs.next()) {
               HashMap<String, Object> parameters = new HashMap<>();
               String userName = rs.getString("name");
               parameters.put("name", userName);
               parametersList.add(parameters);
           }
           
           if (parametersList.isEmpty()) {
               System.out.println("No data found!"); // Debugging
               return Response.status(Response.Status.NO_CONTENT)
                       .entity("No data available for the report")
                       .build();
           }
           System.out.println("Total users added: " + parametersList.size()); // Debugging
           
           JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);

           HashMap<String, Object> reportParams = new HashMap<>();
           reportParams.put("Title", "User Report");
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams,dataSource);
            
           
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
            
            return Response.ok(outputStream.toByteArray(), "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }finally {
            DB.close(rs, pstmt);
        }
    } 

##########################################################################################################
name and image both are working fine:-

@Override
    public Response generateReport() {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> parametersList = new ArrayList<>();    
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/user.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }
            String sql = "SELECT u.name,img.binarydata\n"
                    + "FROM adempiere.ad_user u\n"
                    + "JOIN adempiere.ad_attachment img ON u.ad_user_id = img.record_id AND img.ad_table_id = 114\n"
                    + "WHERE u.ad_client_id = 1000000 ORDER BY img.created deSC ;";
            
            pstmt = DB.prepareStatement(sql, null);
            rs = pstmt.executeQuery();
           while (rs.next()) {
               HashMap<String, Object> parameters = new HashMap<>();
               String userName = rs.getString("name");
               byte[] zipData = rs.getBytes("binarydata");
               byte[] imageData = extractImageFromZip(zipData);
               
               parameters.put("name", userName);
               parameters.put("binarydata", imageData);

               parametersList.add(parameters);
           }
           
           if (parametersList.isEmpty()) {
               System.out.println("No data found!"); // Debugging
               return Response.status(Response.Status.NO_CONTENT)
                       .entity("No data available for the report")
                       .build();
           }
           
           JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);

           // Ensure the parameters map is NOT null
           HashMap<String, Object> reportParams = new HashMap<>();
           reportParams.put("Title", "User Report");
           
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams,dataSource);
           
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
            
            return Response.ok(outputStream.toByteArray(), "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"Report.pdf\"")
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }finally {
            DB.close(rs, pstmt);
        }
    }

        public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
            ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
            ZipInputStream zis = new ZipInputStream(bis);
            ZipEntry entry;

            while ((entry = zis.getNextEntry()) != null) {
                if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) { // Extract only image files
                    ByteArrayOutputStream bos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = zis.read(buffer)) > 0) {
                        bos.write(buffer, 0, len);
                    }
                    zis.closeEntry();
                    zis.close();
                    return bos.toByteArray(); // Return extracted image
                }
            }
            zis.close();
            return null;
        }       

JAsper Source code:-

<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Jaspersoft Studio version 6.20.6.final using JasperReports Library version 6.20.6-5c96b6aa8a39ac1dc6b6bea4b81168e16dd39231  -->
<jasperReport xmlns="http://jasperreports.sourceforge.net/jasperreports" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports http://jasperreports.sourceforge.net/xsd/jasperreport.xsd" name="user" pageWidth="595" pageHeight="842" columnWidth="555" leftMargin="20" rightMargin="20" topMargin="20" bottomMargin="20" uuid="9eb18f70-e1b0-40e8-a34a-9ca4127a364a">
    <property name="com.jaspersoft.studio.data.sql.tables" value=""/>
    <property name="com.jaspersoft.studio.data.defaultdataadapter" value="vinay111.jrdax"/>
    <property name="com.jaspersoft.studio.data.sql.SQLQueryDesigner.sash.w1" value="256"/>
    <property name="com.jaspersoft.studio.data.sql.SQLQueryDesigner.sash.w2" value="732"/>
    <parameter name="Name" class="java.lang.String"/>
    <parameter name="Image" class="java.lang.Byte" isForPrompting="false"/>
    <parameter name="Img" class="java.lang.String"/>
    <queryString language="SQL">
        <![CDATA[]]>
    </queryString>
    <field name="name" class="java.lang.String"/>
    <field name="binarydata" class="byte[]"/>
    <background>
        <band splitType="Stretch"/>
    </background>
    <title>
        <band height="33" splitType="Stretch">
            <staticText>
                <reportElement x="20" y="0" width="260" height="30" uuid="94ab255f-3f48-4ad5-89ff-eed9655203e4"/>
                <textElement textAlignment="Left" verticalAlignment="Middle">
                    <font size="20" isBold="true"/>
                </textElement>
                <text><![CDATA[User]]></text>
            </staticText>
        </band>
    </title>
    <detail>
        <band height="523" splitType="Stretch">
            <image scaleImage="FillFrame" onErrorType="Blank">
                <reportElement x="0" y="3" width="550" height="519" uuid="679d88b0-e201-456c-8748-50af86fa7e19"/>
                <imageExpression><![CDATA[$F{binarydata}]]></imageExpression>
            </image>
            <textField>
                <reportElement x="10" y="180" width="530" height="80" uuid="34a40200-2931-4b9f-a1e0-35cbd5212a89"/>
                <textElement textAlignment="Center" verticalAlignment="Middle">
                    <font size="36" isBold="true" pdfFontName="Helvetica-Bold"/>
                </textElement>
                <textFieldExpression><![CDATA[$F{name}]]></textFieldExpression>
            </textField>
            <break>
                <reportElement x="0" y="522" width="97" height="1" uuid="885c34aa-ad55-43ec-80bc-93d98ab999c7">
                    <property name="com.jaspersoft.studio.unit.y" value="px"/>
                </reportElement>
            </break>
        </band>
    </detail>
</jasperReport>

=======================================================================================================================
Working:-

ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> parametersList = new ArrayList<>();        
        try {
            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/StonexL.jrxml";
            JasperCompileManager.compileReportToFile(jasperFilePath);
            
            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
            
            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Jasper file not found: " + jasperReport)
                        .build();
            }
//            String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.reporttitle AS report_title,pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
//                  + "prt.pi_report_task_ID AS task_id,prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,\n"
//                  + "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
//                  + "prsf.inspection AS inspection,\n"
//                  + "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
//                  + "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
//                  + "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
//                  + "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
//                  + "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
//                  + "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
//                  + "WHERE  pr.pi_report_id =1000047 ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,\n"
//                  + "prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;";
            
            String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.reporttitle AS report_title,pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
                    + "prt.pi_report_task_ID AS task_id,prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,adret.binarydata AS task_binarydata,\n"
                    + "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
                    + "adrest.binarydata AS subtask_binarydata,prsf.inspection AS inspection,\n"
                    + "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
                    + "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
                    + "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
                    + "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
                    + "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
                    + "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
                    + "left JOIN adempiere.ad_attachment adret on adret.ad_table_id = 1000018 and adret.record_id = prt.pi_report_task_id\n"
                    + "left JOIN adempiere.ad_attachment adrest on adrest.ad_table_id = 1000019 and adrest.record_id = prs.pi_report_subtask_id\n"
                    + "WHERE  pr.pi_report_id =1000094 ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;\n"
                    + "";
            
            pstmt = DB.prepareStatement(sql, null);
            rs = pstmt.executeQuery();

           while (rs.next()) {
               HashMap<String, Object> parameters = new HashMap<>();
               byte[] report_binarydata = null;
               byte[] task_binarydata = null;
               byte[] subtask_binarydata = null;
               
               int report_id = rs.getInt("report_id");
               String report_title = rs.getString("report_title");
               
               try {
                   byte[] zipData = rs.getBytes("report_binarydata");
                   if (zipData != null) {
                       report_binarydata = extractImageFromZip(zipData);
                   }
               } catch (Exception e) {
                   System.err.println("Error extracting report image: " + e.getMessage());
               }
               
               try {
                   byte[] zipDataT = rs.getBytes("task_binarydata");
                   if (zipDataT != null) {
                       task_binarydata = extractImageFromZip(zipDataT);
                   }
               } catch (Exception e) {
                   System.err.println("Error extracting Task image: " + e.getMessage());
               }
               
               try {
                   byte[] zipDataS = rs.getBytes("subtask_binarydata");
                   if (zipDataS != null) {
                       subtask_binarydata = extractImageFromZip(zipDataS);
                   }
               } catch (Exception e) {
                   System.err.println("Error extracting Sub Task image: " + e.getMessage());
               }
               
               int task_id = rs.getInt("task_id");
               String task_title = rs.getString("task_title");
               
               int subtask_id = rs.getInt("subtask_id");
               String subtask_title = rs.getString("subtask_title");
               
               int inspection = rs.getInt("inspection");
               
               int field_id = rs.getInt("field_id");
               String field_name = rs.getString("field_name");
               
               parameters.put("report_id", report_id);
               parameters.put("report_title", report_title + " - " + report_id);
               parameters.put("report_binarydata", report_binarydata);
               parameters.put("task_id", task_id);
               parameters.put("task_title", task_title + " - " + task_id);
               parameters.put("task_binarydata", task_binarydata);
               parameters.put("subtask_id", subtask_id);
               parameters.put("subtask_title", subtask_title + " - " + subtask_id);
               parameters.put("subtask_binarydata", subtask_binarydata);
               parameters.put("inspection", inspection);
               parameters.put("field_id", field_id);
               parameters.put("field_name", field_name + " - " + field_id);

               parametersList.add(parameters);
           }
           
           if (parametersList.isEmpty()) {
               System.out.println("No data found!");
               return Response.status(Response.Status.NO_CONTENT)
                       .entity("No data available for the report")
                       .build();
           }
           JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);

           HashMap<String, Object> reportParams = new HashMap<>();
           reportParams.put("Title", "Stonex Report");

            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams,dataSource);
            
            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
            
//            return Response.ok(outputStream.toByteArray(), "application/pdf")
//                    .header("Content-Disposition", "attachment; filename=\"stonexReport.pdf\"")
//                    .build();
            try {
                Path debugPath = Paths.get("/home/chirag/Stonex_report.pdf");
                Files.write(debugPath, outputStream.toByteArray());
                System.out.println("DEBUG: PDF saved to " + debugPath.toString());
            } catch (Exception e) {
                System.err.println("DEBUG: Failed to save PDF: " + e.getMessage());
            }
            
            return Response.ok(outputStream.toByteArray())
                    .header("Content-Type", "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
                    .header("Content-Length", outputStream.size())
                    .build();

        } catch (Exception e) {
            return Response.serverError()
                    .entity("Error generating report: " + e.getMessage())
                    .build();
        }finally {
            DB.close(rs, pstmt);
        }
    }

    -------------------------------------------------+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    For Config

    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    Properties ctx = Env.getCtx();
    String trxName = null;
    
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    List<Map<String, Object>> parametersList = new ArrayList<>();       
    try {
        
        PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
        if(po != null && po.get_ID() ==0)
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
                    .status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString()).build();

//        String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/StonexL.jrxml";
//        JasperCompileManager.compileReportToFile(jasperFilePath);
       
//        JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
        JasperReport jasperReport = JasperCompileManager.compileReport(po.getAttachment().getEntry(0).getInputStream());

       
        if (jasperReport == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Jasper file not found: " + jasperReport)
                    .build();
        }
       
        String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.reporttitle AS report_title,pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
                + "prt.pi_report_task_ID AS task_id,prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,adret.binarydata AS task_binarydata,\n"
                + "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
                + "adrest.binarydata AS subtask_binarydata,prsf.inspection AS inspection,prsf.comments AS field_comments,prsf.config AS field_config,\n"
                + "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
                + "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
                + "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
                + "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
                + "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
                + "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
                + "left JOIN adempiere.ad_attachment adret on adret.ad_table_id = 1000018 and adret.record_id = prt.pi_report_task_id\n"
                + "left JOIN adempiere.ad_attachment adrest on adrest.ad_table_id = 1000019 and adrest.record_id = prs.pi_report_subtask_id\n"
                + "WHERE  pr.pi_report_id ="+reportId+" ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;\n"
                + "";
       
        pstmt = DB.prepareStatement(sql, null);
        rs = pstmt.executeQuery();
       while (rs.next()) {
           HashMap<String, Object> parameters = new HashMap<>();
           byte[] report_binarydata = null;
           byte[] task_binarydata = null;
           byte[] subtask_binarydata = null;
          
           int report_id = rs.getInt("report_id");
           String report_title = rs.getString("report_title");
          
           try {
               byte[] zipData = rs.getBytes("report_binarydata");
               if (zipData != null) {
                   report_binarydata = extractImageFromZip(zipData);
               }
           } catch (Exception e) {
               System.err.println("Error extracting report image: " + e.getMessage());
           }
          
           try {
               byte[] zipDataT = rs.getBytes("task_binarydata");
               if (zipDataT != null) {
                   task_binarydata = extractImageFromZip(zipDataT);
               }
           } catch (Exception e) {
               System.err.println("Error extracting Task image: " + e.getMessage());
           }
          
           try {
               byte[] zipDataS = rs.getBytes("subtask_binarydata");
               if (zipDataS != null) {
                   subtask_binarydata = extractImageFromZip(zipDataS);
               }
           } catch (Exception e) {
               System.err.println("Error extracting Sub Task image: " + e.getMessage());
           }
          
           int task_id = rs.getInt("task_id");
           String task_title = rs.getString("task_title");
          
           int subtask_id = rs.getInt("subtask_id");
           String subtask_title = rs.getString("subtask_title");
          
           int inspection = rs.getInt("inspection");
          
           int field_id = rs.getInt("field_id");
           String field_name = rs.getString("field_name");
          
           String field_comments = rs.getString("field_comments");
        // Handle NULL and empty strings properly
           if (field_comments == null) {
               field_comments = ""; // Or "No comments" if you prefer
           } else {
               field_comments = field_comments.trim();
           }
          
           String field_config = rs.getString("field_config");
           if (field_config == null) {
               field_config = ""; // Or "No comments" if you prefer
           } else {
               field_config = field_config.trim();
           }
          
           parameters.put("report_id", report_id);
           parameters.put("report_title", report_title + " - " + report_id);
           parameters.put("report_binarydata", report_binarydata);
           parameters.put("task_id", task_id);
           parameters.put("task_title", task_title + " - " + task_id);
           parameters.put("task_binarydata", task_binarydata);
           parameters.put("subtask_id", subtask_id);
           parameters.put("subtask_title", subtask_title + " - " + subtask_id);
           parameters.put("subtask_binarydata", subtask_binarydata);
           parameters.put("inspection", inspection);
           parameters.put("field_id", field_id);
           parameters.put("field_name", field_name + " - " + field_id);
           parameters.put("field_comments", field_comments);
           
           if(field_config != null)
//           Map<String, Object> processed = processField("Dropdown", field_config, true);
               field_config = processField(field_name, field_config, true).toString();
           
           parameters.put("field_config", field_config);
           parametersList.add(parameters);
       }
      
       if (parametersList.isEmpty()) {
           System.out.println("No data found!");
           return Response.status(Response.Status.NO_CONTENT)
                   .entity("No data available for the report")
                   .build();
       }
       JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
       HashMap<String, Object> reportParams = new HashMap<>();
       reportParams.put("Title", "Stonex Report");
        JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams,dataSource);
       
        JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
       
//         return Response.ok(outputStream.toByteArray(), "application/pdf")
//                 .header("Content-Disposition", "attachment; filename=\"stonexReport.pdf\"")
//                 .build();
       
        // If you want getting fine in local then added this below code
//        try {
//            Path debugPath = Paths.get("/home/chirag/Stonex_report.pdf");
//            Files.write(debugPath, outputStream.toByteArray());
//        } catch (Exception e) {
//            System.err.println("DEBUG: Failed to save PDF: " + e.getMessage());
//        }
       
        return Response.ok(outputStream.toByteArray())
                .header("Content-Type", "application/pdf")
                .header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
                .header("Content-Length", outputStream.size())
                .build();
    } catch (Exception e) {
        return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
    }finally {
            DB.close(rs, pstmt);
        }
}

    public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
        ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
        ZipInputStream zis = new ZipInputStream(bis);
        ZipEntry entry;
        while ((entry = zis.getNextEntry()) != null) {
            if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) {
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = zis.read(buffer)) > 0) {
                    bos.write(buffer, 0, len);
                }
                zis.closeEntry();
                zis.close();
                return bos.toByteArray();
            }
        }
        zis.close();
        return null;
    }
    
    public StringBuilder processField(String fieldType, String config, boolean isRequired) {
        StringBuilder builder = new StringBuilder();

        try {
            JSONObject configObj = config.isEmpty() ? new JSONObject() : new JSONObject(config);
            builder.append(configObj.optString("questionText", ""));
            builder.append("\n");
            builder.append("\n");
            
            // Type-specific processing
            switch (fieldType) {
                case "Short Answer":
                     builder.append(configObj.optString("answerText", ""));
                    break;
                    
                case "Dropdown":
                case "Checkboxes":
                case "Multiple Choice":
                     builder.append(processOptions(configObj.optJSONArray("options")));
                     builder.append("\n");
                     builder.append(getSelectedOptions(configObj.optJSONArray("options")));
                    break;
                    
                case "File Upload":
                case "Image Upload":
                case "Video field":
                     builder.append(configObj.optInt("fileCount", 0));
                     builder.append("\n");
                     builder.append(configObj.optInt("maxCount", 0));
                    break;
                    
                default:
                     builder.append(configObj.optString("answerText", ""));
            }
            
        } catch (Exception e) {
        }
        
        return builder;
    }
    
    private List<Map<String, Object>> processOptions(org.codehaus.jettison.json.JSONArray optionsArray) {
        List<Map<String, Object>> options = new ArrayList<>();
        if (optionsArray == null) return options;
        
        for (int i = 0; i < optionsArray.length(); i++) {
            JSONObject option = optionsArray.optJSONObject(i);
            if (option != null) {
                Map<String, Object> optMap = new LinkedHashMap<>();
                optMap.put("id", i);
                optMap.put("text", option.optString("text", ""));
                optMap.put("value", option.optString("value", ""));
                optMap.put("selected", option.optBoolean("selected", false));
                options.add(optMap);
            }
        }
        return options;
    }
    
    private List<String> getSelectedOptions(JSONArray optionsArray) {
        List<String> selected = new ArrayList<>();
        if (optionsArray == null) return selected;
        
        for (int i = 0; i < optionsArray.length(); i++) {
            JSONObject option = optionsArray.optJSONObject(i);
            if (option != null && option.optBoolean("selected", false)) {
                selected.add(option.optString("value", ""));
            }
        }
        return selected;
    }












    ==========================================================================================

    @Override
    public Response download(int reportId) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        Properties ctx = Env.getCtx();
        String trxName = null;

        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> parametersList = new ArrayList<>();
        try {

            PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
            if (po != null && po.get_ID() == 0)
                return Response
                        .status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
                                .status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
                        .build();

            String jasperFilePath = "/home/chirag/JaspersoftWorkspace/MyReports/StonexL.jrxml";

            JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
//        JasperReport jasperReport = JasperCompileManager.compileReport(po.getAttachment().getEntry(0).getInputStream());

            byte[] stonex_icon = null;
            po = new Query(ctx, MSysConfig.Table_Name, "name ='ZK_LOGIN_ICON'", trxName).first();
            if (po != null && po.get_ID() != 0)
                stonex_icon = po.getAttachment().getEntry(0).getData();

            if (jasperReport == null) {
                return Response.status(Response.Status.NOT_FOUND).entity("Jasper file not found: " + jasperReport)
                        .build();
            }

            String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.clientName AS client_name,pr.created as report_date,pr.createdby, pr.reporttitle AS report_title, pr.address AS report_address, pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
                    + "prt.pi_report_task_ID AS task_id,prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,adret.binarydata AS task_binarydata,\n"
                    + "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
                    + "adrest.binarydata AS subtask_binarydata,prsf.inspection AS inspection,prsf.comments AS field_comments,prsf.config AS field_config,\n"
                    + "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
                    + "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
                    + "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
                    + "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
                    + "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
                    + "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
                    + "left JOIN adempiere.ad_attachment adret on adret.ad_table_id = 1000018 and adret.record_id = prt.pi_report_task_id\n"
                    + "left JOIN adempiere.ad_attachment adrest on adrest.ad_table_id = 1000019 and adrest.record_id = prs.pi_report_subtask_id\n"
                    + "WHERE  pr.pi_report_id =" + reportId
                    + " ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;\n"
                    + "";

            pstmt = DB.prepareStatement(sql, null);
            rs = pstmt.executeQuery();

            PI_Report report = new PI_Report(ctx, reportId, trxName);
            while (rs.next()) {
                HashMap<String, Object> parameters = new HashMap<>();
                byte[] report_binarydata = null;
                byte[] task_binarydata = null;
                byte[] subtask_binarydata = null;

                int report_id = rs.getInt("report_id");
                String report_title = rs.getString("report_title");
                String report_address = rs.getString("report_address");
                String report_date = rs.getString("report_date");
                int createdby = rs.getInt("createdby");
                MUser user = new MUser(ctx, createdby, trxName);
                String report_createdby = user.getName();
                String client_name = rs.getString("client_name");
                String project_title = rs.getString("project_title");

                try {
                    byte[] zipData = rs.getBytes("report_binarydata");
                    if (zipData != null) {
                        report_binarydata = extractImageFromZip(zipData);
                    }
                } catch (Exception e) {
                    System.err.println("Error extracting report image: " + e.getMessage());
                }

                try {
                    byte[] zipDataT = rs.getBytes("task_binarydata");
                    if (zipDataT != null) {
                        task_binarydata = extractImageFromZip(zipDataT);
                    }
                } catch (Exception e) {
                    System.err.println("Error extracting Task image: " + e.getMessage());
                }

                try {
                    byte[] zipDataS = rs.getBytes("subtask_binarydata");
                    if (zipDataS != null) {
                        subtask_binarydata = extractImageFromZip(zipDataS);
                    }
                } catch (Exception e) {
                    System.err.println("Error extracting Sub Task image: " + e.getMessage());
                }

                int task_id = rs.getInt("task_id");
                String task_title = rs.getString("task_title");

                int subtask_id = rs.getInt("subtask_id");
                String subtask_title = rs.getString("subtask_title");

                int inspection = rs.getInt("inspection");

                int field_id = rs.getInt("field_id");
                String field_name = rs.getString("field_name");

                String field_comments = rs.getString("field_comments");
                // Handle NULL and empty strings properly
                if (field_comments == null) {
                    field_comments = ""; // Or "No comments" if you prefer
                } else {
                    field_comments = field_comments.trim();
                }

                String field_config = rs.getString("field_config");
                if (field_config == null) {
                    field_config = "";
                } else {
                    field_config = field_config.trim();
                }
                
                parameters.put("report_id", report_id);
                parameters.put("report_title", report_title + " - " + report_id);
                parameters.put("report_binarydata", report_binarydata);
                parameters.put("task_id", task_id);
                parameters.put("task_title", task_title + " - " + task_id);
                parameters.put("task_binarydata", task_binarydata);
                parameters.put("subtask_id", subtask_id);
                parameters.put("subtask_title", subtask_title + " - " + subtask_id);
                parameters.put("subtask_binarydata", subtask_binarydata);
                parameters.put("inspection", inspection);
                parameters.put("field_id", field_id);
                parameters.put("field_name", field_name + " - " + field_id);
                parameters.put("field_comments", field_comments);
                parameters.put("stonex_icon", stonex_icon);
                parameters.put("report_address", report_address);
                parameters.put("report_date", report_date);
                parameters.put("report_createdby", report_createdby);
                parameters.put("client_name", client_name);
                parameters.put("project_title", project_title);

                if (field_config != null)
//           Map<String, Object> processed = processField("Dropdown", field_config, true);
                    field_config = processField(field_name, field_config, true).toString();

                parameters.put("field_config", field_config);
                parametersList.add(parameters);
            }

            if (parametersList.isEmpty()) {
                System.out.println("No data found!");
                return Response.status(Response.Status.NO_CONTENT).entity("No data available for the report").build();
            }
            JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
            HashMap<String, Object> reportParams = new HashMap<>();
            reportParams.put("Title", "Stonex Report");

            String themeColor = report.getthemecolour();
            if (themeColor == null)
                themeColor = "#0bf78f";

            reportParams.put("Background_color", themeColor);

            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams, dataSource);

            JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);

            return Response.ok(outputStream.toByteArray()).header("Content-Type", "application/pdf")
                    .header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
                    .header("Content-Length", outputStream.size()).build();
        } catch (Exception e) {
            return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
        } finally {
            DB.close(rs, pstmt);
        }
    }

    public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
        ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
        ZipInputStream zis = new ZipInputStream(bis);
        ZipEntry entry;
        while ((entry = zis.getNextEntry()) != null) {
            if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) {
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = zis.read(buffer)) > 0) {
                    bos.write(buffer, 0, len);
                }
                zis.closeEntry();
                zis.close();
                return bos.toByteArray();
            }
        }
        zis.close();
        return null;
    }

    public StringBuilder processField(String fieldType, String config, boolean isRequired) {
        StringBuilder builder = new StringBuilder();

        try {
            JSONObject configObj = config.isEmpty() ? new JSONObject() : new JSONObject(config);
            builder.append(configObj.optString("questionText", ""));
            builder.append("\n");
            builder.append("\n");

            // Type-specific processing
            switch (fieldType) {
            case "Short Answer":
                builder.append(configObj.optString("answerText", ""));
                break;

            case "Dropdown":
            case "Checkboxes":
            case "Multiple Choice":
                builder.append(processOptions(configObj.optJSONArray("options")));
                builder.append("\n");
                builder.append(getSelectedOptions(configObj.optJSONArray("options")));
                break;

            case "File Upload":
            case "Image Upload":
            case "Video field":
                builder.append(configObj.optInt("fileCount", 0));
                builder.append("\n");
                builder.append(configObj.optInt("maxCount", 0));
                break;

            default:
                builder.append(configObj.optString("answerText", ""));
            }

        } catch (Exception e) {
        }

        return builder;
    }

    private List<Map<String, Object>> processOptions(org.codehaus.jettison.json.JSONArray optionsArray) {
        List<Map<String, Object>> options = new ArrayList<>();
        if (optionsArray == null)
            return options;

        for (int i = 0; i < optionsArray.length(); i++) {
            JSONObject option = optionsArray.optJSONObject(i);
            if (option != null) {
                Map<String, Object> optMap = new LinkedHashMap<>();
                optMap.put("id", i);
                optMap.put("text", option.optString("text", ""));
                optMap.put("value", option.optString("value", ""));
                optMap.put("selected", option.optBoolean("selected", false));
                options.add(optMap);
            }
        }
        return options;
    }

    private List<String> getSelectedOptions(JSONArray optionsArray) {
        List<String> selected = new ArrayList<>();
        if (optionsArray == null)
            return selected;

        for (int i = 0; i < optionsArray.length(); i++) {
            JSONObject option = optionsArray.optJSONObject(i);
            if (option != null && option.optBoolean("selected", false)) {
                selected.add(option.optString("value", ""));
            }
        }
        return selected;
    }

    =====================================
   