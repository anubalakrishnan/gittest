/*****************************************************************************
Author   : 	Praveen Kumar
Date     : 	29/March/2017
Action   : 	This is a handler class of trigger 'TriggerOnRevForecastTransLine'
			used to populate the Rollup of Budget Costs
******************************************************************************/
public class RevForecastTransLineHandler {
    
    //Map<String,double> oldrevLinesvalue = new Map<String,double>();
    
    public void validateForecastTransLineUpdate(List<ffrr__RevenueForecastTransactionLine__c> newLines,Map<ID,ffrr__RevenueForecastTransactionLine__c> oldLinesMap) {
        
        Set<Id> transSetIds = new Set<Id>();
        for (ffrr__RevenueForecastTransactionLine__c line : newLines) {
    	    if (line.ffrr__RevenueForecastTransaction__c != NULL && line.Category_Latest_formula__c &&
                line.Status_formula__c != 'Draft' && line.ffrr_exp__Project__c == NULL &&
                line.ffrr_Budget__c != NULL && line.ffrr__Period__c != NULL && 
                (line.ffrr__Value__c != oldLinesMap.get(line.ID).ffrr__Value__c
               || line.ffrr__Percentage__c != oldLinesMap.get(line.ID).ffrr__Percentage__c)) 
            {     
                   transSetIds.add(line.ffrr__RevenueForecastTransaction__c);
            }            
        }
        System.debug(LoggingLevel.INFO,'my debug statement');
        if(!transSetIds.isEmpty() && transSetIds != NULL)
        {
            system.debug('calling RevForecastTransLineHelper');
            RevForecastTransLineHelper TransLineHelper = new RevForecastTransLineHelper();
            TransLineHelper.getTransactionLines(transSetIds);
        }
            
    }
    
    public void validateForecastTransLine(List<ffrr__RevenueForecastTransactionLine__c> lines){
        Set<Id> transSetIds = new Set<Id>();
        for (ffrr__RevenueForecastTransactionLine__c line : lines) {
            if (line.ffrr__RevenueForecastTransaction__c != NULL && line.Category_Latest_formula__c &&
                line.Status_formula__c != 'Draft' && line.ffrr_exp__Project__c == NULL &&
                line.ffrr_Budget__c != NULL && line.ffrr__Period__c != NULL)
                    	
                	transSetIds.add(line.ffrr__RevenueForecastTransaction__c);
        }
        if(!transSetIds.isEmpty() && transSetIds != NULL)
        {
            RevForecastTransLineHelper TransLineHelper = new RevForecastTransLineHelper();
            TransLineHelper.getTransactionLines(transSetIds);
        }
            
    }
}