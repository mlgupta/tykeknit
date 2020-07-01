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
  * $Id: LoginAction.java,v 1.15 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.LoginForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.api.beans.UserSettings;
import com.tykeknit.web.general.beans.DBConnection;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.ResultSet;

import javax.naming.Context;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  LoginAction
 * Verifies userid and password and if successful creates a session.
 *
 * Required Parameters:
 *  txtUserId       - User ID
 *  txtPassword     - Password
 *
 * Optional Parameters:
 *  txtDToken       - Device Token
 *
 * Authentication Required:
 *      No
 *
 * Returns:
 * (start code)
 * { "methodName" : "LoginAction",
 *   "response" : { "sessionID" : "",
 *                   zipGeoLoc : {Lat : "", Long : ""},
 *                   txtUserTblPk: ""
 *                   AccountConfirmationFlag : "",
 *                   AccountDaysEff : "",
 *                   fname : "",
 *                   lname : "",
 *                   email : "",
 *                   ProfileCompletionStatus: "",
 *                   picURL : ""
 *                },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   - Incorrect Username/Password 
 *  -100   - SQLException
 *
 *  See Also:
 *      <logout>
 *
 */

public class

LoginAction extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      LoginForm LoginForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      
      int rc = 0;

      try {
           logger.debug("Enter");
           
           LoginForm=(LoginForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
           
           logger.debug("jdbs-DS:" + jdbcDS);
           
           PrintWriter out=response.getWriter();

          String username = LoginForm.getTxtUserId();
          String password = LoginForm.getTxtPassword();

          HttpSession session = request.getSession();

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);
          
          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.user_id "
                     +       ",a.password "
                     +       ",a.user_tbl_pk "
                     +       ",a.user_profile_setting "
                     +       ",a.user_contact_setting "
                     +       ",a.user_notification_membership_request "
                     +       ",a.user_notification_playdate "
                     +       ",a.user_notification_playdate_message_board "
                     +       ",a.user_notification_general_messages "
                     +       ",a.user_location_current_location_setting "
                     +       ",a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.user_email "
                     +       ",a.zipcode "
                     +       ",(CURRENT_DATE - a.date_eff) "
                     +       ",a.account_confirmation_flag "
                     +       ",a.user_location_lat "
                     +       ",a.user_location_long "
                     +       ",a.image_tbl_fk ";
          sqlString += "from user_tbl            a ";
          sqlString += "where lower(a.user_id) = lower('" + username + "') "
                     +   "and a.date_eff <= CURRENT_DATE "
                     +   "and a.date_inac > CURRENT_DATE ";

          logger.debug(sqlString);
          
          rs = dbcon.executeQuery(sqlString);            
          
          String upwd = "";
          int userTblPk  = 0;
          
          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          if (!rs.next()) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.loginaction"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.3"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.3"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              dbcon.free(rs);                      

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              return mapping.findForward(null);
          }

          UserSettings userSettings = new UserSettings();
          
          upwd = rs.getString(2);
          userTblPk = rs.getInt(3);
          
          userSettings.setTxtUserProfileSetting(rs.getString(4));
          userSettings.setTxtUserContactSetting(rs.getString(5));
          userSettings.setBoolUserNotificationMembershipRequest(rs.getBoolean(6));
          userSettings.setBoolUserNotificationPlaydate(rs.getBoolean(7));
          userSettings.setBoolUserNotificationPlaydateMessageBoard(rs.getBoolean(8));
          userSettings.setBoolUserNotificationGeneralMessages(rs.getBoolean(9));
          userSettings.setBoolUserLocationCurrentLocationSetting(rs.getBoolean(10));

          User user = new User(username, upwd);
          user.setUserTblPk(Integer.toString(userTblPk));
          user.setUserFName(rs.getString(11));
          user.setUserLName(rs.getString(12));
          user.setUserEmail(rs.getString(13));
          user.setUserZip(rs.getString(14));
          user.setAccount_days_eff(rs.getInt(15));
          user.setAccount_confirmation_flag(rs.getBoolean(16));
          user.setUserLat(rs.getString(17));
          user.setUserLong(rs.getString(18));
          
          String image_tbl_fk = rs.getString(19);

          if (user.passwordMatch(password) == false) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.loginaction"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.3"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.3"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

              dbcon.free(rs);
              
              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              
              return mapping.findForward(null);
          }

          if (LoginForm.getTxtDToken() == null || "".equals(LoginForm.getTxtDToken())) {
          }
          else {
              logger.debug("Device Token:" + LoginForm.getTxtDToken());
              rc = Operations.setDeviceToken(userTblPk, LoginForm.getTxtDToken(), ds);
          }
          
          rs = null;
          
          sqlString  = "select a.latitude "
                     +       ",a.longitude ";
          sqlString += "from zip_codes   a ";
          sqlString += "where a.zip = '" + user.getUserZip() + "' ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);

          JSONObject geoJSON = new JSONObject();

          String data1 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data9");
          String data10 = messageResources.getMessage("json.response.methodname.loginaction.displayname.data10");

          String value10 = messageResources.getMessage("json.response.methodname.loginaction.value.data10");
          
          if (!rs.next()) {
              jsonResponse.put(data2,messageResources.getMessage("json.response.methodname.loginaction.message.failure.reasonstr.4"));
          }
          else {
              geoJSON.put("Lat",rs.getString(1));
              geoJSON.put("Long",rs.getString(2));
              
              jsonResponse.put(data2,geoJSON);
          }
          logger.debug("geoJSON : " + geoJSON.toString());
          
          jsonResponse.put(data3,user.isAccount_confirmation_flag());
          jsonResponse.put(data4,user.getAccount_days_eff());
          
          dbcon.free(rs);                      
          
          
          session.setAttribute("user", user);
          session.setAttribute("UserSettings", userSettings);
          
          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.loginaction"));
         
          jsonResponse.put(data1,session.getId());
          jsonResponse.put(data5,user.getUserTblPk());
          jsonResponse.put(data6,user.getUserFName());
          jsonResponse.put(data7,user.getUserLName());
          jsonResponse.put(data8,user.getUserEmail());
          jsonResponse.put(data9,Operations.profileCompletionStatus(Integer.parseInt(user.getUserTblPk()),ds));
          
          if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
              
          }
          else {
              jsonResponse.put(data10,value10 + image_tbl_fk);
          }

          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          
          out.print(jsonStatus.toString());
          out.close();
          out.flush();
      } catch (Exception e) {
        logger.error(e.toString());
      } finally {
         logger.debug("Exit");
      }
      return mapping.findForward(null);
    }
}
