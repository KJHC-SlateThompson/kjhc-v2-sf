/*
*   File: KJ_Dispatch_Account_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class tests the Account object end to end: KJ_Dispatch_AccountTrigger,
*                KJ_Dispatch_Account routing, and the KJ_Engine_Account automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled, provided values kept
*       Update                      Customer Since
*       Delete                      related record guard
*       Archive                     archive() entry point
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_Account_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static final String CURRENT_CUSTOMER = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER);

    // Account with no billing address and no territory, so the engine's fill-in logic runs.
    private static Account accountWithServiceAddressOnly(String stateCode){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        record.BillingStreet                    = null;
        record.BillingCity                      = null;
        record.BillingState                     = null;
        record.BillingPostalCode                = null;
        record.BillingCountry                   = null;
        record.Branch_Territory__c              = null;

        record.Service_Address__Street__s       = KJ_Tool_TestDataFactory.DEFAULT_STREET;
        record.Service_Address__City__s         = KJ_Tool_TestDataFactory.DEFAULT_CITY;
        record.Service_Address__StateCode__s    = stateCode;
        record.Service_Address__PostalCode__s   = KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE;
        record.Service_Address__CountryCode__s  = KJ_Tool_TestDataFactory.DEFAULT_COUNTRY;
        return record;
    }

    private static Map<Id, Account> requery(List<Account> records){
        return new Map<Id, Account>([
            SELECT Customer_Since__c, Record_Origin__c, Branch_Territory__c, Archived__c, Name,
                BillingStreet, BillingCity, BillingStateCode, BillingPostalCode, BillingCountryCode
            FROM Account
            WHERE Id IN :records
        ]);
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Model_Account.build(KJ_Tool_TestDataFactory.createTestAccount())).withLabel('Account')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_Account.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_Account.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_Account.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Every field the engine fills is blank: Customer Since, Record Origin, Billing Address, Branch Territory.
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account customer = accountWithServiceAddressOnly('AR');
        customer.Account_Status__c = CURRENT_CUSTOMER;
        Account lead = accountWithServiceAddressOnly('OK');

        Test.startTest();
        insert new List<Account>{ customer, lead };
        Test.stopTest();

        Map<Id, Account> found = requery(new List<Account>{ customer, lead });
        Account foundCustomer = found.get(customer.Id);
        Account foundLead     = found.get(lead.Id);

        Assert.areEqual(System.today(), foundCustomer.Customer_Since__c, 'A Current Customer should get Customer Since = today');
        Assert.isNull(foundLead.Customer_Since__c, 'A Lead should not get Customer Since');

        Assert.areEqual('KJHC Salesforce V2', foundCustomer.Record_Origin__c, 'A blank Record Origin should default to KJHC Salesforce V2');

        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_STREET,      foundCustomer.BillingStreet,      'Billing street should copy from the service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_CITY,        foundCustomer.BillingCity,        'Billing city should copy from the service address');
        Assert.areEqual('AR',                                         foundCustomer.BillingStateCode,   'Billing state should copy from the service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_POSTAL_CODE, foundCustomer.BillingPostalCode,  'Billing postal code should copy from the service address');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_COUNTRY,     foundCustomer.BillingCountryCode, 'Billing country should copy from the service address');
        Assert.areEqual('OK',                                         foundLead.BillingStateCode,       'Billing state should copy from the service address');

        Assert.areEqual('NWA',   foundCustomer.Branch_Territory__c, 'An AR service address should set the NWA territory');
        Assert.areEqual('Tulsa', foundLead.Branch_Territory__c,     'An OK service address should set the Tulsa territory');
    }

    // Every field the engine fills is already set, so nothing is overwritten.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account record = accountWithServiceAddressOnly('OK');
        record.Account_Status__c   = CURRENT_CUSTOMER;
        record.Customer_Since__c   = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        record.Record_Origin__c    = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.RecordOrigin.FIELDPULSE);
        record.BillingStreet       = '999 Billing Ave';
        record.Branch_Territory__c = 'NWA';

        Test.startTest();
        insert record;
        Test.stopTest();

        Account found = requery(new List<Account>{ record }).get(record.Id);
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.Customer_Since__c, 'A provided Customer Since should be kept');
        Assert.areEqual('FieldPulse',      found.Record_Origin__c,    'A provided Record Origin should be kept');
        Assert.areEqual('999 Billing Ave', found.BillingStreet,       'A provided billing address should not be replaced by the service address');
        Assert.areEqual('NWA',             found.Branch_Territory__c, 'A provided territory should not be replaced by the service address state');
    }


    //*-- Update ----------------------------------------------------------------------------------
    // Customer Since is set only when the status changes to Current Customer and it isn't already set.
    @isTest
    static void update_CustomerSince_HappyPath(){
        Account becomesCustomer = KJ_Tool_TestDataFactory.createTestAccount();
        Account statusUnchanged = KJ_Tool_TestDataFactory.createTestAccount();
        Account alreadyDated    = KJ_Tool_TestDataFactory.createTestAccount();
        alreadyDated.Customer_Since__c = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        List<Account> records = new List<Account>{ becomesCustomer, statusUnchanged, alreadyDated };
        insert records;

        // Fresh records carrying only the change: values the engine set on insert aren't on the in-memory list
        Test.startTest();
        update new List<Account>{
            new Account(Id = becomesCustomer.Id, Account_Status__c = CURRENT_CUSTOMER),
            new Account(Id = statusUnchanged.Id, Office_Notes__c = 'Status untouched.'),
            new Account(Id = alreadyDated.Id,    Account_Status__c = CURRENT_CUSTOMER)
        };
        Test.stopTest();

        Map<Id, Account> found = requery(records);
        Assert.areEqual(System.today(), found.get(becomesCustomer.Id).Customer_Since__c, 'Changing to Current Customer should set Customer Since = today');
        Assert.isNull(found.get(statusUnchanged.Id).Customer_Since__c, 'An update that leaves the status alone should not set Customer Since');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE, found.get(alreadyDated.Id).Customer_Since__c, 'An existing Customer Since should be kept');
    }


    //*-- Delete ----------------------------------------------------------------------------------
    // One partial-success delete: the Account with a related Contact is blocked, the other goes through.
    @isTest
    static void delete_RelatedRecordGuard_MixedPath(){
        Account withContact = KJ_Tool_TestDataFactory.createTestAccount();
        Account standalone  = KJ_Tool_TestDataFactory.createTestAccount();
        insert new List<Account>{ withContact, standalone };
        insert KJ_Tool_TestDataFactory.createTestContact(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, withContact.Id);

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(new List<Account>{ withContact, standalone }, false);
        Test.stopTest();

        Assert.isFalse(results[0].isSuccess(), 'An Account with a related Contact should not be deletable');
        Assert.areEqual(
            'This Account has related records. Archive it instead of deleting it.',
            results[0].getErrors()[0].getMessage(),
            'The blocked delete should tell the user to archive instead'
        );
        Assert.isTrue(results[1].isSuccess(), 'An Account with no related records should delete');
    }


    //*-- Archive ---------------------------------------------------------------------------------
    // Null package, empty bundle and a non-Account entry are rejected; a real Account entry is archived
    // with the rest of the record untouched.
    @isTest
    static void archive_HappyAndFailPaths(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        insert record;
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Model_Account.build(record)).withLabel('Account')
        );
        KJ_Tool_DataBundle wrongTypeBundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build('Not an Account model').withLabel('Account')
        );

        Test.startTest();
        KJ_Tool_Package nullPkg      = KJ_Dispatch_Account.archive(null);
        KJ_Tool_Package emptyPkg     = KJ_Dispatch_Account.archive(KJ_Tool_Package.build());
        KJ_Tool_Package wrongTypePkg = KJ_Dispatch_Account.archive(KJ_Tool_Package.build(wrongTypeBundle));
        KJ_Tool_Package pkg          = KJ_Dispatch_Account.archive(KJ_Tool_Package.build(bundle));
        Test.stopTest();

        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, nullPkg.result.exceptions[0].code, 'A null package should report INVALID_CONTEXT');
        Assert.areEqual(KJ_Tool_Exception.Code.MISSING_DATA, emptyPkg.result.exceptions[0].code, 'An empty bundle should report MISSING_DATA');
        Assert.isFalse(wrongTypePkg.result.isSuccess, 'A non-Account entry should fail');
        Assert.areEqual(KJ_Tool_Exception.Code.OPERATION_ERROR, wrongTypePkg.result.exceptions[0].code, 'A non-Account entry should be caught by the controller as OPERATION_ERROR');

        Assert.isTrue(pkg.result.isSuccess, 'Archiving a real Account should succeed');
        Account found = requery(new List<Account>{ record }).get(record.Id);
        Assert.isTrue(found.Archived__c, 'The Account should be marked Archived');
        Assert.areEqual(record.Name, found.Name, 'Archiving should not change other fields');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void accountTrigger_BulkBatch_HappyPath(){
        List<Account> records = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            records.add(accountWithServiceAddressOnly('AR'));
        }

        Test.startTest();
        insert records;
        List<Account> changes = new List<Account>();
        for(Account record : records){
            changes.add(new Account(Id = record.Id, Account_Status__c = CURRENT_CUSTOMER));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Account WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 Accounts should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Account WHERE Id IN :records], 'All 200 Accounts should have undeleted');
    }
}
