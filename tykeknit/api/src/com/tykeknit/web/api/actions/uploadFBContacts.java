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
  * $Id: uploadFBContacts.java,v 1.6 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.uploadFBContactsForm;
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
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  uploadFBContacts
 *  Uploads and stores users Facebooks friends in the system, and returns facebook friends who are already in the system for addition to users knit.
 *
 * Required Parameters:
 *  txtContacts     - List of Facebook contacts in the JSON Format ({FBContacts: [xx,xx,xx,xx]})
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "uploadFBContacts",
 *   "response" : { "FBContacts" : [ { "txtUserEmail" : "",
 *             "txtUserFname" : "",
 *             "txtUserLname" : "",
 *             "txtUserTblPk" : ""
 *           } ] },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <uploadContacts>
 *
 */

public class

uploadFBContacts extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      uploadFBContactsForm uploadFBContactsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

          uploadFBContactsForm=(uploadFBContactsForm)form;
          context=servlet.getServletContext();
          jdbcDS = (String)context.getAttribute("jdbcDS");
          
          logger.debug("jdbs-DS:" + jdbcDS);

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);
          
          HttpSession session = request.getSession();
          
          User user = (User) session.getAttribute("user");

          PrintWriter out=response.getWriter();

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();
          
          String txtContacts = uploadFBContactsForm.getTxtContacts();
          
          logger.debug("txtContacts: " + txtContacts);

          JSONObject jsonContactStr = new JSONObject(txtContacts);
          
          String fbContacts = jsonContactStr.getString("FBContacts");
          
          logger.debug("fbContacts:" + fbContacts);
          
          fbContacts = fbContacts.replace("[","(");
          fbContacts = fbContacts.replace("]",")");
          fbContacts = fbContacts.replaceAll("\"","\'");
          
          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.user_tbl_pk "
                     +       ",a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.user_email ";
          sqlString += "from user_tbl            a ";
          sqlString += "where a.user_fb_userid in " + fbContacts
                     +   " and a.date_eff <= CURRENT_DATE "
                     +   " and a.date_inac > CURRENT_DATE "
                     +   " and a.user_tbl_pk not in (select b.knit_to_user_tbl_fk "
                     +                             "   from knit_tbl b "
                     +                             "  where b.knit_from_user_tbl_fk = " + userTblPk + ")";

          logger.debug(sqlString);
          
          rs = dbcon.executeQuery(sqlString); 
          
          JSONObject jsonFBContacts = new JSONObject();
          
          String data1 = messageResources.getMessage("json.response.methodname.uploadFBContacts.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.uploadFBContacts.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.uploadFBContacts.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.uploadFBContacts.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.uploadFBContacts.displayname.data5");

          while(rs.next()) {
              JSONObject jsonFBContact = new JSONObject();

              jsonFBContact.put(data2,rs.getString(1));
              jsonFBContact.put(data3,rs.getString(2));
              jsonFBContact.put(data4,rs.getString(3));
              jsonFBContact.put(data5,rs.getString(4));
              
              jsonFBContacts.append(data1,jsonFBContact);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.uploadFBContacts"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonFBContacts);

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
