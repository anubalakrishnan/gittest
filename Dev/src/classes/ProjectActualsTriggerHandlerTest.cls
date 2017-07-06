/******************************************************************************************************
* @Author      : Praveen Kumar
* @Date        : 21/March/2017 
* @Description : This test class is used to test the ProjectActualsTriggerHandler class.
* ****************************************************************************************************/

@isTest(seealldata=true)
public class ProjectActualsTriggerHandlerTest {
    
    public static testmethod void insertProjectActualsTest(){
        
       Test.startTest(); 
    // create profile record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // create user record
        User u = new User(Alias = 'standt', Email='testuser@ge.com',EmailEncodingKey='UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuser1234@testorg.com');
        insert u;
        System.runas(u){
            
		// Create test contact
        Contact contact = new Contact();
        contact.firstname = 'Mosaic';    
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;
        contact.Client_Business_Unit_CBU__c = '4Print';        
        insert contact;
                   
        
           
   	/*ffrr__RecognitionYear__c varRecognitionYear= new ffrr__RecognitionYear__c();
    varRecognitionYear.Name = 'FY2017';
    varRecognitionYear.ffrr__NumberOfMonths__c = 1;
    varRecognitionYear.ffrr__StartDate__c = Date.Today();
    varRecognitionYear.ffrr__EndDate__c = Date.Today()+30;
    varRecognitionYear.ffrr__PeriodCalculationBasis__c = 'Month'; 
    insert varRecognitionYear;   
            
    ffrr.RevRecCalendarController calcPeriods = new ffrr.RevRecCalendarController();   
            calcPeriods.calculatePeriods();
    
    ffrr__RecognitionPeriod__c varRecognitionPeriod= new ffrr__RecognitionPeriod__c();
    varRecognitionPeriod.Name = 'FY2017/005';
    varRecognitionPeriod.ffrr__RecognitionYear__c = varRecognitionYear.id;
    varRecognitionPeriod.ffrr__EndDate__c = Date.Today()+10;
    varRecognitionPeriod.ffrr__PeriodNumber__c = '005';
    varRecognitionPeriod.ffrr__Period_Group__c = 'Q1';
    varRecognitionPeriod.ffrr__StartDate__c = Date.Today();  
  	insert varRecognitionPeriod;
	
           
	ffrr__RecognitionPeriod__c varRecognitionPeriod=[select id,ffrr__RecognitionYear__c,name,ffrr__StartDate__c,
                                                     ffrr__EndDate__c from ffrr__RecognitionPeriod__c where 
                                                     ffrr__RecognitionYear__r.name like '%2017%' limit 1];
	system.assert(varRecognitionPeriod != null,'No record exists with the entered criteria');
  */          
    /*ffrr__ForecastScheduleDefinition__c varForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        varForecastScheduleDefinition.Name = 'Test';
        varForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        varForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        varForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert varForecastScheduleDefinition;
            
  		ffrr__Settings__c setting1= [select id,name from ffrr__Settings__c where ffrr__Object__c='pse__Proj__c' limit 1];
        /*ffrr__Settings__c setting = new ffrr__Settings__c(name='Project Forecast Settings Test',ffrr__Object__c='pse__Proj__c',ffrr__SettingsLevel__c='Primary',
                                                          ffrr__SettingsType__c='Forecast',ffrr__ForecastHeaderPrimaryRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__ForecastTransactionLineRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__Description__c='pse__Notes__c',ffrr__StartDate__c='Forecast_Start_Date__c',ffrr__EndDate__c='pse__End_Date__c',
                                                          ffrr__TotalRevenue__c='Remaining_Revenue__c',ffrr__ActiveField__c='pse__Include_In_Forecasting__c',ffrr__ActiveValue__c='TRUE',
                                                          ffrr__IncludeActiveValue__c='Include',ffrr__Currency__c='CurrencyIsoCode');
            insert setting1;*/
            
       /* ffrr__Template__c varTemplate= new ffrr__Template__c();
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
	
    ffrr__RecognitionPeriod__c varRecognitionPeriod=[select id,name,ffrr__EndDate__c,ffrr__RecognitionYear__c,ffrr__StartDate__c 
                                                       from ffrr__RecognitionPeriod__c where ffrr__StartDate__c = LAST_MONTH limit 1]; 
  
    ffrr__RevenueForecastTransaction__c varRevenueForecastTransaction= new ffrr__RevenueForecastTransaction__c();
    //varRevenueForecastTransaction.CurrencyIsoCode = 'USD';
    varRevenueForecastTransaction.ffrr__RecognitionYear__c=varRecognitionPeriod.ffrr__RecognitionYear__c;
    //varRevenueForecastTransaction.ffrr__Account__c = 'aaaaaaaaa';
    varRevenueForecastTransaction.ffrr__Category__c = 'Expected';
    varRevenueForecastTransaction.ffrr__Currency__c = 'USD';
    varRevenueForecastTransaction.ffrr__Description__c = 'test';
    varRevenueForecastTransaction.ffrr__EndDate__c = varRecognitionPeriod.ffrr__EndDate__c; 
    varRevenueForecastTransaction.ffrr__Settings__c = setting1.id;
    varRevenueForecastTransaction.ffrr__PrimaryObjectRecordId__c = proj.id ;
    varRevenueForecastTransaction.ffrr__PrimaryObjectRecordName__c = proj.Name;
    varRevenueForecastTransaction.ffrr__StartDate__c = varRecognitionPeriod.ffrr__StartDate__c;
    varRevenueForecastTransaction.ffrr__Status__c = 'Saved';
    varRevenueForecastTransaction.ffrr_exp__Project__c = proj.id;
    varRevenueForecastTransaction.ffrr__TotalRevenue__c = 35000;
    
    insert varRevenueForecastTransaction; 

  
    ffrr__RevenueForecastTransactionLine__c varRevenueForecastTransactionLine= new ffrr__RevenueForecastTransactionLine__c();
    varRevenueForecastTransactionLine.ffrr__RevenueForecastTransaction__c = varRevenueForecastTransaction.id;
    varRevenueForecastTransactionLine.ffrr__Period__c = varRecognitionPeriod.id;
    varRevenueForecastTransactionLine.ffrr__ForecastRecordId__c = 'aaaaaaaaa';
    varRevenueForecastTransactionLine.ffrr__Percentage__c = 10.0;
    varRevenueForecastTransactionLine.ffrr__PrimaryObjectRecordName__c = proj.Name;
    varRevenueForecastTransactionLine.ffrr__Template__c = varTemplate.id;
    varRevenueForecastTransactionLine.ffrr_exp__Project__c = proj.Id;
    insert varRevenueForecastTransactionLine;
          
	    */
        //create Forecast Definitions for Project    
        ffrr__ForecastScheduleDefinition__c varForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        varForecastScheduleDefinition.Name = 'Test Project Forecast Definition';
        varForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        varForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        varForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert varForecastScheduleDefinition;
            
        List<ffrr__Settings__c> settingList= [select id,name,ffrr__Object__c from ffrr__Settings__c where ffrr__Object__c in 
                                              ('pse__Proj__c','Project_Cost__c','pse__Budget__c')];
        
        Map<String,Id> settingsMap = new Map<String,Id>();
        for(ffrr__Settings__c setting:settingList)
            settingsMap.put(setting.ffrr__Object__c, setting.Id);
        
        //Project Template creation    
        ffrr__Template__c varTemplate= new ffrr__Template__c();
        varTemplate.Name = 'Test Project Template';
        varTemplate.CurrencyIsoCode = 'USD';
        varTemplate.ffrr__CalculationType__c = 'Months';
        varTemplate.ffrr__ForecastScheduleDefinition__c = varForecastScheduleDefinition.id;
        varTemplate.ffrr__RevRecType__c = 'Equal Split';
        varTemplate.ffrr__RevenueBasis__c = 'Total Revenue';
        varTemplate.ffrr__RevenueSource__c = 'pse__Proj__c';
        //varTemplate.Opportunity_Service__c = 'Content - Content Factory';
        varTemplate.ffrr__Settings__c = settingsMap.get('pse__Proj__c');
        varTemplate.Months__c = 2;
        insert varTemplate;  
            
        ffrr__RecognitionPeriod__c varRecognitionPeriod=[select id,name,ffrr__EndDate__c,ffrr__RecognitionYear__c,ffrr__StartDate__c 
                                                       from ffrr__RecognitionPeriod__c where ffrr__StartDate__c = LAST_MONTH limit 1];
            
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Content - Content Factory';
        proj.pse__Is_Billable__c = TRUE;
        proj.Client_BusinessUnit_CBU__c = '4Print';
        proj.pse__Start_Date__c = varRecognitionPeriod.ffrr__StartDate__c;
        proj.pse__End_Date__c = varRecognitionPeriod.ffrr__EndDate__c;
        proj.pse__Stage__c = 'In Progress';    
        proj.pse__Include_In_Forecasting__c = true; 
        proj.CurrencyIsoCode = 'USD';
        proj.Revenue_Type__c = 'T&M';
        proj.ffrrtemplate__c = varTemplate.Id;    
        insert proj;    
            
        pse__Time_Period__c timeperiod = new pse__Time_Period__c();
       timeperiod.name = 'Test time period';
       timeperiod.pse__Start_Date__c = Date.newInstance(2010, 1, 1);
       timeperiod.pse__End_Date__c = Date.newInstance(2022, 12, 31);
       timeperiod.pse__Type__c = 'Perpetual';
       insert timeperiod;
            
       //create Project Actuals     
       pse__Project_Actuals__c projActual = new pse__Project_Actuals__c();
       projActual.Name = 'Test project - All Time Periods';
       projActual.pse__Project__c = proj.Id;
       projActual.pse__Unique_Name__c = proj.Id +'-'+timeperiod.Id;
       projActual.pse__Time_Period__c = timeperiod.Id;
       projActual.pse__Bookings__c = 30000;
       insert projActual;    
            
    //create Project Forecast Transaction
    ffrr__RevenueForecastTransaction__c varRevenueForecastTransaction= new ffrr__RevenueForecastTransaction__c();
    varRevenueForecastTransaction.ffrr__RecognitionYear__c=varRecognitionPeriod.ffrr__RecognitionYear__c;
    varRevenueForecastTransaction.ffrr__Category__c = 'Expected';
    varRevenueForecastTransaction.ffrr__Description__c = 'test';
    varRevenueForecastTransaction.ffrr__Settings__c = settingsMap.get('pse__Proj__c');
    varRevenueForecastTransaction.ffrr__PrimaryObjectRecordId__c = proj.id ;
    varRevenueForecastTransaction.ffrr__Status__c = 'Saved';
    varRevenueForecastTransaction.ffrr_exp__Project__c = proj.id;
        
    insert varRevenueForecastTransaction; 
	
  
    //create Project Forecast Transaction Line        
    ffrr__RevenueForecastTransactionLine__c varRevenueForecastTransactionLine= new ffrr__RevenueForecastTransactionLine__c();
    varRevenueForecastTransactionLine.ffrr__RevenueForecastTransaction__c = varRevenueForecastTransaction.id;
    varRevenueForecastTransactionLine.ffrr__Period__c = varRecognitionPeriod.id;
    varRevenueForecastTransactionLine.ffrr__ForecastRecordId__c = proj.Id;
    varRevenueForecastTransactionLine.ffrr__Percentage__c = 10.0;
    varRevenueForecastTransactionLine.ffrr__PrimaryObjectRecordName__c = proj.Name;
    varRevenueForecastTransactionLine.ffrr__Template__c = varTemplate.id;
    varRevenueForecastTransactionLine.ffrr_exp__Project__c = proj.Id;
    insert varRevenueForecastTransactionLine;    
  
		//create Project Monthly Actuals    
        Project_Actuals__c varProjectMonthlyActuals= new Project_Actuals__c();
        varProjectMonthlyActuals.CurrencyIsoCode = 'USD';
        //varProjectMonthlyActuals.Recognition_Period__c = varRecognitionPeriod;
        varProjectMonthlyActuals.ERP_Reference__c = 'aaaaaaaaaTest';
        varProjectMonthlyActuals.Project__c=proj.id;
        varProjectMonthlyActuals.As_Of_Date__c=date.today();
        varProjectMonthlyActuals.Revenue_Actuals__c=100;
        varProjectMonthlyActuals.Recognition_Period__c=varRecognitionPeriod.Id;
            
         insert  varProjectMonthlyActuals;  
            
       Test.stopTest();     
    }

	}
}