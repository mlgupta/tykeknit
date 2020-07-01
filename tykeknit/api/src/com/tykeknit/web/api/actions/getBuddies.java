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
  * $Id: getBuddies.java,v 1.11 2011/04/25 11:40:58 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getBuddiesForm;
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
 * Method:  getBuddies
 * Gets list of buddies for a child in his/her knit
 *
 * Required Parameters:
 *  txtCid    - Child ID
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getBuddies",
 * "response" : { "Buddies" : [ { "Location" : "",
 *            "ParentFName" : "",
 *            "ParentLName" : "",
 *            "ParentUserTblPk" : "",
 *            "Tykes" : [ { "cid" : "",
 *                  "txtDOB" : "",
 *                  "txtFirstName" : "",
 *                  "txtGender" : "",
 *                  "txtLastName" : "",
 *                  "WannaHang" " ""
 *                },
 *                { "cid" : "",
 *                  "txtDOB" : "",
 *                  "txtFirstName" : "",
 *                  "txtGender" : "",
 *                  "txtLastName" : ""
 *                  "WannaHang" " ""
 *                }
 *              ],
 *            "degreeCode" : "1"
 *          },
 *        ] },
 *  "responseStatus" : "success"
 * } 
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid Child ID
 *
 *  See Also:
 *      <getUserProfile>
 *
 */

public class

getBuddies extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getBuddiesForm getBuddiesForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      int rc = 0;

      try {
           logger.debug("Enter");
           
           getBuddiesForm=(getBuddiesForm)form;
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

           rc = Operations.getParentForChild(Integer.parseInt(getBuddiesForm.getTxtCid()), ds);
           
           if (rc < 0) {
               logger.debug("Invalid cid: " + getBuddiesForm.getTxtCid());
               
               jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
               jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getbuddies"));
               
               jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getbuddies.message.failure.reasoncode.1"));
               jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getbuddies.message.failure.reasonstr.1"));

               jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
               
               out.print(jsonStatus.toString());
               out.close();
               out.flush();
               return mapping.findForward(null);
           }

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select distinct a.child_tbl_pk "
                      +       ",a.child_fname "
                      +       ",a.child_lname "
                      +       ",a.child_dob "
                      +       ",a.child_gender "
                      +       ",a.child_image_tbl_fk "
                      +       ",a.user_tbl_pk "
                      +       ",a.user_fname "
                      +       ",a.user_lname "
                      +       ",a.wanna_hang "
                      +       ",a.user_location_lat "
                      +       ",a.user_location_long ";
           sqlString += "from parent_child_vw      a "
                      +     ",knit_tbl             b "
                      +     ",parent_child_vw      c ";
           sqlString += "where c.child_tbl_pk = '" + getBuddiesForm.getTxtCid() + "' "
                      +   "and c.user_tbl_pk = b.knit_from_user_tbl_fk "
                      +   "and b.knit_to_user_tbl_fk = a.user_tbl_pk ";
           sqlString += "order by a.user_tbl_pk, a.child_fname ";

           logger.debug(sqlString);
          
           rs = dbcon.executeQuery(sqlString);            

           JSONObject jsonBuddies = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data7");
           String data8 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data8");
           String data9 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data9");
           String data10 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data10");
           String data11 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data11");
           String data12 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data12");
           String data13 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data13");
           String data14 = messageResources.getMessage("json.response.methodname.getbuddies.displayname.data14");

           String value1 = messageResources.getMessage("json.response.methodname.getbuddies.value.data7");
           
           int prev_user_tbl_pk = 0;
           JSONObject jsonBuddy = new JSONObject();
           JSONObject jsonTyke = new JSONObject();
           
           while(rs.next()) {
              if (rs.getInt(7) != prev_user_tbl_pk) {
                  if (prev_user_tbl_pk != 0) {
                      jsonBuddies.append(data1,jsonBuddy);
                  }
                      
                  prev_user_tbl_pk = rs.getInt(7);
                      
                  jsonBuddy = new JSONObject();

                  jsonBuddy.put(data3,"1");
                  jsonBuddy.put(data10,rs.getString(7));
                  jsonBuddy.put(data11,rs.getString(8));
                  jsonBuddy.put(data12,rs.getString(9));

                  JSONObject geoJSON = new JSONObject();
                      
                  geoJSON.put("Lat",rs.getString(11));
                  geoJSON.put("Long",rs.getString(12));
                     
                  logger.debug("geoJSON : " + geoJSON.toString());
                  jsonBuddy.put(data9,geoJSON.toString());
              }
              
              jsonTyke = new JSONObject();
              jsonTyke.put(data2,rs.getString(1));
              jsonTyke.put(data4,rs.getString(2));
              jsonTyke.put(data5,rs.getString(3));
              jsonTyke.put(data6,rs.getString(4));
              jsonTyke.put(data8,rs.getString(5));
              jsonTyke.put(data14,rs.getString(10));
              
              String image_tbl_fk = rs.getString(6);
              if (image_tbl_fk == null || "".equalsIgnoreCase(image_tbl_fk)) {
                      
              }
              else {
                  jsonTyke.put(data7,value1 + image_tbl_fk);
              }
              
              jsonBuddy.append(data13,jsonTyke);
           }
           
           if (prev_user_tbl_pk !=0) {
               jsonBuddies.append(data1,jsonBuddy);
           }

           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getbuddies"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonBuddies);
          
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
