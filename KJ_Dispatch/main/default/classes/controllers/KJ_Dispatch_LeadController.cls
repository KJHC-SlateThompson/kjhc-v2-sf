/* 
*   File: KJ_Tool_LeadController.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 6/10/2026
*   Description: This class is built to control operations related to the lead object

*/
public with sharing class KJ_Dispatch_LeadController extends KJ_Dispatch_AbstractController {

    //*-- Member Methods --------------------------------------------------------------------------
    public KJ_Dispatch_LeadController() {
        
    }
    protected override String controllerName(){
        return 'KJ_Dispatch_LeadController';
    }
    protected override void route(KJ_Tool_Package pkg){
        if(pkg.triggerContext == null) {
            pkg.result.addException(KJ_Tool_Exception.fatal(
                                                        KJ_Tool_Exception.Code.INVALID_CONTEXT,
                                                        'Lead controller invoked without a trigger context.'
            ));
            return;
        }
        KJ_Tool_TriggerContext ctx = pkg.triggerContext;

        if (ctx.isBefore){
            if (ctx.isInsert) { KJ_Engine_LeadEngine.onBeforeInsert(pkg); }
            if (ctx.isUpdate) { KJ_Engine_LeadEngine.onBeforeUpdate(pkg); }
        }
        else if (ctx.isAfter){
            // after methods go here as needed
        }
    }
}