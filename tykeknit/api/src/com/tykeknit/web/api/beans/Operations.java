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
  * $Id: Operations.java,v 1.27 2011/07/01 12:57:08 manish Exp $
  *****************************************************************************
  */

package com.tykeknit.web.api.beans;

import com.tykeknit.web.api.actionforms.addKidForm;
import com.tykeknit.web.api.actionforms.addSecondaryPRForm;
import com.tykeknit.web.api.actionforms.deleteDBMessageForm;
import com.tykeknit.web.api.actionforms.deleteEventWallMessageForm;
import com.tykeknit.web.api.actionforms.deleteWallMessageForm;
import com.tykeknit.web.api.actionforms.playdateRequestForm;
import com.tykeknit.web.api.actionforms.postEventWallMessageForm;
import com.tykeknit.web.api.actionforms.postRSVPForm;
import com.tykeknit.web.api.actionforms.postWallMessageForm;
import com.tykeknit.web.api.actionforms.registerForm;
import com.tykeknit.web.api.actionforms.removeSecondaryPRForm;
import com.tykeknit.web.api.actionforms.setFBIdTokenForm;
import com.tykeknit.web.api.actionforms.updateKidForm;
import com.tykeknit.web.api.actionforms.updateSettingsForm;
import com.tykeknit.web.api.actionforms.updateUserForm;
import com.tykeknit.web.api.beans.LOOperations;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.InputStream;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.upload.FormFile;

import org.json.JSONArray;
import org.json.JSONObject;

public class

Operations {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public static int registerUser(registerForm registerForm,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter registerForm");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnUserTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_user(?,?,?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setString(2,registerForm.getTxtFirstName());
            cs.setString(3,registerForm.getTxtLastName());
            cs.setString(4,registerForm.getTxtEmail());
            cs.setString(5,registerForm.getTxtPassword());
            cs.setString(6,registerForm.getTxtDOB());
            cs.setString(7,registerForm.getTxtOPREmail());
            cs.setString(8,registerForm.getTxtParentType());
            cs.setString(9,registerForm.getTxtZip());
            
            cs.execute();
            returnUserTblPk = cs.getInt(1);
            
            logger.debug("returnUserTblPk : " + returnUserTblPk);
            
            rc = returnUserTblPk;
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -1;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit register");        
        return(rc);
    }

    public static int updateUser(updateUserForm  updateUserForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateUser");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_user(?,?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setString(3,updateUserForm.getTxtFirstName());
            cs.setString(4,updateUserForm.getTxtLastName());
            cs.setString(5,updateUserForm.getTxtPassword());
            cs.setString(6,updateUserForm.getTxtDOB());
            cs.setString(7,updateUserForm.getTxtParentType());
            cs.setString(8,updateUserForm.getTxtZip());
            
            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateUser");        
        return(rc);
    }

    public static int addKid(addKidForm addKidForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter addKid");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnKidTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_child(?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setString(2,addKidForm.getTxtFirstName());
            cs.setString(3,addKidForm.getTxtLastName());
            cs.setString(4,addKidForm.getTxtDOB());
            cs.setString(5,addKidForm.getTxtGender());
            cs.setInt(6,userTblPk);

            cs.execute();
            returnKidTblPk = cs.getInt(1);
            rc = returnKidTblPk;
            
            logger.debug("returnKidTblPk : " + returnKidTblPk);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit addKid");        
        return(rc);
    }

    public static int updateKid(updateKidForm updateKidForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateKid");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_child(?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setString(2,updateKidForm.getTxtFirstName());
            cs.setString(3,updateKidForm.getTxtLastName());
            cs.setString(4,updateKidForm.getTxtDOB());
            cs.setString(5,updateKidForm.getTxtGender());
            cs.setInt(6,Integer.parseInt(updateKidForm.getTxtChildTblPk()));
            cs.setInt(7,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateKid");        
        return(rc);
    }

    public static int addSecondaryPR(addSecondaryPRForm addSecondaryPRForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter addSecondaryPR");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnSecondaryPRTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_secondary_pr(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setString(3,addSecondaryPRForm.getTxtEmail());

            cs.execute();
            returnSecondaryPRTblPk = cs.getInt(1);
            
            rc = returnSecondaryPRTblPk;
            
            logger.debug("returnSecondaryPRTblPk : " + returnSecondaryPRTblPk);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit addSecondaryPR");        
        return(rc);
    }

    public static int removeSecondaryPR(removeSecondaryPRForm removeSecondaryPRForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter removeSecondaryPR");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnRemoveSecondaryPR;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_secondary_pr(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setString(3,removeSecondaryPRForm.getTxtEmail());

            cs.execute();
            returnRemoveSecondaryPR = cs.getInt(1);
            
            rc = returnRemoveSecondaryPR;
            
            logger.debug("returnRemoveSecondaryPR : " + returnRemoveSecondaryPR);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit removeSecondaryPR");        
        return(rc);
    }

    public static int addImage(FormFile imgFile,
                              int tblPk,
                              DataSource ds,
                              int imageFor) throws SQLException, Exception {
        logger.debug("Enter addImage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnImageTblPk = -1;
        String contentType = null;
        long oid = -1;
        byte[] content = null;
        int contentSize=-1;
        InputStream is = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            contentType = imgFile.getContentType();
            contentSize = imgFile.getFileData().length;
            
            oid = LOOperations.getLargeObjectId(ds);
            
            if (oid != -1) {
                content  =  new byte[contentSize];
                is       =  imgFile.getInputStream();
                is.read(content);

                rc = LOOperations.putLargeObjectContent(oid, content, ds);
                
                if (rc >= 0) {
                    sqlString = "{? = call sp_ins_image(?,?,?,?,?)}";
                    
                    cs = conn.prepareCall(sqlString);
                    cs.registerOutParameter(1,Types.INTEGER);
                    cs.setLong(2,oid);
                    cs.setInt(3,contentSize);
                    cs.setString(4,contentType);
                    cs.setInt(5,tblPk);
                    cs.setInt(6,imageFor);

                    cs.execute();
                    returnImageTblPk = cs.getInt(1);
                    rc = returnImageTblPk;
                }
            }
            logger.debug("returnImageTblPk : " + returnImageTblPk);
        } catch (SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } catch (Exception e) {
            logger.error(e.toString());
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        logger.debug("Exit addImage");        
        return(rc);
    }
    
    public static int deleteImage(String imageTblPk,
                                   DataSource dataSource) throws SQLException, Exception {
      Connection conn = null;
      CallableStatement cs = null;
      String sqlString = null;
      int rc = 0;
      
      try {
        logger.debug("Entering deleteImage");
        
        conn = dataSource.getConnection();
        sqlString = "{?=call sp_del_image(?)}";
        cs = conn.prepareCall(sqlString);

        cs.registerOutParameter(1, Types.INTEGER);
        cs.setInt(2, Integer.parseInt(imageTblPk));

        cs.execute();
        rc = cs.getInt(1);
        logger.debug("rc:" + rc);
      } catch (SQLException e) {
          e.printStackTrace();
          logger.error("--- SQLException Caught ---");
          while (e != null) {
              logger.error("Message: " + e.getMessage());
              logger.error("SQLState: " + e.getSQLState());
              logger.error("ErrorCode: " + e.getErrorCode());
              e = e.getNextException();
          }
          rc = -100;
      } catch (Exception e) {
          logger.error(e.toString());
          rc = -100;
      } finally {
          try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
          try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
      }
        logger.debug("Exit deleteImage");
        return(rc);
    }

    public static int updateImage(FormFile imgFile,
                              int imageTblPk,
                              long oid,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateImage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String contentType = null;
        byte[] content = null;
        int contentSize = -1;
        InputStream is = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            contentType = imgFile.getContentType();
            contentSize = imgFile.getFileData().length;
            
            content  =  new byte[contentSize];
            is       =  imgFile.getInputStream();
            is.read(content);

            rc = LOOperations.putLargeObjectContent(oid, content, ds);
                
            if (rc >= 0) {
                sqlString = "{? = call sp_upd_image(?,?,?)}";
                    
                cs = conn.prepareCall(sqlString);
                cs.registerOutParameter(1,Types.INTEGER);
                cs.setInt(2,imageTblPk);
                cs.setInt(3,contentSize);
                cs.setString(4,contentType);

                cs.execute();
                rc = cs.getInt(1);
            }
            logger.debug("rc : " + rc);
        } catch (SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } catch (Exception e) {
            logger.error(e.toString());
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        logger.debug("Exit updateImage");        
        return(rc);
    }

    public static byte[] getLargeObjectContent(long oid,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getLargeObjectContent");
        
        byte[] content = null;
    
        try {
            logger.debug("About to call LOOperations.getLargeObjectContent ");
            content = LOOperations.getLargeObjectContent(oid, ds);
            logger.debug("Returned from LOOperations.getLargeObjectContent ");
        } catch (SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
        }
        logger.debug("Exit getLargeObjectContent");        
        return content;
    }
    
    public static int knitInviteUsers(JSONArray jsonEmailArray,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter inviteUsers");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String emailList = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_knit_invite(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            emailList = "";
            
            int jsonIndex = 0;
            int jsonEmailArrayLength = jsonEmailArray.length();
            JSONObject jsonEmail = new JSONObject();
                      
            while (jsonIndex < jsonEmailArrayLength) {
                jsonEmail =  jsonEmailArray.getJSONObject(jsonIndex);
                ++jsonIndex;
                
                emailList += jsonEmail.getString("email") + ",";
            }
            
            emailList = emailList.substring(0,emailList.length() - 1);

            cs.setString(2,emailList);
            cs.setInt(3,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit inviteUsers");        
        return(rc);
    }
    
    public static int joinKnitRequest(int inviteFromUserTblFk,
                              int inviteToUserTblFk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter joinKnitRequest");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_join_knit(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,inviteFromUserTblFk);
            cs.setInt(3,inviteToUserTblFk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit joinKnitRequest");        
        return(rc);
    }

    public static int joinKnitAccept(int UserTblPk,
                              int txtKnitInviteTblPk,
                              String txtResponseCode,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter joinKnitAccept");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String acceptCode = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_join_knit_Accept(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,UserTblPk);
            cs.setInt(3,txtKnitInviteTblPk);
            
            if (txtResponseCode.equalsIgnoreCase("0")) {
                acceptCode = "R";
            }
            else {
              if (txtResponseCode.equalsIgnoreCase("1")) {
                  acceptCode = "A";
              }
              else {
                  acceptCode = "I";
              }
            }  
            cs.setString(4,acceptCode);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit joinKnitAccept");        
        return(rc);
    }
    
    public static int uploadContact(String contactId,
                              int userTblPk,
                              String txtDryRunFlag,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter uploadContact");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_user_contacts(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setString(2,contactId);
            cs.setInt(3,userTblPk);
            
            if ("1".equals(txtDryRunFlag)) {
                cs.setInt(4,1);
            }
            else {
                cs.setInt(4,0);
            }

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit uploadContact");        
        return(rc);
    }
    
    public static int getBuddiesCount(int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getBuddiesCount");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_buddies_count(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -1;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getBuddiesCount");        
        return(rc);
    }
    
    public static int getDegreeCode(int fromUserTblPk,
                              int toUserTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getDegreeCode");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_connection_degree(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,fromUserTblPk);
            cs.setInt(3,toUserTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -1;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getDegreeCode");        
        return(rc);
    }
    
    public static String getSecondaryPR(int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getSecondaryPR");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String rc = null;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_secondary_pr(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1, Types.VARCHAR);
            
            cs.setInt(2,userTblPk);

            cs.execute();
            rc = cs.getString(1);
            
            logger.debug("rc : " + rc);
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
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getSecondaryPR");        
        return(rc);
    }

    public static String getCommonFriendsChild(int fromUserTblPk,
                              int toUserTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getCommonFriendsChild");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String rc = null;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_common_friends_child(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1, Types.VARCHAR);
            
            cs.setInt(2,fromUserTblPk);
            cs.setInt(3,toUserTblPk);

            cs.execute();
            rc = cs.getString(1);
            
            logger.debug("rc : " + rc);
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
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getCommonFriendsChild");        
        return(rc);
    }

    public static String getCommonFriends(int fromUserTblPk,
                              int toUserTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getCommonFriends");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String rc = null;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_common_friends(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1, Types.VARCHAR);
            
            cs.setInt(2,fromUserTblPk);
            cs.setInt(3,toUserTblPk);

            cs.execute();
            rc = cs.getString(1);
            
            logger.debug("rc : " + rc);
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
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getCommonFriends");        
        return(rc);
    }

    public static int getParentForChild(int childTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getParentForChild");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_parent_for_child(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,childTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -1;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getParentForChild");        
        return(rc);
    }

    public static String getTykesForParent(int parentTblFk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getTykesForParent");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String rc = null;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_tykes_for_parent(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1, Types.VARCHAR);
            
            cs.setInt(2,parentTblFk);

            cs.execute();
            rc = cs.getString(1);
            
            logger.debug("rc : " + rc);
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
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getTykesForParent");        
        return(rc);
    }

    public static int playdateRequest(playdateRequestForm playdateRequestForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter playdateRequest");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        String inviteeList = "";
        String organiserCidList = "";
        int returnPlaydateTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_playdate_request(?,?,?,?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            
            JSONObject jsonOrganiserCidStr = new JSONObject(playdateRequestForm.getTxtOrganiserCid());
            JSONArray jsonOrganiserCidArray = new JSONArray();
            jsonOrganiserCidArray = jsonOrganiserCidStr.getJSONArray("OrganiserCids");
            
            int jsonIndex = 0;
            int jsonOrganiserCidArrayLength = jsonOrganiserCidArray.length();
                      
            while (jsonIndex < jsonOrganiserCidArrayLength) {
                JSONObject jsonOrganiserCid = new JSONObject();

                jsonOrganiserCid =  jsonOrganiserCidArray.getJSONObject(jsonIndex);
                ++jsonIndex;
                
                organiserCidList += jsonOrganiserCid.getString("cid") + ",";
            }
            
            if (organiserCidList == null || "".equals(organiserCidList)) {
                logger.debug("Exit playdateRequest as organiserCidList empty or Null");        
                return(-1);
            }
            else {
                organiserCidList = organiserCidList.substring(0,organiserCidList.length() - 1);
            }
            
            logger.debug("organiserCidList: " + organiserCidList);
            
            cs.setString(3,organiserCidList);
            cs.setString(4,playdateRequestForm.getTxtPlaydateName());
            cs.setString(5,playdateRequestForm.getTxtLocation());
//            cs.setString(6,"{t '" + playdateRequestForm.getTxtDate() + "'}");
            cs.setString(6,playdateRequestForm.getTxtDate());
            cs.setString(7,playdateRequestForm.getTxtStartTime());
            cs.setString(8,playdateRequestForm.getTxtEndTime());
            cs.setString(9,playdateRequestForm.getTxtMessage());
            cs.setString(10,playdateRequestForm.getTxtEndDate());

            cs.execute();
            returnPlaydateTblPk = cs.getInt(1);
            rc = returnPlaydateTblPk;
            
            logger.debug("returnPlaydateTblPk : " + returnPlaydateTblPk);
            

            sqlString = "{? = call sp_ins_playdate_invitee(?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,returnPlaydateTblPk);
            cs.setString(4,playdateRequestForm.getTxtPlaydateName());
            cs.setString(5,playdateRequestForm.getTxtMessage());

            JSONObject jsonInviteesStr = new JSONObject(playdateRequestForm.getTxtInvitees());
            JSONArray jsonInviteesArray = new JSONArray();
            jsonInviteesArray = jsonInviteesStr.getJSONArray("Invitees");
            
            jsonIndex = 0;
            int jsonInviteesArrayLength = jsonInviteesArray.length();
                      
            while (jsonIndex < jsonInviteesArrayLength) {
                JSONObject jsonInvitee = new JSONObject();

                jsonInvitee =  jsonInviteesArray.getJSONObject(jsonIndex);
                ++jsonIndex;

                cs.setInt(6,Integer.parseInt(jsonInvitee.getString("Parent")));
                
                JSONArray jsonChildInviteesArray = new JSONArray();
                jsonChildInviteesArray = jsonInvitee.getJSONArray("Tykes");
                
                int jsonChildIndex = 0;
                int jsonChildInviteesArrayLength = jsonChildInviteesArray.length();
                
                while (jsonChildIndex < jsonChildInviteesArrayLength) {
                    JSONObject jsonChildInvitee = new JSONObject();
                    
                    jsonChildInvitee = jsonChildInviteesArray.getJSONObject(jsonChildIndex);
                    ++jsonChildIndex;
                    
                    inviteeList += jsonChildInvitee.getString("cid") + ",";
                }
                
                if (inviteeList == null || "".equals(inviteeList)) {
                }
                else {
                    inviteeList = inviteeList.substring(0,inviteeList.length() - 1);
                }
                
                logger.debug("inviteeList: " + inviteeList);
                
                cs.setString(7,inviteeList);

                cs.execute();
                rc = cs.getInt(1);
                
                logger.debug("rc : " + rc);
                inviteeList = "";
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
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit playdateRequest");        
        return(rc);
    }
    
    public static int postWallMessage(postWallMessageForm postWallMessageForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter postWallMessageForm");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnWallMessageTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_wall_message(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(postWallMessageForm.getTxtPid()));
            cs.setString(4,postWallMessageForm.getTxtMessage());

            cs.execute();
            returnWallMessageTblPk = cs.getInt(1);
            rc = returnWallMessageTblPk;
            
            logger.debug("returnWallMessageTblPk : " + returnWallMessageTblPk);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit postWallMessageForm");        
        return(rc);
    }
    
    public static int deleteWallMessage(deleteWallMessageForm deleteWallMessageForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteWallMessage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_wall_message(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(deleteWallMessageForm.getTxtMessageId()));

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteWallMessage");        
        return(rc);
    }

    public static int postEventWallMessage(postEventWallMessageForm postEventWallMessageForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter postEventWallMessage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int returnWallMessageTblPk;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_event_wall_message(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(postEventWallMessageForm.getTxtEventTblPk()));
            cs.setString(4,postEventWallMessageForm.getTxtEventWallMessage());

            cs.execute();
            returnWallMessageTblPk = cs.getInt(1);
            rc = returnWallMessageTblPk;
            
            logger.debug("returnEventWallMessageTblPk : " + returnWallMessageTblPk);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit postEventWallMessage");        
        return(rc);
    }
    
    public static int deleteEventWallMessage(deleteEventWallMessageForm deleteEventWallMessageForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteEventWallMessage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_event_wall_message(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(deleteEventWallMessageForm.getTxtMessageId()));

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteEventWallMessage");        
        return(rc);
    }

    public static int deleteDBMessage(deleteDBMessageForm deleteDBMessageForm,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteDBMessage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_db_message(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(deleteDBMessageForm.getTxtMessageId()));

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteDBMessage");        
        return(rc);
    }

    public static int updateMessageReadStatus(int messageId,
                              int userTblPk,
                              String messageReadStatus,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateMessageReadStatus");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_msg_read_status(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,messageId);
            cs.setString(4,messageReadStatus);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateMessageReadStatus");        
        return(rc);
    }

    public static int updateMessageReadStatusPid(int playdate_id,
                              int userTblPk,
                              String txtReadStatus,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateMessageReadStatusPid");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_msg_read_status_pid(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,playdate_id);
            cs.setString(4,txtReadStatus);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateMessageReadStatusPid");        
        return(rc);
    }

    public static int updateUserLocation(String userLat,
                              String userLong,
                              int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateUserLocation");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_user_location(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setString(3,userLat);
            cs.setString(4,userLong);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateUserLocation");        
        return(rc);
    }


    public static int wallMessagesAuthorization(int userTblPk,
                              int playdateTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter wallMessagesAuthorization");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_wall_message_auth(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,playdateTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit wallMessagesAuthorization");        
        return(rc);
    }
    
    public static int postRSVP(int userTblPk,
                              postRSVPForm postRSVPForm,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter postRSVP");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_playdate_participant_rsvp(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(postRSVPForm.getTxtPid()));
            cs.setString(4,postRSVPForm.getTxtRSVP());

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -1;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit postRSVP");        
        return(rc);
    }

    public static int cancelPlaydate(int userTblPk,
                              int playdateTblFk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter cancelPlaydate");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_playdate_status(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,playdateTblFk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit cancelPlaydate");        
        return(rc);
    }

    public static int setFBIdToken(int userTblPk,
                              setFBIdTokenForm setFBIdTokenForm,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter setFBIdToken");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_fb_id_token(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setString(3,setFBIdTokenForm.getTxtFBId());
            cs.setString(4,setFBIdTokenForm.getTxtFBAuthToken());

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit setFBIdToken");        
        return(rc);
    }

    public static int deleteAccount(int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteAccount");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_user_account(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteAccount");        
        return(rc);
    }

    public static int deleteUserPic(int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteUserPic");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_user_pic(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteUserPic");        
        return(rc);
    }

    public static int deleteChildPic(int userTblPk,
                              int childTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter deleteChildPic");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_del_child_pic(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,childTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit deleteChildPic");        
        return(rc);
    }

    public static int updateSettings(int userTblPk,
                              updateSettingsForm updateSettingsForm,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter updateSettings");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_user_settings(?,?,?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,Integer.parseInt(updateSettingsForm.getTxtUserProfileSetting()));
            cs.setInt(4,Integer.parseInt(updateSettingsForm.getTxtUserContactSetting()));
            cs.setBoolean(5,updateSettingsForm.getBoolUserNotificationMembershipRequest());
            cs.setBoolean(6,updateSettingsForm.getBoolUserNotificationPlaydate());
            cs.setBoolean(7,updateSettingsForm.getBoolUserNotificationPlaydateMessageBoard());
            cs.setBoolean(8,updateSettingsForm.getBoolUserNotificationGeneralMessages());
            cs.setBoolean(9,updateSettingsForm.getBoolUserLocationCurrentLocationSetting());

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit updateSettings");        
        return(rc);
    }

    public static int DBMessagesAuthorization(int userTblPk,
                              int KnitInviteTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter DBMessagesAuthorization");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_DB_message_auth(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,KnitInviteTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit DBMessagesAuthorization");        
        return(rc);
    }

    public static int setDBWannaHang(int userTblPk,
                              int ChildTblPk,
                              int childWannaHangStatus,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter setDBWannaHang");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_wanna_hang(?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,userTblPk);
            cs.setInt(3,ChildTblPk);
            
            if (childWannaHangStatus == 1) {
                cs.setBoolean(4,true);
            }
            else {
                cs.setBoolean(4,false);
            }

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit setDBWannaHang");        
        return(rc);
    }

    public static int sendDBMessage(int inviteFromUserTblFk,
                              int inviteToUserTblFk,
                              String txtMsgSubject,
                              String txtMsgBody,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter sendDBMessage");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_message(?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,inviteFromUserTblFk);
            cs.setInt(3,inviteToUserTblFk);
            cs.setString(4,txtMsgSubject);
            cs.setString(5,txtMsgBody);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit sendDBMessage");        
        return(rc);
    }

    public static int registerConfirm(int confirmCode,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter registerConfirm");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_register_confirm(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,confirmCode);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit registerConfirm");        
        return(rc);
    }

    public static int secondaryPRConfirm(int confirmCode,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter secondaryPRConfirm");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_upd_secondary_pr_confirm(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,confirmCode);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit secondaryPRConfirm");        
        return(rc);
    }

    public static int profileCompletionStatus(int userTblPk,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter profileCompletionStatus");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_profile_completion_status(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,userTblPk);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit profileCompletionStatus");        
        return(rc);
    }

    public static int getUserFromEmail(String userEmail,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getUserFromEmail");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_user_tbl_pk(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setString(2,userEmail);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getUserFromEmail");        
        return(rc);
    }

    public static int getPhotoOwner(int photoID,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter getPhotoOwner");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_get_photo_owner(?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,photoID);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit getPhotoOwner");        
        return(rc);
    }
    
    public static int setDeviceToken(int userTblPk,
                              String deviceToken,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter setDeviceToken");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_device_token(?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            
            cs.setInt(2,userTblPk);
            cs.setString(3,deviceToken);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit setDeviceToken");        
        return(rc);
    }
    
    public static int addEvent(int eventTblPk,
                              String eventTitle,
                              String eventDetail,
                              int userTblPk,
                              String userLat,
                              String userLon,
                              DataSource ds) throws SQLException, Exception {
        logger.debug("Enter addEvent");
        
        Connection conn = null;
        CallableStatement cs= null;
        String sqlString = null;
        int rc = 0;
    
        try {
            conn = ds.getConnection();
            
            sqlString = "{? = call sp_ins_event(?,?,?,?,?,?)}";
            
            cs = conn.prepareCall(sqlString);
            cs.registerOutParameter(1,Types.INTEGER);
            cs.setInt(2,eventTblPk);
            cs.setString(3,eventTitle);
            cs.setString(4,eventDetail);
            cs.setInt(5,userTblPk);
            cs.setString(6,userLat);
            cs.setString(7,userLon);

            cs.execute();
            rc = cs.getInt(1);
            
            logger.debug("rc : " + rc);
        } catch(SQLException e) {
            e.printStackTrace();
            logger.error("--- SQLException Caught ---");
            while (e != null) {
                logger.error("Message: " + e.getMessage());
                logger.error("SQLState: " + e.getSQLState());
                logger.error("ErrorCode: " + e.getErrorCode());
                e = e.getNextException();
            }
            rc = -100;
        } finally {
            try { cs.close(); } catch(Exception e) { logger.debug("Error in closing cs"); }
            try { conn.close(); } catch(Exception e) { logger.debug("Error in closing conn"); }
        }
        
        logger.debug("Exit addEvent");        
        return(rc);
    }
}
