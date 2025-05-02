@isTest
public class ToDoItemHandlerTest {

    @isTest
    static void testUpdateMilestoneProgress() {
        Project__c proj = new Project__c(Name = 'Test Proj');
        insert proj;

        Milestone__c ms = new Milestone__c(Name = 'MS', Project__c = proj.Id, Due_Date__c = Date.today());
        insert ms;

        To_Do_Item__c td1 = new To_Do_Item__c(
            Name = 'TD1', Due_Date__c = Date.today(), Status__c = 'Complete', Milestone__c = ms.Id);
        To_Do_Item__c td2 = new To_Do_Item__c(
            Name = 'TD2', Due_Date__c = Date.today(), Status__c = 'Not Started', Milestone__c = ms.Id);
        insert new List<To_Do_Item__c>{ td1, td2 };

        ms = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :ms.Id];
        System.assertEquals(50, Integer.valueOf(ms.Percent_Complete__c));
    }
}
