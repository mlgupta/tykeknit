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
  * $Id: PgSQLArray.java,v 1.1 2011/02/22 14:49:11 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.general.beans;

import java.sql.ResultSet;
import java.sql.Types;

import java.util.Map;


/**
 *              Purpose: Utility to implement array for database data types
 *
 *             @author   Sudheer Pujar
 *            @version   1.0
 *    Date of creation : 24-11-2006
 *    Last Modified by : 
 *  Last Modified Date :
 */
public class

PgSQLArray implements java.sql.Array {
    private String arrayString = "{}";
    private int baseType = 0;
    private String baseTypeName = getBaseTypeName(baseType);
    private static final String jdbc2TypeName[] = 
    { "arr", "int2", "int4", "int8", "numeric", "float4", "float8", "char", 
      "varchar", "bytea", "bool", "date", "time", "timestamp" };


    private static final int jdbc2Type[] = 
    { Types.ARRAY, Types.SMALLINT, Types.INTEGER, Types.BIGINT, Types.NUMERIC, 
      Types.REAL, Types.DOUBLE, Types.CHAR, Types.VARCHAR, Types.BINARY, 
      Types.BOOLEAN, Types.DATE, Types.TIME, Types.TIMESTAMP };


    public PgSQLArray(String arrayString, int type) {
        this.arrayString = arrayString;
        this.baseType = type;
        this.baseTypeName = getBaseTypeName(type);
    }

    private String getBaseTypeName(int type) {
        String typeName = "int2";
        for (int i = 0; i < jdbc2Type.length; i++) {
            if (jdbc2Type[i] == type) {
                typeName = jdbc2TypeName[i];
            }
        }
        return typeName;
    }

    public String getBaseTypeName() {
        return baseTypeName;
    }

    public int getBaseType() {
        return baseType;
    }

    public Object getArray() {
        return null;
    }

    public Object getArray(Map map) {
        return null;
    }

    public Object getArray(long index, int count) {
        return null;
    }

    public Object getArray(long index, int count, Map map) {
        return null;
    }

    public ResultSet getResultSet() {
        return null;
    }

    public ResultSet getResultSet(Map map) {
        return null;
    }

    public ResultSet getResultSet(long index, int count) {
        return null;
    }

    public ResultSet getResultSet(long index, int count, Map map) {
        return null;
    }

    public String toString() {
        return arrayString;
    }

}
