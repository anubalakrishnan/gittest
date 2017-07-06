@isTest
public class ScheduleTriggerTest {

    private static testMethod void updateSchedulesTest() {
        
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
        contact.firstname = 'Test First';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE; 
        contact.pse__Salesforce_User__c = user.Id;
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
        budget.Practice__c = prac.ID;
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
            
            pse__schedule__c schedule = new pse__schedule__c();
            schedule.pse__Start_Date__c = Date.today();
            schedule.pse__End_Date__c = Date.today().addDays(5);
            schedule.pse__Scheduled_Hours__c = 8;
            insert schedule;
            
            System.debug('----- Inserted schedule : ' + schedule);
            
            pse__Assignment__c assignment = new pse__Assignment__c();
			assignment.pse__Schedule__c = schedule.ID;            
            assignment.pse__Bill_Rate__c = 10;
            assignment.pse__Resource__c = contact.Id;
            assignment.pse__Project__c = proj.Id;
            assignment.pse__Is_Billable__c = TRUE;
            assignment.Budget__c = budget.ID;
            assignment.Client_Business_Unit_CBU__c = '4Print';
            assignment.pse__Planned_Hours__c = 10;
            insert assignment;
            
            System.debug('----- Inserted assignment : ' + assignment);                                     
            
            Test.startTest();
            schedule.pse__Scheduled_Hours__c = 6;
            update schedule;    
            
			assignment = [SELECT ID, name, Scheduled_Hours_Rollup__c FROM pse__assignment__c WHERE ID = :assignment.ID];            
            System.assertEquals(6, assignment.Scheduled_Hours_Rollup__c);            
            
            delete schedule;

            assignment = [SELECT ID, name, Scheduled_Hours_Rollup__c FROM pse__assignment__c WHERE ID = :assignment.ID];            
            System.assertEquals(0, assignment.Scheduled_Hours_Rollup__c);
            			
        }            
    } 
    
    private static testMethod void insertSchedulesTest() {
    
        PageReference pageRef = new PageReference('/apex/pse__assignresource');
        Test.setCurrentPage(pageRef);
        
        pse__schedule__c schedule = new pse__schedule__c();
        schedule.pse__Start_Date__c = Date.today();
        schedule.pse__End_Date__c = Date.today().addDays(5);
        insert schedule;
        
    }
}