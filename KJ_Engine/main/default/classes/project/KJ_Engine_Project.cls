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
            SELECT Account_Sector__c, Account_Primary_Contact__c, Branch_Territory__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
        Map<Id, Contact> primaryContacts = new Map<Id, Contact>([
            SELECT Id
            FROM Contact
            WHERE Id IN :primaryContactIds
        ]);
        Map<Id, Customer_Property__c> projectProperties = new Map<Id, Customer_Property__c>([
            SELECT Property_Sector__c, Property_Address__Street__s
            FROM Customer_Property__c
            Where Id IN :projectPropertyIds
        ]);

        for(Project__c record : (List<Project__c>) ctx.newList){
            // Validation
            if(
                record.Scheduled_Start_Date__c != null &&
                record.Scheduled_End_Date__c != null &&
                record.Scheduled_End_Date__c < record.Scheduled_Start_Date__c
            ){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Scheduled end date is before scheduled start date.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }
            if(
                record.Actual_Start_Date__c != null &&
                record.Actual_End_Date__c != null &&
                record.Actual_End_Date__c < record.Actual_Start_Date__c
            ){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Actual end date is before actual start date.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }

            // Related Objects (null when not linked)
            Account parentAccount = parentAccounts.get(record.Parent_Account__c);
            Contact primaryContact = primaryContacts.get(record.Primary_Contact__c);
            Customer_Property__c projectProperty = projectProperties.get(record.Customer_Property__c);

            // Fill in blanks from related records
            // Primary Contact
            if(record.Primary_Contact__c == null){
                if(parentAccount?.Account_Primary_Contact__c != null){
                    record.Primary_Contact__c = parentAccount.Account_Primary_Contact__c;
                }
            }

            // Sector
            if(record.Sector__c == null){
                if(projectProperty?.Property_Sector__c != null){
                    record.Sector__c = projectProperty.Property_Sector__c;
                }
                else if(parentAccount?.Account_Sector__c != null){
                    record.Sector__c = parentAccount.Account_Sector__c;
                }
            }

            // Branch Territory
            if(record.Branch_Territory__c == null){
                if(parentAccount?.Branch_Territory__c != null){
                    record.Branch_Territory__c = parentAccount.Branch_Territory__c;
                }
            }

            


            // Record Origin
            if(String.isBlank(record.Record_Origin__c)){
                record.Record_Origin__c = 'KJHC Salesforce V2';
            }

            // Stamp times from status
            if(record.Project_Status__c == 'In Progress' && record.Actual_Start_Date__c == null){
                record.Actual_Start_Date__c = System.today();
            }
            if(record.Project_Status__c == 'Completed' && record.Actual_End_Date__c == null){
                record.Actual_End_Date__c = System.today();
            }

            // Name: {street address} - {start date}
            if(String.isNotBlank(projectProperty?.Property_Address__Street__s) && record.Scheduled_Start_Date__c != null){
                record.Project_Name__c = projectProperty.Property_Address__Street__s + ' - ' + record.Scheduled_Start_Date__c.format();
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