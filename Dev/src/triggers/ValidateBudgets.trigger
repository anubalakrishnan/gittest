/********************************************************************
Author         : Ashwini B
Description    : This trigger checks for presales budget before project kick off and also
                 shares assignments with PM on update of Project record.
Date           : 7/March/2017
Action         : This invokes the handler classes 'ProjectTriggerHandler' and 
                 ProjectForecastTemplateHandler
********************************************************************/

trigger ValidateBudgets on pse__Proj__c (before insert, before update, after update) {
    /*
    System.debug('----- Entered Project trigger');

    ProjectTriggerHandler objHandler = new ProjectTriggerHandler();
    
    if (Trigger.isBefore) {
        objHandler.validateBudgets(TRIGGER.NEW);
    }

    if (Trigger.isAfter) {
       objHandler.resetResourceSharing(TRIGGER.NEW, TRIGGER.oldMap);        
    }
    
    System.debug('Exiting Project trigger');
    */
}