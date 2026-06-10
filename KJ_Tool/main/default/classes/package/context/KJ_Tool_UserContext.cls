/* 
*   File: KJ_Tool_UserContext.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 4/20/2026
*   Description: This class is built to structure and hold data about the currently running user

*/
public with sharing class KJ_Tool_UserContext {
    //*-- Member Variables ------------------------------------------------------------------------
    public Id       userId      { get; private set; }
    public String   userName    { get; private set; }
    public String   userEmail   { get; private set; }

    public Id       profileId   { get; private set; }
    public String   profileName { get; private set; }

    public Id       roleId      { get; private set; }
    public String   roleName    { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Constructor and build methods
    public KJ_Tool_UserContext(){
        this.userId         = null;
        this.userName       = '';
        this.userEmail      = '';
        
        this.profileId      = null;
        this.profileName    = '';
        
        this.roleId         = null;
        this.roleName       = '';
    }

    public static KJ_Tool_UserContext build(){
        KJ_Tool_UserContext newContext = new KJ_Tool_UserContext();

        User runningUser = [
            SELECT Id, Name, Email,
                   ProfileId, Profile.Name,
                   UserRoleId, UserRole.Name,
                   UserType, LanguageLocaleKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
 
        newContext.userId          = runningUser.Id             ?? newContext.userId;
        newContext.userName        = runningUser.Name           ?? newContext.userName;
        newContext.userEmail       = runningUser.Email          ?? newContext.userEmail;
 
        newContext.profileId       = runningUser.ProfileId      ?? newContext.profileId;
        newContext.profileName     = runningUser.Profile.Name   ?? newContext.profileName;
 
        newContext.roleId          = runningUser.UserRoleId     ?? newContext.roleId;
        newContext.roleName        = (runningUser.UserRoleId != null) ? runningUser.UserRole.Name : '';

        return newContext;
    }

    // Returns true if the running user has the given custom permission
    public Boolean hasCustomPermission(String permissionApiName) {
        return FeatureManagement.checkPermission(permissionApiName);
    }


}