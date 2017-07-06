/********************************************************************
Author   :Suman Gupta
Date     :15/Feb/2017
Action   :This invokes the handler class 'ResourceRequestTriggerHandler'
********************************************************************/
trigger TriggerOnResourceRequest on pse__Resource_Request__c(before insert, after insert, after update, after delete, after undelete) {

    ResourceRequestTriggerHandler objHandler = new ResourceRequestTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        objHandler.updateCostRateOnResourceRequest(Trigger.New);
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete))
    {
        objHandler.calculateTotalResourceReqCost(Trigger.New, null, null, 'Insert_Undelete');
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        objHandler.calculateTotalResourceReqCost(Trigger.New, Trigger.old, Trigger.oldMap, 'Update');
    }
    
    if(Trigger.isAfter && Trigger.isDelete)
    {
        objHandler.calculateTotalResourceReqCost(null, Trigger.old, Trigger.oldMap, 'Delete');
    }

}