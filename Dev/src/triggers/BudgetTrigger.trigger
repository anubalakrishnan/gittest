/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Misc Adjustment object.
Date           : 23/March/2017
Action         : Create Resource Requests on budget creation
                 Delete Resource Requests / Assignments on budget update and create new 
                 resource requests if applicable
                 Uncheck Financials and close related assignments for time entry on related
                 assignments when budget is rejected
********************************************************************************************/
trigger BudgetTrigger on pse__Budget__c (after insert, after update, before update,before insert) {

    System.debug('----- Entered BudgetTrigger');
    
    
    if (Trigger.isInsert) {
        // Resource Request creation logic
        if(Trigger.isAfter){
            BudgetTriggerHandler budgetHandler = new BudgetTriggerHandler();
            budgetHandler.createResourceRequests(Trigger.NEW);
        }
        // Set Forecast Template when budget is getting inserted
        if(Trigger.isBefore){
            BudgetForecastTriggerHandler forecastHandler = new BudgetForecastTriggerHandler();
            forecastHandler.validateBudgetForecastInsert(Trigger.NEW);
            
            BudgetTriggerHandler budgetHandler = new BudgetTriggerHandler();
            budgetHandler.validateDocketBudgetStatus(Trigger.NEW);
        }
    }
    
    // Resource Request and Assignment deletion logic
    if (Trigger.isUpdate && Trigger.isAfter) {
        BudgetOLIUpdateTriggerHandler budgetOLIHandler = new BudgetOLIUpdateTriggerHandler();
        budgetOLIHandler.identifyAffectedBudgets(Trigger.NEW, Trigger.oldMap);        
    } 
    
    
    if (Trigger.isUpdate && Trigger.isBefore) {                              
        
        // Closed assignments for time entry when budget is rejected
        BudgetTriggerHandler budgetHandler = new BudgetTriggerHandler();
        budgetHandler.validateDocketBudgetStatus(Trigger.NEW, Trigger.oldMap);  
        budgetHandler.validateBudgetRejection(Trigger.NEW, Trigger.oldMap);
        
        // Set Forecast Template when budget is getting updated
        BudgetForecastTriggerHandler forecastHandler = new BudgetForecastTriggerHandler();
        forecastHandler.validateBudgetForecastUpdate(Trigger.NEW, Trigger.oldMap);
    }
    
    //Project Cost Update on New Budget Record
    
    if (Trigger.isInsert && Trigger.isBefore)
    {
        BudgetTriggerHandler budgetHandler = new BudgetTriggerHandler();
        budgetHandler.insertProjectCost(Trigger.NEW);
        budgetHandler.updateBudgetVersion(Trigger.NEW);
    }
    
    System.debug('----- Exited BudgetTrigger');
}