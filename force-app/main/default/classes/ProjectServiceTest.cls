@isTest
public class ProjectServiceTest {

    @isTest
    static void testCreateProjectHierarchy() {
        String projectJSON = '{"name":"Test Project"}';

        String milestoneJSON = '[' +
            '{"name":"MS1","dueDate":"2025-12-31","todos":[' +
                '{"name":"TD1","dueDate":"2025-12-30"},' +
                '{"name":"TD2","dueDate":"2025-12-30"}]},' +
            '{"name":"MS2","dueDate":"2026-01-10","todos":[' +
                '{"name":"TD3","dueDate":"2026-01-05"}]}]';

        Test.startTest();
        ProjectService.createProjectHierarchy(projectJSON, milestoneJSON);
        Test.stopTest();

        List<Project__c> projects = [SELECT Id, Name FROM Project__c WHERE Name = 'Test Project'];
        System.assertEquals(1, projects.size());

        List<Milestone__c> milestones = [SELECT Id FROM Milestone__c WHERE Project__c = :projects[0].Id];
        System.assertEquals(2, milestones.size());

        List<To_Do_Item__c> todos = [SELECT Id FROM To_Do_Item__c WHERE Milestone__c IN :milestones];
        System.assertEquals(3, todos.size());
    }
}
