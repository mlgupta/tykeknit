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
  * $Id: getDBActivities.java,v 1.10 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getDBActivitiesForm;
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
 * Method:  getDBActivities
 * Gets list of upcoming playdate activities
 *
 * Required Parameters:
 *  txtResultLimit          - Number of rows to return
 *  txtResultOffset         - Offset from where the rows needs to be returned (Useful for multiple page results)
 *  txtPastActivitiesFlag   - Set to get Past Activities (1 - Past Activities, 0 - Upcoming Activities)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getDBActivities",
 *  "responseStatus" : "success"
 *  "response" : { "Activities" : [ { "txtPid" : "",
 *            "txtPlaydateName" : "",
 *            "txtPlaydateLocation" : "",
 *            "txtPlaydateDate" : "",
 *            "txtPlaydateStartTime" : ""
 *            "Tykes" : [],
 *            "playdateID" : "",
 *            "txtOrganiserUserTblPk" : "",
 *            "txtOrganiserName" : ""
 *          },
 *          { "txtPid" : "",
 *            "txtPlaydateName" : "",
 *            "txtPlaydateLocation" : "",
 *            "txtPlaydateDate" : "",
 *            "txtPlaydateStartTime" : ""
 *            "Tykes" : [],
 *            "playdateID" : "",
 *            "txtOrganiserUserTblPk" : "",
 *            "txtOrganiserName" : ""
 *          },
 *          { "txtPid" : "",
 *            "txtPlaydateName" : "",
 *            "txtPlaydateLocation" : "",
 *            "txtPlaydateDate" : "",
 *            "txtPlaydateStartTime" : ""
 *            "Tykes" : [],
 *            "playdateID" : "",
 *            "txtOrganiserUserTblPk" : "",
 *            "txtOrganiserName" : ""
 *          }
 *        ] 
 *        playdatesCount : "",
 *        messagesCount : "" },
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <getDBInvitations>
 *
 */

public class

getDBActivities extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getDBActivitiesForm getDBActivitiesForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

           getDBActivitiesForm=(getDBActivitiesForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();

           String userTblPk = user.getUserTblPk();
          
          DBConnection dbcon = new DBConnection(ds);
          
          sqlString  = "select b.playdate_tbl_pk "
                     +       ",b.playdate_name "
                     +       ",b.playdate_location "
                     +       ",b.playdate_date "
                     +       ",b.playdate_start_time "
                     +       ",a.child_fname "
                     +       ",a.child_lname "
                     +       ",e.user_fname "
                     +       ",e.user_lname "
                     +       ",h.playdate_tbl_fk "
                     +       ",e.user_tbl_pk ";
          sqlString += "from child_tbl                  a "
                     + "    ,playdate_tbl               b "
                     + "    ,playdate_participant_tbl   c "
                     + "    ,user_tbl                   e "
                     + "    ,playdate_status_code_tbl   g "
                     + "    ,message_tbl                h ";
          sqlString += "where h.message_to_user_tbl_fk = " + userTblPk + " "
                     +   "and h.playdate_tbl_fk = b.playdate_tbl_pk "
                     +   "and h.invitation_status = 'A' "
                     +   "and h.invite_type = 'P' "
                     +   "and b.playdate_tbl_pk = c.playdate_tbl_fk "
                     +   "and c.child_tbl_fk = a.child_tbl_pk "
                     +   "and b.playdate_status_code_tbl_fk = g.playdate_status_code_tbl_pk "
                     +   "and g.playdate_status = 'ONSCHEDULE' "
                     +   "and b.playdate_organiser_user_tbl_fk = e.user_tbl_pk ";
                     
          if ("1".equals(getDBActivitiesForm.getTxtPastActivitiesFlag())) {
              sqlString += "and b.playdate_date < CURRENT_DATE ";
          }
          else {
              sqlString += "and b.playdate_date >= CURRENT_DATE ";
          }
          sqlString += "order by b.playdate_date, b.playdate_start_time ";
          sqlString += "limit " + getDBActivitiesForm.getTxtResultLimit() + " offset " + getDBActivitiesForm.getTxtResultOffset();

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          JSONObject jsonActivities = new JSONObject();
          
          String data1 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data9");
          String data10 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data10");
          String data11 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data11");
          String data12 = messageResources.getMessage("json.response.methodname.getDBActivities.displayname.data12");

          int prev_playdate_tbl_pk = 0;
          JSONObject jsonActivity = new JSONObject();
          
          while(rs.next()) {
              if (rs.getInt(1) != prev_playdate_tbl_pk) {
                  if (prev_playdate_tbl_pk != 0) {
                      jsonActivities.append(data1,jsonActivity);
                  }

                  prev_playdate_tbl_pk = rs.getInt(1);

                  jsonActivity = new JSONObject();

                  jsonActivity.put(data2,rs.getString(1));
                  jsonActivity.put(data3,rs.getString(2));
                  jsonActivity.put(data4,rs.getString(3));
                  jsonActivity.put(data5,rs.getString(4));
                  jsonActivity.put(data6,rs.getString(5));
                  jsonActivity.put(data8,rs.getString(8) + " " + rs.getString(9));
                  jsonActivity.put(data11,rs.getString(10));
                  jsonActivity.put(data12,rs.getString(11));
              }
              jsonActivity.append(data7,rs.getString(6));
          }
          if (prev_playdate_tbl_pk != 0) {
              jsonActivities.append(data1,jsonActivity);
          }
          
          if ("1".equals(getDBActivitiesForm.getTxtPastActivitiesFlag())) {
              
          }
          else {
              sqlString  = "select count(a.message_tbl_pk) ";
              sqlString += "from message_tbl                  a "
                         +     ",playdate_tbl                 b "
                         +     ",playdate_status_code_tbl     c ";
              sqlString += "where a.message_to_user_tbl_fk = " + userTblPk + " "
                         +   "and a.invitation_status = 'A' "
                         +   "and a.invite_type = 'P' "
                         +   "and a.playdate_tbl_fk = b.playdate_tbl_pk "
                         +   "and b.playdate_status_code_tbl_fk = c.playdate_status_code_tbl_pk "
                         +   "and c.playdate_status = 'ONSCHEDULE' "
                         +   "and b.playdate_date >= CURRENT_DATE ";

              logger.debug(sqlString);
              rs = dbcon.executeQuery(sqlString);
              
              rs.next();
              jsonActivities.put(data9,rs.getString(1));
              
              sqlString  = "select count(a.message_tbl_pk) ";
              sqlString += "from message_tbl                  a ";
              sqlString += "where a.message_to_user_tbl_fk = " + userTblPk + " "
                         +   "and a.invitation_status = 'P' "
                         +   "and a.message_read_status = 'N' ";

              logger.debug(sqlString);
              rs = dbcon.executeQuery(sqlString);
              
              rs.next();
              jsonActivities.put(data10,rs.getString(1));
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBActivities"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonActivities);
          

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
