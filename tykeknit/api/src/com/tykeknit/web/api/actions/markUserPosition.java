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
  * $Id: markUserPosition.java,v 1.13 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.simplegeo.client.SimpleGeoStorageClient;
import com.simplegeo.client.callbacks.SimpleGeoCallback;
import com.simplegeo.client.http.exceptions.APIException;
import com.simplegeo.client.types.Record;

import com.tykeknit.web.api.actionforms.markUserPositionForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import java.util.HashMap;
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

import org.json.JSONObject;


/**
 * Method:  markUserPosition
 * Stores latitude and longitude of current logged in user with the simpleGeo system
 *
 * Required Parameters:
 *  txtLat          - Latitude
 *  txtLong         - Longitude
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "markUserPosition",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   IOException/APIException
 *  -1     -   SimpleGeo Timeout
 *
 *  See Also:
 *      <getMap>
 *
 */

public class

markUserPosition extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      markUserPositionForm markUserPositionForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      String simplegeoKey = null;
      String simplegeoSecret = null;
      String simplegeoKnitLayer = null;
      int rc = 0;

      try {
           logger.debug("Enter");
           
          markUserPositionForm=(markUserPositionForm)form;
          context=servlet.getServletContext();
          jdbcDS = (String)context.getAttribute("jdbcDS");
          
          logger.debug("jdbs-DS:" + jdbcDS);
          
          HttpSession session = request.getSession();
          
          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);

          User user = (User) session.getAttribute("user");
          
          PrintWriter out=response.getWriter();

          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          String userTblPk = user.getUserTblPk();

          if (user.getUserLat() == null) {
              user.setUserLat("");
          }
          
          if (user.getUserLong() == null) {
              user.setUserLong("");
          }
          
          if (user.getUserLat().equals(markUserPositionForm.getTxtLat()) && user.getUserLong().equals(markUserPositionForm.getTxtLong())) {
              
          }
          else {
              simplegeoKey = (String)context.getAttribute("simplegeoKey");
              simplegeoSecret = (String)context.getAttribute("simplegeoSecret");
              simplegeoKnitLayer = (String)context.getAttribute("simplegeoKnitLayer");
              
              logger.debug("simplegeoKey:" + simplegeoKey);
              logger.debug("simplegeoSecret:" + simplegeoSecret);
              logger.debug("simplegeoKnitLayer:" + simplegeoKnitLayer);
              
              final CyclicBarrier barrier = new CyclicBarrier(2);

              try {
                  SimpleGeoStorageClient client = SimpleGeoStorageClient.getInstance();
                  client.getHttpClient().setToken(simplegeoKey, simplegeoSecret);
                  
                  logger.debug("userTblPk:" + userTblPk);
                  logger.debug("simplegeoKnitLayer:" + simplegeoKnitLayer);
                  logger.debug("txtLong:" + markUserPositionForm.getTxtLong());
                  logger.debug("txtLat:" + markUserPositionForm.getTxtLat());
                  Record record = new Record(userTblPk, simplegeoKnitLayer, "", Double.parseDouble(markUserPositionForm.getTxtLong()), Double.parseDouble(markUserPositionForm.getTxtLat()));
                  
                  client.addOrUpdateRecord(record, new SimpleGeoCallback<HashMap<String, Object>>() {
                    @Override
                    public void onSuccess(HashMap<String, Object> hasmap) {
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
                      jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.markuserposition"));
                      jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasoncode.2"));
                      jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasonstr.2"));
                      jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);

                      out.print(jsonStatus.toString());
                      out.close();
                      out.flush();

                      return mapping.findForward(null);
                  }
                  else {
                      user.setUserLat(markUserPositionForm.getTxtLat());
                      user.setUserLong(markUserPositionForm.getTxtLong());
                      rc = Operations.updateUserLocation(user.getUserLat(),user.getUserLong(),Integer.parseInt(userTblPk), ds);
                      
                      session.setAttribute("user", user);
                  }
                  client = null;
              } catch(APIException e) {
                  e.printStackTrace();
                  logger.error("--- IOException Caught ---");
                  logger.error("Status Code: " + e.statusCode);
                  logger.error("Message: " + e.getMessage());

                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.markuserposition"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasonstr.1"));
                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              } catch(IOException e) {
                  e.printStackTrace();
                  logger.error("--- IOException Caught ---");
                  logger.error("Message: " + e.getMessage());

                  jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
                  jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.markuserposition"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.markuserposition.message.failure.reasonstr.1"));
                  jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
              } finally {
              }
          }
          
          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.markuserposition"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),"");

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