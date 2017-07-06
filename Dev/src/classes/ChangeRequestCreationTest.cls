@isTest
public class ChangeRequestCreationTest {

    public static testmethod void testNewOpp(){ 
        
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
			RecordType conrec = [SELECT Id From RecordType WHERE SobjectType = 'Contact' AND Name = 'Resource Contact' LIMIT 1];
			Contact con = new Contact();
			Con.FirstName = 'Test';
			Con.LastName = 'Contact';    
			con.pse__Salesforce_User__c = u.id;
			con.Client_Business_Unit_CBU__c = '4Print';
			con.pse__Salesforce_User__c = u.Id;
			con.RecordTypeId = conrec.Id;
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
			
            // Create project
            pse__proj__c proj = new pse__proj__c();
            proj.name = 'Test project';
            proj.pse__Project_Type__c = 'Internal';
            proj.pse__Project_Manager__c = con.Id;
            proj.pse__Is_Active__c = TRUE;
            proj.Services_Sub_Services__c = 'Other - Other';
            proj.pse__Is_Billable__c = TRUE;
            proj.pse__Stage__c = 'In Planning';
            proj.Client_BusinessUnit_CBU__c = '4Print';
            proj.pse__Region__c = region.ID;
            proj.pse__Practice__c = prac.ID;
            proj.pse__Opportunity__c = Opp.Id;
            insert proj; 
            
			PageReference pageRef = Page.ChangeRequestCreationOnProject;
			Test.setCurrentPage(pageRef);
			pageRef.getParameters().put('Id', String.valueOf(proj.Id));
			ApexPages.StandardController sc = new ApexPages.StandardController(proj);
			ChangeRequestCreationProjectController testClass = new ChangeRequestCreationProjectController(sc);
			testClass.saveData(); 
		}
	}
}