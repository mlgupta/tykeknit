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
  * $Id: postWallMessage.java,v 1.6 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.postWallMessageForm;
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
 * Method:  postWallMessage
 *  Posts a message to a playdate wall
 *
 * Required Parameters:
 *  txtPid          - Playdate ID
 *  txtMessage      - Wall Message
 *
 * Optional Parameters:
 *  none
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "postWallMessage",
 *    "response" : "{messageID=xxx}",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid Playdate ID
 *
 *  See Also:
 *      <deleteWallMessage>
 *
 */

public class

postWallMessage extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      postWallMessageForm postWallMessageForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      int rc = 0;
          
      String recipient=null;
      String subject=null;
      String message=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;
      String appURL = null;

      try {
           logger.debug("Enter");

           postWallMessageForm=(postWallMessageForm)form;
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
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();

          rc = Operations.wallMessagesAuthorization(Integer.parseInt(userTblPk), Integer.parseInt(postWallMessageForm.getTxtPid()), ds);

          if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.postwallmessage"));
             
             if (rc == -1) {
                 jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.postwallmessage.message.failure.reasoncode.1"));
                 jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.postwallmessage.message.failure.reasonstr.1"));
             }
             else if (rc == -2) {
                 jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                 jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));
             }

             jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

             out.print(jsonStatus.toString());
             out.close();
             out.flush();

             return mapping.findForward(null);
          }
          
          rc = Operations.postWallMessage(postWallMessageForm,Integer.parseInt(userTblPk),ds);  
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.postwallmessage"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          }
          else {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.postwallmessage"));

              jsonResponse.put(messageResources.getMessage("json.response.methodname.postwallmessage.displayname.data1"),rc);
              
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              from = messageResources.getMessage("emailmessage.from");
              subject = messageResources.getMessage("emailmessage.postWallMessage.subject");
              subject = subject.replace("<FName>", user.getUserFName());
              subject = subject.replace("<LName>", user.getUserLName());

              message = messageResources.getMessage("emailmessage.postWallMessage.body");

              message += " \"" + postWallMessageForm.getTxtMessage() + "\"<br><br>";

              message += messageResources.getMessage("emailmessage.signature");
              message += messageResources.getMessage("emailmessage.footer");
              
              message = message.replaceAll("<FName>", user.getUserFName());
              message = message.replaceAll("<LName>", user.getUserLName());
              message = message.replaceAll("<br>", "\n");

              logger.debug(message);

              DBConnection dbcon = new DBConnection(ds);

              sqlString  = "select a.playdate_name ";
              sqlString += "from playdate_tbl      a ";
              sqlString += "where a.playdate_tbl_pk = " + postWallMessageForm.getTxtPid() + " ";

              logger.debug(sqlString);

              rs = dbcon.executeQuery(sqlString);           
              
              rs.next();
              message = message.replaceAll("<PlaydateName>", rs.getString(1));

              sqlString  = "select distinct a.user_id "
                         +        ",a.user_notification_playdate_message_board "
                         +        ",a.user_fname ";
              sqlString += "from user_tbl            a "
                         +     ",playdate_participant_tbl b ";
              sqlString += "where a.user_tbl_pk = b.parent_user_tbl_fk " 
                         +   "and b.playdate_tbl_fk = " + postWallMessageForm.getTxtPid() + " "
                         +   "and a.date_eff <= CURRENT_DATE "
                         +   "and a.date_inac > CURRENT_DATE ";

              logger.debug(sqlString);
              
              rs = dbcon.executeQuery(sqlString);            
              
              while (rs.next()) {
                if (rs.getBoolean(2) == true) {
                    recipient = rs.getString(1);
                    GeneralUtil.postMail(recipient,subject,message,from,smtpHost);
                }
              }
              
              dbcon.free(rs);
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
