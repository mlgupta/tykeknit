 /*
  *****************************************************************************
  *                       Confidentiality Information                         *
  *                                                                           *
  * This module is the confidential and proprietary information of            *
  * tykeknit.; it is not to be copied, reproduced, or transmitted in any      *
  * form, by any means, in whole or in part, nor is it to be used for any     *
  * purpose other than that for which it is expressly provided without the    *
  * written permission of tykeknit.                                           *
  *                                                                           *
  * Copyright (c) 2010-2011 tykeknit.  All Rights Reserved.                   *
  *                                                                           *
  *****************************************************************************
  * $Id: Operations.java,v 1.1 2011/06/22 12:47:42 manish Exp $
  *****************************************************************************
  */

package com.tykeknit.utils;

import com.tykeknit.utils.TKConstants;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import org.apache.log4j.Logger;

public class

Operations {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    
    public static String getTykeNames(int userTblPk,
                           DBConnection conn) throws SQLException, Exception {
     logger.debug("Enter getTykeNames");
     
     CallableStatement cs= null;
     String sqlString = null;
     String tykeNames;
     String rc = "";
 
     try {
         sqlString = "{? = call sp_get_tyke_names_list(?)}";
         
         cs = conn.prepareCall(sqlString);
         cs.registerOutParameter(1,Types.VARCHAR);
         cs.setInt(2,userTblPk);
         
         cs.execute();
         tykeNames = cs.getString(1);
         
         logger.debug("tykeNames : " + tykeNames);
         
         rc = tykeNames;
         
         if (rc == null) {
         }
         else {
             int strLen = rc.length();
             
             if (strLen > 2) {
                 rc = rc.substring(0,strLen-2);
                 strLen = rc.length();
                 
                 int commaIndex = rc.lastIndexOf(',');
                 
                 if (commaIndex == -1) {
                     rc = "and " + rc;
                 }
                 else {
                     rc = rc.substring(0,commaIndex) + " and " + rc.substring(commaIndex+1,strLen+1);
                 }
             }
         }
     } catch(SQLException e) {
         e.printStackTrace();
         logger.error("--- SQLException Caught ---");
         while (e != null) {
             logger.error("Message: " + e.getMessage());
             logger.error("SQLState: " + e.getSQLState());
             logger.error("ErrorCode: " + e.getErrorCode());
             e = e.getNextException();
         }
     } finally {
         try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
     }
     
     logger.debug("Exit getTykeNames");        
     return(rc);
 }
 
    public static int updatePNSentStatus(String pn_sent_list,
                           DBConnection conn) throws SQLException, Exception {
     logger.debug("Enter updatePNSentStatus");
     
     CallableStatement cs= null;
     String sqlString = null;
     int rc = 0;
    
     try {
         sqlString = "{? = call sp_upd_pn_sent_status(?)}";
         
         cs = conn.prepareCall(sqlString);
         cs.registerOutParameter(1,Types.INTEGER);
         cs.setString(2,pn_sent_list);
         
         cs.execute();
         rc = cs.getInt(1);
     } catch(SQLException e) {
         e.printStackTrace();
         logger.error("--- SQLException Caught ---");
         while (e != null) {
             logger.error("Message: " + e.getMessage());
             logger.error("SQLState: " + e.getSQLState());
             logger.error("ErrorCode: " + e.getErrorCode());
             e = e.getNextException();
         }
     } finally {
         try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
     }
     
     logger.debug("Exit updatePNSentStatus");        
     return(rc);
    }

    public static int deleteOldPn(DBConnection conn) throws SQLException, Exception {
     logger.debug("Enter deleteOldPn");
     
     CallableStatement cs= null;
     String sqlString = null;
     int rc = 0;
    
     try {
         sqlString = "{? = call sp_del_old_pn()}";
         
         cs = conn.prepareCall(sqlString);
         cs.registerOutParameter(1,Types.INTEGER);
         
         cs.execute();
         rc = cs.getInt(1);
     } catch(SQLException e) {
         e.printStackTrace();
         logger.error("--- SQLException Caught ---");
         while (e != null) {
             logger.error("Message: " + e.getMessage());
             logger.error("SQLState: " + e.getSQLState());
             logger.error("ErrorCode: " + e.getErrorCode());
             e = e.getNextException();
         }
     } finally {
         try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
     }
     
     logger.debug("Exit deleteOldPn");        
     return(rc);
    }

    public static int disableDeviceToken(String deviceToken,
                           DBConnection conn) throws SQLException, Exception {
     logger.debug("Enter disableDeviceToken");
     
     CallableStatement cs= null;
     String sqlString = null;
     int rc = 0;
    
     try {
         sqlString = "{? = call sp_upd_device_token_status(?,?)}";
         
         cs = conn.prepareCall(sqlString);
         cs.registerOutParameter(1,Types.INTEGER);
         cs.setString(2,deviceToken);
         cs.setString(3,"I");
         
         cs.execute();
         rc = cs.getInt(1);
     } catch(SQLException e) {
         e.printStackTrace();
         logger.error("--- SQLException Caught ---");
         while (e != null) {
             logger.error("Message: " + e.getMessage());
             logger.error("SQLState: " + e.getSQLState());
             logger.error("ErrorCode: " + e.getErrorCode());
             e = e.getNextException();
         }
     } finally {
         try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
     }
     
     logger.debug("Exit disableDeviceToken");        
     return(rc);
    }
}
