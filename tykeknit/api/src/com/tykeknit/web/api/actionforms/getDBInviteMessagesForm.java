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
  * $Id: getDBInviteMessagesForm.java,v 1.1 2011/03/11 11:27:59 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

getDBInviteMessagesForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtResultLimit;
    private String txtResultOffset;

    public void setTxtResultLimit(String txtResultLimit) {
        this.txtResultLimit = txtResultLimit;
    }

    public String getTxtResultLimit() {
        return txtResultLimit;
    }

    public void setTxtResultOffset(String txtResultOffset) {
        this.txtResultOffset = txtResultOffset;
    }

    public String getTxtResultOffset() {
        return txtResultOffset;
    }
}
