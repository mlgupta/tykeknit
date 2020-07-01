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
  * $Id: registerConfirm.java,v 1.2 2011/04/29 15:15:39 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.registerConfirmForm;
import com.tykeknit.web.api.beans.Operations;
import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;

import javax.naming.Context;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
//import org.apache.struts.util.MessageResources;

/**
 * Method:  registerConfirm
 * Confirms Users Registration
 *
 * Required Parameters:
 *  confirmCode -   This needs to be supplied embedded in the url
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      None
 *
 * Returns:
 * (start code)
 * (end code)
 *
 * Exception:
 *  -100   -   SQLException
 *    -1   -   Invalid confirmCode
 *
 *  See Also:
 *
 */

public class

registerConfirm extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      registerConfirmForm registerConfirmForm=null;
      ServletContext context=null;
//      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;

      try {
           logger.debug("Enter");

           registerConfirmForm=(registerConfirmForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);

           String confirmCode = request.getParameter("confirmCode");
          
           if (confirmCode == null || "".equals(confirmCode) || confirmCode.length() > 6) {
              rc = -1;
           }
           else {
              Context ctx = new javax.naming.InitialContext();
              DataSource ds = (DataSource)ctx.lookup(jdbcDS);

              rc = Operations.registerConfirm(Integer.parseInt(confirmCode),ds);  
           }
           
          registerConfirmForm.setRc(Integer.toString(rc));
      } catch (Exception e) {
        logger.error(e.toString());
        registerConfirmForm.setRc("-1");
      } finally {
         request.setAttribute("registerConfirmForm", registerConfirmForm);
         logger.debug("Exit");
      }
      return mapping.findForward("success");
    }
}
