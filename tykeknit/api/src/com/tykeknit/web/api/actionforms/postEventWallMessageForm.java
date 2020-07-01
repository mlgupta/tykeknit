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
  * $Id: postEventWallMessageForm.java,v 1.1 2011/07/01 12:57:08 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.actionforms;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;
import org.apache.struts.validator.ValidatorForm;


public class

postEventWallMessageForm extends ValidatorForm {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    private String txtEventTblPk;
    private String txtEventWallMessage;

    public void setTxtEventTblPk(String txtEventTblPk) {
        this.txtEventTblPk = txtEventTblPk;
    }

    public String getTxtEventTblPk() {
        return txtEventTblPk;
    }

    public void setTxtEventWallMessage(String txtEventWallMessage) {
        this.txtEventWallMessage = txtEventWallMessage;
    }

    public String getTxtEventWallMessage() {
        return txtEventWallMessage;
    }
}
