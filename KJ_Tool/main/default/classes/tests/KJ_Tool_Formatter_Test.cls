/*
*   File: KJ_Tool_Formatter_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests KJ_Tool_Formatter: every toString() overload and toLogEntry().
*
*   Index:
*       toString                    origins, levels and codes, log entries, results, exceptions, Account models
*       toLogEntry                  exception to log entry
*/
@isTest
public with sharing class KJ_Tool_Formatter_Test {

    //*-- toString --------------------------------------------------------------------------------
    // Apex origins read file: class.method, record origins read object: Id, anything else is UNSPECIFIED.
    @isTest
    static void toString_Origins_HappyPath(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        insert record;

        Assert.areEqual('File.cls: File.method', KJ_Tool_Formatter.toString(KJ_Tool_Origin.fromApex('File.cls', 'File', 'method')), 'An Apex origin should read file: class.method');
        Assert.areEqual('Account: ' + record.Id, KJ_Tool_Formatter.toString(KJ_Tool_Origin.fromRecord('Account', record.Id)), 'A record origin should read object: Id');
        Assert.areEqual('UNSPECIFIED', KJ_Tool_Formatter.toString(new KJ_Tool_Origin()), 'An unspecified origin should read UNSPECIFIED');
    }

    // Every log level, exception level and exception code has a readable name.
    @isTest
    static void toString_LevelsAndCodes_HappyPath(){
        for(KJ_Tool_LogEntry.Level level : KJ_Tool_LogEntry.Level.values()){
            Assert.areEqual(level.name(), KJ_Tool_Formatter.toString(level), 'Log level ' + level + ' should read as its name');
        }
        for(KJ_Tool_Exception.Level level : KJ_Tool_Exception.Level.values()){
            Assert.areEqual(level.name(), KJ_Tool_Formatter.toString(level), 'Exception level ' + level + ' should read as its name');
        }
        for(KJ_Tool_Exception.Code code : KJ_Tool_Exception.Code.values()){
            Assert.areEqual(code.name(), KJ_Tool_Formatter.toString(code), 'Exception code ' + code + ' should read as its name');
        }
        Assert.areEqual('UNSPECIFIED', KJ_Tool_Formatter.toString((KJ_Tool_LogEntry.Level) null), 'A null log level should read UNSPECIFIED');
        Assert.areEqual('UNSPECIFIED', KJ_Tool_Formatter.toString((KJ_Tool_Exception.Level) null), 'A null exception level should read UNSPECIFIED');
    }

    // A log entry block carries its level, origin, timestamp and message.
    @isTest
    static void toString_LogEntry_HappyPath(){
        KJ_Tool_LogEntry entry = KJ_Tool_LogEntry.warn('Something to look at', KJ_Tool_Origin.fromApex('File.cls', 'File', 'method'));

        String output = KJ_Tool_Formatter.toString(entry);

        Assert.isTrue(output.contains('L O G   E N T R Y'), 'The block should have the log entry header');
        Assert.isTrue(output.contains('Level: WARN'), 'The block should carry the level');
        Assert.isTrue(output.contains('Origin: File.cls: File.method'), 'The block should carry the origin');
        Assert.isTrue(output.contains('Timestamp: ' + entry.timestamp.format()), 'The block should carry the timestamp');
        Assert.isTrue(output.contains('Something to look at'), 'The block should carry the message');
    }

    // A result block carries success, message, exception count and each level flag.
    @isTest
    static void toString_Result_HappyPath(){
        KJ_Tool_Result result = KJ_Tool_Result.build(true).withMessage('Result message');
        result.addException(KJ_Tool_Exception.high(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'high'));
        result.addException(KJ_Tool_Exception.low(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'low'));

        String output = KJ_Tool_Formatter.toString(result);

        Assert.isTrue(output.contains('Is Success: FALSE'), 'The block should show the failed result');
        Assert.isTrue(output.contains('Message: Result message'), 'The block should carry the message');
        Assert.isTrue(output.contains('Exception count: 2'), 'The block should count the exceptions');
        Assert.isTrue(output.contains('Has Fatals: FALSE'), 'The block should show no fatals');
        Assert.isTrue(output.contains('Has Highs: TRUE'), 'The block should show the high');
        Assert.isTrue(output.contains('Has Lows: TRUE'), 'The block should show the low');
        Assert.isTrue(output.contains('Origin: UNSPECIFIED'), 'The block should carry the origin');
        Assert.isTrue(KJ_Tool_Formatter.toString(new KJ_Tool_Result()).contains('Is Success: TRUE'), 'A clean result should show success');
    }

    // An exception block carries code, level, origin and message, plus the native type when it wraps one.
    @isTest
    static void toString_Exception_MixedPath(){
        KJ_Tool_Exception plain   = KJ_Tool_Exception.high(KJ_Tool_Exception.Code.VALIDATION_ERROR, 'Plain message');
        KJ_Tool_Exception wrapped = KJ_Tool_Exception.fatal(new DmlException('Native message'), KJ_Tool_Exception.Code.OPERATION_ERROR);

        String plainOutput   = KJ_Tool_Formatter.toString(plain);
        String wrappedOutput = KJ_Tool_Formatter.toString(wrapped);

        Assert.isTrue(plainOutput.contains('Code: VALIDATION_ERROR'), 'The block should carry the code');
        Assert.isTrue(plainOutput.contains('Level: HIGH'), 'The block should carry the level');
        Assert.isTrue(plainOutput.contains('Origin: (UNSPECIFIED)'), 'The block should carry the origin');
        Assert.isTrue(plainOutput.contains('Plain message'), 'The block should carry the message');
        Assert.isFalse(plainOutput.contains('Caused by'), 'A plain exception should have no cause');

        Assert.isTrue(wrappedOutput.contains('Native message'), 'A wrapped exception should carry the native message');
        Assert.isTrue(wrappedOutput.contains('Caused by: System.DmlException'), 'A wrapped exception should name the native type');
        Assert.isTrue(wrappedOutput.contains('Stack Trace:'), 'A wrapped exception should include the stack trace section');
    }

    // An Account model reads name (Id) -- status, sector, territory.
    @isTest
    static void toString_AccountModel_HappyPath(){
        KJ_Model_Account model = KJ_Model_Account.build()
            .setName('Formatter Account')
            .setStatus(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER)
            .setSector(KJ_Model_Picklist.Sector.RESIDENTIAL)
            .setBranchTerritory(KJ_Model_Picklist.Territory.TULSA);

        Assert.areEqual(
            'Account Formatter Account (null) -- status Current Customer, sector Residential, territory Tulsa',
            KJ_Tool_Formatter.toString(model),
            'The Account summary should read name (Id) -- status, sector, territory'
        );
    }


    //*-- toLogEntry ------------------------------------------------------------------------------
    // An exception becomes a log entry at the mapped level, keeping its origin and formatted text.
    @isTest
    static void toLogEntry_Exception_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_Exception e = KJ_Tool_Exception.low(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'Low message', origin);

        KJ_Tool_LogEntry entry = KJ_Tool_Formatter.toLogEntry(e);

        Assert.areEqual(KJ_Tool_LogEntry.Level.WARN, entry.level, 'A LOW exception should become a WARN entry');
        Assert.areEqual(origin, entry.origin, 'The entry should keep the exception origin');
        Assert.areEqual(KJ_Tool_Formatter.toString(e), entry.message, 'The entry message should be the formatted exception');
        Assert.isNotNull(entry.timestamp, 'The entry should be timestamped');
    }
}
