@isTest
private class MiscAdjustmentTriggerHandlerTest {

    @testSetup static void createTestData() {
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';        
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        
        insert proj;        
        System.debug('Inserted project - ' + proj);             
         
	}
    
    private static testMethod void insertMiscAdjustTest() {
                        
        pse__proj__c proj = [SELECT ID, Name FROM pse__proj__c LIMIT 1];
        
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c();
        miscAdj.Name = 'Test MA - Test';
        miscAdj.pse__Project__c = proj.ID;
        miscAdj.pse__Status__c = 'Approved';
        insert miscAdj;
        
        List<pse__Milestone__c> milestone = [SELECT ID, Name FROM pse__Milestone__c
                                              WHERE Miscellaneous_Adjustment__c = :miscAdj.ID]; 
        
        System.assertEquals(1, milestone.size());
        
    }    
    
    private static testMethod void updateMiscAdjustTest() {
        
        pse__proj__c proj = [SELECT ID, Name FROM pse__proj__c LIMIT 1];
                        
        pse__Miscellaneous_Adjustment__c miscAdj = new pse__Miscellaneous_Adjustment__c();
        miscAdj.Name = 'Test MA - Test';
        miscAdj.pse__Project__c = proj.ID;  
        insert miscAdj;
        System.debug('Inserted misc adjustment - ' + miscAdj);        
        
        miscAdj.pse__Status__c = 'Approved';
        update miscAdj;
        
        List<pse__Milestone__c> milestone = [SELECT ID, Name FROM pse__Milestone__c
                                              WHERE Miscellaneous_Adjustment__c = :miscAdj.ID]; 
        
        System.assertEquals(1, milestone.size());
        
    }
}