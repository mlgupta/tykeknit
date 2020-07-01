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
  * $Id: addSecondaryPR.java,v 1.7 2011/04/18 11:08:01 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.addSecondaryPRForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.GeneralUtil;
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
 * Method:  addSecondaryPR
 * Registers user's spouse with the system.
 *
 * Required Parameters:
 *  txtEmail        - Email Address of spouse
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "addSecondaryPR",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *    -1   -   Addition of second spouse not allowed
 *
 *  See Also:
 *      <removeSecondaryPR>
 *
 */

public class

addSecondaryPR extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      addSecondaryPRForm addSecondaryPRForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;
      String recipient=null;
      String subject=null;
      String message=null;
      String from=null;
      String smtpHost=null;
      String domainName = null;
      String appURL = null;
      
      String confirmCode = null;

      try {
           logger.debug("Enter");

           addSecondaryPRForm=(addSecondaryPRForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
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
           
           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();
          
          rc = Operations.addSecondaryPR(addSecondaryPRForm,Integer.parseInt(userTblPk),ds);  
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.addsecondarypr"));
              
              if (rc == -1) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.addsecondarypr.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.addsecondarypr.message.failure.reasonstr.1"));
              }
              else {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));
              }
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          }
          else {
              confirmCode = String.valueOf(rc);

              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.addsecondarypr"));
              
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),"");
              
              recipient = addSecondaryPRForm.getTxtEmail();
              from = messageResources.getMessage("emailmessage.from");
              subject = messageResources.getMessage("emailmessage.addSecondaryPR.subject");
              subject = subject.replaceAll("<Spouse>", user.getUserFName());
              
              rc = Operations.getUserFromEmail(recipient,ds);  
              
              if (rc < 0) {
                  message = messageResources.getMessage("emailmessage.addSecondaryPR.body");
              }
              else {
                  message = messageResources.getMessage("emailmessage.addSecondaryPR.body.confirmation");
                  message += "<" + appURL + "/" + messageResources.getMessage("json.response.methodname.secondaryPRConfirm") + ".do?confirmCode=" + confirmCode + "><br><br>";
              }

              message += user.getUserFName();
              message += messageResources.getMessage("emailmessage.footer");
              message = message.replaceAll("<br>", "\n");

              logger.debug(message);

              GeneralUtil.postMail(recipient,subject,message,from,smtpHost);
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
