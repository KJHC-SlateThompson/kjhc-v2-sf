/* 
*   File: KJ_Tool_Package.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 5/22/2026
*   Description: This class structures the standard unit used for passing information around including data, context, and results.
*/
public with sharing class KJ_Tool_Package {
    //*-- Member Variables ------------------------------------------------------------------------
    KJ_Tool_DataBundle      dataBundle;     { get; private set; }

    KJ_Tool_Result          result;         { get; private set; }

    KJ_Tool_Origin          origin;         { get; private set; }
    KJ_Tool_OrgContext      orgContext;     { get; private set; }
    KJ_Tool_UserContext     userContext;    { get; private set; }
    KJ_Tool_TriggerContext  triggerContext; { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    public KJ_Tool_Package() {
        this.dataBundle     = new KJ_Tool_DataBundle();

        this.result         = new KJ_Tool_Result();

        this.origin         = new KJ_Tool_Origin();
        this.orgContext     = new KJ_Tool_OrgContext();
        this.userContext    = new KJ_Tool_UserContext();
        this.triggerContext = new KJ_Tool_TriggerContext();
    }

    public static KJ_Tool_Package build(
                                        KJ_Tool_DataBundle initDataBundle, 
                                        KJ_Tool_Origin initOrigin, 
                                        KJ_Tool_Result initResult, 
                                        KJ_Tool_OrgContext initOrgContext, 
                                        KJ_Tool_UserContext initUserContext, 
                                        KJ_Tool_TriggerContext initTriggerContext
    ) {
        KJ_Tool_Package newPackage = new KJ_Tool_Package();

        newPackage.dataBundle       = initDataBundle        ?? newPackage.dataBundle;
        newPackage.origin           = initOrigin            ?? newPackage.origin;
        newPackage.result           = initResult            ?? newPackage.result;
        newPackage.orgContext       = initOrgContext        ?? newPackage.orgContext;
        newPackage.userContext      = initUserContext       ?? newPackage.userContext;
        newPackage.triggerContext   = initTriggerContext    ?? newPackage.triggerContext;

        return newPackage;
    }
    public static KJ_Tool_Package build(KJ_Tool_DataBundle initDataBundle){
        return build(initDataBundle, null, null, null, null, null);
    }
    public static KJ_Tool_Package build(KJ_Tool_DataBundle initDataBundle, KJ_Tool_Origin initOrigin){
        return build(initDataBundle, initOrigin, null, null, null, null);
    }
    public static KJ_Tool_Package build(KJ_Tool_DataBundle initDataBundle, KJ_Tool_Origin initOrigin, KJ_Tool_Result initResult){
        return build(initDataBundle, initOrigin, initResult, null, null, null);
    }
}