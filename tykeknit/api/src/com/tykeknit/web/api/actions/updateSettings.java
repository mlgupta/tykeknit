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
  * $Id: updateSettings.java,v 1.5 2011/04/15 13:05:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.updateSettingsForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.api.beans.UserSettings;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

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
 * Method:  updateSettings
 * Updates user settings
 *
 * Required Parameters:
 *  txtUserProfileSetting                          - Who can see users profile (1-1st Degree, 2-2nd Degree, 3-All)
 *  txtUserContactSetting                          - Who can contact user (1-1st Degree, 2-2nd Degree, 3-All)
 *  boolUserNotificationMembershipRequest          - User wants to receive membership notifications (True/False)
 *  boolUserNotificationPlaydate                   - User wants to receive playdate notifications (True/False)
 *  boolUserNotificationPlaydateMessageBoard       - User wants to receive playdate wall messages (True/False)
 *  boolUserNotificationGeneralMessages            - User wants to receive general messages (True/False)
 *  boolUserLocationCurrentLocationSetting         - System to use users current location settings (True/False)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "updateSettings",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      
 *
 */

public class

updateSettings extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      updateSettingsForm updateSettingsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;

      try {
           logger.debug("Enter");

           updateSettingsForm=(updateSettingsForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

          int userTblPk = Integer.parseInt(user.getUserTblPk());
          
          rc = Operations.updateSettings(userTblPk, updateSettingsForm,  ds);

          if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateSettings"));
             
             jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
             jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));

             jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

             out.print(jsonStatus.toString());
             out.close();
             out.flush();

             return mapping.findForward(null);
          }
          else {
              UserSettings userSettings = new UserSettings();
              
              userSettings.setTxtUserProfileSetting(updateSettingsForm.getTxtUserProfileSetting());
              userSettings.setTxtUserContactSetting(updateSettingsForm.getTxtUserContactSetting());
              userSettings.setBoolUserNotificationMembershipRequest(updateSettingsForm.getBoolUserNotificationMembershipRequest());
              userSettings.setBoolUserNotificationPlaydate(updateSettingsForm.getBoolUserNotificationPlaydate());
              userSettings.setBoolUserNotificationPlaydateMessageBoard(updateSettingsForm.getBoolUserNotificationPlaydateMessageBoard());
              userSettings.setBoolUserNotificationGeneralMessages(updateSettingsForm.getBoolUserNotificationGeneralMessages());
              userSettings.setBoolUserLocationCurrentLocationSetting(updateSettingsForm.getBoolUserLocationCurrentLocationSetting());

              session.setAttribute("UserSettings", userSettings);

              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateSettings"));
              
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),"");
              
          }
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
