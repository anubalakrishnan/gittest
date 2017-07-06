/********************************************************************
Author   : 	Praveen Kumar
Date     : 	24/March/2017
Action   : 	This is another handler class of trigger 'BudgetTrigger'
			used to populate the Forecast Templates on the Budget
********************************************************************/
public class BudgetForecastTriggerHandler {
    
    //Method to validate Project records to set the Forecast Templates while inserting
    public void validateBudgetForecastInsert(List<pse__Budget__c> newBudgets) {
        
        // This block checks if the relevant changes have been done to run this method
        List<pse__Budget__c> budgetsToProcess = new List<pse__Budget__c>();
        for (pse__Budget__c budget : newBudgets) {
        	if (budget.End_Date__c != NULL && budget.Start_Date__c != NULL && budget.ffrrtemplate__c == NULL
                && budget.pse__Project__r.pse__Include_In_Forecasting__c == TRUE)
            		budgetsToProcess.add(budget);
        }
        
        if (!budgetsToProcess.isEmpty() && budgetsToProcess != NULL)
        	setBudgetForecastTemplates(budgetsToProcess);
    }
    
    //Method to validate Project records to set the Forecast Templates while updating
    public void validateBudgetForecastUpdate(List<pse__Budget__c> newBudgets,Map<ID,pse__Budget__c> oldBudgetsMap) {
        
        // This block checks if the relevant changes have been done to run this method
        List<pse__Budget__c> budgetsToProcess = new List<pse__Budget__c>();
        for (pse__Budget__c budget : newBudgets) {
    	    if ((budget.End_Date__c != oldBudgetsMap.get(budget.ID).End_Date__c && budget.End_Date__c != NULL)
                || (budget.Start_Date__c != oldBudgetsMap.get(budget.ID).Start_Date__c && budget.Start_Date__c != NULL)
                ) {                        
                 	budgetsToProcess.add(budget);
            }
            system.debug('budget.Include_in_Forecast__c:'+budget.Include_in_Forecast__c);
        }
        if (!budgetsToProcess.isEmpty() && budgetsToProcess != NULL)
            setBudgetForecastTemplates(budgetsToProcess);
    }
    
     // Method to fetch the appropriate Budget Forecast Templates
    public void setBudgetForecastTemplates(List<pse__Budget__c> budgetList) {
		
        system.debug('entered setBudgetForecastTemplates method');
       
        //Set of months for all the Budgets 
		Set<Integer> allBudgets_months = new Set<Integer>();
        for (pse__Budget__c budget : budgetList) {
            Date forecast_start_date = budget.Forecast_Start_Date__c;// budget.Start_Date__c > Date.today() ? budget.Start_Date__c : Date.today();	
            if(budget.End_Date__c >= forecast_start_date){
                Integer monthsBetween = forecast_start_date.monthsBetween(budget.End_Date__c)+1;
                allBudgets_months.add(monthsBetween);
            }
		}        
			system.debug('allBudgets_months:'+allBudgets_months);
        // Get the map of associated Budget templates		
		List<ffrr__Template__c> allBudgetTemplates=[SELECT Id,Name,Months__c 
                                                      FROM ffrr__Template__c 
                                                     WHERE (Months__c in: allBudgets_months or Months__c = 18)
                                                       AND ffrr__RevenueSource__c='pse__Budget__c']; 
        
        system.debug('allBudgetTemplates:'+allBudgetTemplates);
        Map<Double,id> mapTemplates= new Map<Double,id>(); 	
        if (!allBudgetTemplates.isEmpty() && allBudgetTemplates != NULL) {			
			for (ffrr__Template__c budgetTemplate:allBudgetTemplates)
			{
            	if (budgetTemplate.Months__c!=NULL)
			    	mapTemplates.put(budgetTemplate.Months__c,budgetTemplate.id);
			}
		} 
        system.debug('mapTemplates:'+mapTemplates);
        
        for (pse__Budget__c budget:budgetList) {
            system.debug('budget.Include_in_Forecast__c:'+budget.Include_in_Forecast__c);          
            if(budget.Include_in_Forecast__c == TRUE ) {
                Date forecast_start_date = budget.Forecast_Start_Date__c;//budget.Start_Date__c > Date.today() ? budget.Start_Date__c : Date.today();	
                if(budget.End_Date__c >= forecast_start_date){
                    Integer monthsBetween = (forecast_start_date.monthsBetween(budget.End_Date__c)+1) > 12? 18 : forecast_start_date.monthsBetween(budget.End_Date__c)+1;
                    budget.ffrrtemplate__c  = mapTemplates.containsKey(monthsBetween)? mapTemplates.get(monthsBetween) : NULL;
                    System.debug('budget after setting template : ' + budget.ffrrtemplate__c);
                }
            } else 
                budget.ffrrtemplate__c = NULL;
        }
        
	}
}