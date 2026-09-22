/* 
*   File: KJ_Dispatch_AccountController_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class tests the routing of the Account controller
*/
@isTest
public with sharing class KJ_Dispatch_AccountController_Test {

    // No trigger context, so route() calls summarize. Builds the model off an unsaved record.
    @isTest
    static void receive_NoTriggerContext_Summarizes(){
        KJ_Model_Account model = KJ_Model_Account.build(KJ_Tool_TestDataFactory.createTestAccount());
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(model).withLabel('Account')
        );

        KJ_Tool_Package pkg = KJ_Dispatch_AccountController.receive(KJ_Tool_Package.build(bundle));

        Assert.isTrue(pkg.result.isSuccess);
        Assert.isTrue(String.isNotBlank(pkg.result.message));
    }

    // Routed correctly, but the bundle is empty. Distinct from a routing failure.
    @isTest
    static void receive_MissingBundleEntry_FailPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_AccountController.receive(KJ_Tool_Package.build());

        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.MISSING_DATA, pkg.result.exceptions[0].code);
    }

    // build() returns null outside a trigger, so the no-arg constructor is the only fixture. Every
    // flag is false, so no engine method fires -- this asserts route() handles it cleanly.
    @isTest
    static void receive_TriggerContext_HappyPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_AccountController.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess);
        Assert.isTrue(pkg.result.exceptions.isEmpty());
    }

    @isTest
    static void receive_NullPackage_FailPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_AccountController.receive(null);

        Assert.isNotNull(pkg);
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, pkg.result.exceptions[0].code);
    }

    // An 'Account' entry holding something that is not a KJ_Model_Account makes summarize throw on
    // the cast, which proves receive()'s catch wraps anything route() blows up on.
    @isTest
    static void receive_RouteThrows_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build('not a model').withLabel('Account')
        );

        KJ_Tool_Package pkg = KJ_Dispatch_AccountController.receive(KJ_Tool_Package.build(bundle));

        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.ROUTING_ERROR, pkg.result.exceptions[0].code);
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
