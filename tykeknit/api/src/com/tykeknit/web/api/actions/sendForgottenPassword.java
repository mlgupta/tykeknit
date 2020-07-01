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
  * $Id: sendForgottenPassword.java,v 1.4 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.sendForgottenPasswordForm;
import com.tykeknit.web.general.beans.DBConnection;
import com.tykeknit.web.general.beans.GeneralUtil;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.ResultSet;

import javax.naming.Context;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  sendForgottenPassword
 * Sends forgotten userid and password to a confirmed user via email
 *
 * Required Parameters:
 *  txtUserId       - User ID
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      No
 *
 * Returns:
 * (start code)
 * { "methodName" : "sendForgottenPassword",
 *   "response" : "",
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -1     - email exception
 *  -2     - Account unconfirmed
 *  -100   - SQLException
 *
 *  See Also:
 *      <resendConfirmationURL>
 *
 */

public class

sendForgottenPassword extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      sendForgottenPasswordForm sendForgottenPasswordForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      String recipient=null;
      String subject=null;
      String message=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;
      String appURL = null;

      try {
           logger.debug("Enter");
           
           sendForgottenPasswordForm=(sendForgottenPasswordForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
           
           logger.debug("jdbs-DS:" + jdbcDS);

           smtpHost = (String)context.getAttribute("smtpHost");
           domainName = (String)context.getAttribute("domain");
           appURL = (String)context.getAttribute("appURL");
          
           logger.debug("smtpHost:" + smtpHost);
           logger.debug("domainName:" + domainName);
           logger.debug("appURL:" + appURL);
          
           PrintWriter out=response.getWriter();

           String username = sendForgottenPasswordForm.getTxtUserId().toLowerCase();

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);
          
          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.user_id "
                     +       ",a.password "
                     +       ",a.user_tbl_pk "
                     +       ",a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.user_email "
                     +       ",zipcode "
                     +       ",(CURRENT_DATE - date_eff) "
                     +       ",a.account_confirmation_flag ";
          sqlString += "from user_tbl            a ";
          sqlString += "where lower(a.user_id) = '" + username + "' "
                     +   "and a.date_eff <= CURRENT_DATE "
                     +   "and a.date_inac > CURRENT_DATE ";

          logger.debug(sqlString);
          
          rs = dbcon.executeQuery(sqlString);            
          
          String upwd = "";
          int userTblPk  = 0;
          String userFName = "";
          
          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          if (!rs.next()) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendForgottenPassword"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.3"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.3"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              dbcon.free(rs);                      

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              return mapping.findForward(null);
          }

          upwd = rs.getString(2);
          userTblPk = rs.getInt(3);
          userFName = rs.getString(4);

/*          
          if (rs.getBoolean(9) == false) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendForgottenPassword"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.sendForgottenPassword.message.failure.reasoncode.1"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.sendForgottenPassword.message.failure.reasonstr.1"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              
              return mapping.findForward(null);
          }
*/
          dbcon.free(rs);                      

          recipient = username;
          from = messageResources.getMessage("emailmessage.from");
          subject = messageResources.getMessage("emailmessage.sendForgottenPassword.subject");
          message = messageResources.getMessage("emailmessage.sendForgottenPassword.body");

          message += "UserName: " + username + "<br>";
          message += "Password: " + upwd + "<br><br>";
          message += messageResources.getMessage("emailmessage.signature");
          message += messageResources.getMessage("emailmessage.footer");
          
          message = message.replaceAll("<br>", "\n");
          message = message.replaceAll("<FName>", userFName);

          logger.debug(message);

          GeneralUtil.postMail(recipient,subject,message,from,smtpHost);
          
          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendForgottenPassword"));
         
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),"");
          
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
