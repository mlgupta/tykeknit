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
  * $Id: displayPhoto.java,v 1.5 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

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
 * Method:  displayPhoto
 * Displays Photo
 *
 * Required Parameters:
 *  photoID    - Image ID (This needs to be embedded in the URL like /displayPhoto?photoID=xxx)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * None
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid Playdate ID
 *
 *  See Also:
 *      
 *
 */

public class

displayPhoto extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      byte[] content = null;

      try {
           logger.debug("Enter");
           
           String photoID = request.getParameter("photoID");

           JSONObject jsonStatus   = new JSONObject();
           JSONObject jsonResponse = new JSONObject();
           
           if (photoID == null || "".equals(photoID)) {
               PrintWriter out=response.getWriter();

               jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
               jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto"));
               
               jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasoncode.1"));
               jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasonstr.1"));

               jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

               out.print(jsonStatus.toString());
               out.close();
               out.flush();
               return mapping.findForward(null);
           }
           else {
               context=servlet.getServletContext();
               jdbcDS = (String)context.getAttribute("jdbcDS");
               
               logger.debug("jdbs-DS:" + jdbcDS);
               
               Context ctx = new javax.naming.InitialContext();
               DataSource ds = (DataSource)ctx.lookup(jdbcDS);

               HttpSession session = request.getSession();
               
               User user = (User) session.getAttribute("user");

               String userTblPk = user.getUserTblPk();
               
               int photoOwnerUserTblPk = Operations.getPhotoOwner(Integer.parseInt(photoID), ds);
               
               logger.debug("photoOwnerUserTblPk: " + photoOwnerUserTblPk);
               
               if (photoOwnerUserTblPk < 0) {
                   logger.debug("Photo not found for photoID: " + photoID);
                   PrintWriter out=response.getWriter();

                   jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                   jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto"));
                   
                   jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasoncode.2"));
                   jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasonstr.2"));

                   jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

                   out.print(jsonStatus.toString());
                   out.close();
                   out.flush();
                   return mapping.findForward(null);
               }
               
               int degreeCode = Operations.getDegreeCode(Integer.parseInt(userTblPk), photoOwnerUserTblPk, ds);

               DBConnection dbcon = new DBConnection(ds);

               sqlString  = "select a.user_profile_setting ";
               sqlString += "from user_tbl            a ";
               sqlString += "where a.user_tbl_pk = " + photoOwnerUserTblPk + " ";

               rs = dbcon.executeQuery(sqlString);
               rs.next();
               
               if (degreeCode > Integer.parseInt(rs.getString(1))) {
                   logger.debug("Unauthorized User: " + userTblPk);
                   PrintWriter out=response.getWriter();

                   jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                   jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto"));
                   
                   jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                   jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));

                   jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

                   out.print(jsonStatus.toString());
                   out.close();
                   out.flush();
                   return mapping.findForward(null);
               }
               
               sqlString  = "select a.image_oid "
                         +       ",a.image_content_size "
                         +       ",a.image_content_type ";
               sqlString += "from image_tbl            a ";
               sqlString += "where a.image_tbl_pk = " + photoID + " ";

               logger.debug(sqlString);
               
               rs = dbcon.executeQuery(sqlString);
               if (!rs.next()) {
                   logger.debug("Photo not found for photoID: " + photoID);
                   PrintWriter out=response.getWriter();

                   jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                   jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto"));
                   
                   jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasoncode.2"));
                   jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.displayPhoto.message.failure.reasonstr.2"));

                   jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

                   out.print(jsonStatus.toString());
                   out.close();
                   out.flush();
                   return mapping.findForward(null);
               }
               long oid = rs.getLong(1);
               int  image_content_size = rs.getInt(2);
               String image_content_type = rs.getString(3);
                
               logger.debug("Image OID: " + oid);
               logger.debug("Image Size: " + image_content_size);
               logger.debug("Image Type: " + image_content_type);
                
               dbcon.free(rs);

               content = Operations.getLargeObjectContent(oid, ds);
               GeneralUtil.imageDisplay(content, image_content_type, image_content_size, response); 
           }
      } catch (Exception e) {
        logger.error(e.toString());
      } finally {
         logger.debug("Exit");
      }
      return mapping.findForward(null);
    }
}
