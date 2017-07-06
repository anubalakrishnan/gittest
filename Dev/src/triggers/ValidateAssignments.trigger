trigger ValidateAssignments on pse__Assignment__c (before insert, after insert, after update) {

    System.debug('----- Entered ValidateAssignments trigger');  
    
    ValidateAssignmentsHandler assignHandler = new ValidateAssignmentsHandler();
    
    // Before insert logic
    if (Trigger.isBefore) {
        assignHandler.setFieldsFromResourceRequest(Trigger.NEW);
    }
        
    // After insert and update logic
    if (Trigger.isAfter) {        
        assignHandler.manageContactShareWithPM(Trigger.NEW);                
    }   
    
    System.debug('----- Exited ValidateAssignments trigger');  
        
}