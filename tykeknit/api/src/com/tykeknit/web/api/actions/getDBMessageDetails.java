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
  * $Id: getDBMessageDetails.java,v 1.6 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getDBMessageDetailsForm;
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
 * Method:  getDBMessageDetails
 * Gets details about a Message/Invitation
 *
 * Required Parameters:
 *  txtMsgId    - Message ID
 *  txtMsgType  - Message Type (I - Knit Invitation, M - Message, P - Playdate Invitation)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getDBMessageDetails",
 *  "response" : { "txtMsgId" : "",
 *            "txtFromUserTblFk" : "",
 *            "txtFromFirstName" : "",
 *            "txtFromLastName": "",
 *            "txtFromEmail" : "",
 *            "txtToUserTblFk" : "",
 *            "txtToFirstName" : "",
 *            "txtToLastName : "",
 *            "txtToEmail" : "",
 *            "txtTimestamp" : "",
 *            "txtMsgSubject" : "",
 *            "txtMsgBody" : "",
 *            "txtMsgType" : "",
 *            "txtMsgReadStatus" : "",
 *            "txtInviteStatus" : ""
 *          },
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid Message ID
 *    -2   -   Invalid Message Type
 *
 *  See Also:
 *      <getDBInvitationDetails>
 *
 */

public class

getDBMessageDetails extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getDBMessageDetailsForm getDBMessageDetailsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      int rc = 0;

      try {
           logger.debug("Enter");

           getDBMessageDetailsForm=(getDBMessageDetailsForm)form;
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
          String knitInviteTblPk = getDBMessageDetailsForm.getTxtMsgId();
          
          rc = Operations.DBMessagesAuthorization(Integer.parseInt(userTblPk), Integer.parseInt(knitInviteTblPk), ds);

          if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBMessageDetails"));
             
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

          rc = Operations.updateMessageReadStatus(Integer.parseInt(userTblPk), Integer.parseInt(knitInviteTblPk), "R", ds);

          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select a.message_tbl_pk "
                     +       ",b.user_tbl_pk "
                     +       ",b.user_fname "
                     +       ",b.user_lname "
                     +       ",b.user_email "
                     +       ",c.user_tbl_pk "
                     +       ",c.user_fname "
                     +       ",c.user_lname "
                     +       ",c.user_email "
                     +       ",a.invitation_timestamp "
                     +       ",a.invite_type "
                     +       ",a.msg_subject "
                     +       ",a.msg_body "
                     +       ",a.message_read_status "
                     +       ",a.invitation_status ";
          sqlString += "from message_tbl            a "
                     + "    ,user_tbl                   b "
                     + "    ,user_tbl                   c ";
          sqlString += "where a.message_tbl_pk = " + knitInviteTblPk + " "
                     +   "and a.message_from_user_tbl_fk = b.user_tbl_pk "
                     +   "and a.message_to_user_tbl_fk = c.user_tbl_pk "
                     +   "and a.invite_type = '" + getDBMessageDetailsForm.getTxtMsgType() + "' ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          String data1 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data9");
          String data10 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data10");
          String data11 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data11");
          String data12 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data12");
          String data13 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data13");
          String data14 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data14");
          String data15 = messageResources.getMessage("json.response.methodname.getDBMessageDetails.displayname.data15");

          if (!rs.next()) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBMessageDetails"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getDBMessages.message.failure.reasoncode.2"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getDBMessages.message.failure.reasonstr.2"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

          }
          else {
              JSONObject jsonMsgDetails = new JSONObject();

              jsonMsgDetails.put(data1,rs.getString(1));
              jsonMsgDetails.put(data2,rs.getString(2));
              jsonMsgDetails.put(data3,rs.getString(3));
              jsonMsgDetails.put(data4,rs.getString(4));
              jsonMsgDetails.put(data5,rs.getString(5));
              jsonMsgDetails.put(data6,rs.getString(6));
              jsonMsgDetails.put(data7,rs.getString(7));
              jsonMsgDetails.put(data8,rs.getString(8));
              jsonMsgDetails.put(data9,rs.getString(9));
              jsonMsgDetails.put(data10,rs.getString(10));
              jsonMsgDetails.put(data11,rs.getString(11));
              jsonMsgDetails.put(data12,rs.getString(12));
              jsonMsgDetails.put(data13,rs.getString(13));
              jsonMsgDetails.put(data14,rs.getString(14));
              jsonMsgDetails.put(data15,rs.getString(15));

              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBMessageDetails"));
              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonMsgDetails);
          }
          dbcon.free(rs);                      


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
