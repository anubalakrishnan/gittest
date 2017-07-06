/********************************************************************
Author         : Mihir Kumar
Description    : This trigger creates milestones when an opportunity reaches 'Closed Won' stage.
Date           : 3/March/2017
Action         : This invokes the handler class 'OpportunityTriggerHandler'
LastModified By: Praveen Kumar on 15/03/2017
********************************************************************/

trigger TriggerOnOpportunity on Opportunity (after update,before insert,before update) {
    
    System.debug('///// Opp - ' + Trigger.NEW[0]);
    
    if(Trigger.isafter && Trigger.isupdate){
        System.debug('///// After Opp - ' + Trigger.NEW[0]);
        OpportunityTriggerHandler objHandler = new OpportunityTriggerHandler();
        objHandler.createMilestones(TRIGGER.NEW, TRIGGER.OLDMAP);  //Calling 'OpportunityTriggerHandler' class
    }
    
    if(Trigger.isBefore && Trigger.isupdate){
        System.debug('///// Before Opp - ' + Trigger.NEW[0]);
        //Calling 'Opportunity_ForecastTemplate_Handler' class 
        Opportunity_ForecastTemplate_Handler TempHandler= new Opportunity_ForecastTemplate_Handler();
        TempHandler.validateOpportunityForecastUpdate(TRIGGER.NEW, TRIGGER.OLDMAP); 
        System.debug('///// BeforeUpdate Opp - ' + Trigger.NEW[0]);        
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('///// Insert Opp - ' + Trigger.NEW[0]);
        //Calling 'Opportunity_ForecastTemplate_Handler' class 
        Opportunity_ForecastTemplate_Handler TempHandler= new Opportunity_ForecastTemplate_Handler();
        TempHandler.validateOpportunityForecastInsert(TRIGGER.NEW); 
    }
}