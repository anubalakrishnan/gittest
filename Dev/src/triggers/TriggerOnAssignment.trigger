/********************************************************************
Author   :Suman Gupta
Date     :03/Feb/2017
Action   :This invokes the handler class 'AssignmentTriggerHandler'
********************************************************************/
trigger TriggerOnAssignment on pse__Assignment__c (before insert, after insert, after update, after delete, after undelete) {

    AssignmentTriggerHandler objHandler = new AssignmentTriggerHandler();
    if(Trigger.isBefore && Trigger.isInsert)
    {
        objHandler.updateCBUFromProjectToAssignment(Trigger.New);
        objHandler.validateAssignmentCreation(Trigger.New);
        
        
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete))
    {
        objHandler.calculateTotalAssignmentCost(Trigger.New, null, null, 'Insert_Undelete');
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        objHandler.calculateTotalAssignmentCost(Trigger.New, Trigger.old, Trigger.oldMap, 'Update');
    }
    
    if(Trigger.isAfter && Trigger.isDelete)
    {
        objHandler.calculateTotalAssignmentCost(null, Trigger.old, Trigger.oldMap, 'Delete');
    }

}