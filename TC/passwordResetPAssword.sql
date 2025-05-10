public void sendEmail(MClient client,MUser user, String token) throws Exception {
    	
        String senderEmail = client.getRequestEMail();
        
        if (senderEmail == null || senderEmail.isEmpty()) {
            throw new MessagingException("Sender email not configured in tenant");
        }
        
        EMail email = client.createEMailFrom(
                senderEmail, 
                user.getEMail(), 
                "Password Reset Request", 
                buildEmailContent(user, token),
                true // isHTML
            );
        if (email == null) {
            throw new Exception("Failed to create email object");
        }

        String status = email.send();
        if (!EMail.SENT_OK.equals(status)) {
            throw new Exception("Failed to send email: ");
        }
        
    }
    
    private String buildEmailContent(MUser user, String token) {
        String resetLink = "http://13.233.84.2:8080/ADInterface/services/rest/realmeds_customservice/gettokenvalidation?userId=" 
            + user.get_ID() + "&token=" + token;
        
        return String.format(
            "<html><body>" +
            "<p><strong>Token:</strong> %s</p>" +
            "<p>To reset your password, please click the following link:</p>" +
            "<p><a href=\"%s\">Reset Password</a></p>" +
            "</body></html>",
            token, resetLink
        );
    }



   ======================================================================
   String fullURL = httpServletRequest.getRequestURL().toString();
            String baseURL = fullURL.substring(0, fullURL.lastIndexOf('/'));
            System.out.println("Base URL: " + baseURL);

 ====================================++++++++++++++++++++++++++++++++++++
 
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

            Query query = new Query(Env.getCtx(), X_pi_planitem.Table_Name,
                    "pi_salesplanline_id=? AND totalQnty != completedQnty", null);

            List<PO> children = query.setParameters(m_parentID).list();

            for (PO child : children) {
                Row row = new Row();
                X_pi_planitem planItem = new X_pi_planitem(Env.getCtx(), child.get_ID(), null);
                MProduct_Custom product = new MProduct_Custom(Env.getCtx(), planItem.getM_Product_ID(), null);
                Checkbox cb = new Checkbox(product.getName());
                checkboxes.add(cb);
                childIDs.add(child.get_ID());

                Label productQty = new Label(planItem.gettotalqnty().toString());

                String quantity = planItem.gettotalqnty().toString();
                Textbox qtyTextbox = new Textbox();
                qtyTextbox.setValue(quantity);
                qtyTextbox.setWidth("80px");
                qtyTextbox.addEventListener("onChange", event -> {
                    try {
                        int value = Integer.parseInt(qtyTextbox.getValue());
                        int totalQty = planItem.gettotalqnty().intValue();
                        int completedQty = planItem.getcompletedqnty().intValue();
                        int pendingQty = totalQty - completedQty ;
                        if (value < 0 || value > planItem.gettotalqnty().intValue()) {
                            qtyTextbox.setValue(quantity);
                            Messagebox.show("Please enter a value between 0 and " + quantity + ".");
                        }
                    } catch (NumberFormatException e) {
                        qtyTextbox.setValue("0");
                        Messagebox.show("Please enter a valid integer.");
                    }
                });

                quantityFields.add(qtyTextbox);

                row.appendChild(cb);
                row.appendChild(productQty);
                row.appendChild(qtyTextbox);
                rows.appendChild(row);
            }
                        