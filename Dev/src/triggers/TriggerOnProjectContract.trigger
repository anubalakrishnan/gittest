/********************************************************************************************
Author         : Ashwini B
Description    : Trigger on Project Contract object.
Date           : 22/March/2017
Action         : First project contract should be saved on milestones in associated project
********************************************************************************************/
trigger TriggerOnProjectContract on Project_Contract__c (after insert) {
    
    System.debug('----- Entered TriggerOnProjectContract');
    
    ProjectContractTriggerHandler objHandler = new ProjectContractTriggerHandler();
    objHandler.updateContractInMilestones(Trigger.NEW);
    
    System.debug('----- Exited TriggerOnProjectContract');

}