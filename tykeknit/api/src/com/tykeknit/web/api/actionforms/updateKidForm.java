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
  * $Id: updateKidForm.java,v 1.1 2011/03/31 16:26:41 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.upload.FormFile;
import org.apache.struts.validator.ValidatorForm;


public class
updateKidForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtChildTblPk;
    private String txtFirstName;
    private String txtLastName;
    private String txtDOB;
    private String txtGender;
    private FormFile imgFile;

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

    public void setTxtDOB(String txtDOB) {
        this.txtDOB = txtDOB;
    }

    public String getTxtDOB() {
        return txtDOB;
    }

    public void setTxtGender(String txtGender) {
        this.txtGender = txtGender;
    }

    public String getTxtGender() {
        return txtGender;
    }

    public void setImgFile(FormFile imgFile) {
        this.imgFile = imgFile;
    }

    public FormFile getImgFile() {
        return imgFile;
    }

    public void setTxtChildTblPk(String txtChildTblPk) {
        this.txtChildTblPk = txtChildTblPk;
    }

    public String getTxtChildTblPk() {
        return txtChildTblPk;
    }
}
