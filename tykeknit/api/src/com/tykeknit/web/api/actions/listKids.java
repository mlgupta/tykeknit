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
  * $Id: listKids.java,v 1.8 2011/04/25 11:40:58 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.listKidsForm;
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
 * Method:  listKids
 *  Lists kids for an authenticated user
 *
 * Required Parameters:
 *  None
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "listkids",
 *  "response" : { "kids" : [ { "ChildTblPk" : "",
 *             "DOB" : "",
 *             "fname" : "",
 *             "gender" : "",
 *             "lname" : "",
 *             "picURL" : "/displayPhoto.do?photoID=xxx"
 *           },
 *           { "ChildTblPk" : "",
 *             "DOB" : "",
 *             "fname" : "",
 *             "gender" : "",
 *             "lname" : "",
 *             "picURL" : "/displayPhoto.do?photoID=xxx"
 *           },
 *         ] },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <getBuddies>
 *
 */

public class

listKids extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      listKidsForm listKidsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
           listKidsForm=(listKidsForm)form;
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

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select a.child_tbl_pk "
                      +       ",a.child_fname "
                      +       ",a.child_lname "
                      +       ",a.child_dob "
                      +       ",a.child_gender "
                      +       ",a.child_image_tbl_fk "
                      +       ",a.wanna_hang ";
           sqlString += "from parent_child_vw            a ";
           sqlString += "where a.user_tbl_pk = '" + userTblPk + "' ";
           sqlString += " order by a.child_fname ";


           logger.debug(sqlString);
          
           rs = dbcon.executeQuery(sqlString);            

           JSONObject jsonkids = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.listkids.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.listkids.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.listkids.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.listkids.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.listkids.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.listkids.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.listkids.displayname.data7");

           String value1 = messageResources.getMessage("json.response.methodname.listkids.value.data2");

           String data8 = messageResources.getMessage("json.response.methodname.listkids.displayname.data8");
           
           String image_tbl_fk = "";
           
           while(rs.next()) {
               JSONObject jsonkid = new JSONObject();

               jsonkid.put(data7,rs.getString(1));
               jsonkid.put(data3,rs.getString(2));
               jsonkid.put(data4,rs.getString(3));
               jsonkid.put(data5,rs.getString(4));
               jsonkid.put(data6,rs.getString(5));
               
               image_tbl_fk = rs.getString(6);
               
               if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
                   
               }
               else {
                   jsonkid.put(data2,value1 + image_tbl_fk);
               }
               
               jsonkid.put(data8,rs.getString(7));
               jsonkids.append(data1,jsonkid);
           }

           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.listkids"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonkids);
          
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
