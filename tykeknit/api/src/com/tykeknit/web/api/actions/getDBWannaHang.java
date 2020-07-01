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
  * $Id: getDBWannaHang.java,v 1.2 2011/03/18 14:47:15 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getDBWannaHangForm;
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
 * Method:  getDBWannaHang
 * Gets Wanna Hang Status for all children that belongs to user
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
 * { "methodName" : "getDBWannaHang",
 *  "responseStatus" : "success"
 *  "response" : { "Kids" : [ { "firstName" : "",
 *            "lastName" : "",
 *            "Cid" : "",
 *            "WannaHang" : ""
 *          },
 *          { "firstName" : "",
 *            "lastName" : "",
 *            "Cid" : "",
 *            "WannaHang" : ""
 *          },
 *          { "firstName" : "",
 *            "lastName" : "",
 *            "Cid" : "",
 *            "WannaHang" : ""
 *          }
 *        ] },
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <setDBWannaHang>
 *
 */

public class

getDBWannaHang extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getDBWannaHangForm getDBWannaHangForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

           getDBWannaHangForm=(getDBWannaHangForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();
//           JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();

          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.child_tbl_pk "
                     +       ",a.child_fname "
                     +       ",a.child_lname "
                     +       ",a.wanna_hang ";
          sqlString += "from parent_child_vw   a ";
          sqlString += "where a.user_tbl_pk = " + userTblPk ;
          sqlString += " order by a.child_fname ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          JSONObject jsonKids = new JSONObject();
          
          String data1 = messageResources.getMessage("json.response.methodname.getDBWannaHang.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getDBWannaHang.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getDBWannaHang.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getDBWannaHang.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getDBWannaHang.displayname.data5");

          while(rs.next()) {
              JSONObject jsonKid = new JSONObject();

              jsonKid.put(data2,rs.getString(1));
              jsonKid.put(data3,rs.getString(2));
              jsonKid.put(data4,rs.getString(3));
              jsonKid.put(data5,rs.getString(4));
              
              jsonKids.append(data1,jsonKid);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBWannaHang"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonKids);
          

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
