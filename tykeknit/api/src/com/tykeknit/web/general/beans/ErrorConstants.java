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
  * $Id: ErrorConstants.java,v 1.1 2011/02/22 14:49:11 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.general.beans;

/**
 *	           Purpose: To generate error codes and error values to handle the exceptions that occurs in program. 
 *                 @author  Manish Gupta
 *                @version  1.0
 * 	  Date of creation: 24-11-2006
 * 	  Last Modfied by :     
 * 	 Last Modfied Date:    
 */
public class

ErrorConstants {
    private String code;
    private String value;

    /**
     * Purpose : Contructs an ErrorConstants object and initializes the member variables.
     * @param code - A String object representing the code associated with any error.
     * @param value - A String object representing the value of any error that is generated in 
     *                the program.
     */
    private ErrorConstants(String code, String value) {
        this.code = code;
        this.value = value;
    }

    /**
     * Purpose : Returns the error code.
     * @return String.
     */
    public String getErrorCode() {
        return this.code;
    }

    /**
     * Purpose : Returns the error value.
     * @return String.
     */
    public String getErrorValue() {
        return this.value;
    }

    /**
     * Purpose : Returns the error code and error value.
     * @return String.
     */
    public String toString() {
        return this.code + " " + this.value;
    }


    public static final ErrorConstants UNIQUE = 
        new ErrorConstants("23505", "unique");
    public static final ErrorConstants REFERED = 
        new ErrorConstants("23503", "referential");
    public static final ErrorConstants NOT_NULL_VIOLATION = 
        new ErrorConstants("23502", "notNullViolation");

}
