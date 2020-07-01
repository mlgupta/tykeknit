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
  * $Id: getChildProfileDetails.java,v 1.9 2011/05/13 01:59:21 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getChildProfileDetailsForm;
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

import org.json.JSONArray;
import org.json.JSONObject;


/**
 * Method:  getChildProfileDetails
 * Gets detailed profile of a child
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
 * { "methodName" : "getChildProfileDetails",
 *   "response" : { "SecondaryPR" : [ { 
 *            "firstName" : "",
 *            "id" : "",
 *            "lastName" : ""
 *          } ],
 *      "childLocation" : "{}",
 *      "childStatus" : "",
 *      "degreeCode" : "",
 *      "numberOfBuddies" : "",
 *      "privacyEnforcedFlag" : ""
 *      "photoURL" : "/displayPhoto.do?photoID=xxx",
 *      "primaryParent" : { 
 *          "firstName" : "",
 *          "id" : "",
 *          "lastName" : ""
 *        },
 *      "txtDOB" : "",
 *      "txtFirstName" : "",
 *      "txtGender" : "",
 *      "txtLastName" : "",
 *      "commonFriends" : ""
 *    },
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
 *      <getBuddies>
 *
 */

public class

getChildProfileDetails extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getChildProfileDetailsForm getChildProfileDetailsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
           getChildProfileDetailsForm=(getChildProfileDetailsForm)form;
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

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select a.child_tbl_pk "
                      +       ",a.child_fname "
                      +       ",a.child_lname "
                      +       ",a.child_dob "
                      +       ",a.child_gender "
                      +       ",a.parent_tbl_fk "
                      +       ",a.image_tbl_fk "
                      +       ",b.user_id "
                      +       ",b.user_fname "
                      +       ",b.user_lname "
                      +       ",b.user_location_lat "
                      +       ",b.user_location_long "
                      +       ",b.user_profile_setting ";
           sqlString += "from child_tbl            a "
                      +     ",user_tbl             b ";
           sqlString += "where a.parent_tbl_fk = b.user_tbl_pk "
                      +   "and a.child_tbl_pk = " + getChildProfileDetailsForm.getTxtCid()
                      +   "and a.date_eff <= CURRENT_DATE "
                      +   "and a.date_inac > CURRENT_DATE "
                      +   "and b.date_eff <= CURRENT_DATE "
                      +   "and b.date_inac > CURRENT_DATE ";

           logger.debug(sqlString);
          
           rs = dbcon.executeQuery(sqlString); 
           
          if (!rs.next()) {
              logger.debug("Invalid cid: " + getChildProfileDetailsForm.getTxtCid());
              
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getchildprofiledetails"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getchildprofiledetails.message.failure.reasoncode.1"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getchildprofiledetails.message.failure.reasonstr.1"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              dbcon.free(rs);                      

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              return mapping.findForward(null);
          }

           JSONObject jsonkid = new JSONObject();
           JSONObject jsonParent = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data7");
           String data8 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data8");
           String data9 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data9");
           String data10 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data10");
           String data11 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data11");
           String data12 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data12");
           String data13 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data13");
           String data14 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data14");
           String data15 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data15");
           String data16 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data16");
           String data17 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.displayname.data17");

           String value1 = messageResources.getMessage("json.response.methodname.getchildprofiledetails.value.data6");
           
           int degreeCode = Operations.getDegreeCode(Integer.parseInt(userTblPk), Integer.parseInt(rs.getString(6)), ds);
           boolean privacyEnforcedFlag = true;

           jsonParent.put(data12,rs.getString(6));
           jsonParent.put(data13,rs.getString(9));
           jsonParent.put(data14,rs.getString(10));
          
           jsonkid.put(data8,jsonParent);
           
           if (degreeCode <= Integer.parseInt(rs.getString(13))) {
               privacyEnforcedFlag = false;
               jsonkid.put(data2,rs.getString(2));
               jsonkid.put(data3,rs.getString(3));
               jsonkid.put(data5,rs.getString(4));
               
               String image_tbl_fk = rs.getString(7);
               if (image_tbl_fk == null || "".equalsIgnoreCase(image_tbl_fk)) {
                   
               }
               else {
                   jsonkid.put(data6,value1 + image_tbl_fk);
               }
               
               jsonkid.put(data7,rs.getString(5));
               jsonkid.put(data10,String.valueOf(Operations.getBuddiesCount(Integer.parseInt(rs.getString(6)), ds)));
               
               JSONObject geoJSON = new JSONObject();
               
               geoJSON.put("Lat",rs.getString(11));
               geoJSON.put("Long",rs.getString(12));
               
               logger.debug("geoJSON : " + geoJSON.toString());
               jsonkid.put(data9,geoJSON.toString());

               jsonkid.put(data1,String.valueOf(degreeCode));
               
               jsonkid.put(data16, Operations.getSecondaryPR(Integer.parseInt(rs.getString(6)),ds));
               jsonkid.put(data11, new JSONArray(Operations.getCommonFriendsChild(Integer.parseInt(userTblPk),Integer.parseInt(rs.getString(6)),ds)));
               jsonkid.put(data4,"");
           }
          jsonkid.put(data17,privacyEnforcedFlag);
           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getchildprofiledetails"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonkid);
          
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
