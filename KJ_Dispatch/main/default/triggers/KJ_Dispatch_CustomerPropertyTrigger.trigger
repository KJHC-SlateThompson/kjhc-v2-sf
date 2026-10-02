trigger KJ_Dispatch_CustomerPropertyTrigger on CustomerProperty (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_CustomerProperty.receive(
        KJ_Tool_Package.fromTrigger('CustomerProperty', 'KJ_Dispatch_CustomerPropertyTrigger')
    );
}
