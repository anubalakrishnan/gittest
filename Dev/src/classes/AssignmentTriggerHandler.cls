/********************************************************************
Author   :Suman Gupta
Date     :03/Feb/2017
Action   :This is handler class of Trigger 'TriggerOnAssignment'
********************************************************************/
public class AssignmentTriggerHandler
{   
    //Author   :Suman Gupta
    //Date     :03/Feb/2017
    //Action   :this method covers the below functionality:
    //The following individuals should only be able to create assignments on the presales budget:
    //Project Manager, CBU Queue Member, Project Team Member
    //For any other budget, only the CBU Queue Owner is able to create assignments.
    public void validateAssignmentCreation(List<pse__Assignment__c> lstAssignment)
    {
        set<Id> setProjectIds = new set<Id>();
        
        List<pse__Resource_Request__c> lstResourceRequest = new List<pse__Resource_Request__c>{};
        
        //For Non-Presales Budget - if Assignment is coming from Resource Request Page
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
          (ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__assignresource?')))
        {
            Id objRequestId = ApexPages.currentPage().getParameters().get('Id');
            lstResourceRequest = [SELECT id, Client_Business_Unit_CBU__c
                                                         FROM pse__Resource_Request__c
                                                        WHERE id = :objRequestId LIMIT 1];   
                        
        }

        for(pse__Assignment__c objAssignment: lstAssignment)
        {
            //check if budget and project is not null
            If(objAssignment.Budget__c != null && objAssignment.pse__Project__c != null)
            {
                setProjectIds.add(objAssignment.pse__Project__c);
                
            }
        }
        
        if(setProjectIds.size() > 0)
        {
            Map<Id, pse__Proj__c> mapIdToProject = new Map<Id, pse__Proj__c>([Select Id, pse__Project_Manager__r.pse__Salesforce_User__c, Client_BusinessUnit_CBU__c,
                                                                                    (Select User__c from Project_Team_Roles__r) 
                                                                                    from pse__Proj__c
                                                                                    where Id in :setProjectIds]);
            //fetching budget data                                                                      
            Map<Id, pse__Budget__c> mapIdToBudget = new Map<Id, pse__Budget__c>([Select id, pse__Project__c, pse__Type__c
                                                                                            from pse__Budget__c
                                                                                            where pse__Project__c in :setProjectIds]);                                                                   
            
            // Get cbu metadata map
            Map<String,String> cbuMetaMap = new Map<String,String>();
            for (CBU_Routing_Map__mdt cbu : [SELECT Label, DeveloperName, Queue_Owner__c
                                             FROM CBU_Routing_Map__mdt]) {
                                                 System.debug(cbu.Label + ' - ' + cbu.Queue_Owner__c);                                   
                 cbuMetaMap.put(cbu.Label, cbu.Queue_Owner__c);                                 
            }              
            
            //fetching queue members
            Map<String,Id> queueMemberMap = new Map<String, Id>{};
            for (GroupMember groupMemberObj : [SELECT UserOrGroupId, Group.Name
                                    FROM GroupMember where Group.Type = 'Queue'
                                    AND UserOrGroupId = :UserInfo.getUserId()]) 
            {
                                   
                String queueCBUName = groupMemberObj.Group.Name.replace('Queue', '').trim();
                queueMemberMap.put(queueCBUName, groupMemberObj.Id); 
                
                // Additional cbu values for mapped cbu queues  
                Set<String> cbuSet = new Set<String>();
                for (String s : cbuMetaMap.values()) {
                    cbuSet.add(s);
                }                                           
                for (String mappedGroup : cbuSet) {                 
                    if (mappedGroup == queueCBUName) {
                        for (String childGroup : cbuMetaMap.keySet()) {
                            if (cbuMetaMap.get(childGroup) == mappedGroup)
                                queueMemberMap.put(childGroup, UserInfo.getUserId());     
                        }
                    }                     
                }                
            }                          
            
            //looping through all assignments
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                //checking if mapIdToProject is not null
                if(mapIdToProject != null && mapIdToProject.containsKey(objAssignment.pse__Project__c) && mapIdToProject.get(objAssignment.pse__Project__c) != null)
                {
                    pse__Proj__c objProject = mapIdToProject.get(objAssignment.pse__Project__c);
                    
                    //fetching Project Team Roles from Project
                    List<Project_Team_Roles__c> lstProjectTeamRoles = objProject.Project_Team_Roles__r;
                    
                    //set of Project Team Members
                    set<Id> setUserIds = new set<Id>();
                    
                    //check if Project Team Members are there against Project
                    if(lstProjectTeamRoles != null && lstProjectTeamRoles.size() > 0)
                    {
                        for(Project_Team_Roles__c objProjectTeamRole :lstProjectTeamRoles)
                        {
                            setUserIds.add(objProjectTeamRole.User__c);
                        }
                    }
                    //check for presales Budget
                    If(mapIdToBudget != null && mapIdToBudget.containsKey(objAssignment.Budget__c) && mapIdToBudget.get(objAssignment.Budget__c) != null)
                    {
                        if(mapIdToBudget.get(objAssignment.Budget__c).pse__Type__c == 'Presales Budget')
                        {
                            //checking if assignment is not coming from Resource Request Page - Presales Budget
                            if (lstResourceRequest.isEmpty())
                            {
                                If(UserInfo.getUserId() != objProject.pse__Project_Manager__r.pse__Salesforce_User__c && queueMemberMap.get(objProject.Client_BusinessUnit_CBU__c) == null && (!setUserIds.contains(UserInfo.getUserId())))
                                {
                                    objAssignment.addError(System.label.Assignment_Creation_Permission_Presales_Budget);
                                }
                            }
                            //checking if assignment is coming from Resource Request Page - Non Presales Budget
                            else
                            {
                                If(UserInfo.getUserId() != objProject.pse__Project_Manager__r.pse__Salesforce_User__c && queueMemberMap.get(lstResourceRequest[0].Client_Business_Unit_CBU__c) == null && (!setUserIds.contains(UserInfo.getUserId())))
                                {
                                    objAssignment.addError(System.label.Assignment_Creation_Permission_Presales_Budget);
                                }
                            }
                        }
                    
                        //check for non-presales budget
                        else
                        {
                            //checking if assignment is not coming from Resource Request Page - Non Presales Budget
                            if (lstResourceRequest.isEmpty())
                            {                                
                                if(queueMemberMap.get(objProject.Client_BusinessUnit_CBU__c) == null)
                                {
                                    objAssignment.addError(System.label.Assignment_Creation_Permission_NonPresales_Budget);
                                }
                            }
                            //checking if assignment is coming from Resource Request Page - Non Presales Budget
                            else
                            {
                                if(queueMemberMap.get(lstResourceRequest[0].Client_Business_Unit_CBU__c) == null)
                                {
                                    objAssignment.addError(System.label.Assignment_Creation_Permission_NonPresales_Budget);
                                }
                            }
                       }
                   }               
                }
            }                                                                 
        }
    }
    
    //Author   :Suman Gupta
    //Date     :09/Feb/2017
    //Action   :this method covers the below functionality:
    //Auto- Populate CBU from Project to Assignment if Resource Request is null
    //Auto - Populate Budget,Bill Rate and Sub-account based on Role on Assignment, if it comes from Budget Page
    //Auto - Populate Role and Sub-account on Self Assignment
    public void updateCBUFromProjectToAssignment(List<pse__Assignment__c> lstAssignment)
    {
        set<Id> setProjectIds = new set<Id>();
        
        //checking if assignment is not coming from Resource Request Page
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
           !(ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__assignresource?')))
        {
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                setProjectIds.add(objAssignment.pse__Project__c);
            }
        }
        
        if(setProjectIds.size() > 0)
        {
            Map<Id, pse__Proj__c> mapIdToProject = new Map<Id, pse__Proj__c>([Select Id, Client_BusinessUnit_CBU__c
                                                                                    from pse__Proj__c
                                                                                    where Id in :setProjectIds]);
            //looping through all assignments
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                //checking if mapIdToProject is not null
                if(mapIdToProject != null && mapIdToProject.containsKey(objAssignment.pse__Project__c) && mapIdToProject.get(objAssignment.pse__Project__c) != null)
                { 
                    pse__Proj__c objProject = mapIdToProject.get(objAssignment.pse__Project__c);
                    objAssignment.Client_Business_Unit_CBU__c = objProject.Client_BusinessUnit_CBU__c;
                
                }
            }                                                                          
        }
        
        //Auto - Populate Budget,Bill Rate and Sub-account based on Role on Assignment, if it comes from Budget Page
        //checking if assignment is coming from Budget Page
        List<pse__Budget__c> lstBudget = new List<pse__Budget__c>{};
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
           (ApexPages.currentPage().getUrl().containsIgnoreCase('&BudgetId')))
        {
            Id objBudgetId = ApexPages.currentPage().getParameters().get('BudgetId');
            lstBudget = [Select id, Bill_Rate__c from pse__Budget__c where id = :objBudgetId];
            
            // Populate role and sub account map
            Map<String,String> mapSubAccount = new Map<String,String>();
            for (Sub_Account_Lookup__c objSubAcc : [SELECT ID, name, Role__c
                                               FROM Sub_Account_Lookup__c]) {
                mapSubAccount.put(objSubAcc.Role__c, objSubAcc.ID);                              
            }
            //looping through all assignment
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                objAssignment.Budget__c = objBudgetId;
                objAssignment.pse__Bill_Rate__c = lstBudget[0].Bill_Rate__c;
                //get sub-account based on role
                if(mapSubAccount.containsKey(objAssignment.pse__Role__c) && mapSubAccount.get(objAssignment.pse__Role__c) != null)
                    objAssignment.Sub_Account_Lookup__c = mapSubAccount.get(objAssignment.pse__Role__c);
            }
        }
        //Auto - Populate Role and Sub-account on Self Assignment
        //checking if it is self assignment
        set<id> setContactId = new set<id>{};
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
           (ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__SelfAssignment?')))
        {
            //looping through all assignment
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                //check if resource is not null
            	if(objAssignment.pse__Resource__c != null)
                {
                    setContactId.add(objAssignment.pse__Resource__c);
                }
            }
            //checking if set is not empty
            if(!setContactId.isEmpty())
            {
                Map<Id, Contact> mapIdToContact = new Map<id, Contact>([Select id, pse__Resource_Role__c 
                                                                        from Contact where id in :setContactId]);
                
                // Populate role and sub account map
                Map<String,String> mapSubAccount = new Map<String,String>();
                for (Sub_Account_Lookup__c objSubAcc : [SELECT ID, name, Role__c
                                                   FROM Sub_Account_Lookup__c]) {
                    mapSubAccount.put(objSubAcc.Role__c, objSubAcc.ID);                              
                }
                //looping through all assignment
                for(pse__Assignment__c objAssignment: lstAssignment)
                {
                    if(mapIdToContact.containsKey(objAssignment.pse__Resource__c) && mapIdToContact.get(objAssignment.pse__Resource__c) != null)
                    {
                        Contact objContact = mapIdToContact.get(objAssignment.pse__Resource__c);
                        if(objContact.pse__Resource_Role__c != null)
                        {
                            objAssignment.pse__Role__c = objContact.pse__Resource_Role__c;
                        }
                    }
                    //get sub-account based on role
                    if(objAssignment.pse__Role__c != null && mapSubAccount.containsKey(objAssignment.pse__Role__c) && mapSubAccount.get(objAssignment.pse__Role__c) != null)
                        objAssignment.Sub_Account_Lookup__c = mapSubAccount.get(objAssignment.pse__Role__c);
                }
            }
        }
    }
    
    //Author   :Suman Gupta
    //Date     :14/Feb/2017
    //Action   :this method covers the below functionality:
    //Update total Assignment cost on Budget to ensure All assignment should be within total cost of the budget
    public void calculateTotalAssignmentCost(List<pse__Assignment__c> lstAssignment, List<pse__Assignment__c> lstOldAssignment, Map<Id, pse__Assignment__c> mapAssignment, String strTriggerContext)
    {
        System.debug('----- context : ' + strTriggerContext);
        set<Id> setBudgetIds = new set<Id>();
        set<Id> setRequestIds = new set<Id>();
        set<Id> setAssignmentId = new set<Id>();
        Set<Id> budgetsWithErrors = new Set<Id>();
        
        List<pse__Assignment__c> lstAssignmentToUpdate = new List<pse__Assignment__c>{};
        List<pse__Budget__c> lstBudgetToUpdate = new List<pse__Budget__c>{};
        
        //checking if assignmnet is coming from Resource Request page
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
          (ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__assignresource?')))
        {
            Id objRequestId = ApexPages.currentPage().getParameters().get('Id');
            setRequestIds.add(objRequestId); 
        }
        //insert & upsert scenario
        if(strTriggerContext == 'Insert_Undelete')
        {
            for(pse__Assignment__c objAssignment: lstAssignment)
            {
                if(objAssignment.Budget__c != null)
                {
                    setBudgetIds.add(objAssignment.Budget__c);
                    setAssignmentId.add(objAssignment.id);
                }
                
            }
        }
        //delete scenario
        if(strTriggerContext == 'Delete')
        {
            for(pse__Assignment__c objAssignment: lstOldAssignment)
            {
                if(objAssignment.Budget__c != null)
                {
                    setBudgetIds.add(objAssignment.Budget__c);
                }
            }
        }
        //update scenario
        if(strTriggerContext == 'Update')
        {
            for(pse__Assignment__c objAssignment: lstAssignment)
            {                
                setBudgetIds.add(objAssignment.Budget__c);
                if(objAssignment.Budget__c != null && (mapAssignment.get(objAssignment.id).Budget__c != objAssignment.Budget__c ||
                                                      objAssignment.pse__Cost_Rate_Amount__c != mapAssignment.get(objAssignment.id).pse__Cost_Rate_Amount__c ||
                                                      (objAssignment.Scheduled_Hours_Updated__c != mapAssignment.get(objAssignment.id).Scheduled_Hours_Updated__c 
                                                      && objAssignment.Scheduled_Hours_Updated__c == true)))
                {
                    setBudgetIds.add(objAssignment.Budget__c);
                    if(mapAssignment.get(objAssignment.id).Budget__c != objAssignment.Budget__c)
                        setBudgetIds.add(mapAssignment.get(objAssignment.id).Budget__c);
                }
            }
        }
        
        //list not empty
        if(!setBudgetIds.isEmpty())
        {
            //fetching budget and related assignments, resource requests
            List<pse__Budget__c> lstBudget = [Select id, Total_Assignment_Cost__c, Expected_Cost__c, (Select id, Scheduled_Hours_Updated__c, pse__Planned_Hours__c, pse__schedule__r.pse__Scheduled_Hours__c, Assignment_Cost__c, pse__Cost_Rate_Amount__c from Assignments__r), (Select id, Resource_Request_Cost__c from Resource_Requests__r where pse__Assignment__c = null AND pse__Status__c != 'Cancelled') from pse__Budget__c where id in :setBudgetIds];
            //checking list is not empty
            if(lstBudget != null && lstBudget.size() > 0)
            {
                for(pse__Budget__c objBudget :lstBudget)
                {
                    Double dbTotalCost = 0;
                    //assignments
                    if(objBudget.Assignments__r != null && objBudget.Assignments__r.size() > 0)
                    {
                        List<pse__Assignment__c> lstBudgetAssignments = objBudget.Assignments__r;
                        
                        for(pse__Assignment__c objAssignment :lstBudgetAssignments)
                        {
                            //checking assignment from resource request page and new assignment
                            if(setRequestIds.size() > 0 && setAssignmentId.contains(objAssignment.id))
                            {
                                dbTotalCost = dbTotalCost + (objAssignment.pse__Cost_Rate_Amount__c * objAssignment.pse__Planned_Hours__c);                                
                            }
                            else
                            {
                                dbTotalCost = dbTotalCost + objAssignment.Assignment_Cost__c;
                            }
                            
                            //set false to checkbox to make it open for further updates on Scheduled hours 
                            if(objAssignment.Scheduled_Hours_Updated__c == true)
                            {
                                objAssignment.Scheduled_Hours_Updated__c = false;
                                lstAssignmentToUpdate.add(objAssignment); 
                            }
                        }
                    }
                    //resource requests
                    if(objBudget.Resource_Requests__r != null && objBudget.Resource_Requests__r.size() > 0)
                    {
                        List<pse__Resource_Request__c> lstBudgetResourceReq = objBudget.Resource_Requests__r;
                        for(pse__Resource_Request__c objRequest :lstBudgetResourceReq)
                        {
                            if(!setRequestIds.contains(objRequest.id))
                            {
                                dbTotalCost = dbTotalCost + objRequest.Resource_Request_Cost__c;
                            }
                        }
                    }
                    
                    if (objBudget.Expected_Cost__c < dbTotalCost) {                        
                        budgetsWithErrors.add(objBudget.Id);
                    }                        
                }
                
                // Add errors if assignments + resource requests are going over expected cost
                List<pse__Assignment__c> assignmentsWithErrors = new List<pse__Assignment__c>();
                if (strTriggerContext == 'Update' || strTriggerContext == 'Insert_Undelete' ) {
                    assignmentsWithErrors = lstAssignment;
                } else if (strTriggerContext == 'Delete') {
                    assignmentsWithErrors = lstOldAssignment;
                }
                
                if (assignmentsWithErrors != null && assignmentsWithErrors.size() > 0) {
                    for (pse__Assignment__c assignment : assignmentsWithErrors) {
                        if (budgetsWithErrors.contains(assignment.Budget__c))
                        	assignment.addError(Label.Total_RR_Assignment_Cost_Exceeds_Budget);
                    }                    
                }  
                
                // checking if list is not empty
                if(lstAssignmentToUpdate.size() > 0)
                {
                    //update checkbox to false on assignments
                    update lstAssignmentToUpdate;
                }
            }
        }
    }
    
}