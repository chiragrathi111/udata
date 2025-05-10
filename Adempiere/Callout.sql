Callout Complete Process:-

Why are use ?
This Callout Process is using UI any specific field any changes and give notification in your console . This notification before your set output process

1. Create a Plug in Eclipse :-
go to File->New->Other->Plug-in-Project

enter plug in name and create Plug in Eclipse

2. Create Package :-

src right click and go to new -> package
(1)org.chirag.callout
(2)org.chirag.callout.factory
two package will be created

3. Create Class:-
Every package craete 1 Class
(1)MyCallout
(2)MyCalloutFactory

4. MyCallout Class

import java.util.Properties;

import org.adempiere.base.IColumnCallout;
import org.compiere.model.GridField;
import org.compiere.model.GridTab;
import org.compiere.util.CLogger;

public class MyCallout implements IColumnCallout {
	
	CLogger log = CLogger.getCLogger(MyCallout.class);

	@Override
	public String start(Properties ctx, int WindowNo, GridTab mTab, GridField mField,
			Object value, Object oldValue) {
		// TODO Auto-generated method stub
		log.warning("-----------------------------------------------------------");
		log.warning("ColumnName: "+mField.getColumnName());
		log.warning("Value: "+value.toString());
		log.warning("OldValue: "+oldValue.toString());
		log.warning("===============================================================");
		
		return null;
	}

}

5.MyCalloutFactory Class

import java.util.ArrayList;
import java.util.List;

import org.adempiere.base.IColumnCallout;
import org.adempiere.base.IColumnCalloutFactory;
import org.chirag.callout.model.MyCallout;
import org.compiere.model.MOrder;

public class MyFactory implements IColumnCalloutFactory{

	@Override
	public IColumnCallout[] getColumnCallouts(String tableName, String columnName) {
		// TODO Auto-generated method stub
		
		List<IColumnCallout> list = new ArrayList<IColumnCallout>();
		
		if(tableName.equalsIgnoreCase(MOrder.Table_Name) && columnName.equalsIgnoreCase(MOrder.COLUMNNAME_Description))
			
			list.add(new MyCallout());
		
		return list != null ? list.toArray(new IColumnCallout[0]) : new IColumnCallout[0];
	}
}

go to run configure and check your plug in and change value 1 and true

if you are callout not working then clear your 8080 and 8443 port no.
remove port no.
lsof -i | grep 8443  and lsof -i | grep 8080
kill -9 <ps id>

and run configure again and working properly


=================================================================================================================================================
one column field auto increment:-

package org.compiere.model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import org.compiere.model.CalloutEngine;
import org.compiere.model.GridField;
import org.compiere.model.GridTab;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.compiere.util.Env;

public class MyCallout2 extends CalloutEngine{	
	CLogger log = CLogger.getCLogger(MyCallout2.class);
	
	public String getNextItemNbr (Properties ctx, int WindowNo,
			GridTab mTab, GridField mField, Object value)
	{
		Integer momId = (Integer)mTab.getValue("c_mom_ID");
		String sql = "SELECT MAX(item_nbr) "
		+ "FROM C_Mom_DiscussionLine "
		+ "WHERE C_Mom_ID=?";
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {			
			pstmt = DB.prepareStatement(sql, null);
			pstmt.setInt(1, momId);
			rs = pstmt.executeQuery();
			Integer maxItemNbr = 0;
			if (rs.next())
			{
			maxItemNbr = rs.getInt(1);
			Env.setContext(ctx, WindowNo, "item_nbr", maxItemNbr+1);
			mTab.setValue("item_nbr", maxItemNbr+1);
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
(Starting create this class  org.adempiere.base->src->org.compiere.model this package mai class create karna hai)
New plug in create karke package create karke phir class create karna is good way but this time not read process method this way is not connected

Complie the Project and login to System Administrator role

go to the Table and column window open and the details  of the c_mom_ID Column in c_mom_discussionline table 
scrool down go to technical option click and show callout inbox

callout - org.compiere.model.MyCallout2.getNextItemNbr (Package_Name.Class_Name.Function_Name) 
save and change role and login GardenAdmin

Menu tree ->Minutes Of Meeting-> discussionline and add row you seen item_nbr auto increment 
(Callout method working fine)




















































