/*
*   File: KJ_Dispatch_Membership_Test.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/29/2026
*   Description: This class tests the Membership object end to end: KJ_Dispatch_MembershipTrigger,
*                KJ_Dispatch_Membership routing, and the KJ_Engine_Membership automations behind it.
*                Each test runs one mixed batch through a single operation, like real data arrives.
*
*   Index:
*       Helpers
*       Routing                     receive() entry point
*       Insert                      blanks filled, provided values kept, date validation
*       Bulk                        200-record trigger batch
*/
@isTest
public with sharing class KJ_Dispatch_Membership_Test {

    //*-- Helpers ---------------------------------------------------------------------------------
    private static Account insertAccount(){
        Account record = KJ_Tool_TestDataFactory.createTestAccount();
        insert record;
        return record;
    }

    private static Membership__c membershipWithDates(Id memberAccountId, Date startDate, Date expirationDate){
        Membership__c record = KJ_Tool_TestDataFactory.createTestMembership(memberAccountId);
        record.Membership_Start_Date__c      = startDate;
        record.Membership_Expiration_Date__c = expirationDate;
        return record;
    }

    private static Map<Id, Membership__c> requery(List<Membership__c> records){
        return new Map<Id, Membership__c>([
            SELECT Membership_Start_Date__c, Membership_Expiration_Date__c
            FROM Membership__c
            WHERE Id IN :records
        ]);
    }


    //*-- Routing ---------------------------------------------------------------------------------
    // receive() is trigger-only: a null package and a package with no trigger context are both rejected.
    @isTest
    static void receive_InvalidPackages_FailPath(){
        KJ_Tool_DataBundle bundle = KJ_Tool_DataBundle.build(
            KJ_Tool_DataEntry.build(KJ_Tool_TestDataFactory.createTestMembership()).withLabel('Membership')
        );

        KJ_Tool_Package nullPkg      = KJ_Dispatch_Membership.receive(null);
        KJ_Tool_Package noContextPkg = KJ_Dispatch_Membership.receive(KJ_Tool_Package.build(bundle));

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
        KJ_Tool_Package pkg = KJ_Dispatch_Membership.receive(
            KJ_Tool_Package.build().withTriggerContext(new KJ_Tool_TriggerContext())
        );

        Assert.isTrue(pkg.result.isSuccess, 'An empty trigger context should route without failing');
        Assert.isTrue(pkg.result.exceptions.isEmpty(), 'An empty trigger context should raise no exceptions');
    }


    //*-- Insert ----------------------------------------------------------------------------------
    // Blank dates fill in: start defaults to today, expiration to one year after whatever the start is.
    @isTest
    static void insert_FillsBlanks_HappyPath(){
        Account member = insertAccount();
        Membership__c noDates   = membershipWithDates(member.Id, null, null);
        Membership__c startOnly = membershipWithDates(member.Id, KJ_Tool_TestDataFactory.DEFAULT_DATE, null);
        List<Membership__c> records = new List<Membership__c>{ noDates, startOnly };

        Test.startTest();
        insert records;
        Test.stopTest();

        Map<Id, Membership__c> found = requery(records);
        Assert.areEqual(System.today(),              found.get(noDates.Id).Membership_Start_Date__c,      'A blank start should default to today');
        Assert.areEqual(System.today().addYears(1),  found.get(noDates.Id).Membership_Expiration_Date__c, 'A blank expiration should default to one year after a defaulted start');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE.addYears(1), found.get(startOnly.Id).Membership_Expiration_Date__c, 'A blank expiration should default to one year after a provided start');
    }

    // Provided dates are kept, even when the term isn't exactly one year.
    @isTest
    static void insert_KeepsProvidedValues_HappyPath(){
        Account member = insertAccount();
        Membership__c record = membershipWithDates(member.Id, KJ_Tool_TestDataFactory.DEFAULT_DATE, KJ_Tool_TestDataFactory.DEFAULT_DATE.addMonths(6));

        Test.startTest();
        insert record;
        Test.stopTest();

        Membership__c found = requery(new List<Membership__c>{ record }).get(record.Id);
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE,              found.Membership_Start_Date__c,      'A provided start should be kept');
        Assert.areEqual(KJ_Tool_TestDataFactory.DEFAULT_DATE.addMonths(6), found.Membership_Expiration_Date__c, 'A provided expiration should be kept');
    }

    // One partial-success insert: an expiration on or before the start is blocked, a valid term goes through.
    @isTest
    static void insert_DateValidation_MixedPath(){
        Account member = insertAccount();
        Date start = KJ_Tool_TestDataFactory.DEFAULT_DATE;
        Membership__c sameDay  = membershipWithDates(member.Id, start, start);
        Membership__c backward = membershipWithDates(member.Id, start, start.addDays(-1));
        Membership__c valid    = membershipWithDates(member.Id, start, start.addDays(1));

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(new List<Membership__c>{ sameDay, backward, valid }, false);
        Test.stopTest();

        String expected = 'Membership expiration is before (or the same as) membership start.';
        Assert.isFalse(results[0].isSuccess(), 'An expiration on the start date should be blocked');
        Assert.areEqual(expected, results[0].getErrors()[0].getMessage(), 'The same-day error should explain the date rule');
        Assert.isFalse(results[1].isSuccess(), 'An expiration before the start date should be blocked');
        Assert.areEqual(expected, results[1].getErrors()[0].getMessage(), 'The backward error should explain the date rule');
        Assert.isTrue(results[2].isSuccess(), 'An expiration after the start date should be allowed');
    }


    //*-- Bulk ------------------------------------------------------------------------------------
    // A full 200-record trigger batch through insert, update, delete and undelete stays inside governor limits.
    @isTest
    static void membershipTrigger_BulkBatch_HappyPath(){
        Account member = insertAccount();
        List<Membership__c> records = new List<Membership__c>();
        for(Integer i = 0; i < 200; i++){
            records.add(membershipWithDates(member.Id, null, null));
        }

        Test.startTest();
        insert records;
        List<Membership__c> changes = new List<Membership__c>();
        for(Membership__c record : records){
            changes.add(new Membership__c(Id = record.Id, Membership_Notes__c = 'Bulk update.'));
        }
        update changes;
        delete records;
        Integer countAfterDelete = [SELECT COUNT() FROM Membership__c WHERE Id IN :records];
        undelete records;
        Test.stopTest();

        Assert.areEqual(0, countAfterDelete, 'All 200 memberships should have deleted');
        Assert.areEqual(200, [SELECT COUNT() FROM Membership__c WHERE Id IN :records], 'All 200 memberships should have undeleted');
    }
}
