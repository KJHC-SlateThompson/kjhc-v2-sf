/* 
*   File: KJ_Tool_Origin.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/13/2026
*   Description: This class acts as the base layer to describe the origin of an entity within the system

*/
public with sharing class KJ_Tool_Origin {
    //*-- Constants -------------------------------------------------------------------------------
    public enum SourceType{
        UNSPECIFIED,
        APEX,
        RECORD
    }

    //*-- Member Variables ------------------------------------------------------------------------
    public SourceType   sourceType    { get; private set; }

    public String       fileName      { get; private set; }
    public String       className     { get; private set; }
    public String       methodName    { get; private set; }

    public String       objectName    { get; private set; }
    public Id           recordId      { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Constructor and build methods
    public KJ_Tool_Origin(){
        this.sourceType = KJ_Tool_Origin.SourceType.UNSPECIFIED;
        this.filename   = '';
        this.className  = '';
        this.methodName = '';
        this.objectName = '';
    }
    private static KJ_Tool_Origin build(SourceType newSourceType, String newFileName, String newClassName, String newMethodName, String newObjectName, String newRecordId){
        KJ_Tool_Origin newOrigin = new KJ_Tool_Origin();

        newOrigin.sourceType    = newSourceType ?? newOrigin.sourceType;
        newOrigin.fileName      = newFileName   ?? newOrigin.fileName;
        newOrigin.className     = newClassName  ?? newOrigin.className;
        newOrigin.methodName    = newMethodName ?? newOrigin.methodName;
        newOrigin.recordId      = newRecordId   ?? newOrigin.recordId;
        newOrigin.objectName    = newObjectName ?? newOrigin.objectName;
        
        return newOrigin;
    }

    public static KJ_Tool_Origin fromApex(String fileName, String className, String methodName){
        KJ_Tool_Origin newOrigin = KJ_Tool_Origin.build(
            SourceType.APEX,
            fileName,
            className,
            methodName,
            null,
            null
        );
        return newOrigin; 
    }

    public static KJ_Tool_Origin fromRecord(String objectName, Id recordId){
        KJ_Tool_Origin newOrigin = KJ_Tool_Origin.build(
            SourceType.RECORD,
            null,
            null,
            null,
            objectName,
            recordId
        );
        return newOrigin;
    }
}