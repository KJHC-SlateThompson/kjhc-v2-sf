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
    // factory method
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
 
        newContext.userId          = runningUser.Id;
        newContext.userName        = runningUser.Name;
        newContext.userEmail       = runningUser.Email;
 
        newContext.profileId       = runningUser.ProfileId;
        newContext.profileName     = runningUser.Profile.Name;
 
        newContext.roleId          = runningUser.UserRoleId;
        newContext.roleName        = (runningUser.UserRole != null) ? runningUser.UserRole.Name : null;

        return newContext;
    }

    // Returns true if the running user has the given custom permission
    public Boolean hasCustomPermission(String permissionApiName) {
        return FeatureManagement.checkPermission(permissionApiName);
    }


}