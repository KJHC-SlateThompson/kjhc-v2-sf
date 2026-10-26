trigger KJ_Dispatch_HvacUnitTrigger on HVAC_Unit__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_HvacUnit.receive(
        KJ_Tool_Package.fromTrigger('HvacUnit', 'KJ_Dispatch_HvacUnitTrigger')
    ).applyErrorsToRecords();
}
