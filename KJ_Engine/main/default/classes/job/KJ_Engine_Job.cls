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

        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> parentProjectIds = new Set<Id>();
        for(Job__c record : (List<Job__c>) ctx.newList){
            parentAccountIds.add(record.Parent_Account__c);
            parentProjectIds.add(record.Parent_Project__c);
        }

        // Related Objects
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Account_Sector__c, Account_Primary_Contact__c, Branch_Territory__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
        Map<Id, Project__c> parentProjects = new Map<Id, Project__c>([
            SELECT Primary_Contact__c, Sector__c, Service_Type__c, Branch_Territory__c
            FROM Project__c
            WHERE Id IN :parentProjectIds
        ]);

        for(Job__c record : (List<Job__c>) ctx.newList){
            // Validation
            if(record.Parent_Account__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Parent Account. Parent Account required.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }
            if(record.Parent_Project__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Parent Project. Parent Project required.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }
            if(record.Customer_Property__c == null){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'No Customer Property. Customer Property required.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }

            if(record.Scheduled_End__c <= record.Scheduled_Start__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Scheduled end is before (or the same as) scheduled start.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }
            if(record.Actual_End__c <= record.Actual_Start__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Actual end is before (or the same as) actual start.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }
            if(record.Travel_End__c <= record.Travel_Start__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Travel end is before (or the same as) Travel start.',
                    record
                );
                pkg.result.addException(newException);

                continue;
            }

            // Related Objects (null when not linked)
            Account parentAccount = parentAccounts.get(record.Parent_Account__c);
            Project__c parentProject = parentProjects.get(record.Parent_Project__c);

            // Fill in Primary Contact if blank
            if(record.Primary_Contact__c == null){
                if(parentProject?.Primary_Contact__c != null){
                    record.Primary_Contact__c = parentProject.Primary_Contact__c;
                }
                else if(parentAccount?.Account_Primary_Contact__c != null){
                    record.Primary_Contact__c = parentAccount.Account_Primary_Contact__c;
                }
            }

            // fill in Sector if blank
            if(record.Job_Sector__c == null){
                if(parentProject?.Sector__c != null){
                    record.Job_Sector__c = parentProject.Sector__c;
                }
                else if(parentAccount?.Account_Sector__c != null){
                    record.Job_Sector__c = parentAccount.Account_Sector__c;
                }
            }

            // fill in service type if blank
            if(record.Service_Type__c == null){
                if(parentProject?.Service_Type__c != null){
                    record.Service_Type__c = parentProject.Service_Type__c;
                }
            }

            // fill in service territory if blank
            if(record.Branch_Territory__c == null){
                if(parentProject?.Branch_Territory__c != null){
                    record.Branch_Territory__c = parentProject.Branch_Territory__c;
                }
                else if(parentAccount?.Branch_Territory__c != null){
                    record.Branch_Territory__c = parentAccount.Branch_Territory__c;
                }
            }
        }
    }
    public static void onBeforeUpdate(KJ_Tool_Package pkg){}
    public static void onBeforeDelete(KJ_Tool_Package pkg){}

    public static void onAfterInsert(KJ_Tool_Package pkg){
        markLastServiceDate((List<Job__c>) pkg.triggerContext.newList);
    }
    public static void onAfterUpdate(KJ_Tool_Package pkg){
        markLastServiceDate((List<Job__c>) pkg.triggerContext.newList);
    }
    public static void onAfterDelete(KJ_Tool_Package pkg){
        // disconnect related objects
    }
    public static void onAfterUndelete(KJ_Tool_Package pkg){}

    //*-- Private Methods -------------------------------------------------------------------------
    // Mark last service date on account (if job is done and is most recent)
    private static void markLastServiceDate(List<Job__c> jobs){
        // Gather parent Ids
        Set<Id> parentAccountIds = new Set<Id>();
        for(Job__c record : jobs){
            if(record.Job_Status__c == 'Completed' && record.Actual_End__c != null){
                parentAccountIds.add(record.Parent_Account__c);
            }
        }
        if(parentAccountIds.isEmpty()){
            return;
        }

        // Related Objects
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Last_Service_Date__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        for(Job__c record : jobs){
            Account parentAccount = parentAccounts.get(record.Parent_Account__c);
            if(parentAccount == null || record.Job_Status__c != 'Completed' || record.Actual_End__c == null){
                continue;
            }

            Date serviceDate = record.Actual_End__c.date();
            if(parentAccount.Last_Service_Date__c == null || serviceDate > parentAccount.Last_Service_Date__c){
                parentAccount.Last_Service_Date__c = serviceDate;
                accountsToUpdate.put(parentAccount.Id, parentAccount);
            }
        }

        update accountsToUpdate.values();
    }
}