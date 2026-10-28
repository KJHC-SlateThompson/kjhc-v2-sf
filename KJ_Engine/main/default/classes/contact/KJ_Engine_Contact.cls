/* 
*   File: KJ_Engine_Contact.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/1/2026
*   Description: This class is built to hold the operations needed for the Contact object

*/
public with sharing class KJ_Engine_Contact {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        for(Contact record : (List<Contact>) ctx.newList){
            parentAccountIds.add(record.AccountId);
        }

        // Related Objects
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Account_Sector__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);

        for(Contact record : (List<Contact>) ctx.newList){
            // Validation
            // Validate at least one of the following: Phone, Email, Mailing address
            // (compound address fields are read-only and null in before triggers, so use the component fields)
            if (record.Phone == null && record.Email == null && String.isBlank(record.MailingStreet)){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Contact does not have any of the following contact methods: Phone, Email, Mailing Address',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }

            // Setting vars for use in operations
            Account parentAccount = parentAccounts.get(record.AccountId);

            // Default contact method preference if only one is available
            if (record.Contact_Method_Preference__c == null &&
                !(record.Phone == null && record.Email == null) &&
                !(record.Phone != null && record.Email != null)
            ){
                if(record.Phone != null){
                    record.Contact_Method_Preference__c = 'Phone';
                }
                if(record.Email != null){
                    record.Contact_Method_Preference__c = 'Email';
                }
            }

            // copy sector from account if blank
            if (record.Contact_Sector__c == null && record.AccountId != null){
                record.Contact_Sector__c = parentAccount?.Account_Sector__c;
            }
        }
    }
    public static void onBeforeUpdate(KJ_Tool_Package pkg){}
    public static void onBeforeDelete(KJ_Tool_Package pkg){}

    public static void onAfterInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        for(Contact record : (List<Contact>) ctx.newList){
            parentAccountIds.add(record.AccountId);
        }

        // Related Objects (only Accounts still missing a primary contact)
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Account_Primary_Contact__c
            FROM Account
            WHERE Id IN :parentAccountIds AND Account_Primary_Contact__c = null
        ]);

        // Set as primary contact on Account if blank (first Contact in the batch wins)
        for(Contact record : (List<Contact>) ctx.newList){
            Account parentAccount = parentAccounts.get(record.AccountId);
            if (parentAccount != null && parentAccount.Account_Primary_Contact__c == null){
                parentAccount.Account_Primary_Contact__c = record.Id;
            }
        }

        update parentAccounts.values();
    }
    public static void onAfterUpdate(KJ_Tool_Package pkg){}
    public static void onAfterDelete(KJ_Tool_Package pkg){}
    public static void onAfterUndelete(KJ_Tool_Package pkg){}    
}