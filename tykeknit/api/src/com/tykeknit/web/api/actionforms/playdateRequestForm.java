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
  * $Id: playdateRequestForm.java,v 1.3 2011/04/23 14:29:44 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

playdateRequestForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtOrganiserCid;
    private String txtPlaydateName;
    private String txtLocation;
    private String txtDate;
    private String txtEndDate;
    private String txtStartTime;
    private String txtEndTime;
    private String txtMessage;
    private String txtInvitees;

    public void setTxtOrganiserCid(String txtOrganiserCid) {
        this.txtOrganiserCid = txtOrganiserCid;
    }

    public String getTxtOrganiserCid() {
        return txtOrganiserCid;
    }

    public void setTxtPlaydateName(String txtPlaydateName) {
        this.txtPlaydateName = txtPlaydateName;
    }

    public String getTxtPlaydateName() {
        return txtPlaydateName;
    }

    public void setTxtLocation(String txtLocation) {
        this.txtLocation = txtLocation;
    }

    public String getTxtLocation() {
        return txtLocation;
    }

    public void setTxtDate(String txtDate) {
        this.txtDate = txtDate;
    }

    public String getTxtDate() {
        return txtDate;
    }

    public void setTxtStartTime(String txtStartTime) {
        this.txtStartTime = txtStartTime;
    }

    public String getTxtStartTime() {
        return txtStartTime;
    }

    public void setTxtEndTime(String txtEndTime) {
        this.txtEndTime = txtEndTime;
    }

    public String getTxtEndTime() {
        return txtEndTime;
    }

    public void setTxtMessage(String txtMessage) {
        this.txtMessage = txtMessage;
    }

    public String getTxtMessage() {
        return txtMessage;
    }

    public void setTxtInvitees(String txtInvitees) {
        this.txtInvitees = txtInvitees;
    }

    public String getTxtInvitees() {
        return txtInvitees;
    }

    public void setTxtEndDate(String txtEndDate) {
        this.txtEndDate = txtEndDate;
    }

    public String getTxtEndDate() {
        return txtEndDate;
    }
}
