trigger KJ_Dispatch_AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_Account.receive(
        KJ_Tool_Package.fromTrigger('Account', 'KJ_Dispatch_AccountTrigger')
    );
}
