/********************************************************************
Author   : 	Praveen Kumar
Date     : 	31/March/2017
********************************************************************/
global class UpdateForecastTemplateScheduler implements Schedulable{
    
global void execute(SchedulableContext sc) {

        UpdateProjectForecastTemplateBatch projbatch = new UpdateProjectForecastTemplateBatch();
        ID batchprocessid1 = Database.executeBatch(projbatch,200);           
    
    
        UpdateBudgetForecastTemplateBatch budgbatch = new UpdateBudgetForecastTemplateBatch();
        ID batchprocessid2 = Database.executeBatch(budgbatch,200); 
    }
}