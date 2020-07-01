/*
 *****************************************************************************
 *                       Confidentiality Information                         *
 *                                                                           *
 * This module is the confidential and proprietary information of            *
 * Tykeknit.; it is not to be copied, reproduced, or transmitted in any      *
 * form, by any means, in whole or in part, nor is it to be used for any     *
 * purpose other than that for which it is expressly provided without the    *
 * written permission of Tykeknit.                                           *
 *                                                                           *
 * Copyright (c) 2010-2011 Tykeknit.  All Rights Reserved.                   *
 *                                                                           *
 *****************************************************************************
 * $Id: tykeknitRequestProcessor.java,v 1.4 2011/04/21 18:03:08 manish Exp $
 *****************************************************************************
 */

package com.tykeknit.web.action;

import com.tykeknit.web.api.beans.User;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionMapping;

import org.json.JSONObject;


/**
 *              Purpose: Custom Request processor
 *
 *             @author   Manish Gupta
 *            @version   1.0
 *    Date of creation : 09-15-2010
 *    Last Modified by : 
 *  Last Modified Date :
 */

public class tykeknitRequestProcessor extends org.apache.struts.action.RequestProcessor {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());


    protected boolean processRoles(HttpServletRequest request,
                                   HttpServletResponse response,
                                   ActionMapping mapping) throws IOException, ServletException {   
      logger.debug("Enter");    

      // Is this action protected by role requirements?
      String roles[] = mapping.getRoleNames();
      if ((roles == null) || (roles.length < 1)) {
          return (true);
      }

      String requestedApi = request.getRequestURI();
      logger.debug("requestedPage: " + requestedApi);
      
      HttpSession session = request.getSession();
      
      User user = (User) session.getAttribute("user");

      PrintWriter out=response.getWriter();

      if (user == null) {
          logger.debug("Invalid Session");

          try {
                JSONObject jsonStatus   = new JSONObject();
                JSONObject jsonResponse = new JSONObject();

                jsonStatus.put("responseStatus","failure");
                jsonStatus.put("methodName",requestedApi);
              
                jsonResponse.put("reasonCode","-401");
                jsonResponse.put("reasonStr","Invalid Session for call to " + requestedApi);

                jsonStatus.put("reason",jsonResponse);

                out.print(jsonStatus.toString());
                out.close();
                out.flush();
          } catch (Exception e) {
            logger.error(e.toString());
          }
          return false;
      }
      
      if (!user.isAccount_confirmation_flag() && user.getAccount_days_eff() > 7) {
          logger.debug("Unauthorized User");

          try {
                JSONObject jsonStatus   = new JSONObject();
                JSONObject jsonResponse = new JSONObject();

                jsonStatus.put("responseStatus","failure");
                jsonStatus.put("methodName",requestedApi);
              
                jsonResponse.put("reasonCode","-401");
                jsonResponse.put("reasonStr","User unauthorized to access " + requestedApi);

                jsonStatus.put("reason",jsonResponse);

                out.print(jsonStatus.toString());
                out.close();
                out.flush();
          } catch (Exception e) {
            logger.error(e.toString());
          }
          return false;
      }
      
      logger.debug("Exit");    
      return (true);
  }
}
