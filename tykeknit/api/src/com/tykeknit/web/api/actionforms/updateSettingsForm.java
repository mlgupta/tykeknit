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
  * $Id: updateSettingsForm.java,v 1.1 2011/02/22 14:49:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

updateSettingsForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtUserProfileSetting;
    private String txtUserContactSetting;
    private Boolean boolUserNotificationMembershipRequest;
    private Boolean boolUserNotificationPlaydate;
    private Boolean boolUserNotificationPlaydateMessageBoard;
    private Boolean boolUserNotificationGeneralMessages;
    private Boolean boolUserLocationCurrentLocationSetting;

    public void setTxtUserContactSetting(String txtUserContactSetting) {
        this.txtUserContactSetting = txtUserContactSetting;
    }

    public String getTxtUserContactSetting() {
        return txtUserContactSetting;
    }

    public void setBoolUserNotificationMembershipRequest(Boolean boolUserNotificationMembershipRequest) {
        this.boolUserNotificationMembershipRequest = boolUserNotificationMembershipRequest;
    }

    public Boolean getBoolUserNotificationMembershipRequest() {
        return boolUserNotificationMembershipRequest;
    }

    public void setBoolUserNotificationPlaydate(Boolean boolUserNotificationPlaydate) {
        this.boolUserNotificationPlaydate = boolUserNotificationPlaydate;
    }

    public Boolean getBoolUserNotificationPlaydate() {
        return boolUserNotificationPlaydate;
    }

    public void setBoolUserNotificationPlaydateMessageBoard(Boolean boolUserNotificationPlaydateMessageBoard) {
        this.boolUserNotificationPlaydateMessageBoard = boolUserNotificationPlaydateMessageBoard;
    }

    public Boolean getBoolUserNotificationPlaydateMessageBoard() {
        return boolUserNotificationPlaydateMessageBoard;
    }

    public void setBoolUserNotificationGeneralMessages(Boolean boolUserNotificationGeneralMessages) {
        this.boolUserNotificationGeneralMessages = boolUserNotificationGeneralMessages;
    }

    public Boolean getBoolUserNotificationGeneralMessages() {
        return boolUserNotificationGeneralMessages;
    }

    public void setBoolUserLocationCurrentLocationSetting(Boolean boolUserLocationCurrentLocationSetting) {
        this.boolUserLocationCurrentLocationSetting = boolUserLocationCurrentLocationSetting;
    }

    public Boolean getBoolUserLocationCurrentLocationSetting() {
        return boolUserLocationCurrentLocationSetting;
    }

    public void setTxtUserProfileSetting(String txtUserProfileSetting) {
        this.txtUserProfileSetting = txtUserProfileSetting;
    }

    public String getTxtUserProfileSetting() {
        return txtUserProfileSetting;
    }
}
