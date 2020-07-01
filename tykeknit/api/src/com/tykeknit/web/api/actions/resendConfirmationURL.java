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
  * $Id: resendConfirmationURL.java,v 1.5 2011/04/18 11:08:01 manish Exp $
  *****************************************************************************
  */

 /**
  * Method:  resendConfirmationURL
  * Resends account confirmation URL to the registered email address
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
  *  { "methodName" : "resendConfirmationURL",
  *    "response" : "",
  *    "responseStatus" : "success"
  *  }
  * (end code)
  *
  * Exception:
  *  -1     -   Error sending mail
  *  -100   -   SQLException
  *
  *  See Also:
  *      <LoginAction>
  *
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.resendConfirmationURLForm;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.GeneralUtil;
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

public class
resendConfirmationURL extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      resendConfirmationURLForm resendConfirmationURLForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);

      String recipient=null;
      String subject=null;
      String message=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;
      String appURL = null;


      try {
           logger.debug("Enter");
           
           resendConfirmationURLForm = (resendConfirmationURLForm)form;
           
           context=servlet.getServletContext();
           
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

           if (user == null) {
             logger.error("Invalid Session");

             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.resendConfirmationURL"));

             jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.1"));
             jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.1"));
             
             jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

             out.print(jsonStatus.toString());
             out.close();
             out.flush();

             return mapping.findForward(null);
           }

                  
           recipient = user.getUserEmail();
           from = messageResources.getMessage("emailmessage.from");
           subject = messageResources.getMessage("emailmessage.resendConfirmationURL.subject");
           message = messageResources.getMessage("emailmessage.resendConfirmationURL.body");

           message += "<" + appURL + "/" + messageResources.getMessage("json.response.methodname.registerConfirm") + ".do?confirmCode=" + user.getUserTblPk() + "><br><br>";
           message += messageResources.getMessage("emailmessage.signature");
           message += messageResources.getMessage("emailmessage.footer");
                  
           message = message.replaceAll("<br>", "\n");
           message = message.replaceAll("<FName>", user.getUserFName());

           logger.debug(message);

           GeneralUtil.postMail(recipient,subject,message,from,smtpHost);

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.resendConfirmationURL"));
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
