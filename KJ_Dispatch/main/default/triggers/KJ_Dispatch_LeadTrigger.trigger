trigger KJ_Dispatch_LeadTrigger on Lead (before insert, before update) {
    new KJ_Dispatch_LeadController().receive(
        KJ_Tool_Package.fromTrigger('Lead', 'KJ_Dispatch_LeadTrigger')
    );
}
