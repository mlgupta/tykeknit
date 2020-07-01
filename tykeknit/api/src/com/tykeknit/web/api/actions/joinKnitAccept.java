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
  * $Id: joinKnitAccept.java,v 1.6 2011/04/15 13:05:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.joinKnitAcceptForm;
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

import org.json.JSONObject;


/**
 * Method:  joinKnitAccept
 * Accept Knit invitation
 *
 * Required Parameters:
 *  txtKnitInviteTblPk     - Knit Invitation ID
 *  txtResponseCode        - Response Code (0-No, 1-Yes, 3-Ignore)
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 *  { "methodName" : "joinKnitAccept",
 *    "response" : "",
 *    "responseStatus" : "success"
 *  }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -401   -   Unauthorized User
 *  -100   -   SQLException
 *    -1   -   Invalid txtKnitInviteTblPk
 *    -2   -   Knit already exists
 *
 *  See Also:
 *      <joinKnitRequest>
 */

public class

joinKnitAccept extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      joinKnitAcceptForm joinKnitAcceptForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      int rc = 0;

      try {
           logger.debug("Enter");
           
          joinKnitAcceptForm=(joinKnitAcceptForm)form;
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
          
          String txtKnitInviteTblPk = joinKnitAcceptForm.getTxtKnitInviteTblPk();
          String txtResponseCode = joinKnitAcceptForm.getTxtResponseCode();
          
          logger.debug("txtKnitInviteTblPk: " + txtKnitInviteTblPk);
          logger.debug("txtResponseCode: " + txtResponseCode);

          // Call Add Invitation to Operations
          rc = Operations.joinKnitAccept(Integer.parseInt(userTblPk),Integer.parseInt(txtKnitInviteTblPk),txtResponseCode,ds);
          
          if (rc < 0) {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.failure"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.joinknitaccept"));
              
              if (rc == -2) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.2"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.2"));
                  
              }
              if (rc == -3) {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.methodname.joinknitaccept.message.failure.reasoncode.1"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.methodname.joinknitaccept.message.failure.reasonstr.1"));
                  
              }
              else {
                  jsonResponse.put(messageResources.getMessage("json.response.reasoncode.displayname"),messageResources.getMessage("json.response.message.failure.reasoncode.4"));
                  jsonResponse.put(messageResources.getMessage("json.response.reasonstr.displayname"),messageResources.getMessage("json.response.message.failure.reasonstr.4"));
              }

              jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonResponse);
          }
          else
          {
              jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
              jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.joinKnitAccept"));
          }
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