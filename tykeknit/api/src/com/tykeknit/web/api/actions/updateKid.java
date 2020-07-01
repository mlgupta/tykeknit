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
  * $Id: updateKid.java,v 1.2 2011/04/26 15:58:30 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.updateKidForm;
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


/**
 * Method:  updateKid
 * Update Kids data
 *
 * Required Parameters:
 *  txtChildTblPk   - Child ID
 *  txtFirstName    - Kid's First Name
 *  txtLastName     - Kid's Last Name
 *  txtDOB          - Kid's Date of Birth (yyyy-MM-DD)
 *  txtGender       - Kid's Gender (M, F)
 *
 * Optional Parameters:
 *  imgFile         - Kid's Picture
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "updateKid",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *  -100   -   Error Adding picture to the database
 *
 *  See Also:
 *      <addKid>, <listKids>
 *
 */
public class

updateKid extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      updateKidForm updateKidForm=null;
      FormFile imgFile;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;
      
      ResultSet rs = null;
      String sqlString = null;


      try {
           logger.debug("Enter");

          updateKidForm=(updateKidForm)form;

          if (updateKidForm.getImgFile() == null || "".equals(updateKidForm.getImgFile())) {
             imgFile = null;
          }
          else {
              imgFile = updateKidForm.getImgFile();
              logger.debug(imgFile.getFileName());
          }

          context=servlet.getServletContext();
          jdbcDS = (String)context.getAttribute("jdbcDS");

          logger.debug("jdbs-DS:" + jdbcDS);
          
          PrintWriter out=response.getWriter();

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);

          HttpSession session = request.getSession();
          
          User user = (User) session.getAttribute("user");

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();
          
          rc = Operations.updateKid(updateKidForm,Integer.parseInt(userTblPk),ds);  
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateKid"));
              if (rc == -1) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.updateKid.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.updateKid.message.failure.reasonstr.2"));
              }
              else if (rc == -2) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));
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
          else if (imgFile == null || imgFile.getFileSize() == 0) {
          }
          else {
              DBConnection dbcon = new DBConnection(ds);
              
              sqlString  = "select a.image_tbl_pk "
                         +       ",a.image_oid ";
              sqlString += "from image_tbl            a "
                         +     ",child_tbl             b ";
              sqlString += "where b.child_tbl_pk = " + updateKidForm.getTxtChildTblPk() + " "
                         +   "and b.date_eff <= CURRENT_DATE "
                         +   "and b.date_inac > CURRENT_DATE "
                         +   "and a.image_tbl_pk = b.image_tbl_fk ";

              logger.debug(sqlString);
              
              rs = dbcon.executeQuery(sqlString);            

              if (rs.next()) {
                  rc = Operations.updateImage(imgFile, Integer.parseInt(rs.getString(1)), rs.getLong(2), ds);
              }
              else {
                  rc = Operations.addImage(imgFile, Integer.parseInt(updateKidForm.getTxtChildTblPk()), ds, 2);
              }
              
              dbcon.free(rs);

              if (rc < 0) {
                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateKid"));
                  
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.updateKid.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.updateKid.message.failure.reasonstr.1"));

                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
                  
                  out.print(jsonStatus.toString());
                  out.close();
                  out.flush();

                  return mapping.findForward(null);
              }
          }

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.updateKid"));
                  
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
