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

        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        for(Customer_Property__c record : (List<Customer_Property__c>) ctx.newList){
            parentAccountIds.add(record.Property_Owner_Account__c);
        }

        // Related Objects
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Account_Sector__c, Service_Address__Street__s, Service_Address__City__s,
                Service_Address__StateCode__s, Service_Address__PostalCode__s, Service_Address__CountryCode__s
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);

        for(Customer_Property__c record : (List<Customer_Property__c>) ctx.newList){
            // Related Objects (null when not linked)
            Account parentAccount = parentAccounts.get(record.Property_Owner_Account__c);

            // copy sector from account if blank
            if (record.Property_Sector__c == null && record.Property_Owner_Account__c != null){
                record.Property_Sector__c = parentAccount?.Account_Sector__c;
            }

            // copy address from account if blank
            // (compound address fields are read-only and null in before triggers, so use the component fields)
            if (String.isBlank(record.Property_Address__Street__s) && String.isNotBlank(parentAccount?.Service_Address__Street__s)){
                record.Property_Address__Street__s      = parentAccount.Service_Address__Street__s;
                record.Property_Address__City__s        = parentAccount.Service_Address__City__s;
                record.Property_Address__StateCode__s   = parentAccount.Service_Address__StateCode__s;
                record.Property_Address__PostalCode__s  = parentAccount.Service_Address__PostalCode__s;
                record.Property_Address__CountryCode__s = parentAccount.Service_Address__CountryCode__s;
            }

            // Default name if blank
            if (record.Name == null){
                record.Name = record.Property_Address__Street__s;
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