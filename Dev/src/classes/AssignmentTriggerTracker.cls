/********************************************************************
Author   :Suman Gupta
Date     :07/Feb/2017
Action   :This is test class of Trigger 'TriggerOnAssignment'
/********************************************************************/
@isTest
public class AssignmentTriggerTracker
{
    static User objUser;
    static User objAnotherUser;
    static User objQueueMember;
    static Contact objContact;
    static pse__proj__c objProject;
    static pse__Budget__c objBudget;
    static pse__Budget__c objAnotherBudget;
    static pse__region__c objRegion;
    static pse__practice__c objPractice;
    static pse__grp__c objGroup;
    static pse__permission_control__c objPermission;
    static pse__permission_control__c objAnotherPermission;
    static pse__permission_control__c objMemberPermission;
    static pse__schedule__c objSchedule;
    static pse__schedule__c objAnotherSchedule;
    static pse__schedule__c objTestSchedule;
    static pse__schedule__c objCostTestSchedule;
    static pse__schedule__c objAnotherTestSchedule;
    static Sub_Account_Lookup__c objSubAccount;
    //This method covers the positive test case (Error Scenarios) of method 'validateAssignmentCreation' of class 'AssignmentTriggerHandler'
    public static testmethod void validateAssignmentCreation_AddErrorTest()
    {
        
        //calling test data creation
        LoadTestData();
        
        //run as test user which is not PM, CBU Queue Member or Project Team Member
        System.runAs(objUser)
        {
            //Create assignment against Presales Budget
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            objAssignment.Budget__c = objBudget.id;
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            try
            {
                insert objAssignment ;
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Assignment_Creation_Permission_Presales_Budget) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
            
            //Create assignment against Non-Presales Budget
            pse__Assignment__c objAnotherAssignment = new pse__Assignment__c();
            objAnotherAssignment.pse__Schedule__c = objSchedule.Id;
            objAnotherAssignment.pse__Bill_Rate__c = 10;
            objAnotherAssignment.pse__Resource__c = objContact.Id;
            objAnotherAssignment.pse__Project__c = objProject.Id;
            objAnotherAssignment.pse__Is_Billable__c = TRUE;
            objAnotherAssignment.Budget__c = objAnotherBudget.id;
            objAnotherAssignment.Client_Business_Unit_CBU__c = '4Print';
            try
            {
                insert objAnotherAssignment;
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Assignment_Creation_Permission_NonPresales_Budget) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
            
            //create resource request
            pse__Resource_Request__c objRequest = new pse__Resource_Request__c();
            objRequest.Client_Business_Unit_CBU__c = 'CHI1';
            objRequest.Budget__c = objAnotherBudget.Id;
            objRequest.pse__Project__c = objProject.Id;
            objRequest.pse__Region__c = objRegion.Id;
            objRequest.pse__Practice__c = objPractice.Id;
            objRequest.pse__Group__c = objGroup.Id;
            objRequest.pse__Staffer_Resource__c = objContact.Id;
            objRequest.pse__Requested_Bill_Rate__c = 100;
            objRequest.pse__SOW_Hours__c = 40;
            objRequest.pse__Start_Date__c = Date.today();
            objRequest.pse__End_Date__c = Date.today().addDays(10);
            objRequest.pse__Resource_Role__c = 'Buyer';
            objRequest.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objRequest.pse__Requested_Bill_Rate__c = 10;
            insert objRequest;
            
            //setting current page reference as resource request page
            PageReference objTestPageReference = new PageReference('/apex/pse__assignresource');
            Test.setCurrentPage(objTestPageReference);
            System.currentPageReference().getParameters().put('id', objRequest.Id);
            
            //Create assignment against Non-Presales Budget
            pse__Assignment__c objTestAssignment = new pse__Assignment__c();
            objTestAssignment.pse__Schedule__c = objSchedule.Id;
            objTestAssignment.pse__Bill_Rate__c = 10;
            objTestAssignment.pse__Resource__c = objContact.Id;
            objTestAssignment.pse__Project__c = objProject.Id;
            objTestAssignment.pse__Is_Billable__c = TRUE;
            objTestAssignment.Budget__c = objAnotherBudget.id;
            objTestAssignment.Client_Business_Unit_CBU__c = '4Print';
            try
            {
                insert objTestAssignment;
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Assignment_Creation_Permission_NonPresales_Budget) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
        } 
    }
    
    //This method covers the negative test case (No Error Scenarios) of method 'validateAssignmentCreation' of class 'AssignmentTriggerHandler'
    public static testmethod void validateAssignmentCreation_Presales_NoErrorTest()
    {
        
        //calling test data creation
        LoadTestData();
        
        //Presales Budget Scenario
        //run as test user which is PM on Project, there should not be any error while creating assignment - Presales Budget Test
        System.runAs(objAnotherUser)
        {
            Test.startTest();
            //Create assignment against Presales Budget
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            objAssignment.Budget__c = objBudget.id;
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            insert objAssignment ;
            //checking assignment is inserted successfully.
            System.assert([SELECT id FROM pse__Assignment__c  WHERE id = :objAssignment.id LIMIT 1].size() > 0);
            Test.StopTest();
        } 
        //Create Project Team Role
        Project_Team_Roles__c objProjectTeamRole = new Project_Team_Roles__c();
        objProjectTeamRole.Project__c = objProject.id;
        objProjectTeamRole.Project_Team_Role__c = 'Director';
        objProjectTeamRole.User__c = objUser.id;
        insert objProjectTeamRole ;
        
        //run as Project team Member, there should not be any error while creating assignment - Presales Budget Test
        System.runAs(objUser)
        {
            //Create assignment against Presales Budget
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objTestSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            objAssignment.Budget__c = objBudget.id;
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            insert objAssignment ;
            //checking assignment is inserted successfully.
            System.assert([SELECT id FROM pse__Assignment__c  WHERE id = :objAssignment.id LIMIT 1].size() > 0);
        } 
    }
    
    //This method covers the negative test case (No Error Scenarios) of method 'validateAssignmentCreation' of class 'AssignmentTriggerHandler'
    public static testmethod void validateAssignmentCreation_NonPresales_NoErrorTest()
    {
        //calling test data creation
        LoadTestData();
        //run as CBU queue Member, there should not be any error while creating assignment - Non-Presales Budget Test
        System.runAs(objQueueMember)
        {
            Test.startTest();
            //Create assignment against Non-Presales Budget
            pse__Assignment__c objAnotherAssignment = new pse__Assignment__c();
            objAnotherAssignment.pse__Schedule__c = objAnotherSchedule.Id;
            objAnotherAssignment.pse__Bill_Rate__c = 10;
            objAnotherAssignment.pse__Resource__c = objContact.Id;
            objAnotherAssignment.pse__Project__c = objProject.Id;
            objAnotherAssignment.pse__Is_Billable__c = TRUE;
            objAnotherAssignment.Budget__c = objAnotherBudget.id;
            objAnotherAssignment.Client_Business_Unit_CBU__c = '4Print';
            insert objAnotherAssignment;
            //checking assignment is inserted successfully.
            System.assert([SELECT id FROM pse__Assignment__c  WHERE id = :objAnotherAssignment.id LIMIT 1].size() > 0);
            Test.stopTest(); 
        }
    }
    
    //This method covers the method 'updateCBUFromProjectToAssignment' of class 'AssignmentTriggerHandler'
    //This covers the logic of auto populating CBU from Project to Assignment
    public static testmethod void updateCBUFromProjectToAssignment_Test()
    {
        
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objAnotherUser)
        {
            Test.startTest();
            //Positive Test Case
            //setting current page reference other than resource request page
            PageReference objPageReference = new PageReference('/apex/pse__assignresourcetoproject');
            Test.setCurrentPage(objPageReference);
            System.currentPageReference().getParameters().put('id', objProject.Id);
            
            //Create assignment
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            objAssignment.Budget__c = objBudget.id;
            insert objAssignment;
            //confirm CBU is auto populated from Project to Assignment
            System.AssertEquals([SELECT id, Client_Business_Unit_CBU__c FROM pse__Assignment__c  WHERE id = :objAssignment.id LIMIT 1].Client_Business_Unit_CBU__c, '4Print');
            
            //Negative Test Case
            
            //create resource request
            pse__Resource_Request__c objRequest = new pse__Resource_Request__c();
            objRequest.Client_Business_Unit_CBU__c = 'CHI1';
            objRequest.Budget__c = objBudget.Id;
            objRequest.pse__Project__c = objProject.Id;
            objRequest.pse__Region__c = objRegion.Id;
            objRequest.pse__Practice__c = objPractice.Id;
            objRequest.pse__Group__c = objGroup.Id;
            objRequest.pse__Staffer_Resource__c = objContact.Id;
            objRequest.pse__Requested_Bill_Rate__c = 100;
            objRequest.pse__SOW_Hours__c = 40;
            objRequest.pse__Start_Date__c = Date.today();
            objRequest.pse__End_Date__c = Date.today().addDays(10);
            objRequest.pse__Resource_Role__c = 'Buyer';
            objRequest.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objRequest.pse__Requested_Bill_Rate__c = 10;
            insert objRequest;
            
            //setting current page reference as resource request page
            PageReference objTestPageReference = new PageReference('/apex/pse__assignresource');
            Test.setCurrentPage(objTestPageReference);
            System.currentPageReference().getParameters().put('id', objRequest.Id);
            
            //Create assignment
            pse__Assignment__c objAnotherAssignment = new pse__Assignment__c();
            objAnotherAssignment.pse__Schedule__c = objAnotherSchedule.Id;
            objAnotherAssignment.pse__Bill_Rate__c = 10;
            objAnotherAssignment.pse__Resource__c = objContact.Id;
            objAnotherAssignment.pse__Project__c = objProject.Id;
            objAnotherAssignment.pse__Is_Billable__c = TRUE;
            objAnotherAssignment.Budget__c = objBudget.id;
            insert objAnotherAssignment;
            //confirm CBU is not auto populated from Project to Assignment
            System.AssertNotEquals([SELECT id, Client_Business_Unit_CBU__c FROM pse__Assignment__c  WHERE id = :objAnotherAssignment.id LIMIT 1].Client_Business_Unit_CBU__c, '4Print');
            Test.stopTest();
        }
    }
    
    //This method covers the method 'updateCBUFromProjectToAssignment' of class 'AssignmentTriggerHandler'
    //This covers the logic of auto populating Budget, Bill Rate, SubAccount from Budget to Assignment
    public static testmethod void updateCBUFromProjectToAssignment_Budget_Test()
    {
        
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objAnotherUser)
        {
            Test.startTest();
            //setting current page reference as Assignment from Budget Page
            PageReference objBudgetPageReference = new PageReference('apex/AssignResourceToProject?scontrolCaching=1');
            Test.setCurrentPage(objBudgetPageReference);
            System.currentPageReference().getParameters().put('AId', objProject.Id);
            System.currentPageReference().getParameters().put('BudgetId', objBudget.Id);
            
            //Create assignment
            pse__Assignment__c objBudgetAssignment = new pse__Assignment__c();
            objBudgetAssignment.pse__Schedule__c = objTestSchedule.Id;
            objBudgetAssignment.pse__Bill_Rate__c = 10;
            objBudgetAssignment.pse__Resource__c = objContact.Id;
            objBudgetAssignment.pse__Project__c = objProject.Id;
            objBudgetAssignment.pse__Is_Billable__c = TRUE;
            objBudgetAssignment.pse__Role__c = 'Team Lead';
            insert objBudgetAssignment;
            //confirm Budget, Bill Rate, SubAccount is auto populated on Assignment from Budget Page
            System.AssertEquals([SELECT id, Budget__c FROM pse__Assignment__c  WHERE id = :objBudgetAssignment.id LIMIT 1].Budget__c, objBudget.Id);
            System.AssertEquals([SELECT id, pse__Bill_Rate__c FROM pse__Assignment__c  WHERE id = :objBudgetAssignment.id LIMIT 1].pse__Bill_Rate__c, 30);
            System.Assert([SELECT id, Sub_Account_Lookup__c FROM pse__Assignment__c  WHERE id = :objBudgetAssignment.id LIMIT 1].Sub_Account_Lookup__c != null);
            Test.stopTest();
        }
    }
    
    //This method covers the method 'updateCBUFromProjectToAssignment' of class 'AssignmentTriggerHandler'
    //This covers the logic of auto populating Role and SubAccount on Self Assignment
    public static testmethod void updateCBUFromProjectToAssignment_SelfAssignment_Test()
    {
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objAnotherUser)
        {
            Test.startTest();
            //Create New Global Project
            pse__proj__c objGlobalProject = new pse__proj__c();
            objGlobalProject.name = 'Test project';
            objGlobalProject.pse__Project_Type__c = 'Global';
            objGlobalProject.pse__Project_Manager__c = objContact.Id;
            objGlobalProject.pse__Is_Active__c = TRUE;
            objGlobalProject.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objGlobalProject.pse__Is_Billable__c = TRUE;
            objGlobalProject.Client_BusinessUnit_CBU__c = '4Print';
            objGlobalProject.pse__Allow_Self_Staffing__c = true;
            insert objGlobalProject;
            
            //setting current page reference as SelfAssignment Page
            PageReference objPageReference = new PageReference('apex/pse__SelfAssignment');
            Test.setCurrentPage(objPageReference);
            System.currentPageReference().getParameters().put('id', Userinfo.getUserId());
            
            //Create assignment
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objTestSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objGlobalProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            insert objAssignment;
            
            //confirm Role and SubAccount is auto populated on SelfAssignment
            System.AssertEquals([SELECT id, pse__Role__c FROM pse__Assignment__c  WHERE id = :objAssignment.id LIMIT 1].pse__Role__c, 'Team Lead');
            System.Assert([SELECT id, Sub_Account_Lookup__c FROM pse__Assignment__c  WHERE id = :objAssignment.id LIMIT 1].Sub_Account_Lookup__c != null);
            Test.stopTest();
        }
    }
    
    //This method covers the method 'calculateTotalAssignmentCost' of class 'AssignmentTriggerHandler'
    public static testmethod void calculateTotalAssignmentCost_Test()
    {
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objAnotherUser)
        {
            Test.startTest();
            //Create assignment - Assignment cost is greater than Budget Expected Cost
            pse__Assignment__c objAssignment = new pse__Assignment__c();
            objAssignment.pse__Schedule__c = objCostTestSchedule.Id;
            objAssignment.pse__Bill_Rate__c = 10;
            objAssignment.pse__Resource__c = objContact.Id;
            objAssignment.pse__Project__c = objProject.Id;
            objAssignment.pse__Is_Billable__c = TRUE;
            objAssignment.Budget__c = objBudget.id;
            objAssignment.pse__Planned_Hours__c = 20;
            objAssignment.pse__Cost_Rate_Amount__c = 20;
            objAssignment.Client_Business_Unit_CBU__c = '4Print';
            try
            {
                insert objAssignment;
            }
            catch (DMLException objException) 
            {
                String strErrorMsg = '';
                strErrorMsg = objException.getMessage();
                Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Assignment_RR_Cost_Validation) ? true : false;
                System.assertEquals(isExpectedException, true);
            }
            //Create assignment - Assignment cost is less than Budget Expected Cost
            pse__Assignment__c objTestAssignment = new pse__Assignment__c();
            objTestAssignment.pse__Schedule__c = objAnotherTestSchedule.Id;
            objTestAssignment.pse__Bill_Rate__c = 10;
            objTestAssignment.pse__Resource__c = objContact.Id;
            objTestAssignment.pse__Project__c = objProject.Id;
            objTestAssignment.pse__Is_Billable__c = TRUE;
            objTestAssignment.Budget__c = objBudget.id;
            objTestAssignment.pse__Planned_Hours__c = 2;
            objTestAssignment.pse__Cost_Rate_Amount__c = 20;
            objTestAssignment.Client_Business_Unit_CBU__c = '4Print'; 
            insert objTestAssignment;
            //checking assignment is inserted successfully. 
            System.assert([SELECT id FROM pse__Assignment__c  WHERE id = :objTestAssignment.id LIMIT 1].size() > 0);
            
            //Update Scenario
            objTestAssignment.Budget__c = objAnotherBudget.id;
            update objTestAssignment;
            System.assert([SELECT id FROM pse__Assignment__c  WHERE Budget__c = :objBudget.id LIMIT 1].size() == 0);
            
            //Delete Scenario
            delete objTestAssignment;
            System.assert([SELECT id FROM pse__Assignment__c  WHERE Budget__c = :objAnotherBudget.id LIMIT 1].size() == 0);
            Test.stopTest();
        }
    }
    
    //Create test data 
    public static void LoadTestData()
    {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            objQueueMember = new User();
            objQueueMember.Username = 'testqueuemember@acostamosaic.com';
            objQueueMember.LastName = 'Test Queue Member';
            objQueueMember.email = 'testqueuemember@acostamosaic.com';
            objQueueMember.alias = 'testuser';
            objQueueMember.CommunityNickname = 'test queue member';
            objQueueMember.TimeZoneSidKey = 'Asia/Kolkata';
            objQueueMember.LocaleSidKey = 'en_US';
            objQueueMember.EmailEncodingKey = 'UTF-8';
            objQueueMember.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objQueueMember.LanguageLocaleKey = 'en_US';
            insert objQueueMember;
            
            //get the queue details from the system 
            List<Group> lstGroup = new List<Group>{};
                lstGroup = [Select id from Group where Type='QUEUE' AND Name= '4Print Queue'];
            if(lstGroup.size() > 0)
            {
                //Adding Group Member
                GroupMember objGroupMember = new GroupMember();
                objGroupMember.GroupId = lstGroup[0].Id;
                objGroupMember.UserOrGroupId = objQueueMember.Id;
                insert objGroupMember;
            }
            else
            {
                //Creating queue
                Group objQueue = new Group(Name= '4Print Queue', Type='QUEUE');
                insert objQueue;
                
                //Adding sObject to queue
                QueuesObject objQueuesObject = new QueuesObject (SobjectType = 'pse__Resource_Request__c', QueueId = objQueue.id);
                insert objQueuesObject;
                
                //Adding Group Member
                GroupMember objGroupMember = new GroupMember();
                objGroupMember.GroupId = objQueue.Id;
                objGroupMember.UserOrGroupId = objQueueMember.Id;
                insert objGroupMember;
            }
            
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
            
            insert objUser;
            
            // Create another test user
            objAnotherUser = new User();
            objAnotherUser.Username = 'testanotheruser@acostamosaic.com';
            objAnotherUser.LastName = 'Test Another User';
            objAnotherUser.email = 'testanotheruser@acostamosaic.com';
            objAnotherUser.alias = 'test';
            objAnotherUser.CommunityNickname = 'test another name';
            objAnotherUser.TimeZoneSidKey = 'Asia/Kolkata';
            objAnotherUser.LocaleSidKey = 'en_US';
            objAnotherUser.EmailEncodingKey = 'UTF-8';
            objAnotherUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objAnotherUser.LanguageLocaleKey = 'en_US';
            objAnotherUser.ManagerId = objUser.id;
            insert objAnotherUser;
            
            //Create region
            objRegion = new pse__region__c();
            objRegion.Name = 'Test Region';
            insert objRegion;
            
            //Create practice
            objPractice = new pse__practice__c();
            objPractice .Name = 'Test Practice';
            insert objPractice;
            
            //Create Group  
            objGroup = new pse__grp__c();
            objGroup.Name = 'Test Group';
            insert objGroup;
            
            // Create test contact
            objContact = new Contact();
            objContact.pse__Salesforce_User__c = objAnotherUser.id;
            objContact.firstname = 'Mosaic';
            objContact.lastname = 'Test contact';
            objContact.pse__Is_Resource__c = TRUE;
            objContact.pse__Is_Resource_Active__c = TRUE; 
            objContact.pse__Region__c = objRegion.id;
            objContact.pse__Resource_Role__c = 'Team Lead';
            insert objContact;
            
            // Create project
            objProject = new pse__proj__c();
            objProject.name = 'Test project';
            objProject.pse__Project_Type__c = 'Internal';
            objProject.pse__Project_Manager__c = objContact.Id;
            objProject.pse__Is_Active__c = TRUE;
            objProject.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objProject.pse__Is_Billable__c = TRUE;
            objProject.Client_BusinessUnit_CBU__c = '4Print'; 
            insert objProject;
            
            //Create presales budget        
            objBudget = new pse__Budget__c();
            objBudget.Name = 'Test Budget';
            objBudget.pse__Type__c = 'Presales Budget';
            objBudget.pse__Project__c = objProject.Id;
            objBudget.Expected_Cost__c = 100;
            objBudget.Hours_Booked__c = 10;
            objBudget.pse__Amount__c = 300;
            objBudget.Practice__c = objPractice.id;
            objBudget.Management_Personnel__c = true;
            insert objBudget ;
            
            //Create non-presales budget        
            objAnotherBudget = new pse__Budget__c();
            objAnotherBudget.Name = 'Test Budget';
            objAnotherBudget.pse__Type__c = 'Customer Purchase Order';
            objAnotherBudget.pse__Project__c = objProject.Id;
            objAnotherBudget.Expected_Cost__c = 100;
            objAnotherBudget.Practice__c = objPractice.id;
            objAnotherBudget.Management_Personnel__c = true;
            insert objAnotherBudget;
            
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
            
            //Create Permission Control for another user
            objAnotherPermission = new pse__permission_control__c();
            objAnotherPermission.pse__User__c = objAnotherUser.Id;
            objAnotherPermission.pse__Region__c = objRegion.Id;
            objAnotherPermission.pse__Practice__c = objPractice.Id;
            objAnotherPermission.pse__Group__c = objGroup.Id;
            objAnotherPermission.pse__Resource_Request_Entry__c = TRUE;
            objAnotherPermission.pse__Project__c = objProject.Id;
            objAnotherPermission.pse__Staffing__c = TRUE;
            objAnotherPermission.pse__Start_Date__c = Date.today().addDays(-10);
            objAnotherPermission.pse__End_Date__c = Date.today().addDays(30);
            objAnotherPermission.pse__Resource__c = objContact.Id;
            insert objAnotherPermission;
            
            //Create Permission Control for queue member
            objMemberPermission = new pse__permission_control__c();
            objMemberPermission.pse__User__c = objQueueMember.Id;
            objMemberPermission.pse__Region__c = objRegion.Id;
            objMemberPermission.pse__Practice__c = objPractice.Id;
            objMemberPermission.pse__Group__c = objGroup.Id;
            objMemberPermission.pse__Resource_Request_Entry__c = TRUE;
            objMemberPermission.pse__Project__c = objProject.Id;
            objMemberPermission.pse__Staffing__c = TRUE;
            objMemberPermission.pse__Start_Date__c = Date.today().addDays(-10);
            objMemberPermission.pse__End_Date__c = Date.today().addDays(30);
            objMemberPermission.pse__Resource__c = objContact.Id;
            insert objMemberPermission;
            
            
            //Create Schedule
            objSchedule = new pse__schedule__c();
            objSchedule.pse__Start_Date__c = Date.today();
            objSchedule.pse__End_Date__c = Date.today().addDays(5);
            insert objSchedule ;
            
            //Create another Schedule
            objAnotherSchedule = new pse__schedule__c();
            objAnotherSchedule.pse__Start_Date__c = Date.today();
            objAnotherSchedule.pse__End_Date__c = Date.today().addDays(5);
            insert objAnotherSchedule;
            
            //Create another Schedule
            objTestSchedule = new pse__schedule__c();
            objTestSchedule.pse__Start_Date__c = Date.today();
            objTestSchedule.pse__End_Date__c = Date.today().addDays(5);
            insert objTestSchedule;
            
            //Create Schedule
            objCostTestSchedule = new pse__schedule__c();
            objCostTestSchedule.pse__Start_Date__c = Date.today();
            objCostTestSchedule.pse__End_Date__c = Date.today().addDays(5);
            objCostTestSchedule.pse__Scheduled_Hours__c = 20;
            insert objCostTestSchedule ;
            
            //Create another Schedule
            objAnotherTestSchedule = new pse__schedule__c();
            objAnotherTestSchedule.pse__Start_Date__c = Date.today();
            objAnotherTestSchedule.pse__End_Date__c = Date.today().addDays(5);
            objAnotherTestSchedule.pse__Scheduled_Hours__c = 2;
            insert objAnotherTestSchedule;
            
            //Create Sub-Account
            objSubAccount = new Sub_Account_Lookup__c();
            objSubAccount.Role__c = 'Team Lead';
            objSubAccount.Name = 'Test SubAccount';
            insert objSubAccount;
        }
    }
}