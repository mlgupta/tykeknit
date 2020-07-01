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
  * $Id: TykeOnMap.java,v 1.4 2011/04/26 15:58:30 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.beans;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;


public class 
TykeOnMap
{
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
	
    private String whereTykeOnMapUserTblPk;

    public void setWhereTykeOnMapUserTblPk(String whereTykeOnMapUserTblPk) {
        this.whereTykeOnMapUserTblPk = whereTykeOnMapUserTblPk;
    }

    public String getWhereTykeOnMapUserTblPk() {
        return whereTykeOnMapUserTblPk;
    }
}
