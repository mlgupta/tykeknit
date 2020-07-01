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

import javapns.back.PushNotificationManager;

import javapns.back.SSLConnectionHelper;

import javapns.data.Device;
import javapns.data.PayLoad;

import javapns.exceptions.DuplicateDeviceException;
import javapns.exceptions.NullDeviceTokenException;
import javapns.exceptions.NullIdException;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import org.json.JSONException;

import org.postgresql.ds.PGSimpleDataSource;


public class wannaHangAPN {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());

    public wannaHangAPN() {
    }

    public static void main(String[] args) {
        new wannaHangAPN();
        
        if (args.length != 1) {
            System.err.println("--------------------------------------------------------------------------------------------------------------------");
            System.err.println("Usage: java wannaHangAPN <log4j-init-file>");
            System.err.println("--------------------------------------------------------------------------------------------------------------------");
            System.exit(1);
        }
        
        String log4jInitFile   = args[0];
        
        String prefix = System.getProperty("user.dir");
        
        PropertyConfigurator.configure(prefix + "/" + log4jInitFile);
        logger.debug("Log4J Initialized");
        
        String HOST = "gateway.push.apple.com";
        int PORT = 2195;
        String certificate = prefix + "/TykeKnitAPN.p12";
        String password = "tk0101";

        ResultSet rs = null;
        String sqlString = null;
        int rc = 0;
        
        try {
            logger.debug("Certificate: " + certificate);
            PGSimpleDataSource ds = new PGSimpleDataSource();
            
            ds.setDatabaseName("tykeknit");
            ds.setUser("tykeknit");
            ds.setPassword("tk0101");
            ds.setServerName("localhost");
            
            DBConnection dbcon = new DBConnection(ds);
            
            sqlString  = "select distinct a.user_tbl_fk "
                       +       ",c.user_tbl_fk "
                       +       ",c.device_token "
                       +       ",d.user_fname ";
            sqlString += "from wanna_hang_pn_tbl          a "
                       +     ",knit_tbl                   b "
                       +     ",device_token_tbl           c "
                       +     ",user_tbl                   d ";
            sqlString += "where a.push_notification_sent = 'N' "
                       +   "and a.user_tbl_fk = b.knit_from_user_tbl_fk "
                       +   "and b.knit_to_user_tbl_fk = c.user_tbl_fk "
                       +   "and c.device_status = 'A' "
                       +   "and a.user_tbl_fk = d.user_tbl_pk ";
            sqlString += "order by  a.user_tbl_fk ";

            logger.debug(sqlString);

            rs = dbcon.executeQuery(sqlString);
            
            boolean first_time_flag = true;
            String prev_user_tbl_fk = "";
            PayLoad aPayLoad = new PayLoad();
            String payLoadMessage = "";
            String tykeNames = "";
            PushNotificationManager pushManager = PushNotificationManager.getInstance();
            pushManager.initializeConnection(HOST, PORT, certificate, password, SSLConnectionHelper.KEYSTORE_TYPE_PKCS12);
            Device client;
            String pn_sent_list = "";
            int pnSentCount = 0;
            
            while (rs.next()) {
                if (first_time_flag == true) {
                    payLoadMessage = rs.getString(4);
                    tykeNames = Operations.getTykeNames(Integer.parseInt(rs.getString(1)), dbcon);
                    payLoadMessage += ", " + tykeNames + " Wanna Hang now.";
                    
                    prev_user_tbl_fk = rs.getString(1);
                    aPayLoad = new PayLoad();
                    aPayLoad.addAlert(payLoadMessage);
                    aPayLoad.addSound("default");

                    first_time_flag = false;
                    logger.debug(aPayLoad);
                }
                else if (prev_user_tbl_fk.equals(rs.getString(1))) {
                }
                else {
                    payLoadMessage = rs.getString(4);
                    aPayLoad = new PayLoad();
                    tykeNames = Operations.getTykeNames(Integer.parseInt(rs.getString(1)), dbcon);
                    payLoadMessage += ", " + tykeNames + " Wanna Hang now.";
                    aPayLoad.addAlert(payLoadMessage);
                    aPayLoad.addSound("default");

                    logger.debug(aPayLoad);

                    prev_user_tbl_fk = rs.getString(1);
                }
                pn_sent_list += rs.getString(1) + ",";
                
                logger.debug ("user_tbl_fk: " + rs.getString(2) + " Device Token: " + rs.getString(3));
                pushManager.addDevice(rs.getString(2),rs.getString(3));
                client = pushManager.getDevice(rs.getString(2));
                pushManager.sendNotification(client, aPayLoad);
                ++pnSentCount;
            }

            pushManager.stopConnection();
            
            rs = null;
            
            if ("".equals(pn_sent_list)) {
            }
            else {
                pn_sent_list = pn_sent_list.substring(0,pn_sent_list.length()-1);
                logger.debug(pn_sent_list);
                
                rc = Operations.updatePNSentStatus(pn_sent_list, dbcon);
            }
            
            dbcon.free(rs);
            
            logger.info("-----------------------------------------------------------------------------");
            logger.info("             Wanna Hang Push Notification Execution Summary");
            logger.info("");
            logger.info("Push Notifications Sent:               " + pnSentCount);
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
