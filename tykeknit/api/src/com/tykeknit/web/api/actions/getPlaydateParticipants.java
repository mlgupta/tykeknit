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
  * $Id: getPlaydateParticipants.java,v 1.7 2011/05/13 01:59:21 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getPlaydateParticipantsForm;
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
 * Method:  getPlaydateParticipants
 * Gets list of scheduled playdate participants. This call can only be made by one of the playdate participants.
 *
 * Required Parameters:
 *  txtPid    - Playdate ID
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getPlaydateParticipants",
 *  "response" : { "Participants" : [ { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "parentId" : "",
 *            "parentFName" : "",
 *            "parentLName" : "",
 *            "organizerFlag" : "",
 *            "status" : "MAYBE"
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "parentId" : "",
 *            "parentFName" : "",
 *            "parentLName" : "",
 *            "organizerFlag" : "",
 *            "status" : "MAYBE"
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "parentId" : "",
 *            "parentFName" : "",
 *            "parentLName" : "",
 *            "organizerFlag" : "",
 *            "status" : "YES"
 *          }
 *        ] },
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
 *      <playdateDetails>, <playdateRequest>
 *
 */

public class

getPlaydateParticipants extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getPlaydateParticipantsForm getPlaydateParticipantsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;
      int rc = 0;

      try {
           logger.debug("Enter");

           getPlaydateParticipantsForm=(getPlaydateParticipantsForm)form;
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
          int playdate_id = Integer.parseInt(getPlaydateParticipantsForm.getTxtPid());
          
          rc = Operations.wallMessagesAuthorization(userTblPk, playdate_id, ds);

          if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getplaydateparticipants"));
             
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
          
          sqlString  = "select b.child_tbl_pk "
                     +       ",b.child_fname "
                     +       ",b.child_lname "
                     +       ",c.rsvp_code "
                     +       ",d.user_tbl_pk "
                     +       ",d.user_fname "
                     +       ",d.user_lname "
                     +       ",a.organizer_flag ";
          sqlString += "from playdate_participant_tbl   a "
                     + "    ,child_tbl                  b "
                     + "    ,rsvp_code_tbl              c "
                     + "    ,user_tbl                   d ";
          sqlString += "where a.playdate_tbl_fk = " + getPlaydateParticipantsForm.getTxtPid() + " "
                     +   "and a.child_tbl_fk = b.child_tbl_pk "
                     +   "and a.rsvp_code_tbl_fk = c.rsvp_code_tbl_pk "
                     +   "and a.parent_user_tbl_fk = d.user_tbl_pk ";
          sqlString += " order by d.user_fname, d.user_lname, b.child_fname ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          JSONObject jsonparticipants = new JSONObject();
          
          String data1 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getplaydateparticipants.displayname.data9");

          while(rs.next()) {
              JSONObject jsonparticipant = new JSONObject();

              jsonparticipant.put(data1,rs.getString(1));
              jsonparticipant.put(data2,rs.getString(2));
              jsonparticipant.put(data3,rs.getString(3));
              jsonparticipant.put(data4,rs.getString(4));
              jsonparticipant.put(data6,rs.getString(5));
              jsonparticipant.put(data7,rs.getString(6));
              jsonparticipant.put(data8,rs.getString(7));
              jsonparticipant.put(data9,rs.getBoolean(8));
              
              jsonparticipants.append(data5,jsonparticipant);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getplaydateparticipants"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonparticipants);
          

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
