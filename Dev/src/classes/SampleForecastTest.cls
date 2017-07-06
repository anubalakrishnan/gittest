@isTest
private class SampleForecastTest {
	
    private static testmethod void testRevForecastTransLineHandler(){ 
        
        ffrr__RecognitionYear__c recYear = new ffrr__RecognitionYear__c();
        recYear.ffrr__StartDate__c = Date.newInstance(2016,11,1);
        recYear.ffrr__EndDate__c = Date.newInstance(2017,10,31);
        recYear.ffrr__NumberOfMonths__c = 12;
        recYear.ffrr__PeriodCalculationBasis__c = 'Month';
        recYear.Name = 'Test FY';
        insert recYear;
        
        List<ffrr__RecognitionPeriod__c> listRecPeriod = new List<ffrr__RecognitionPeriod__c>();
        ffrr__RecognitionPeriod__c recPeriod = new ffrr__RecognitionPeriod__c();
        recPeriod.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod.Name = 'Test Period1';
        recPeriod.ffrr__StartDate__c = Date.newInstance(2016,11,1);
        recPeriod.ffrr__PeriodNumber__c = '001';
        recPeriod.ffrr__EndDate__c = Date.newInstance(2016,11,30);
        listRecPeriod.add(recPeriod);
        
        ffrr__RecognitionPeriod__c recPeriod1 = new ffrr__RecognitionPeriod__c();
        recPeriod1.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod1.Name = 'Test Period1';
        recPeriod1.ffrr__StartDate__c = Date.newInstance(2016,12,1);
        recPeriod1.ffrr__PeriodNumber__c = '002';
        recPeriod1.ffrr__EndDate__c = Date.newInstance(2016,12,31);
        listRecPeriod.add(recPeriod1);
        
        ffrr__RecognitionPeriod__c recPeriod2 = new ffrr__RecognitionPeriod__c();
        recPeriod2.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod2.Name = 'Test Period1';
        recPeriod2.ffrr__StartDate__c = Date.newInstance(2017,1,1);
        recPeriod2.ffrr__PeriodNumber__c = '003';
        recPeriod2.ffrr__EndDate__c = Date.newInstance(2017,1,31);
        listRecPeriod.add(recPeriod2);
        
        ffrr__RecognitionPeriod__c recPeriod3 = new ffrr__RecognitionPeriod__c();
        recPeriod3.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod3.Name = 'Test Period1';
        recPeriod3.ffrr__StartDate__c = Date.newInstance(2017,2,1);
        recPeriod3.ffrr__PeriodNumber__c = '004';
        recPeriod3.ffrr__EndDate__c = Date.newInstance(2017,2,28);
        listRecPeriod.add(recPeriod3);
        
        ffrr__RecognitionPeriod__c recPeriod4 = new ffrr__RecognitionPeriod__c();
        recPeriod4.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod4.Name = 'Test Period1';
        recPeriod4.ffrr__StartDate__c = Date.newInstance(2017,3,1);
        recPeriod4.ffrr__PeriodNumber__c = '005';
        recPeriod4.ffrr__EndDate__c = Date.newInstance(2017,3,31);
        listRecPeriod.add(recPeriod4);
        
        ffrr__RecognitionPeriod__c recPeriod5 = new ffrr__RecognitionPeriod__c();
        recPeriod5.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod5.Name = 'Test Period1';
        recPeriod5.ffrr__StartDate__c = Date.newInstance(2017,4,1);
        recPeriod5.ffrr__PeriodNumber__c = '006';
        recPeriod5.ffrr__EndDate__c = Date.newInstance(2017,4,30);
        listRecPeriod.add(recPeriod5);
        
        ffrr__RecognitionPeriod__c recPeriod6 = new ffrr__RecognitionPeriod__c();
        recPeriod6.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod6.Name = 'Test Period1';
        recPeriod6.ffrr__StartDate__c = Date.newInstance(2017,5,1);
        recPeriod6.ffrr__PeriodNumber__c = '007';
        recPeriod6.ffrr__EndDate__c = Date.newInstance(2017,5,31);
        listRecPeriod.add(recPeriod6);
        
        ffrr__RecognitionPeriod__c recPeriod7 = new ffrr__RecognitionPeriod__c();
        recPeriod7.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod7.Name = 'Test Period1';
        recPeriod7.ffrr__StartDate__c = Date.newInstance(2017,6,1);
        recPeriod7.ffrr__PeriodNumber__c = '008';
        recPeriod7.ffrr__EndDate__c = Date.newInstance(2017,6,30);
        listRecPeriod.add(recPeriod7);
        
        ffrr__RecognitionPeriod__c recPeriod8 = new ffrr__RecognitionPeriod__c();
        recPeriod8.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod8.Name = 'Test Period1';
        recPeriod8.ffrr__StartDate__c = Date.newInstance(2017,7,1);
        recPeriod8.ffrr__PeriodNumber__c = '009';
        recPeriod8.ffrr__EndDate__c = Date.newInstance(2017,7,31);
        listRecPeriod.add(recPeriod8);
        
        ffrr__RecognitionPeriod__c recPeriod9 = new ffrr__RecognitionPeriod__c();
        recPeriod9.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod9.Name = 'Test Period1';
        recPeriod9.ffrr__StartDate__c = Date.newInstance(2017,8,1);
        recPeriod9.ffrr__PeriodNumber__c = '010';
        recPeriod9.ffrr__EndDate__c = Date.newInstance(2017,8,31);
        listRecPeriod.add(recPeriod9);
        
        ffrr__RecognitionPeriod__c recPeriod10 = new ffrr__RecognitionPeriod__c();
        recPeriod10.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod10.Name = 'Test Period1';
        recPeriod10.ffrr__StartDate__c = Date.newInstance(2017,9,1);
        recPeriod10.ffrr__PeriodNumber__c = '011';
        recPeriod10.ffrr__EndDate__c = Date.newInstance(2017,9,30);
        listRecPeriod.add(recPeriod10);
        
        ffrr__RecognitionPeriod__c recPeriod11 = new ffrr__RecognitionPeriod__c();
        recPeriod11.ffrr__RecognitionYear__c = recYear.Id;
        recPeriod11.Name = 'Test Period1';
        recPeriod11.ffrr__StartDate__c = Date.newInstance(2017,10,1);
        recPeriod11.ffrr__PeriodNumber__c = '012';
        recPeriod11.ffrr__EndDate__c = Date.newInstance(2017,10,31);
        listRecPeriod.add(recPeriod11);
        
        insert listRecPeriod;
    }
    
}