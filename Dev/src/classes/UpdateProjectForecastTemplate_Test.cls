/******************************************************************************************************
* @Author      : Mihir Kumar
* @Date        : April 1, 2017 
* @Description : This test class is used to test the UpdateProjectForecastTemplateBatch batch classes.
* ****************************************************************************************************/
@isTest

public class UpdateProjectForecastTemplate_Test {
  
    //PUBLIC STATIC Opportunity Opp;
    //Test Data Setup
    @testSetup static void dataSetupMethod(){
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
        
      //  System.debug('Inserted contact - ' + contact);    
        
        //create opportunity record
         Opportunity Opp = new Opportunity(Name='Test-opp',Quote_Status__c = 'Approved',Services_Sub_Services__c='Other - Other',
                                          StageName='New',CloseDate=Date.today(),AccountId=a.Id,Specific_Project_Identified_w__c = true,
                                          pse__Region__c=region.id,pse__Practice__c = prac.id,pse__Group__c=grp.id, 
                                          Start_Date__c = Date.today().addDays(-30), End_Date__c = Date.today().addDays(30));
        Opp.RecordTypeId=[select Id,Name from RecordType where Name ='New Opportunity' and SobjectType = 'Opportunity'].Id;
        Opp.Client_Business_Unit_CBU__c='CHI1';
        Opp.Revenue_Type__c='T&M';
        insert Opp;
        system.debug('Opp1@@@@@: '+opp);
        
        // Access pricebookid
    //    Id pricebookId = Test.getStandardPricebookId();
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
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(30),
            TotalPrice = 200
        );
        insert oli;
                
    	}
    }
    
    public static testmethod void testbatch1(){ 
        
        User u = [select id,name,email,username,profileid from user where username='testuser1234@testorg.com'];
        System.runas(u){
        
            
        Opportunity opp1 = [Select Id, Name, Primary_Quote_Count__c, Awaiting_Final_Signature__c 
                            from Opportunity where Name LIKE '%Test-opp%' LIMIT 1];
        opp1.Primary_Quote_Count__c = 1;
        opp1.Awaiting_Final_Signature__c = true;
        update opp1;
            
        //Create ForecastScheduleDefinition record
        ffrr__ForecastScheduleDefinition__c varForecastScheduleDefinition= new ffrr__ForecastScheduleDefinition__c();
        varForecastScheduleDefinition.Name = 'Test';
        varForecastScheduleDefinition.CurrencyIsoCode = 'USD';
        varForecastScheduleDefinition.ffrr__Description__c = 'aaaaaaaaa';
        varForecastScheduleDefinition.ffrr__StartsOn__c = 'Start of the record';
        insert varForecastScheduleDefinition;
        
        //Setting Data for ffrr__Settings__c
        
        ffrr__Settings__c setting1 = new ffrr__Settings__c(name='Project Forecast Settings Test',ffrr__Object__c='pse__Proj__c',ffrr__SettingsLevel__c='Primary',
                                                          ffrr__SettingsType__c='Forecast',ffrr__ForecastHeaderPrimaryRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__ForecastTransactionLineRelationship__c='ffrr_exp__Project__c',
                                                          ffrr__Description__c='pse__Notes__c',ffrr__StartDate__c='Forecast_Start_Date__c',ffrr__EndDate__c='pse__End_Date__c',
                                                          ffrr__TotalRevenue__c='Remaining_Revenue__c',ffrr__ActiveField__c='pse__Include_In_Forecasting__c',ffrr__ActiveValue__c='TRUE',
                                                          ffrr__IncludeActiveValue__c='Include',ffrr__Currency__c='CurrencyIsoCode');
            insert setting1;
        
        //Create Template record
        ffrr__Template__c varTemplate= new ffrr__Template__c();
        varTemplate.Name = 'Test';
        varTemplate.CurrencyIsoCode = 'USD';
        varTemplate.ffrr__CalculationType__c = 'Months';
        varTemplate.ffrr__ForecastScheduleDefinition__c = varForecastScheduleDefinition.id;
        varTemplate.ffrr__RevRecType__c = 'Equal Split';
        varTemplate.ffrr__RevenueBasis__c = 'Total Revenue';
        varTemplate.ffrr__RevenueSource__c = 'pse__Proj__c';
        //varTemplate.Opportunity_Service__c = 'Content - Content Factory';
        varTemplate.ffrr__Settings__c = setting1.id;
        varTemplate.Months__c = 2;
        insert varTemplate;  
            
        
        pse__Proj__c projdata = [select id, pse__Stage__c, pse__Project_Manager__c, ERP_Project_Type__c, pse__Start_Date__c, pse__End_Date__c,Client_BusinessUnit_CBU__c
                                 from pse__Proj__c  where pse__Opportunity__c =: opp1.id];
        System.debug('project data ====' + projdata + 'proj manager id == >' + projdata.pse__project_manager__c);
        projdata.pse__Stage__c = 'Closed Won';
        projdata.ERP_Project_Type__c = 'Billable Project';
        projdata.pse__Start_Date__c = Date.today().addDays(-30);
        projdata.pse__End_Date__c = Date.today().addDays(30);
        //projdata.ffrrtemplate__c = varTemplate.Id;
        Update projdata;
        
        //call the scheduler class
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String strJobId = System.schedule('UpdateForecastTemplateBatch', CRON_EXP, new UpdateForecastTemplateScheduler()); 
        
        // Call UpdateBudgetForecastTemplateBatch Batch Class
        UpdateBudgetForecastTemplateBatch Projectbatch = new UpdateBudgetForecastTemplateBatch();
        Database.executebatch(Projectbatch); 
        
        // Call UpdateProjectForecastTemplateBatch Batch Class
        UpdateProjectForecastTemplateBatch Budgetbatch = new UpdateProjectForecastTemplateBatch();
        Database.executebatch(Budgetbatch); 
        }
    }   
    
    public static testmethod void testbatch2(){ 
        
        User u = [select id,name,email,username,profileid from user where username='testuser1234@testorg.com'];
        
        System.runas(u){
        
    	Opportunity opp2 = [Select Id, Name, Primary_Quote_Count__c, Awaiting_Final_Signature__c 
                            from Opportunity where Name LIKE '%Test-opp%' LIMIT 1];
        opp2.Primary_Quote_Count__c = 1;
        opp2.Awaiting_Final_Signature__c = true;
        update opp2;
        
        pse__Proj__c projdata = [select id, pse__Stage__c, pse__Project_Manager__c, ERP_Project_Type__c, pse__Start_Date__c, pse__End_Date__c
                                 from pse__Proj__c  where pse__Opportunity__c =: opp2.id];
        System.debug('project data ====' + projdata + 'proj manager id == >' + projdata.pse__project_manager__c);
        
        if(projdata!=Null){
            List<pse__Budget__c> budgetData = [Select id, Name, Start_Date__c, End_Date__c
                                         from pse__Budget__c where pse__Project__c =: projdata.Id];
            if(budgetData.size()>0){
                for(pse__Budget__c budget1 : budgetData)
                  budget1.Start_Date__c = Date.today().addDays(1);
                Update budgetData;
            }    
        
            projdata.pse__Stage__c = 'Closed Won';
            projdata.ERP_Project_Type__c = 'Billable Project';
            projdata.pse__Start_Date__c = Date.today();
            projdata.pse__End_Date__c = Date.today().addDays(30);
            //projdata.ffrrtemplate__c = varTemplate.Id;
            Update projdata;
        }
        
        //call the scheduler class
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String strJobId = System.schedule('UpdateForecastTemplateBatch', CRON_EXP, new UpdateForecastTemplateScheduler()); 
        
        // Call UpdateBudgetForecastTemplateBatch Batch Class
        UpdateBudgetForecastTemplateBatch Projectbatch = new UpdateBudgetForecastTemplateBatch();
        Database.executebatch(Projectbatch); 
        
        // Call UpdateProjectForecastTemplateBatch Batch Class
        UpdateProjectForecastTemplateBatch Budgetbatch = new UpdateProjectForecastTemplateBatch();
        Database.executebatch(Budgetbatch);         
        }
    }
    
    public static testmethod void testbatch3(){ 
        User u = [select id,name,email,username,profileid from user where username='testuser1234@testorg.com'];
        
        
        System.runas(u){
                    
        Opportunity opp1 = [Select Id, Name, Primary_Quote_Count__c, Awaiting_Final_Signature__c 
                            from Opportunity where Name LIKE '%Test-opp%' LIMIT 1];
        opp1.Primary_Quote_Count__c = 1;
        opp1.Awaiting_Final_Signature__c = true;
        update opp1;
        
            
        /*ffrr__Template__c  varTemplate=[select id,name,ffrr__RevenueBasis__c,ffrr__Settings__c,Months__c,ffrr__RevenueSource__c 
                                          from ffrr__Template__c where ffrr__RevenueSource__c='pse__Proj__c'];   */
        
        pse__Proj__c projdata = [select id, pse__Stage__c, pse__Project_Manager__c, ERP_Project_Type__c, pse__Start_Date__c, pse__End_Date__c
                                 from pse__Proj__c  where pse__Opportunity__c =: opp1.id];
        System.debug('project data ====' + projdata + 'proj manager id == >' + projdata.pse__project_manager__c);
        projdata.pse__Stage__c = 'Closed Won';
        projdata.ERP_Project_Type__c = 'Billable Project';
        projdata.pse__Start_Date__c = Date.today().addDays(-30);
        projdata.pse__End_Date__c = Date.today().addDays(30);
        //projdata.ffrrtemplate__c = varTemplate.Id;
        Update projdata;
        
        //call the scheduler class
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String strJobId = System.schedule('UpdateForecastTemplateBatch', CRON_EXP, new UpdateForecastTemplateScheduler()); 
        
        // Call UpdateBudgetForecastTemplateBatch Batch Class
        UpdateBudgetForecastTemplateBatch Projectbatch = new UpdateBudgetForecastTemplateBatch();
        Database.executebatch(Projectbatch); 
        
        // Call UpdateProjectForecastTemplateBatch Batch Class
        UpdateProjectForecastTemplateBatch Budgetbatch = new UpdateProjectForecastTemplateBatch();
        Database.executebatch(Budgetbatch); 
        }
    }  
}