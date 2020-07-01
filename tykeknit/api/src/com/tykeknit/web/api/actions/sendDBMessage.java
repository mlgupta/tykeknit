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
  * $Id: sendDBMessage.java,v 1.7 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.sendDBMessageForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
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
 * Method:  sendDBMessage
 *  Sends a message to another user in tykeknit via email and also via tykeknit message system
 *
 * Required Parameters:
 *  txtToUserTblPk      - To User ID
 *  txtMsgSubject       - Message Subject
 *
 * Optional Parameters:
 *  txtMsgBody          - Message Body
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "sendDBMessage",
 *  "response" : "",
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *  -1     -   Invalid txtToUserTblPk
 *
 *  See Also:
 *      <getDBMessageDetails>
 *
 */

public class

sendDBMessage extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      sendDBMessageForm sendDBMessageForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;
      ResultSet rs = null;
      String sqlString = null;

      String recipient=null;
      String subject=null;
      String message=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;

      try {
           logger.debug("Enter");

           sendDBMessageForm=(sendDBMessageForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);
           
           smtpHost = (String)context.getAttribute("smtpHost");
           domainName = (String)context.getAttribute("domain");

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

           int userTblPk = Integer.parseInt(user.getUserTblPk());
           String userFName = user.getUserFName();
           String userLName = user.getUserLName();
           String userEmail = user.getUserEmail();

          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.user_email "
                     +       ",a.user_notification_general_messages ";
          sqlString += "from user_tbl            a ";
          sqlString += "where a.user_tbl_pk = " + Integer.parseInt(sendDBMessageForm.getTxtToUserTblPk()) + " "
                     +   "and a.date_eff <= CURRENT_DATE "
                     +   "and a.date_inac > CURRENT_DATE ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          if(!rs.next()) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendDBMessage"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.sendDBMessage.message.failure.reasoncode.1"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.sendDBMessage.message.failure.reasonstr.1"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

              out.print(jsonStatus.toString());
              out.close();
              out.flush();

              return mapping.findForward(null);
          }
          
          recipient = rs.getString(3);
          
          boolean user_notification_general_messages = rs.getBoolean(4);

          dbcon.free(rs);                      
          
           rc = Operations.sendDBMessage(userTblPk, Integer.parseInt(sendDBMessageForm.getTxtToUserTblPk()), sendDBMessageForm.getTxtMsgSubject(), sendDBMessageForm.getTxtMsgBody(), ds);

           if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendDBMessage"));
             
             jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
             jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));

             jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

             out.print(jsonStatus.toString());
             out.close();
             out.flush();

             return mapping.findForward(null);
          }
          
          if (user_notification_general_messages == true) {
              from = messageResources.getMessage("emailmessage.from");
              subject = messageResources.getMessage("emailmessage.sendDBMessage.subject");
              subject = subject.replace("<FName>", user.getUserFName());
              subject = subject.replace("<LName>", user.getUserLName());

              message = messageResources.getMessage("emailmessage.sendDBMessage.body");
              message += messageResources.getMessage("emailmessage.signature");
              message += messageResources.getMessage("emailmessage.footer");

              message = message.replaceAll("<FName>", user.getUserFName());
              message = message.replaceAll("<LName>", user.getUserLName());
              message = message.replaceAll("<MessageSubject>", sendDBMessageForm.getTxtMsgSubject());
              message = message.replaceAll("<MessageBody>", sendDBMessageForm.getTxtMsgBody());
              message = message.replaceAll("<br>", "\n");

              logger.debug(message);

              GeneralUtil.postMail(recipient,subject,message,from,smtpHost);
          }

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.sendDBMessage"));
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
