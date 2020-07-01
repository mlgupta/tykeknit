 /*
  *****************************************************************************
  *                       Confidentiality Information                         *
  *                                                                           *
  * This module is the confidential and proprietary information of            *
  * Tykeknit.; it is not to be copied, reproduced, or transmitted in any      *
  * form, by any means, in whole or in part, nor is it to be used for any     *
  * purpose other than that for which it is expressly provided without the    *
  * written permission of Tykeknit.                                           *
  *                                                                           *
  * Copyright (c) 2010-2011 Tykeknit.  All Rights Reserved.                   *
  *                                                                           *
  *****************************************************************************
  * $Id: DateUtil.java,v 1.1 2011/02/22 14:49:11 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.general.beans;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Date;


/**
 *              Purpose: Utility to get formatted date.
 *
 *             @author   Rajan Kamal Gupta
 *            @version   1.0
 *    Date of creation : 24-11-2006
 *    Last Modified by : 
 *  Last Modified Date :
 */
public class


DateUtil {

    public DateUtil() {
    }


    /**
     * Purpose   : Returns formatted date in dd-MMM-yyyy format.
     * @param    : date - Date
     * @return   : formattedDate
     */
    public static String getFormattedDate(Date date) {
        Date unformattedDate = date;
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
        String formattedDate = dateFormat.format(unformattedDate);
        return formattedDate;
    }


    /**
     * Purpose   : Returns formatted date in dd-MMM-yy format.
     * @param    : strDate - String
     * @return   : date in dd-MMM-yyyy
     */
    public static Date parseDate(String strDate) throws ParseException {
        Date date;
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yy");
        date = dateFormat.parse(strDate);
        return date;
    }


    public static String format(Date date, String pattern) {
        SimpleDateFormat formatter = new SimpleDateFormat(pattern);
        return formatter.format(date);
    }

    /**
     * Purpose   : To convert a given String in Date object.
     * @param    date - String representation of date object.
     * @param    pattern - Pattern for the date.
     * @return   Date - the converted date.
     */
    public static Date parse(String date, String pattern) {
        Date parsedDate = null;
        try {
            SimpleDateFormat parser = new SimpleDateFormat(pattern);
            parsedDate = parser.parse(date);
        } catch (ParseException pe) {
            pe.getMessage();
        }
        return parsedDate;
    }
}

