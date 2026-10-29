/*
*   File: KJ_Tool_Logger_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests logging: KJ_Tool_LogEntry (factories, level mapping, setters) and
*                KJ_Tool_Logger (every level writes to the debug log without throwing).
*
*   Index:
*       LogEntry                    factories, level mapping, setters
*       Logger                      every overload
*/
@isTest
public with sharing class KJ_Tool_Logger_Test {

    //*-- LogEntry --------------------------------------------------------------------------------
    // Each level factory sets its level, with or without an origin; a new entry is DEBUG and timestamped now.
    @isTest
    static void logEntry_Factories_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        Datetime stamp = Datetime.newInstance(2026, 1, 1, 8, 0, 0);

        KJ_Tool_LogEntry blank = new KJ_Tool_LogEntry();
        KJ_Tool_LogEntry built = KJ_Tool_LogEntry.build(KJ_Tool_LogEntry.Level.INFO, origin, stamp, 'Built');
        KJ_Tool_LogEntry defaults = KJ_Tool_LogEntry.build(null, null, null, null);

        Map<KJ_Tool_LogEntry.Level, List<KJ_Tool_LogEntry>> byLevel = new Map<KJ_Tool_LogEntry.Level, List<KJ_Tool_LogEntry>>{
            KJ_Tool_LogEntry.Level.DEBUG => new List<KJ_Tool_LogEntry>{ KJ_Tool_LogEntry.debug('m', origin), KJ_Tool_LogEntry.debug('m') },
            KJ_Tool_LogEntry.Level.INFO  => new List<KJ_Tool_LogEntry>{ KJ_Tool_LogEntry.info('m', origin),  KJ_Tool_LogEntry.info('m') },
            KJ_Tool_LogEntry.Level.WARN  => new List<KJ_Tool_LogEntry>{ KJ_Tool_LogEntry.warn('m', origin),  KJ_Tool_LogEntry.warn('m') },
            KJ_Tool_LogEntry.Level.ERROR => new List<KJ_Tool_LogEntry>{ KJ_Tool_LogEntry.error('m', origin), KJ_Tool_LogEntry.error('m') }
        };
        for(KJ_Tool_LogEntry.Level level : byLevel.keySet()){
            List<KJ_Tool_LogEntry> entries = byLevel.get(level);
            Assert.areEqual(level, entries[0].level, level + ' with origin should set the ' + level + ' level');
            Assert.areEqual(origin, entries[0].origin, level + ' with origin should keep the origin');
            Assert.areEqual(level, entries[1].level, level + ' without origin should set the ' + level + ' level');
            Assert.areEqual(KJ_Tool_Origin.SourceType.UNSPECIFIED, entries[1].origin.sourceType, level + ' without origin should be unspecified');
        }

        Assert.areEqual(KJ_Tool_LogEntry.Level.DEBUG, blank.level, 'A new entry should be DEBUG');
        Assert.isNotNull(blank.timestamp, 'A new entry should be timestamped');
        Assert.areEqual(stamp, built.timestamp, 'build should keep a provided timestamp');
        Assert.areEqual('Built', built.message, 'build should keep the message');
        Assert.areEqual(KJ_Tool_LogEntry.Level.DEBUG, defaults.level, 'build with nulls should keep the defaults');
        Assert.areEqual('', defaults.message, 'build with nulls should keep a blank message');
    }

    // Exception levels and Apex LoggingLevels map onto LogEntry levels, and LogEntry levels map back to LoggingLevels.
    @isTest
    static void logEntry_LevelMapping_HappyPath(){
        Assert.areEqual(KJ_Tool_LogEntry.Level.WARN,  KJ_Tool_LogEntry.mapToLogEntryLevel(KJ_Tool_Exception.Level.LOW),   'A LOW exception should log as WARN');
        Assert.areEqual(KJ_Tool_LogEntry.Level.ERROR, KJ_Tool_LogEntry.mapToLogEntryLevel(KJ_Tool_Exception.Level.HIGH),  'A HIGH exception should log as ERROR');
        Assert.areEqual(KJ_Tool_LogEntry.Level.ERROR, KJ_Tool_LogEntry.mapToLogEntryLevel(KJ_Tool_Exception.Level.FATAL), 'A FATAL exception should log as ERROR');
        Assert.areEqual(KJ_Tool_LogEntry.Level.ERROR, KJ_Tool_LogEntry.mapToLogEntryLevel((KJ_Tool_Exception.Level) null), 'An unknown exception level should log as ERROR');

        Assert.areEqual(KJ_Tool_LogEntry.Level.ERROR, KJ_Tool_LogEntry.mapToLogEntryLevel(LoggingLevel.ERROR),  'LoggingLevel.ERROR should map to ERROR');
        Assert.areEqual(KJ_Tool_LogEntry.Level.WARN,  KJ_Tool_LogEntry.mapToLogEntryLevel(LoggingLevel.WARN),   'LoggingLevel.WARN should map to WARN');
        Assert.areEqual(KJ_Tool_LogEntry.Level.INFO,  KJ_Tool_LogEntry.mapToLogEntryLevel(LoggingLevel.INFO),   'LoggingLevel.INFO should map to INFO');
        Assert.areEqual(KJ_Tool_LogEntry.Level.DEBUG, KJ_Tool_LogEntry.mapToLogEntryLevel(LoggingLevel.FINEST), 'Finer LoggingLevels should map to DEBUG');

        Assert.areEqual(LoggingLevel.ERROR, KJ_Tool_LogEntry.mapToLoggingLevel(KJ_Tool_LogEntry.Level.ERROR), 'ERROR should map to LoggingLevel.ERROR');
        Assert.areEqual(LoggingLevel.INFO,  KJ_Tool_LogEntry.mapToLoggingLevel(KJ_Tool_LogEntry.Level.INFO),  'INFO should map to LoggingLevel.INFO');
        Assert.areEqual(LoggingLevel.WARN,  KJ_Tool_LogEntry.mapToLoggingLevel(KJ_Tool_LogEntry.Level.WARN),  'WARN should map to LoggingLevel.WARN');
        Assert.areEqual(LoggingLevel.DEBUG, KJ_Tool_LogEntry.mapToLoggingLevel(KJ_Tool_LogEntry.Level.DEBUG), 'DEBUG should map to LoggingLevel.DEBUG');
    }

    // Setters apply values and ignore null.
    @isTest
    static void logEntry_Setters_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_LogEntry entry = new KJ_Tool_LogEntry();

        entry.setMessage('Message');
        entry.setLevel(KJ_Tool_LogEntry.Level.WARN);
        entry.setOrigin(origin);
        entry.setMessage(null);
        entry.setLevel(null);
        entry.setOrigin(null);

        Assert.areEqual('Message', entry.message, 'setMessage should set the message, and null should not clear it');
        Assert.areEqual(KJ_Tool_LogEntry.Level.WARN, entry.level, 'setLevel should set the level, and null should not clear it');
        Assert.areEqual(origin, entry.origin, 'setOrigin should set the origin, and null should not clear it');
    }


    //*-- Logger ----------------------------------------------------------------------------------
    // Every logging overload formats and writes its entry without throwing. System.debug output can't be read
    // back in a test, so this proves the paths run cleanly.
    @isTest
    static void logger_EveryOverload_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_Exception e = KJ_Tool_Exception.high(new DmlException('Native message'), KJ_Tool_Exception.Code.TEST_EXCEPTION);
        Exception thrown;

        Test.startTest();
        try{
            KJ_Tool_Logger.debug('Debug', origin);
            KJ_Tool_Logger.debug('Debug');
            KJ_Tool_Logger.info('Info', origin);
            KJ_Tool_Logger.info('Info');
            KJ_Tool_Logger.warn('Warn', origin);
            KJ_Tool_Logger.warn('Warn');
            KJ_Tool_Logger.warn(e);
            KJ_Tool_Logger.error('Error', origin);
            KJ_Tool_Logger.error('Error');
            KJ_Tool_Logger.error(e);
        }
        catch(Exception caught){
            thrown = caught;
        }
        Test.stopTest();

        Assert.isNull(thrown, 'No logging overload should throw: ' + thrown?.getMessage());
    }
}
