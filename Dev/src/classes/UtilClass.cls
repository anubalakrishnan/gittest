/******************************************************************************************************
* @Author      : Praveen Kumar
* @Date        : 16/March/2017 
* @Description : This test class is used to insert the test data.
* ****************************************************************************************************/

@isTest
public class UtilClass {
    
    
	 public static testmethod Opportunity createOpportunity(){ 
         
        // create Account record
        Account a = new Account(Name = 'Test Acc',Type = 'Client',Status__c= 'Active');    
        insert a;
        
         
       
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
        
        
        //create opportunity record
    
        Opportunity Opp = new Opportunity(Name='Test-opp',StageName='New',CloseDate=Date.today(),AccountId=a.Id, pse__Group__c=grp.id,
                                         pse__Practice__c=prac.id,pse__Region__c=region.id);
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        Opp.Services_Sub_Services__c='Sales - Sales';
        Opp.Start_Date__c=Date.today();
        Opp.End_Date__c=Date.today()+60;  
        insert Opp;
         
     return Opp;
     }
    
  
   /* public static void createTemplate(){ 
        
        ffrr__Settings__c Settings = new ffrr__Settings__c(Name='Opportunity Forecast Test Settings',ffrr__Description__c='Description',
                                                          ffrr__ActiveField__c='MOF_Approved__c',ffrr__ActiveValue__c='TRUE',
                                                          ffrr__Object__c='Opportunity',ffrr__TotalRevenue__c='Amount',
                                                          ffrr__SettingsType__c='Forecast',ffrr__AccountName__c='AccountId');
        Settings.ffrr__StartDate__c='Start_Date__c';
        Settings.ffrr__EndDate__c='End_Date__c';
        Settings.ffrr__SettingsLevel__c='Primary';
        Settings.ffrr__ForecastHeaderPrimaryRelationship__c='ffrr_Opportunity__c';
        Settings.ffrr__ForecastTransactionLineRelationship__c='ffrr_Opportunity__c';
        Settings.ffrr__IncludeActiveValue__c='Include';
        Settings.ffrr__Currency__c='CurrencyIsoCode';
        
        
            insert Settings;
            
		ffrr__Template__c template = new ffrr__Template__c(Name='Test Template',ffrr__Settings__c=Settings.id,
                                                          ffrr__RevenueBasis__c='Total Revenue',ffrr__CalculationType__c='Months',
                                                          Months__c=2,Opportunity_Service__c='Sales - Sales');
        
        	insert template;
        
    }*/
}