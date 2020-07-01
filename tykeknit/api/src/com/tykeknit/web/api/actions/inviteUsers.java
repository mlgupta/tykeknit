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
  * $Id: inviteUsers.java,v 1.8 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.inviteUsersForm;
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

import org.json.JSONArray;
import org.json.JSONObject;


/**
 * Method:  inviteUsers
 * Invite email address contacts within users addressbook.
 *
 * Required Parameters:
 *  txtEmails        - List of email addresses for invitation. List needs to be in the following JSON format
 *  (start code)
 *  {
 *   Emails:
 *        [{
 *          email : ""
 *         },
 *         {
 *          email : ""
 *         } 
 *        ]
 *   }     
 *  (end code)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "inviteUsers",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *
 *  See Also:
 *      <uploadFBContacts>, <uploadContacts>
 *
 */

public class

inviteUsers extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      inviteUsersForm inviteUsersForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      int rc = 0;
      String recipient=null;
      String subject=null;
      String message_tykeknit_member=null;
      String message_tykeknit_not_member=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;
      String appURL = null;

      try {
           logger.debug("Enter");
           
          inviteUsersForm=(inviteUsersForm)form;
          context=servlet.getServletContext();
          jdbcDS = (String)context.getAttribute("jdbcDS");
          
          logger.debug("jdbs-DS:" + jdbcDS);

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);

          smtpHost = (String)context.getAttribute("smtpHost");
          domainName = (String)context.getAttribute("domain");
          appURL = (String)context.getAttribute("appURL");
          
          logger.debug("smtpHost:" + smtpHost);
          logger.debug("domainName:" + domainName);
          logger.debug("appURL:" + appURL);
          
          HttpSession session = request.getSession();
          
          User user = (User) session.getAttribute("user");

          PrintWriter out=response.getWriter();

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();
          
          String txtEmails = inviteUsersForm.getTxtEmails();
          
          logger.debug("txtEmails: " + txtEmails);

          // JSON to emails
          JSONObject jsonEmailStr = new JSONObject(txtEmails);
          JSONArray jsonEmailArray = new JSONArray();
          jsonEmailArray = jsonEmailStr.getJSONArray("Emails");

          // Call Add Invitation to Operations
          rc = Operations.knitInviteUsers(jsonEmailArray,Integer.parseInt(userTblPk),ds);
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.inviteusers"));
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          }
          else {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.inviteusers"));
      
              from = messageResources.getMessage("emailmessage.from");
              subject = messageResources.getMessage("emailmessage.joinKnitRequest.subject");
              subject = subject.replace("<FName>", user.getUserFName());
              subject = subject.replace("<LName>", user.getUserLName());
            
              message_tykeknit_member = messageResources.getMessage("emailmessage.joinKnitRequest.body");

              message_tykeknit_member += "<" + appURL + "/" + messageResources.getMessage("json.response.methodname.knitConfirm") + ".do?confirmCode=<confirmCode>&userTblPk=<userTblPk>><br><br>";
              
              message_tykeknit_member += user.getUserFName();
              message_tykeknit_member += messageResources.getMessage("emailmessage.footer");
              
              message_tykeknit_member = message_tykeknit_member.replaceAll("<br>", "\n");
              message_tykeknit_member = message_tykeknit_member.replace("<FName>", user.getUserFName());
              message_tykeknit_member = message_tykeknit_member.replace("<LName>", user.getUserLName());

              logger.debug(message_tykeknit_member);

              message_tykeknit_not_member = messageResources.getMessage("emailmessage.joinKnitRequest.body.2");
              message_tykeknit_not_member += messageResources.getMessage("emailmessage.signature");
              message_tykeknit_not_member += messageResources.getMessage("emailmessage.footer");
              
              message_tykeknit_not_member = message_tykeknit_not_member.replaceAll("<br>", "\n");
              message_tykeknit_not_member = message_tykeknit_not_member.replace("<FName>", user.getUserFName());
              message_tykeknit_not_member = message_tykeknit_not_member.replace("<LName>", user.getUserLName());

              logger.debug(message_tykeknit_not_member);
        
              int jsonIndex = 0;
              int jsonEmailArrayLength = jsonEmailArray.length();
              JSONObject jsonEmail = new JSONObject();
              
              DBConnection dbcon = new DBConnection(ds);
          
              while (jsonIndex < jsonEmailArrayLength) {
                  jsonEmail =  jsonEmailArray.getJSONObject(jsonIndex);
                  ++jsonIndex;
                  
                  recipient = jsonEmail.getString("email");
                  
                  sqlString  = "select a.user_tbl_pk "
                             + "      ,b.message_tbl_pk ";
                  sqlString += "from user_tbl            a "
                             + "    ,message_tbl         b ";
                  sqlString += "where lower(a.user_id) = lower('" + recipient + "') "
                             +   "and a.date_eff <= CURRENT_DATE "
                             +   "and a.date_inac > CURRENT_DATE "
                             +   "and a.user_tbl_pk = b.message_to_user_tbl_fk "
                             +   "and b.message_from_user_tbl_fk =" + user.getUserTblPk() + " ";

                  logger.debug(sqlString);
                  
                  rs = dbcon.executeQuery(sqlString);            

                  if (rs.next()) {
                      message_tykeknit_member = message_tykeknit_member.replaceAll("<confirmCode>", rs.getString(2));
                      message_tykeknit_member = message_tykeknit_member.replaceAll("<userTblPk>", rs.getString(1));
                    
                      GeneralUtil.postMail(recipient,subject,message_tykeknit_member,from,smtpHost);
                  }
                  else {
                      GeneralUtil.postMail(recipient,subject,message_tykeknit_not_member,from,smtpHost);
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