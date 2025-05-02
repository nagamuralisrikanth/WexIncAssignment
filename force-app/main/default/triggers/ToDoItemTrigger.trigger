trigger ToDoItemTrigger on To_Do_Item__c (after insert, after update,after delete,after undelete) {
    // This trigger is fired after a To_Do_Item__c record is inserted, updated, deleted, or undeleted.
    // It calls the ToDoItemTriggerHandler class to handle the trigger logic.
    ToDoItemTriggerHandler.updateMilestoneprogress(Trigger.newMap, Trigger.oldMap,Trigger.isDelete);

}