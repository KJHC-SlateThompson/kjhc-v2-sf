/* 
*   File: KJ_Tool_TriggerContext.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/10/2026
*   Description: This class is built to structure and hold data as to the context of what happened in regards to a trigger

*/
public with sharing class KJ_Tool_TriggerContext {
    //*-- Member Variables ------------------------------------------------------------------------
    public Boolean isBefore     { get; private set; }
    public Boolean isAfter      { get; private set; }

    public Boolean isInsert     { get; private set; }
    public Boolean isUpdate     { get; private set; }
    public Boolean isDelete     { get; private set; }
    public Boolean isUndelete   { get; private set; }

    public List<SObject> newList    { get; private set; }
    public List<SObject> oldList    { get; private set; }
    public Map<Id, SObject> newMap  { get; private set; }
    public Map<Id, SObject> oldMap  { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Constructor and build methods
    public KJ_Tool_TriggerContext(){
        this.isBefore   = false;
        this.isAfter    = false;

        this.isInsert   = false;
        this.isUpdate   = false;
        this.isDelete   = false;
        this.isUndelete = false;

        this.newList    = new List<SObject>();
        this.oldList    = new List<SObject>();
        this.newMap     = new Map<Id, SObject>();
        this.oldMap     = new Map<Id, SObject>();
    }

    public static KJ_Tool_TriggerContext build(){
        if (!Trigger.isExecuting) { return null; }
        KJ_Tool_TriggerContext newContext = new KJ_Tool_TriggerContext();

        newContext.isBefore     = Trigger.isBefore      ?? newContext.isBefore;
        newContext.isAfter      = Trigger.isAfter       ?? newContext.isAfter;

        newContext.isInsert     = Trigger.isInsert      ?? newContext.isInsert;
        newContext.isUpdate     = Trigger.isUpdate      ?? newContext.isUpdate;
        newContext.isDelete     = Trigger.isDelete      ?? newContext.isDelete;
        newContext.isUndelete   = Trigger.isUndelete    ?? newContext.isUndelete;

        newContext.newList      = Trigger.new           ?? newContext.newList;
        newContext.oldList      = Trigger.old           ?? newContext.oldList;
        newContext.newMap       = Trigger.newMap        ?? newContext.newMap;
        newContext.oldMap       = Trigger.oldMap        ?? newContext.oldMap;

        return newContext;
    }

    // Returns whether specified field has changed on specified record
    public Boolean didFieldChange(Id targetRecordId, schema.SObjectField targetField){
        SObject newRecord = newMap.get(targetRecordId);
        SObject oldRecord = oldMap.get(targetRecordId);

        Boolean result = newRecord.get(targetField) != oldRecord.get(targetField);

        return result;
    }
    
    // Returns list of records that had their specified field changed
    public List<SObject> getChangedRecords(Schema.SObjectField targetField){
        List<SObject> changedRecords = new List<SObject>();

        for(SObject currentRecord : newList) {
            if (didFieldChange(currentRecord.Id, targetField)){
                changedRecords.add(currentRecord);
            }
        }

        return changedRecords;
    }

}