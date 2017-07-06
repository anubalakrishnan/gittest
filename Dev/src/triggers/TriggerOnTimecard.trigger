/********************************************************************
Author   :Suman Gupta
Date     :28/Feb/2017
Action   :This invokes the handler class 'TimecardTriggerHandler' 
********************************************************************/
trigger TriggerOnTimecard on pse__Timecard_Header__c(before update, after insert, after update, after delete, after undelete) {

    TimecardTriggerHandler objHandler = new TimecardTriggerHandler();
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        objHandler.validateRejectionComments(Trigger.New, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete))
    {
        objHandler.calculateTotalSubmittedHours(Trigger.New, null, null, 'Insert_Undelete');
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        objHandler.calculateTotalSubmittedHours(Trigger.New, Trigger.old, Trigger.oldMap, 'Update');
        objHandler.timecardRejectionNotification(Trigger.New, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete)
    {
        objHandler.calculateTotalSubmittedHours(null, Trigger.old, Trigger.oldMap, 'Delete');
    } 
}