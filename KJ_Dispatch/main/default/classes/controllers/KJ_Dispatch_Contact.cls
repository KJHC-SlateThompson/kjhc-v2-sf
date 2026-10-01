/* 
*   File: KJ_Dispatch_Contact.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 10/1/2026
*   Description: This class is built to control operations related to the Contact object
*
*   Index:
*       Constants                   private
*       Static Methods              public + private    (private: route)
*/
public with sharing class KJ_Dispatch_Contact {
    //*-- Constants -------------------------------------------------------------------------------
    private static final String CONTROLLER_NAME = 'KJ_Dispatch_Contact';

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
            if (ctx.isInsert) { KJ_Engine_Contact.onBeforeInsert(pkg); }
            if (ctx.isUpdate) { KJ_Engine_Contact.onBeforeUpdate(pkg); }
            if (ctx.isDelete) { KJ_Engine_Contact.onBeforeDelete(pkg); }
        }
        else if (ctx.isAfter){
            if (ctx.isInsert)   { KJ_Engine_Contact.onAfterInsert(pkg); }
            if (ctx.isUpdate)   { KJ_Engine_Contact.onAfterUpdate(pkg); }
            if (ctx.isDelete)   { KJ_Engine_Contact.onAfterDelete(pkg); }
            if (ctx.isUndelete) { KJ_Engine_Contact.onAfterUndelete(pkg); }
        }
    }
}