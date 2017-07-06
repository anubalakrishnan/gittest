/********************************************************************
Author   :Suman Gupta
Date     :23/March/2017
Action   :This is handler class of Trigger 'TriggerOnProject'
********************************************************************/
public class ProjectTriggerHandler_version2 {
    
    //Author   :Suman Gupta
    //Date     :23/March/2017
    //Action   :this method covers the below functionality:
    //Create Validation for Project Stage Ready to Close by CST
    public void validateReadyToCloseByCSTStage(List<pse__proj__c> lstProject, Map<id, pse__proj__c> mapProject)
    {
        Map<Id, pse__proj__c> mapIdToProject = new Map<Id, pse__proj__c>{};
            
        //looping through project list
        for(pse__proj__c objProject: lstProject)
        {
            pse__proj__c objOldProject = mapProject.get(objProject.Id);

            if (objOldProject.pse__Stage__c != 'Ready to Close by CST' && objProject.pse__Stage__c == 'Ready to Close by CST')
            { 
                mapIdToProject.put(objProject.id, objProject);
            }
        }
        //checking if map is not empty
        if(mapIdToProject.size() > 0)
        {
            List<pse__proj__c> lstFilteredProject = [Select id, (Select id, pse__Status__c from pse__Assignments__r),
                                            (Select id, pse__Status__c from pse__Budgets__r),
                                            (Select id, pse__Status__c from pse__Milestones__r),
                                            (Select id, pse__Status__c from pse__Timecards__r)
                                            from pse__proj__c where id in :mapIdToProject.keyset()];
            if(lstFilteredProject != null && !lstFilteredProject.isEmpty())
            {
                for(pse__proj__c objProject: lstFilteredProject)
                {
                    Boolean isAssignmentCheck = false;
                    Boolean isTimecardCheck = false;
                    Boolean isMilestoneCheck = false;
                    Boolean isBudgetCheck = false;
                    
                    //fetching related records
                    List<pse__Assignment__c> lstAssignment = objProject.pse__Assignments__r;
                    List<pse__Timecard_Header__c> lstTimecard = objProject.pse__Timecards__r;
                    List<pse__Milestone__c> lstMilestone = objProject.pse__Milestones__r;
                    List<pse__Budget__c> lstBudget = objProject.pse__Budgets__r;
                    //checking assignments
                    if(lstAssignment != null && lstAssignment.size() > 0)
                    {
                        for(pse__Assignment__c objAssignment :lstAssignment)
                        {
                            if(objAssignment.pse__Status__c != 'Closed')
                            {
                                isAssignmentCheck = true;
                                break;
                            }
                        }
                    }
                    //checking Timecards
                    if(lstTimecard != null && lstTimecard.size() > 0)
                    {
                        for(pse__Timecard_Header__c objTimecard :lstTimecard)
                        {
                            if(objTimecard.pse__Status__c != 'Approved')
                            {
                                isTimecardCheck = true;
                                break;
                            }
                        }
                    }
                    //checking Budgets
                    if(lstBudget != null && lstBudget.size() > 0)
                    {
                        for(pse__Budget__c objBudget :lstBudget)
                        {
                            if(objBudget.pse__Status__c != 'Closed')
                            {
                                isBudgetCheck = true;
                                break;
                            }
                        }
                    }
                    //checking Milestones
                    if(lstMilestone != null && lstMilestone.size() > 0)
                    {
                        for(pse__Milestone__c objMilestone :lstMilestone)
                        {
                            if(objMilestone.pse__Status__c != 'Approved' && objMilestone.pse__Status__c != 'Canceled')
                            {
                                isMilestoneCheck = true;
                                break;
                            }
                        }
                    }
                    //add error
                    if(isAssignmentCheck == true || isTimecardCheck == true || isBudgetCheck == true || isMilestoneCheck == true)
                    {
                        if(mapIdToProject.containsKey(objProject.id) && mapIdToProject.get(objProject.id) != null)
                        {
                            pse__proj__c objMainProject = mapIdToProject.get(objProject.id);
                            objMainProject.adderror(System.label.Project_Ready_to_Close_by_CST_Validation); 
                        }
                        
                    }
                }
            }
        }
    } 
    
    //Author   :Suman Gupta
    //Date     :27/March/2017
    //Action   :this method covers the below functionality:
    //Create Validation for Project Stage Ready to Close
    public void validateReadyToCloseStage(List<pse__proj__c> lstProject, Map<id, pse__proj__c> mapProject)
    {
        Map<Id, pse__proj__c> mapIdToProject = new Map<Id, pse__proj__c>{};
            
        //looping through project list
        for(pse__proj__c objProject: lstProject)
        {
            pse__proj__c objOldProject = mapProject.get(objProject.Id);

            if (objOldProject.pse__Stage__c != 'Ready to Close' && objProject.pse__Stage__c == 'Ready to Close')
            { 
                mapIdToProject.put(objProject.id, objProject);
            }
        }
        //checking if map is not empty
        if(mapIdToProject.size() > 0)
        {
            List<pse__proj__c> lstFilteredProject = [Select id, 
                                            (Select id, pse__Billed__c, pse__Invoiced__c from pse__Milestones__r 
                                             where pse__Status__c = 'Approved')
                                            from pse__proj__c where id in :mapIdToProject.keyset()];
            //checking if list is not empty
            if(lstFilteredProject != null && !lstFilteredProject.isEmpty())
            {
                for(pse__proj__c objProject: lstFilteredProject)
                {
                    //fetching related milestones
                    List<pse__Milestone__c> lstMilestone = objProject.pse__Milestones__r;
                    
                    //checking Milestone list is not empty
                    if(lstMilestone != null && lstMilestone.size() > 0)
                    {
                        for(pse__Milestone__c objMilestone :lstMilestone)
                        {
                            //check for billed and invoiced checkboxes
                            if(objMilestone.pse__Billed__c == false || objMilestone.pse__Invoiced__c == false) 
                            {
                                //add error
                                if(mapIdToProject.containsKey(objProject.id) && mapIdToProject.get(objProject.id) != null)
                                {
                                    pse__proj__c objMainProject = mapIdToProject.get(objProject.id);
                                    objMainProject.adderror(System.label.Project_ReadyToClose_Validation);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}