/* 
*   File: KJ_Dispatch_AbstractController.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 6/3/2026
*   Description: This class is built to template per-object controllers
*/

public abstract class KJ_Dispatch_AbstractController {
    //*-- Member Methods --------------------------------------------------------------------------
    // The domain's front door. Input domains assemble the package; the controller only receives it.
    // Not virtual on purpose: every entry into KJ_Dispatch lands on the same error lane.
    public KJ_Tool_Package receive(KJ_Tool_Package pkg){
        KJ_Tool_Package inbound = pkg ?? KJ_Tool_Package.build();

        // A null package is a caller error, not a routing failure. Record it, route nothing.
        if (pkg == null) {
            inbound.result.addException(KJ_Tool_Exception.fatal(
                KJ_Tool_Exception.Code.INVALID_CONTEXT,
                this.controllerName() + ' received a null package.'
            ));
            this.finalize(inbound);
            return inbound;
        }

        try{ 
            this.route(inbound);
        }
        catch (Exception e) {
            inbound.result.addException(
                KJ_Tool_Exception.fatal(e, KJ_Tool_Exception.Code.ROUTING_ERROR)
            );
        }
        this.finalize(inbound);
        return inbound;
    }

    protected abstract String controllerName();

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
