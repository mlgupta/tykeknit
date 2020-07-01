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
  * $Id: updateUser.java,v 1.5 2011/04/15 13:05:40 manish Exp $
  *****************************************************************************
  */

 /**
  * Method:  updateUser
  * Updates user
  *
  * Required Parameters:
  *  txtFirstName    - First Name
  *  txtLastName     - Last Name
  *  txtDOB          - Date of Birth (yyyy-MM-DD)
  *  txtZip          - Zip Code
  *  txtParentType   - Parent Type (Mom, Dad)
  *
  * Optional Parameters:
  *  txtPassword     - New Password
  *  imgFile         - Picture of the user
  *
  * Authentication Required:
  *      Yes
  *
  * Returns:
  * (start code)
  *  { "methodName" : "updateUser",
  *    "response" : "",
  *    "responseStatus" : "success"
  *  }
  * (end code)
  *
  * Exception:
  *  -100   -   SQLException
  *  -401   -   Invalid Session
  *
  *  See Also:
  *      <register>
  *
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.updateUserForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.DBConnection;
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
import org.apache.struts.upload.FormFile;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


public class
updateUser extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      updateUserForm updateUserForm=null;
      FormFile imgFile;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      int rc = 0;

      try {
           logger.debug("Enter");
           
           updateUserForm = (updateUserForm)form;
           
           if (updateUserForm.getImgFile() == null || "".equals(updateUserForm.getImgFile())) {
              imgFile = null;
           }
           else {
               imgFile = updateUserForm.getImgFile();
               logger.debug(imgFile.getFileName());
           }
           
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
           
           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           String userTblPk = user.getUserTblPk();
           
           PrintWriter out=response.getWriter();

           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();

           rc = Operations.updateUser(updateUserForm,Integer.parseInt(userTblPk), ds);  
          
           if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateUser"));
              
              if (rc == -1) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.updateUser.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.updateUser.message.failure.reasonstr.1"));
              }
              else {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));
              }

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              return mapping.findForward(null);
           }
           else {
              if (imgFile == null || imgFile.getFileSize() == 0) {
              }
              else {
                  DBConnection dbcon = new DBConnection(ds);
                  
                  sqlString  = "select a.image_tbl_pk "
                             +       ",a.image_oid ";
                  sqlString += "from image_tbl            a "
                             +     ",user_tbl             b ";
                  sqlString += "where b.user_tbl_pk = " + userTblPk + " "
                             +   "and b.date_eff <= CURRENT_DATE "
                             +   "and b.date_inac > CURRENT_DATE "
                             +   "and a.image_tbl_pk = b.image_tbl_fk ";

                  logger.debug(sqlString);
                  
                  rs = dbcon.executeQuery(sqlString);            

                  if (rs.next()) {
                      rc = Operations.updateImage(imgFile, Integer.parseInt(rs.getString(1)), rs.getLong(2), ds);
                  }
                  else {
                      rc = Operations.addImage(imgFile, Integer.parseInt(userTblPk), ds, 1);
                  }
                  dbcon.free(rs);
                  
                  if (rc < 0) {
                      jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                      jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateUser"));
                      
                      jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.updateUser.message.failure.reasoncode.2"));
                      jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.updateUser.message.failure.reasonstr.2"));

                      jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
                      
                      out.print(jsonStatus.toString());
                      out.close();
                      out.flush();
                      return mapping.findForward(null);
                  }
              }
           }
           
           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateUser"));
          
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
