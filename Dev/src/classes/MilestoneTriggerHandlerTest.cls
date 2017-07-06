@isTest
private class MilestoneTriggerHandlerTest {

    @testSetup static void createTestData() {
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        System.debug('Inserted account - ' + account);        
        
		// Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';        
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';   
        proj.pse__Account__c = account.Id;
        insert proj;        
        System.debug('Inserted project - ' + proj);   
            
        Contract contract = new Contract();
        contract.Name = 'Test Contract - 1';   
        contract.AccountId = account.ID;
        contract.Revenue_Type__c = 'POC';
        insert contract;            
        System.debug('Inserted contract - ' + contract);

        Project_Contract__c projCon = new Project_Contract__c();
        projCon.Project__c = proj.ID;
        projCon.Contract__c = contract.ID;
        insert projCon;
        System.debug('Inserted project contract - ' + projCon);
        
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.Account__c = account.ID;         
        milestone.pse__Project__c = proj.ID;
        milestone.name = 'Test Milestone 1';  
        milestone.pse__Target_Date__c = Date.today();
        milestone.pse__Actual_Date__c = Date.today();
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Milestone__c = 1;        
        insert milestone;    
        System.debug('Inserted milestone - ' + milestone);        
    }    
    
    private static testMethod void milestoneApprovedTest() { 
        
        Contract contract = [SELECT ID, Name FROM Contract
                              WHERE Name = 'Test Contract - 1'];
        
        pse__Milestone__c milestone = [SELECT ID, Name, Contract_ID__c
                                        FROM pse__Milestone__c
                                        WHERE name = 'Test Milestone 1' LIMIT 1];
        milestone.pse__Status__c = 'Approved';
        milestone.Account__c = null;
        update milestone;
        System.debug('---- Updated milestone : ' + milestone);
        
        pse__milestone__c milestone2 = [SELECT ID, Name, Contract_ID__c
                                          FROM pse__Milestone__c
                                         WHERE name = 'Test Milestone 1' LIMIT 1];
        
        System.assertEquals(contract.ID, milestone2.Contract_ID__c);
    }
    
    private static testMethod void insertApprovedmilestoneTest() {
        
        Contract contract = [SELECT ID, Name FROM Contract
                              WHERE Name = 'Test Contract - 1'];        
        
        Account account = [SELECT ID, Name FROM Account LIMIT 1];
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];
        
        pse__Milestone__c milestone = new pse__Milestone__c();
        //milestone.Account__c = account.ID;         
        milestone.pse__Project__c = proj.ID;
        milestone.name = 'Test Milestone 2';  
        milestone.pse__Target_Date__c = Date.today();
        milestone.pse__Actual_Date__c = Date.today();
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Milestone__c = 1;  
        milestone.pse__Status__c = 'Approved';
        insert milestone;    
        System.debug('Inserted milestone - ' + milestone);   
        
        pse__milestone__c milestone2 = [SELECT ID, Name, Contract_ID__c
                                          FROM pse__Milestone__c
                                         WHERE name = 'Test Milestone 2' LIMIT 1];
        
        System.assertEquals(contract.ID, milestone2.Contract_ID__c);        
    }    
}