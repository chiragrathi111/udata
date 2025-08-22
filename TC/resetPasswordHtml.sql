String postmanLink = url + "/?userName=" + user.getName() + "&token=" + token;
String keralaLogoUrl = "https://tc.warepro.in/resources/images/logo2.png";
String kdiscLogoUrl = "https://tc.warepro.in/resources/images/logo1.png";

        
        String emailContent = String.format(
        	    "<!DOCTYPE html>" +
        	    "<html>" +
        	    "<head>" +
        	    "<meta charset='UTF-8'>" +
        	    "<title>Reset Your Password</title>" +
        	    "</head>" +
        	    "<body style='margin:0; padding:0; background-color:#EEFFFA; font-family:Arial, sans-serif;'>" +
        	    "<table role='presentation' border='0' cellpadding='0' cellspacing='0' width='100%%'>"+

        	    "<tr>" +
        	        "<td align='left' style='padding: 40px;'>" +
        	            "<img src=%s alt='Left Logo' style='height:60px;' />" +
        	        "</td>" +
        	        "<td align='right' style='padding: 40px;'>" +
        	            "<img src='%s' alt='Right Logo' style='height:60px;' />" +
        	        "</td>" +
        	    "</tr>" +

        	    "<tr><td align='center' style='padding: 40px 0;'>" +
        	        "<table role='presentation' border='0' cellpadding='0' cellspacing='0' width='600' " +
        	        "style='background-color:#ffffff; border-radius:5px; overflow:hidden; border-top:5px solid #2e7d32; width: 600px; max-width: 600px;'>" +

        	            "<tr><td align='left' style='padding: 0 30px;'>"
        	            + "<h1></h1>" +
        	                "<h2 style='margin:0; font-size:22px; color:#333333;'>Reset Your Password</h2>" +
        	            "</td></tr>" +

        	            "<tr><td style='padding: 20px 30px; font-size:16px; color:#555555; text-align:left;'>" +
        	                "Hi, <strong>%s</strong><br><br>" +
        	                "Tap the button below to reset your account password.<br>" +
        	                "If you didn't request a new password, you can safely delete this email." +
        	            "</td></tr>" +

        	            "<tr><td align='center' style='padding: 30px 30px;'>" +
        	                "<a href='%s' style='border: 2px solid #2e7d32; background-color:#2e7d32; color:#ffffff; padding:12px 25px; text-decoration:none; font-size:16px; border-radius:4px; display:inline-block;'>Reset Password</a>" +
        	            "</td></tr>" +

        	            "<tr><td style='padding: 10px 30px 20px 30px; font-size:14px; color:#555555; text-align:left;'>" +
        	                "If that doesn't work, copy and paste the following link in your browser:<br>" +
        	                "<a href='%s' style='color:#2e7d32;'>%s</a>" +
        	            "</td></tr>" +

        	            "<tr><td style='padding: 20px 30px; font-size:14px; color:#555555;'>Team K-Disc</td></tr>" +
        	        "</table>" +
        	    "</td></tr>" +
        	    "</table>" +
        	    "</body>" +
        	    "</html>",
        	    keralaLogoUrl,
        	    kdiscLogoUrl,
        	    user.getName(), postmanLink, postmanLink, postmanLink
        	);