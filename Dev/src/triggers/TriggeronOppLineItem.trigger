trigger TriggeronOppLineItem on OpportunityLineItem (before update, before delete) {       

    if(Trigger.isBefore && Trigger.isDelete){
        OpplineItemTriggerHandler OliHandler = new OpplineItemTriggerHandler();
        OliHandler.updateopplinebudget(Trigger.Old);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        OliUpdateHandler objHandler = new OliUpdateHandler();
        objHandler.budgetCreateUpdate(Trigger.NEW);
    }
        
}