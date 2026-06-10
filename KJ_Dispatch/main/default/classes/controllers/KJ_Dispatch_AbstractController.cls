/* 
*   File: KJ_Tool_AbstractController.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 6/3/2026
*   Description: This class is built to template per-object controllers

*/
public abstract class KJ_Dispatch_AbstractController {
    //*-- Member Methods --------------------------------------------------------------------------
    // Method called by trigger
    public void run(){
        KJ_Tool_Package pkg = this.buildPackage();
        try{ 
            this.route(pkg);
        }
        catch (Exception e) {
            // wrap in KJ_Tool_exception and add to package.result.exceptions
        }
        this.finalize(pkg);
    }

    protected abstract String controllerName();

    protected virtual KJ_Tool_Package buildPackage() {
        return KJ_Tool_Package.build(null)
                                .withOrigin(KJ_ToolOrigin.fromApex(
                                    this.controllerName() + '.cls',
                                    this.controllerName(),
                                    'buildPackage()'
                                ))
                                .withOrgContext(KJ_Tool_OrgContext.build())
                                .withUserContext(KJ_Tool_UserContext.build())
                                .withTriggerContext(KJ_Tool_TriggerContext.build());
    }

    protected abstract void route(KJ_Tool_Package pkg);

    protected virtual void finalize(KJ_Tool_Package pkg){
        if(pkg.result.isSuccess) { return; }

        for(KJ_Tool_Exception e : pkg.result.exceptions){
            switch on e.level{
                when FATAL  { KJ_Tool_Logger.fatal(e); }
                when else   { KJ_Tool_Logger.high(e); }
            }
        }
    }
}