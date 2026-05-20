/* 
*   File: KJ_Tool_OrgContext.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/20/2026
*   Description: This class is built to structure and hold data about the currently Salesforce org

*/
public with sharing class KJ_Tool_OrgContext {
    //*-- Constants -------------------------------------------------------------------------------
    public enum OrgType{
            PRODUCTION,
            SANDBOX
            SCRATCH
            DEVELOPER
    }
    //*-- Member Variables ------------------------------------------------------------------------
    public Id       orgId           { get; private set; }
    public String   orgName         { get; private set; }
 
    public String   instanceUrl     { get; private set; }
    public OrgType  orgType         { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    public static KJ_Tool_OrgContext build(){
        KJ_Tool_OrgContext newContext = new KJ_Tool_OrgContext();
 
        Organization org = [
            SELECT Id, Name, InstanceName, IsSandbox
            FROM Organization
            LIMIT 1
        ];

        newContext.orgId         = org.Id;
        newContext.orgName       = org.Name;
 
        newContext.instanceUrl   = URL.getOrgDomainUrl().toExternalForm();
        newContext.orgType       = IsSandbox ? OrgType.SANDBOX : OrgType.PRODUCTION;
 
        return newContext;
    }
}