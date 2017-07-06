@isTest
public class ResourceRequestTriggerTest {
    
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
        
        // Create test contact
        Contact contact = new Contact();
        contact.firstname = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;
        contact.Client_Business_Unit_CBU__c = '4Print';        
        insert contact;
        
        System.debug('Inserted contact - ' + contact);    
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.Client_BusinessUnit_CBU__c = '4Print';
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
        budget.pse__Type__c = 'Presales';
        budget.pse__Project__c = proj.Id;
        budget.Practice__c = prac.ID;
        budget.Management_Personnel__c = TRUE;
        insert budget;
        
        System.debug('Inserted budget - ' + budget); 
        
        List<pse__permission_control__c> permissions = new List<pse__permission_control__c>();
        
        pse__permission_control__c perm = new pse__permission_control__c();
        perm.pse__User__c = User.Id;
        perm.pse__Region__c = region.Id;
        perm.pse__Practice__c = prac.Id;
        perm.pse__Group__c = grp.Id;
        perm.pse__Resource_Request_Entry__c = TRUE;
        perm.pse__Project__c = proj.Id;
        perm.pse__Staffing__c = TRUE;
        perm.pse__Start_Date__c = Date.today().addDays(-10);
        perm.pse__End_Date__c = Date.today().addDays(30);
        perm.pse__Resource__c = contact.Id;
        
        permissions.add(perm);
        
        pse__permission_control__c perm2 = new pse__permission_control__c();
        perm2.pse__User__c = UserInfo.getUserId();
        perm2.pse__Region__c = region.Id;
        perm2.pse__Practice__c = prac.Id;
        perm2.pse__Group__c = grp.Id;
        perm2.pse__Resource_Request_Entry__c = TRUE;
        perm2.pse__Project__c = proj.Id;
        perm2.pse__Staffing__c = TRUE;
        perm2.pse__Start_Date__c = Date.today().addDays(-10);
        perm2.pse__End_Date__c = Date.today().addDays(30);
        perm2.pse__Resource__c = contact.Id;        
        
        permissions.add(perm2);
        
        insert permissions;
        
        System.debug('Inserted permissions - ' + permissions);
        
        pse__schedule__c schedule = new pse__schedule__c();
        schedule.pse__Start_Date__c = Date.today();
        schedule.pse__End_Date__c = Date.today().addDays(5);
        insert schedule;
            
        System.debug('----- Inserted schedule : ' + schedule);  
        
        Sub_Account_Lookup__c subAcc = new Sub_Account_Lookup__c();
        subAcc.Name = 'Field Management';
        subAcc.Role__c = 'Team Lead';
        insert subAcc;
        
        System.debug('----- Inserted sub account : ' + subAcc);  
        
        Test.startTest(); 
            ResourceRequestTriggerTest.createGroupMember(UserInfo.getUserId());
        Test.stopTest();

        pse__Assignment__c assignment = new pse__Assignment__c();
        assignment.pse__Schedule__c = schedule.Id;
        assignment.pse__Bill_Rate__c = 10;
        assignment.pse__Resource__c = contact.Id;
        assignment.pse__Project__c = proj.Id;
        assignment.Budget__c = budget.Id;
        assignment.pse__Is_Billable__c = TRUE;
        assignment.Client_Business_Unit_CBU__c = '4Print';
        
        insert assignment;
        System.debug('----- Inserted assignment : ' + assignment);        
        
    }
    
    @future
    static void createGroupMember(Id uId) {
        
        Group qGroup = [select Id from Group where Name = '4Print Queue' and Type = 'Queue'];
        
        System.debug('Selected group : ' + qGroup); 
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Id = :uId];   
        
        System.debug('----- Fetched user : ' + user);
        
        GroupMember grpMem = new GroupMember();
        grpMem.GroupId = qGroup.Id;
        grpMem.UserOrGroupId = user.Id;
        insert grpMem;
        
        System.debug('GroupMember - ' + grpMem); 
    }
    
    static testMethod void notGroupMemberCreateRequest() {                      
        
        User user = [SELECT id, name, email
                       FROM User 
                      WHERE Username = 'testprojuser@acostamosaic.com' LIMIT 1];
        
        System.debug('----- Fetched user : ' + user);
        
        pse__Budget__c budget = [SELECT id, name FROM pse__Budget__c LIMIT 1];
        pse__Proj__c proj = [SELECT id, name FROM pse__Proj__c LIMIT 1];
        pse__Region__c region = [SELECT id, name FROM pse__Region__c LIMIT 1];
        pse__Practice__c prac = [SELECT id, name FROM pse__Practice__c LIMIT 1];
        pse__Grp__c grp = [SELECT id, name FROM pse__Grp__c LIMIT 1];
        Contact contact = [SELECT id, name FROM Contact LIMIT 1];
        pse__assignment__c assignment = [SELECT id, name FROM pse__assignment__c LIMIT 1];                
        
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
        request.pse__Resource_Role__c = 'Team Lead';        
        request.Services_Sub_Services__c = 'Other - Other';
        request.pse__Requested_Bill_Rate__c = 10; 
        
        System.runAs(user) {              

            insert request;
            
            request.pse__Status__c = 'Cancelled';
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 1 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Cancelled_Message) ? true : false;
                System.assertEquals(true, err);
            }
            
            request.pse__Status__c = 'Not Fulfilled';
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 2 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Not_Fulfilled_Message) ? true : false;
                System.assertEquals(true, err);                
            }

            request.pse__Status__c = 'Ready To Staff';
            request.Client_Business_Unit_CBU__c = 'CHI1';    
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 3 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_CBU_Change_Message) ? true : false;
                System.assertEquals(true, err);
            }   
            
            request.pse__Resource_Held__c = TRUE;
            request.pse__Staffer_Resource__c = Contact.ID;
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 4 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Soft_Book_Insufficient_Privileges_Message) ? true : false;
                System.assertEquals(true, err);
            } 

            request.pse__Resource_Held__c = FALSE;
            request.pse__Staffer_Resource__c = NULL;
            request.pse__Assignment__c = assignment.Id;
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 5 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Assignment_Insufficient_Privileges_Message) ? true : false;
                System.assertEquals(true, err);
            } 
            
            Test.startTest();
                ResourceRequestTriggerTest.createGroupMember(User.Id);
            Test.stopTest();
            
            request.Client_Business_Unit_CBU__c = '4Print';
            request.pse__Resource_Held__c = TRUE;
            request.pse__Staffer_Resource__c = Contact.ID;
            request.pse__Assignment__c = NULL;
            request.pse__Status__c = 'Not Fulfilled';
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 6 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Soft_Book_Message) ? true : false;
                System.assertEquals(true, err);
            } 
            
            request.pse__Resource_Held__c = FALSE;
            request.pse__Staffer_Resource__c = Contact.ID;
            request.pse__Assignment__c = assignment.ID;
            request.pse__Status__c = 'Not Fulfilled';
            try {
                update request;     
            } catch (exception e) {
                System.debug('----- error msg 7 : ' + e.getMessage());
                Boolean err = e.getMessage().containsIgnoreCase(Label.Resource_Request_Assignment_Message) ? true : false;
                System.assertEquals(true, err);
            }             
            
        }
        
    }
}