// Generic trigger on schedule object
trigger ScheduleTrigger on pse__Schedule__c (after insert, after update, before delete, after undelete) {

    ScheduleTriggerHandler scheduleHandler = new ScheduleTriggerHandler();    
    if (Trigger.isUpdate || Trigger.isUndelete)
        scheduleHandler.rollupScheduleToAssignment(Trigger.NEW, FALSE); 
    if (Trigger.isDelete)
    	scheduleHandler.rollupScheduleToAssignment(Trigger.OLD, TRUE); 
    if (Trigger.isInsert)
        scheduleHandler.roundScheduledHours(Trigger.NEW);
}