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
  * $Id: playdateDetails.java,v 1.9 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.playdateDetailsForm;
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
 * Method:  playdateDetails
 * Provides detailed information about a playdate
 *
 * Required Parameters:
 *  txtPid          - Playdate ID
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "response" : { "Location" : "",
 *       "OrganiserFName" : "",
 *       "OrganiserLName" : "",
 *       "date" : "",
 *       "endDate" : "",
 *       "organiserUserID" : "",
 *       "playdateID" : "",
 *       "playdateMessage" : "",
 *       "playdateName" : "",
 *       "playdateStatus" : "ONSCHEDULE",
 *       "StartTime" : "",
 *       "EndTime" : "",
 *       "playdateCreateTimestamp" : ""
 *     },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -  Invalid Session
 *  -100   -   SQLException
 *  -1     -   Invalid Playdate ID
 *
 *  See Also:
 *      <playdateRequest>, <cancelPlaydate>
 *
 */

public class

playdateDetails extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      playdateDetailsForm playdateDetailsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      int rc = 0;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
           playdateDetailsForm=(playdateDetailsForm)form;
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
           String playdate_id = playdateDetailsForm.getTxtPid();

           rc = Operations.wallMessagesAuthorization(Integer.parseInt(userTblPk), Integer.parseInt(playdate_id), ds);

           if (rc < 0) {
             jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
             jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails"));
             
             if (rc == -1) {
                 jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails.message.failure.reasoncode.1"));
                 jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails.message.failure.reasonstr.1"));
             }
             else if (rc == -2) {
                 jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                 jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));
             }

             jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

             out.print(jsonStatus.toString());
             out.close();
             out.flush();

             return mapping.findForward(null);
           }

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select a.playdate_tbl_pk "
                      +       ",b.user_tbl_pk "
                      +       ",b.user_fname "
                      +       ",b.user_lname "
                      +       ",a.playdate_name "
                      +       ",a.playdate_location "
                      +       ",to_char(a.playdate_date,'YYYY-MM-DD') "
                      +       ",to_char(date '2011-01-01' + a.playdate_start_time,'HH24:MI') "
                      +       ",to_char(date '2011-01-01' + a.playdate_end_time,'HH24:MI') "
                      +       ",a.playdate_message "
                      +       ",c.playdate_status "
                      +       ",to_char(a.playdate_end_date,'YYYY-MM-DD') "
                      +       ",playdate_create_timestamp ";
           sqlString += "from playdate_tbl             a "
                      +     ",user_tbl                 b "
                      +     ",playdate_status_code_tbl c ";
           sqlString += "where a.playdate_tbl_pk = " + playdate_id + " "
                      +   "and b.user_tbl_pk = playdate_organiser_user_tbl_fk "
                      +   "and c.playdate_status_code_tbl_pk = playdate_status_code_tbl_fk ";

           logger.debug(sqlString);
          
           rs = dbcon.executeQuery(sqlString);            

           JSONObject jsonplaydate = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data7");
           String data8 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data8");
           String data9 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data9");
           String data10 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data10");
           String data11 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data11");
           String data12 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data12");
           String data13 = messageResources.getMessage("json.response.methodname.playdatedetails.displayname.data13");

          if (!rs.next()) {
              logger.debug("Invalid pid: " + playdate_id);
              
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails.message.failure.reasoncode.1"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.playdatedetails.message.failure.reasonstr.1"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              dbcon.free(rs);                      

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              
              return mapping.findForward(null);
          }

           jsonplaydate.put(data1,rs.getString(1));
           jsonplaydate.put(data2,rs.getString(2));
           jsonplaydate.put(data3,rs.getString(3));
           jsonplaydate.put(data4,rs.getString(4));
           jsonplaydate.put(data5,rs.getString(5));
           jsonplaydate.put(data6,rs.getString(6));
           jsonplaydate.put(data7,rs.getString(7));
           jsonplaydate.put(data8,rs.getString(8));
           jsonplaydate.put(data9,rs.getString(9));
           jsonplaydate.put(data10,rs.getString(10));
           jsonplaydate.put(data11,rs.getString(11));
           jsonplaydate.put(data12,rs.getString(12));
           jsonplaydate.put(data13,rs.getString(13));
           
           rc = Operations.updateMessageReadStatusPid(Integer.parseInt(userTblPk), Integer.parseInt(playdate_id), "R", ds);

           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.playdateDetails"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonplaydate);
          
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
