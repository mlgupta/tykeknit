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
  * $Id: setFBIdTokenForm.java,v 1.1 2011/02/22 14:49:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

setFBIdTokenForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtFBId;
    private String txtFBAuthToken;

    public void setTxtFBId(String txtFBId) {
        this.txtFBId = txtFBId;
    }

    public String getTxtFBId() {
        return txtFBId;
    }

    public void setTxtFBAuthToken(String txtFBAuthToken) {
        this.txtFBAuthToken = txtFBAuthToken;
    }

    public String getTxtFBAuthToken() {
        return txtFBAuthToken;
    }
}
