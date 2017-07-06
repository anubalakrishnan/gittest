/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Milestone object.
Date           : 19/March/2017
Action         : Approved milestones should have Project Contract record reference saved
********************************************************************************************/
public class MilestoneTriggerHandler {        
    
    // Method invoked when inserting milestones
    public void insertMilestones(List<pse__Milestone__c> milestoneList) {
        List<pse__Milestone__c> milestoneListToProcess = new List<pse__Milestone__c>();
        List<pse__Milestone__c> milestoneAccountToUpdate = new List<pse__Milestone__c>();        
        // Check if milestone status is approved
        for (pse__Milestone__c milestone : milestoneList) {
            if (milestone.pse__Status__c != null && milestone.pse__Status__c == 'Approved' && milestone.Contract_ID__c == NULL)
                milestoneListToProcess.add(milestone);
            if (String.isEmpty(milestone.Account__c))
               milestoneAccountToUpdate.add(milestone);
        }
        System.debug('----- milestoneListToProcess size : ' + milestoneListToProcess.size());
        System.debug('----- milestoneAccountToUpdate size : ' + milestoneAccountToUpdate.size());
        // Proceed if milestone process list exists, to update project contract
        if (milestoneListToProcess != null && milestoneListToProcess.size() > 0) 
           updateProjectContractReference(milestoneListToProcess);
        // Proceed if milestone process list exists, to update account
        if (milestoneAccountToUpdate != null && milestoneAccountToUpdate.size() > 0) 
           updateAccountsInMilestones(milestoneAccountToUpdate);
    }
    
    // Method invoked when updating milestones
    public void updateMilestones(List<pse__Milestone__c> milestoneList, Map<ID,pse__Milestone__c> oldMilestoneMap) {
        List<pse__Milestone__c> milestoneListToProcess = new List<pse__Milestone__c>();
        List<pse__Milestone__c> milestoneAccountToUpdate = new List<pse__Milestone__c>();   
        // Check if milestone status changed to approved
        for (pse__Milestone__c milestone : milestoneList) {
            if (milestone.pse__Status__c != oldMilestoneMap.get(milestone.ID).pse__Status__c && milestone.pse__Status__c != null &&
                milestone.pse__Status__c == 'Approved' && milestone.Contract_ID__c == NULL)
                milestoneListToProcess.add(milestone);
            if (String.isEmpty(milestone.Account__c))
               milestoneAccountToUpdate.add(milestone);
        }
        System.debug('----- milestoneListToProcess size : ' + milestoneListToProcess.size());
        // Proceed if milestone process list exists
        if (milestoneListToProcess != null && milestoneListToProcess.size() > 0) 
           updateProjectContractReference(milestoneListToProcess);
        // Proceed if milestone process list exists, to update account
        if (milestoneAccountToUpdate != null && milestoneAccountToUpdate.size() > 0) 
           updateAccountsInMilestones(milestoneAccountToUpdate);        
    }    
    
    // Method to update accounts in milestones when the field is blank
    public void updateAccountsInMilestones(List<pse__Milestone__c> milestoneAccountUpdateList) {
        
        System.debug('----- Entered updateAccountsInMilestones method');        
        
        // Proceed if milestone update list exists
        if (milestoneAccountUpdateList != null && milestoneAccountUpdateList.size() > 0) {
            
            // Get project set
            Set<String> projectSet = new Set<String>();
            for (pse__Milestone__c milestone : milestoneAccountUpdateList) {
                projectSet.add(milestone.pse__Project__c);
            }
            System.debug('----- project set : ' + projectSet);
            
            // Get account map from related project
            Map<String,String> projAccountMap = new Map<String,String>();
            for (pse__Proj__c project : [SELECT ID, Name, pse__Account__c
                                           FROM pse__Proj__c
                                          WHERE ID IN :projectSet]) {
                 projAccountMap.put(project.Id, project.pse__Account__c);                            
            } 
            System.debug('----- projAccountMap : ' + projAccountMap.size());
            
            // Set account field in milestone records
            for (pse__Milestone__c milestone : milestoneAccountUpdateList) {
                milestone.Account__c = projAccountMap.get(milestone.pse__Project__c);
            }
        }
    }

    // Method to check if milestones have reached approved status, check if project contract record exists 
    // and set the reference in milestones
    public void updateProjectContractReference(List<pse__Milestone__c> milestoneListToProcess) {                
        System.debug('----- Entered updateProjectContractReference method');        
        
        // Proceed if milestone process list exists
        if (milestoneListToProcess != null && milestoneListToProcess.size() > 0) { 
            
            // Get project set from milestones
            Set<String> projectSet = new Set<String>();
            for (pse__Milestone__c milestone : milestoneListToProcess) {
                projectSet.add(milestone.pse__Project__c);
            }
            System.debug('----- projectSet size : ' + projectSet.size());
            
            // Populate project contract map from project set
            Map<String,String> projContractMap = new Map<String,String>();
            for (pse__proj__c project : [SELECT id, name, pse__Account__c,
                                                (SELECT ID, name, Contract__c 
                                                   FROM Project_Contract__r
                                                  ORDER BY createddate ASC LIMIT 1)
                                           FROM pse__proj__c
                                          WHERE ID IN :projectSet]) {
                if (project.Project_Contract__r != null && project.Project_Contract__r.size() > 0)
                    projContractMap.put(project.ID,project.Project_Contract__r[0].Contract__c);                                    
            }
            System.debug('----- projContractMap size : ' + projContractMap.size());
            
            // process milestones
            for (pse__milestone__c milestone : milestoneListToProcess) {
                
                // Set project contract reference in milestones
                if (projContractMap.get(milestone.pse__Project__c) != NULL)
                    milestone.Contract_ID__c = projContractMap.get(milestone.pse__Project__c);                
                
            }
        }
        
        System.debug('----- Exited updateProjectContractReference method');        
    }
}