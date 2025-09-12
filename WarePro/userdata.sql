public StandardResponseDocument uploadfile(List<File> files, String user, String pass, int clientId, int orgId, int roleId,
			int warehouseId, int tableId, String userName) {
		StandardResponseDocument response = StandardResponseDocument.Factory.newInstance();
		StandardResponse resp = response.addNewStandardResponse();
		Trx trx = null;
		try {
			CompiereService m_cs = getCompiereService();
			Properties ctx = m_cs.getCtx();
			String trxName = Trx.createTrxName(getClass().getName() + "_");
			trx = Trx.get(trxName, true);
			trx.start();
			getCompiereService().connect();

			ADLoginRequest loginReq = ADLoginRequest.Factory.newInstance();
			loginReq.setUser(user);
			loginReq.setPass(pass);
			loginReq.setLang("112");
			loginReq.setClientID(clientId);
			loginReq.setRoleID(roleId);
			loginReq.setOrgID(orgId);
			loginReq.setWarehouseID(warehouseId);
			loginReq.setStage(0);

			String err = login(loginReq, webServiceName, "uploadfile", "uploadfile");
			if (err != null && err.length() > 0) {
				resp.setError(err);
				resp.setIsError(true);
				return response;
			}
			MUser existingUser = new Query(ctx, MUser.Table_Name, "Name=? AND AD_Client_ID=?", trxName)
	                .setParameters(userName,clientId)
	                .first();

	        if (existingUser != null) {
	            resp.setError("User with name '" + userName + "' already exists.");
	            resp.setIsError(true);
	            return response;
	        }
	        
	        MUser newUser = new MUser(ctx, 0, trxName);
	        newUser.setAD_Org_ID(orgId);
	        newUser.setName(userName);
	        newUser.setDescription("Created via API");
	        newUser.saveEx();
	        trx.commit();
	        
	        int userId = newUser.get_ID();

			MAttachment attachment = new MAttachment(ctx, tableId, userId, trxName);
			
			attachment.setClientOrg(clientId, orgId);
			attachment.setTextMsg("User Photos Upload");
	        
	        for (File file : files) {
	            byte[] data = convertFileToByteArray(file);
	            attachment.addEntry(file.getName(), data);
	            
	        }
	        attachment.saveEx();
	        trx.commit();
	        
	        pushFilebyAPI(userName, files);
	            
//	        for (File file : files) {
//	            BufferedImage img = null;
//	            try {
//	                img = ImageIO.read(file);
//	            } catch (IOException e) {
//	                img = null;
//	            }
//	            if (img != null) {
//	                pushFilebyAPI(userName, files);
//	            }
//	        }

	        resp.setIsError(false);	        
		} catch (Exception e) {
			if (trx != null) trx.rollback();
			resp.setError(e.getMessage());
			resp.setIsError(true);
			return response;
		} finally {
			if (manageTrx && trx != null)
				trx.close();
			getCompiereService().disconnect();
		}
		return response;
	}
	
	public static void pushFilebyAPI(String name, List<File> files) {
		try {
			String url = "http://3.7.97.129:8000/upload_faces/";
//			String url = "https://dev.warepro.in/upload/";
			String boundary = Long.toHexString(System.currentTimeMillis()); 
			String CRLF = "\r\n";

			// Open connection
			URL obj = new URL(url);
			HttpURLConnection con = (HttpURLConnection) obj.openConnection();
			con.setRequestMethod("POST");
			con.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
			con.setDoOutput(true);
			
//			String mimeType = Files.probeContentType(files.toPath());
//			if (mimeType == null) {
//			    mimeType = "application/octet-stream"; // fallback
//			}

			// Prepare the request body
			try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
				// Send name part
				wr.writeBytes("--" + boundary + CRLF);
				wr.writeBytes("Content-Disposition: form-data; name=\"name\"" + CRLF);
				wr.writeBytes(CRLF);
				wr.writeBytes(name + CRLF);

				// --- Send grayscale ---
	            wr.writeBytes("--" + boundary + CRLF);
	            wr.writeBytes("Content-Disposition: form-data; name=\"grayscale\"" + CRLF);
	            wr.writeBytes(CRLF);
	            wr.writeBytes("true" + CRLF);

				// --- Send all files ---
	            for (File file : files) {
	                wr.writeBytes("--" + boundary + CRLF);
	                wr.writeBytes("Content-Disposition: form-data; name=\"files\"; filename=\"" + file.getName() + "\"" + CRLF);
	                wr.writeBytes("Content-Type: image/jpeg" + CRLF); // or detect via Files.probeContentType(file.toPath())
	                wr.writeBytes(CRLF);

	                byte[] data = convertFileToByteArray(file);
	                wr.write(data);
	                wr.writeBytes(CRLF);
	            }

	            // --- End boundary ---
	            wr.writeBytes("--" + boundary + "--" + CRLF);
	            wr.flush();
	        }
			
			int responseCode = con.getResponseCode();

			if (responseCode == HttpURLConnection.HTTP_OK) {
				BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
				String inputLine;
				StringBuilder response = new StringBuilder();
				while ((inputLine = in.readLine()) != null) {
					response.append(inputLine);
				}
				in.close();
				System.out.println("Response: " + response.toString());
			} else {
				BufferedReader errorReader = new BufferedReader(new InputStreamReader(con.getErrorStream()));
				StringBuilder errorResponse = new StringBuilder();
				String errorLine;
				while ((errorLine = errorReader.readLine()) != null) {
					errorResponse.append(errorLine);
				}
				errorReader.close();
				System.err.println("Error Response: " + errorResponse.toString());
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}