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
  * $Id: registerForm.java,v 1.1 2011/02/22 14:49:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.upload.FormFile;
import org.apache.struts.validator.ValidatorForm;


public class

registerForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtFirstName;
    private String txtLastName;
    private String txtEmail;
    private String txtPassword;
    private String txtDOB;
    private String txtOPREmail;
    private String txtParentType;
    private FormFile imgFile;
    private String txtZip;

    public void setTxtFirstName(String txtFirstName) {
        this.txtFirstName = txtFirstName;
    }

    public String getTxtFirstName() {
        return txtFirstName;
    }

    public void setTxtLastName(String txtLastName) {
        this.txtLastName = txtLastName;
    }

    public String getTxtLastName() {
        return txtLastName;
    }

    public void setTxtEmail(String txtEmail) {
        this.txtEmail = txtEmail;
    }

    public String getTxtEmail() {
        return txtEmail;
    }

    public void setTxtPassword(String txtPassword) {
        this.txtPassword = txtPassword;
    }

    public String getTxtPassword() {
        return txtPassword;
    }

    public void setTxtDOB(String txtDOB) {
        this.txtDOB = txtDOB;
    }

    public String getTxtDOB() {
        return txtDOB;
    }

    public void setTxtOPREmail(String txtOPREmail) {
        this.txtOPREmail = txtOPREmail;
    }

    public String getTxtOPREmail() {
        return txtOPREmail;
    }

    public void setTxtParentType(String txtParentType) {
        this.txtParentType = txtParentType;
    }

    public String getTxtParentType() {
        return txtParentType;
    }

    public void setTxtZip(String txtZip) {
        this.txtZip = txtZip;
    }

    public String getTxtZip() {
        return txtZip;
    }

    public void setImgFile(FormFile imgFile) {
        this.imgFile = imgFile;
    }

    public FormFile getImgFile() {
        return imgFile;
    }
}
