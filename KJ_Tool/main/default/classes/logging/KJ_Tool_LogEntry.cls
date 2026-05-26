/* 
*   File: KJ_Tool_LogEntry.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/1/2026
*   Description: This class is built to structure the data of log entries

*/
public with sharing class KJ_Tool_LogEntry {
    //*-- Constants -------------------------------------------------------------------------------
    public enum Level {
        DEBUG,
        INFO,
        WARN,
        ERROR
    }

    public static Level mapToLogEntryLevel(KJ_Tool_Exception.Level eLevel){
        switch on eLevel {
            when LOW    { return Level.WARN; }
            when HIGH   { return Level.ERROR; }
            when FATAL  { return Level.ERROR; }
            when else   { return Level.ERROR; }
        }
    }
    public static Level mapToLogEntryLevel(LoggingLevel logLevel){
        switch on logLevel {
            when ERROR  { return Level.ERROR; }
            when WARN   { return Level.WARN; }
            when INFO   { return Level.INFO; }
            when else   { return Level.DEBUG; }
        }
    }
    public static LoggingLevel mapToLoggingLevel(Level logEntryLevel){
        switch on logEntryLevel {
            when ERROR    { return LoggingLevel.ERROR; }
            when INFO     { return LoggingLevel.INFO; }
            when WARN     { return LoggingLevel.WARN; }
            when else     { return LoggingLevel.DEBUG; }
        }
    }

    //*-- Member Variables ------------------------------------------------------------------------
    public Level            level       { get; private set; }            
    public KJ_Tool_Origin   origin      { get; private set; }
    public Datetime         timestamp   { get; private set; }
    public String           message     { get; private set; }

    //*-- Member Functions ------------------------------------------------------------------------
    // Constructors
    public KJ_Tool_LogEntry() {
        this.level      = Level.DEBUG;
        this.origin     = new KJ_Tool_Origin();
        this.timestamp  = System.now();
        this.message    = '';
    }
    // Factory methods
    public static KJ_Tool_LogEntry build(Level initLevel, KJ_Tool_Origin initOrigin, Datetime initTimestamp, String initMessage){
        KJ_Tool_LogEntry newLogEntry = new KJ_Tool_LogEntry();

        newLogEntry.level       = initLevel     ?? newLogEntry.level;
        newLogEntry.origin      = initOrigin    ?? newLogEntry.origin;
        newLogEntry.timestamp   = initOrigin    ?? newLogEntry.timestamp; 
        newLogEntry.message     = initMessage   ?? newLogEntry.message;

        return newLogEntry;
    }
    

    public static KJ_Tool_LogEntry debug(String initMessage, KJ_Tool_Origin initOrigin){
        return build(Level.DEBUG, initOrigin, null, initMessage);
    }
    public static KJ_Tool_LogEntry debug(String initMessage){
        return build(Level.DEBUG, null, null, initMessage);
    }
    
    public static KJ_Tool_LogEntry info(String initMessage, KJ_Tool_Origin initOrigin){
        return build(Level.INFO, initOrigin, null, initMessage);
    }
    public static KJ_Tool_LogEntry info(String initMessage){
        return build(Level.INFO, null, null, initMessage);
    }

    public static KJ_Tool_LogEntry warn(String initMessage, KJ_Tool_Origin initOrigin){
        return build(Level.WARN, initOrigin, null, initMessage);
    }
    public static KJ_Tool_LogEntry warn(String initMessage){
        return build(Level.WARN, null, null, initMessage);
    }

    public static KJ_Tool_LogEntry error(String initMessage, KJ_Tool_Origin initOrigin){
        return build(Level.ERROR, initOrigin, null, initMessage);
    }
    public static KJ_Tool_LogEntry error(String initMessage){
        return build(Level.ERROR, null, null, initMessage);
    }

    
    // Mutators
    public void setMessage(String newMessage){
        this.message = newMessage ?? this.message;
    }
    public void setLevel(Level newLevel){
        this.level = newLevel ?? this.level;
    }
    public void setOrigin(KJ_Tool_Origin newOrigin){
        this.origin = newOrigin ?? this.origin;
    }

}