/********************************************************************************************
Author         : Ashwini B
Description    : Generic trigger on Misc Adjustment object.
Date           : 19/March/2017
Action         : This invokes the handler class 'MiscAdjustmentTriggerHandler' which checks 
                 if a Misc Adjustment record is approved and creates a billing milestone
			   : This invokes the handler class 'MiscAdjustmentTriggerHandler_version2' which checks 
                 for mandatory comments at the time of rejection of Misc. Adjustment
********************************************************************************************/
trigger TriggerOnMiscAdjustment on pse__Miscellaneous_Adjustment__c (after insert, before update, after update) {
 
    System.debug('----- Entered TriggerOnMiscAdjustment');
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
    	MiscAdjustmentTriggerHandler objHandler = new MiscAdjustmentTriggerHandler();
    	objHandler.insertMiscAdjustments(Trigger.NEW);
    }    
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
    	MiscAdjustmentTriggerHandler objHandler = new MiscAdjustmentTriggerHandler();
    	objHandler.updateMiscAdjustments(Trigger.NEW, Trigger.OLDMAP);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        MiscAdjustmentTriggerHandler_version2 objHandler = new MiscAdjustmentTriggerHandler_version2();
        objHandler.validateRejectionComments(Trigger.New, Trigger.oldMap);
    }
    
    System.debug('----- Exited TriggerOnMiscAdjustment');
    
}