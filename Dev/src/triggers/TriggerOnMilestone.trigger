/********************************************************************************************
Author         : Ashwini B
Description    : Trigger on Milestone object.
Date           : 22/March/2017
Action         : First project contract should be saved on milestones in associated project
********************************************************************************************/
trigger TriggerOnMilestone on pse__Milestone__c (before insert, before update) {

   System.debug('----- Entered TriggerOnMilestone');
    
    if (Trigger.isInsert) {   
   		MilestoneTriggerHandler objHandler = new MilestoneTriggerHandler();
    	objHandler.insertMilestones(Trigger.NEW);
    }    
    
    if (Trigger.isUpdate) {   
   		MilestoneTriggerHandler objHandler = new MilestoneTriggerHandler();
    	objHandler.updateMilestones(Trigger.NEW, Trigger.OLDMAP);
    }
      
   System.debug('----- Exited TriggerOnMilestone');    

}