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
  * $Id: getMap.java,v 1.21 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.simplegeo.client.SimpleGeoStorageClient;
import com.simplegeo.client.callbacks.FeatureCollectionCallback;
import com.simplegeo.client.http.exceptions.APIException;

import com.simplegeo.client.types.FeatureCollection;

import com.tykeknit.web.api.actionforms.getMapForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.TykeOnMap;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.api.beans.getMapLastResults;
import com.tykeknit.web.general.beans.DBConnection;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import java.sql.ResultSet;

import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

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

import org.json.JSONException;
import org.json.JSONObject;


/**
 * Method:  getMap
 * Gets list of tykeknit users around you. Data can be filtered on 
 *
 * Required Parameters:
 *  txtLat        - Latitude
 *  txtLong       - Longitude
 *  txtRadius     - Radius of search
 *
 * Optional Parameters:
 *  txtDegreeCode      - Limit search to knit degree code (1-Wanna Hang, 2-1st Degree, 3-1st and 2nd degree, 4-All) 
 *  txtGenderCode      - Limit search to gender (0-Male, 1-Female)
 *  txtAgeCode         - Limit Search to age group (1-0 to 2, 2-2 to 4, 3-4 to 6, 4-6 to 8, 5-8+)
 *  txtSearchString    - Limit search on a search string
 *  txtCount           - Limit result to this count
 *  txtStart           - Offset
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getMap",
 *  "response" : { "Parents" : [ {  },
 *          { "Kids" : [ { "PhotoUrl" : "/displayPhoto.do?photoID=xxx",
 *                  "txtChildAge" : "",
 *                  "txtChildFname" : "",
 *                  "txtChildGender" : "",
 *                  "txtChildLname" : "",
 *                  "txtWannaHang" : "",
 *                  "txtChildTblPk" : ""
 *                },
 *                { "PhotoUrl" : "/displayPhoto.do?photoID=xxx",
 *                  "txtChildAge" : "",
 *                  "txtChildFname" : "",
 *                  "txtChildGender" : "",
 *                  "txtChildLname" : "",
 *                  "txtWannaHang" : "",
 *                  "txtChildTblPk" : ""
 *                },
 *                { "PhotoUrl" : "/displayPhoto.do?photoID=xxx",
 *                  "txtChildAge" : "",
 *                  "txtChildFname" : "",
 *                  "txtChildGender" : "",
 *                  "txtChildLname" : "",
 *                  "txtWannaHang" : "",
 *                  "txtChildTblPk" : ""
 *                }
 *              ],
 *            "PhotoUrl" : "",
 *            "txtLong" : "",
 *            "txtLat" : "",
 *            "txtParentFname" : "",
 *            "txtParentLname" : "",
 *            "txtParentType" : "",
 *            "txtUserTblPk" : "",
 *            "DegreeCode" : ""
 *          },
 *          { "Kids" : [ { "PhotoUrl" : "",
 *                  "txtChildAge" : "",
 *                  "txtChildFname" : "",
 *                  "txtChildGender" : "",
 *                  "txtChildLname" : "",
 *                  "txtWannaHang" : "",
 *                  "txtChildTblPk" : ""
 *                },
 *                { "PhotoUrl" : "",
 *                  "txtChildAge" : "",
 *                  "txtChildFname" : "",
 *                  "txtChildGender" : "",
 *                  "txtChildLname" : "",
 *                  "txtWannaHang" : "",
 *                  "txtChildTblPk" : ""
 *                }
 *              ],
 *            "PhotoUrl" : "",
 *            "txtLong" : "",
 *            "txtLat" : "",
 *            "txtParentFname" : "",
 *            "txtParentLname" : "",
 *            "txtParentType" : "",
 *            "DegreeCode" : "",
 *            "txtUserTblPk" : ""
 *          }
 *        ] },
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   IOException/APIException
 *
 *  See Also:
 *      
 *
 */

public class

getMap extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getMapForm getMapForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      String simplegeoKey = null;
      String simplegeoSecret = null;
      String simplegeoKnitLayer = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
          getMapForm=(getMapForm)form;
          context=servlet.getServletContext();
          jdbcDS = (String)context.getAttribute("jdbcDS");
          
          logger.debug("jdbs-DS:" + jdbcDS);

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS); 
           
          HttpSession session = request.getSession();
            
          User user = (User) session.getAttribute("user");

          PrintWriter out=response.getWriter();

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();

          if (getMapForm.getTxtCount() == null || "".equals(getMapForm.getTxtCount())) {
              getMapForm.setTxtCount("20");
          }

          if (getMapForm.getTxtStart() == null || "".equals(getMapForm.getTxtStart())) {
              getMapForm.setTxtStart("0");
          }

          String whereTykeOnMapUserTblPk = "";
          
          getMapLastResults gm = (getMapLastResults) session.getAttribute("getMapLastResults");
          boolean prev_result_usable_flag = false;

          if (gm == null || "".equals(gm)) {
          }
          else {
              String prev_txt_degree_code = gm.getTxtDegreeCode();
              String prev_txt_gender_code = gm.getTxtGenderCode();
              String prev_txt_age_code = gm.getTxtAgeCode();
              String txt_degree_code = getMapForm.getTxtDegreeCode();
              String txt_gender_code = getMapForm.getTxtGenderCode();
              String txt_age_code = getMapForm.getTxtAgeCode();
              
              if (gm.getTxtLat().equals(getMapForm.getTxtLat()) &&
                  gm.getTxtLong().equals(getMapForm.getTxtLong()) &&
                  gm.getTxtRadius().equals(getMapForm.getTxtRadius()) &&
                  (getMapForm.getTxtSearchString() == null || "".equals(getMapForm.getTxtSearchString())) &&
                  (gm.getTxtSearchString() == null || "".equals(gm.getTxtSearchString()))) {
                   prev_result_usable_flag = true;

                  if ((prev_txt_degree_code != null && txt_degree_code != null && !prev_txt_degree_code.equals(txt_degree_code)) ||
                      (prev_txt_gender_code != null && txt_gender_code != null && !prev_txt_gender_code.equals(txt_gender_code)) ||
                      (prev_txt_age_code != null && txt_age_code != null && !prev_txt_age_code.equals(txt_age_code)) ||
                      (prev_txt_degree_code == null && txt_degree_code != null) || 
                      (prev_txt_degree_code != null && txt_degree_code == null) || 
                      (prev_txt_gender_code == null && txt_gender_code != null) ||
                      (prev_txt_gender_code != null && txt_gender_code == null) ||
                      (prev_txt_age_code == null && txt_age_code != null) ||
                      (prev_txt_age_code != null && txt_age_code == null) ||
                      (!gm.getTxtCount().equals(getMapForm.getTxtCount())) ||
                      (!gm.getTxtStart().equals(getMapForm.getTxtStart()))) {
                         whereTykeOnMapUserTblPk = gm.getWhereTykeOnMapUserTblPk();
                     }
                     else {
                         jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
                         jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
                         jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),gm.getJsonParents());

                         out.print(jsonStatus.toString());
                         out.close();
                         out.flush();

                         return mapping.findForward(null);
                     }
              }
          }

          JSONObject jsonParents = new JSONObject();
          JSONObject jsonParent = new JSONObject();
          JSONObject jsonKid = new JSONObject();

          String data1 = messageResources.getMessage("json.response.methodname.getmap.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.getmap.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.getmap.displayname.data3");
          String data4 = messageResources.getMessage("json.response.methodname.getmap.displayname.data4");
          String data5 = messageResources.getMessage("json.response.methodname.getmap.displayname.data5");
          String data6 = messageResources.getMessage("json.response.methodname.getmap.displayname.data6");
          String data7 = messageResources.getMessage("json.response.methodname.getmap.displayname.data7");
          String data8 = messageResources.getMessage("json.response.methodname.getmap.displayname.data8");
          String data9 = messageResources.getMessage("json.response.methodname.getmap.displayname.data9");
          String data10 = messageResources.getMessage("json.response.methodname.getmap.displayname.data10");
          String data11 = messageResources.getMessage("json.response.methodname.getmap.displayname.data11");
          String data12 = messageResources.getMessage("json.response.methodname.getmap.displayname.data12");
          String data13 = messageResources.getMessage("json.response.methodname.getmap.displayname.data13");
          String data14 = messageResources.getMessage("json.response.methodname.getmap.displayname.data14");
          String data15 = messageResources.getMessage("json.response.methodname.getmap.displayname.data15");
          String data16 = messageResources.getMessage("json.response.methodname.getmap.displayname.data16");
          String value7 = messageResources.getMessage("json.response.methodname.getmap.value.data7");

          simplegeoKey = (String)context.getAttribute("simplegeoKey");
          simplegeoSecret = (String)context.getAttribute("simplegeoSecret");
          simplegeoKnitLayer = (String)context.getAttribute("simplegeoKnitLayer");
           
          logger.debug("simplegeoKey:" + simplegeoKey);
          logger.debug("simplegeoSecret:" + simplegeoSecret);
          logger.debug("simplegeoKnitLayer:" + simplegeoKnitLayer);
          
          String txtSearchString = getMapForm.getTxtSearchString();

          if ((txtSearchString == null || "".equals(txtSearchString)) && !prev_result_usable_flag) {
              whereTykeOnMapUserTblPk = "(";
              final TykeOnMap tykeOnMap = new TykeOnMap();
              final CyclicBarrier barrier = new CyclicBarrier(2);
              try {
                  SimpleGeoStorageClient client = SimpleGeoStorageClient.getInstance();
                  client.getHttpClient().setToken(simplegeoKey, simplegeoSecret);
                  
                  client.search(Double.parseDouble(getMapForm.getTxtLat()),
                                Double.parseDouble(getMapForm.getTxtLong()),
                                simplegeoKnitLayer,
                                Double.parseDouble(getMapForm.getTxtRadius()),
                                100,
                                null,
                                new FeatureCollectionCallback() {
                                   @Override
                                   public void onSuccess(FeatureCollection featureCollection) {
                                     String innerWhereTykeOnMapUserTblPk = "";
                                     try {
                                        logger.debug("featureCollection : " + featureCollection.toJSONString());
                                         int jsonIndex = 0;
                                         int jsonGetMapArrayLength = featureCollection.getFeatures().size();
                                           
                                         String TykeOnMapUserTblPk = null;

                                         while (jsonIndex < jsonGetMapArrayLength) {
                                           TykeOnMapUserTblPk = null;

                                           TykeOnMapUserTblPk = featureCollection.getFeatures().get(jsonIndex).getSimpleGeoId();
                                               
                                           innerWhereTykeOnMapUserTblPk += TykeOnMapUserTblPk + ",";
                                               
                                           ++jsonIndex;
                                         }
                                     } catch (JSONException e) {
                                        logger.error("--- JSONException Caught ---");
                                        logger.error("Message: " + e.getMessage());
                                     }
                                     logger.debug("innerWhereTykeOnMapUserTblPk:" + innerWhereTykeOnMapUserTblPk);
                                     tykeOnMap.setWhereTykeOnMapUserTblPk(innerWhereTykeOnMapUserTblPk);
                                     barrierAwait(barrier);
                                   }
                                   @Override
                                   public void onError(String errorMessage) {
                                       logger.error("Error at barrier");
                                       logger.error("errorMessage:" + errorMessage);
                                   }
                  });
                  int timeOutFlag = barrierAwait(barrier);
                  
                  if (timeOutFlag == 1) {
                      jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                      jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
                        
                      jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasoncode.1"));
                      jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasonstr.1"));

                      jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
                        
                      out.print(jsonStatus.toString());
                      out.close();
                      out.flush();

                      return mapping.findForward(null);
                  }
                 
                  whereTykeOnMapUserTblPk += tykeOnMap.getWhereTykeOnMapUserTblPk();
                  whereTykeOnMapUserTblPk = whereTykeOnMapUserTblPk.substring(0,whereTykeOnMapUserTblPk.length() - 1);
                  if (whereTykeOnMapUserTblPk == null || "".equals(whereTykeOnMapUserTblPk)) {
                      jsonParents.append(data1,jsonParent);

                      jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
                      jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
                      jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonParents);

                      out.print(jsonStatus.toString());
                      out.close();
                      out.flush();

                      return mapping.findForward(null);
                  }
                  whereTykeOnMapUserTblPk += ")";
                  logger.debug("whereTykeOnMapUserTblPk:" + whereTykeOnMapUserTblPk);
                  client = null;
              } catch(APIException e) {
                  e.printStackTrace();
                  logger.error("--- APIException Caught ---");
                  logger.error("Status Code: " + e.statusCode);
                  logger.error("Message: " + e.getMessage());

                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
                    
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasonstr.2"));

                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
                    
                  out.print(jsonStatus.toString());
                  out.close();
                  out.flush();

                  return mapping.findForward(null);

              } catch(IOException e) {
                  e.printStackTrace();
                  logger.error("--- IOException Caught ---");
                  logger.error("Message: " + e.getMessage());

                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
                    
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.getmap.message.failure.reasonstr.2"));

                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
                    
                  out.print(jsonStatus.toString());
                  out.close();
                  out.flush();

                  return mapping.findForward(null);
              }
              finally {
              }
          }
          
          DBConnection dbcon = new DBConnection(ds);
          
          String txtDegreeCode = getMapForm.getTxtDegreeCode();
          String txtGenderCode = getMapForm.getTxtGenderCode();
          String txtAgeCode = getMapForm.getTxtAgeCode();
          
          sqlString  = "select distinct a.user_tbl_pk "
                     +       ",a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.parent_type "
                     +       ",a.parent_image_tbl_fk "
                     +       ",a.child_tbl_pk "
                     +       ",a.child_fname "
                     +       ",a.child_lname "
                     +       ",age(a.child_dob) "
                     +       ",a.child_gender "
                     +       ",a.child_image_tbl_fk "
                     +       ",a.wanna_hang "
                     +       ",a.user_location_lat "
                     +       ",a.user_location_long ";
          sqlString += "from parent_child_vw      a ";

          if (txtSearchString == null || "".equals(txtSearchString)) {
              if (txtDegreeCode == null || "".equals(txtDegreeCode)) {
              }
              else if ("1".equals(txtDegreeCode) || "2".equals(txtDegreeCode)) {
                  sqlString += ",knit_tbl      b ";
              }
              else if ("3".equals(txtDegreeCode)) {
                  sqlString += ",knit_tbl      b ";
                  sqlString += ",knit_tbl      c ";
              }

              sqlString += "where a.user_tbl_pk in " + whereTykeOnMapUserTblPk;

              if (txtDegreeCode == null || "".equals(txtDegreeCode)) {
              }
              else if ("1".equals(txtDegreeCode) || "2".equals(txtDegreeCode)) {
                  sqlString += " and a.user_tbl_pk = b.knit_to_user_tbl_fk "
                             + " and b.knit_from_user_tbl_fk = " + userTblPk;
              }
              else  if ("3".equals(txtDegreeCode)) {
                  sqlString += " and b.knit_from_user_tbl_fk = " + userTblPk 
                             + " and b.knit_to_user_tbl_fk = c.knit_from_user_tbl_fk "
                             + " and a.user_tbl_pk in (b.knit_to_user_tbl_fk, c.knit_to_user_tbl_fk) ";
              }
              else if ("1".equals(txtDegreeCode)) {
                  sqlString += " and a.wanna_hang = 'True' ";
              }

              if (txtGenderCode == null || "".equals(txtGenderCode)) {
              }
              else if ("0".equals(txtGenderCode)){
                  sqlString += " and  a.child_gender = 'M' ";
              }
              else if ("1".equals(txtGenderCode)){
                  sqlString += " and  a.child_gender = 'F' ";
              }

              if (txtAgeCode == null || "".equals(txtAgeCode)) {
              }
              else if ("1".equals(txtAgeCode)){
                  sqlString += " and date_part('year', age(a.child_dob)) < 2 ";
              }
              else if ("2".equals(txtAgeCode)){
                  sqlString += " and date_part('year', age(a.child_dob)) between 2 and 4 ";
              }
              else if ("3".equals(txtAgeCode)){
                  sqlString += " and date_part('year', age(a.child_dob)) between 4 and 6 ";
              }
              else if ("4".equals(txtAgeCode)){
                  sqlString += " and date_part('year', age(a.child_dob)) between 6 and 8 ";
              }
              else if ("5".equals(txtAgeCode)){
                  sqlString += " and date_part('year', age(a.child_dob)) > 8 ";
              }
          }
          else {
              sqlString += " where (a.user_fname like '%" + txtSearchString + "%' "
                        + "   or a.user_lname like '%"  + txtSearchString + "%' "
                        + "   or a.child_fname like '%" + txtSearchString + "%' "
                        + "   or a.child_lname like '%" + txtSearchString + "%') ";
          }
          
          sqlString += " order by a.user_fname, a.user_lname, a.child_fname ";

          logger.debug(sqlString);
          
          rs = dbcon.executeQuery(sqlString); 
          
          String prev_user_tbl_pk = "";

          int degreeCode = 3;
          boolean endOfResultFlag = false;
          int queryResultPointer = 0;
          int queryOffset = Integer.parseInt(getMapForm.getTxtStart());
          
          while (queryResultPointer < queryOffset) {
              if (!rs.next()) {
                  queryResultPointer = queryOffset;
                  endOfResultFlag = true;
              }
              else if (prev_user_tbl_pk.equals(rs.getString(1)))  {
              }
              else {
                  ++queryResultPointer;
                  prev_user_tbl_pk = rs.getString(1);
              }
          }
          
          if (endOfResultFlag || queryResultPointer == 0) {
          }
          else {
              jsonParent = new JSONObject();
              jsonParent.put(data3, rs.getString(1));
              jsonParent.put(data4, rs.getString(2));
              jsonParent.put(data5, rs.getString(3));
              jsonParent.put(data6, rs.getString(4));
              
              if (rs.getString(5) == null) {
                  jsonParent.put(data7, "");
              }
              else {
                  jsonParent.put(data7, value7 + rs.getString(5));
                  
              }
              
              jsonParent.put(data14, rs.getString(13));
              jsonParent.put(data15, rs.getString(14));
              
              degreeCode = Operations.getDegreeCode(Integer.parseInt(userTblPk), Integer.parseInt(rs.getString(1)), ds);
              jsonParent.put(data16, Integer.toString(degreeCode));

              jsonKid = new JSONObject();
              
              jsonKid.put(data8, rs.getString(6));
              jsonKid.put(data9, rs.getString(7));
              jsonKid.put(data10, rs.getString(8));
              jsonKid.put(data11, rs.getString(9));
              jsonKid.put(data12, rs.getString(10));
              
              if (rs.getString(11) == null) {
                  jsonKid.put(data7, "");
              }
              else {
                  jsonKid.put(data7, value7 + rs.getString(11));
              }
              if (degreeCode > 1) {
                  jsonKid.put(data13, "f");
              }
              else {
                  jsonKid.put(data13, rs.getString(12));
              }
              
              jsonParent.append(data2, jsonKid);
          }
          
          int queryLimitPointer = 0;
          int queryLimit = Integer.parseInt(getMapForm.getTxtCount());
          
          while (rs.next() && queryLimitPointer <= queryLimit) {
            if (prev_user_tbl_pk.equals(rs.getString(1))) {
            }
            else {
              degreeCode = 3;
              jsonParents.append(data1,jsonParent);
              
              jsonParent = new JSONObject();
              jsonParent.put(data3, rs.getString(1));
              jsonParent.put(data4, rs.getString(2));
              jsonParent.put(data5, rs.getString(3));
              jsonParent.put(data6, rs.getString(4));
              
              if (rs.getString(5) == null) {
                  jsonParent.put(data7, "");
              }
              else {
                  jsonParent.put(data7, value7 + rs.getString(5));
                  
              }
              
              jsonParent.put(data14, rs.getString(13));
              jsonParent.put(data15, rs.getString(14));
              
              degreeCode = Operations.getDegreeCode(Integer.parseInt(userTblPk), Integer.parseInt(rs.getString(1)), ds);
              jsonParent.put(data16, Integer.toString(degreeCode));

              prev_user_tbl_pk = rs.getString(1);
              ++queryLimitPointer;
            }
            jsonKid = new JSONObject();
            
            jsonKid.put(data8, rs.getString(6));
            jsonKid.put(data9, rs.getString(7));
            jsonKid.put(data10, rs.getString(8));
            jsonKid.put(data11, rs.getString(9));
            jsonKid.put(data12, rs.getString(10));
            
            if (rs.getString(11) == null) {
                jsonKid.put(data7, "");
            }
            else {
                jsonKid.put(data7, value7 + rs.getString(11));
            }
            
            if (degreeCode > 1) {
                jsonKid.put(data13, "f");
            }
            else {
                jsonKid.put(data13, rs.getString(12));
            }
            
            jsonParent.append(data2, jsonKid);
          }

          if(queryLimitPointer > queryLimit) {
          }
          else {
              jsonParents.append(data1,jsonParent);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getmap"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonParents);

          out.print(jsonStatus.toString());
          out.close();
          out.flush();
          
          gm = new getMapLastResults();
          
          gm.setTxtLong(getMapForm.getTxtLong());
          gm.setTxtLat(getMapForm.getTxtLat());
          gm.setTxtRadius(getMapForm.getTxtRadius());
          gm.setTxtDegreeCode(getMapForm.getTxtDegreeCode());
          gm.setTxtGenderCode(getMapForm.getTxtGenderCode());
          gm.setTxtAgeCode(getMapForm.getTxtAgeCode());
          gm.setTxtSearchString(getMapForm.getTxtSearchString());
          gm.setTxtCount(getMapForm.getTxtCount());
          gm.setTxtStart(getMapForm.getTxtStart());
          gm.setJsonParents(jsonParents);
          gm.setWhereTykeOnMapUserTblPk(whereTykeOnMapUserTblPk);
          
          session.setAttribute("getMapLastResults", gm);
      } catch (Exception e) {
        logger.error(e.toString());
      } finally {
         logger.debug("Exit");
      }
      return mapping.findForward(null);
    }
    
    final private int barrierAwait(CyclicBarrier barrier) {
            try {
                    barrier.await(8,TimeUnit.SECONDS);
                    return(0);
            } catch (InterruptedException e) {
               logger.error("--- Interrupted Exception ---");
               logger.error("Message: " + e.getMessage());
                return(1);
            } catch (BrokenBarrierException e) {
                logger.error("--- BrokenBarrier Exception ---");
                logger.error("Message: " + e.getMessage());
                return(1);
            } catch (TimeoutException e) {
                logger.error("SimpleGeo Timeout");
                return(1);
        }
    }
}
