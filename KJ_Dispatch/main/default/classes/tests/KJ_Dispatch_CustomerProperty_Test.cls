/*
*   File: KJ_Dispatch_CustomerProperty_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the Customer Property object end to end: KJ_Dispatch_CustomerPropertyTrigger,
*                KJ_Dispatch_CustomerProperty routing, and the KJ_Engine_CustomerProperty automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled, provided values kept
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_CustomerProperty_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    // Residential owner Account with a full AR service address for properties to copy from.
    private static Account insertOwnerAccount(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount(KJ_Model_Picklist.Sector.RESIDENTIAL, null, null, null);
        record.Service_Address__Street__s       = '42 Owner Ln';
        record.Service_Address__City__s         = KJ_Tool_TestDataFactory.DEFAULT_CITY;
        record.Service_Address__StateCode__s    = KJ_Tool_TestDataFactory.DEFAULT_STATE;
        record.Service_Address__PostalCode__s   = KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE;
        record.Service_Address__CountryCode__s  = KJ_Tool_TestDataFactory.DEFAULT_COUNTRY;
        insert record;
        return record;
    }

    // Property with no name, sector or address, so the engine's fill-in logic runs.
    private static Customer_Property__c blankProperty(Id ownerAccountId){
        Customer_Property__c record = KJ_Tool_TestDataFactory.createTestCustomerProperty(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, ownerAccountId);
        record.Name                             = null;
        record.Property_Sector__c               = null;
        record.Property_Address__Street__s      = null;
        record.Property_Address__City__s        = null;
        record.Property_Address__StateCode__s   = null;
        record.Property_Address__PostalCode__s  = null;
        record.Property_Address__CountryCode__s = null;
        return record;
    }

    private static Customer_Property__c requery(Id recordId){
        return [
            SELECT Name, Property_Sector__c, Property_Address__Street__s, Property_Address__City__s,
                Property_Address__StateCode__s, Property_Address__PostalCode__s, Property_Address__CountryCode__s
            FROM Customer_Property__c
            WHERE Id = :recordId
        ];
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Tool_TestDataFactory.createTestCustomerProperty()).withLabel('CustomerProperty')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_CustomerProperty.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_CustomerProperty.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_CustomerProperty.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Sector, address and name are all blank and get filled from the owner Account.
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account owner = insertOwnerAccount();
        Customer_Property__c record = blankProperty(owner.Id);

        Test.startTest();
        insert record;
        Test.stopTest();

        Customer_Property__c found = requery(record.Id);
        Assert.areEqual('Residential', found.Property_Sector__c, 'A blank sector should copy from the owner Account');
        Assert.areEqual('42 Owner Ln', found.Property_Address__Street__s, 'Street should copy from the owner service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_CITY,        found.Property_Address__City__s,        'City should copy from the owner service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STATE,       found.Property_Address__StateCode__s,   'State should copy from the owner service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE, found.Property_Address__PostalCode__s,  'Postal code should copy from the owner service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_COUNTRY,     found.Property_Address__CountryCode__s, 'Country should copy from the owner service address');
        Assert.areEqual('42 Owner Ln', found.Name, 'A blank name should default to the street address');
    }

    // Every field the engine fills is already set, so nothing is overwritten.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account owner = insertOwnerAccount();
        Customer_Property__c record = blankProperty(owner.Id);
        record.Name                        = 'Lake House';
        record.Property_Sector__c          = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.Sector.COMMERCIAL);
        record.Property_Address__Street__s = '500 Own St';

        Test.startTest();
        insert record;
        Test.stopTest();

        Customer_Property__c found = requery(record.Id);
        Assert.areEqual('Lake House', found.Name, 'A provided name should not be replaced by the street');
        Assert.areEqual('Commercial', found.Property_Sector__c, 'A provided sector should not be replaced by the Account sector');
        Assert.areEqual('500 Own St', found.Property_Address__Street__s, 'A provided street should not be replaced by the owner service address');
        Assert.isNull(found.Property_Address__City__s, 'A provided address should not be partially filled from the owner');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void customerPropertyTrigger_BulkBatch_HappyPath(){
        Account owner = insertOwnerAccount();
        List<Customer_Property__c> records = new List<Customer_Property__c>();
        for(Integer i = 0; i < 200; i++){
            records.add(blankProperty(owner.Id));
        }

        Test.startTest();
        insert records;
        List<Customer_Property__c> changes = new List<Customer_Property__c>();
        for(Customer_Property__c record : records){
            changes.add(new Customer_Property__c(Id = record.Id, Property_Notes__c = 'Bulk update.'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Customer_Property__c WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 properties should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Customer_Property__c WHERE Id IN :records], 'All 200 properties should have undeleted');
    }
}
