@isTest
private class ProjectContractTriggerHandlerTest {

        @testSetup static void createTestData() {
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';        
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';        
        insert proj;        
        System.debug('Inserted project - ' + proj);   
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        System.debug('Inserted account - ' + account);   
            
        Contract contract = new Contract();
        contract.Name = 'Test Contract - 1';   
        contract.AccountId = account.ID;
        contract.Revenue_Type__c = 'POC';
        insert contract;            
        System.debug('Inserted contract - ' + contract);
            
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.Account__c = account.ID;         
        milestone.pse__Project__c = proj.ID;
        milestone.name = 'Test Milestone';  
        milestone.pse__Target_Date__c = Date.today();
        milestone.pse__Actual_Date__c = Date.today();
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Milestone__c = 1;
        milestone.pse__Status__c = 'Approved';
        insert milestone;    
        System.debug('Inserted milestone - ' + milestone);
            
	}
    
	private static testMethod void projectContractTest() {    
        
        pse__proj__c proj = [SELECT Id, Name FROM pse__proj__c WHERE name = 'Test project' LIMIT 1];
        Contract contract = [SELECT Id, Name FROM Contract WHERE name = 'Test Contract - 1' LIMIT 1];
        
        Project_Contract__c projCon = new Project_Contract__c();
        projCon.Project__c = proj.ID;
        projCon.Contract__c = contract.ID;
        insert projCon;
        
        List<pse__Milestone__c> milestones = [SELECT Id, Name FROM pse__Milestone__c
                                               WHERE Contract_ID__c = :contract.ID];
        
        System.assertEquals(1,milestones.size());
    }
}