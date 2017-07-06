@isTest
private class BillingEventItemTriggerHandlerTest {

    @testSetup static void createTestData() {
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contract contract = new Contract();
        contract.Name = 'Test Contract';
        contract.AccountId = account.ID;
        contract.Revenue_Type__c = 'POC';
        insert contract;        
        
        pse__Region__c region = new pse__Region__c();
        region.name = 'Test Region';
        insert region;
        
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Region__c = region.ID;
        proj.pse__Project_Type__c = 'Internal';        
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Other - Other';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';        
        insert proj;        
        System.debug('Inserted project - ' + proj); 
        
        pse__permission_control__c perm = new pse__permission_control__c();        
        perm.pse__Billing__c = TRUE;
        perm.pse__Invoicing__c = TRUE;
        perm.pse__Project__c = proj.ID;
        perm.pse__Start_Date__c = Date.today().addDays(-5);
        perm.pse__End_Date__c = Date.today().addDays(10);
        perm.pse__Cascading_Permission__c = TRUE;
        perm.pse__User__c = UserInfo.getUserId();
        perm.pse__Region__c = region.ID;
        insert perm;
                        
        pse__Milestone__c milestone = new pse__Milestone__c();        
        milestone.pse__Project__c = proj.ID;
        milestone.name = 'Test Milestone';  
        milestone.pse__Target_Date__c = Date.today();
        milestone.pse__Actual_Date__c = Date.today();
        milestone.pse__Milestone_Amount__c = -100;
        milestone.Milestone__c = 1;
        milestone.pse__Status__c = 'Approved';
        milestone.pse__Approved__c = TRUE;
        milestone.pse__Include_In_Financials__c = TRUE;
        milestone.pse__Approved_for_Billing__c = TRUE;
        milestone.Contract_ID__c = contract.ID;        
        insert milestone;    
        System.debug('Inserted milestone - ' + milestone);           
                
        pse__Time_period__c timePeriod = new pse__Time_period__c();
        timePeriod.name = 'Test Time Period';
        timePeriod.pse__Type__c = 'Other';
        timePeriod.pse__Start_Date__c = Date.today();
        timePeriod.pse__End_Date__c = Date.today().addDays(5);
        insert timePeriod;
        System.debug('Inserted time period - ' + timePeriod);                
        
        pse__Billing_Event_Calculation__c billEventCalc = new pse__Billing_Event_Calculation__c();                      
        billEventCalc.pse__Include_Prior_Periods__c = TRUE; 
        billEventCalc.pse__Locale_Information__c = '{"numberFormat":"#,###.##","nameFormat":"FL","dateFormat":"d/m/yyyy"}';        
        billEventCalc.pse__Project__c = proj.ID;         
        billEventCalc.pse__Time_Period__c = timePeriod.ID;
        insert billEventCalc;
        
        pse__Billing_Event_Batch__c eventBatch = new pse__Billing_Event_Batch__c();
        eventBatch.pse__Is_Released__c = TRUE;
        eventBatch.pse__Summary_Amount__c = 100;
        eventBatch.pse__Time_Period__c = timePeriod.ID;
        eventBatch.pse__Billing_Event_Calculation__c = billEventCalc.ID;
        insert eventBatch;
        System.debug('Inserted billing event batch - ' + eventBatch);        
        
        pse__Billing_Event__c billEvent = new pse__Billing_Event__c();
        billEvent.pse__Project__c = proj.ID;
        billEvent.pse__Billing_Event_Batch__c = eventBatch.ID;
        billEvent.pse__Billing_Event_Calculation__c = billEventCalc.ID;
        billEvent.pse__Rounded_Summary_Amount__c = 100;        
        billEvent.pse__Status__c = 'Saved';
        billEvent.pse__Approver__c = UserInfo.getUserId();
        billEvent.pse__Is_Approved__c = TRUE;
        billEvent.pse__Date__c = Date.today();        
        insert billEvent;
        System.debug('Inserted billEvent - ' + billEvent); 
        
        billEvent.pse__Status__c = 'Released';
        billEvent.pse__Is_Released__c = TRUE;
        update billEvent;
        
        pse__Billing_Event__c billEvent2 = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c, pse__is_released__c, pse__status__c
                                             FROM pse__Billing_Event__c WHERE id = :billEvent.ID]; 
        System.debug(billEvent2);
                
        pse__Billing_Event_Item__c billEventItem = new pse__Billing_Event_Item__c();
        billEventItem.pse__Billing_Event__c = billEvent.ID;
        billEventItem.pse__Billing_Event_Batch__c = eventBatch.ID;
        billEventItem.pse__Billing_Event_Calculation__c = billEventCalc.ID;
        billEventItem.pse__Project__c = proj.ID;
        billEventItem.pse__Object_Id__c = milestone.ID;
        billEventItem.pse__Milestone__c = milestone.ID;
        billEventItem.pse__Quantity__c = 1;
        billEventItem.pse__Category__c = 'Milestone';
        billEventItem.pse__Amount__c = -100;
        billEventItem.pse__Date__c = Date.today();   
        billEventItem.pse__Unit_Price__c = -100;
        insert billEventItem;
        System.debug('Inserted billEventItem - ' + billEventItem);  
        
        milestone.pse__Billing_Event_Item__c = billEventItem.ID;
        milestone.pse__Billed__c = TRUE;
        
        update milestone;
        
    }
    
	private static testMethod void singleBillingEventItemTest() {                      

        pse__Billing_Event_Item__c billEventItem = [SELECT ID, Name FROM pse__Billing_Event_Item__c LIMIT 1];
        
        billEventItem.Invoice_Date__c = Date.today();        
        update billEventItem;

        pse__Billing_Event__c billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                                             FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(TRUE, billEvent.pse__Invoiced__c);
       
    }
    
	private static testMethod void multipleBillingEventItemTest() {        
        
        pse__Billing_Event_Calculation__c billEventCalc = [SELECT ID, Name FROM pse__Billing_Event_Calculation__c LIMIT 1];

        pse__Billing_Event_Batch__c eventBatch = [SELECT ID, Name FROM pse__Billing_Event_Batch__c LIMIT 1];
        
        pse__Billing_Event__c billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                                             FROM pse__Billing_Event__c LIMIT 1];
        
        pse__Milestone__c milestone = [SELECT ID, Name FROM pse__Milestone__c LIMIT 1];
                                           
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];                                   
        
        pse__Billing_Event_Item__c billEventItem_2 = new pse__Billing_Event_Item__c();
        billEventItem_2.pse__Billing_Event__c = billEvent.ID;
        billEventItem_2.pse__Billing_Event_Batch__c = eventBatch.ID;
        billEventItem_2.pse__Billing_Event_Calculation__c = billEventCalc.ID;
        billEventItem_2.pse__Project__c = proj.ID;
        billEventItem_2.pse__Object_Id__c = milestone.ID;
        billEventItem_2.pse__Milestone__c = milestone.ID;
        billEventItem_2.pse__Quantity__c = 2;
        billEventItem_2.pse__Category__c = 'Milestone';
        billEventItem_2.pse__Amount__c = -200;
        billEventItem_2.pse__Date__c = Date.today();   
        billEventItem_2.pse__Unit_Price__c = -200;
        insert billEventItem_2;
        System.debug('Inserted billEventItem 2 - ' + billEventItem_2);                          
        
        billEventItem_2.Invoice_Date__c = Date.today();        
        update billEventItem_2;

        billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                       FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(FALSE, billEvent.pse__Invoiced__c);
       
    }    
    
	private static testMethod void closeBillingEventItemTest() {                      

        pse__Billing_Event_Item__c billEventItem = [SELECT ID, Name FROM pse__Billing_Event_Item__c LIMIT 1];
        
        billEventItem.Invoice_Date__c = Date.today();        
        update billEventItem;

        pse__Billing_Event__c billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                                             FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(TRUE, billEvent.pse__Invoiced__c);
        
        billEventItem.Payment_Status__c = 'Closed';        
        update billEventItem;
        
        billEvent = [SELECT ID, Name, Paid__c
                       FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(TRUE, billEvent.Paid__c);
    }
    
	private static testMethod void closePartialBillingEventItemTest() {        
        
        pse__Billing_Event_Calculation__c billEventCalc = [SELECT ID, Name FROM pse__Billing_Event_Calculation__c LIMIT 1];

        pse__Billing_Event_Batch__c eventBatch = [SELECT ID, Name FROM pse__Billing_Event_Batch__c LIMIT 1];
        
        pse__Billing_Event__c billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                                             FROM pse__Billing_Event__c LIMIT 1];
        
        pse__Milestone__c milestone = [SELECT ID, Name FROM pse__Milestone__c LIMIT 1];
                                           
        pse__Proj__c proj = [SELECT ID, Name FROM pse__Proj__c LIMIT 1];                                   
        
        pse__Billing_Event_Item__c billEventItem_2 = new pse__Billing_Event_Item__c();
        billEventItem_2.pse__Billing_Event__c = billEvent.ID;
        billEventItem_2.pse__Billing_Event_Batch__c = eventBatch.ID;
        billEventItem_2.pse__Billing_Event_Calculation__c = billEventCalc.ID;
        billEventItem_2.pse__Project__c = proj.ID;
        billEventItem_2.pse__Object_Id__c = milestone.ID;
        billEventItem_2.pse__Milestone__c = milestone.ID;
        billEventItem_2.pse__Quantity__c = 2;
        billEventItem_2.pse__Category__c = 'Milestone';
        billEventItem_2.pse__Amount__c = -200;
        billEventItem_2.pse__Date__c = Date.today();   
        billEventItem_2.pse__Unit_Price__c = -200;
        insert billEventItem_2;
        System.debug('Inserted billEventItem 2 - ' + billEventItem_2);                          
        
        billEventItem_2.Invoice_Date__c = Date.today();        
        update billEventItem_2;

        billEvent = [SELECT ID, Name, pse__Invoice_Date__c, pse__Invoiced__c
                       FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(FALSE, billEvent.pse__Invoiced__c);
        
        billEventItem_2.Payment_Status__c = 'Closed';        
        update billEventItem_2;
        
        billEvent = [SELECT ID, Name, Paid__c
                       FROM pse__Billing_Event__c LIMIT 1];
        
        System.assertEquals(FALSE, billEvent.Paid__c);        
       
    }  
}