@isTest
private class ValidateBudgetTest {
    
    @testSetup static void createTestData() {
        
        // Create test user
        List<User> users = new List<User>();
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
        users.add(user);
        
        User user2 = new User();
        user2.Username = 'testprojuser2@acostamosaic.com';
        user2.LastName = 'Test User 2';
        user2.email = 'testprojuser2@acostamosaic.com';
        user2.alias = 'test2';
        user2.CommunityNickname = 'test name 2';
        user2.TimeZoneSidKey = 'Asia/Kolkata';
        user2.LocaleSidKey = 'en_US';
        user2.EmailEncodingKey = 'UTF-8';
        user2.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
        user2.LanguageLocaleKey = 'en_US';
        users.add(user2);        
        insert users;
        
        System.debug('Inserted users - ' + users);        
        
        Group qGroup = [select Id from Group where Name = '4Print Queue' and Type = 'Queue'];
        
        System.debug('Selected group : ' + qGroup); 
        
        GroupMember grpMem = new GroupMember();
        grpMem.GroupId = qGroup.Id;
        grpMem.UserOrGroupId = user.Id;
        insert grpMem;
        
        System.debug('GroupMember - ' + grpMem);
    }    

    static testMethod void kickOffProjectTest() {
        
        // Create test user
        User user = [SELECT ID, Name FROM User WHERE email='testprojuser@acostamosaic.com' LIMIT 1];        
        System.debug('Inserted user - ' + user);
        
        // Create test contact
        Contact contact = new Contact();
        contact.firstname = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;
        insert contact;
        
        System.debug('Inserted contact - ' + contact);                  

        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        insert proj;
        
        System.debug('Inserted project - ' + proj);
        
        System.runAs(user) {
            proj.Kick_off_Project__c = TRUE;
            String errMsg = '';
            try {
                update proj;
            } catch (DMLException e) {
                System.debug('Inside first exception');
                errMsg = e.getMessage();
                Boolean expectedException = errMsg.containsIgnoreCase('Please ensure that an associated Budget exists of type other than "Presales Budget"') ? true : false;
                System.assertEquals(expectedException, true);
            } catch (exception ex) {
                System.debug('Inside second exception');
                System.debug('Misc exceptions');
            }            
        }                
    }       
    
    static testMethod void closeCompleteProjectTest() {        
            
        User user = [SELECT ID, Name FROM User WHERE email='testprojuser@acostamosaic.com' LIMIT 1];
        User user2 = [SELECT ID, Name FROM User WHERE email='testprojuser2@acostamosaic.com' LIMIT 1];
        
        // Create test contact
        List<Contact> contacts = new List<Contact>();
            
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE; 
        contact.pse__Salesforce_User__c = user.Id;
        contacts.add(contact);                     
        
        // Create another test contact
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test';
        contact2.lastname = 'Test contact 2';
        contact2.pse__Is_Resource__c = TRUE;
        contact2.pse__Is_Resource_Active__c = TRUE; 
        contact2.pse__Salesforce_User__c = UserInfo.getUserId();
        contacts.add(contact2);  
        
        // Create another test contact
        Contact contact3 = new Contact();
        contact3.firstname = 'Test';
        contact3.lastname = 'Test contact 3';
        contact3.pse__Is_Resource__c = TRUE;
        contact3.pse__Is_Resource_Active__c = TRUE; 
        contact3.pse__Salesforce_User__c = user2.ID;
        contacts.add(contact3);        
        
        insert contacts;        
        System.debug('Inserted contacts - ' + contacts); 
        
        // Create project
        List<pse__proj__c> projects = new List<pse__proj__c>();
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        projects.add(proj);                 
        
        // Create project
        pse__proj__c proj2 = new pse__proj__c();
        proj2.name = 'Test project 2';
        proj2.pse__Project_Type__c = 'Internal';
        proj2.pse__Project_Manager__c = contact.Id;
        proj2.pse__Is_Active__c = TRUE;
        proj2.Services_Sub_Services__c = 'Other - Other';
        proj2.pse__Is_Billable__c = TRUE;
        proj2.pse__Stage__c = 'In Planning';
        projects.add(proj2);
        
        // Create project
        pse__proj__c proj3 = new pse__proj__c();
        proj3.name = 'Test project 3';
        proj3.pse__Project_Type__c = 'Internal';
        proj3.pse__Project_Manager__c = contact.Id;
        proj3.pse__Is_Active__c = TRUE;
        proj3.Services_Sub_Services__c = 'Other - Other';
        proj3.pse__Is_Billable__c = TRUE;
        proj3.pse__Stage__c = 'In Planning';
        projects.add(proj3);        
        
        insert projects;        
        System.debug('Inserted projects - ' + projects);        
        
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
        
        List<pse__permission_control__c> permissions = new List<pse__permission_control__c>();
        
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
        perm.pse__Resource__c = contact2.Id;
        permissions.add(perm);
        
        pse__permission_control__c perm2 = new pse__permission_control__c();
        perm2.pse__User__c = user.Id;
        perm2.pse__Region__c = region.Id;
        perm2.pse__Practice__c = prac.Id;
        perm2.pse__Group__c = grp.Id;
        perm2.pse__Resource_Request_Entry__c = TRUE;
        perm2.pse__Project__c = proj2.Id;
        perm2.pse__Staffing__c = TRUE;
        perm2.pse__Start_Date__c = Date.today().addDays(-10);
        perm2.pse__End_Date__c = Date.today().addDays(30);
        perm2.pse__Resource__c = contact2.Id;        
        permissions.add(perm2);
        
        pse__permission_control__c perm3 = new pse__permission_control__c();
        perm3.pse__User__c = user.Id;
        perm3.pse__Region__c = region.Id;
        perm3.pse__Practice__c = prac.Id;
        perm3.pse__Group__c = grp.Id;
        perm3.pse__Resource_Request_Entry__c = TRUE;
        perm3.pse__Project__c = proj3.Id;
        perm3.pse__Staffing__c = TRUE;
        perm3.pse__Start_Date__c = Date.today().addDays(-10);
        perm3.pse__End_Date__c = Date.today().addDays(30);
        perm3.pse__Resource__c = contact3.Id;        
        permissions.add(perm3);        
        
        insert permissions;        
        System.debug('Inserted perm - ' + permissions);
        
        List<pse__Budget__c> budgets = new List<pse__Budget__c>();
        
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Test Budget';
        budget.pse__Type__c = 'Presales Budget';
        budget.pse__Project__c = proj.Id;
        budget.Practice__c = prac.ID;
        budget.Management_Personnel__c = TRUE;
        budgets.add(budget);                
        
        pse__Budget__c budget2 = new pse__Budget__c();
        budget2.Name = 'Test Budget 2';
        budget2.pse__Type__c = 'Presales Budget';
        budget2.pse__Project__c = proj2.Id;
        budget2.Practice__c = prac.ID;
        budget2.Management_Personnel__c = TRUE;
        budgets.add(budget2);
        
        pse__Budget__c budget3 = new pse__Budget__c();
        budget3.Name = 'Test Budget 3';
        budget3.pse__Type__c = 'Presales Budget';
        budget3.pse__Project__c = proj3.Id;
        budget3.Practice__c = prac.ID;
        budget3.Management_Personnel__c = TRUE;
        budgets.add(budget3);        
        
        insert budgets;
        System.debug('Inserted budgets - ' + budgets);          
        
        Test.startTest();
        
        System.runAs(user) {
            
            List<pse__Schedule__c> schedules = new List<pse__Schedule__c>();
            
            pse__schedule__c schedule = new pse__schedule__c();
            schedule.pse__Start_Date__c = Date.today();
            schedule.pse__End_Date__c = Date.today().addDays(5);
            schedules.add(schedule);
            
            pse__schedule__c schedule2 = new pse__schedule__c();
            schedule2.pse__Start_Date__c = Date.today();
            schedule2.pse__End_Date__c = Date.today().addDays(5);
            schedules.add(schedule2);
            
            pse__schedule__c schedule3 = new pse__schedule__c();
            schedule3.pse__Start_Date__c = Date.today();
            schedule3.pse__End_Date__c = Date.today().addDays(5);
            schedules.add(schedule3);            
            
            System.debug('----- Inserted schedules : ' + schedules);            
            insert schedules;                        

            List<pse__Assignment__c> assignments = new List<pse__Assignment__c>();
            
            pse__Assignment__c assignment = new pse__Assignment__c();
            assignment.pse__Schedule__c = schedule.Id;
            assignment.pse__Bill_Rate__c = 10;
            assignment.pse__Resource__c = contact2.Id;
            assignment.pse__Project__c = proj.Id;
            assignment.pse__Is_Billable__c = TRUE;
            assignment.Budget__c = budget.ID;
            assignment.Client_Business_Unit_CBU__c = '4Print';
            assignments.add(assignment);
            
            pse__Assignment__c assignment2 = new pse__Assignment__c();
            assignment2.pse__Schedule__c = schedule2.Id;
            assignment2.pse__Bill_Rate__c = 10;
            assignment2.pse__Resource__c = contact2.Id;
            assignment2.pse__Project__c = proj2.Id;
            assignment2.pse__Is_Billable__c = TRUE;
            assignment2.Budget__c = budget2.ID;
            assignment2.Client_Business_Unit_CBU__c = '4Print';
            assignments.add(assignment2); 
            
            pse__Assignment__c assignment3 = new pse__Assignment__c();
            assignment3.pse__Schedule__c = schedule3.Id;
            assignment3.pse__Bill_Rate__c = 10;
            assignment3.pse__Resource__c = contact3.Id;
            assignment3.pse__Project__c = proj3.Id;
            assignment3.pse__Is_Billable__c = TRUE;
            assignment3.Budget__c = budget3.ID;
            assignment3.Client_Business_Unit_CBU__c = '4Print';
            assignments.add(assignment3);             
            
            insert assignments;            
            System.debug('----- Inserted assignment : ' + assignments);   
            
            //Update project manager
            proj.pse__Project_Manager__c = contact2.Id;            
            update proj;                                                
                        
            projects[0].pse__Stage__c = 'Ready to Close';
            projects[1].pse__Stage__c = 'Ready to Close';
            
            update projects;
            
            proj.pse__Stage__c = 'Ready to Close';
            update proj;  
            
            List<ContactShare> conShares = [SELECT Id FROM ContactShare WHERE ContactId = :contact3.Id AND RowCause = 'Manual'];
            System.assertEquals(0, conShares.size());
            
        }     
        
        Test.stopTest();
        
    }
}