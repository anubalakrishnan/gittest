/********************************************************************
Author   :Suman Gupta
Date     :24/March/2017
Action   :This is handler class of Trigger 'TriggerOnMiscAdjustment'
********************************************************************/
public class MiscAdjustmentTriggerHandler_version2
{   
    //Author   :Suman Gupta
    //Date     :24/March/2017
    //Action   :this method covers the below functionality:
    //Comments should be mandatory at the time of Misc. Adjustment Rejection
    public void validateRejectionComments(List<pse__Miscellaneous_Adjustment__c> lstMiscAdjustment, Map<id, pse__Miscellaneous_Adjustment__c> mapMiscAdjustment)
    {
        Map<Id, pse__Miscellaneous_Adjustment__c> mapRejectedStatements = new Map<Id, pse__Miscellaneous_Adjustment__c>{};
        
        //looping through Misc. Adjustment list
        for(pse__Miscellaneous_Adjustment__c objMiscAdjustment: lstMiscAdjustment)
        {
            pse__Miscellaneous_Adjustment__c objOldMiscAdjustment = mapMiscAdjustment.get(objMiscAdjustment.Id);

            if (objOldMiscAdjustment.pse__Status__c != 'Rejected' && objMiscAdjustment.pse__Status__c == 'Rejected')
            { 
                mapRejectedStatements.put(objMiscAdjustment.Id, objMiscAdjustment);
            }
        }
        //getting approval step information
        for (ProcessInstance objProcessInstance : [SELECT TargetObjectId, 
                              (  
                                 SELECT Id, StepStatus, Comments 
                                 FROM Steps
                                 WHERE StepStatus = 'Rejected'
                                 ORDER BY CreatedDate DESC
                                 LIMIT 1 
                              )
                               FROM ProcessInstance
                               WHERE TargetObjectId In 
                                 :mapRejectedStatements.keySet()
                               ORDER BY CreatedDate DESC
                              ])
        {   
            //if comments is null, then add the error  
            if ((objProcessInstance.Steps[0].Comments == null || objProcessInstance.Steps[0].Comments.trim().length() == 0))
            {
                mapRejectedStatements.get(objProcessInstance.TargetObjectId).addError(System.label.Misc_Adjustment_Mandatory_Rejection_Comments);
            }
        }
    }
}