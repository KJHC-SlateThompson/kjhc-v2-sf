/* 
*   File: KJ_Dispatch_Membership.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/2/2026
*   Description: This class is built to control operations related to the Membership object
*
*   Index:
*       Constants                   private
*       Static Methods              public + private    (private: route)
*/
public with sharing class KJ_Dispatch_Membership {
    //*-- Constants -------------------------------------------------------------------------------
    private static final String CONTROLLER_NAME = 'KJ_Dispatch_Membership';

    //*-- Static Methods --------------------------------------------------------------------------
    public static KJ_Tool_Package receive(KJ_Tool_Package pkg){
        // null check
        if(pkg !== (pkg = KJ_Tool_Package.nullCheck(pkg))) { return pkg; }

        try{
            route(pkg);
        }
        catch (Exception e) {
            pkg.result.addException(
                KJ_Tool_Exception.fatal(e, KJ_Tool_Exception.Code.ROUTING_ERROR)
            );
        }

        return pkg;
    }

    // Internal/Private methods 
    private static void route(KJ_Tool_Package pkg){
        if (pkg.triggerContext == null) {
            KJ_Tool_Exception newException = KJ_Tool_Exception.fatal(
                KJ_Tool_Exception.Code.INVALID_CONTEXT,
                CONTROLLER_NAME + ' received a package with no trigger context.'
            );
            pkg.result.addException(newException);

            return;
        }

        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        if (ctx.isBefore){
            if (ctx.isInsert) { KJ_Engine_Membership.onBeforeInsert(pkg); }
            if (ctx.isUpdate) { KJ_Engine_Membership.onBeforeUpdate(pkg); }
            if (ctx.isDelete) { KJ_Engine_Membership.onBeforeDelete(pkg); }
        }
        else if (ctx.isAfter){
            if (ctx.isInsert)   { KJ_Engine_Membership.onAfterInsert(pkg); }
            if (ctx.isUpdate)   { KJ_Engine_Membership.onAfterUpdate(pkg); }
            if (ctx.isDelete)   { KJ_Engine_Membership.onAfterDelete(pkg); }
            if (ctx.isUndelete) { KJ_Engine_Membership.onAfterUndelete(pkg); }
        }
    }
}