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
  * $Id: addEventForm.java,v 1.2 2011/07/01 12:57:07 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

addEventForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtEventTitle;
    private String txtEventDetail;
    private String txtEventTblPk;

    public void setTxtEventTitle(String txtEventTitle) {
        this.txtEventTitle = txtEventTitle;
    }

    public String getTxtEventTitle() {
        return txtEventTitle;
    }

    public void setTxtEventDetail(String txtEventDetail) {
        this.txtEventDetail = txtEventDetail;
    }

    public String getTxtEventDetail() {
        return txtEventDetail;
    }

    public void setTxtEventTblPk(String txtEventTblPk) {
        this.txtEventTblPk = txtEventTblPk;
    }

    public String getTxtEventTblPk() {
        return txtEventTblPk;
    }
}
