/********************************************************************
Author   :Suman Gupta
Date     :24/March/2017
Action   :This is test class of Trigger 'TriggerOnProject' and handler class 'ProjectTriggerHandler_version2'
/********************************************************************/
@isTest
public class ProjectTriggerTracker {
    
    //This method covers the method 'validateReadyToCloseByCSTStage' of class 'ProjectTriggerHandler_version2'
    public static testmethod void validateReadyToCloseByCSTStage_Test()
    {
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user 
        System.runAs(lstUser[0]) 
        {
            Test.startTest();
            //Get the records created by test setup method 
            List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
            
            //create new Timecard
            pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
        	objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = lstContact[0].id;
            objTimecard.pse__Project__c = lstProject[0].id;
            objTimecard.pse__Assignment__c = lstAssignment[0].id;
            objTimecard.pse__Start_Date__c = System.today();
            objTimecard.pse__End_Date__c = System.today().addDays(6);
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
            
            //create new Milestone
            pse__Milestone__c objMilestone = new pse__Milestone__c();
            objMilestone.Name = 'Test Milestone';
            objMilestone.pse__Target_Date__c = System.today();
            objMilestone.pse__Milestone_Amount__c = 4000;
        	objMilestone.pse__Project__c = lstProject[0].id;
            objMilestone.Milestone__c = 1;
            objMilestone.pse__Status__c = 'Open';
            insert objMilestone;
            
        	//checking Milestone is inserted successfully.
            System.assert([SELECT id FROM pse__Milestone__c WHERE id = :objMilestone.id LIMIT 1].size() > 0);
            try
            {
                //update stage to 'Ready to Close by CST'
                pse__proj__c objProject = new pse__proj__c(id = lstProject[0].id);
                objProject.pse__Stage__c = 'Ready to Close by CST';
                update objProject;
                Test.stopTest();
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Project_Ready_to_Close_by_CST_Validation) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
        }
        
    }
    
    //This method covers the method 'validateReadyToCloseStage' of class 'ProjectTriggerHandler_version2'
    public static testmethod void validateReadyToCloseStage_Test()
    {
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user 
        System.runAs(lstUser[0]) 
        {
            Test.startTest();
            //Get the records created by test setup method 
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            
            //create new Milestone
            pse__Milestone__c objMilestone = new pse__Milestone__c();
            objMilestone.Name = 'Test Milestone';
            objMilestone.pse__Target_Date__c = System.today();
            objMilestone.pse__Milestone_Amount__c = 4000;
        	objMilestone.pse__Project__c = lstProject[0].id;
            objMilestone.Milestone__c = 1;
            objMilestone.pse__Status__c = 'Approved';
            insert objMilestone;
            
        	//checking Milestone is inserted successfully.
            System.assert([SELECT id FROM pse__Milestone__c WHERE id = :objMilestone.id LIMIT 1].size() > 0);
            try
            {
                //update stage to 'Ready to Close'
                pse__proj__c objProject = new pse__proj__c(id = lstProject[0].id);
                objProject.pse__Stage__c = 'Ready to Close';
                update objProject;
                Test.stopTest();
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Project_ReadyToClose_Validation) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
        }
    }
    //Create test data 
    @testSetup static void LoadTestData()
    {
        User objTestAnotherUser;
        User objTestUser;
        User objUser;
        pse__region__c objRegion;
        pse__practice__c objPractice;
        pse__grp__c objGroup;
        Contact objContact;
        Contact objTestContact;
        pse__proj__c objProject;
        pse__Budget__c objBudget;
        pse__permission_control__c objPermission;
        pse__permission_control__c objAnotherPermission;
        pse__schedule__c objSchedule;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
            // Create test user
            objTestAnotherUser = new User();
            objTestAnotherUser.Username = 'anothermanageruser@acostamosaic.com';
            objTestAnotherUser.LastName = 'Another Manager User';
            objTestAnotherUser.email = 'anothermanageruser@acostamosaic.com';
            objTestAnotherUser.alias = 'amanager';
            objTestAnotherUser.CommunityNickname = 'another manager name';
            objTestAnotherUser.TimeZoneSidKey = 'Asia/Kolkata';
            objTestAnotherUser.LocaleSidKey = 'en_US';
            objTestAnotherUser.EmailEncodingKey = 'UTF-8';
            objTestAnotherUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objTestAnotherUser.LanguageLocaleKey = 'en_US';
            insert objTestAnotherUser;
            
            // Create test user
            objTestUser = new User();
            objTestUser.Username = 'manageruser@acostamosaic.com';
            objTestUser.LastName = 'Manager User';
            objTestUser.email = 'manageruser@acostamosaic.com';
            objTestUser.alias = 'manager';
            objTestUser.CommunityNickname = 'manager name';
            objTestUser.TimeZoneSidKey = 'Asia/Kolkata';
            objTestUser.LocaleSidKey = 'en_US';
            objTestUser.EmailEncodingKey = 'UTF-8';
            objTestUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objTestUser.LanguageLocaleKey = 'en_US';
            //objTestUser.ManagerId = objTestAnotherUser.id;
            insert objTestUser;
            
            // Create test user
            objUser = new User();
            objUser.Username = 'testuser@acostamosaic.com';
            objUser.LastName = 'Test User';
            objUser.email = 'testuser@acostamosaic.com';
            objUser.alias = 'test';
            objUser.CommunityNickname = 'test name';
            objUser.TimeZoneSidKey = 'Asia/Kolkata';
            objUser.LocaleSidKey = 'en_US';
            objUser.EmailEncodingKey = 'UTF-8';
            objUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objUser.LanguageLocaleKey = 'en_US';
            objUser.ManagerId = objTestUser.id;
            insert objUser;
            
            //Create region
            objRegion = new pse__region__c();
            objRegion.Name = 'Test Region';
            insert objRegion;
            
            //Create practice
            objPractice = new pse__practice__c();
            objPractice.Name = 'Test Practice';
            insert objPractice;
            
            //Create Group  
            objGroup = new pse__grp__c();
            objGroup.Name = 'Test Group';
            insert objGroup;
            
            // Create test contact
            objContact = new Contact();
            objContact.pse__Salesforce_User__c = objUser.id;
            objContact.firstname = 'Mosaic';
            objContact.lastname = 'Test contact';
            objContact.pse__Is_Resource__c = TRUE;
            objContact.pse__Is_Resource_Active__c = TRUE; 
            objContact.pse__Region__c = objRegion.id;
            objContact.pse__Resource_Role__c = 'Team Lead';
            insert objContact;
            
            // Create Another contact
            objTestContact = new Contact();
            objTestContact.pse__Salesforce_User__c = objTestUser.id;
            objTestContact.firstname = 'Mosaic';
            objTestContact.lastname = 'Test Another contact';
            objTestContact.pse__Is_Resource__c = TRUE;
            objTestContact.pse__Is_Resource_Active__c = TRUE; 
            objTestContact.pse__Region__c = objRegion.id;
            objTestContact.pse__Resource_Role__c = 'Team Lead';
            insert objTestContact;
            
            // Create project
            objProject = new pse__proj__c();
            objProject.name = 'Test project';
            objProject.pse__Project_Type__c = 'Global';
            objProject.pse__Project_Manager__c = objContact.Id;
            objProject.pse__Is_Active__c = TRUE;
            objProject.Services_Sub_Services__c = 'Brand Management - Staff Augmentation';
            objProject.Client_BusinessUnit_CBU__c = '4Print';
            objProject.pse__Start_Date__c = System.Today();
            objProject.pse__End_Date__c = System.Today().addDays(14);
            objProject.pse__Stage__c = 'In Planning';
            insert objProject;
            
            //Create presales budget        
            objBudget = new pse__Budget__c();
            objBudget.Name = 'Test Budget';
            objBudget.pse__Type__c = 'Presales Budget';
            objBudget.pse__Project__c = objProject.Id;
            objBudget.Expected_Cost__c = 100;
            objBudget.Hours_Booked__c = 10;
            objBudget.pse__Amount__c = 300;
            objBudget.Management_Personnel__c = true;
            objBudget.pse__Status__c = 'Draft';
            objBudget.Practice__c = objPractice.id;
            objBudget.Management_Personnel__c = true;
            insert objBudget ;
            
            //Create Permission Control
            objPermission = new pse__permission_control__c();
            objPermission.pse__User__c = objUser.Id;
            objPermission.pse__Region__c = objRegion.Id;
            objPermission.pse__Practice__c = objPractice.Id;
            objPermission.pse__Group__c = objGroup.Id;
            objPermission.pse__Resource_Request_Entry__c = TRUE;
            objPermission.pse__Project__c = objProject.Id;
            objPermission.pse__Staffing__c = TRUE;
            objPermission.pse__Start_Date__c = Date.today().addDays(-10);
            objPermission.pse__End_Date__c = Date.today().addDays(30);
            objPermission.pse__Resource__c = objContact.Id;
            insert objPermission;
            
            //Create Another Permission Control
            objAnotherPermission = new pse__permission_control__c();
            objAnotherPermission.pse__User__c = objTestUser.Id;
            objAnotherPermission.pse__Region__c = objRegion.Id;
            objAnotherPermission.pse__Practice__c = objPractice.Id;
            objAnotherPermission.pse__Group__c = objGroup.Id;
            objAnotherPermission.pse__Resource_Request_Entry__c = TRUE;
            objAnotherPermission.pse__Project__c = objProject.Id;
            objAnotherPermission.pse__Staffing__c = TRUE;
            objAnotherPermission.pse__Start_Date__c = Date.today().addDays(-10);
            objAnotherPermission.pse__End_Date__c = Date.today().addDays(30);
            objAnotherPermission.pse__Resource__c = objTestContact.Id;
            insert objAnotherPermission;
            
            //Create Schedule
           	objSchedule = new pse__schedule__c();
            objSchedule.pse__Start_Date__c = Date.today();
            objSchedule.pse__End_Date__c = Date.today().addDays(14);
            objSchedule.pse__Scheduled_Hours__c = 20;
            insert objSchedule ;
        }
        //run as test user which is PM on Project
        System.runAs(objUser) 
        {
            //Create assignment against Presales Budget
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objTestContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.Budget__c = objBudget.id; 
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            objAssignment.pse__Status__c = 'Scheduled';
            objAssignment.pse__Planned_Hours__c = 20;
            objAssignment.Enter_Time_over_Assigned_Hours__c = true;
            insert objAssignment;
        }
    }
}