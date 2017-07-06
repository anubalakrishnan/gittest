/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Misc Adjustment object.
Date           : 19/March/2017
Action         : Check if Misc adjustment has been approved and create a billing milestone.
                 Update count of milestone based on existing milestones.
********************************************************************************************/
public class MiscAdjustmentTriggerHandler {

    // Check if misc adjustments are approved while insertion and call method to insert milestones
    public void insertMiscAdjustments(List<pse__Miscellaneous_Adjustment__c> miscAdjList) {
        
        List<pse__Miscellaneous_Adjustment__c> miscAdjustListToProcess = new List<pse__Miscellaneous_Adjustment__c>();
        
        // Loop through misc adjustment records triggered
        for (pse__Miscellaneous_Adjustment__c miscAdj : miscAdjList) {
            // add to process list if status is Approved
            if (miscAdj.pse__Status__c != NULL && miscAdj.pse__Status__c == 'Approved')
                miscAdjustListToProcess.add(miscAdj);            
        }
        System.debug('----- miscAdjustListToProcess size : ' + miscAdjustListToProcess.size());
        
        // Call milestone creation method
        if (miscAdjustListToProcess != NULL && miscAdjustListToProcess.size() > 0)
            createBillingMilestone(miscAdjustListToProcess);
        
    }
    
    // Check if misc adjustments are approved while updating and call method to insert milestones
    public void updateMiscAdjustments(List<pse__Miscellaneous_Adjustment__c> miscAdjList, 
                                       Map<ID,pse__Miscellaneous_Adjustment__c> oldMiscAdjMap) {
        
        List<pse__Miscellaneous_Adjustment__c> miscAdjustListToProcess = new List<pse__Miscellaneous_Adjustment__c>();
        
        // Check if status has changed for any of the Misc Adjustment records
        for (pse__Miscellaneous_Adjustment__c miscAdj : miscAdjList) {            
             // Add to process list if status was changed to approved
             if (miscAdj.pse__Status__c != oldMiscAdjMap.get(miscAdj.ID).pse__Status__c && miscAdj.pse__Status__c != NULL &&
                     miscAdj.pse__Status__c == 'Approved')
                 miscAdjustListToProcess.add(miscAdj);                 
        }                                           
        System.debug('----- miscAdjustListToProcess size : ' + miscAdjustListToProcess.size());
        
        // Call milestone creation method
        if (miscAdjustListToProcess != NULL && miscAdjustListToProcess.size() > 0)
            createBillingMilestone(miscAdjustListToProcess);
        
    }    

    // Method to create billing milestone record from misc adjustment approval
    public void createBillingMilestone(List<pse__Miscellaneous_Adjustment__c> miscAdjList) {
          
        System.debug('----- Entered createBillingMilestone method');                                   
                                           
        // Proceed if list has any records eligible for processing
        if (miscAdjList != NULL && miscAdjList.size() > 0) {
            
            List<pse__Milestone__c> milestonesToInsert = new List<pse__Milestone__c>();
            
            // Get set of related projects
            Set<String> projectSet = new Set<String>();
            for (pse__Miscellaneous_Adjustment__c miscAdj : miscAdjList) {
                projectSet.add(miscAdj.pse__Project__c);
            }
            System.debug('----- Project set size : ' + projectSet.size());
            
            // Get map of all other milestones in the related projects
            Map<String,Integer> projMilestoneMap = new Map<String,Integer>();
            Map<String,String> projAccountMap = new Map<String,String>();
            for (pse__proj__c project : [SELECT ID, Name, pse__Account__c,
                                                (SELECT id, name 
                                                   FROM pse__milestones__r)
                                           FROM pse__proj__c
                                          WHERE ID IN :projectSet]) {
                                             
                 Integer milestoneCount = (project.pse__milestones__r == NULL) ? 0 : project.pse__milestones__r.size();
                 projMilestoneMap.put(project.ID, milestoneCount);  
                 projAccountMap.put(project.ID, project.pse__Account__c);                             
            }
            System.debug('----- projMilestoneMap size : ' + projMilestoneMap);
            System.debug('----- projAccountMap size : ' + projAccountMap);

            for (pse__Miscellaneous_Adjustment__c miscAdj : miscAdjList) {
                                
                pse__Milestone__c milestone = new pse__Milestone__c();
                
                String name = miscAdj.name;
                milestone.name = ((name.length() > 70) ? name.substring(0, 69) : name) + ' Milestone';
                
                Integer count = projMilestoneMap.get(miscAdj.pse__Project__c);
                count++;
                milestone.Milestone__c = count;
                projMilestoneMap.put(miscAdj.pse__Project__c, count);
                
                milestone.Account__c = projAccountMap.get(miscAdj.pse__Project__c);
                milestone.pse__Milestone_Amount__c = miscAdj.pse__Amount__c;
                milestone.pse__Project__c = miscAdj.pse__Project__c;
                milestone.pse__Target_Date__c = miscAdj.pse__Effective_Date__c;
                milestone.pse__Actual_Date__c = miscAdj.pse__Effective_Date__c;
                milestone.pse__Approver__c = miscAdj.CreatedById;
                milestone.pse__Approved__c = TRUE;
                milestone.pse__Status__c = 'Approved';
                milestone.pse__Include_In_Financials__c = TRUE;
                milestone.pse__Approved_for_Billing__c = TRUE;
                milestone.Province_of_Billing__c = miscAdj.Province_of_Billing__c;
                milestone.Miscellaneous_Adjustment__c = miscAdj.ID;
                
                milestonesToInsert.add(milestone);
            }
            
            if (milestonesToInsert.size() > 0)
                Database.saveResult[] srList = Database.insert(milestonesToInsert, TRUE);
        }                            
                                                       
        System.debug('----- Exited createBillingMilestone method');                                    
    }
}