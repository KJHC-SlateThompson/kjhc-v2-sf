/*
*   File: KJ_Tool_Package_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the package framework: KJ_Tool_Package and the pieces it carries --
*                KJ_Tool_Result, KJ_Tool_Exception, KJ_Tool_DataBundle, KJ_Tool_DataEntry, and the
*                Origin, Org, User and Trigger contexts.
*
*   Index:
*       Package                     build, setters, fromTrigger, nullCheck, applyErrorsToRecords
*       Result                      success flags by exception level, setters
*       Exception                   level factories, defaults, setters
*       Data                        DataBundle, DataEntry
*       Context                     Origin, OrgContext, UserContext, TriggerContext
*/
@isTest
public with sharing class KJ_Tool_Package_Test {

    //*-- Package ---------------------------------------------------------------------------------
    // build() starts empty and successful; every with* setter applies a value and ignores null.
    @isTest
    static void package_BuildAndSetters_HappyPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(KJ_Tool_DataEntry.build('value'));
        KJ_Tool_Result result     = KJ_Tool_Result.build(false);
        KJ_Tool_Origin origin     = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_OrgContext org    = new KJ_Tool_OrgContext();
        KJ_Tool_UserContext user  = new KJ_Tool_UserContext();
        KJ_Tool_TriggerContext ctx = new KJ_Tool_TriggerContext();

        KJ_Tool_Package empty = KJ_Tool_Package.build();
        KJ_Tool_Package pkg = KJ_Tool_Package.build(bundle)
            .withLabel('Label')
            .withResult(result)
            .withOrigin(origin)
            .withOrgContext(org)
            .withUserContext(user)
            .withTriggerContext(ctx);
        pkg.withLabel(null).withResult(null).withOrigin(null).withOrgContext(null).withUserContext(null).withTriggerContext(null);

        Assert.areEqual('', empty.label, 'A new package should have a blank label');
        Assert.isTrue(empty.dataBundle.entries.isEmpty(), 'A new package should have an empty bundle');
        Assert.isTrue(empty.result.isSuccess, 'A new package should start successful');
        Assert.areEqual(KJ_Tool_Origin.SourceType.UNSPECIFIED, empty.origin.sourceType, 'A new package should have an unspecified origin');
        Assert.isNull(empty.triggerContext, 'A new package should have no trigger context');

        Assert.areEqual(bundle, pkg.dataBundle, 'build(bundle) should carry the bundle');
        Assert.areEqual('Label', pkg.label, 'withLabel should set the label, and null should not clear it');
        Assert.areEqual(result,  pkg.result, 'withResult should set the result, and null should not clear it');
        Assert.areEqual(origin,  pkg.origin, 'withOrigin should set the origin, and null should not clear it');
        Assert.areEqual(org,     pkg.orgContext, 'withOrgContext should set the org context, and null should not clear it');
        Assert.areEqual(user,    pkg.userContext, 'withUserContext should set the user context, and null should not clear it');
        Assert.areEqual(ctx,     pkg.triggerContext, 'withTriggerContext should set the trigger context, and null should not clear it');
    }

    // Outside a trigger, fromTrigger() still labels the package and stamps its origin, but carries no trigger context.
    @isTest
    static void package_FromTriggerOutsideTrigger_EdgePath(){
        KJ_Tool_Package pkg = KJ_Tool_Package.fromTrigger('Account', 'KJ_Dispatch_AccountTrigger');

        Assert.areEqual('Account Trigger Package', pkg.label, 'The label should name the object');
        Assert.areEqual(KJ_Tool_Origin.SourceType.APEX, pkg.origin.sourceType, 'The origin should be Apex');
        Assert.areEqual('KJ_Dispatch_AccountTrigger.trigger', pkg.origin.fileName, 'The origin file should be the trigger file');
        Assert.isNull(pkg.triggerContext, 'Outside a trigger there should be no trigger context');
    }

    // nullCheck() swaps a null package for a failed stand-in and passes a real package through untouched.
    @isTest
    static void package_NullCheck_MixedPath(){
        KJ_Tool_Package real = KJ_Tool_Package.build();

        KJ_Tool_Package standIn = KJ_Tool_Package.nullCheck(null);
        KJ_Tool_Package passed  = KJ_Tool_Package.nullCheck(real);

        Assert.isNotNull(standIn, 'A null package should be replaced');
        Assert.isFalse(standIn.result.isSuccess, 'The stand-in should be marked failed');
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, standIn.result.exceptions[0].code, 'The stand-in should report INVALID_CONTEXT');
        Assert.areEqual(KJ_Tool_Exception.Level.FATAL, standIn.result.exceptions[0].level, 'The stand-in exception should be FATAL');
        Assert.areEqual(real, passed, 'A real package should be returned as-is');
    }

    // HIGH and FATAL exceptions block their record; LOW exceptions never block.
    @isTest
    static void package_ApplyErrorsToRecords_MixedPath(){
        Account lowRecord   = new Account(Name = 'Low');
        Account highRecord  = new Account(Name = 'High');
        Account fatalRecord = new Account(Name = 'Fatal');
        KJ_Tool_Package pkg = KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext());
        pkg.result.addExceptions(new List<KJ_Tool_Exception>{
            KJ_Tool_Exception.low(KJ_Tool_Exception.Code.VALIDATION_ERROR, 'Low message', lowRecord),
            KJ_Tool_Exception.high(KJ_Tool_Exception.Code.VALIDATION_ERROR, 'High message', highRecord),
            KJ_Tool_Exception.fatal(KJ_Tool_Exception.Code.VALIDATION_ERROR, 'Fatal message', fatalRecord),
            KJ_Tool_Exception.fatal(KJ_Tool_Exception.Code.ROUTING_ERROR, 'Batch message')
        });

        Test.startTest();
        pkg.applyErrorsToRecords();
        Test.stopTest();

        Assert.isFalse(lowRecord.hasErrors(), 'A LOW exception should not block its record');
        Assert.areEqual('High message', highRecord.getErrors()[0].getMessage(), 'A HIGH exception should block its record with its message');
        Assert.areEqual('Fatal message', fatalRecord.getErrors()[0].getMessage(), 'A FATAL exception should block its record with its message');
    }


    //*-- Result ----------------------------------------------------------------------------------
    // LOW exceptions are recorded without failing the result; HIGH and FATAL fail it, and nothing turns it back.
    @isTest
    static void result_LevelFlags_MixedPath(){
        KJ_Tool_Result lowOnly = new KJ_Tool_Result();
        lowOnly.addException(KJ_Tool_Exception.low(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'low'));

        KJ_Tool_Result high = new KJ_Tool_Result();
        high.addException(KJ_Tool_Exception.high(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'high'));
        high.addException(KJ_Tool_Exception.low(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'low'));

        KJ_Tool_Result fatal = KJ_Tool_Result.build(true).withExceptions(new List<KJ_Tool_Exception>{
            KJ_Tool_Exception.fatal(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'fatal')
        });

        KJ_Tool_Result viaWith = KJ_Tool_Result.build(null)
            .withException(KJ_Tool_Exception.high(KJ_Tool_Exception.Code.TEST_EXCEPTION, 'high'));

        Assert.isTrue(lowOnly.isSuccess, 'LOW exceptions alone should not fail the result');
        Assert.isTrue(lowOnly.hasLows, 'A LOW exception should set hasLows');
        Assert.isFalse(lowOnly.hasHighs || lowOnly.hasFatals, 'A LOW exception should not set hasHighs or hasFatals');

        Assert.isFalse(high.isSuccess, 'A HIGH exception should fail the result, and a later LOW should not restore it');
        Assert.isTrue(high.hasHighs && high.hasLows, 'Both levels should be flagged');

        Assert.isFalse(fatal.isSuccess, 'A FATAL exception set through withExceptions should fail the result');
        Assert.isTrue(fatal.hasFatals, 'A FATAL exception should set hasFatals');

        Assert.isTrue(viaWith.hasHighs && !viaWith.isSuccess, 'withException should flag and fail like addException');
    }

    // Setters apply values and ignore null; null exceptions are skipped; success can be set by hand.
    @isTest
    static void result_SettersAndNulls_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_Result result = KJ_Tool_Result.build(true)
            .withMessage('First')
            .withOrigin(origin)
            .withExceptions(null);

        result.addException(null);
        result.addExceptions(null);
        result.setMessage('Second');
        result.setMessage(null);
        result.setOrigin(null);
        result.markUnsuccessful();
        Boolean afterMarkUnsuccessful = result.isSuccess;
        result.markSuccessful();

        Assert.areEqual('Second', result.message, 'setMessage should set the message, and null should not clear it');
        Assert.areEqual(origin, result.origin, 'withOrigin should set the origin, and setOrigin(null) should not clear it');
        Assert.isTrue(result.exceptions.isEmpty(), 'Null exceptions and lists should be skipped');
        Assert.isFalse(afterMarkUnsuccessful, 'markUnsuccessful should fail the result');
        Assert.isTrue(result.isSuccess, 'markSuccessful should restore success');
        Assert.isFalse(KJ_Tool_Result.build(false).isSuccess, 'build(false) should start failed');
    }


    //*-- Exception -------------------------------------------------------------------------------
    // Each level has the same four factories: with an origin, with a record, message only, and wrapping a native exception.
    @isTest
    static void exception_LevelFactories_HappyPath(){
        KJ_Tool_Origin origin = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        Account record = new Account(Name = 'Record');
        DmlException nativeException = new DmlException('Native message');
        KJ_Tool_Exception.Code code = KJ_Tool_Exception.Code.TEST_EXCEPTION;

        Map<KJ_Tool_Exception.Level, List<KJ_Tool_Exception>> byLevel = new Map<KJ_Tool_Exception.Level, List<KJ_Tool_Exception>>{
            KJ_Tool_Exception.Level.LOW => new List<KJ_Tool_Exception>{
                KJ_Tool_Exception.low(code, 'With origin', origin),
                KJ_Tool_Exception.low(code, 'With record', record),
                KJ_Tool_Exception.low(code, 'Message only'),
                KJ_Tool_Exception.low(nativeException, code)
            },
            KJ_Tool_Exception.Level.HIGH => new List<KJ_Tool_Exception>{
                KJ_Tool_Exception.high(code, 'With origin', origin),
                KJ_Tool_Exception.high(code, 'With record', record),
                KJ_Tool_Exception.high(code, 'Message only'),
                KJ_Tool_Exception.high(nativeException, code)
            },
            KJ_Tool_Exception.Level.FATAL => new List<KJ_Tool_Exception>{
                KJ_Tool_Exception.fatal(code, 'With origin', origin),
                KJ_Tool_Exception.fatal(code, 'With record', record),
                KJ_Tool_Exception.fatal(code, 'Message only'),
                KJ_Tool_Exception.fatal(nativeException, code)
            }
        };

        for(KJ_Tool_Exception.Level level : byLevel.keySet()){
            List<KJ_Tool_Exception> built = byLevel.get(level);
            for(KJ_Tool_Exception e : built){
                Assert.areEqual(level, e.level, level + ' factories should set the ' + level + ' level');
                Assert.areEqual(code, e.code, level + ' factories should keep the code');
            }
            Assert.areEqual(origin, built[0].origin, level + ' with origin should keep the origin');
            Assert.areEqual(record, built[1].record, level + ' with record should keep the record');
            Assert.isNull(built[2].record, level + ' message only should apply to the whole batch');
            Assert.areEqual('Message only', built[2].message, level + ' message only should keep the message');
            Assert.areEqual(nativeException, built[3].nativeException, level + ' wrapping should keep the native exception');
            Assert.areEqual('Native message', built[3].message, level + ' wrapping should take the native message');
        }
    }

    // build() with nothing falls back to DEFAULT_CODE, LOW, a blank message and an unspecified origin; setters ignore null.
    @isTest
    static void exception_DefaultsAndSetters_HappyPath(){
        KJ_Tool_Exception e = KJ_Tool_Exception.build(null, null, null, null, null, null);

        Assert.areEqual(KJ_Tool_Exception.Code.DEFAULT_CODE, e.code, 'A missing code should default to DEFAULT_CODE');
        Assert.areEqual(KJ_Tool_Exception.Level.LOW, e.level, 'A missing level should default to LOW');
        Assert.areEqual('', e.message, 'A missing message with no native exception should be blank');
        Assert.areEqual(KJ_Tool_Origin.SourceType.UNSPECIFIED, e.origin.sourceType, 'A missing origin should be unspecified');

        KJ_Tool_Origin origin = KJ_Tool_Origin.fromRecord('Account', null);
        Account record = new Account(Name = 'Record');
        e.setCode(KJ_Tool_Exception.Code.VALIDATION_ERROR);
        e.setLevel(KJ_Tool_Exception.Level.HIGH);
        e.setMessage('Set message');
        e.setOrigin(origin);
        e.setRecord(record);
        e.setCode(null);
        e.setLevel(null);
        e.setMessage(null);
        e.setOrigin(null);
        e.setRecord(null);

        Assert.areEqual(KJ_Tool_Exception.Code.VALIDATION_ERROR, e.code, 'setCode should set the code, and null should not clear it');
        Assert.areEqual(KJ_Tool_Exception.Level.HIGH, e.level, 'setLevel should set the level, and null should not clear it');
        Assert.areEqual('Set message', e.message, 'setMessage should set the message, and null should not clear it');
        Assert.areEqual(origin, e.origin, 'setOrigin should set the origin, and null should not clear it');
        Assert.areEqual(record, e.record, 'setRecord should set the record, and null should not clear it');
    }


    //*-- Data ------------------------------------------------------------------------------------
    // A bundle holds entries in order, finds them by label, and answers null when empty or not found.
    @isTest
    static void dataBundle_AddAndRead_HappyPath(){
        KJ_Tool_DataEntry first  = KJ_Tool_DataEntry.build(1).withLabel('first');
        KJ_Tool_DataEntry second = KJ_Tool_DataEntry.build(2).withLabel('second');

        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(first).withLabel('Bundle');
        bundle.add(second);
        bundle.withLabel(null);
        KJ_Tool_DataBundle empty    = KJ_Tool_DataBundle.build((List<KJ_Tool_DataEntry>) null);
        KJ_Tool_DataBundle fromList = KJ_Tool_DataBundle.build(new List<KJ_Tool_DataEntry>{ first, second });

        Assert.areEqual('Bundle', bundle.label, 'withLabel should set the label, and null should not clear it');
        Assert.areEqual(first,  bundle.getFirst(), 'getFirst should return the first entry');
        Assert.areEqual(second, bundle.getLast(),  'getLast should return the last entry added');
        Assert.areEqual(second, bundle.getByLabel('second'), 'getByLabel should find an entry by its label');
        Assert.isNull(bundle.getByLabel('missing'), 'getByLabel should return null for an unknown label');
        Assert.areEqual(2, fromList.entries.size(), 'build(list) should keep every entry');

        Assert.isTrue(empty.entries.isEmpty(), 'build(null) should start with an empty list');
        Assert.isNull(empty.getFirst(), 'getFirst on an empty bundle should return null');
        Assert.isNull(empty.getLast(), 'getLast on an empty bundle should return null');
    }

    // An entry carries any value with a label and data type; null leaves the defaults.
    @isTest
    static void dataEntry_BuildAndSetters_HappyPath(){
        KJ_Tool_DataEntry entry = KJ_Tool_DataEntry.build('value')
            .withLabel('Label')
            .withDataType(KJ_Tool_DataEntry.DataType.UNKNOWN);
        entry.withLabel(null).withDataType(null);
        KJ_Tool_DataEntry empty = KJ_Tool_DataEntry.build(null);

        Assert.areEqual('value', entry.value, 'build should carry the value');
        Assert.areEqual('Label', entry.label, 'withLabel should set the label, and null should not clear it');
        Assert.areEqual(KJ_Tool_DataEntry.DataType.UNKNOWN, entry.dataType, 'withDataType should keep the data type');
        Assert.isNull(empty.value, 'build(null) should carry no value');
        Assert.areEqual('', empty.label, 'A new entry should have a blank label');
    }


    //*-- Context ---------------------------------------------------------------------------------
    // fromApex() and fromRecord() fill only their own fields; a new origin is unspecified.
    @isTest
    static void origin_Factories_HappyPath(){
        Id accountId = KJ_Tool_TestDataFactory.createTestAccount().Id;
        KJ_Tool_Origin blank  = new KJ_Tool_Origin();
        KJ_Tool_Origin apex   = KJ_Tool_Origin.fromApex('File.cls', 'File', 'method');
        KJ_Tool_Origin record = KJ_Tool_Origin.fromRecord('Account', accountId);

        Assert.areEqual(KJ_Tool_Origin.SourceType.UNSPECIFIED, blank.sourceType, 'A new origin should be unspecified');
        Assert.areEqual(KJ_Tool_Origin.SourceType.APEX, apex.sourceType, 'fromApex should set the Apex source type');
        Assert.areEqual('File.cls', apex.fileName, 'fromApex should keep the file name');
        Assert.areEqual('File', apex.className, 'fromApex should keep the class name');
        Assert.areEqual('method', apex.methodName, 'fromApex should keep the method name');
        Assert.areEqual('', apex.objectName, 'fromApex should leave the object name blank');
        Assert.areEqual(KJ_Tool_Origin.SourceType.RECORD, record.sourceType, 'fromRecord should set the record source type');
        Assert.areEqual('Account', record.objectName, 'fromRecord should keep the object name');
        Assert.areEqual('', record.className, 'fromRecord should leave the class name blank');
    }

    // OrgContext and UserContext read the running org and user.
    @isTest
    static void orgAndUserContext_Build_HappyPath(){
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];

        Test.startTest();
        KJ_Tool_OrgContext orgContext   = KJ_Tool_OrgContext.build();
        KJ_Tool_UserContext userContext = KJ_Tool_UserContext.build();
        Test.stopTest();

        Assert.areEqual(UserInfo.getOrganizationId(), orgContext.orgId, 'The org Id should be the running org');
        Assert.areEqual(org.IsSandbox ? KJ_Tool_OrgContext.OrgType.SANDBOX : KJ_Tool_OrgContext.OrgType.PRODUCTION, orgContext.orgType, 'The org type should match the running org');
        Assert.isTrue(orgContext.instanceUrl.startsWith('https://'), 'The instance URL should be the org domain');
        Assert.isNull(new KJ_Tool_OrgContext().orgId, 'A new org context should have no org Id');

        Assert.areEqual(UserInfo.getUserId(), userContext.userId, 'The user Id should be the running user');
        Assert.areEqual(UserInfo.getUserEmail(), userContext.userEmail, 'The email should be the running user email');
        Assert.isTrue(String.isNotBlank(userContext.profileName), 'The profile name should be read from the user profile');
        Assert.isFalse(userContext.hasCustomPermission('KJ_Nonexistent_Permission'), 'An unknown custom permission should not be granted');
        Assert.isNull(new KJ_Tool_UserContext().userId, 'A new user context should have no user Id');
    }

    // Outside a trigger build() returns null; a new context has every flag off and empty collections.
    @isTest
    static void triggerContext_OutsideTrigger_EdgePath(){
        KJ_Tool_TriggerContext built = KJ_Tool_TriggerContext.build();
        KJ_Tool_TriggerContext blank = new KJ_Tool_TriggerContext();

        Assert.isNull(built, 'build() outside a trigger should return null');
        Assert.isFalse(blank.isBefore || blank.isAfter || blank.isInsert || blank.isUpdate || blank.isDelete || blank.isUndelete, 'A new context should have every flag off');
        Assert.isTrue(blank.newList.isEmpty() && blank.oldList.isEmpty(), 'A new context should have empty lists');
        Assert.isTrue(blank.newMap.isEmpty() && blank.oldMap.isEmpty(), 'A new context should have empty maps');
        Assert.isTrue(blank.getChangedRecords(Account.Name).isEmpty(), 'With no records, nothing should have changed');
    }
}
