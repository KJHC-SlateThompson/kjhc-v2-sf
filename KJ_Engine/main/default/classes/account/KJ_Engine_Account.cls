/* 
*   File: KJ_Engine_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 9/22/2026
*   Description: This class is built to hold the operations needed for the account object

*/
public with sharing class KJ_Engine_Account {


    //*-- Static Methods --------------------------------------------------------------------------
    // Triggered methods
    public static void onBeforeInsert(KJ_Tool_Package pkg){}
    public static void onBeforeUpdate(KJ_Tool_Package pkg){}
    public static void onBeforeDelete(KJ_Tool_Package pkg){}

    public static void onAfterInsert(KJ_Tool_Package pkg){}
    public static void onAfterUpdate(KJ_Tool_Package pkg){}
    public static void onAfterDelete(KJ_Tool_Package pkg){}
    public static void onAfterUndelete(KJ_Tool_Package pkg){}
    

    public static KJ_Tool_Package archive(KJ_Tool_Package pkg){
        List<KJ_Model_Account> accounts = new List<KJ_Model_Account>();

        for(KJ_Tool_DataEntry entry : pkg.dataBundle.entries){
            if (!(entry.value instanceof KJ_Model_Account)){
                KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                    KJ_Tool_Exception.Code.MISSING_DATA,
                    'archive received a non-Account entry: ' + entry.label
                );
                pkg.result.addException(newException);

                return pkg;
            }
            accounts.add((KJ_Model_Account) entry.value);
        }

        if (accounts.isEmpty()) {
            KJ_Tool_Exception newException = KJ_Tool_Exception.high(
                KJ_Tool_Exception.Code.MISSING_DATA,
                'arc    hive received no Account entries.'
            );
            pkg.result.addException(newException);
            return pkg;
        }

        List<Account> toUpdate = new List<Account>();
        for(KJ_Model_Account account : accounts){
            account.setArchived(True);
            toUpdate.add(account.toRecord());
        }
        update toUpdate;

        return pkg;
    }
}
