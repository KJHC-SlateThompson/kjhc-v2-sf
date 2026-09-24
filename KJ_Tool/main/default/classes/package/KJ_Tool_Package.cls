/*
*   File: KJ_Tool_Package.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/22/2026
*   Description: This class structures the standard unit used for passing information around including data, context, and results.
*
*   Index:
*       Member Variables            public get; private set
*       Member Methods              public
*           Constructor & Factories
*           Setters
*           Helpers
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
    // Constructor
    public KJ_Tool_Package() {
        this.label          = '';
        this.dataBundle     = new KJ_Tool_DataBundle();
        
        this.result         = new KJ_Tool_Result();
        
        this.origin         = new KJ_Tool_Origin();
        this.orgContext     = null;
        this.userContext    = null;
        this.triggerContext = null;
    }
    
 
    // Factories
    public static KJ_Tool_Package build(KJ_Tool_DataBundle initDataBundle){
        KJ_Tool_Package newPackage = new KJ_Tool_Package();
        newPackage.dataBundle = initDataBundle ?? newPackage.dataBundle;

        return newPackage;
    }
    public static KJ_Tool_Package build(){
        return build(null);
    }

    // Trigger package assembly. Lives here so every trigger body stays a one-liner and the
    // controller never has to reach into static Trigger state itself.
    public static KJ_Tool_Package fromTrigger(String objectName, String triggerName){
        return KJ_Tool_Package.build()
                                .withLabel(objectName + ' Trigger Package')
                                .withOrigin(KJ_Tool_Origin.fromApex(
                                    triggerName + '.trigger',
                                    triggerName,
                                    'trigger body'
                                ))
                                .withTriggerContext(KJ_Tool_TriggerContext.build());
    }

    // Setters
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

    //helpers
    public static KJ_Tool_Package nullCheck(KJ_Tool_Package pkg){
        if(pkg == null){
            KJ_Tool_Package empty = KJ_Tool_Package.build();

            KJ_Tool_Exception newException = KJ_Tool_Exception.fatal(
                KJ_Tool_Exception.Code.INVALID_CONTEXT,
                'Somewhere a null package was detected by a null check. This is the stand-in package to replace it.'
            );
            empty.result.addException(newException);

            pkg = empty;
        }
        return pkg;
    }

}