/******************************************************************************************************
* @Author      : Praveen Kumar
* @Date        : April 2, 2017 
* @Description : This test class is used to test the RevForecastTransLineHandler class and 
                 TriggerOnRevForecastTransLine Trigger.
* ****************************************************************************************************/
@isTest(seealldata=true)
public class RevForecastTransLineHandlerTest {
    
    /*public static testmethod void testRevForecastTransLineHandler(){ 
        
       
        // create profile record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // create user record
        User u = new User(Alias = 'standt', Email='testuser@ge.com',EmailEncodingKey='UTF-8', 
                          LastName = 'Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuser1234@testorg.com');
        insert u;
        System.runas(u){
        // create Account record
        Account a = new Account(Name = 'Test Acc',Type = 'Client',status__c = 'Active');    
        insert a;
        
        pse__region__c region = new pse__region__c();
        region.Name = 'Test Region';
        insert region;
        
        pse__practice__c prac = new pse__practice__c();
        prac.Name = 'Test Practice';
        insert prac;
                
        pse__grp__c grp = new pse__grp__c();
        grp.Name = 'Test Group';
        insert grp;
                
        // Create test contact
        Contact contact = new Contact();
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;
        contact.Client_Business_Unit_CBU__c = '4Print';        
        insert contact;
        system.debug(LoggingLevel.INFO,'------>contact');    
            
        
        //ffrr__RecognitionPeriod__c varRecognitionPeriod=[select id from ffrr__RecognitionPeriod__c where name='FY2017/005' limit 1]; 
        
    	Test.startTest(); 
        
        //create Forecast Definitions for Project and Budget    
        ffrr__ForecastScheduleDefinition__c varForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        varForecastScheduleDefinition.Name = 'Test Project Forecast Definition';
        varForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        varForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        varForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert varForecastScheduleDefinition;
            
        ffrr__ForecastScheduleDefinition__c budgForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        budgForecastScheduleDefinition.Name = 'Test Budget Forecast Definition';
        budgForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        budgForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        budgForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert budgForecastScheduleDefinition;    
  		
        List<ffrr__Settings__c> settingList= [select id,name,ffrr__Object__c from ffrr__Settings__c where ffrr__Object__c in 
                                              ('pse__Proj__c','Project_Cost__c','pse__Budget__c')];
        
        Map<String,Id> settingsMap = new Map<String,Id>();
        for(ffrr__Settings__c setting:settingList)
            settingsMap.put(setting.ffrr__Object__c, setting.Id);
        
         system.debug(LoggingLevel.INFO,'settingsMap:'+settingsMap);
         String str =   'pse__Proj__c';
         system.debug(LoggingLevel.INFO,'settingsMapget:'+settingsMap.get(str));
            
         //Settings insert   
        /*ffrr__Settings__c setting1 = new ffrr__Settings__c(name='Project Forecast Settings Test',ffrr__Object__c='pse__Proj__c',ffrr__SettingsLevel__c='Primary',
                                                          ffrr__SettingsType__c='Forecast',ffrr__ForecastHeaderPrimaryRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__ForecastTransactionLineRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__Description__c='pse__Notes__c',ffrr__StartDate__c='Forecast_Start_Date__c',ffrr__EndDate__c='pse__End_Date__c',
                                                          ffrr__TotalRevenue__c='Remaining_Revenue__c',ffrr__ActiveField__c='pse__Include_In_Forecasting__c',ffrr__ActiveValue__c='TRUE',
                                                          ffrr__IncludeActiveValue__c='Include',ffrr__Currency__c='CurrencyIsoCode');*/
            //insert setting;
        
        //Project Template creation    
        /*ffrr__Template__c varTemplate= new ffrr__Template__c();
        varTemplate.Name = 'Test Project Template';
        varTemplate.CurrencyIsoCode = 'USD';
        varTemplate.ffrr__CalculationType__c = 'Months';
        varTemplate.ffrr__ForecastScheduleDefinition__c = varForecastScheduleDefinition.id;
        varTemplate.ffrr__RevRecType__c = 'Equal Split';
        varTemplate.ffrr__RevenueBasis__c = 'Total Revenue';
        varTemplate.ffrr__RevenueSource__c = 'pse__Proj__c';
        //varTemplate.Opportunity_Service__c = 'Content - Content Factory';
        varTemplate.ffrr__Settings__c = settingsMap.get(str);
        varTemplate.Months__c = 1;
        insert varTemplate;  
            
        //Budget Template creation    
        ffrr__Template__c budgTemplate= new ffrr__Template__c();
        budgTemplate.Name = 'Test Budget Template';
        budgTemplate.CurrencyIsoCode = 'USD';
        budgTemplate.ffrr__CalculationType__c = 'Months';
        budgTemplate.ffrr__ForecastScheduleDefinition__c = budgForecastScheduleDefinition.id; 
        budgTemplate.ffrr__RevRecType__c = 'Equal Split';
        budgTemplate.ffrr__RevenueBasis__c = 'Total Revenue';
        budgTemplate.ffrr__RevenueSource__c = 'pse__Budget__c';	
        //budgTemplate.Opportunity_Service__c = 'Content - Content Factory';
        budgTemplate.ffrr__Settings__c = settingsMap.get('pse__Budget__c');
        budgTemplate.Months__c = 1;
        insert budgTemplate;      
            
        system.debug(LoggingLevel.INFO,'Template ID------>'+varTemplate);
         
           
                     	
           
            
		 ffrr__RecognitionPeriod__c varRecognitionPeriod=[select id,name,ffrr__RecognitionYear__c,ffrr__StartDate__c,ffrr__EndDate__c
                                                       from ffrr__RecognitionPeriod__c where ffrr__StartDate__c = LAST_MONTH limit 1]; 
            
         system.debug(LoggingLevel.INFO,'varRecognitionPeriod------>'+varRecognitionPeriod);   
            
        Opportunity Opp = new Opportunity(Name='Test-opp',StageName='New',CloseDate=Date.today(),AccountId=a.Id, pse__Group__c=grp.id,Quote_Status__c = 'Approved',
                                         pse__Practice__c=prac.id,pse__Region__c=region.id,Client_Business_Unit_CBU__c='4Print',Specific_Project_Identified_w__c = true);
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        Opp.Services_Sub_Services__c='Content - Content Factory';
        Opp.Start_Date__c = varRecognitionPeriod.ffrr__StartDate__c;
        Opp.End_Date__c = varRecognitionPeriod.ffrr__EndDate__c;
        Opp.MOF_Approved__c=true;    
        insert Opp;    
        system.debug(LoggingLevel.INFO,'------>'+Opp.ID); 
        
        // Create project
        pse__proj__c proj = new pse__proj__c();
        proj.name = 'Test project';
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Project_Manager__c = contact.Id;
        proj.pse__Is_Active__c = TRUE;
        proj.Services_Sub_Services__c = 'Content - Content Factory';
        proj.pse__Is_Billable__c = TRUE;
        proj.pse__Stage__c = 'In Planning';
        proj.Client_BusinessUnit_CBU__c = '4Print';
        proj.pse__Region__c = region.ID;
        proj.pse__Practice__c = prac.ID;
        proj.pse__Group__c = grp.Id;
        proj.pse__Start_Date__c = varRecognitionPeriod.ffrr__StartDate__c;
        proj.pse__End_Date__c = varRecognitionPeriod.ffrr__EndDate__c;
        proj.pse__Stage__c = 'In Progress';    
        proj.pse__Include_In_Forecasting__c = true; 
        proj.CurrencyIsoCode = 'USD';
        proj.Revenue_Type__c = 'T&M';
        proj.pse__Account__c = a.ID;
        proj.pse__Opportunity__c = opp.ID;
        proj.ffrrtemplate__c = varTemplate.Id;
            
        insert proj; 
       system.debug(LoggingLevel.INFO,'proj------>'+proj);
            
       pse__Time_Period__c timeperiod = new pse__Time_Period__c();
       timeperiod.name = 'Test time period';
       timeperiod.pse__Start_Date__c = Date.newInstance(2010, 1, 1);
       timeperiod.pse__End_Date__c = Date.newInstance(2022, 12, 31);
       timeperiod.pse__Type__c = 'Perpetual';
       insert timeperiod;
            
       //insert Project Actuals     
       pse__Project_Actuals__c projActual = new pse__Project_Actuals__c();
       projActual.Name = 'Test project - All Time Periods';
       projActual.pse__Project__c = proj.Id;
       projActual.pse__Unique_Name__c = proj.Id +'-'+timeperiod.Id;
       projActual.pse__Time_Period__c = timeperiod.Id;
       projActual.pse__Bookings__c = 30000;
       insert projActual;
            
       //insert Project cost
       Project_Cost__c projCost = new Project_Cost__c();
       projCost.Name = 'Test Project Cost';
       projCost.Project__c = proj.Id;
       projCost.Cost__c = 8000;
       insert projCost;  
            system.debug('projCost:'+projCost);
            
            //create budget
            pse__Budget__c budget = new pse__Budget__c();
            budget.Name = 'Test Budget';        
            budget.pse__Type__c = 'Customer Purchase Order';
            budget.pse__Project__c = proj.Id;
            budget.Management_Personnel__c = TRUE;
            budget.Quantity__c = 0;
            budget.Start_Date__c = varRecognitionPeriod.ffrr__StartDate__c;
            budget.End_Date__c = varRecognitionPeriod.ffrr__EndDate__c;
            budget.Hours_Booked__c = 20;
            budget.Practice__c = prac.ID;
            budget.Expected_Cost__c = 4000;
            budget.Project_Cost__c = projCost.Id;
            budget.ffrrtemplate__c = budgTemplate.Id;
            insert budget;
			system.debug('budget:'+budget);      

  	//create Project Forecast Transaction
    ffrr__RevenueForecastTransaction__c varRevenueForecastTransaction= new ffrr__RevenueForecastTransaction__c();
    varRevenueForecastTransaction.ffrr__RecognitionYear__c=varRecognitionPeriod.ffrr__RecognitionYear__c;
    varRevenueForecastTransaction.ffrr__Category__c = 'Expected';
    varRevenueForecastTransaction.ffrr__Description__c = 'test';
    varRevenueForecastTransaction.ffrr__Settings__c = settingsMap.get(str);
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
            
    //create Budget Forecast Transaction
    ffrr__RevenueForecastTransaction__c varRevForecastTransBudg= new ffrr__RevenueForecastTransaction__c();
    varRevForecastTransBudg.ffrr__RecognitionYear__c=varRecognitionPeriod.ffrr__RecognitionYear__c;
    varRevForecastTransBudg.ffrr__Category__c = 'Expected';
    varRevForecastTransBudg.ffrr__Description__c = 'test Project Cost';
    varRevForecastTransBudg.ffrr__Settings__c = settingsMap.get('Project_Cost__c');
    varRevForecastTransBudg.ffrr__PrimaryObjectRecordId__c = projCost.Id ;
    varRevForecastTransBudg.ffrr__Status__c = 'Saved';
    varRevForecastTransBudg.ffrr_Project_Cost__c = projCost.Id ;
    insert varRevForecastTransBudg; 
	
  
    //create Budget Forecast Transaction Line  --- //Commented because of the error while we are inserting budget FTL      
    ffrr__RevenueForecastTransactionLine__c varRevForecastTransLineBudg= new ffrr__RevenueForecastTransactionLine__c();
    varRevForecastTransLineBudg.ffrr__RevenueForecastTransaction__c = varRevForecastTransBudg.id;
    varRevForecastTransLineBudg.ffrr__Period__c = varRecognitionPeriod.id;
    varRevForecastTransLineBudg.ffrr__ForecastRecordId__c = budget.Id;
    varRevForecastTransLineBudg.ffrr__Percentage__c = 15.0;
    varRevForecastTransLineBudg.ffrr__PrimaryObjectRecordName__c = projCost.Name;
    varRevForecastTransLineBudg.ffrr__Level2ObjectRecordName__c = budget.Name;
    varRevForecastTransLineBudg.ffrr__Template__c = budgTemplate.id;
    varRevForecastTransLineBudg.ffrr_Project_Cost__c = projCost.Id;
    varRevForecastTransLineBudg.ffrr_Budget__c = budget.Id;
    insert varRevForecastTransLineBudg;      	

    
            
    
       Test.stopTest();     
    }
    }*/
    
    public static testmethod void testRevForecastTransLineHandler2()
    { 
        test.startTest();
        List<ffrr__RevenueForecastTransactionLine__c> projLines = [select id,name,ffrr__Template__c,ffrr__Period__c,ffrr_exp__Project__c,
                                                               			ffrr__RevenueForecastTransaction__c,ffrr__Value__c,ffrr_exp__ValueCurrency__c,
                                                               			Rollup_of_Budget_Costs__c
                                                          		 from ffrr__RevenueForecastTransactionLine__c 
                                                         		where Category_Latest_formula__c=true
                                                           		  and ffrr__Period__c!=null 
                                                           		  and ffrr_exp__Project__c!=null
                                                              	  and ffrr_exp__Project__r.pse__Include_In_Forecasting__c = True
                                                              	  and ffrr_exp__Project__r.Revenue_Type__c = 'T&M'
                                                               	  and Status_formula__c != 'Draft'
                                                              	  and ffrr__Template__c in (select ffrrtemplate__c from pse__Proj__c)
                                                              	limit 10];
            Set<Id> projIds = new Set<Id>();
            Set<Id> periodIds = new Set<Id>();
            for(ffrr__RevenueForecastTransactionLine__c projLine:projLines){
                projIds.add(projLine.ffrr_exp__Project__c);
                periodIds.add(projLine.ffrr__Period__c);
            }
            
          ffrr__RevenueForecastTransactionLine__c budgLine = [select id,name,ffrr__Template__c,ffrr__Period__c,ffrr_exp__Project__c,
                                                               			ffrr__RevenueForecastTransaction__c,ffrr__Value__c,ffrr_exp__ValueCurrency__c,
                                                                 		Rollup_of_Budget_Costs__c,ffrr__Percentage__c,
                                                              			ffrr__RevenueForecastTransaction__r.ffrr_exp__Project__c,
                                                              			ffrr__RevenueForecastTransaction__r.ffrr__Status__c
                                                          		 from ffrr__RevenueForecastTransactionLine__c 
                                                                where category_Latest_formula__c=true
                                                           		  and ffrr__Period__c in: periodIds
                                                           		  and ffrr_exp__Project__c = NULL
                                                              	  and ffrr_Budget__c != NULL
                                                                  and ffrr_Budget__r.pse__Project__c in :projIds                                                              	  
                                                               	  and Status_formula__c != 'Draft'
                                                                limit 1];
            
           budgLine.ffrr__Value__c += 100;
           budgLine.ffrr__Percentage__c = NULL; 
           budgLine.ffrr_exp__Project__c = NULL;                  
          	
        	update budgLine;
        	delete budgLine;
        //system.assertEquals(budgLine.IsDeleted, false);
        try{
        	undelete budgLine;
        }catch(DmlException e){
            System.debug(e.getCause()+e.getMessage());
        }
        
        ffrr__RevenueForecastTransaction__c newProjTrans = [select ffrr__RecognitionYear__c,ffrr__Settings__c,ffrr__PrimaryObjectRecordId__c,
                                                            		ffrr__Status__c,ffrr_Project_Cost__c,ffrr__Category__c
                                                             from ffrr__RevenueForecastTransaction__c 
                                                            where id =:projLines[0].ffrr__RevenueForecastTransaction__c];
        system.debug(newProjTrans);
        try{
			ffrr__RevenueForecastTransaction__c newProjTransclone = newProjTrans.clone(false,false,false,false);
            insert newProjTransclone;
        }catch(DmlException e){
            System.debug(e.getCause()+e.getMessage());
        }
            
        test.stopTest();
    }
}