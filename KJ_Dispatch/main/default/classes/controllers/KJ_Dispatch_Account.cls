/* 
*   File: KJ_Dispatch_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 7/22/2026
*   Description: This class is built to control operations related to the Account object

*/
public with sharing class KJ_Dispatch_Account {
    //*-- Constants -------------------------------------------------------------------------------
    private static final String CONTROLLER_NAME = 'KJ_Dispatch_Account';

    //*-- Static Methods --------------------------------------------------------------------------
    public static KJ_Tool_Package receive(KJ_Tool_Package pkg){
        if (pkg == null) {
            KJ_Tool_Package empty = KJ_Tool_Package.build();
            empty.result.addException(KJ_Tool_Exception.fatal(
                KJ_Tool_Exception.Code.INVALID_CONTEXT,
                CONTROLLER_NAME + ' received a null package.'
            ));
            finalize(empty);
            return empty;
        }

        try{
            route(pkg);
        }
        catch (Exception e) {
            pkg.result.addException(
                KJ_Tool_Exception.fatal(e, KJ_Tool_Exception.Code.ROUTING_ERROR)
            );
        }
        finalize(pkg);
        return pkg;
    }

    private static void route(KJ_Tool_Package pkg){
        if (pkg.triggerContext == null) {
            KJ_Engine_Account.summarize(pkg);
            return;
        }

        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        if (ctx.isBefore){
            if (ctx.isInsert) { KJ_Engine_Account.onBeforeInsert(pkg); }
            if (ctx.isUpdate) { KJ_Engine_Account.onBeforeUpdate(pkg); }
            if (ctx.isDelete) { KJ_Engine_Account.onBeforeDelete(pkg); }
        }
        else if (ctx.isAfter){
            if (ctx.isInsert)   { KJ_Engine_Account.onAfterInsert(pkg); }
            if (ctx.isUpdate)   { KJ_Engine_Account.onAfterUpdate(pkg); }
            if (ctx.isDelete)   { KJ_Engine_Account.onAfterDelete(pkg); }
            if (ctx.isUndelete) { KJ_Engine_Account.onAfterUndelete(pkg); }
        }
    }

    private static void finalize(KJ_Tool_Package pkg){
        if(pkg.result.isSuccess) { return; }

        for(KJ_Tool_Exception e : pkg.result.exceptions){
            switch on e.level{
                when FATAL  { KJ_Tool_Logger.error(e); }
                when else   { KJ_Tool_Logger.warn(e); }
            }
        }
    }
}
