/*
*   File: KJ_Dispatch_Project_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the Project object end to end: KJ_Dispatch_ProjectTrigger,
*                KJ_Dispatch_Project routing, and the KJ_Engine_Project automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled, provided values kept, date validation
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_Project_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    // Residential Account in Tulsa whose primary contact is set by the Contact trigger.
    private static Account insertAccountWithPrimaryContact(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount(KJ_Model_Picklist.Sector.RESIDENTIAL, null, null, null);
        record.Branch_Territory__c = 'Tulsa';
        insert record;
        insert KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.RESIDENTIAL, record.Id);
        return [SELECT Id, Account_Primary_Contact__c FROM Account WHERE Id = :record.Id];
    }

    // Commercial property at the factory street address.
    private static Customer_Property__c insertProperty(Id ownerAccountId){
        Customer_Property__c record = KJ_Tool_TestDataFactory.createTestCustomerProperty(KJ_Model_Picklist.Sector.COMMERCIAL, ownerAccountId);
        insert record;
        return record;
    }

    // Project with no name, contact, sector, territory or origin, so the engine's fill-in logic runs.
    private static Project__c blankProject(Id accountId, Id propertyId){
        Project__c record = KJ_Tool_TestDataFactory.createTestProject(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, accountId, null, null, propertyId);
        record.Project_Name__c     = null;
        record.Sector__c           = null;
        record.Branch_Territory__c = null;
        return record;
    }

    private static Map<Id, Project__c> requery(List<Project__c> records){
        return new Map<Id, Project__c>([
            SELECT Primary_Contact__c, Sector__c, Branch_Territory__c, Record_Origin__c, Project_Name__c,
                Actual_Start_Date__c, Actual_End_Date__c, Scheduled_Start_Date__c
            FROM Project__c
            WHERE Id IN :records
        ]);
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Tool_TestDataFactory.createTestProject()).withLabel('Project')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_Project.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_Project.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_Project.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Name, contact, sector, territory, origin and actual dates are blank. The property sector wins over the
    // Account's; with no property, the Account sector fills in and there's no street to name it from.
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);

        Project__c withProperty = blankProject(parent.Id, property.Id);
        withProperty.Project_Status__c = 'In Progress';
        Project__c noProperty = blankProject(parent.Id, null);
        noProperty.Project_Status__c = 'Completed';
        List<Project__c> records = new List<Project__c>{ withProperty, noProperty };

        Test.startTest();
        insert records;
        Test.stopTest();

        Map<Id, Project__c> found = requery(records);
        Project__c foundWithProperty = found.get(withProperty.Id);
        Project__c foundNoProperty   = found.get(noProperty.Id);

        Assert.areEqual(parent.Account_Primary_Contact__c, foundWithProperty.Primary_Contact__c, 'A blank contact should copy from the Account primary contact');
        Assert.areEqual('Commercial',  foundWithProperty.Sector__c,           'A blank sector should copy from the property first');
        Assert.areEqual('Residential', foundNoProperty.Sector__c,             'With no property, the Account sector should fill in');
        Assert.areEqual('Tulsa',       foundWithProperty.Branch_Territory__c, 'A blank territory should copy from the Account');
        Assert.areEqual('KJHC Salesforce V2', foundWithProperty.Record_Origin__c, 'A blank Record Origin should default to KJHC Salesforce V2');

        Assert.areEqual(System.today(), foundWithProperty.Actual_Start_Date__c, 'An In Progress Project should stamp actual start = today');
        Assert.isNull(foundWithProperty.Actual_End_Date__c,                      'An In Progress Project should not stamp actual end');
        Assert.areEqual(System.today(), foundNoProperty.Actual_End_Date__c,     'A Completed Project should stamp actual end = today');

        Assert.areEqual(
            KJ_Tool_TestDataFactory.DEFAULT_STREET + ' - ' + foundWithProperty.Scheduled_Start_Date__c.format(),
            foundWithProperty.Project_Name__c,
            'A blank name should fill as {property street} - {scheduled start}'
        );
        Assert.isNull(foundNoProperty.Project_Name__c, 'With no property street, a blank name should stay blank');
    }

    // Every field the engine fills is already set, so nothing is overwritten.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        Contact projectContact = KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.COMMERCIAL, parent.Id);
        insert projectContact;

        Project__c record = blankProject(parent.Id, property.Id);
        record.Project_Name__c      = 'Spring Tune-Up';
        record.Primary_Contact__c   = projectContact.Id;
        record.Sector__c            = 'Other';
        record.Branch_Territory__c  = 'NWA';
        record.Record_Origin__c     = KJ_Model_Picklist.mapToString(KJ_Model_Picklist.RecordOrigin.FIELDPULSE);
        record.Project_Status__c    = 'Completed';
        record.Actual_Start_Date__c = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        record.Actual_End_Date__c   = KJ_Tool_TestDataFactory.DEFAULT_DATE.addDays(3);

        Test.startTest();
        insert record;
        Test.stopTest();

        Project__c found = requery(new List<Project__c>{ record }).get(record.Id);
        Assert.areEqual('Spring Tune-Up',  found.Project_Name__c,     'A provided name should not be replaced by {street} - {start date}');
        Assert.areEqual(projectContact.Id, found.Primary_Contact__c,  'A provided contact should be kept');
        Assert.areEqual('Other',           found.Sector__c,           'A provided sector should not be replaced by the property sector');
        Assert.areEqual('NWA',             found.Branch_Territory__c, 'A provided territory should be kept');
        Assert.areEqual('FieldPulse',      found.Record_Origin__c,    'A provided Record Origin should be kept');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE,             found.Actual_Start_Date__c, 'A provided actual start should be kept');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE.addDays(3), found.Actual_End_Date__c,   'A provided actual end should be kept');
    }

    // One partial-success insert: an end before its start is blocked, an end on the same day as its start is allowed.
    @isTest
    static void insert_DateValidation_MixedPath(){
        Account parent = insertAccountWithPrimaryContact();

        Project__c badSchedule = blankProject(parent.Id, null);
        badSchedule.Scheduled_End_Date__c = badSchedule.Scheduled_Start_Date__c.addDays(-1);
        Project__c badActual = blankProject(parent.Id, null);
        badActual.Actual_Start_Date__c = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        badActual.Actual_End_Date__c   = KJ_Tool_TestDataFactory.DEFAULT_DATE.addDays(-1);
        Project__c sameDay = blankProject(parent.Id, null);
        sameDay.Scheduled_End_Date__c = sameDay.Scheduled_Start_Date__c;
        sameDay.Actual_Start_Date__c  = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        sameDay.Actual_End_Date__c    = KJ_Tool_TestDataFactory.DEFAULT_DATE;

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(new List<Project__c>{ badSchedule, badActual, sameDay }, false);
        Test.stopTest();

        Assert.isFalse(results[0].isSuccess(), 'A scheduled end before the scheduled start should be blocked');
        Assert.areEqual('Scheduled end date is before scheduled start date.', results[0].getErrors()[0].getMessage(), 'The schedule error should name the scheduled dates');
        Assert.isFalse(results[1].isSuccess(), 'An actual end before the actual start should be blocked');
        Assert.areEqual('Actual end date is before actual start date.', results[1].getErrors()[0].getMessage(), 'The actual error should name the actual dates');
        Assert.isTrue(results[2].isSuccess(), 'An end on the same day as its start should be allowed');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void projectTrigger_BulkBatch_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        List<Project__c> records = new List<Project__c>();
        for(Integer i = 0; i < 200; i++){
            records.add(blankProject(parent.Id, property.Id));
        }

        Test.startTest();
        insert records;
        List<Project__c> changes = new List<Project__c>();
        for(Project__c record : records){
            changes.add(new Project__c(Id = record.Id, Project_Status__c = 'In Progress'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Project__c WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 Projects should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Project__c WHERE Id IN :records], 'All 200 Projects should have undeleted');
    }
}
