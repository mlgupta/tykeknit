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
  * $Id: zipToGeoloc.java,v 1.1 2011/03/22 10:15:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.zipToGeolocForm;
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

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.MessageResources;

import org.json.JSONObject;


/**
 * Method:  zipToGeoloc
 * Returns latitude and longitude for a zipcode
 *
 * Required Parameters:
 *  txtZip       - Zip Code
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      No
 *
 * Returns:
 * (start code)
 * { "methodName" : "zipToGeoloc",
 *   "response" : { zipGeoLoc : {Lat : "", Long : ""},
 *                },
 *   "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -100   - SQLException
 *    -1   - Invalid Zipcode
 *
 *  See Also:
 *
 */

public class

zipToGeoloc extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      zipToGeolocForm zipToGeolocForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");
           
           zipToGeolocForm=(zipToGeolocForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
           
           logger.debug("jdbs-DS:" + jdbcDS);
           
           PrintWriter out=response.getWriter();

          String txtZip = zipToGeolocForm.getTxtZip();

          Context ctx = new javax.naming.InitialContext();
          DataSource ds = (DataSource)ctx.lookup(jdbcDS);
          
          DBConnection dbcon = new DBConnection(ds);
          
          JSONObject jsonStatus   = new JSONObject();
          JSONObject jsonResponse = new JSONObject();

          sqlString  = "select a.latitude "
                     +       ",a.longitude ";
          sqlString += "from zip_codes   a ";
          sqlString += "where a.zip = '" + txtZip + "' ";

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);

          JSONObject geoJSON = new JSONObject();

          if (!rs.next()) {
              jsonResponse.put(messageResources.getMessage("json.response.methodname.zipToGeoloc.displayname.data1"),messageResources.getMessage("json.response.methodname.zipToGeoloc.message.failure.reasonstr.1"));
          }
          else {
              geoJSON.put("Lat",rs.getString(1));
              geoJSON.put("Long",rs.getString(2));
              
              jsonResponse.put(messageResources.getMessage("json.response.methodname.zipToGeoloc.displayname.data1"),geoJSON);
          }
          logger.debug("geoJSON : " + geoJSON.toString());
          
          dbcon.free(rs);                      
          
          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.zipToGeoloc"));
         
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
