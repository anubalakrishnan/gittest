/********************************************************************
Author   :Suman Gupta
Date     :27/March/2017
Action   :This is test class of Trigger 'TriggerOnMiscAdjustment' and handler class 'MiscAdjustmentTriggerHandler_version2'
/********************************************************************/
@isTest
global class MiscAdjustmentTriggerTracker {

    //This method covers the method 'validateRejectionComments' of class 'MiscAdjustmentTriggerHandler_version2'
    public static testmethod void validateRejectionComments_Test()
    {
        //Get the project created by test setup method 
        
        List<pse__proj__c> lstProject = [Select id from pse__proj__c limit 1];
        
        //create new Misc. Adjustment
        pse__Miscellaneous_Adjustment__c objMiscAdjustment = new pse__Miscellaneous_Adjustment__c();
        objMiscAdjustment.Name = 'Test MA - Test';
        objMiscAdjustment.pse__Project__c = lstProject[0].ID;
        objMiscAdjustment.pse__Status__c = 'Submitted';
        objMiscAdjustment.pse__Amount__c = -4000;
        insert objMiscAdjustment;
        
        //checking Misc.Adjustment is inserted successfully.
        System.assert([SELECT id FROM pse__Miscellaneous_Adjustment__c  WHERE id = :objMiscAdjustment.id LIMIT 1].size() > 0);
        
        //get approval process detail which is auto submitted
        List<ProcessInstanceWorkitem> lstWorkItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem 
                                                      WHERE ProcessInstance.TargetObjectId = :objMiscAdjustment.id limit 1];
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
            Boolean isExpectedException = strErrorMsg.containsIgnoreCase(System.label.Misc_Adjustment_Mandatory_Rejection_Comments) ? true : false;
            System.assertEquals(isExpectedException, true);
        }
        
    }
    //Create test data 
    @testSetup static void LoadTestData()
    {
        // Create test user
        User objUser = new User();
        objUser.Username = 'testuser@acostamosaic.com';
        objUser.LastName = 'Test User';
        objUser.email = 'testuser@acostamosaic.com';
        objUser.Title = 'Art Director';
        objUser.alias = 'test';
        objUser.CommunityNickname = 'test name';
        objUser.TimeZoneSidKey = 'Asia/Kolkata';
        objUser.LocaleSidKey = 'en_US';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.ProfileId = [SELECT id FROM profile WHERE name = 'System Administrator' LIMIT 1].Id;
        objUser.LanguageLocaleKey = 'en_US';
        objUser.Operational_Role__c = 'Art Director';
        insert objUser;
        
        // create Account record
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Type = 'Client';
        objAccount.Status__c = 'Active';    
        insert objAccount;
        
        //Create region
        pse__region__c objRegion = new pse__region__c();
        objRegion.Name = 'Test Region';
        insert objRegion;
            
        //Create practice
        pse__practice__c objPractice = new pse__practice__c();
        objPractice .Name = 'Test Practice';
        insert objPractice;
        
        //Create Group  
        pse__grp__c objGroup = new pse__grp__c();
        objGroup.Name = 'Test Group';
        insert objGroup;
        
        //Create Opportunity
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.StageName ='New';
        objOpportunity.CloseDate = Date.today();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.pse__Group__c = objGroup.id;
        objOpportunity.pse__Practice__c = objPractice.id;
        objOpportunity.pse__Region__c = objRegion.id;
        objOpportunity.RecordTypeId = [select Id, Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        objOpportunity.Services_Sub_Services__c = 'Content - Content Factory';  
        objOpportunity.Start_Date__c = Date.today();
        objOpportunity.End_Date__c = Date.today()+60;  
        objOpportunity.Director__c = objUser.id;
        insert objOpportunity;
        
        // Create project
        pse__proj__c objProject = new pse__proj__c();
        objProject.name = 'Test project';
        objProject.pse__Opportunity__c = objOpportunity.id;
        objProject.pse__Project_Type__c = 'Internal';        
        objProject.pse__Is_Active__c = TRUE;
        objProject.Services_Sub_Services__c = 'Retail Demo - Premium Demo';
        objProject.pse__Is_Billable__c = TRUE;
        objProject.pse__Stage__c = 'In Planning';
        insert objProject; 
    }
}