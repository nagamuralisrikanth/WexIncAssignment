public class MilestoneHandler {
    public static void updateProjectProgress(
        Map<Id, Milestone__c> newMap,
        Map<Id, Milestone__c> oldMap,
        Boolean isDelete
    ) {
        Set<Id> projectIds = new Set<Id>();
        // Defensive check for null maps
        if (!isDelete && newMap != null) {
            for (Milestone__c m : newMap.values()) {
                if (m.Project__c != null) {
                    projectIds.add(m.Project__c);
                }
            }
        }

        if (oldMap != null) {
            for (Milestone__c m : oldMap.values()) {
                if (m.Project__c != null) {
                    projectIds.add(m.Project__c);
                }
            }
        }

        if (projectIds.isEmpty()) return;

        Map<Id, List<Milestone__c>> projectToMilestones = new Map<Id, List<Milestone__c>>();
        for (Milestone__c m : [
            SELECT Project__c, Percent_Complete__c
            FROM Milestone__c
            WHERE Project__c IN :projectIds
        ]) {
            if (!projectToMilestones.containsKey(m.Project__c)) {
                projectToMilestones.put(m.Project__c, new List<Milestone__c>());
            }
            projectToMilestones.get(m.Project__c).add(m);
        }

        List<Project__c> updates = new List<Project__c>();
        for (Id projId : projectToMilestones.keySet()) {
            List<Milestone__c> msList = projectToMilestones.get(projId);
            Decimal total = 0;
            for (Milestone__c m : msList) {
         if (m.Percent_Complete__c != null) {
        total += m.Percent_Complete__c;
    }            }
            Decimal percent = msList.size() > 0 ? total / msList.size() : 0;
            updates.add(new Project__c(Id = projId, Percent_Complete__c = percent));
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }
}
