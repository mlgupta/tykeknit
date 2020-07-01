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
  * $Id: playdateRequest.java,v 1.12 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.playdateRequestForm;
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
 * Method:  playdateRequest
 * Organizes a playdate
 *
 * Required Parameters:
 *  txtOrganiserCid     - Organizer child ID (Needs to to be in the JSON string form {OrganiserCids:[{cid:xx},{cid:xx},..,{cid:xx}]}
 *  txtPlaydateName     - Playdate Name
 *  txtLocation         - Location of the Playdate
 *  txtDate             - Start Date of Playdate (yyyy-MM-DD)
 *  txtEndDate          - End Date of Playdate (yyyy-MM-DD)
 *  txtStartTime        - Start Time of Playdate (HH24:MI:SS)
 *  txtEndTime          - End Time of Playdate (HH24:MI:SS)
 *  txtInvitees         - List of Invitees (Needs to to be in the JSON string form {Invitees:[{Parent:yy,Tykes:[{cid:xx},{cid:xx}]},..,{Parent:yy,Tykes:[{cid:xx},{cid:xx}]}]}
 *
 * Optional Parameters:
 *  txtMessage          - Message for Playdate
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "playdateRequest",
 *   "response" : { "PlaydateID" : 41 },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *  -1     -   Invalid OrganiserCids List
 *
 *  See Also:
 *      <postRSVP>
 *
 */

public class

playdateRequest extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      playdateRequestForm playdateRequestForm=null;
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

           playdateRequestForm=(playdateRequestForm)form;
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
          
          rc = Operations.playdateRequest(playdateRequestForm,Integer.parseInt(userTblPk),ds);  
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest"));
              
              if (rc == -1) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest.message.failure.reasonstr.1"));
              }
              else if (rc == -2) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));
              }
              else if (rc == -3) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest.message.failure.reasonstr.2"));
              }
              else {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));
              }

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          }
          else {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.playdaterequest"));

              jsonResponse.put(messageResources.getMessage("json.response.methodname.playdaterequest.displayname.data1"),rc);
              
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              JSONObject jsonInviteesStr = new JSONObject(playdateRequestForm.getTxtInvitees());
              JSONArray jsonInviteesArray = new JSONArray();
              jsonInviteesArray = jsonInviteesStr.getJSONArray("Invitees");
              
              int jsonIndex = 0;
              int jsonInviteesArrayLength = jsonInviteesArray.length();

              from = messageResources.getMessage("emailmessage.from");
              subject = messageResources.getMessage("emailmessage.playdateRequest.subject");
              subject = subject.replace("<FName>", user.getUserFName());
              subject = subject.replace("<LName>", user.getUserLName());

              message = messageResources.getMessage("emailmessage.playdateRequest.body");

              message += messageResources.getMessage("emailmessage.signature");
              message += messageResources.getMessage("emailmessage.footer");
              
              message = message.replaceAll("<br>", "\n");
              message = message.replace("<FName>", user.getUserFName());
              message = message.replace("<LName>", user.getUserLName());
              message = message.replace("<Date>", playdateRequestForm.getTxtDate());
              message = message.replace("<Time>", playdateRequestForm.getTxtStartTime());
              message = message.replace("<Time>", playdateRequestForm.getTxtLocation());

              logger.debug(message);
              
              DBConnection dbcon = new DBConnection(ds);

              while (jsonIndex < jsonInviteesArrayLength) {
                  JSONObject jsonInvitee = new JSONObject();

                  jsonInvitee =  jsonInviteesArray.getJSONObject(jsonIndex);
                  ++jsonIndex;

                  sqlString  = "select a.user_id "
                            +        ",a.user_notification_playdate ";
                  sqlString += "from user_tbl            a ";
                  sqlString += "where a.user_tbl_pk = " + jsonInvitee.getString("Parent") + " "
                             +   "and a.date_eff <= CURRENT_DATE "
                             +   "and a.date_inac > CURRENT_DATE ";

                  logger.debug(sqlString);
                  
                  rs = dbcon.executeQuery(sqlString);            
                  rs.next();
                  
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
