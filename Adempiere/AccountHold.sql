public class AccountHold extends SvrProcess{
	private CLogger log = CLogger.getCLogger(AccountHold.class);
	private Properties ctx = Env.getCtx();
	private int clientId = Env.getAD_Client_ID(ctx);
	private String Hold = "H";
	private String Subject = "Account Payment Reminder";
    private String message = "Your account payment is overdue by 21 days. Please make the payment.";

	@Override
	protected void prepare() {
		// TODO Auto-generated method stub	
	}
	@Override
	protected String doIt() throws Exception {
		try {
			String sql = "SELECT C_BPartner_ID FROM adempiere.C_Invoice "
					+ "WHERE dateinvoiced + INTERVAL '21 days' <= current_date "
					+ "AND IsPaid='N' AND issotrx = 'Y'"
					+ "AND ad_client_id =" +clientId+ ";";
			
			PreparedStatement pstm = null;
			ResultSet rs = null;
			
			pstm = DB.prepareStatement(sql.toString(),null);
			rs = pstm.executeQuery();
			
			while(rs.next()) {
				
				int bPartnerID = rs.getInt("C_BPartner_ID");

				MBPartner bp = new MBPartner(getCtx(), bPartnerID,get_TrxName());
				
				String bpStatus = bp.getSOCreditStatus(); //check credit Status
				
				if(bpStatus != Hold) {

				bp.setSOCreditStatus(Hold);  //set Credit Status
				
				bp.saveEx();
				commitEx();
				System.out.println("BPartner Hold is SuccessFully, Id is :- "+bPartnerID);

				customMail(bPartnerID);
				
				}else {
					System.out.println("BPartner Already Hold");
				}	
			}	
		}catch(Exception e) {
			e.printStackTrace();
			log.warning("Some Error Occured");
		}
		return "Billing accounts placed on hold for overdue invoices.";
	}

	private void customMail(int bPartnerID) throws Exception {
		try {
		MBPartner bp = new MBPartner(getCtx(), bPartnerID,get_TrxName());
		MUser user = bp.getContact(bPartnerID);
		MClient client = MClient.get(Env.getCtx(), user.getAD_Client_ID());
		EMail mail = client.createEMail(user.getEMailUser(), Subject, message);
		System.out.println(mail);
		mail.sendEx();
		
		}catch(Exception e) {
			System.out.println("Email Problem");
		}
	}
}