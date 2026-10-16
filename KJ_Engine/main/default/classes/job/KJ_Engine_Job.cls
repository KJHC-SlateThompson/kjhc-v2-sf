/* 
*   File: KJ_Engine_Job.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to hold the operations needed for the Job object

*/
public with sharing class KJ_Engine_Job {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        for(Jobs__c record : (List<Job__c>) ctx.newList){
            // Validation
            if(record.Parent_Account__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Parent Account. Parent Account required. Entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }
            if(record.Parent_Project__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Parent Project. Parent Project required. Entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }
            if(record.Customer_Property__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Customer Property. Customer Property required. Entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }

            if(record.Scheduled_Start__c <= record.Scheduled_End__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Scheduled end is before (or the same as) scheduled start. entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }
            if(record.Actual_Start__c <= record.Actual_End__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Actual end is before (or the same as) actual start. entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }
            if(record.Travel_Start__c <= record.Travel_End__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Travel end is before (or the same as) Travel start. entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }

            // Related Objects
            Account parentAccount = [
                SELECT Account_Sector__c, Property_Address__c, Primary_Contacy
                FROM Account 
                WHERE Id = :record.Parent_Account__c
            ];
            Project__c parentProject = [
                SELECT Primary_Contact__c, Service_Type__c
                FROM Project__c 
                WHERE Id = :record.Parent_Project__c
            ];
            Contact primaryContact = [
                SELECT 
                FROM Contact
                WHERE Id = :record.Primary_Contact__c
            ];
            Customer_Property__c jobProperty = [
                SELECT
                FROM Customer_Property__c
                Where Id = :record.Customer_Property__c
            ];

            // Fill in Primary Contact if blank
            if(record.Primary_Contact__c == null){
                if(parentProject.Primary_Contact__c != null){
                    record.Primary_Contact__c = parentProject.Primary_Contact__c;
                }
                else if(parentAccount.Primary_Contact__c !- null){
                    record.Primary_Contact__c = parentAccount.Primary_Contact__c;
                }
            }

            // fill in Sector if blank
            if(record.Sector__c == null){
                if(parentProject.Sector__c != null){
                    record.Sector__c = parentProject.Sector__c;
                }
                else if(parentAccount.Sector__c != null){
                    record.Sector__c = parentAccount.Sector__c;
                }
            }

            // fill in service type if blank
            if(record.Service_Type__c == null){
                if(parentProject.Service_Type__c != null){
                    record.Service_Type__c = parentProject.Service_Type__c;
                }
            }

            // fill in service territory if blank
            if(record.Service_Territory__c == null){
                if(parentProject.Service_Territory__c != null){
                    record.Service_Territory__c = parentProject.Service_Territory__c;
                }
                else if(parentAccount.Service_Territory__c != null){
                    record.Service_Territory__c = parentAccount.Service_Territory__c;
                }
            }
        
            // Mark last service date on account (if job is done and is most recent)
            if(record.Job_Status__c == 'Completed' && record.Actual_End__c != null){
                if(record.Actual_End__c > parentAccount.Last_Service_Date__c){
                    parentAccount.Last_Service_Date__c = record.Actual_End__c;
                }
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