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
  * $Id: getMapForm.java,v 1.1 2011/02/22 14:49:07 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

getMapForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtLat;
    private String txtLong;
    private String txtRadius;
    private String txtDegreeCode;
    private String txtGenderCode;
    private String txtAgeCode;
    private String txtSearchString;
    private String txtCount;
    private String txtStart;

    public void setTxtLat(String txtLat) {
        this.txtLat = txtLat;
    }

    public String getTxtLat() {
        return txtLat;
    }

    public void setTxtLong(String txtLong) {
        this.txtLong = txtLong;
    }

    public String getTxtLong() {
        return txtLong;
    }

    public void setTxtRadius(String txtRadius) {
        this.txtRadius = txtRadius;
    }

    public String getTxtRadius() {
        return txtRadius;
    }

    public void setTxtDegreeCode(String txtDegreeCode) {
        this.txtDegreeCode = txtDegreeCode;
    }

    public String getTxtDegreeCode() {
        return txtDegreeCode;
    }

    public void setTxtGenderCode(String txtGenderCode) {
        this.txtGenderCode = txtGenderCode;
    }

    public String getTxtGenderCode() {
        return txtGenderCode;
    }

    public void setTxtAgeCode(String txtAgeCode) {
        this.txtAgeCode = txtAgeCode;
    }

    public String getTxtAgeCode() {
        return txtAgeCode;
    }

    public void setTxtSearchString(String txtSearchString) {
        this.txtSearchString = txtSearchString;
    }

    public String getTxtSearchString() {
        return txtSearchString;
    }

    public void setTxtCount(String txtCount) {
        this.txtCount = txtCount;
    }

    public String getTxtCount() {
        return txtCount;
    }

    public void setTxtStart(String txtStart) {
        this.txtStart = txtStart;
    }

    public String getTxtStart() {
        return txtStart;
    }
}
