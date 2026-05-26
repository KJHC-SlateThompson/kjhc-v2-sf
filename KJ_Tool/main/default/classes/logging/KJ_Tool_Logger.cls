/* 
*   File: KJ_Tool_Logger.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/1/2026
*   Description: This class is built to allow for easy logging to terminal from other classes
*/
public with sharing class KJ_Tool_Logger {
    //*-- Member Methods --------------------------------------------------------------------------
    // Level based logging methods
    public static void debug(String message, KJ_Tool_Origin origin){
        KJ_Tool_LogEntry logEntry = KJ_Tool_LogEntry.debug(message, origin)
        log(logEntry);
    }
    public static void debug(String message){
        debug(message, null);
    }


    public static void info(String message, KJ_Tool_Origin origin){
        KJ_Tool_LogEntry logEntry = KJ_Tool_LogEntry.info(message, origin);
        log(logEntry);
    }
    public static void info(String message){
        info(message, null);
    }


    public static void warn(String message, KJ_Tool_Origin origin){
        KJ_Tool_LogEntry logEntry = new KJ_Tool_LogEntry.WARN(message, origin);
        log(logEntry);
    }
    public static void warn(String message){
        warn(message, null);
    }
    public static void warn(KJ_Tool_Exception e){
        warn(KJ_Tool_Formatter.toString(e), e.origin);
    }

    
    public static void error(String message, KJ_Tool_Origin origin){
        KJ_Tool_LogEntry logEntry = new KJ_Tool_LogEntry.ERROR(message, origin);
        log(logEntry);
    }
    public static void error(String message){
        error(message, null);
    }
    public static void error(KJ_Tool_Exception e){
        error(KJ_Tool_Formatter.toString(e), e.origin);
    }


    // Universal logging method
    public static void log(KJ_Tool_LogEntry logEntry){
        String logEntryOutputString = KJ_Tool_Formatter.toString(logEntry);
        LoggingLevel logEntryLevel = KJ_Tool_LogEntry.mapToLoggingLevel(logEntry.level);

        System.debug(logEntryLevel, logEntryOutputString);
    }
}