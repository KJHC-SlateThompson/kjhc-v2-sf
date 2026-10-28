/*
*   File: KJ_Engine_HvacUnit.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to hold the operations needed for the HVAC Unit object

*/
public with sharing class KJ_Engine_HvacUnit {
    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        // Gather parent Ids
        Set<Id> unitPropertyIds = new Set<Id>();
        Set<Id> unitMembershipIds = new Set<Id>();
        for(HVAC_Unit__c record : (List<HVAC_Unit__c>) ctx.newList){
            unitPropertyIds.add(record.Customer_Property__c);
            unitMembershipIds.add(record.Membership__c);
        }

        // Related Objects
        Map<Id, Customer_Property__c> unitProperties = new Map<Id, Customer_Property__c>([
            SELECT Property_Owner_Account__c
            FROM Customer_Property__c
            WHERE Id IN :unitPropertyIds
        ]);
        Map<Id, Membership__c> unitMemberships = new Map<Id, Membership__c>([
            SELECT Member_Account__c
            FROM Membership__c
            WHERE Id IN :unitMembershipIds
        ]);

        for(HVAC_Unit__c record : (List<HVAC_Unit__c>) ctx.newList){
            // Related Objects (null when not linked)
            Customer_Property__c unitProperty = unitProperties.get(record.Customer_Property__c);
            Membership__c unitMembership = unitMemberships.get(record.Membership__c);

            // Validation
            if(record.Membership__c != null && unitMembership?.Member_Account__c != unitProperty?.Property_Owner_Account__c){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.VALIDATION_ERROR,
                    'Membership account does not match the unit\'s property owner account.',
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
    public static void onAfterDelete(KJ_Tool_Package pkg){}
    public static void onAfterUndelete(KJ_Tool_Package pkg){}
}