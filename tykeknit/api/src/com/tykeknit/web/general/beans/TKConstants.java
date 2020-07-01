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
  * $Id: TKConstants.java,v 1.1 2011/02/22 14:49:11 manish Exp $
  *****************************************************************************
  */
  
  package com.tykeknit.web.general.beans;

/**
 *	          Purpose: To generate the name for the constants used in program.
 *                   Info: This class has one constructor which takes one string argument and initializes the
 *                          constant_name with that value.
 *                @author  Manish Gupta
 *              @version   1.0
 * 	 Date of creation: 09/14/2010
 * 	 Last Modfied by :     
 * 	Last Modfied Date:    
 */
public final class

TKConstants {

    //Tag Name 
    private final String constant_name;

    //Private Contructor to use in this class only

    private TKConstants(String constant_name) {
        this.constant_name = constant_name;
    }

    /**
     * Purpose  : To Get the Contant , the toString() method of Object Class is overloaded 
     * @return  : Returns an Contant Name
     */
    public String toString() {
        return this.constant_name;
    }

    public static final TKConstants LOGGER = new TKConstants("com.tykeknit");

}
