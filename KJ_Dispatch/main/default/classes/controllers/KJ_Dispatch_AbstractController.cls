/* 
*   File: KJ_Tool_AbstractController.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 6/3/2026
*   Description: This class is built to template per-object controllers
*/

public abstract class KJ_Dispatch_AbstractController {
    //*-- Member Methods --------------------------------------------------------------------------
    // Method called by trigger
    public KJ_Tool_Package run(){
        KJ_Tool_Package pkg = KJ_Tool_Package.build();
        try{ 
            pkg = this.buildPackage();
            this.route(pkg);
        }
        catch (Exception e) {
            pkg.result.addException(
                KJ_Tool_Exception.fatal(e, KJ_Tool_Exception.Code.ROUTING_ERROR)
            );
        }
        this.finalize(pkg);
        return pkg;
    }

    protected abstract String controllerName();

    protected virtual KJ_Tool_Package buildPackage() {
        return KJ_Tool_Package.build(null)
                                .withOrigin(KJ_Tool_Origin.fromApex(
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
                when FATAL  { KJ_Tool_Logger.error(e); }
                when else   { KJ_Tool_Logger.warn(e); }
            }
        }
    }
}