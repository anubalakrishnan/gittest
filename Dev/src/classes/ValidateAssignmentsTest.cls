@isTest
global class ValidateAssignmentsTest {

    global static testMethod void resourceRequestTest() {
        
        // Create test user
        User user = new User();
        user.Username = 'testprojuser3@acostamosaic.com';
        user.LastName = 'Test User';
        user.email = 'testprojuser3@acostamosaic.com';
        user.alias = 'test';
        user.CommunityNickname = 'test name';
        user.TimeZoneSidKey = 'Asia/Kolkata';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
        user.LanguageLocaleKey = 'en_US';
        
        insert user;
        
        System.debug('Inserted user - ' + user);
            
        // Create test contact
        Contact contact = new Contact();
        contact.firstname = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE; 
        contact.pse__Salesforce_User__c = user.Id;
        insert contact;
        
        System.debug('Inserted contact - ' + contact);
        
        // Create another test contact
        Contact contact2 = new Contact();
        contact2.firstname = 'Mosaic';
        contact2.lastname = 'Test contact 2';
        contact2.pse__Is_Resource__c = TRUE;
        contact2.pse__Is_Resource_Active__c = TRUE; 
        contact2.pse__Salesforce_User__c = UserInfo.getUserId();
        insert contact2;
        
        System.debug('Inserted contact 2 - ' + contact2);        
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        insert proj;
        
        System.debug('Inserted project - ' + proj);            
        
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
        
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Test Budget';
        budget.pse__Type__c = 'Presales Budget';
        budget.pse__Project__c = proj.Id;
        budget.Practice__c = prac.Id;
        budget.Management_Personnel__c = TRUE;
        insert budget;
        
        System.debug('Inserted budget - ' + budget);         
        
        pse__permission_control__c perm = new pse__permission_control__c();
        perm.pse__User__c = user.Id;
        perm.pse__Region__c = region.Id;
        perm.pse__Practice__c = prac.Id;
        perm.pse__Group__c = grp.Id;
        perm.pse__Resource_Request_Entry__c = TRUE;
        perm.pse__Project__c = proj.Id;
        perm.pse__Staffing__c = TRUE;
        perm.pse__Start_Date__c = Date.today().addDays(-10);
        perm.pse__End_Date__c = Date.today().addDays(30);
        perm.pse__Resource__c = contact.Id;
        insert perm;
        
        System.debug('Inserted perm - ' + perm);
        
        System.runAs(user) {
            
            Test.startTest();
            
            pse__Resource_Request__c request = new pse__Resource_Request__c();
            request.Client_Business_Unit_CBU__c = '4Print';
            request.Budget__c = budget.Id;
            request.pse__Project__c = proj.Id;
            request.pse__Region__c = region.Id;
            request.pse__Practice__c = prac.Id;
            request.pse__Group__c = grp.Id;
            request.pse__Staffer_Resource__c = contact.Id;
            request.pse__Requested_Bill_Rate__c = 100;
            request.pse__SOW_Hours__c = 40;
            request.pse__Start_Date__c = Date.today();
            request.pse__End_Date__c = Date.today().addDays(10);
            request.pse__Resource_Role__c = 'Buyer';
            // request.Sub_Account__c = 'Procurement';
            request.Services_Sub_Services__c = 'Other - Other';
            request.pse__Requested_Bill_Rate__c = 10;
            insert request;
            
            System.debug('----- Inserted request : ' + request);
            
            PageReference pageRef = new PageReference('/apex/pse__assignresource');
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('id', request.Id);
            
            pse__schedule__c schedule = new pse__schedule__c();
            schedule.pse__Start_Date__c = Date.today();
            schedule.pse__End_Date__c = Date.today().addDays(5);
            insert schedule;
            
            System.debug('----- Inserted schedule : ' + schedule);
            
            pse__Assignment__c assignment = new pse__Assignment__c();
            assignment.pse__Schedule__c = schedule.Id;
            assignment.pse__Bill_Rate__c = 10;
            assignment.pse__Resource__c = contact.Id;
            assignment.pse__Project__c = proj.Id;
            assignment.pse__Is_Billable__c = TRUE;
            insert assignment;
            
            System.debug('----- Inserted assignment : ' + assignment);     
            
            // Update project manager
            proj.pse__Project_Manager__c = contact2.Id;            
            update proj;
            
            System.debug('----- Updated project : ' + proj);  
            
            Test.stopTest();
            
        }            
    }
}