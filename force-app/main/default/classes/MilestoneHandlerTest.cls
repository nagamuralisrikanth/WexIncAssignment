@isTest
public class MilestoneHandlerTest {

    @isTest
    static void testUpdateProjectProgress() {
        Project__c proj = new Project__c(Name = 'My Project');
        insert proj;

        Milestone__c m1 = new Milestone__c(Name = 'MS1', Project__c = proj.Id, Percent_Complete__c = 100, Due_Date__c = Date.today());
        Milestone__c m2 = new Milestone__c(Name = 'MS2', Project__c = proj.Id, Percent_Complete__c = 0, Due_Date__c = Date.today());
        insert new List<Milestone__c>{ m1, m2 };

        // Update m2 to trigger handler
        m2.Percent_Complete__c = 100;
        update m2;

        proj = [SELECT Percent_Complete__c FROM Project__c WHERE Id = :proj.Id];
        System.assertEquals(100, Integer.valueOf(proj.Percent_Complete__c));
    }
}
