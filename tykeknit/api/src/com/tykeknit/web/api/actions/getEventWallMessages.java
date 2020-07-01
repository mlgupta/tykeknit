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
  * $Id: getEventWallMessages.java,v 1.1 2011/07/01 12:57:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getEventWallMessagesForm;
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

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  getEventWallMessages
 * Retrieves messages for events tykeboard
 *
 * Required Parameters:
 *  txtEventTblPk    - Event ID
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "response" : { "messages" : [ { "timestamp" : "",
 *                                   "txtEventWallMessageTblPk" : "",
 *                                   "txtMessage" : "",
 *                                   "txtUserFName" : "",
 *                                   "txtUserLName" : "",
 *                                   "txtUserTblFk" : ""
 *                             } ] },
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *    -1   -   Invalid Event ID
 *
 *  See Also:
 *      <deleteEventWallMessage>
 *
 */

public class

getEventWallMessages extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getEventWallMessagesForm getEventWallMessagesForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      String event_id = null;

      try {
           logger.debug("Enter");
           
           getEventWallMessagesForm=(getEventWallMessagesForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
           
           PrintWriter out=response.getWriter();

           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS); 

//           HttpSession session = request.getSession();
          
//           User user = (User) session.getAttribute("user");

           JSONObject jsonStatus   = new JSONObject();
//           JSONObject jsonResponse = new JSONObject();

           event_id = getEventWallMessagesForm.getTxtEventTblPk();
           
           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select b.event_wall_message_tbl_pk "
                      +       ",a.user_id "
                      +       ",b.message "
                      +       ",a.user_fname "
                      +       ",a.user_lname "
                      +       ",b.timestamp ";
           sqlString += "from user_tbl                  a "
                      + "    ,event_wall_message_tbl    b ";
           sqlString += "where b.event_tbl_fk = " + getEventWallMessagesForm.getTxtEventTblPk() + " "
                      +   "and b.user_tbl_fk = a.user_tbl_pk ";

           logger.debug(sqlString);
           rs = dbcon.executeQuery(sqlString);            

           JSONObject jsonmessages = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getEventWallMessages.displayname.data7");

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
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getEventWallMessages"));
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
