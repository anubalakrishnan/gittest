/********************************************************************
Author   :Suman Gupta
Date     :15/Feb/2017
Action   :This is handler class of Trigger 'ResourceRequestTrigger'
********************************************************************/
public class ResourceRequestTriggerHandler
{   
    //Author   :Suman Gupta
    //Date     :15/Feb/2017
    //Action   :this method covers the below functionality:
    //Update Cost Rate Amount on Resource Request
    public void updateCostRateOnResourceRequest(List<pse__Resource_Request__c> lstResourceRequest)
    {
        Map<String, decimal> mapCostRate = new Map<String, decimal>{};
        
        //fetching cost rates
        List<Cost_Rate_Lookup__c>  lstCostRate = [Select id, Cost_Rate__c, Region__c, Role__c from Cost_Rate_Lookup__c];
        
        if(lstCostRate != null && lstCostRate.size() > 0)
        {
            for(Cost_Rate_Lookup__c objCostRate :lstCostRate)
            {
                String strRoleRegion = objCostRate.Role__c + objCostRate.Region__c;
                mapCostRate.put(strRoleRegion, objCostRate.Cost_Rate__c);
            }
        }
        //looping through all resource requests
        for(pse__Resource_Request__c objResourceRequest: lstResourceRequest)
        {
            If(objResourceRequest.pse__Resource_Role__c != null && objResourceRequest.pse__Region__c != null)
            {
                String strRoleRegion = objResourceRequest.pse__Resource_Role__c + objResourceRequest.pse__Region__c;
                if(mapCostRate.containskey(strRoleRegion) && mapCostRate.get(strRoleRegion) != null)
                {
                    objResourceRequest.Cost_Rate_Amount__c = mapCostRate.get(strRoleRegion);
                }
            }
        }
    }
    
    //Author   :Suman Gupta
    //Date     :15/Feb/2017
    //Action   :this method covers the below functionality:
    //Update total Resource Request cost on Budget to ensure All resource request should be within total cost of the budget
    public void calculateTotalResourceReqCost(List<pse__Resource_Request__c> lstResourceRequest, List<pse__Resource_Request__c> lstOldResourceRequest, Map<Id, pse__Resource_Request__c> mapResourceRequest, String strTriggerContext)
    { 
        set<Id> setBudgetIds = new set<Id>();
        List<pse__Budget__c> lstBudgetToUpdate = new List<pse__Budget__c>{};
        Set<Id> budgetsWithErrors = new Set<Id>();
        
        //insert & upsert scenario
        if(strTriggerContext == 'Insert_Undelete')
        {
            for(pse__Resource_Request__c objResourceRequest: lstResourceRequest)
            {
                if(objResourceRequest.Budget__c != null && objResourceRequest.pse__Assignment__c == null && objResourceRequest.pse__Status__c != 'Cancelled')
                {
                    setBudgetIds.add(objResourceRequest.Budget__c);
                }
            }
        }
        //delete scenario
        if(strTriggerContext == 'Delete')
        {
            for(pse__Resource_Request__c objResourceRequest: lstOldResourceRequest)
            {
                if(objResourceRequest.Budget__c != null && objResourceRequest.pse__Assignment__c == null && objResourceRequest.pse__Status__c != 'Cancelled')
                {
                    setBudgetIds.add(objResourceRequest.Budget__c);
                }
            }
        }
        //update scenario
        if(strTriggerContext == 'Update')
        {
            for(pse__Resource_Request__c objResourceRequest: lstResourceRequest)
            {
                if(objResourceRequest.Budget__c != null && objResourceRequest.pse__Assignment__c == null && (mapResourceRequest.get(objResourceRequest.id).Budget__c != objResourceRequest.Budget__c ||
                                                      objResourceRequest.Cost_Rate_Amount__c != mapResourceRequest.get(objResourceRequest.id).Cost_Rate_Amount__c ||
                                                      objResourceRequest.pse__SOW_Hours__c != mapResourceRequest.get(objResourceRequest.id).pse__SOW_Hours__c || 
                                                      mapResourceRequest.get(objResourceRequest.id).pse__Assignment__c != objResourceRequest.pse__Assignment__c ||
                                                      mapResourceRequest.get(objResourceRequest.id).pse__Status__c != objResourceRequest.pse__Status__c ))
                {
                    setBudgetIds.add(objResourceRequest.Budget__c);
                    if(mapResourceRequest.get(objResourceRequest.id).Budget__c != objResourceRequest.Budget__c)
                        setBudgetIds.add(mapResourceRequest.get(objResourceRequest.id).Budget__c);
                }
            }
        }
        
        //list not empty
        if(!setBudgetIds.isEmpty())
        {
            //fetching budget and related assignments,resource requests
            List<pse__Budget__c> lstBudget = [Select id, Total_Assignment_Cost__c, Expected_Cost__c, (Select id, Resource_Request_Cost__c from Resource_Requests__r where pse__Assignment__c = null AND pse__Status__c != 'Cancelled'), (Select id, Assignment_Cost__c from Assignments__r) from pse__Budget__c where id in :setBudgetIds];
            //checking list is not empty
            if(lstBudget != null && lstBudget.size() > 0)
            {
                for(pse__Budget__c objBudget :lstBudget)
                {
                    Double dbTotalCost = 0;
                    //resource requests
                    if(objBudget.Resource_Requests__r != null && objBudget.Resource_Requests__r.size() > 0)
                    {
                        List<pse__Resource_Request__c> lstBudgetResourceReq = objBudget.Resource_Requests__r;
                        
                        for(pse__Resource_Request__c objRequest :lstBudgetResourceReq)
                        {
                            dbTotalCost = dbTotalCost + objRequest.Resource_Request_Cost__c;
                        }
                    }
                    //assignments
                    if(objBudget.Assignments__r != null && objBudget.Assignments__r.size() > 0)
                    {
                        List<pse__Assignment__c> lstBudgetAssignments = objBudget.Assignments__r;
                        
                        for(pse__Assignment__c objAssignment :lstBudgetAssignments)
                        {
                            dbTotalCost = dbTotalCost + objAssignment.Assignment_Cost__c;
                        }
                    }
                    
                    if (objBudget.Expected_Cost__c < dbTotalCost) {                        
                        budgetsWithErrors.add(objBudget.Id);
                    } 
                }

                // Add errors if assignments + resource requests are going over expected cost
                List<pse__Resource_Request__c> requestsWithErrors = new List<pse__Resource_Request__c>();
                if (strTriggerContext == 'Update' || strTriggerContext == 'Insert_Undelete' ) {
                    requestsWithErrors = lstResourceRequest;
                } else if (strTriggerContext == 'Delete') {
                    requestsWithErrors = lstOldResourceRequest;
                }
                
                if (requestsWithErrors != null && requestsWithErrors.size() > 0) {
                    for (pse__Resource_Request__c request : requestsWithErrors) {
                        if (budgetsWithErrors.contains(request.Budget__c))
                        	request.addError(Label.Total_RR_Assignment_Cost_Exceeds_Budget);
                    }                    
                }                
            }
        }
    }
    
}