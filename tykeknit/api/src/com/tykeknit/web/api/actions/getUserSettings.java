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
  * $Id: getUserSettings.java,v 1.2 2011/04/07 15:53:39 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getUserSettingsForm;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.api.beans.UserSettings;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  getUserSettings
 * Retrives user settings
 *
 * Required Parameters:
 *  None
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getUserSettings",
 *   "response" : { txtUserProfileSetting : "",
 *                  txtUserContactSetting : ""
 *                  boolUserNotificationMembershipRequest : ""
 *                  boolUserNotificationPlaydate : "",
 *                  boolUserNotificationPlaydateMessageBoard : "",
 *                  boolUserNotificationGeneralMessages : "",
 *                  boolUserLocationCurrentLocationSetting : ""
 *                },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   - Invalid Session
 *
 *  See Also:
 *      <updateSettings>
 *
 */

public class

getUserSettings extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getUserSettingsForm getUserSettingsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;

      try {
           logger.debug("Enter");
           
           getUserSettingsForm=(getUserSettingsForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
           
           logger.debug("jdbs-DS:" + jdbcDS);
           
           PrintWriter out=response.getWriter();

          HttpSession session = request.getSession();
          User user = (User) session.getAttribute("user");
          UserSettings userSettings = (UserSettings) session.getAttribute("UserSettings");

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String data1 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getUserSettings.displayname.data7");

          jsonResponse.put(data1,userSettings.getTxtUserProfileSetting());
          jsonResponse.put(data2,userSettings.getTxtUserContactSetting());
          jsonResponse.put(data3,userSettings.getBoolUserNotificationMembershipRequest());
          jsonResponse.put(data4,userSettings.getBoolUserNotificationPlaydate());
          jsonResponse.put(data5,userSettings.getBoolUserNotificationPlaydateMessageBoard());
          jsonResponse.put(data6,userSettings.getBoolUserNotificationGeneralMessages());
          jsonResponse.put(data7,userSettings.getBoolUserLocationCurrentLocationSetting());

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getUserSettings"));
         
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
