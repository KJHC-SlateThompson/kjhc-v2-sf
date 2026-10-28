/* 
*   File: KJ_Engine_Membership.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to hold the operations needed for the Membership object

*/
public with sharing class KJ_Engine_Membership {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        for(Membership__c record : (List<Membership__c>) ctx.newList){
            // Default start date to today if blank
            if(record.Membership_Start_Date__c == null){
                record.Membership_Start_Date__c = Date.today();
            }

            // Default expiration to 1 year after start if blank
            if(record.Membership_Expiration_Date__c == null){
                record.Membership_Expiration_Date__c = record.Membership_Start_Date__c.addYears(1);
            }

            // Validation
            if(record.Membership_Expiration_Date__c <= record.Membership_Start_Date__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Membership expiration is before (or the same as) membership start.',
                    record
                );
                pkg.result.addException(newException);

                continue;
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