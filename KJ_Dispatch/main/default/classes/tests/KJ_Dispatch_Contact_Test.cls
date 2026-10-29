/*
*   File: KJ_Dispatch_Contact_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the Contact object end to end: KJ_Dispatch_ContactTrigger,
*                KJ_Dispatch_Contact routing, and the KJ_Engine_Contact automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled, provided values kept, contact method validation
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_Contact_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static Account insertAccount(KJ_Model_Picklist.Sector sector){
        Account record = KJ_Tool_TestDataFactory.createTestAccount(sector, null, null, null);
        insert record;
        return record;
    }

    // Contact with only the given contact methods, no preference and no sector, so the engine's fill-in logic runs.
    private static Contact contactWith(Id accountId, String phone, String email, String mailingStreet){
        Contact record = KJ_Tool_TestDataFactory.createTestContact(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, accountId);
        record.Phone                        = phone;
        record.Email                        = email;
        record.MailingStreet                = mailingStreet;
        record.Contact_Method_Preference__c = null;
        record.Contact_Sector__c            = null;
        return record;
    }

    private static Map<Id, Contact> requery(List<Contact> records){
        return new Map<Id, Contact>([
            SELECT Contact_Method_Preference__c, Contact_Sector__c
            FROM Contact
            WHERE Id IN :records
        ]);
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Model_Contact.build(KJ_Tool_TestDataFactory.createTestContact())).withLabel('Contact')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_Contact.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_Contact.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_Contact.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Contact method preference, sector and the Account's primary contact are all blank and get filled.
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account parent = insertAccount(KJ_Model_Picklist.Sector.RESIDENTIAL);
        Contact phoneOnly = contactWith(parent.Id, KJ_Tool_TestDataFactory.DEFAULT_PHONE, null, null);
        Contact emailOnly = contactWith(parent.Id, null, KJ_Tool_TestDataFactory.DEFAULT_EMAIL, null);
        Contact both      = contactWith(parent.Id, KJ_Tool_TestDataFactory.DEFAULT_PHONE, KJ_Tool_TestDataFactory.DEFAULT_EMAIL, null);
        List<Contact> records = new List<Contact>{ phoneOnly, emailOnly, both };

        Test.startTest();
        insert records;
        Test.stopTest();

        Map<Id, Contact> found = requery(records);
        Assert.areEqual('Phone', found.get(phoneOnly.Id).Contact_Method_Preference__c, 'A phone-only Contact should default to the Phone preference');
        Assert.areEqual('Email', found.get(emailOnly.Id).Contact_Method_Preference__c, 'An email-only Contact should default to the Email preference');
        Assert.isNull(found.get(both.Id).Contact_Method_Preference__c, 'A Contact with both phone and email should be left for the user to choose');

        for(Contact record : found.values()){
            Assert.areEqual('Residential', record.Contact_Sector__c, 'A blank sector should copy from the parent Account');
        }

        Account foundParent = [SELECT Account_Primary_Contact__c FROM Account WHERE Id = :parent.Id];
        Assert.areEqual(phoneOnly.Id, foundParent.Account_Primary_Contact__c, 'The first Contact in the batch should become the Account primary contact');
    }

    // Every field the engine fills is already set, so nothing is overwritten.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account parent = insertAccount(KJ_Model_Picklist.Sector.RESIDENTIAL);
        Contact existingPrimary = contactWith(parent.Id, KJ_Tool_TestDataFactory.DEFAULT_PHONE, null, null);
        insert existingPrimary;

        Contact record = contactWith(parent.Id, KJ_Tool_TestDataFactory.DEFAULT_PHONE, null, null);
        record.Contact_Method_Preference__c = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.ContactMethod.EMAIL);
        record.Contact_Sector__c            = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.Sector.COMMERCIAL);

        Test.startTest();
        insert record;
        Test.stopTest();

        Contact found = requery(new List<Contact>{ record }).get(record.Id);
        Assert.areEqual('Email', found.Contact_Method_Preference__c, 'A provided preference should be kept even when only a phone is on file');
        Assert.areEqual('Commercial', found.Contact_Sector__c, 'A provided sector should not be replaced by the Account sector');

        Account foundParent = [SELECT Account_Primary_Contact__c FROM Account WHERE Id = :parent.Id];
        Assert.areEqual(existingPrimary.Id, foundParent.Account_Primary_Contact__c, 'An existing Account primary contact should not be replaced');
    }

    // One partial-success insert: the Contact with no phone, email or mailing street is blocked, the other goes through.
    @isTest
    static void insert_ContactMethodValidation_MixedPath(){
        Account parent = insertAccount(KJ_Model_Picklist.Sector.RESIDENTIAL);
        Contact noMethods  = contactWith(parent.Id, null, null, null);
        Contact mailOnly   = contactWith(parent.Id, null, null, KJ_Tool_TestDataFactory.DEFAULT_STREET);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(new List<Contact>{ noMethods, mailOnly }, false);
        Test.stopTest();

        Assert.isFalse(results[0].isSuccess(), 'A Contact with no phone, email or mailing street should be blocked');
        Assert.areEqual(
            'Contact does not have any of the following contact methods: Phone, Email, Mailing Address',
            results[0].getErrors()[0].getMessage(),
            'The blocked insert should list the missing contact methods'
        );
        Assert.isTrue(results[1].isSuccess(), 'A mailing street alone should satisfy the contact method rule');
        Assert.isNull(requery(new List<Contact>{ mailOnly }).get(mailOnly.Id).Contact_Method_Preference__c, 'A mail-only Contact should get no phone/email preference');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void contactTrigger_BulkBatch_HappyPath(){
        Account parent = insertAccount(KJ_Model_Picklist.Sector.RESIDENTIAL);
        List<Contact> records = new List<Contact>();
        for(Integer i = 0; i < 200; i++){
            records.add(contactWith(parent.Id, KJ_Tool_TestDataFactory.DEFAULT_PHONE, null, null));
        }

        Test.startTest();
        insert records;
        List<Contact> changes = new List<Contact>();
        for(Contact record : records){
            changes.add(new Contact(Id = record.Id, Contact_Notes__c = 'Bulk update.'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Contact WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 Contacts should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Contact WHERE Id IN :records], 'All 200 Contacts should have undeleted');
        Assert.areEqual(records[0].Id, [SELECT Account_Primary_Contact__c FROM Account WHERE Id = :parent.Id].Account_Primary_Contact__c, 'Only the first of the 200 should become the primary contact');
    }
}
