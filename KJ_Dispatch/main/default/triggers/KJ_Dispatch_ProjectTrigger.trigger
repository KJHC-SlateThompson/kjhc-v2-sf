trigger KJ_Dispatch_ProjectTrigger on Project (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_Project.receive(
        KJ_Tool_Package.fromTrigger('Project', 'KJ_Dispatch_AccountTrigger')
    );
}
