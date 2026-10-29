/*
*   File: KJ_Dispatch_Job_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the Job object end to end: KJ_Dispatch_JobTrigger,
*                KJ_Dispatch_Job routing, and the KJ_Engine_Job automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled from Project then Account, provided values kept, validation
*       Last Service Date           Account stamped on insert and update
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_Job_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static final Datetime START = KJ_Tool_TestDataFactory.DEFAULT_DATETIME;

    // Residential Account in Tulsa whose primary contact is set by the Contact trigger.
    private static Account insertAccountWithPrimaryContact(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount(KJ_Model_Picklist.Sector.RESIDENTIAL, null, null, null);
        record.Branch_Territory__c = 'Tulsa';
        insert record;
        insert KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.RESIDENTIAL, record.Id);
        return [SELECT Id, Account_Primary_Contact__c, Last_Service_Date__c FROM Account WHERE Id = :record.Id];
    }

    private static Customer_Property__c insertProperty(Id ownerAccountId){
        Customer_Property__c record = KJ_Tool_TestDataFactory.createTestCustomerProperty(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, ownerAccountId);
        insert record;
        return record;
    }

    private static Project__c insertProject(Id accountId, Id propertyId){
        Project__c record = KJ_Tool_TestDataFactory.createTestProject(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, accountId, null, null, propertyId);
        insert record;
        return record;
    }

    // Job with no contact, sector, service type or territory, so the engine's fill-in logic runs.
    private static Job__c blankJob(Id accountId, Id projectId, Id propertyId){
        Job__c record = KJ_Tool_TestDataFactory.createTestJob(KJ_Tool_TestDataFactory.DEFAULT_SECTOR, projectId, accountId, null, propertyId);
        record.Job_Sector__c        = null;
        record.Service_Type__c      = null;
        record.Branch_Territory__c  = null;
        return record;
    }

    private static Job__c completedJob(Id accountId, Id projectId, Id propertyId, Datetime actualEnd){
        Job__c record = blankJob(accountId, projectId, propertyId);
        record.Job_Status__c   = 'Completed';
        record.Actual_Start__c = actualEnd.addHours(-2);
        record.Actual_End__c   = actualEnd;
        return record;
    }

    private static Map<Id, Job__c> requery(List<Job__c> records){
        return new Map<Id, Job__c>([
            SELECT Primary_Contact__c, Job_Sector__c, Service_Type__c, Branch_Territory__c
            FROM Job__c
            WHERE Id IN :records
        ]);
    }

    private static Date lastServiceDate(Id accountId){
        return [SELECT Last_Service_Date__c FROM Account WHERE Id = :accountId].Last_Service_Date__c;
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Tool_TestDataFactory.createTestJob()).withLabel('Job')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_Job.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_Job.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_Job.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Contact, sector, service type and territory are blank. A fully filled Project wins; when the
    // Project is blank too, the Account fills in (service type has no Account fallback).
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);

        Contact projectContact = KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.COMMERCIAL, parent.Id);
        insert projectContact;
        Project__c filledProject = KJ_Tool_TestDataFactory.createTestProject(KJ_Model_Picklist.Sector.COMMERCIAL, parent.Id, projectContact.Id, null, property.Id);
        filledProject.Service_Type__c     = 'Install';
        filledProject.Branch_Territory__c = 'NWA';
        insert filledProject;

        // Blanked after insert, since the Project trigger fills these on insert
        Project__c blankProject = insertProject(parent.Id, property.Id);
        update new Project__c(Id = blankProject.Id, Primary_Contact__c = null, Sector__c = null, Service_Type__c = null, Branch_Territory__c = null);

        Job__c fromProject = blankJob(parent.Id, filledProject.Id, property.Id);
        Job__c fromAccount = blankJob(parent.Id, blankProject.Id, property.Id);
        List<Job__c> records = new List<Job__c>{ fromProject, fromAccount };

        Test.startTest();
        insert records;
        Test.stopTest();

        Map<Id, Job__c> found = requery(records);
        Job__c foundFromProject = found.get(fromProject.Id);
        Assert.areEqual(projectContact.Id, foundFromProject.Primary_Contact__c, 'A blank contact should copy from the Project first');
        Assert.areEqual('Commercial', foundFromProject.Job_Sector__c,           'A blank sector should copy from the Project first');
        Assert.areEqual('Install',    foundFromProject.Service_Type__c,         'A blank service type should copy from the Project');
        Assert.areEqual('NWA',        foundFromProject.Branch_Territory__c,     'A blank territory should copy from the Project first');

        Job__c foundFromAccount = found.get(fromAccount.Id);
        Assert.areEqual(parent.Account_Primary_Contact__c, foundFromAccount.Primary_Contact__c, 'With no Project contact, the Account primary contact should fill in');
        Assert.areEqual('Residential', foundFromAccount.Job_Sector__c,       'With no Project sector, the Account sector should fill in');
        Assert.isNull(foundFromAccount.Service_Type__c,                       'Service type has no Account fallback, so it should stay blank');
        Assert.areEqual('Tulsa',       foundFromAccount.Branch_Territory__c, 'With no Project territory, the Account territory should fill in');
    }

    // Every field the engine fills is already set, so nothing is overwritten by the Project or Account.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        Project__c project = insertProject(parent.Id, property.Id);

        Contact jobContact = KJ_Tool_TestDataFactory.createTestContact(KJ_Model_Picklist.Sector.RESIDENTIAL, parent.Id);
        insert jobContact;
        Job__c record = blankJob(parent.Id, project.Id, property.Id);
        record.Primary_Contact__c  = jobContact.Id;
        record.Job_Sector__c       = 'Other';
        record.Service_Type__c     = 'Diagnostic';
        record.Branch_Territory__c = 'NWA';

        Test.startTest();
        insert record;
        Test.stopTest();

        Job__c found = requery(new List<Job__c>{ record }).get(record.Id);
        Assert.areEqual(jobContact.Id, found.Primary_Contact__c,  'A provided contact should be kept');
        Assert.areEqual('Other',       found.Job_Sector__c,       'A provided sector should be kept');
        Assert.areEqual('Diagnostic',  found.Service_Type__c,     'A provided service type should be kept');
        Assert.areEqual('NWA',         found.Branch_Territory__c, 'A provided territory should be kept');
    }

    // One partial-success insert: each required parent and each time window is broken on its own record,
    // and only the valid Job goes through.
    @isTest
    static void insert_Validation_MixedPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        Project__c project = insertProject(parent.Id, property.Id);

        Job__c noAccount  = blankJob(null,      project.Id, property.Id);
        Job__c noProject  = blankJob(parent.Id, null,       property.Id);
        Job__c noProperty = blankJob(parent.Id, project.Id, null);
        Job__c badSchedule = blankJob(parent.Id, project.Id, property.Id);
        badSchedule.Scheduled_End__c = badSchedule.Scheduled_Start__c;
        Job__c badActual = blankJob(parent.Id, project.Id, property.Id);
        badActual.Actual_End__c = badActual.Actual_Start__c.addMinutes(-30);
        Job__c badTravel = blankJob(parent.Id, project.Id, property.Id);
        badTravel.Travel_End__c = badTravel.Travel_Start__c;
        Job__c valid = blankJob(parent.Id, project.Id, property.Id);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(
            new List<Job__c>{ noAccount, noProject, noProperty, badSchedule, badActual, badTravel, valid },
            false
        );
        Test.stopTest();

        List<String> expectedErrors = new List<String>{
            'No Parent Account. Parent Account required.',
            'No Parent Project. Parent Project required.',
            'No Customer Property. Customer Property required.',
            'Scheduled end is before (or the same as) scheduled start.',
            'Actual end is before (or the same as) actual start.',
            'Travel end is before (or the same as) Travel start.'
        };
        for(Integer i = 0; i < expectedErrors.size(); i++){
            Assert.isFalse(results[i].isSuccess(), 'Record ' + i + ' should be blocked: ' + expectedErrors[i]);
            Assert.areEqual(expectedErrors[i], results[i].getErrors()[0].getMessage(), 'Record ' + i + ' should report its own validation error');
        }
        Assert.isTrue(results[6].isSuccess(), 'A Job with every parent and valid time windows should insert');
    }


    //*-- Last Service Date -----------------------------------------------------------------------
    // Completed Jobs stamp the Account with their actual end date, only ever moving it later: on insert
    // (latest in the batch wins, whatever the order) and on update to Completed.
    @isTest
    static void markLastServiceDate_InsertAndUpdate_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        Project__c project = insertProject(parent.Id, property.Id);

        Job__c march    = completedJob(parent.Id, project.Id, property.Id, Datetime.newInstance(2026, 3, 1, 12, 0, 0));
        Job__c february = completedJob(parent.Id, project.Id, property.Id, Datetime.newInstance(2026, 2, 1, 12, 0, 0));
        Job__c open     = blankJob(parent.Id, project.Id, property.Id);

        Test.startTest();
        insert new List<Job__c>{ march, february, open };
        Date afterInsert = lastServiceDate(parent.Id);

        update new Job__c(
            Id              = open.Id,
            Job_Status__c   = 'Completed',
            Actual_Start__c = Datetime.newInstance(2026, 4, 1, 10, 0, 0),
            Actual_End__c   = Datetime.newInstance(2026, 4, 1, 12, 0, 0)
        );
        Date afterUpdate = lastServiceDate(parent.Id);

        update new Job__c(Id = february.Id, Field_Notes__c = 'Edited after completion.');
        Date afterOlderEdit = lastServiceDate(parent.Id);
        Test.stopTest();

        Assert.isNull(parent.Last_Service_Date__c, 'The Account should start with no last service date');
        Assert.areEqual(Date.newInstance(2026, 3, 1), afterInsert, 'The latest completed Job in the insert batch should set the date');
        Assert.areEqual(Date.newInstance(2026, 4, 1), afterUpdate, 'A Job updated to Completed with a later end should move the date');
        Assert.areEqual(Date.newInstance(2026, 4, 1), afterOlderEdit, 'Editing an older completed Job should not move the date back');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void jobTrigger_BulkBatch_HappyPath(){
        Account parent = insertAccountWithPrimaryContact();
        Customer_Property__c property = insertProperty(parent.Id);
        Project__c project = insertProject(parent.Id, property.Id);
        List<Job__c> records = new List<Job__c>();
        for(Integer i = 0; i < 200; i++){
            records.add(blankJob(parent.Id, project.Id, property.Id));
        }

        Test.startTest();
        insert records;
        List<Job__c> changes = new List<Job__c>();
        for(Job__c record : records){
            changes.add(new Job__c(Id = record.Id, Job_Status__c = 'Completed'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Job__c WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 Jobs should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Job__c WHERE Id IN :records], 'All 200 Jobs should have undeleted');
        Assert.areEqual(START.addHours(2).date(), lastServiceDate(parent.Id), 'Completing the batch should stamp the Account last service date');
    }
}
