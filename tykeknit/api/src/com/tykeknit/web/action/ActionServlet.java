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
  * $Id: ActionServlet.java,v 1.2 2011/03/18 07:34:02 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.action;

import com.tykeknit.web.general.beans.TKConstants;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;


/**
 *              Purpose: General Action Servlet
 *
 *             @author   Manish Gupta
 *            @version   1.0
 *    Date of creation : 03-20-2007
 *    Last Modified by : 
 *  Last Modified Date :
 */

public class ActionServlet extends org.apache.struts.action.ActionServlet {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    private ServletContext context = null;

  public void init(ServletConfig config) throws ServletException {

    try {
      super.init(config);

      log("Entering Actionservlet");

      log("Initializing Logger...");
      context = config.getServletContext();
      
      String prefix = context.getRealPath("/");
      String log4jInitFile = getInitParameter("log4j-init-file");
      String smtpHost = getInitParameter("smtp-host");
      String domain = getInitParameter("domain");
      String sendMailTo = getInitParameter("sendmailto");
      String appURL = getInitParameter("web-server");
      String jdbcDS = getInitParameter("jdbc-DS");
      String simplegeoKey = getInitParameter("simplegeo-key");
      String simplegeoSecret = getInitParameter("simplegeo-secret");
      String simplegeoKnitLayer = getInitParameter("simplegeo-knit-layer");
      String simplegeoEventLayer = getInitParameter("simplegeo-event-layer");
      
      context.setAttribute("contextPath", prefix);
      context.setAttribute("smtpHost", smtpHost);
      context.setAttribute("domain", domain);
      context.setAttribute("sendMailTo", sendMailTo);
      context.setAttribute("appURL", appURL);
      context.setAttribute("jdbcDS", jdbcDS);
      context.setAttribute("simplegeoKey", simplegeoKey);
      context.setAttribute("simplegeoSecret", simplegeoSecret);
      context.setAttribute("simplegeoKnitLayer", simplegeoKnitLayer);
      context.setAttribute("simplegeoEventLayer", simplegeoEventLayer);
      
      if (log4jInitFile != null) {
        PropertyConfigurator.configure(prefix + log4jInitFile);
        logger.info("Logger initialized successfully..");
      } else {
        log("Unable to find log4j-initialization-file : " + log4jInitFile);
      }
      logger.debug("Exit init");
    } catch (Exception e) {
      e.printStackTrace();
      log(" Unable to initialize logger : " + e.toString());
    }
  }

//All the request will pass through this method
  public void process(HttpServletRequest request,
                      HttpServletResponse response) {
   
      logger.debug("Enter");    
      
      try {
        super.process(request, response);
        logger.debug("Exit");    
      } catch (Exception ex) {
        ex.printStackTrace();
        logger.error(ex);
      }
  }
}
