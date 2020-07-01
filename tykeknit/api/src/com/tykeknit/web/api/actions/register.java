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
  * $Id: register.java,v 1.12 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */

 /**
  * Method:  register
  * Registers user with the system.
  *
  * Required Parameters:
  *  txtFirstName    - First Name
  *  txtLastName     - Last Name
  *  txtEmail        - Email Address (This also acts as username)
  *
  * Optional Parameters:
  *  txtDOB          - Date of Birth (yyyy-MM-DD)
  *  imgFile         - Picture of the user
  *  txtParentType   - Parent Type (Mom, Dad)
  *  txtZip          - Zipcode
  *
  * Authentication Required:
  *      No
  *
  * Returns:
  * (start code)
  *  { "methodName" : "register",
  *    "response" : "{zipGeoLoc : {Lat : "", Long : ""}}",
  *    "responseStatus" : "success"
  *  }
  * (end code)
  *
  * Exception:
  *    -1   -   Error Adding picture to the database
  *    -2   -   User with this email address already exist in the database
  *  -100   -   SQLException
  *
  *  See Also:
  *      <LoginAction>, <deleteAccount>
  *
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.registerForm;
import com.tykeknit.web.api.beans.Operations;
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
import org.apache.struts.upload.FormFile;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


public class

register extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      registerForm registerForm=null;
      FormFile imgFile;
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
      String confirmCode = null;


      try {
           logger.debug("Enter");
           
           registerForm = (registerForm)form;
           
           if (registerForm.getImgFile() == null || "".equals(registerForm.getImgFile())) {
              imgFile = null;
           }
           else {
               imgFile = registerForm.getImgFile();
               logger.debug(imgFile.getFileName());
           }
           
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
           
           smtpHost = (String)context.getAttribute("smtpHost");
           domainName = (String)context.getAttribute("domain");
           appURL = (String)context.getAttribute("appURL");
           
           registerForm.setTxtZip("22209");
           registerForm.setTxtDOB("1971-01-01");
           
           logger.debug("smtpHost:" + smtpHost);
           logger.debug("domainName:" + domainName);
           logger.debug("appURL:" + appURL);
           

           PrintWriter out=response.getWriter();

           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

           rc = Operations.registerUser(registerForm,ds);  
          
           if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.register"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
           }
           else {
              confirmCode = String.valueOf(rc);
              if (imgFile == null || imgFile.getFileSize() == 0) {
              }
              else {
                  rc = Operations.addImage(imgFile, rc, ds, 1);
              }
              
              if (rc < 0) {
                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.register"));
                  
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.register.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.register.message.failure.reasonstr.2"));

                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              }
              else if (rc == 0) {
                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.register"));
                  
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.register.message.failure.reasoncode.3"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.register.message.failure.reasonstr.3"));

                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              }
              else {
                  DBConnection dbcon = new DBConnection(ds);
                  
                  sqlString  = "select a.latitude "
                             +       ",a.longitude ";
                  sqlString += "from zip_codes   a ";
                  sqlString += "where a.zip = '" + registerForm.getTxtZip() + "' ";

                  logger.debug(sqlString);
                  rs = dbcon.executeQuery(sqlString);

                  JSONObject geoJSON = new JSONObject();

                  if (!rs.next()) {
                      jsonResponse.put(messageResources.getMessage("json.response.methodname.register.displayname.data1"),messageResources.getMessage("json.response.methodname.register.message.failure.reasonstr.4"));
                  }
                  else {
                      geoJSON.put("Lat",rs.getString(1));
                      geoJSON.put("Long",rs.getString(2));

                      jsonResponse.put(messageResources.getMessage("json.response.methodname.register.displayname.data1"),geoJSON);
                  }
                  logger.debug("geoJSON : " + geoJSON.toString());
                  
                  dbcon.free(rs);

                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.register"));
                  
                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),geoJSON);
                  
                  recipient = registerForm.getTxtEmail();
                  from = messageResources.getMessage("emailmessage.from");
                  subject = messageResources.getMessage("emailmessage.register.subject");
                  message = messageResources.getMessage("emailmessage.register.body");

                  message += "<" + appURL + "/" + messageResources.getMessage("json.response.methodname.registerConfirm") + ".do?confirmCode=" + confirmCode + "><br><br>";
                  message += messageResources.getMessage("emailmessage.signature");
                  message += messageResources.getMessage("emailmessage.footer");
                  
                  message = message.replaceAll("<br>", "\n");
                  message = message.replace("<FName>", registerForm.getTxtFirstName());

                  logger.debug(message);

                  GeneralUtil.postMail(recipient,subject,message,from,smtpHost);
              }
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
