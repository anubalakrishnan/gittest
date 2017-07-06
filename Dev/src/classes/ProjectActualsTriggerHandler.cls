/**************************************************************************************************
Author   : Praveen Kumar
Date     : 21/March/2017
Action   : This is a handler class of trigger 'TriggerOnProjectActuals' and is
		   used to update Month_Project_Actual__c on ffrr__RevenueForecastTransactionLine__c Object
***************************************************************************************************/
public class ProjectActualsTriggerHandler {
    
    //Method used to update the RevenueForecastTransactionLine Object
    public void updateRevenueForecastTransLine(List<Project_Actuals__c> newProjActs){
        
        //Set of Projects and Recognition Periods of the Project Actuals
        Set<id> projIds = new Set<id>();
        Set<Date> startDates = new Set<Date>();
        for (Project_Actuals__c pa:newProjActs){
        	if (pa.Project__c!=NULL ){
            	projIds.add(pa.Project__c);
                /*Integer year = pa.As_Of_Date__c.month() == 1 ? pa.As_Of_Date__c.year() - 1 : pa.As_Of_Date__c.year();
                Integer month = pa.As_Of_Date__c.month() == 1 ? 12 : pa.As_Of_Date__c.month()-1;
                Date startDate=  Date.newInstance(year,month,1);*/
                startDates.add(pa.Start_Date_formula__c);
        	}
   		}
        
        if(!startDates.isEmpty() && startDates != NULL){
            //record lookup, finding RecognitionPeriod records
        	List<ffrr__RecognitionPeriod__c> periodIds = [select id,ffrr__StartDate__c from ffrr__RecognitionPeriod__c where ffrr__StartDate__c in: startDates];
            Map<Date,Id> periodMap = new Map<Date,Id>();
            for(ffrr__RecognitionPeriod__c period:periodIds)
                periodMap.put(period.ffrr__StartDate__c, period.Id);
        
        //This block will check if any RevenueForecastTransactionLines matching with Recognition period exists under the same Project
        if (!projIds.isEmpty() && projIds != NULL && !periodIds.isEmpty() && periodIds != NULL){
        	List<ffrr__RevenueForecastTransactionLine__c> lstRevForecast =[SELECT id,name,ffrr__Period__c,ffrr_exp__Project__c,Month_Project_Actual__c
                                                                             FROM ffrr__RevenueForecastTransactionLine__c 
                                                                            WHERE ffrr_exp__Project__c in: projIds
                                                                              AND ffrr__Period__c in : periodMap.values()];
            
            system.debug('lstRevForecast:'+lstRevForecast);
            if (!lstRevForecast.isEmpty() && lstRevForecast !=NULL){
                List<ffrr__RevenueForecastTransactionLine__c> lstRevForecastToUpdt = new List<ffrr__RevenueForecastTransactionLine__c>();
            	for (Project_Actuals__c projActs:newProjActs){
                    for (ffrr__RevenueForecastTransactionLine__c revLine:lstRevForecast){
                        //Assign the value of Revenue_Actuals__c to Month_Project_Actual__c
                        if (revLine.ffrr_exp__Project__c == projActs.Project__c && revLine.ffrr__Period__c == periodMap.get(projActs.Start_Date_formula__c)){
                            revLine.Month_Project_Actual__c = projActs.Revenue_Actuals__c;
                            lstRevForecastToUpdt.add(revLine);
                        }
                    }
                }
                system.debug('lstRevForecastToUpdt:'+lstRevForecastToUpdt);
                // DML statement
             	update lstRevForecastToUpdt;
                        
			}
        }
    }      
   }
}