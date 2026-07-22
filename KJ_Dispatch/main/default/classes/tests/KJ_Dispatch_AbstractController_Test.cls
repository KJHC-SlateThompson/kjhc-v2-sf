@isTest
public with sharing class KJ_Dispatch_AbstractController_Test {
    private class FakeController extends KJ_Dispatch_AbstractController {
        Boolean failInRoute = false;
        Boolean failInBuild = false;

        protected override String controllerName() { return 'FakeController'; }

        protected override KJ_Tool_Package buildPackage(){
            if (failInBuild) { throw new StubException('buildPackage() Fail'); }
            return KJ_Tool_Package.build();
        }

        protected override void route(KJ_Tool_Package pkg) {
            if (failInRoute) { throw new stubException('route() Fail'); }
        }
    }
    private class StubException extends Exception {}

    @isTest 
    static void route_FailPath(){
        FakeController controller = new FakeController();
        controller.failInRoute = true;

        KJ_Tool_Package pkg = controller.run();
        
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.ROUTING_ERROR, pkg.result.exceptions[0].code);
    }
    
    @isTest
    static void buildPackage_FailPath(){
        FakeController controller = new FakeController();
        controller.failInBuild = true;

        KJ_Tool_Package pkg = controller.run();

        Assert.isNotNull(pkg);
        Assert.isFalse(pkg.result.isSuccess);
        Assert.areEqual(KJ_Tool_Exception.Code.ROUTING_ERROR,  pkg.result.exceptions[0].code);
    }

    @isTest
    static void run_HappyPath(){
        KJ_Tool Package pkg = new FakeController().run();

        Assert.isTrue(pkg.result.isSuccess);
    }
}