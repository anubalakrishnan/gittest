/********************************************************************************
Author   : 	Praveen Kumar
Date     : 	31/March/2017
Action   : 	This is another handler class of trigger 'TriggeronProject'
			used to update the Forecast Templates on the child budgets of Project
*********************************************************************************/
public class ProjectForecastBudgetsUpdate {
    
    public void validateForecastBudgetsUpdate(List<pse__Proj__c> newProj,Map<ID,pse__Proj__c> oldProjMap) {
        
        // This block checks if the relevant changes have been done to run this method
        
        List<Id> projectsToProcess = new List<Id>();
        for (pse__Proj__c proj : newProj) {
    	    if(proj.pse__Include_In_Forecasting__c != oldProjMap.get(proj.ID).pse__Include_In_Forecasting__c)
                projectsToProcess.add(proj.Id);
        }
        
        
        if(!projectsToProcess.isEmpty() && projectsToProcess != NULL){
            List<pse__Budget__c> budgetsToProcess = [select id,name,Start_Date__c,Forecast_Start_Date__c,End_Date__c,ffrrtemplate__c,
                                                     		Include_in_Forecast__c,pse__Project__r.pse__Include_In_Forecasting__c
                                                       from pse__Budget__c 
                                                      where pse__Project__c in:projectsToProcess];
            
            BudgetForecastTriggerHandler budgetHandler = new BudgetForecastTriggerHandler();
            budgetHandler.setBudgetForecastTemplates(budgetsToProcess);
            update budgetsToProcess;
        }
    }

}