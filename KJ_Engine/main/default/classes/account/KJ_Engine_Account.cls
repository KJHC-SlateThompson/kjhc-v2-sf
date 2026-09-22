/* 
*   File: KJ_Engine_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class is built to hold the operations needed for the account object

*/
public with sharing class KJ_Engine_Account {
    //*-- Trigger Methods -------------------------------------------------------------------------
    // Methods take the package, matching the old lead engine. Bodies are stubs: the controller
    // routes, and each comment records what the Account metadata says belongs here.

    // Account_Status__c, Account_Sector__c, Branch_Territory__c, Account_Lead_Source__c and
    // Customer_Since__c are all <required>true</required> with NO <defaultValue>, so every insert
    // path -- integration, UI, test factory -- fails without them. Defaulting them is this hook's
    // first job. Attribution (GCLID__c, UTM_*) and Record_Origin__c also get stamped here.
    public static void onBeforeInsert(KJ_Tool_Package pkg){
        List<Account> newAccounts = (List<Account>) pkg.triggerContext.newList;
        KJ_Tool_Logger.debug('AccountEngine.onBeforeInsert fired for ' + newAccounts.size() + ' record(s).');
    }

    // Branch_Territory__c reassignment when the billing address changes, and the status transition
    // into AccountStatus.CURRENT_CUSTOMER that sets Customer_Since__c. KJ_Tool_TriggerContext
    // .getChangedRecords(SObjectField) is the intended tool for both.
    public static void onBeforeUpdate(KJ_Tool_Package pkg){
        List<Account> newAccounts = (List<Account>) pkg.triggerContext.newList;
        KJ_Tool_Logger.debug('AccountEngine.onBeforeUpdate fired for ' + newAccounts.size() + ' record(s).');
    }

    // Guard rail: an Account carrying FieldPulse_Account_Id__c or QBO_Account_Id__c is owned by an
    // external system and should not be deleted out from under it.
    public static void onBeforeDelete(KJ_Tool_Package pkg){
        List<Account> oldAccounts = (List<Account>) pkg.triggerContext.oldList;
        KJ_Tool_Logger.debug('AccountEngine.onBeforeDelete fired for ' + oldAccounts.size() + ' record(s).');
    }

    // Outbound integration: push new Accounts to FieldPulse/QBO and write the returned ids back.
    public static void onAfterInsert(KJ_Tool_Package pkg){
        List<Account> newAccounts = (List<Account>) pkg.triggerContext.newList;
        KJ_Tool_Logger.debug('AccountEngine.onAfterInsert fired for ' + newAccounts.size() + ' record(s).');
    }

    public static void onAfterUpdate(KJ_Tool_Package pkg){
        List<Account> newAccounts = (List<Account>) pkg.triggerContext.newList;
        KJ_Tool_Logger.debug('AccountEngine.onAfterUpdate fired for ' + newAccounts.size() + ' record(s).');
    }

    public static void onAfterDelete(KJ_Tool_Package pkg){
        List<Account> oldAccounts = (List<Account>) pkg.triggerContext.oldList;
        KJ_Tool_Logger.debug('AccountEngine.onAfterDelete fired for ' + oldAccounts.size() + ' record(s).');
    }

    public static void onAfterUndelete(KJ_Tool_Package pkg){
        List<Account> newAccounts = (List<Account>) pkg.triggerContext.newList;
        KJ_Tool_Logger.debug('AccountEngine.onAfterUndelete fired for ' + newAccounts.size() + ' record(s).');
    }

    //*-- Direct Call Methods ---------------------------------------------------------------------
    // Reads the packaged Account model and writes a summary onto the result. No SOQL, no DML --
    // the caller assembles the cargo, the engine only reads it.
    public static void summarize(KJ_Tool_Package pkg){
        KJ_Model_Account model = (KJ_Model_Account) pkg.dataBundle.getByLabel('Account')?.value;

        // The bundle did not carry what this method needs.
        if (model == null) {
            pkg.result.addException(KJ_Tool_Exception.high(
                KJ_Tool_Exception.Code.MISSING_DATA,
                'KJ_Engine_Account.summarize found no "Account" entry in the data bundle.'
            ));
            return;
        }

        pkg.result.setMessage(
            'Account ' + model.name + ' (' + model.recordId + ') -- ' +
            'status '    + KJ_Model_Picklist.mapToString(model.status) +
            ', sector '  + KJ_Model_Picklist.mapToString(model.sector) +
            ', territory ' + KJ_Model_Picklist.mapToString(model.branchTerritory)
        );
        KJ_Tool_Logger.debug('KJ_Engine_Account.summarize: ' + pkg.result.message, pkg.origin);
    }
}
