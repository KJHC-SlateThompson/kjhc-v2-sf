@isTest
public with sharing class KJ_Dispatch_AbstractController_Test {
    private class FakeController extends KJ_Dispatch_AbstractController {
        Boolean failInRoute = false;

        protected override String controllerName() { return 'FakeController'; }

        protected override void route(KJ_Tool_Package pkg) {
            if (failInRoute) { throw new stubException('route() Fail'); }
        }
    }
    private class StubException extends Exception {}

    @isTest 
    static void route_FailPath(){
        FakeController controller = new FakeController();
        controller.failInRoute = true;

        KJ_Tool_Package pkg = controller.receive(KJ_Tool_Package.build());
        
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.ROUTING_ERROR, pkg.result.exceptions[0].code);
    }
    
    @isTest
    static void receive_NullPackage_FailPath(){
        KJ_Tool_Package pkg = new FakeController().receive(null);

        Assert.isNotNull(pkg);
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, pkg.result.exceptions[0].code);
    }

    @isTest
    static void receive_HappyPath(){
        KJ_Tool_Package pkg = new FakeController().receive(KJ_Tool_Package.build());

        Assert.isTrue(pkg.result.isSuccess);
        Assert.isTrue(pkg.result.exceptions.isEmpty());
    }

    // The real controller, handed a package with no trigger context: the route() guard should
    // label it honestly instead of letting a null deref fall into the generic catch.
    @isTest
    static void receive_MissingTriggerContext_FailPath(){
        KJ_Tool_Package pkg = new KJ_Dispatch_LeadController().receive(KJ_Tool_Package.build());

        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.INVALID_CONTEXT, pkg.result.exceptions[0].code);
    }
}
