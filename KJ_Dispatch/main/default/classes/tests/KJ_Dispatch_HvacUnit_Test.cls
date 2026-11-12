/*
*   File: KJ_Dispatch_HvacUnit_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the HVAC Unit object end to end: KJ_Dispatch_HvacUnitTrigger,
*                KJ_Dispatch_HvacUnit routing, and the KJ_Engine_HvacUnit automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      membership / property owner validation
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_HvacUnit_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static Account insertAccount(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        insert record;
        return record;
    }

    private static Customer_Property__c insertProperty(Id ownerAccountId){
        Customer_Property__c record = KJ_Tool_TestDataFactory.createTestCustomerProperty(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, ownerAccountId);
        insert record;
        return record;
    }

    private static Membership__c insertMembership(Id memberAccountId){
        Membership__c record = KJ_Tool_TestDataFactory.createTestMembership(memberAccountId);
        insert record;
        return record;
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Tool_TestDataFactory.createTest_HVAC_Unit()).withLabel('HvacUnit')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_HvacUnit.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_HvacUnit.receive(KJ_Tool_Package.build(bundle));

        Assert.isNotNull(nullPkg, 'A null package should be replaced, not returned as null');
        Assert.isFalse(nullPkg.result.isSuccess, 'A null package should fail');
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, nullPkg.result.exceptions[0].code, 'A null package should report INVALID_CONTEXT');

        Assert.isFalse(noContextPkg.result.isSuccess, 'A package with no trigger context should fail');
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, noContextPkg.result.exceptions[0].code, 'A package with no trigger context should report INVALID_CONTEXT');
    }

    // build() returns null outside a trigger, so the no-arg constructor is the only fixture. Every
    // flag is false, so no engine method fires -- this asserts route() handles it cleanly.
    @isTest
    static void receive_EmptyTriggerContext_HappyPath(){
        KJ_Tool_Package pkg = KJ_Dispatch_HvacUnit.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // One partial-success insert: a unit whose membership belongs to a different Account than the property
    // owner is blocked; a matching membership and a unit with no membership both go through.
    @isTest
    static void insert_MembershipAccountValidation_MixedPath(){
        // One insert: the org's Standard Account Duplicate Rule flags a second, similar factory Account
        // saved on its own, but doesn't compare records within the same batch
        Account owner    = KJ_Tool_TestDataFactory.createTestAccount();
        Account stranger = KJ_Tool_TestDataFactory.createTestAccount();
        insert new List<Account>{ owner, stranger };
        Customer_Property__c property = insertProperty(owner.Id);
        Membership__c ownerMembership    = insertMembership(owner.Id);
        Membership__c strangerMembership = insertMembership(stranger.Id);

        HVAC_Unit__c matching     = KJ_Tool_TestDataFactory.createTest_HVAC_Unit(ownerMembership.Id, property.Id);
        HVAC_Unit__c mismatched   = KJ_Tool_TestDataFactory.createTest_HVAC_Unit(strangerMembership.Id, property.Id);
        HVAC_Unit__c noMembership = KJ_Tool_TestDataFactory.createTest_HVAC_Unit(null, property.Id);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(new List<HVAC_Unit__c>{ matching, mismatched, noMembership }, false);
        Test.stopTest();

        Assert.isTrue(results[0].isSuccess(), 'A membership held by the property owner should be allowed');
        Assert.isFalse(results[1].isSuccess(), 'A membership held by a different Account should be blocked');
        Assert.areEqual(
            'Membership account does not match the unit\'s property owner account.',
            results[1].getErrors()[0].getMessage(),
            'The blocked insert should explain the account mismatch'
        );
        Assert.isTrue(results[2].isSuccess(), 'A unit with no membership should be allowed');
    }

    // Origin fields: blanks are filled (Origin Record Id after insert, once the Id exists); provided values are kept.
    @isTest
    static void insert_OriginFields_HappyPath(){
        Customer_Property__c property = insertProperty(insertAccount().Id);
        HVAC_Unit__c blank    = KJ_Tool_TestDataFactory.createTest_HVAC_Unit(null, property.Id);
        HVAC_Unit__c provided = KJ_Tool_TestDataFactory.createTest_HVAC_Unit(null, property.Id);
        provided.Record_Origin__c       = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.RecordOrigin.FIELDPULSE);
        provided.Origin_Created_Date__c = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        provided.Origin_Record_ID__c    = 'FP-U-1001';

        Test.startTest();
        insert new List<HVAC_Unit__c>{ blank, provided };
        Test.stopTest();

        Map<Id, HVAC_Unit__c> found = new Map<Id, HVAC_Unit__c>([
            SELECT Record_Origin__c, Origin_Created_Date__c, Origin_Record_ID__c
            FROM HVAC_Unit__c
            WHERE Id IN :new List<Id>{ blank.Id, provided.Id }
        ]);
        Assert.areEqual('KJHC Salesforce V2', found.get(blank.Id).Record_Origin__c, 'A blank Record Origin should default to KJHC Salesforce V2');
        Assert.areEqual(System.today(), found.get(blank.Id).Origin_Created_Date__c, 'A blank Origin Created Date should default to today');
        Assert.areEqual(String.valueOf(blank.Id), found.get(blank.Id).Origin_Record_ID__c, 'A blank Origin Record Id should default to the Salesforce Id');
        Assert.areEqual('FieldPulse', found.get(provided.Id).Record_Origin__c, 'A provided Record Origin should be kept');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.get(provided.Id).Origin_Created_Date__c, 'A provided Origin Created Date should be kept');
        Assert.areEqual('FP-U-1001', found.get(provided.Id).Origin_Record_ID__c, 'A provided Origin Record Id should be kept');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void hvacUnitTrigger_BulkBatch_HappyPath(){
        Account owner = insertAccount();
        Customer_Property__c property = insertProperty(owner.Id);
        Membership__c membership = insertMembership(owner.Id);
        List<HVAC_Unit__c> records = new List<HVAC_Unit__c>();
        for(Integer i = 0; i < 200; i++){
            records.add(KJ_Tool_TestDataFactory.createTest_HVAC_Unit(membership.Id, property.Id));
        }

        Test.startTest();
        insert records;
        List<HVAC_Unit__c> changes = new List<HVAC_Unit__c>();
        for(HVAC_Unit__c record : records){
            changes.add(new HVAC_Unit__c(Id = record.Id, Unit_Notes__c = 'Bulk update.'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM HVAC_Unit__c WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 units should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM HVAC_Unit__c WHERE Id IN :records], 'All 200 units should have undeleted');
    }
}
