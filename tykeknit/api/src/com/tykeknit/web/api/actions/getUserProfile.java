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
  * $Id: getUserProfile.java,v 1.14 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getUserProfileForm;
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
 * Method:  getUserProfile
 * Retrives Users profile
 *
 * Required Parameters:
 *  txtUserTblPk    - User Tables primary key (user id)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "getUserProfile",
 *    "response" : {"userDetails":{
 *         "gender":"",
 *        "Age":"
 *        "firstName":"",
 *        "id":"",
 *        "lastName":"",
 *        "zipcode":"",
 *        "picURL" : "",
 *        "DegreeCode" : "",
 *        "privacyEnforcedFlag": ""
 *     },
 *     "commonFriends" : "{}",
 *     "Kids":[
 *        {
 *           "gender":"M",
 *           "status":"t",
 *           "Age":"2 years 3 mons 26 days",
 *           "firstName":"abhina",
 *           "id":"26",
 *           "lastName":"singh"
 *            "picURL" : ""
 *        },
 *        {
 *           "gender":"M",
 *           "status":"t",
 *           "Age":"1 year 3 mons 26 days",
 *           "firstName":"abhinav",
 *           "id":"25",
 *           "lastName":"singh"
 *            "picURL" : ""
 *        },
 *      ],
 *     "spouseDetails":{
 *      }
 *    }
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid txtUserTblPk
 *
 *  See Also:
 *      <getChildProfileDetails>
 *
 */

public class

getUserProfile extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getUserProfileForm getUserProfileForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
           getUserProfileForm=(getUserProfileForm)form;
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
           
           String txtUserTblPk = getUserProfileForm.getTxtUserTblPk();

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "select a.user_tbl_pk "
                      +       ",a.user_fname "
                      +       ",a.user_lname "
                      +       ",age(a.user_dob) "
                      +       ",a.user_email "
                      +       ",b.parent_type "
                      +       ",a.zipcode "
                      +       ",a.user_dob "
                      +       ",a.image_tbl_fk "
                      +       ",a.user_profile_setting ";
           sqlString += "from user_tbl            a "
                      +     ",parent_type_tbl     b ";
           sqlString += "where a.user_tbl_pk = " + txtUserTblPk
                      +   " and a.parent_type_tbl_fk = b.parent_type_tbl_pk "
                      +   " and a.date_eff <= CURRENT_DATE "
                      +   " and a.date_inac > CURRENT_DATE ";

           logger.debug(sqlString);
          
           rs = dbcon.executeQuery(sqlString); 
           
           if (!rs.next()) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getuserurofile"));
              
              jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getuserprofile.message.failure.reasoncode.1"));
              jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getuserurofile.message.failure.reasonstr.1"));

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              
              dbcon.free(rs);                      

              out.print(jsonStatus.toString());
              out.close();
              out.flush();
              return mapping.findForward(null);
           }

           JSONObject jsonUser = new JSONObject();
           JSONObject jsonSpouse = new JSONObject();
           
           String data1 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data7");
           String data8 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data8");
           String data9 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data9");
           String data10 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data10");
           String data11 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data11");
           String data12 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data12");
           String data13 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data13");
           String data14 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data14");

           String value14 = messageResources.getMessage("json.response.methodname.getUserProfile.value.data14");
           String data15 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data15");
           String data16 = messageResources.getMessage("json.response.methodname.getUserProfile.displayname.data16");
           
           String image_tbl_fk = "";
           
           int degreeCode = Operations.getDegreeCode(Integer.parseInt(userTblPk),Integer.parseInt(rs.getString(1)), ds);
           boolean privacyEnforcedFlag = true;
           
           jsonUser.put(data9,rs.getString(1));
           jsonUser.put(data4,rs.getString(2));
           jsonUser.put(data5,rs.getString(3));
           jsonUser.put(data16,degreeCode);

           if (degreeCode <= Integer.parseInt(rs.getString(10))) {
               privacyEnforcedFlag = false;
               jsonUser.put(data6,rs.getString(4));
               jsonUser.put(data8,rs.getString(6));
               jsonUser.put(data11,rs.getString(7));
               jsonUser.put(data12,rs.getString(8));

               image_tbl_fk = rs.getString(9);
               
               if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
                   
               }
               else {
                   jsonUser.put(data14,value14 + image_tbl_fk);
               }
           }
          
           jsonResponse.put(data13,new JSONArray(Operations.getCommonFriends(Integer.parseInt(userTblPk),Integer.parseInt(txtUserTblPk),ds)));
           jsonUser.put(data15,privacyEnforcedFlag);

           jsonResponse.put(data1,jsonUser);

           if (degreeCode <= Integer.parseInt(rs.getString(10))) {
              rs = null;

              String spouseUserTblPk = null;
              
              sqlString  = "select a.user_tbl_pk "
                         +       ",a.user_fname "
                         +       ",a.user_lname "
                         +       ",age(a.user_dob) "
                         +       ",a.user_email "
                         +       ",b.parent_type "
                         +       ",a.image_tbl_fk "
                         +       ",a.user_profile_setting ";
              sqlString += "from user_tbl            a "
                         +     ",parent_type_tbl     b "
                         +     ",secondary_pr_tbl    c ";
              sqlString += "where a.user_tbl_pk = c.secondary_user_tbl_fk " 
                         +   " and a.parent_type_tbl_fk = b.parent_type_tbl_pk "
                         +   " and c.primary_user_tbl_fk = " + txtUserTblPk
                         +   " and c.confirmation_flag = True "
                         +   " and a.date_eff <= CURRENT_DATE "
                         +   " and a.date_inac > CURRENT_DATE "
                         +   " and c.date_eff <= CURRENT_DATE "
                         +   " and c.date_inac > CURRENT_DATE ";

              logger.debug(sqlString);
              
              rs = dbcon.executeQuery(sqlString);
              
              if (rs.next()) {
                 jsonSpouse.put(data9,rs.getString(1));
                 jsonSpouse.put(data4,rs.getString(2));
                 jsonSpouse.put(data5,rs.getString(3));
                 
                  if (degreeCode <= Integer.parseInt(rs.getString(8))) {
                      jsonSpouse.put(data6,rs.getString(4));
                      jsonSpouse.put(data8,rs.getString(6));

                      image_tbl_fk = rs.getString(7);
                      
                      if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
                          
                      }
                      else {
                          jsonSpouse.put(data14,value14 + image_tbl_fk);
                      }
                  }

                 spouseUserTblPk = rs.getString(1);
              }
              else {
                 rs = null;
                 
                 sqlString  = "select a.user_tbl_pk "
                            +       ",a.user_fname "
                            +       ",a.user_lname "
                            +       ",age(a.user_dob) "
                            +       ",a.user_email "
                            +       ",b.parent_type "
                            +       ",a.image_tbl_fk "
                            +       ",a.user_profile_setting ";
                 sqlString += "from user_tbl            a "
                            +     ",parent_type_tbl     b "
                            +     ",secondary_pr_tbl    c ";
                 sqlString += "where a.user_tbl_pk = c.primary_user_tbl_fk " 
                            +   " and a.parent_type_tbl_fk = b.parent_type_tbl_pk "
                            +   " and c.secondary_user_tbl_fk = " + txtUserTblPk
                            +   " and a.date_eff <= CURRENT_DATE "
                            +   " and a.date_inac > CURRENT_DATE "
                            +   " and c.date_eff <= CURRENT_DATE "
                            +   " and c.date_inac > CURRENT_DATE ";

                 logger.debug(sqlString);
                 
                 rs = dbcon.executeQuery(sqlString); 
                 
                 if (rs.next()) {
                     jsonSpouse.put(data9,rs.getString(1));
                     jsonSpouse.put(data4,rs.getString(2));
                     jsonSpouse.put(data5,rs.getString(3));
                     
                     if (degreeCode <= Integer.parseInt(rs.getString(8))) {
                         jsonSpouse.put(data6,rs.getString(4));
                         jsonSpouse.put(data8,rs.getString(6));

                         image_tbl_fk = rs.getString(7);
                         
                         if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
                             
                         }
                         else {
                             jsonSpouse.put(data14,value14 + image_tbl_fk);
                         }
                     }
                     spouseUserTblPk = rs.getString(1);
                 }
              }

              jsonResponse.put(data2,jsonSpouse);
              
              rs = null;

              sqlString  = "select a.child_tbl_pk "
                        +       ",a.child_fname "
                        +       ",a.child_lname "
                        +       ",a.child_dob "
                        +       ",a.child_gender "
                        +       ",a.wanna_hang "
                        +       ",a.image_tbl_fk ";
              sqlString += "from child_tbl            a ";
              
              if (spouseUserTblPk == null || "".equals(spouseUserTblPk)) {
                 sqlString += "where a.parent_tbl_fk = " +  txtUserTblPk;
              }
              else {
                 sqlString += "where a.parent_tbl_fk in (" +  txtUserTblPk + "," + spouseUserTblPk + ") ";
              }
              sqlString +=   " and a.date_eff <= CURRENT_DATE "
                        +   " and a.date_inac > CURRENT_DATE ";
              sqlString +=   " order by a.child_fname,a.child_lname ";
                        

              logger.debug(sqlString);
              
              rs = dbcon.executeQuery(sqlString);
              
              while (rs.next()) {
                 JSONObject jsonkid = new JSONObject();
                 
                 jsonkid.put(data9, rs.getString(1));
                 jsonkid.put(data4, rs.getString(2));
                 jsonkid.put(data5, rs.getString(3));
                 jsonkid.put(data6, rs.getString(4));
                 jsonkid.put(data8, rs.getString(5));
                 jsonkid.put(data10, rs.getString(6));

                 image_tbl_fk = rs.getString(7);
                 
                 if (image_tbl_fk == null || "".equals(image_tbl_fk)) {
                     
                 }
                 else {
                     jsonkid.put(data14,value14 + image_tbl_fk);
                 }
                 
                 jsonResponse.append(data3, jsonkid);
              }
           }
           
           dbcon.free(rs);                      

           jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
           jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getUserProfile"));
           jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          
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
