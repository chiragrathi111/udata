/******************************************************************************
 * Product: iDempiere ERP & CRM Smart Business Solution                       *
 * Copyright (C) 1999-2012 ComPiere, Inc. All Rights Reserved.                *
 * This program is free software, you can redistribute it and/or modify it    *
 * under the terms version 2 of the GNU General Public License as published   *
 * by the Free Software Foundation. This program is distributed in the hope   *
 * that it will be useful, but WITHOUT ANY WARRANTY, without even the implied *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.           *
 * See the GNU General Public License for more details.                       *
 * You should have received a copy of the GNU General Public License along    *
 * with this program, if not, write to the Free Software Foundation, Inc.,    *
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.                     *
 * For the text or an alternative of this public license, you may reach us    *
 * ComPiere, Inc., 2620 Augustine Dr. #245, Santa Clara, CA 95054, USA        *
 * or via info@compiere.org or http://www.compiere.org/license.html           *
 *****************************************************************************/
/** Generated Model - DO NOT CHANGE */
package org.pipra.model.custom;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.util.Properties;
import org.compiere.model.*;
import org.compiere.util.Env;

/** Generated Model for pi_qrRelations
 *  @author iDempiere (generated) 
 *  @version Release 10 - $Id$ */
@org.adempiere.base.Model(table="pi_qrRelations")
public class X_pi_qrRelations extends PO implements I_pi_qrRelations, I_Persistent 
{

	/**
	 *
	 */
	private static final long serialVersionUID = 20231204L;

    /** Standard Constructor */
    public X_pi_qrRelations (Properties ctx, int pi_qrRelations_ID, String trxName)
    {
      super (ctx, pi_qrRelations_ID, trxName);
      /** if (pi_qrRelations_ID == 0)
        {
			setpi_qrRelations_ID (0);
        } */
    }

    /** Standard Constructor */
    public X_pi_qrRelations (Properties ctx, int pi_qrRelations_ID, String trxName, String ... virtualColumns)
    {
      super (ctx, pi_qrRelations_ID, trxName, virtualColumns);
      /** if (pi_qrRelations_ID == 0)
        {
			setpi_qrRelations_ID (0);
        } */
    }

    /** Load Constructor */
    public X_pi_qrRelations (Properties ctx, ResultSet rs, String trxName)
    {
      super (ctx, rs, trxName);
    }

    /** AccessLevel
      * @return 1 - Org 
      */
    protected int get_AccessLevel()
    {
      return accessLevel.intValue();
    }

    /** Load Meta Data */
    protected POInfo initPO (Properties ctx)
    {
      POInfo poi = POInfo.getPOInfo (ctx, Table_ID, get_TrxName());
      return poi;
    }

    public String toString()
    {
      StringBuilder sb = new StringBuilder ("X_pi_qrRelations[")
        .append(get_ID()).append("]");
      return sb.toString();
    }

	private int get_ValueAsIntCustom(String columnName)
	{
		Object val = get_Value(columnName);
		if (val == null)
			return 0;
		if (val instanceof Number)
			return ((Number)val).intValue();
		try {
			return Integer.parseInt(val.toString());
		} catch (Exception e) {
			return 0;
		}
	}

	/** Set corderlineid.
		@param corderlineid corderlineid
	*/
	public void setcorderlineid (int corderlineid)
	{
		set_Value (COLUMNNAME_corderlineid, Integer.valueOf(corderlineid));
	}

	/** Get corderlineid.
		@return corderlineid	  */
	public int getcorderlineid()
	{
		return get_ValueAsIntCustom(COLUMNNAME_corderlineid);
	}

	/** Set isinlocator.
		@param isinlocator isinlocator
	*/
	public void setisinlocator (int isinlocator)
	{
		set_Value (COLUMNNAME_isinlocator, Integer.valueOf(isinlocator));
	}

	/** Get isinlocator.
		@return isinlocator	  */
	public int getisinlocator()
	{
		return get_ValueAsIntCustom(COLUMNNAME_isinlocator);
	}

	/** Set isshippedout.
		@param isshippedout isshippedout
	*/
	public void setisshippedout (int isshippedout)
	{
		set_Value (COLUMNNAME_isshippedout, Integer.valueOf(isshippedout));
	}

	/** Get isshippedout.
		@return isshippedout	  */
	public int getisshippedout()
	{
		return get_ValueAsIntCustom(COLUMNNAME_isshippedout);
	}

	/** Set locatorid.
		@param locatorid locatorid
	*/
	public void setlocatorid (int locatorid)
	{
		set_Value (COLUMNNAME_locatorid, Integer.valueOf(locatorid));
	}

	/** Get locatorid.
		@return locatorid	  */
	public int getlocatorid()
	{
		return get_ValueAsIntCustom(COLUMNNAME_locatorid);
	}

	/** Set minoutlineid.
		@param minoutlineid minoutlineid
	*/
	public void setminoutlineid (int minoutlineid)
	{
		set_Value (COLUMNNAME_minoutlineid, Integer.valueOf(minoutlineid));
	}

	/** Get minoutlineid.
		@return minoutlineid	  */
	public int getminoutlineid()
	{
		return get_ValueAsIntCustom(COLUMNNAME_minoutlineid);
	}

	/** Set palletuuid.
		@param palletuuid palletuuid
	*/
	public void setpalletuuid (String palletuuid)
	{
		set_Value (COLUMNNAME_palletuuid, palletuuid);
	}

	/** Get palletuuid.
		@return palletuuid	  */
	public String getpalletuuid()
	{
		return (String)get_Value(COLUMNNAME_palletuuid);
	}

	/** Set pi_qrRelations.
		@param pi_qrRelations_ID pi_qrRelations
	*/
	public void setpi_qrRelations_ID (int pi_qrRelations_ID)
	{
		if (pi_qrRelations_ID < 1)
			set_ValueNoCheck (COLUMNNAME_pi_qrRelations_ID, null);
		else
			set_ValueNoCheck (COLUMNNAME_pi_qrRelations_ID, Integer.valueOf(pi_qrRelations_ID));
	}

	/** Get pi_qrRelations.
		@return pi_qrRelations	  */
	public int getpi_qrRelations_ID()
	{
		return get_ValueAsIntCustom(COLUMNNAME_pi_qrRelations_ID);
	}

	/** Set productid.
		@param productid productid
	*/
	public void setproductid (int productid)
	{
		set_Value (COLUMNNAME_productid, Integer.valueOf(productid));
	}

	/** Get productid.
		@return productid	  */
	public int getproductid()
	{
		return get_ValueAsIntCustom(COLUMNNAME_productid);
	}

	/** Set pstatus.
		@param pstatus pstatus
	*/
	public void setpstatus (String pstatus)
	{
		set_Value (COLUMNNAME_pstatus, pstatus);
	}

	/** Get pstatus.
		@return pstatus	  */
	public String getpstatus()
	{
		return (String)get_Value(COLUMNNAME_pstatus);
	}

	/** Set quantity.
		@param quantity quantity
	*/
	public void setquantity (BigDecimal quantity)
	{
		set_Value (COLUMNNAME_quantity, quantity);
	}

	/** Get quantity.
		@return quantity	  */
	public BigDecimal getquantity()
	{
		BigDecimal bd = (BigDecimal)get_Value(COLUMNNAME_quantity);
		if (bd == null)
			 return Env.ZERO;
		return bd;
	}
}