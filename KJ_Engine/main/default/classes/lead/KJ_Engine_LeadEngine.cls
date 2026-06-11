/* 
*   File: KJ_Engine_LeadEngine.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 6/10/2026
*   Description: This class is built to hold the operations needed for the lead object

*/
public with sharing class KJ_Engine_LeadEngine {
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        List<Lead> newLeads = (List<Lead>) pkg.triggerContext.newList;

        for (Lead lead : newLeads){

        }
    }

    public static void onBeforeUpdate(KJ_Tool_Package pkg){
        List<Lead> newLeads = (List<Lead>) pkg.triggerContext.newList;
        Map<Id, Lead> oldLeads = (Map<Id, Lead>) pkg.triggerContext.oldMap;

        for (Lead lead : newLeads){
            
        }
    }
}