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
  * $Id: updateMessageReadStatusForm.java,v 1.1 2011/04/05 06:20:36 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

updateMessageReadStatusForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtMessageId;
    private String txtReadStatus;

    public void setTxtMessageId(String txtMessageId) {
        this.txtMessageId = txtMessageId;
    }

    public String getTxtMessageId() {
        return txtMessageId;
    }

    public void setTxtReadStatus(String txtReadStatus) {
        this.txtReadStatus = txtReadStatus;
    }

    public String getTxtReadStatus() {
        return txtReadStatus;
    }
}
