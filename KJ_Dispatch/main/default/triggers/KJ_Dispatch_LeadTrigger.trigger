trigger KJ_Dispatch_LeadTrigger on Lead (before insert, before update) {
    new KJ_Dispatch_LeadController().run();
}