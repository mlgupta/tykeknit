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
  * $Id: getEvents.java,v 1.2 2011/07/01 12:57:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getEventsForm;
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
 * Method:  getEvents
 * Gets list of upcoming events
 *
 * Required Parameters:
 *  txtResultLimit          - Number of rows to return
 *  txtResultOffset         - Offset from where the rows needs to be returned (Useful for multiple page results)
 *  txtMyEventsFlag         - If set, returns events submitted by the user (Possible value 0 or 1).
 *
 * Optional Parameters:
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getEvents",
 *  "responseStatus" : "success"
 *  "response" : { "Events" : [ { "txtEventDetail" : "",
 *                                "txtEventTblPk" : "",
 *                                "txtEventTitle" : "",
 *                                "txtSubmissionTimestamp" : "2011-06-22 22:23:10.324146-04",
 *                                "txtUserFName" : "",
 *                                "txtUserLName" : "",
 *                                "txtUserTblFk" : ""
 *                               },
 *                               { "txtEventDetail" : "",
 *                                "txtEventTblPk" : "",
 *                                "txtEventTitle" : "",
 *                                "txtSubmissionTimestamp" : "2011-06-22 22:23:10.324146-04",
 *                                "txtUserFName" : "",
 *                                "txtUserLName" : "",
 *                                "txtUserTblFk" : ""
 *                               }
 *                             ] 
 *               },
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <addEvent>
 *
 */

public class

getEvents extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getEventsForm getEventsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

           getEventsForm=(getEventsForm)form;
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
           String userLat = user.getUserLat();
           String userLon = user.getUserLong();
          
          DBConnection dbcon = new DBConnection(ds);
          
          if ("1".equals(getEventsForm.getTxtMyEventsFlag())) {
              sqlString  = "select a.event_tbl_pk "
                         +       ",a.event_title "
                         +       ",a.event_detail "
                         +       ",a.submission_timestamp "
                         +       ",a.user_tbl_fk "
                         +       ",b.user_fname "
                         +       ",b.user_lname ";
              sqlString += "from  event_tbl                  a "
                         +     " ,user_tbl                   b ";
              sqlString += "where a.user_tbl_fk = " + userTblPk + " "
                         +  " and a.user_tbl_fk = b.user_tbl_pk ";
              sqlString += "order by a.submission_timestamp desc ";
              sqlString += "limit " + getEventsForm.getTxtResultLimit() + " offset " + getEventsForm.getTxtResultOffset();
          }
          else {
              sqlString  = "select a.event_tbl_pk "
                         +       ",a.event_title "
                         +       ",a.event_detail "
                         +       ",a.submission_timestamp "
                         +       ",a.user_tbl_fk "
                         +       ",b.user_fname "
                         +       ",b.user_lname ";
              sqlString += "from  event_tbl                  a "
                         +     " ,user_tbl                   b ";
              sqlString += "where ST_DWithin(a.event_submitter_geoloc, ST_Point(" + userLon + "," + userLat + "),80000) = True "
                         +  " and a.user_tbl_fk = b.user_tbl_pk ";
              sqlString += "order by a.submission_timestamp desc ";
              sqlString += "limit " + getEventsForm.getTxtResultLimit() + " offset " + getEventsForm.getTxtResultOffset();
          }

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          String data1 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getEvents.displayname.data9");

          JSONObject jsonEvents = new JSONObject();
          JSONObject jsonEvent = new JSONObject();
          
          int degreeCode = 0;
          
          while(rs.next()) {
              jsonEvent = new JSONObject();

              jsonEvent.put(data2,rs.getString(1));
              jsonEvent.put(data3,rs.getString(2));
              jsonEvent.put(data4,rs.getString(3));
              jsonEvent.put(data5,rs.getString(4));
              jsonEvent.put(data6,rs.getString(5));
              jsonEvent.put(data7,rs.getString(6));
              jsonEvent.put(data8,rs.getString(7));
              
              degreeCode = Operations.getDegreeCode(Integer.parseInt(user.getUserTblPk()),Integer.parseInt(rs.getString(5)), ds);
              
              if (degreeCode <= 1) {
                  jsonEvent.put(data9,"1");
              }
              else {
                  jsonEvent.put(data9,"0");
              }

              jsonEvents.append(data1,jsonEvent);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getEvents"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonEvents);
          

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
