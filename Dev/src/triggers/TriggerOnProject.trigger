/**********************************************************************************
Author         : Ashwini B
Description    : 1. This trigger checks for presales budget before project kick off
                 2. Shares assignments with PM on update of Project record.
                 3. Sets Project forecast template in Project record
                 4. Validates ready to close by CST and ready to close stage in Project
                 5. Updates related Project Cost when Project reaches Closed Won stage
Date           : 23/March/2017
Action         : This invokes the handler classes 
                 1. ProjectTriggerHandler
                 2. ProjectForecastTemplateHandler 
                 3. ProjectTriggerHandler_version2
**********************************************************************************/
trigger TriggerOnProject on pse__Proj__c (before insert,before update,after update) {
    
    // Call method to check for presales budget validation
    if (Trigger.isBefore && (Trigger.isupdate || Trigger.isInsert)) {
        ProjectTriggerHandler objHandler = new ProjectTriggerHandler();
        objHandler.validateBudgets(TRIGGER.NEW);
    }
    
    // Call method to check if pm changed and update contact sharing
    if (Trigger.isAfter && Trigger.isupdate) {
        ProjectTriggerHandler objHandler = new ProjectTriggerHandler();
        objHandler.resetResourceSharing(TRIGGER.NEW, TRIGGER.oldMap); 
        
        ProjectForecastBudgetsUpdate budghandler = new ProjectForecastBudgetsUpdate(); 
        budghandler.validateForecastBudgetsUpdate(TRIGGER.NEW, TRIGGER.oldMap);
    }    
    
    if(Trigger.isBefore && Trigger.isupdate){
       //To set the Project Forecast Template on update of the Project record. 
       ProjectForecastTemplateHandler TempHandler= new ProjectForecastTemplateHandler();
       TempHandler.validateProjectTemplateUpdate(TRIGGER.NEW, TRIGGER.OLDMAP);
        
       //Call method to validates 'Ready to Close by CST' and 'Ready to Close' stage on Project 
       ProjectTriggerHandler_version2 objHandler = new ProjectTriggerHandler_version2();
       objHandler.validateReadyToCloseByCSTStage(Trigger.new, Trigger.oldmap);
       objHandler.validateReadyToCloseStage(Trigger.new, Trigger.oldmap);
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
       //To set the Project Forecast Template on insertion of the Project record.
       ProjectForecastTemplateHandler TempHandler= new ProjectForecastTemplateHandler();
       TempHandler.validateProjectTemplateInsert(TRIGGER.NEW); 
    }
    
    // Call method to update related Project Cost
    if (Trigger.isAfter && Trigger.isupdate) {
        ProjectTriggerHandler objHandler = new ProjectTriggerHandler();
        objHandler.updateRelatedProjectCost(TRIGGER.NEW, TRIGGER.oldMap); 
    }
}