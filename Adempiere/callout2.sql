create a class in org.compiere.model 


package org.compiere.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class MyCallout3 extends CalloutEngine{
	
	CLogger log = CLogger.getCLogger(MyCallout3.class);
	public String getNextItemNbr (Properties ctx, int WindowNo,
			GridTab mTab, GridField mField, Object value)
	{
		Integer chiId = (Integer)mTab.getValue("AD_Client_ID");
		String sql = "SELECT MAX(Numbers) "
		+ "FROM c_chirag "
		+ "WHERE AD_Client_ID=?";
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			
			pstmt = DB.prepareStatement(sql, null);
			pstmt.setInt(1,chiId);
			rs = pstmt.executeQuery();
			Integer maxItemNbr = 0;
			if (rs.next())
			{
			maxItemNbr = rs.getInt(1);
			Env.setContext(ctx, WindowNo, "Numbers", maxItemNbr+1);
			mTab.setValue("Numbers", maxItemNbr+1);
			}
			DB.close(rs, pstmt);
			rs = null;
			pstmt = null;
			
		}catch(SQLException e) {
			log.log(Level.SEVERE,sql,e);
			return e.getLocalizedMessage();
		}finally {
			DB.close(rs,pstmt);
			rs = null;
			pstmt = null;
		}		
		return "";				
	}	
}

and this method is using regular increment value in windows part 

Table and go to column and choose our static field change your increment data
go to scroll down and show Tachnical value and see the empty field in callout 
copy and pste value directly 
org.compiere.model.MyCallout3.getNextItemNbr  (package.class.function)

change role and go to windows menu and put the record you see your selected field is automaticly value increment. 
