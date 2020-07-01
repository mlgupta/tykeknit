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
  * $Id: getWallMessages.java,v 1.6 2011/04/01 07:02:56 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getWallMessagesForm;
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
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  getWallMessages
 * Retrieves messages for a playdate wall
 *
 * Required Parameters:
 *  txtPid    - Playdate ID
 *  txTime    - Retrive messages after this timestamp (YYYYMMDDHH24MM)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "response" : { "messages" : [ { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "message" : "",
 *            "time" : "",
 *            "userID" : ""
 *          } ] },
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid Playdate ID
 *
 *  See Also:
 *      <deleteWallMessage>
 *
 */

public class

getWallMessages extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getWallMessagesForm getWallMessagesForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      String playdate_id = null;
      String timestamp = null;
      int rc = 0;

      try {
           logger.debug("Enter");
           
           getWallMessagesForm=(getWallMessagesForm)form;
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

           int userTblPk = Integer.parseInt(user.getUserTblPk());
           playdate_id = getWallMessagesForm.getTxtPid();
           timestamp = getWallMessagesForm.getTxtTime();
           
           rc = Operations.wallMessagesAuthorization(userTblPk, Integer.parseInt(playdate_id), ds);

           if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getwallmessages"));
              
              if (rc == -2) {
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
           
           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select b.wall_message_tbl_pk "
                      +       ",a.user_id "
                      +       ",b.message "
                      +       ",a.user_fname "
                      +       ",a.user_lname "
                      +       ",b.timestamp ";
           sqlString += "from user_tbl            a "
                      + "    ,wall_message_tbl    b ";
           sqlString += "where b.playdate_tbl_fk = " + getWallMessagesForm.getTxtPid() + " "
                      +   "and b.poster_user_tbl_fk = a.user_tbl_pk ";

           if (timestamp == null || "".equals(timestamp)) {
           }
           else {
               sqlString += " and b.timestamp >= to_timestamp('" + timestamp + "','YYYYMMDDHH24MM') ";
           }
           
           logger.debug(sqlString);
           rs = dbcon.executeQuery(sqlString);            

           JSONObject jsonmessages = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getwallmessages.displayname.data7");

           while(rs.next()) {
               JSONObject jsonmessage = new JSONObject();

               jsonmessage.put(data1,rs.getString(1));
               jsonmessage.put(data2,rs.getString(2));
               jsonmessage.put(data3,rs.getString(3));
               jsonmessage.put(data4,rs.getString(4));
               jsonmessage.put(data5,rs.getString(5));
               jsonmessage.put(data6,rs.getString(6));
               
               jsonmessages.append(data7,jsonmessage);
           }

           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getWallMessages"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonmessages);
          
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
