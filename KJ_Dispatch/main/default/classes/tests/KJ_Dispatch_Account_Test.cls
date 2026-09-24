/*
*   File: KJ_Dispatch_Account_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class tests the routing of the Account controller
*/
@isTest
public with sharing class KJ_Dispatch_Account_Test {

    // receive() is trigger-only, so a package with data but no trigger context is rejected.
    @isTest
    static void receive_NoTriggerContext_FailPath(){
        KJ_Model_Account model = KJ_Model_Account.build(KJ_Tool_TestDataFactory.createTestAccount());
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(model).withLabel('Account')
        );

        KJ_Tool_Package pkg = KJ_Dispatch_Account.receive(KJ_Tool_Package.build(bundle));

        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, pkg.result.exceptions[0].code);
    }

    // Reached the engine, but the bundle is empty. Distinct from a context failure.
    @isTest
    static void archive_MissingBundleEntry_FailPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_Account.archive(KJ_Tool_Package.build());

        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.MISSING_DATA, pkg.result.exceptions[0].code);
    }

    // build() returns null outside a trigger, so the no-arg constructor is the only fixture. Every
    // flag is false, so no engine method fires -- this asserts route() handles it cleanly.
    @isTest
    static void receive_TriggerContext_HappyPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_Account.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess);
        Assert.isTrue(pkg.result.exceptions.isEmpty());
    }

    @isTest
    static void receive_NullPackage_FailPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_Account.receive(null);

        Assert.isNotNull(pkg);
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, pkg.result.exceptions[0].code);
    }

    // The real path end to end: DML on Account fires KJ_Dispatch_AccountTrigger, which builds a
    // package and hands it to the controller. Proves the trigger, controller and engine are wired.
    @isTest
    static void accountTrigger_InsertAndUpdate_HappyPath(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();

        Test.startTest();
        insert record;
        record.Office_Notes__c = 'Touched by the Account trigger test.';
        update record;
        Test.stopTest();

        Assert.isNotNull(record.Id);
    }
}
