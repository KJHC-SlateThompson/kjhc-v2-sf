trigger KJ_Dispatch_ContactTrigger on Contact (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_Contact.receive(
        KJ_Tool_Package.fromTrigger('Contact', 'KJ_Dispatch_ContactTrigger')
    ).applyErrorsToRecords();
}
