public with sharing class ProjectService {

    @AuraEnabled
    public static Id createProjectHierarchy(String projectJSON, String milestoneJSON) {
        try {
            if (String.isBlank(projectJSON) || String.isBlank(milestoneJSON)) {
                throw new AuraHandledException('Input JSON cannot be empty.');
            }

            // Deserialize and validate
            ProjectWrapper project = (ProjectWrapper)JSON.deserialize(projectJSON, ProjectWrapper.class);
            List<MilestoneWrapper> milestones = 
                (List<MilestoneWrapper>)JSON.deserialize(milestoneJSON, List<MilestoneWrapper>.class);

            if (project == null || String.isBlank(project.name)) {
                throw new AuraHandledException('Project Name is required.');
            }

            if (milestones == null || milestones.isEmpty()) {
                throw new AuraHandledException('At least one milestone is required.');
            }

            // 🔐 Check permissions
            if (!Schema.sObjectType.Project__c.isCreateable() ||
                !Schema.sObjectType.Milestone__c.isCreateable() ||
                !Schema.sObjectType.To_Do_Item__c.isCreateable()) {
                throw new AuraHandledException('You do not have permission to create records.');
            }

            // Step 1: Create Project
            Project__c proj = new Project__c(
                Name = project.name,
                OwnerId = UserInfo.getUserId()
            );
            insert proj;

            // Step 2: Create Milestones
            List<Milestone__c> milestoneRecords = new List<Milestone__c>();
            for (MilestoneWrapper m : milestones) {
                if (String.isBlank(m.name) || String.isBlank(m.dueDate)) {
                    throw new AuraHandledException('Milestone name and due date are required.');
                }
                milestoneRecords.add(new Milestone__c(
                    Name = m.name,
                    Due_Date__c = Date.valueOf(m.dueDate),
                    Project__c = proj.Id
                ));
            }
            insert milestoneRecords;

            // Step 3: Create To-Do Items
            List<To_Do_Item__c> todoRecords = new List<To_Do_Item__c>();
            for (Integer i = 0; i < milestones.size(); i++) {
                List<TodoWrapper> todos = milestones[i].todos;
                if (todos != null) {
                    for (TodoWrapper t : todos) {
                        if (String.isBlank(t.name) || String.isBlank(t.dueDate)) {
                            throw new AuraHandledException('To-Do name and due date are required.');
                        }
                        todoRecords.add(new To_Do_Item__c(
                            Name = t.name,
                            Due_Date__c = Date.valueOf(t.dueDate),
                            Milestone__c = milestoneRecords[i].Id
                        ));
                    }
                }
            }

            if (!todoRecords.isEmpty()) {
                insert todoRecords;
            }
    return proj.Id;
        } catch (Exception ex) {
            throw new AuraHandledException('Project creation failed: ' + ex.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
public static Project__c getProjectWithMilestones(Id projectId) {
    return [
        SELECT Id, Name, Percent_Complete__c,
            (SELECT Id, Name, Percent_Complete__c FROM Milestones__r)
        FROM Project__c
        WHERE Id = :projectId
    ];
}


    public class ProjectWrapper {
        @AuraEnabled public String name;
    }

    public class MilestoneWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String dueDate;
        @AuraEnabled public List<TodoWrapper> todos;
    }

    public class TodoWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String dueDate;
    }
}
