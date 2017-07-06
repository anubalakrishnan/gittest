/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Project Contract object.
Date           : 19/March/2017
Action         : First project contract should be saved on milestones in associated project
********************************************************************************************/
public class ProjectContractTriggerHandler {

    // Method to check if project contract is the first record in the project
    // and update the reference in project milestones
    public void updateContractInMilestones(List<Project_Contract__c> projContractList) {
        System.debug('----- Entered updateContractInMilestones method');
        List<Project_Contract__c> projContractListToProcess = new List<Project_Contract__c>();       
        
        // Get set of related projects
        Set<String> projectSet = new Set<String>();
        for (Project_Contract__c projCon : projContractList) {            
            projectSet.add(projCon.Project__c);            
        }
        System.debug('----- projectSet size : ' + projectSet.size());
        
        // Get project and contract map for the project set
        Map<String,List<Project_Contract__c>> projContractMap = new Map<String,List<Project_Contract__c>>();
        Map<String,List<pse__Milestone__c>> projMilestoneMap = new Map<String,List<pse__Milestone__c>>();        
        for (pse__proj__c project : [SELECT ID, name, 
                                            (SELECT ID, name, Contract__c FROM Project_Contract__r
                                              ORDER BY createddate ASC),
                                            (SELECT ID, name FROM pse__Milestones__r
                                              WHERE pse__status__c = 'Approved')
                                       FROM pse__proj__c
                                      WHERE ID IN :projectSet]) {
            projContractMap.put(project.ID,project.Project_Contract__r);  
            projMilestoneMap.put(project.ID,project.pse__Milestones__r);
        }
        System.debug('----- projContractMap size : ' + projContractMap.size() + ' - ' + projContractMap);
        System.debug('----- projMilestoneMap size : ' + projMilestoneMap.size() + ' - ' + projMilestoneMap);
                
        // Check which contracts are first records for the project and 
        // if approved milestones exist for the project
        for (Project_Contract__c projCon : projContractList) {
            if (projContractMap.get(projCon.Project__c) != null && projContractMap.get(projCon.Project__c).size() == 1 && 
                   projMilestoneMap.get(projCon.Project__c) != null && projMilestoneMap.get(projCon.Project__c).size() > 0)                     
                projContractListToProcess.add(projCon);                    
        }
        System.debug('----- projContractListToProcess size : ' + projContractListToProcess.size());
        
        // Proceed if there are any valid project contract records to process
        if (projContractListToProcess != null && projContractListToProcess.size() > 0) {  
            
            List<pse__Milestone__c> milestonesToUpdate = new List<pse__Milestone__c>();
            Map<String,String> projStatusMap = new Map<String,String>();
            
            for (Project_Contract__c projCon : projContractListToProcess) {
                System.debug('----- record being processed : ' + projCon);

                // Check if the project is already processed in this batch
                if (projStatusMap.get(projCon.Project__c) == null) {
                
                    for(pse__Milestone__c milestone : projMilestoneMap.get(projCon.Project__c)) {
                        
                        // Set project contract reference in milestones
                        milestone.Contract_ID__c = projContractMap.get(projCon.Project__c)[0].Contract__c;                        
                        milestonesToUpdate.add(milestone);
                    }
                    
                    // Set project as processed, to skip next project contract record for same project
                    projStatusMap.put(projCon.Project__c,projCon.Project__c);
                }
            }  
            
            System.debug('----- Milestones to update : ' + milestonesToUpdate.size());
            if (milestonesToUpdate != null && milestonesToUpdate.size() > 0) 
                update milestonesToUpdate;
        } 
        System.debug('----- Exited updateContractInMilestones method');
    }
}