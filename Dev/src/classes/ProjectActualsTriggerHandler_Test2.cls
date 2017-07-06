/******************************************************************************************************
 Author      : Ashwini B
 Date        : 17/April/2017 
 Description : This test class is used to test the ProjectActualsTriggerHandler class and importantly 
               with seeAllData = false
* ****************************************************************************************************/
@isTest
private class ProjectActualsTriggerHandler_Test2 {

    public static testmethod void test_1(){
        
        ffrr__RecognitionYear__c recYear = new ffrr__RecognitionYear__c();
        recYear.name = 'FY2017';
        recYear.ffrr__NumberOfMonths__c = 12;
        recYear.ffrr__PeriodCalculationBasis__c = 'Month';
        recYear.ffrr__StartDate__c = Date.newInstance(2017,1,1);
        recYear.ffrr__EndDate__c = Date.newInstance(2017,12,31);
        insert recYear;
                
        List<ffrr__RecognitionPeriod__c> recPeriodList = new List<ffrr__RecognitionPeriod__c>();
        for (integer i=1; i <= 12; i++) {
            ffrr__RecognitionPeriod__c recPeriod = new ffrr__RecognitionPeriod__c();
            recPeriod.name = 'FY2017/0' + String.valueOf(i).leftpad(2,'0');
            recPeriod.ffrr__NumberOfWeeks__c = 0;
            recPeriod.ffrr__PeriodNumber__c = String.valueOf(i).leftpad(3,'0');
            recPeriod.ffrr__RecognitionYear__c = recYear.Id;
            recPeriod.ffrr__StartDate__c = Date.newInstance(2016,1,1);
            recPeriod.ffrr__EndDate__c = Date.newInstance(2016,1,31);
            System.debug('----- recPeriod : ' + recPeriod);
            recPeriodList.add(recPeriod);            
        }
        insert recPeriodList; 
        
        /*
        PageReference pg = Page.ffrr__RevRecCalculatePeriods;
        Test.setCurrentPage(pg);
        ApexPages.StandardController sc = new ApexPages.StandardController(recYear);
        ffrr.RevRecCalendarController con = new ffrr.RevRecCalendarController(sc);
        sc.calculatePeriods(); */
        
    }
}