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
  * $Id: setDBWannaHang.java,v 1.4 2011/04/01 07:02:57 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.setDBWannaHangForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

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
 * Method:  setDBWannaHang
 *  Updates wanna hang status for user's tykes
 *
 * Required Parameters:
 *  txtWannaHangStatus  - Wanna Hang Status for users tykes in JSON format ({KidsStatus:[{Cid:"",WannaHang:""},{Cid:"",WannaHang:""}]}, WannaHang can have a value of "0" or "1")
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "setDBWannaHang",
 *    "responseStatus" : "success",
 *    "response" : "{WannaHangUpdateStatus:[{Cid:"", updateStatus:""},{Cid:"", updateStatus:""}]}",
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized user
 *  -100   -   SQLException
 *  -1     -   Invalid WannaHang Input (needs to be either 0 or 1)
 *
 *  See Also:
 *      <getDBWannaHang>
 *
 */

public class

setDBWannaHang extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      setDBWannaHangForm setDBWannaHangForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;

      try {
           logger.debug("Enter");

           setDBWannaHangForm=(setDBWannaHangForm)form;
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
          
          String txtDBWannaHangStatus = setDBWannaHangForm.getTxtDBWannaHangStatus();
          
          JSONObject jsonWannaHangStr = new JSONObject(txtDBWannaHangStatus);
          JSONArray jsonWannaHangArray = new JSONArray();
          jsonWannaHangArray = jsonWannaHangStr.getJSONArray("KidsStatus");
          
          int jsonIndex = 0;
          int jsonWannaHangArrayLength = jsonWannaHangArray.length();
          JSONObject jsonKid = new JSONObject();
          
          String childTblPk = "";
          String childWannaHangStatus = "";

          JSONObject jsonKidsUpdateStaus = new JSONObject();

          String data1 = messageResources.getMessage("json.response.methodname.setDBWannaHang.displayname.data1");
          String data2 = messageResources.getMessage("json.response.methodname.setDBWannaHang.displayname.data2");
          String data3 = messageResources.getMessage("json.response.methodname.setDBWannaHang.displayname.data3");

          while (jsonIndex < jsonWannaHangArrayLength) {
              childTblPk = "";
              childWannaHangStatus = "";

              jsonKid =  jsonWannaHangArray.getJSONObject(jsonIndex);

              childTblPk = jsonKid.getString("Cid");
              childWannaHangStatus = jsonKid.getString("WannaHang");
              
              rc = Operations.setDBWannaHang(userTblPk, Integer.parseInt(childTblPk), Integer.parseInt(childWannaHangStatus), ds);

              JSONObject jsonKidUpdateStaus = new JSONObject();
              
              jsonKidUpdateStaus.put(data2,childTblPk);
              
              if (rc < 0) {
                  jsonKidUpdateStaus.put(data3,messageResources.getMessage("json.response.message.failure.reasoncode.2")+ " " + messageResources.getMessage("json.response.message.failure.reasonstr.2"));
              }
              else {
                  jsonKidUpdateStaus.put(data3,messageResources.getMessage("json.response.message.success"));
              }
              
              jsonKidsUpdateStaus.append(data1, jsonKidUpdateStaus);
              ++jsonIndex;
          }

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.setDBWannaHang"));
              
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonKidsUpdateStaus);
              
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
