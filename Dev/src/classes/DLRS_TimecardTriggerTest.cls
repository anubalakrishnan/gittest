/********************************************************************
Author   :Ashwini B
Date     :22/April/2017
Action   :Test class to deploy DLRS managed trigger in QAPartial
/********************************************************************/
@isTest
global class DLRS_TimecardTriggerTest {

    global static testmethod void calculateTotalSubmittedHours_Test(){
        
        // Create test user
        User objUser = new User();
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
        objUser.ManagerId = UserInfo.getUserId();
        insert objUser;
        System.debug('----- objUser : ' + objUser);
                
        //Create region
        pse__Region__c objRegion = new pse__region__c();
        objRegion.Name = 'Test Region';
        insert objRegion;
        
        //Create practice
        pse__Practice__c objPractice = new pse__practice__c();
        objPractice.Name = 'Test Practice';
        insert objPractice;
        
        //Create Group  
        pse__Grp__c objGroup = new pse__grp__c();
        objGroup.Name = 'Test Group';
        insert objGroup;
            
        // Create test contact
        Contact objContact = new Contact();
        objContact.pse__Salesforce_User__c = objUser.id;
        objContact.firstname = 'Mosaic';
        objContact.lastname = 'Test contact';
        objContact.pse__Is_Resource__c = TRUE;
        objContact.pse__Is_Resource_Active__c = TRUE; 
        objContact.pse__Region__c = objRegion.id;
        objContact.pse__Resource_Role__c = 'Team Lead';
        insert objContact;
            
        // Create project
        pse__Proj__c objProject = new pse__proj__c();
        objProject.name = 'Test project';
        objProject.pse__Project_Type__c = 'Global';
        objProject.pse__Project_Manager__c = objContact.Id;
        objProject.pse__Is_Active__c = TRUE;
        objProject.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
        objProject.Client_BusinessUnit_CBU__c = '4Print';
        objProject.pse__Start_Date__c = System.Today();
        objProject.pse__End_Date__c = System.Today().addDays(14);
        insert objProject;
        
        //Create Permission Control
        pse__Permission_Control__c objPermission = new pse__permission_control__c();
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
        
        //Create Schedule
        pse__Schedule__c objSchedule = new pse__schedule__c();
        objSchedule.pse__Start_Date__c = Date.today();
        objSchedule.pse__End_Date__c = Date.today().addDays(14);
        objSchedule.pse__Scheduled_Hours__c = 20;
        insert objSchedule ;        
            
        Test.startTest();
        
        //Create presales budget        
        pse__Budget__c objBudget = new pse__Budget__c();
        objBudget.Name = 'Test Budget';
        objBudget.pse__Type__c = 'Presales Budget';
        objBudget.pse__Project__c = objProject.Id;
        objBudget.Expected_Cost__c = 100;
        objBudget.Hours_Booked__c = 10;
        objBudget.pse__Amount__c = 300;
        objBudget.Management_Personnel__c = true;
        objBudget.Practice__c = objPractice.id;
        insert objBudget ;                        
        
        //run as test user which is PM on Project
        System.runAs(objUser) 
        {                       
            //Create assignment against Presales Budget
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.Budget__c = objBudget.id; 
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            objAssignment.pse__Status__c = 'Scheduled';
            objAssignment.pse__Planned_Hours__c = 20;
            objAssignment.Enter_Time_over_Assigned_Hours__c = true;
            insert objAssignment;        
            
            //create new timecard
            pse__Timecard_Header__c objTimecard = new pse__Timecard_Header__c();
            objTimecard.pse__Monday_Hours__c = 8;
            objTimecard.pse__Resource__c = objContact.Id;
            objTimecard.pse__Project__c = objProject.Id;
            objTimecard.pse__Assignment__c = objAssignment.id;
            objTimecard.pse__Start_Date__c = System.today();
            objTimecard.pse__End_Date__c = System.today().addDays(6);
            objTimecard.pse__Status__c = 'Submitted';
            insert objTimecard;
            //checking timecard is inserted successfully.
            System.assert([SELECT id FROM pse__Timecard_Header__c  WHERE id = :objTimecard.id LIMIT 1].size() > 0);                           
        } 
        Test.stopTest();
    }
}