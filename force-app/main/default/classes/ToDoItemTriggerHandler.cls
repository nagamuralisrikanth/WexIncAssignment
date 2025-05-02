public with sharing class ToDoItemTriggerHandler {
   public static void updateMilestoneProgress(Map<Id, To_Do_Item__c> newMap, Map<Id, To_Do_Item__c> oldMap, Boolean isDelete) {
        Set<Id> milestoneIds = new Set<Id>();

        if (!isDelete && newMap != null)
            for (To_Do_Item__c todo : newMap.values())
                if (todo.Milestone__c != null)
                    milestoneIds.add(todo.Milestone__c);

        if (oldMap != null)
            for (To_Do_Item__c todo : oldMap.values())
                if (todo.Milestone__c != null)
                    milestoneIds.add(todo.Milestone__c);

        if (milestoneIds.isEmpty()) return;

        Map<Id, List<To_Do_Item__c>> milestoneIdToTodos = new Map<Id, List<To_Do_Item__c>>();
        for (To_Do_Item__c tdi : [
            SELECT Status__c, Milestone__c
            FROM To_Do_Item__c
            WHERE Milestone__c IN :milestoneIds
        ]) {
            if (!milestoneIdToTodos.containsKey(tdi.Milestone__c)) {
                milestoneIdToTodos.put(tdi.Milestone__c, new List<To_Do_Item__c>());
            }
            milestoneIdToTodos.get(tdi.Milestone__c).add(tdi);
        }

        List<Milestone__c> milestonesToUpdate = new List<Milestone__c>();
        for (Id milestoneId : milestoneIdToTodos.keySet()) {
            List<To_Do_Item__c> todos = milestoneIdToTodos.get(milestoneId);
            Integer total = todos.size();
            Integer completed = 0;
            for (To_Do_Item__c t : todos)
                if (t.Status__c == 'Complete') completed++;

            Decimal percent = total == 0 ? 0 : (Decimal.valueOf(completed) / total) * 100;
            milestonesToUpdate.add(new Milestone__c(Id = milestoneId, Percent_Complete__c = percent));
        }

        if (!milestonesToUpdate.isEmpty())
            update milestonesToUpdate;
    }
}