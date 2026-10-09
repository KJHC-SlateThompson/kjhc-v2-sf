trigger KJ_Dispatch_MembershipTrigger on Membership__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    KJ_Dispatch_Membership.receive(
        KJ_Tool_Package.fromTrigger('Membership', 'KJ_Dispatch_MembershipTrigger')
    );
}
