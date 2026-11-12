/* 
*   File: KJ_Engine_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class is built to hold the operations needed for the account object

*/
public with sharing class KJ_Engine_Account {

    //*-- Constants -------------------------------------------------------------------------------
    private static final String RELATED_RECORDS_ERROR = 'This Account has related records. Archive it instead of deleting it.';

    //*-- Member Variables ------------------------------------------------------------------------
    // Accounts found with related records in before delete. The block is applied in after delete, the
    // only event where MasterRecordId is set, so merge losers (whose children move to the master) can go.
    private static Set<Id> accountsWithRelatedRecords = new Set<Id>();

    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        for(Account record : (List<Account>) ctx.newList){
            // Customer Since: set the first time the Account becomes a Current Customer
            KJ_Model_Picklist.AccountStatus recordAccountStatus = KJ_Model_Picklist.mapToAccountStatus(record.Account_Status__c);
            if(
                recordAccountStatus == KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER &&
                record.Customer_Since__c == null
                ){
                record.Customer_Since__c = System.today();
            }

            // Setting Default Record Origin
            if(record.Record_Origin__c == null || record.Record_Origin__c == ''){
                record.Record_Origin__c = 'KJHC Salesforce V2';
            }

            // Origin Created Date: the insert date when no origin system provided one
            if(record.Origin_Created_Date__c == null){
                record.Origin_Created_Date__c = System.today();
            }

            // Setting Billing Address from Service Address if blank
            // (compound address fields are read-only and null in before triggers, so use the component fields)
            if(String.isBlank(record.BillingStreet) && String.isNotBlank(record.Service_Address__Street__s)){
                record.BillingStreet     = record.Service_Address__Street__s;
                record.BillingCity       = record.Service_Address__City__s;
                record.BillingStateCode   = record.Service_Address__StateCode__s;
                record.BillingPostalCode  = record.Service_Address__PostalCode__s;
                record.BillingCountryCode = record.Service_Address__CountryCode__s;
            }

            // Setting Default Service Territory
            if(record.Branch_Territory__c == null){
                switch on record.Service_Address__StateCode__s {
                    when 'AR'{ record.Branch_Territory__c = 'NWA'; }
                    when 'OK'{ record.Branch_Territory__c = 'Tulsa'; }
                }
            }
        } 
    }
    public static void onBeforeUpdate(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        for(Account record : (List<Account>) ctx.newList){
            Account oldRecord = (Account) ctx.oldMap.get(record.Id);
            // Customer Since: set the first time the Account becomes a Current Customer
            KJ_Model_Picklist.AccountStatus recordAccountStatus = KJ_Model_Picklist.mapToAccountStatus(record.Account_Status__c);
            if(
                recordAccountStatus == KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER &&
                record.Account_Status__c != oldRecord.Account_Status__c &&
                record.Customer_Since__c == null
                ){
                record.Customer_Since__c = System.today();
            }
        } 
        
    }
    public static void onBeforeDelete(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Note Accounts that still have related records; onAfterDelete blocks them unless they lost a merge.
        // Customer Properties are already blocked by their Restrict lookup.
        for(Account found : [
            SELECT Id,
                (SELECT Id FROM Contacts LIMIT 1),
                (SELECT Id FROM Jobs__r LIMIT 1),
                (SELECT Id FROM Memberships__r LIMIT 1),
                (SELECT Id FROM Projects__r LIMIT 1)
            FROM Account
            WHERE Id IN :ctx.oldMap.keySet()
        ]){
            if(
                !found.Contacts.isEmpty() ||
                !found.Jobs__r.isEmpty() ||
                !found.Memberships__r.isEmpty() ||
                !found.Projects__r.isEmpty()
            ){
                accountsWithRelatedRecords.add(found.Id);
            }
        }
    }

    public static void onAfterInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Origin Record Id: the Salesforce Id when no origin system provided one (the Id only exists after insert)
        Map<Id, SObject> updates = new Map<Id, SObject>();
        for(Account record : (List<Account>) ctx.newList){
            if(String.isBlank(record.Origin_Record_Id__c)){
                updates.put(record.Id, new Account(Id = record.Id, Origin_Record_Id__c = record.Id));
            }
        }
        if(!updates.isEmpty()){
            update updates.values();
        }
    }
    public static void onAfterUpdate(KJ_Tool_Package pkg){}
    public static void onAfterDelete(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Block the delete of Accounts with related records, except merge losers (MasterRecordId set)
        for(Account record : (List<Account>) ctx.oldList){
            if(accountsWithRelatedRecords.remove(record.Id) && record.MasterRecordId == null){
                record.addError(RELATED_RECORDS_ERROR);
            }
        }
    }
    public static void onAfterUndelete(KJ_Tool_Package pkg){}
    
    // Called methods
    public static KJ_Tool_Package archive(KJ_Tool_Package pkg){
        List<KJ_Model_Account> accounts = new List<KJ_Model_Account>();

        for(KJ_Tool_DataEntry entry : pkg.dataBundle.entries){
            if (!(entry.value instanceof KJ_Model_Account)){
                 
            }
            accounts.add((KJ_Model_Account) entry.value);
        }

        if (accounts.isEmpty()) {
            KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                KJ_Tool_Exception.Code.MISSING_DATA,
                'archive received no Account entries.'
            );
            pkg.result.addException(newException);
            return pkg;
        }

        List<Account> toUpdate = new List<Account>();
        for(KJ_Model_Account account : accounts){
            account.setArchived(True);
            toUpdate.add(account.toRecord());
        }
        update toUpdate;

        return pkg;
    }
}
