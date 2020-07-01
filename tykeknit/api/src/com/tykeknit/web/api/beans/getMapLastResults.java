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
  * $Id: getMapLastResults.java,v 1.2 2011/06/19 16:27:41 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.api.beans;

import com.tykeknit.web.general.beans.TKConstants;

import org.apache.log4j.Logger;

import org.json.JSONObject;


public class 
getMapLastResults
{
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

    private JSONObject jsonParents;
    
    private String whereTykeOnMapUserTblPk;

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

    public void setJsonParents(JSONObject jsonParents) {
        this.jsonParents = jsonParents;
    }

    public JSONObject getJsonParents() {
        return jsonParents;
    }

    public void setWhereTykeOnMapUserTblPk(String whereTykeOnMapUserTblPk) {
        this.whereTykeOnMapUserTblPk = whereTykeOnMapUserTblPk;
    }

    public String getWhereTykeOnMapUserTblPk() {
        return whereTykeOnMapUserTblPk;
    }
}
