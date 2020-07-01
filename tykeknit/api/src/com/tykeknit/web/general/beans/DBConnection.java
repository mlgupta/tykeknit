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
  * $Id: DBConnection.java,v 1.1 2011/02/22 14:49:10 manish Exp $
  *****************************************************************************
  */
package com.tykeknit.web.general.beans;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.apache.log4j.Logger;


/**
 *              Purpose: Utility to perform database specific operations
 *
 *             @author   Manish Gupta
 *            @version   1.0
 *    Date of creation : 24-11-2006
 *    Last Modified by : 
 *  Last Modified Date :
 */
public class

DBConnection {
    private DataSource dataSource = null;
    private Connection connection = null;
    private Statement statement = null;
    private Logger logger = null;

    public DBConnection(DataSource dataSource) throws SQLException, Exception {
        logger = Logger.getLogger(TKConstants.LOGGER.toString());
        logger.debug("Enter DBConnection Contructor");
        try {
            this.dataSource = dataSource;
            this.connection = this.dataSource.getConnection();
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit DBConnection Contructor");
        }
    }

    public ResultSet executeQuery(String sqlString) throws SQLException, 
                                                           Exception {
        ResultSet resultSet = null;
        try {
            logger.debug("Enter executeQuery");
            this.statement = this.connection.createStatement();
            resultSet = this.statement.executeQuery(sqlString);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit executeQuery");
        }
        return resultSet;
    }

    public ResultSet executeQuery(String sqlString, int resultSetType, 
                                  int resultSetConcurrency) throws SQLException, 
                                                                   Exception {
        ResultSet resultSet = null;
        try {
            logger.debug("Enter executeQuery");
            this.statement = 
                    this.connection.createStatement(resultSetType, resultSetConcurrency);
            resultSet = this.statement.executeQuery(sqlString);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit executeQuery");
        }
        return resultSet;
    }

    public ResultSet executeQuery(String sqlString, int resultSetType, 
                                  int resultSetConcurrency, 
                                  int resultSetHoldability) throws SQLException, 
                                                                   Exception {
        ResultSet resultSet = null;
        try {
            logger.debug("Enter executeQuery");
            this.statement = 
                    this.connection.createStatement(resultSetType, resultSetConcurrency, 
                                                    resultSetHoldability);
            resultSet = this.statement.executeQuery(sqlString);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit executeQuery");
        }
        return resultSet;
    }


    public CallableStatement prepareCall(String sqlString) throws SQLException, 
                                                                  Exception {
        CallableStatement callableStatement = null;
        try {
            logger.debug("Enter prepareCall ");
            callableStatement = this.connection.prepareCall(sqlString);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit prepareCall");
        }
        return callableStatement;
    }

    public CallableStatement prepareCall(String sqlString, int resultSetType, 
                                         int resultSetConcurrency) throws SQLException, 
                                                                          Exception {
        CallableStatement callableStatement = null;
        try {
            logger.debug("Enter prepareCall ");
            callableStatement = 
                    this.connection.prepareCall(sqlString, resultSetType, 
                                                resultSetConcurrency);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit prepareCall");
        }
        return callableStatement;
    }

    public CallableStatement prepareCall(String sqlString, int resultSetType, 
                                         int resultSetConcurrency, 
                                         int resultSetHoldability) throws SQLException, 
                                                                          Exception {
        CallableStatement callableStatement = null;
        try {
            logger.debug("Enter prepareCall ");
            callableStatement = 
                    this.connection.prepareCall(sqlString, resultSetType, 
                                                resultSetConcurrency, 
                                                resultSetHoldability);
        } catch (SQLException se) {
            throw se;
        } catch (Exception e) {
            throw e;
        } finally {
            logger.debug("Exit prepareCall");
        }
        return callableStatement;
    }

    public boolean executeCallableStatement(CallableStatement callableStatement) throws SQLException {
        try {
            logger.debug("Enter executeCallableStatement");
            return callableStatement.execute();
        } catch (SQLException sqle) {
            logger.error(sqle);
            throw sqle;
        } finally {
            logger.debug("Exit executeCallableStatement");
        }
    }

    public void freeCallableSatement(CallableStatement callableStatement) {
        // Closing Callable Statement 
        if (callableStatement != null) {
            try {
                callableStatement.close();
            } catch (SQLException sqle) {
                logger.error(sqle.getMessage());
            } finally {
                callableStatement = null;
            }
        }
    }

    public void free(CallableStatement callableStatement) {
        // Closing Callable Statement 
        freeCallableSatement(callableStatement);

        // Closing Statement and Connection
        free();
    }

    public void freeResultSet(ResultSet resultSet) {
        //Closing ResultSet 
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException sqle) {
                logger.error(sqle.getMessage());
            } finally {
                resultSet = null;
            }
        }

    }

    public void free(ResultSet resultSet) {
        //Closing ResultSet 
        freeResultSet(resultSet);

        // Closing Statement and Connection
        free();
    }

    public void free() {
        // Closing Statement
        if (this.statement != null) {
            try {
                this.statement.close();
            } catch (SQLException sqle) {
                logger.error(sqle.getMessage());
            } finally {
                this.statement = null;
            }
        }

        //Closing Connection
        if (this.connection != null) {
            try {
                this.connection.close();
            } catch (SQLException sqle) {
                logger.error(sqle.getMessage());
            } finally {
                this.connection = null;
            }
        }
    }
}
