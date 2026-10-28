trigger KJ_Dispatch_JobTrigger on Job__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_Job.receive(
        KJ_Tool_Package.fromTrigger('Job', 'KJ_Dispatch_JobTrigger')
    ).applyErrorsToRecords();
}
