@isTest
private class BudgetTriggerTest {        
    
    @testSetup static void createTestData() {                 
        
        // Create test user
        User user = new User();
        user.Username = 'testprojuser@acostamosaic.com';
        user.LastName = 'Test User';
        user.email = 'testprojuser@acostamosaic.com';
        user.alias = 'test';
        user.CommunityNickname = 'test name';
        user.TimeZoneSidKey = 'Asia/Kolkata';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
        user.LanguageLocaleKey = 'en_US';

        insert user;
        
        System.debug('Inserted user - ' + user);

        Group qGroup = [select Id from Group where Name = '4Print Queue' and Type = 'Queue'];
        
        System.debug('Selected group : ' + qGroup); 
        
        GroupMember grpMem = new GroupMember();
        grpMem.GroupId = qGroup.Id;
        grpMem.UserOrGroupId = user.Id;
        insert grpMem;
        
        System.debug('GroupMember - ' + grpMem);    
        
        System.runAs(user) {
            
            Account account = new Account (name = 'Test Account');
            insert account;
            
            // Create test contact
            Contact contact = new Contact();
            contact.firstname = 'FName';
            contact.lastname = 'Test contact';
            contact.pse__Is_Resource__c = TRUE;
            contact.pse__Is_Resource_Active__c = TRUE;
            contact.pse__salesforce_user__c = user.ID;
            contact.Client_Business_Unit_CBU__c = '4Print';
            insert contact;
            
            System.debug('Inserted contact - ' + contact);
    
            pse__region__c region = new pse__region__c();
            region.Name = 'Test Region';
            insert region;
            System.debug('Inserted region - ' + region);  
            
            pse__practice__c prac = new pse__practice__c();
            prac.Name = 'Test Practice';
            insert prac;
            System.debug('Inserted practice - ' + prac);   
            
            pse__grp__c grp = new pse__grp__c();
            grp.Name = 'Test Group';
            insert grp;
            System.debug('Inserted group - ' + grp);  
            
            // Create project
            pse__proj__c proj = new pse__proj__c();
            proj.name = 'Test project';
            proj.pse__Project_Type__c = 'Internal';
            proj.pse__Project_Manager__c = contact.Id;
            proj.pse__Is_Active__c = TRUE;
            proj.Services_Sub_Services__c = 'Other - Other';
            proj.pse__Is_Billable__c = TRUE;
            proj.pse__Stage__c = 'In Planning';
            proj.Client_BusinessUnit_CBU__c = '4Print';
            proj.pse__Region__c = region.ID;
            proj.pse__Practice__c = prac.ID;
            insert proj; 
            
            System.debug('Inserted project - ' + proj); 
            
            pse__permission_control__c perm = new pse__permission_control__c();
            perm.pse__User__c = user.Id;
            perm.pse__Region__c = region.Id;
            perm.pse__Resource_Request_Entry__c = TRUE;
            perm.pse__Project__c = proj.Id;
            perm.pse__Staffing__c = TRUE;
            perm.pse__Start_Date__c = Date.today().addDays(-10);
            perm.pse__End_Date__c = Date.today().addDays(30);
            perm.pse__Resource__c = contact.Id;
            insert perm;
            
            System.debug('Inserted perm - ' + perm); 
        }
        
    }
    
    static testMethod void VersionUpdate() {
        
        Account account = [SELECT Id, Name FROM Account LIMIT 1];        
        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1]; 
		pse__proj__c proj = [Select Id, pse__Opportunity__c FROM pse__proj__c LIMIT 1];
        
        //create opportunity record
        Opportunity Opp = new Opportunity(Name='Test-opp',pse__Region__c=region.id,Quote_Status__c = 'Approved',Client_Business_Unit_CBU__c = '4Print', 
                                          Revenue_Type__c='POC' ,Services_Sub_Services__c='Other - Other' ,pse__Practice__c = prac.id,pse__Group__c=grp.id, StageName='New',
                                          CloseDate=Date.today(),AccountId=account.Id,pse__Primary_Project__c = proj.Id );
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        insert Opp;
        proj.pse__Opportunity__c = Opp.Id;
        update proj;
        
		pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Test Docket Budget';        
        budget.pse__Type__c = 'Docket Budget';
        budget.pse__Project__c = proj.Id;
        budget.Start_Date__c = Date.today();
        budget.End_Date__c = Date.today().addDays(5);
        budget.Hours_Booked__c = 20;
        budget.Practice__c = prac.ID;  
        budget.pse__Status__c = 'Approved';
		budget.pse__Project__c = proj.Id;
		budget.pse__Opportunity__c = Opp.Id;
		budget.Version__c = 3;
		insert budget;
        
		//create Change Request record
		Opportunity CR = new Opportunity(Name='Test-opp',pse__Region__c=region.id,Quote_Status__c = 'Approved',Client_Business_Unit_CBU__c = '4Print', 
		Revenue_Type__c='POC' ,Services_Sub_Services__c='Other - Other' ,pse__Practice__c = prac.id,pse__Group__c=grp.id, StageName='New',
		CloseDate=Date.today(),AccountId=account.Id,Specific_Project_Identified_w__c = true, pse__Primary_Project__c = proj.Id, pse__Parent_Opportunity__c = Opp.Id);
		CR.RecordTypeId=[select Id,Name from RecordType where Name ='Change Request' and SobjectType = 'Opportunity'].Id;
        
        insert CR; 
        
		//Create Budget for Create
		pse__Budget__c budgetCR = new pse__Budget__c();
        budgetCR.Name = 'Test Docket Budget';        
        budgetCR.pse__Type__c = 'Docket Budget';
        budgetCR.pse__Project__c = proj.Id;
        budgetCR.Start_Date__c = Date.today();
        budgetCR.End_Date__c = Date.today().addDays(5);
        budgetCR.Hours_Booked__c = 20;
        budgetCR.Practice__c = prac.ID;  
        budgetCR.pse__Status__c = 'Approved';
		budgetCR.pse__Project__c = proj.Id;
		budgetCR.pse__Opportunity__c = CR.Id;
		Insert budgetCR;
	} 
        
    static testMethod void sendTestEmail() {
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        PSACustomUtilityClass.sendEmailToSingleRecipient(user.ID, 'Test', 'Test');
        
    } 
    
    static testMethod void validateDocketBudgetInsert() {
        
        Account account = [SELECT Id, Name FROM Account LIMIT 1];        
        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];                   
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.pse__Account__c = account.Id;
        proj.name = 'Test project - 2';        
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        proj.Client_BusinessUnit_CBU__c = '4Print';
        proj.pse__Project_Type__c = 'Docket';
        proj.pse__Region__c = region.ID;
        proj.pse__Practice__c = prac.ID;
        insert proj; 
        
        System.debug('Inserted project - ' + proj); 
        
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Test Docket Budget';        
        budget.pse__Type__c = 'Docket Budget';
        budget.pse__Project__c = proj.Id;
        budget.Start_Date__c = Date.today();
        budget.End_Date__c = Date.today().addDays(5);
        budget.Hours_Booked__c = 20;
        budget.Practice__c = prac.ID;  
        budget.pse__Status__c = 'Approved';
        
        try {
            insert budget; 
        } catch (exception e) {
            System.debug(e.getMessage());
            Boolean err = e.getMessage().containsIgnoreCase(Label.Create_Approved_Docket_Budget_Msg) ? true : false;
            System.assertEquals(true, err);            
        }       
    }
    
    static testMethod void validateDocketBudgetUpdate() {
        
        Account account = [SELECT Id, Name FROM Account LIMIT 1];    
        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];                   
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.pse__Account__c = account.Id;
        proj.name = 'Test project - 2';        
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        proj.Client_BusinessUnit_CBU__c = '4Print';
        proj.pse__Project_Type__c = 'Docket';
        proj.pse__Region__c = region.ID;
        proj.pse__Practice__c = prac.ID;
        insert proj; 
        
        System.debug('Inserted project - ' + proj); 
        
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Test Docket Budget';        
        budget.pse__Type__c = 'Docket Budget';
        budget.pse__Project__c = proj.Id;
        budget.Start_Date__c = Date.today();
        budget.End_Date__c = Date.today().addDays(5);
        budget.Hours_Booked__c = 20;
        budget.Practice__c = prac.ID;  
        budget.pse__Status__c = 'Draft';        
        insert budget;
        
        budget.pse__Status__c = 'Approved';
        try {
            update budget;
        } catch (exception e) {
            System.debug(e.getMessage());
            Boolean err = e.getMessage().containsIgnoreCase(Label.Update_Approved_Docket_Budget_Msg) ? true : false;
            System.assertEquals(true, err);
        }        
    }    

    static testMethod void createBudget() {
        
        BudgetTriggerHandler.excepCoverage = TRUE;
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;
            budget.Management_Personnel__c = TRUE;
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;            
            insert budget;
    
            System.debug('Inserted budget - ' + budget);
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            
            List<pse__Resource_Request__c> requests = [SELECT ID, Name FROM pse__Resource_Request__c];
            System.assertEquals(requests.size(), 2);
        }        
    } 
    
    static testMethod void rejectBudget() {
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;
            budget.Management_Personnel__c = TRUE;
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;            
            insert budget;
    
            System.debug('Inserted budget - ' + budget);
            
            pse__schedule__c schedule = new pse__schedule__c();
            schedule.pse__Start_Date__c = budget.Start_Date__c;
            schedule.pse__End_Date__c = budget.End_Date__c;
            insert schedule;
            
            System.debug('----- Inserted schedule : ' + schedule);
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            
            pse__Assignment__c assignment = new pse__Assignment__c();
            assignment.pse__Schedule__c = schedule.Id;
            assignment.pse__Bill_Rate__c = 10;
            assignment.pse__Resource__c = contact.Id;
            assignment.pse__Project__c = proj.Id;
            assignment.pse__Is_Billable__c = TRUE;
            assignment.Budget__c = budget.ID;
            assignment.Client_Business_Unit_CBU__c = '4Print';
            insert assignment;
            
            System.debug('----- Inserted assignment : ' + assignment);
            
            Test.startTest();
            budget.pse__Status__c = 'Rejected';
            update budget;
            Test.stopTest(); 
            
            assignment = [SELECT id, name, pse__closed_for_time_entry__c FROM pse__assignment__c LIMIT 1];
            System.assertEquals(TRUE, assignment.pse__closed_for_time_entry__c);
            
        }        
    }    
    
    static testMethod void updateBudgetWithSingleRR() {
        
        BudgetOLIUpdateTriggerHandler.excepCoverage = TRUE;
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget 2';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;            
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;   
            budget.Management_Personnel__c = TRUE;
            insert budget;
    
            System.debug('Inserted budget - ' + budget);
            
            List<pse__Resource_Request__c> requests = [SELECT ID, Name FROM pse__Resource_Request__c WHERE Budget__c = :budget.ID];
            System.assertEquals(requests.size(), 2);
            
            Test.startTest();            
            budget.Start_Date__c = budget.Start_Date__c.addDays(-1);
            budget.End_Date__c = budget.End_Date__c.addDays(1);
            budget.OLI_Sync_Timestamp__c = System.now();
            update budget;
            
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            Test.stopTest();
        }        
    }   
    
    static testMethod void updateBudgetWithMultipleRR() {
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget 2';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;            
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;   
            budget.Management_Personnel__c = TRUE;
            insert budget;
    
            System.debug('Inserted budget - ' + budget);            
            
            List<pse__Resource_Request__c> requests = [SELECT ID, Name FROM pse__Resource_Request__c WHERE Budget__c = :budget.ID];
            requests[0].pse__Resource_Held__c = TRUE;
            requests[0].pse__Staffer_Resource__c = contact.ID;
            update requests[0];
            
            Test.startTest();            
            budget.Start_Date__c = budget.Start_Date__c.addDays(-1);
            budget.End_Date__c = budget.End_Date__c.addDays(1);
            budget.OLI_Sync_Timestamp__c = System.now();
            update budget;
            
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            Test.stopTest();
                        
            System.assertEquals(requests.size(), 2);            
        }        
    }       
    
    static testMethod void updateBudgetWithAssignments() {
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget 2';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;            
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;   
            budget.Management_Personnel__c = TRUE;
            insert budget;
    
            System.debug('Inserted budget - ' + budget);
            
            pse__schedule__c schedule = new pse__schedule__c();
            schedule.pse__Start_Date__c = budget.Start_Date__c;
            schedule.pse__End_Date__c = budget.End_Date__c;
            insert schedule;
            
            System.debug('----- Inserted schedule : ' + schedule);
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            
            pse__Assignment__c assignment = new pse__Assignment__c();
            assignment.pse__Schedule__c = schedule.Id;
            assignment.pse__Bill_Rate__c = 10;
            assignment.pse__Resource__c = contact.Id;
            assignment.pse__Project__c = proj.Id;
            assignment.pse__Is_Billable__c = TRUE;
            assignment.Budget__c = budget.ID;
            assignment.Client_Business_Unit_CBU__c = '4Print';
            insert assignment;
            
            System.debug('----- Inserted assignment : ' + assignment);
            System.debug('----- SOQLs used : ' + Limits.getQueries());            
            
            Test.startTest();            
            budget.Start_Date__c = budget.Start_Date__c.addDays(-1);
            budget.End_Date__c = budget.End_Date__c.addDays(1);
            budget.OLI_Sync_Timestamp__c = System.now();
            update budget;
            
            System.debug('----- SOQLs used : ' + Limits.getQueries());
            Test.stopTest();
            
            List<pse__Assignment__c> assignments = [SELECT Id, Name FROM pse__Assignment__c WHERE Budget__c = :budget.ID];
            System.assertEquals(0,assignments.size());
            
        }        
    }     

    static testMethod void updateBudgetParameters() {
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);

        Contact contact = [SELECT ID, Name FROM Contact LIMIT 1];        
        pse__Region__c region = [SELECT ID, Name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT ID, Name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT ID, Name FROM pse__Grp__c LIMIT 1];   
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];

        System.debug('----- SOQLs used : ' + Limits.getQueries());                         
    
        System.runAs(user) {
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget 2';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;            
            budget.Quantity__c = 2;
            budget.Start_Date__c = Date.today();
            budget.End_Date__c = Date.today().addDays(5);
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;   
            budget.Management_Personnel__c = FALSE;
            insert budget;
    
            System.debug('Inserted budget - ' + budget);

            Test.startTest();
            budget.Management_Personnel__c = TRUE; 
            budget.Quantity__c = 1;
            budget.OLI_Sync_Timestamp__c = System.now();
            update budget;
            Test.stopTest();
                                    
            List<pse__Resource_Request__c> requests = [SELECT ID, Name FROM pse__Resource_Request__c WHERE Budget__c = :budget.ID];
            System.assertEquals(1, requests.size());                       
        }        
    }    
}