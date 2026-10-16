/* 
*   File: KJ_Engine_CustomerProperty.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to hold the operations needed for the CustomerProperty object

*/
public with sharing class KJ_Engine_CustomerProperty {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        for(Customer_Property__c record : (List<Customer_Property__c>) ctx.newList){
            Account parentAccount = [
                SELECT Account_Sector__c, property_Address__c
                FROM Account 
                WHERE Id = :record.AccountId
            ];
    
            // copy sector from account if blank
            if (record.Property_Sector__c == null && record.AccountId != null){
                record.Property_Sector__c = parentAccount.Account_Sector__c;
            }

            // copy address from account if blank
            if (record.Property_Address__c == null && parentAccount.Service_Address__c != null){
                record.Property_Address__Street__c     = parentAccount.Service_Address__Street__s;
                record.Property_Address__City__c       = parentAccount.Service_Address__City__s;
                record.Property_Address__State__c      = parentAccount.Service_Address__State__s;
                record.Property_Address__PostalCode__c = parentAccount.Service_Address__PostalCode__s;
                record.Property_Address__Country__c    = parentAccount.Service_Address__Country__s;
            }

            // Default name if blank
            if (record.name == null){
                record.name = record.Property_Address__Street__c;
            }
        }
    }
    public static void onBeforeUpdate(KJ_Tool_Package pkg){}
    public static void onBeforeDelete(KJ_Tool_Package pkg){}

    public static void onAfterInsert(KJ_Tool_Package pkg){}
    public static void onAfterUpdate(KJ_Tool_Package pkg){}
    public static void onAfterDelete(KJ_Tool_Package pkg){
        // disconnect related objects
    }
    public static void onAfterUndelete(KJ_Tool_Package pkg){}    
}