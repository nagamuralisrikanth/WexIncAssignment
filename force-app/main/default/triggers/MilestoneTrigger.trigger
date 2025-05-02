trigger MilestoneTrigger on Milestone__c (after insert, after update, after delete) {
    MilestoneHandler.updateProjectProgress(
        Trigger.isDelete ? null : Trigger.newMap,
        Trigger.isInsert ? null : Trigger.oldMap,
        Trigger.isDelete
    );
}
