package com.tykeknit.web.api.beans;

import com.tykeknit.web.general.beans.TKConstants;

import java.io.IOException;
import java.io.InputStream;

import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.apache.tomcat.dbcp.dbcp.DelegatingConnection;

import org.postgresql.largeobject.LargeObject;
import org.postgresql.largeobject.LargeObjectManager;


final class LOOperations  {
    static Logger logger = Logger.getLogger(TKConstants.LOGGER.toString());
  
  public static byte[] getLargeObjectContent(long oId, 
                                DataSource dataSource) throws SQLException, IOException, Exception   {

    logger.debug("Enter getLargeObjectContent");

    Connection conn=null;
    Connection pgConn = null;

    InputStream is = null;
    LargeObjectManager lObjManager = null;
    LargeObject lObj = null;
    byte[] content = null;
    int contentSize ;
    boolean oldAutoCommit = true;

    try {
        conn=dataSource.getConnection();
 
        pgConn = ((DelegatingConnection)conn).getInnermostDelegate();

        if (pgConn == null) {
            logger.debug("pgConn is null");
        } 
        else {
            oldAutoCommit = pgConn.getAutoCommit();
            pgConn.setAutoCommit(false);

            logger.debug("Auto Commit: " + pgConn.getAutoCommit());

            lObjManager = ((org.postgresql.PGConnection)pgConn).getLargeObjectAPI();      

            if (lObjManager == null) {
                logger.debug("lObjManager is null");
            }
            else {
                logger.debug("lObjManager seems good");
                lObj = lObjManager.open(oId,LargeObjectManager.READ);
                logger.debug("After lObjManager.open");
                is = lObj.getInputStream();
                contentSize = lObj.size();
                logger.debug("contentSize: " + String.valueOf(contentSize));
                content = new byte[contentSize]; 
                is.read(content); 
                logger.debug("After is.read");
            }
        }
    } catch(SQLException sqle){
      logger.error(sqle.toString());
    } catch(IOException ioe){
      logger.error(ioe.toString());
    } catch(Exception e){
        logger.error(e.toString());
    } finally {
      logger.debug("In the finally block");
      
      if (is != null){
        logger.debug("Closing is");
        is.close(); 
        logger.debug("Closed is");
      }
      if (lObj != null){
        logger.debug("Closing lObj");
        lObj.close();
        logger.debug("Closed lObj");
      }
      if (pgConn != null) {
          logger.debug("Before Commit");
          pgConn.commit();
          logger.debug("About to reset AutoCommit");
          pgConn.setAutoCommit(oldAutoCommit);
          logger.debug("Reset Autocommit");
      }
      if (conn != null){
        logger.debug("Closing conn");
        conn.close();   
        logger.debug("Closed conn");
      }
    }
    logger.debug("Exit getLargeObjectContent");
    return content;
  }

  public static int putLargeObjectContent(long oId,
                                byte[] content,
                                DataSource dataSource)throws SQLException, Exception {

    logger.debug("Enter putLargeObjectContent");

    Connection conn=null;
    Connection pgConn = null;
    LargeObjectManager lObjManager = null;
    LargeObject lObj = null;
    boolean oldAutoCommit = true;
    int rc = 0;

    try {
        conn=dataSource.getConnection();
        
        pgConn = ((DelegatingConnection)conn).getInnermostDelegate();

        if (pgConn == null) {
            logger.debug("pgConn is null");
            rc = -1;
        } 
        else {    
            oldAutoCommit = pgConn.getAutoCommit();
            pgConn.setAutoCommit(false);

            logger.debug("Auto Commit: " + pgConn.getAutoCommit());

            lObjManager = ((org.postgresql.PGConnection)pgConn).getLargeObjectAPI();      
            
            if (lObjManager == null) {
                rc = -1;
                logger.debug("lObjManager is null");
            }
            else {
                logger.debug("Before Open");
                lObj = lObjManager.open(oId, LargeObjectManager.WRITE);
                logger.debug("After Open");
                lObj.write(content);
                logger.debug("After write");
            }
        }

    } catch(SQLException sqle){
      logger.error(sqle.toString());
      rc = -1;
    } catch(Exception e){
        logger.error(e.toString());
        rc = -1;
    } finally{
      if (lObj != null){
        lObj.close();
      }
      logger.debug("Before Commit");
      pgConn.commit();
      logger.debug("Setting AutoCommit to its original");
      pgConn.setAutoCommit(oldAutoCommit);
      if (conn!=null){
        conn.close();   
      }
    }
    logger.debug("Exit putLargeObjectContent");
    return (rc);
  }

  public static long getLargeObjectId(DataSource dataSource)
                            throws SQLException, Exception {

    logger.debug("Enter getLargeObjectId");

    LargeObjectManager lObjManager = null;
    Connection conn = null;
    Connection pgConn = null;
    long oId = -1;

    try {
        conn=dataSource.getConnection();
        
        pgConn = ((DelegatingConnection)conn).getInnermostDelegate();
        
        if (pgConn != null) {
            boolean oldAutoCommit = pgConn.getAutoCommit();
            pgConn.setAutoCommit(false);

            logger.debug("Auto Commit: " + pgConn.getAutoCommit());

            lObjManager = ((org.postgresql.PGConnection)pgConn).getLargeObjectAPI();
            
            if (lObjManager != null) {
                oId = lObjManager.createLO(LargeObjectManager.READ | LargeObjectManager.WRITE);
            }
            pgConn.commit();
            pgConn.setAutoCommit(oldAutoCommit);
        }
    } catch(SQLException sqle ){
        logger.error(sqle.toString());
        oId = -1;
    } catch(Exception e ){
        logger.error(e.toString());
        oId = -1;
    } finally {
        if(conn != null){
          conn.close();
        }
    }     
    logger.debug("Exit getLargeObjectId");
    return oId;
  }
}
