/* 
*   File: KJ_Engine_Project.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to hold the operations needed for the Project object

*/
public with sharing class KJ_Engine_Project {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> primaryContactIds = new Set<Id>();
        Set<Id> projectPropertyIds = new Set<Id>();
        for(Project__c record : (List<Project__c>) ctx.newList){
            parentAccountIds.add(record.Parent_Account__c);
            primaryContactIds.add(record.Primary_Contact__c);
            projectPropertyIds.add(record.Customer_Property__c);
        }

        // Related Objects
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Account_Sector__c, Property_Address__c, Primary_Contacy
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
        Map<Id, Contact> primaryContacts = new Map<Id, Contact>([
            SELECT
            FROM Contact
            WHERE Id IN :primaryContactIds
        ]);
        Map<Id, Customer_Property__c> projectProperties = new Map<Id, Customer_Property__c>([
            SELECT
            FROM Customer_Property__c
            Where Id IN :projectPropertyIds
        ]);

        for(Project__c record : (List<Project__c>) ctx.newList){
            // Related Objects (null when not linked)
            Account parentAccount = parentAccounts.get(record.Parent_Account__c);
            Contact primaryContact = primaryContacts.get(record.Primary_Contact__c);
            Customer_Property__c projectProperty = projectProperties.get(record.Customer_Property__c);

            if ()
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