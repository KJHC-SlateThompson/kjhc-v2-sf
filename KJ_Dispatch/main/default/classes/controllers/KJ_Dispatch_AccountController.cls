/* 
*   File: KJ_Dispatch_AccountController.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 7/22/2026
*   Description: This class is built to control operations related to the Account object

*/
public with sharing class KJ_Dispatch_AccountController extends KJ_Dispatch_AbstractController{
    //*-- Member Methods --------------------------------------------------------------------------
    protected override String controllerName(){
        return 'KJ_Dispatch_AccountController';
    }
    protected override void route(KJ_Tool_Package pkg){
        // Stub. Present only to satisfy KJ_Dispatch_AbstractController so the domain compiles.
        // Model the real implementation on KJ_Dispatch_LeadController when Account routing lands.
    }
}