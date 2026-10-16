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

        for(Contact record : (List<Contact>) ctx.newList){
            // Validation
            // Validate at least one of the following: Phone, Email, Mailing address
            if (record.Phone == null && record.Email && record.MailingAddress){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Contact does not have any of the following contact methods: Phone, Email, Mailing Address'
                );
                pkg.result.addException(newException);

                return pkg;
            }

            // Setting vars for use in operations
            Account parentAccount = [
                SELECT Account_Sector__c, Account_Primary_Contact__c 
                FROM Account 
                WHERE Id = :record.AccountId
            ];

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
                record.Contact_Sector__c = parentAccount.Account_Sector__c;
            }

            // Set as primary contact on Account if blank
            if (parentAccount.Account_Primary_Contact__c == null){
                parentAccount.Account_Primary_Contact__c = record.Id;
            }



        }
    }
    public static void onBeforeUpdate(KJ_Tool_Package pkg){}
    public static void onBeforeDelete(KJ_Tool_Package pkg){}

    public static void onAfterInsert(KJ_Tool_Package pkg){}
    public static void onAfterUpdate(KJ_Tool_Package pkg){}
    public static void onAfterDelete(KJ_Tool_Package pkg){}
    public static void onAfterUndelete(KJ_Tool_Package pkg){}    
}