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
  * $Id: getDBMessages.java,v 1.4 2011/04/15 13:05:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getDBMessagesForm;
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
 * Method:  getDBMessages
 * Gets Pending Messages for the user
 *
 * Required Parameters:
 *  txtResultLimit     - Number of rows to return
 *  txtResultOffset    - Offset from where the rows needs to be returned (Useful for multiple page results)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getDBMessages",
 *  "responseStatus" : "success"
 *  "response" : { "InvitationsAndMessages" : [ { "txtMsgId" : "",
 *            "txtFromUserTblFk" : "",
 *            "txtFromFirstName" : "",
 *            "txtFromLastName": "",
 *            "txtFromEmail" : "",
 *            "txtTimestamp" : "",
 *            "txtMsgSubject" : "",
 *            "txtMsgType" : "",
 *            "txtMsgReadStatus : ""
 *          },
 *          { "txtMsgId" : "",
 *            "txtFromUserTblFk" : "",
 *            "txtFromFirstName" : "",
 *            "txtFromLastName": "",
 *            "txtFromEmail" : "",
 *            "txtTimestamp" : "",
 *            "txtMsgSubject" : "",
 *            "txtMsgType" : "",
 *            "txtMsgReadStatus : ""
 *          },
 *          { "txtMsgId" : "",
 *            "txtFromUserTblFk" : "",
 *            "txtFromFirstName" : "",
 *            "txtFromLastName": "",
 *            "txtFromEmail" : "",
 *            "txtTimestamp" : "",
 *            "txtMsgSubject" : "",
 *            "txtMsgType" : "",
 *            "txtMsgReadStatus : ""
 *          },
 *        ]}
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <getDBInvitationDetails>
 *
 */

public class

getDBMessages extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getDBMessagesForm getDBMessagesForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

           getDBMessagesForm=(getDBMessagesForm)form;
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
          
          sqlString  = "select a.message_tbl_pk "
                     +       ",b.user_tbl_pk "
                     +       ",b.user_fname "
                     +       ",b.user_lname "
                     +       ",b.user_email "
                     +       ",a.invitation_timestamp "
                     +       ",a.invite_type "
                     +       ",a.msg_subject "
                     +       ",a.message_read_status ";
          sqlString += "from message_tbl            a "
                     + "    ,user_tbl                   b ";
          sqlString += "where a.message_to_user_tbl_fk = " + userTblPk + " "
                     +   "and a.message_from_user_tbl_fk = b.user_tbl_pk "
                     +   "and a.invite_type = 'M'"
                     +   "and a.invitation_status = 'P' ";
          sqlString += "order by a.invitation_timestamp ";
          sqlString += "limit " + getDBMessagesForm.getTxtResultLimit() + " offset " + getDBMessagesForm.getTxtResultOffset();

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          JSONObject jsonKnitInvites = new JSONObject();
          
          String data1 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data9");
          String data10 = messageResources.getMessage("json.response.methodname.getDBMessages.displayname.data10");

          while(rs.next()) {
              JSONObject jsonKnitInvite = new JSONObject();

              jsonKnitInvite.put(data2,rs.getString(1));
              jsonKnitInvite.put(data3,rs.getString(2));
              jsonKnitInvite.put(data4,rs.getString(3));
              jsonKnitInvite.put(data5,rs.getString(4));
              jsonKnitInvite.put(data6,rs.getString(5));
              jsonKnitInvite.put(data7,rs.getString(6));
              jsonKnitInvite.put(data8,rs.getString(7));
              jsonKnitInvite.put(data9,rs.getString(8));
              jsonKnitInvite.put(data10,rs.getString(9));
              
              jsonKnitInvites.append(data1,jsonKnitInvite);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBMessages"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonKnitInvites);
          

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
