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
  * $Id: getDBFriends.java,v 1.11 2011/06/19 16:27:40 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actions;

import com.tykeknit.web.api.actionforms.getDBFriendsForm;
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
 * Method:  getDBFriends
 * Gets list of friends and friends of friends
 *
 * Required Parameters:
 *  None
 *
 * Optional Parameters:
 *  None
 *
 * Authentication Required:
 *      Yes
 *
 * Returns:
 * (start code)
 * { "methodName" : "getDBFriends",
 *  "response" : { friendsCount : "", 
 *         { "Friends" : [ 
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "DegreeCode" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "DegreeCode" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          }
 *        ] },
 *         { "FriendsOfFriends" : [ 
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : ""
 *            "DegreeCode" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "DegreeCode" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          },
 *          { "firstName" : "",
 *            "id" : "",
 *            "lastName" : "",
 *            "DegreeCode" : "",
 *            "Tykes" : [{},{ChildID:"",fName:"",lName:"",Age:""},..,{ChildID:"",fName:"",lName:"",Age:""}],
 *            "picURL" : ""
 *          }
 *        ] }
 *       }
 *  "responseStatus" : "success"
 * }
 * (end code)
 *
 * Exception:
 *  -401   -   Invalid Session
 *  -100   -   SQLException
 *
 *  See Also:
 *      <getUserProfile>
 *
 */

public class

getDBFriends extends Action {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
    
    public ActionForward execute(ActionMapping mapping, 
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {
      getDBFriendsForm getDBFriendsForm=null;
      ServletContext context=null;
      MessageResources messageResources = getResources(request);
      String jdbcDS = null;
      ResultSet rs = null;
      String sqlString = null;

      try {
           logger.debug("Enter");

           getDBFriendsForm=(getDBFriendsForm)form;
           context=servlet.getServletContext();
           jdbcDS = (String)context.getAttribute("jdbcDS");
          
           logger.debug("jdbs-DS:" + jdbcDS);
          
           PrintWriter out=response.getWriter();
           
           Context ctx = new javax.naming.InitialContext();
           DataSource ds = (DataSource)ctx.lookup(jdbcDS);

           HttpSession session = request.getSession();
          
           User user = (User) session.getAttribute("user");
           
           JSONObject jsonStatus   = new JSONObject();
//           JSONObject jsonResponse = new JSONObject();

           String userTblPk = user.getUserTblPk();
           
           String userAndSpouse = "(" + userTblPk + ",";

           DBConnection dbcon = new DBConnection(ds);
          
           sqlString  = "(select distinct a.user_tbl_pk ";
           sqlString += "from user_tbl   a "
                     + "     ,secondary_pr_tbl     b ";
           sqlString += "where b.secondary_user_tbl_fk = " + userTblPk + " "
                     +   "and b.primary_user_tbl_fk = a.user_tbl_pk "
                     +   "and b.confirmation_flag = True "
                     +   "and a.date_eff <= CURRENT_DATE "
                     +   "and a.date_inac > CURRENT_DATE) ";
           sqlString += "UNION ";
           sqlString  += "(select distinct a.user_tbl_pk ";
           sqlString += "from user_tbl   a "
                     + "     ,secondary_pr_tbl     b ";
           sqlString += "where b.primary_user_tbl_fk = " + userTblPk + " "
                     +   "and b.secondary_user_tbl_fk = a.user_tbl_pk "
                     +   "and b.confirmation_flag = True "
                     +   "and a.date_eff <= CURRENT_DATE "
                     +   "and a.date_inac > CURRENT_DATE) ";

           logger.debug(sqlString);
           rs = dbcon.executeQuery(sqlString);

           while(rs.next()) {
              userAndSpouse += rs.getString(1) + ",";
           }
           
           userAndSpouse = userAndSpouse.substring(0,userAndSpouse.length() - 1) + ")";
           
           rs = null;
           int userFriendsCount = 0;
           
           String data1 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data1");
           String data2 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data2");
           String data3 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data3");
           String data4 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data4");
           String data5 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data5");
           String data6 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data6");
           String data7 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data7");
           String data8 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data8");
           String data9 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data9");
           String data10 = messageResources.getMessage("json.response.methodname.getDBFriends.displayname.data10");

           String value1 = messageResources.getMessage("json.response.methodname.getDBFriends.value.data8");
           
           String sqlSubString = "select distinct d.user_tbl_pk ";
           sqlSubString += "from user_tbl d "
                        +      ",secondary_pr_tbl e ";
           sqlSubString += "where ((e.primary_user_tbl_fk = a.user_tbl_pk "
                        +    "and   e.secondary_user_tbl_fk = d.user_tbl_pk) "
                        +    "  or (e.primary_user_tbl_fk = d.user_tbl_pk "
                        +    "and   e.secondary_user_tbl_fk = a.user_tbl_pk)) "
                        +    "and e.confirmation_flag = True "
                        +    "and d.date_eff <= CURRENT_DATE "
                        +    "and d.date_inac > CURRENT_DATE "
                        +    "and e.date_eff <= CURRENT_DATE "
                        +    "and e.date_inac > CURRENT_DATE ";
           
           sqlString  = "select distinct a.user_tbl_pk "
                      +       ",a.user_fname "
                      +       ",a.user_lname "
                      +       ",a.user_email "
                      +       ",a.image_tbl_fk ";
           sqlString += "from user_tbl   a "
                     + "     ,knit_tbl     b ";
           sqlString += "where b.knit_from_user_tbl_fk IN " + userAndSpouse + " "
                     +    "and a.user_tbl_pk = b.knit_to_user_tbl_fk "
                     +    "and a.date_eff <= CURRENT_DATE "
                     +    "and a.date_inac > CURRENT_DATE ";
           sqlString += "order by a.user_fname, a.user_lname ";
           
          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);

          JSONObject jsonFriends = new JSONObject();
          
          String userFriendsList = "(";

          JSONObject jsonFriend = new JSONObject();
          jsonFriends.append(data2,jsonFriend);

          while(rs.next()) {
             ++userFriendsCount;
             
             jsonFriend = new JSONObject();

             jsonFriend.put(data4,rs.getString(1));
             jsonFriend.put(data5,rs.getString(2));
             jsonFriend.put(data6,rs.getString(3));
             
             String image_tbl_fk = rs.getString(5);
              if (image_tbl_fk == null || "".equalsIgnoreCase(image_tbl_fk)) {
                  
              }
              else {
                  jsonFriend.put(data8,value1 + image_tbl_fk);
              }

              String tykes = Operations.getTykesForParent(Integer.parseInt(rs.getString(1)), ds);
              jsonFriend.put(data9,tykes);
              jsonFriend.put(data10,"1");

             jsonFriends.append(data2,jsonFriend);
             
             userFriendsList += rs.getString(1) + ","; 
          }
           
          jsonFriends.put(data1,userFriendsCount);
          
          if ("(".equals(userFriendsList)) {
              userFriendsList +=  ")";
          }
          else {
              userFriendsList = userFriendsList.substring(0,userFriendsList.length() - 1) + ")";
          }
          
          rs = null;
          
          sqlString  = "select distinct a.user_tbl_pk "
                     +       ",a.user_fname "
                     +       ",a.user_lname "
                     +       ",a.user_email ";
          sqlString += "from user_tbl   a "
                    + "     ,knit_tbl   b "
                    + "     ,knit_tbl   c ";
          sqlString += "where b.knit_from_user_tbl_fk IN " + userAndSpouse + " "
                    +   "and a.user_tbl_pk NOT IN " + userAndSpouse + " "
                    +   "and b.knit_to_user_tbl_fk = c.knit_from_user_tbl_fk "
                    +   "and a.user_tbl_pk = c.knit_to_user_tbl_fk  "
                    +   "and a.date_eff <= CURRENT_DATE "
                    +   "and a.date_inac > CURRENT_DATE ";
                    
          if (userFriendsCount == 0) {
              
          }
          else {
              sqlString += " and a.user_tbl_pk NOT IN " + userFriendsList + " ";
              
          }

          logger.debug(sqlString);
          rs = dbcon.executeQuery(sqlString);            

          jsonFriend = new JSONObject();
          jsonFriends.append(data3,jsonFriend);

          while(rs.next()) {
              jsonFriend = new JSONObject();

              jsonFriend.put(data4,rs.getString(1));
              jsonFriend.put(data5,rs.getString(2));
              jsonFriend.put(data6,rs.getString(3));

              String tykes = Operations.getTykesForParent(Integer.parseInt(rs.getString(1)), ds);
              jsonFriend.put(data9,new JSONArray(tykes));
              jsonFriend.put(data10,"2");
              
              jsonFriends.append(data3,jsonFriend);
          }

          dbcon.free(rs);                      

          jsonStatus.put(messageResources.getMessage("json.response.responsestatus.displayname"),messageResources.getMessage("json.response.message.success"));
          jsonStatus.put(messageResources.getMessage("json.response.methodname.displayname"),messageResources.getMessage("json.response.methodname.getDBFriends"));
          jsonStatus.put(messageResources.getMessage("json.response.response.displayname"),jsonFriends);

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
