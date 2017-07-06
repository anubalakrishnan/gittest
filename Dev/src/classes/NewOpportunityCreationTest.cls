@isTest
public class NewOpportunityCreationTest{

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
			
			PageReference pageRef = Page.NewOpportunityCreationFromAccount;
			Test.setCurrentPage(pageRef);
			pageRef.getParameters().put('Id', String.valueOf(a.Id));
			ApexPages.StandardController sc = new ApexPages.StandardController(a);
			NewOpportunityCreationAccountController testClass = new NewOpportunityCreationAccountController(sc);
			testClass.saveData(); 
		}
	}	
}