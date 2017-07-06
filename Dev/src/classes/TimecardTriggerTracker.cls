/********************************************************************
Author   :Suman Gupta
Date     :03/March/2017
Action   :This is test class of Trigger 'TriggerOnTimecard'
	     :This is test class of Apex Schedulers 'TimecardApprovalReminder' and 'TimecardSubmissionReminder'
/********************************************************************/
@isTest
global class TimecardTriggerTracker {

    //This method covers the method 'validateRejectionComments' of class 'TimecardTriggerHandler'
    public static testmethod void validateRejectionComments_Test()
    {
        pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
        
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user
        System.runAs(lstUser[0])
        {
            Test.startTest();
            
            //Get the data created by test setup method 
            List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
            //create new Timecard
        	objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = lstContact[0].id;
            objTimecard.pse__Project__c = lstProject[0].id;
            objTimecard.pse__Assignment__c = lstAssignment[0].id;
            objTimecard.pse__Start_Date__c = System.today();
            objTimecard.pse__End_Date__c = System.today().addDays(6);
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
            
            //update Timecard
            objTimecard.pse__Status__c = 'Submitted';
            update objTimecard;
            //checking timecard is updated successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Status__c = 'Submitted' LIMIT 1].size() > 0);
            
            //get approval process detail which is auto submitted
            List<ProcessInstanceWorkitem> lstWorkItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem 
                                                       WHERE ProcessInstance.TargetObjectId = :objTimecard.id limit 1];
            try
            {
                // Reject the submitted request, without providing a comment.
                Approval.ProcessWorkitemRequest objRejection = new Approval.ProcessWorkitemRequest();
                objRejection.setComments('');
                objRejection.setAction('Reject');      
                objRejection.setWorkitemId(lstWorkItems[0].id);
                
            	// Attempt to process the rejection
                Approval.ProcessResult objRejectionResult =  Approval.process(objRejection);
                
            	Test.stopTest();
        	}
        	catch (DMLException objException) 
        	{
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Timecard_Mandatory_Rejection_Comments) ? true : false;
                System.assertEquals(isExpectedException, true);
			}
        }
    }
    
    //This method covers the method 'timecardRejectionNotification' of class 'TimecardTriggerHandler'
    public static testmethod void timecardRejectionNotification_Test()
    {
        pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
        
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user which is PM on Project
        System.runAs(lstUser[0])
        {
            Test.startTest();
            
            //Get the data created by test setup method 
            List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
            //create new Timecard
        	objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = lstContact[0].id;
            objTimecard.pse__Project__c = lstProject[0].id;
            objTimecard.pse__Assignment__c = lstAssignment[0].id;
            objTimecard.pse__Start_Date__c = System.today();
            objTimecard.pse__End_Date__c = System.today().addDays(6);
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
            
            //update Timecard
            objTimecard.pse__Status__c = 'Submitted';
            update objTimecard;
            //checking timecard is updated successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Status__c = 'Submitted' LIMIT 1].size() > 0);
            
            //get approval process detail which is auto submitted
            List<ProcessInstanceWorkitem> lstWorkItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem 
                                                       WHERE ProcessInstance.TargetObjectId = :objTimecard.id limit 1];
            
            // Reject the submitted request, with providing a comment.
            Approval.ProcessWorkitemRequest objRejection = new Approval.ProcessWorkitemRequest();
            objRejection.setComments('Rejection Comments');
            objRejection.setAction('Reject');      
            objRejection.setWorkitemId(lstWorkItems[0].id);
            
            // Attempt to process the rejection
            Approval.ProcessResult objRejectionResult =  Approval.process(objRejection);
            
            //checking timecard is rejected successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Status__c = 'Rejected' LIMIT 1].size() > 0);
            
            Test.stopTest();
        }
    }
    
    //This method covers the method 'calculateTotalSubmittedHours' of class 'TimecardTriggerHandler'
    global static testmethod void calculateTotalSubmittedHours_Test()
    {
        System.debug('----- Entered calculateTotalSubmittedHours_Test');
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        System.debug('----- lstUser : ' + lstUser);
        //run as test user which is PM on Project
        if (lstUser != null && lstUser.size() > 0) {
            System.runAs(lstUser[0])
            {
                Test.startTest();
                //Get the data created by test setup method 
                List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
                List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
                List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
                //create new timecard
                pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
                objTimecard.pse__Monday_Hours__c = 8;
                objTimecard.pse__Resource__c = lstContact[0].id;
                objTimecard.pse__Project__c = lstProject[0].id;
                objTimecard.pse__Assignment__c = lstAssignment[0].id;
                objTimecard.pse__Start_Date__c = System.today();
                objTimecard.pse__End_Date__c = System.today().addDays(6);
                objTimecard.pse__Status__c = 'Submitted';
                insert objTimecard;
                //checking timecard is inserted successfully.
                System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
                
                //update status to Approved
                objTimecard.pse__Status__c = 'Approved';
                update objTimecard;
                //checking timecard is updated successfully.
                System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Status__c = 'Approved' LIMIT 1].size() > 0);
                
                //update Assignment
                objTimecard.pse__Assignment__c = lstAssignment[1].id;
                update objTimecard;
                //checking timecard is updated successfully.
                System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Assignment__c = :lstAssignment[1].id LIMIT 1].size() > 0);
                
                //delete timecard
                delete objTimecard;
                //checking timecard is deleted successfully.
                System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() == 0);
                Test.stopTest();
            }
        }
    }
    
    //This method covers the Scheduler class 'TimecardApprovalReminder' 
    public static testmethod void TimecardApprovalReminder_Test()
    {
        pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
        
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user which is PM on Project
        System.runAs(lstUser[0])
        {
            Test.startTest();
            
            //Get the data created by test setup method 
            List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
            //create new Timecard
        	objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = lstContact[0].id;
            objTimecard.pse__Project__c = lstProject[0].id;
            objTimecard.pse__Assignment__c = lstAssignment[0].id;
            objTimecard.pse__Start_Date__c = System.today();
            objTimecard.pse__End_Date__c = System.today().addDays(6);
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
            
            //update Timecard
            objTimecard.pse__Status__c = 'Submitted';
            update objTimecard;
            //checking timecard is updated successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id AND pse__Status__c = 'Submitted' LIMIT 1].size() > 0);
            
            //call the scheduler class
            Datetime dt = Datetime.now().addMinutes(1);
        	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            TimecardApprovalReminder approveJob = new TimecardApprovalReminder();
            approveJob.isTestRun = TRUE;
        	String strJobId = System.schedule('TimecardApprovalReminder', CRON_EXP, approveJob); 
            CronTrigger objCronTrigger = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strJobId]; 
			System.assertEquals(CRON_EXP, objCronTrigger.CronExpression);
       		System.assertEquals(0, objCronTrigger.TimesTriggered);
            Test.stopTest();
        }
    }
    
    //This method covers the Scheduler class 'TimecardSubmissionReminder' 
    public static testmethod void TimecardSubmissionReminder_Test()
    {
        pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
        
        //Get the user created by test setup method 
		List<User> lstUser = [Select id from User where name = 'Manager User' limit 1];
        
        //run as test user which is PM on Project
        System.runAs(lstUser[0])
        {
            Test.startTest();
            
            //Get the data created by test setup method 
            List<Contact> lstContact = [Select id from Contact where lastname = 'Test Another contact' limit 1];
            List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
            List<pse__Assignment__c> lstAssignment = [Select id from pse__Assignment__c];
            //create new Timecard
        	objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = lstContact[0].id;
            objTimecard.pse__Project__c = lstProject[0].id;
            objTimecard.pse__Assignment__c = lstAssignment[0].id;
            objTimecard.pse__Start_Date__c = System.today().addDays(-7);
            objTimecard.pse__End_Date__c = System.today().addDays(-1); 
            objTimecard.pse__Status__c = 'Approved';
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);
            
            //call the scheduler class
            Datetime dt = Datetime.now().addMinutes(1);
        	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            TimecardSubmissionReminder submitJob = new TimecardSubmissionReminder();
            submitJob.isTestRun = TRUE;
        	String strJobId = System.schedule('TimecardSubmissionReminder', CRON_EXP, submitJob); 
            CronTrigger objCronTrigger = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strJobId]; 
			System.assertEquals(CRON_EXP, objCronTrigger.CronExpression);
       		System.assertEquals(0, objCronTrigger.TimesTriggered);
            Test.stopTest();
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
        pse__schedule__c objAnotherSchedule;
        list<pse__Assignment__c> lstAssignment = new list<pse__Assignment__c>{};
            
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.debug('----- thisUser : ' + thisUser);
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
            System.debug('----- objTestAnotherUser : ' + objTestAnotherUser);
            
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
            objTestUser.ManagerId = objTestAnotherUser.id;
            insert objTestUser;
            System.debug('----- objTestUser : ' + objTestUser);
            
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
            System.debug('----- objUser : ' + objUser);
            
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
            objContact.firstname = 'Test';
            objContact.lastname = 'Test contact';
            objContact.pse__Is_Resource__c = TRUE;
            objContact.pse__Is_Resource_Active__c = TRUE; 
            objContact.pse__Region__c = objRegion.id;
            objContact.pse__Resource_Role__c = 'Team Lead';
            insert objContact;
            
            // Create Another contact
            objTestContact = new Contact();
            objTestContact.pse__Salesforce_User__c = objTestUser.id;
            objTestContact.firstname = 'Test contact';
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
            objProject.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objProject.Client_BusinessUnit_CBU__c = '4Print';
            objProject.pse__Start_Date__c = System.Today();
            objProject.pse__End_Date__c = System.Today().addDays(14);
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
            objBudget.Practice__c = objPractice.id;
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
            
            //Create Another Schedule
            objAnotherSchedule = new pse__schedule__c();
            objAnotherSchedule.pse__Start_Date__c = Date.today();
            objAnotherSchedule.pse__End_Date__c = Date.today().addDays(14);
            objAnotherSchedule.pse__Scheduled_Hours__c = 20;
            insert objAnotherSchedule;
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
            lstAssignment.add(objAssignment);
            
            //Create assignment against Presales Budget
            pse__Assignment__c objAnotherAssignment = new pse__Assignment__c();
            objAnotherAssignment.pse__Schedule__c = objAnotherSchedule.Id;
            objAnotherAssignment.pse__Bill_Rate__c = 10;
            objAnotherAssignment.pse__Resource__c = objTestContact.Id;
            objAnotherAssignment.pse__Project__c = objProject.Id;
            objAnotherAssignment.Budget__c = objBudget.id; 
            objAnotherAssignment.Client_Business_Unit_CBU__c = '4Print';
            objAnotherAssignment.pse__Status__c = 'Scheduled';
            objAnotherAssignment.pse__Planned_Hours__c = 20;
            objAnotherAssignment.Enter_Time_over_Assigned_Hours__c = true;
            lstAssignment.add(objAnotherAssignment);
            insert lstAssignment;
        
        }
   }
}