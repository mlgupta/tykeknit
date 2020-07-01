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
  * $Id:
  *****************************************************************************
  */
package com.tykeknit.utils;

import java.sql.ResultSet;

import java.util.LinkedList;

import java.util.ListIterator;

import javapns.back.FeedbackServiceManager;

import javapns.back.SSLConnectionHelper;

import javapns.data.Device;

import javapns.exceptions.DuplicateDeviceException;
import javapns.exceptions.NullDeviceTokenException;
import javapns.exceptions.NullIdException;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import org.json.JSONException;

import org.postgresql.ds.PGSimpleDataSource;


public class feedbackAPN {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    public feedbackAPN() {
    }

    public static void main(String[] args) {
        new feedbackAPN();
        
        if (args.length != 1) {
            System.err.println("--------------------------------------------------------------------------------------------------------------------");
            System.err.println("Usage: java feedbackAPN <log4j-init-file>");
            System.err.println("--------------------------------------------------------------------------------------------------------------------");
            System.exit(1);
        }
        
        String log4jInitFile   = args[0];
        
        String prefix = System.getProperty("user.dir");
        
        PropertyConfigurator.configure(prefix + "/" + log4jInitFile);
        logger.debug("Log4J Initialized");
        
        String HOST = "feedback.push.apple.com";
        int PORT = 2196;
        String certificate = prefix + "/TykeKnitAPN.p12";
        String password = "tk0101";

        ResultSet rs = null;
        int rc = 0;
        int deviceDisabledCount = 0;
        
        try {
            PGSimpleDataSource ds = new PGSimpleDataSource();

            ds.setDatabaseName("tykeknit");
            ds.setUser("tykeknit");
            ds.setPassword("tk0101");
            ds.setServerName("localhost");
            
            DBConnection dbcon = new DBConnection(ds);

            FeedbackServiceManager feedbackManager = FeedbackServiceManager.getInstance();
            
            LinkedList<Device> devices = feedbackManager.getDevices( HOST, PORT, certificate, password, SSLConnectionHelper.KEYSTORE_TYPE_PKCS12 );

            ListIterator<Device> itr = devices.listIterator();
            
            while ( itr.hasNext() ) {
                Device device = itr.next();
                logger.debug( "Device: id=[" + device.getId() + " token=[" + device.getToken() + "]" );

                rc = Operations.disableDeviceToken(device.getToken(), dbcon);
                ++deviceDisabledCount;
            }
            
            dbcon.free(rs);
            
            logger.info("-----------------------------------------------------------------------------");
            logger.info("                   APN Feedback Execution Summary");
            logger.info("");
            logger.info("Devices Disabled:               " + deviceDisabledCount);
            logger.info("-----------------------------------------------------------------------------");

        } catch (ClassNotFoundException e) {
             e.printStackTrace();
             logger.error("--- ClassNotFoundException Caught ---");
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (DuplicateDeviceException e) {
            e.printStackTrace();
        } catch (NullIdException e) {
            e.printStackTrace();
        } catch (NullDeviceTokenException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            logger.debug("End");
        }
    }
}
