/******************************************************************************************************
* @Author      : Praveen Kumar
* @Date        : 16/March/2017 
* @Description : This test class is used to test the Opportunity_ForecastTemplate_Handler class.
* ****************************************************************************************************/

@isTest
public class Opportunity_ForecastTemplate_HandlerTest {
    
    public static testmethod void testForecaseTemplate(){ 
        
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
            
        ffrr__ForecastScheduleDefinition__c varForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        varForecastScheduleDefinition.Name = 'Test';
        varForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        varForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        varForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert varForecastScheduleDefinition;
  		
        //ffrr__Settings__c setting= [select id,name from ffrr__Settings__c where name='Opportunity Forecast Settings' limit 1];
        
         //Settings insert   
        ffrr__Settings__c setting1 = new ffrr__Settings__c(name='Opportunity Forecast Settings Test',ffrr__Object__c='Opportunity',ffrr__SettingsLevel__c='Primary',
                                                          ffrr__SettingsType__c='Forecast',ffrr__ForecastHeaderPrimaryRelationship__c='ffrr_Opportunity__c',
                                                          ffrr__ForecastTransactionLineRelationship__c='ffrr_Opportunity__c',ffrr__AccountName__c='AccountId',
                                                          ffrr__Description__c='Description',ffrr__StartDate__c='Start_Date__c',ffrr__EndDate__c='End_Date__c',
                                                          ffrr__TotalRevenue__c='Amount',ffrr__ActiveField__c='MOF_Approved__c',ffrr__ActiveValue__c='TRUE',
                                                          ffrr__IncludeActiveValue__c='Include',ffrr__Currency__c='CurrencyIsoCode');
            insert setting1;
            
        ffrr__Template__c varTemplate= new ffrr__Template__c();
        varTemplate.Name = 'Test';
        varTemplate.CurrencyIsoCode = 'USD';
        varTemplate.ffrr__CalculationType__c = 'Months';
        varTemplate.ffrr__ForecastScheduleDefinition__c = varForecastScheduleDefinition.id;
        varTemplate.ffrr__RevRecType__c = 'Equal Split';
        varTemplate.ffrr__RevenueBasis__c = 'Total Revenue';
        varTemplate.ffrr__RevenueSource__c = 'Opportunity';
        varTemplate.Opportunity_Service__c = 'Content - Content Factory';
        varTemplate.ffrr__Settings__c = setting1.id;
        varTemplate.Months__c = 2;
        insert varTemplate;       
      
        
        
        //create opportunity record
    
        Opportunity Opp = new Opportunity(Name='Test-opp',StageName='New',CloseDate=Date.today(),AccountId=a.Id, pse__Group__c=grp.id,Quote_Status__c = 'Approved',
                                         pse__Practice__c=prac.id,pse__Region__c=region.id,Client_Business_Unit_CBU__c='4Print',Specific_Project_Identified_w__c = true);
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        Opp.Services_Sub_Services__c='Content - Content Factory';
        Opp.Start_Date__c=Date.today();
        Opp.End_Date__c=Date.today().adddays(35);
        Opp.MOF_Approved__c=true;    
        insert Opp;
        
        Opportunity Opp1 = new Opportunity(Name='Test-opp1',Quote_Status__c = 'Approved',pse__Practice__c = prac.id,Revenue_Type__c='POC',Services_Sub_Services__c='Other - Other',
                                        StageName='New',CloseDate=Date.today(),AccountId=a.Id,Client_Business_Unit_CBU__c='4Print',Specific_Project_Identified_w__c = true);
        Opp1.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        Opp1.Services_Sub_Services__c='Content - Content Factory';
        Opp1.Start_Date__c=Date.today();
        Opp1.End_Date__c=Date.today().adddays(100); 
        Opp1.MOF_Approved__c=true;
        insert Opp1; 
       
            
            //Updating the Opportunity
            Opp1.Services_Sub_Services__c='Content - Content Factory;B2B - B2B';
            Opp1.End_Date__c=Date.today().addMonths(13); 
        	update Opp1;
            
            //Updating the Opportunity
            Opp.Services_Sub_Services__c='Content - Content Factory';
            Opp.End_Date__c=Date.today().addMonths(14); 
            Opp.MOF_Approved__c=false;
        	update Opp;
            
        
    }
    }

}