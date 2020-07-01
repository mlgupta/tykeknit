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
  * $Id: getDBMessageDetailsForm.java,v 1.2 2011/03/14 13:24:25 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

getDBMessageDetailsForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtMsgId;
    private String txtMsgType;

    public void setTxtMsgId(String txtMsgId) {
        this.txtMsgId = txtMsgId;
    }

    public String getTxtMsgId() {
        return txtMsgId;
    }

    public void setTxtMsgType(String txtMsgType) {
        this.txtMsgType = txtMsgType;
    }

    public String getTxtMsgType() {
        return txtMsgType;
    }
}
