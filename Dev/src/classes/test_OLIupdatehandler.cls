/******************************************************************************************************
* @Author      : Deepanshu
* @Date        : 3rd March, 2017 
* @Description : This test class is used to test the OLIupdatehandler batch class.
* ****************************************************************************************************/

@isTest
public class test_OLIupdatehandler{

    public static testmethod void testdel(){ 
        
        // create profile record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // create user record
        User u = new User(Alias = 'standt', Email='testuser@ge.com',EmailEncodingKey='UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuser1234@testorg.com');
        insert u;
        System.runas(u){
        // create Account record
        Account a = new Account(Name = 'Test Acc',Type = 'Client');    
        insert a;
        
        // create contact record
        Contact con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'Contact';    
        con.pse__Salesforce_User__c = u.id;
        con.Client_Business_Unit_CBU__c = '4Print';
        insert con;
        
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
        
        pse__permission_control__c perm = new pse__permission_control__c();
        perm.pse__User__c = U.Id;
        perm.pse__Region__c = region.Id;
        perm.pse__Practice__c = prac.Id;
        perm.pse__Group__c = grp.Id;
        perm.pse__Resource_Request_Entry__c = TRUE;
        //  perm.pse__Project__c = proj.Id;
        perm.pse__Staffing__c = TRUE;
        perm.pse__Start_Date__c = Date.today().addDays(-10);
        perm.pse__End_Date__c = Date.today().addDays(30);
        perm.pse__Resource__c = con.Id;    
        insert perm;
        
        //create opportunity record
        Opportunity Opp = new Opportunity(Name='Test-opp',pse__Region__c=region.id,Quote_Status__c = 'Approved',Client_Business_Unit_CBU__c = 'CHI1', 
        Revenue_Type__c='POC' ,Services_Sub_Services__c='Other - Other' ,pse__Practice__c = prac.id,pse__Group__c=grp.id, StageName='New',
        CloseDate=Date.today(),AccountId=a.Id,Specific_Project_Identified_w__c = true);
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        insert Opp;       
        
        System.debug('Opp primary proj==' + opp.pse__Primary_Project__c );
        
        // Access pricebookid
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = '11301-11000',
            ProductCode = '11301-11000',
            Family = 'Management',
            isActive = true,
            Description = 'Learning Consultant'
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 200,
            End_date__c = Date.today(),
            Start_date__c = Date.today()
        );
        insert oli;    
        
        opp.Primary_Quote_Count__c = 1;
        opp.Awaiting_Final_Signature__c = true;
        update opp;
        
        // Delete oli record   
        if(oli.id != null){
            Delete oli;        
        }
        }
        /* 
// Call Batch Apex
DeleteRelatedRec delbatch = new DeleteRelatedRec();
Database.executebatch(delbatch);
*/   
    }
    
    public static testmethod void testmilestone(){ 
        
        // create profile record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // create user record
        User u = new User(Alias = 'standt', Email='testuser@ge.com',EmailEncodingKey='UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuser1234@testorg.com');
        insert u;
        System.runas(u){
        // create Account record
        Account a = new Account(Name = 'Test Acc',Type = 'Client',Status__c= 'Active');    
        insert a;
        
        // create contact record
        Contact con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'Contact';    
        con.pse__Salesforce_User__c = u.id;
        con.Client_Business_Unit_CBU__c = '4Print';
        insert con; 
       /* 
        pse__region__c region = new pse__region__c();
        region.Name = 'Test Region';
        insert region;
        System.debug('Inserted region - ' + region);
       */ 
        pse__practice__c prac = new pse__practice__c();
        prac.Name = 'Test Practice';
        insert prac;
        System.debug('Inserted practice - ' + prac);   
    
        //create opportunity record
      
        Opportunity Opp = new Opportunity(Name='Test-opp',Quote_Status__c = 'Approved',pse__Practice__c = prac.id,Revenue_Type__c='POC',Services_Sub_Services__c='Other - Other',
                                        StageName='New',CloseDate=Date.today(),AccountId=a.Id,Client_Business_Unit_CBU__c='4Print',Specific_Project_Identified_w__c = true);
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        insert Opp; 
        System.debug('Opp milestone rec==' + opp);

        // Access pricebookid
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
            Name = '11301-11000',
            ProductCode = '11301-11000',
            Family = 'Management',
            isActive = true,
            Description = 'Learning Consultant'
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 200,
            End_date__c = Date.today(),
            Start_date__c = Date.today()
        );
        insert oli;
        
        BigMachines__Configuration_Record__c bmconfigrec = new BigMachines__Configuration_Record__c();
        bmconfigrec.BigMachines__bm_site__c = 'Test Site';
        bmconfigrec.BigMachines__process_id__c = '7868766';
        bmconfigrec.BigMachines__action_id_open__c = '76676';
        bmconfigrec.BigMachines__action_id_copy__c = '87656565';
        bmconfigrec.BigMachines__document_id__c = '346';
        bmconfigrec.BigMachines__version_id__c = '6456556';
        bmconfigrec.BigMachines__process__c = 'test process';
        bmconfigrec.BigMachines__Is_Active__c = true;
        insert bmconfigrec;
        
        BigMachines__Quote__c bmquote = new BigMachines__Quote__c();
        bmquote.Name = 'CPQ-001';
        bmquote.BigMachines__Opportunity__c = opp.id;
        bmquote.Agency_Fees_Billing_Schedule__c  = '1@@Milestone #1@@2017-03-07@@30@@2017-04-06@@20.0@@15546.112@@0.0@@15546.112##2@@Milestone #2@@2017-03-21@@30@@2017-04-20@@80.0@@62184.448@@0.0@@62184.448##3@@Milestone #3@@2017-03-21@@30@@2017-04-20@@0.0@@0.0@@0.0@@0.0##';
        bmquote.BigMachines__Is_Primary__c = true;
        bmquote.BigMachines__Site__c = bmconfigrec.id;
        insert bmquote;
        
       /* opp.Specific_Project_Identified_w__c = True;
        update opp; */  
        Opportunity opp1 = [Select Id, StageName, Specific_Project_Identified_w__c, Awaiting_Final_Signature__c from Opportunity where Id =: opp.Id];
        opp1.Awaiting_Final_Signature__c = True;
        update opp1;
        Opportunity opp2 = [Select Id, StageName, Awaiting_Final_Signature__c,Signed_Quote_PO_Received__c, Won_Reason__c from Opportunity where Id =: opp.Id];
        opp2.Signed_Quote_PO_Received__c = True;
        opp2.Won_Reason__c = 'Idea';
        update opp2;
        }
    } 
}