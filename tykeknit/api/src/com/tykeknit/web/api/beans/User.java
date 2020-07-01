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
  * $Id: User.java,v 1.5 2011/05/13 01:59:22 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.beans;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;


public class 
User
{
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
	
    private String username;
    private String password;
    private String userTblPk;
    private String userFName;
    private String userLName;
    private String userEmail;
    private String userZip;
    private String userLat;
    private String userLong;
    private boolean account_confirmation_flag;
    private int account_days_eff;

    public User(String p1, String p2) 
    {
       setUsername(p1);
       setPassword(p2);
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String get_username() {
        return username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPassword() {
        return password;
    }
    
    public boolean passwordMatch(String p1) 
    {
      if (this.password.equals(p1))
         return true;
      else
         return false;
    }

    public void setUserTblPk(String userTblPk) {
        this.userTblPk = userTblPk;
    }

    public String getUserTblPk() {
        return userTblPk;
    }

    public void setUserFName(String userFName) {
        this.userFName = userFName;
    }

    public String getUserFName() {
        return userFName;
    }

    public void setUserLName(String userLName) {
        this.userLName = userLName;
    }

    public String getUserLName() {
        return userLName;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserZip(String userZip) {
        this.userZip = userZip;
    }

    public String getUserZip() {
        return userZip;
    }

    public void setUserLat(String userLat) {
        this.userLat = userLat;
    }

    public String getUserLat() {
        return userLat;
    }

    public void setUserLong(String userLong) {
        this.userLong = userLong;
    }

    public String getUserLong() {
        return userLong;
    }

    public void setAccount_confirmation_flag(boolean account_confirmation_flag) {
        this.account_confirmation_flag = account_confirmation_flag;
    }

    public boolean isAccount_confirmation_flag() {
        return account_confirmation_flag;
    }

    public void setAccount_days_eff(int account_days_eff) {
        this.account_days_eff = account_days_eff;
    }

    public int getAccount_days_eff() {
        return account_days_eff;
    }
}
