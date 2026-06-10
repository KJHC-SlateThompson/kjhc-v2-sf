/* 
*   File: KJ_Tool_Package.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/22/2026
*   Description: This class structures the standard unit used for passing information around including data, context, and results.
*/
public with sharing class KJ_Tool_Package {
    //*-- Member Variables ------------------------------------------------------------------------
    public String                  label          { get; private set; }
    public KJ_Tool_DataBundle      dataBundle     { get; private set; }

    public KJ_Tool_Result          result         { get; private set; }

    public KJ_Tool_Origin          origin         { get; private set; }
    public KJ_Tool_OrgContext      orgContext     { get; private set; }
    public KJ_Tool_UserContext     userContext    { get; private set; }
    public KJ_Tool_TriggerContext  triggerContext { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    public KJ_Tool_Package() {
        this.label          = '';
        this.dataBundle     = new KJ_Tool_DataBundle();
        this.origin         = new KJ_Tool_Origin();

        this.result         = new KJ_Tool_Result();

        this.orgContext     = null;
        this.userContext    = null;
        this.triggerContext = null;
    }
 
 
    public static KJ_Tool_Package build(KJ_Tool_DataBundle initDataBundle){
        KJ_Tool_Package newPackage = new KJ_Tool_Package();
        newPackage.dataBundle = initDataBundle ?? newPackage.dataBundle;

        return newPackage;
    }
    public KJ_Tool_Package withLabel(String initLabel){
        this.label = initLabel ?? this.label;
        return this;
    }
    public KJ_Tool_Package withResult(KJ_Tool_Result initResult){
        this.result = initResult ?? this.result;
        return this;
    }
    public KJ_Tool_Package withOrigin(KJ_Tool_Origin initOrigin){
        this.origin = initOrigin ?? this.origin;
        return this;
    }
    public KJ_Tool_Package withOrgContext(KJ_Tool_OrgContext initOrgContext){
        this.orgContext = initOrgContext ?? this.orgContext;
        return this;
    }
    public KJ_Tool_Package withUserContext(KJ_Tool_UserContext initUserContext){
        this.userContext = initUserContext ?? this.userContext;
        return this;
    }
    public KJ_Tool_Package withTriggerContext(KJ_Tool_TriggerContext initTriggerContext){
        this.triggerContext = initTriggerContext ?? this.triggerContext;
        return this;
    }
}