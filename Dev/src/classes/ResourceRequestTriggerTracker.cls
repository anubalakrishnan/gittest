/********************************************************************
Author   :Suman Gupta
Date     :06/Feb/2017
Action   :This is test class of Trigger 'TriggerOnResourceRequest'
/********************************************************************/
@isTest
public class ResourceRequestTriggerTracker 
{
    static User objUser;
    static User objTestUser;
    static Contact objContact;
    static pse__proj__c objProject;
    static pse__Budget__c objBudget;
    static pse__Budget__c objAnotherBudget;
    static pse__region__c objRegion;
    static pse__practice__c objPractice;
    static pse__grp__c objGroup;
    static pse__permission_control__c objPermission;
    static pse__schedule__c objSchedule;
    static Cost_Rate_Lookup__c objCostRate;
    
    //This method covers method 'updateCostRateOnResourceRequest' of class 'ResourceRequestTriggerHandler'
    public static testmethod void updateCostRateOnResourceRequest_Test()
    {
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objUser)
        {
            Test.startTest();
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
            objRequest.pse__SOW_Hours__c = 5;
            objRequest.pse__Start_Date__c = Date.today();
            objRequest.pse__End_Date__c = Date.today().addDays(10);
            objRequest.pse__Resource_Role__c = 'Team Lead';
            objRequest.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objRequest.pse__Requested_Bill_Rate__c = 10;
            insert objRequest;
            //checking cost rate is populated successfully 
            System.assertEquals([Select id, Cost_Rate_Amount__c from pse__Resource_Request__c where id = :objRequest.id].Cost_Rate_Amount__c, 20);
        }
    }
    
    //This method covers method 'calculateTotalResourceReqCost' of class 'ResourceRequestTriggerHandler'
    public static testmethod void calculateTotalResourceReqCost_Test()
    {
        //calling test data creation
        LoadTestData();
        
        //run as test user which is PM
        System.runAs(objUser)
        {
            Test.startTest();
            //create resource request - Resource Request cost is greater than Budget Expected Cost
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
            objRequest.pse__Resource_Role__c = 'Team Lead';
            objRequest.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objRequest.pse__Requested_Bill_Rate__c = 10;
            try
            {
                insert objRequest;
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
            objTestAssignment.pse__Schedule__c = objSchedule.Id;
            objTestAssignment.pse__Bill_Rate__c = 10;
            objTestAssignment.pse__Resource__c = objContact.Id;
            objTestAssignment.pse__Project__c = objProject.Id;
            objTestAssignment.pse__Is_Billable__c = TRUE;
            objTestAssignment.Budget__c = objAnotherBudget.id;
            objTestAssignment.pse__Planned_Hours__c = 2;
            objTestAssignment.pse__Cost_Rate_Amount__c = 20;
            objTestAssignment.Client_Business_Unit_CBU__c = '4Print';
            insert objTestAssignment;
            //checking assignment is inserted successfully. 
            System.assert([SELECT id FROM pse__Assignment__c  WHERE id = :objTestAssignment.id LIMIT 1].size() > 0);
            
            //create resource request - Resource Request cost is less than Budget Expected Cost
            pse__Resource_Request__c objTestRequest = new pse__Resource_Request__c();
            objTestRequest.Client_Business_Unit_CBU__c = 'CHI1';
            objTestRequest.Budget__c = objAnotherBudget.Id;
            objTestRequest.pse__Project__c = objProject.Id;
            objTestRequest.pse__Region__c = objRegion.Id;
            objTestRequest.pse__Practice__c = objPractice.Id;
            objTestRequest.pse__Group__c = objGroup.Id;
            objTestRequest.pse__Staffer_Resource__c = objContact.Id;
            objTestRequest.pse__Requested_Bill_Rate__c = 100;
            objTestRequest.pse__SOW_Hours__c = 2;
            objTestRequest.pse__Start_Date__c = Date.today();
            objTestRequest.pse__End_Date__c = Date.today().addDays(10);
            objTestRequest.pse__Resource_Role__c = 'Team Lead';
            objTestRequest.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
            objTestRequest.pse__Requested_Bill_Rate__c = 10;
            insert objTestRequest;
            //checking Resource request is instered successfully 
            System.assert([Select id from pse__Resource_Request__c where id = :objTestRequest.id Limit 1].size() > 0);
            
            //Update scenario
            objTestRequest.Budget__c = objBudget.Id;
            update objTestRequest;
            System.assert([SELECT id FROM pse__Resource_Request__c WHERE Budget__c = :objAnotherBudget.id LIMIT 1].size() == 0);
            
            //Delete Scenario
            delete objTestRequest;
            System.assert([SELECT id FROM pse__Resource_Request__c WHERE Budget__c = :objBudget.id LIMIT 1].size() == 0);
            Test.stopTest();
        }
    }
    
    //Create test data 
    public static void LoadTestData()
    {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ){
            // Create test user
            objTestUser = new User();
            objTestUser.Username = 'testuser@acostamosaic.com';
            objTestUser.LastName = 'Test User';
            objTestUser.email = 'testuser@acostamosaic.com';
            objTestUser.alias = 'test';
            objTestUser.CommunityNickname = 'test name';
            objTestUser.TimeZoneSidKey = 'Asia/Kolkata';
            objTestUser.LocaleSidKey = 'en_US';
            objTestUser.EmailEncodingKey = 'UTF-8';
            objTestUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
            objTestUser.LanguageLocaleKey = 'en_US';
            insert objTestUser;
            // Create test user
            objUser = new User();
            objUser.Username = 'testanotheruser@acostamosaic.com';
            objUser.LastName = 'Test Another User';
            objUser.email = 'testanotheruser@acostamosaic.com';
            objUser.alias = 'test';
            objUser.CommunityNickname = 'test another name';
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
            objPractice .Name = 'Test Practice';
            insert objPractice;
            
            //Create Group  
            objGroup = new pse__grp__c();
            objGroup.Name = 'Test Group';
            insert objGroup;
            
            //Create Cost Rate lookup
            objCostRate = new Cost_Rate_Lookup__c();
            objCostRate.Region__c = objRegion.id;
            objCostRate.Role__c = 'Team Lead';
            objCostRate.Cost_Rate__c = 20;
            insert objCostRate;
            
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
            objBudget.Practice__c = objPractice.id;
            objBudget.Management_Personnel__c = true;
            insert objBudget ;
            
            //Create another presales budget        
            objAnotherBudget = new pse__Budget__c();
            objAnotherBudget.Name = 'Test Budget';
            objAnotherBudget.pse__Type__c = 'Presales Budget';
            objAnotherBudget.pse__Project__c = objProject.Id;
            objAnotherBudget.Expected_Cost__c = 100;
            objAnotherBudget.Practice__c = objPractice.id;
            objAnotherBudget.Management_Personnel__c = true;
            insert objAnotherBudget;
            
            //Create Permission Control for user
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
            
            //Create Schedule
            objSchedule = new pse__schedule__c();
            objSchedule.pse__Start_Date__c = Date.today();
            objSchedule.pse__End_Date__c = Date.today().addDays(5);
            insert objSchedule ;
        }
  	}
}