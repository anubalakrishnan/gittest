public class ProjectTriggerHandler {
    
    // Method to validate presales budget exists before project kick-off
    public void validateBudgets(List<pse__proj__c> projects) {
        
        // This block checks if the relevant changes have been done to run this method
        Boolean runMethod = FALSE;
        for (pse__proj__c proj : projects) {
            if (proj.pse__Project_Type__c != 'Global' && proj.Kick_off_Project__c == TRUE) 
                runMethod = TRUE;
        }   
        
        if (runMethod) {
        
            // Populate map for bulk run
            Map<Id,List<pse__Budget__c>> projMap = new Map<Id,List<pse__Budget__c>>();
            for (pse__Proj__c proj : [SELECT Id, 
                                             (SELECT id FROM pse__Budgets__r 
                                               WHERE pse__type__c != 'Presales Budget')  
                                        FROM pse__Proj__c
                                      WHERE id IN :projects]) {
                
                projMap.put(proj.Id, proj.pse__Budgets__r);                                  
            }
            
            System.debug('----- Project map - ' + projMap.size());
            
            // Loop through each project record
            for (pse__Proj__c proj : projects) {
                
                System.debug('----- Project record : ' + proj);
                
                if (proj.pse__Project_Type__c != 'Global' && proj.Kick_off_Project__c == TRUE) {
                    
                    // Get list of budgets
                    List<pse__Budget__c> budgets = projMap.get(proj.Id);
        
                    System.debug('----- Budgets : ' + budgets.size());
                
                    if (budgets.size() == 0) 
                        proj.addError(Label.Project_KickOff_Presales_Budget_Message);                      
                }        
                
            } 
        }
    }
    
    // This method will update Cost field on related Project Cost record for Forecasting
    public void updateRelatedProjectCost(List<pse__proj__c> projects, Map<ID,pse__proj__c> oldProjectMap) {
        // This block checks if the relevant changes have been done to run this method
        Boolean runMethod = FALSE;
        set<pse__proj__c> projList = new set<pse__proj__c>();
        for (pse__proj__c proj : projects) {
            if ((proj.pse__Stage__c != oldProjectMap.get(proj.ID).pse__Stage__c) && proj.pse__Stage__c != 'In Planning'){
                projList.add(proj);
                runMethod = TRUE;
            }   
        }
        //This Block updates the related Project Cost records
        if(runMethod){
            list<Project_Cost__c> projcostList = new list<Project_Cost__c>();
            for(Project_Cost__c projcost:  [SELECT id,Cost_From_Budget__c, Cost__c, Project__c  
                                        FROM Project_Cost__c
                                            WHERE Project__c IN: projList]){
                projcost.Cost__c = projcost.Cost_From_Budget__c;  
                projcostList.add(projcost);
            }
            if(projcostList.size()>0)
                update projcostList;
        }
    }
    
    
    // This method will reset resource sharing with PMs if project is closed or if PM changes
    public void resetResourceSharing(List<pse__proj__c> projects, Map<ID,pse__proj__c> oldProjectMap) {
        
        System.debug('----- Entered resetResourceSharing method');
        
        // This block checks if the relevant changes have been done to run this method
        Boolean runMethod = FALSE;
        for (pse__proj__c proj : projects) {
            if ((proj.pse__Project_Manager__c != oldProjectMap.get(proj.ID).pse__Project_Manager__c) || 
                (proj.pse__Stage__c != NULL && (proj.pse__Stage__c == 'Ready to Close' || proj.pse__Stage__c == 'Close Complete')))
                runMethod = TRUE;
        }
        
        if (runMethod) {
        
            // Populate project - assignment contact map
            Set<String> pmSet = new Set<String>();
            Map<String,String> pmUserMap = new Map<String,String>();
            Set<String> resourceSet = new Set<String>();
            Map<String,List<String>> pmResourceMap = new Map<String,List<String>>();
            Map<String,List<pse__Assignment__c>> assignmentMap = new Map<String,List<pse__Assignment__c>>();
            for (pse__proj__c proj : [SELECT id, pse__project_manager__c, 
                                             pse__project_manager__r.pse__salesforce_user__c,
                                             (SELECT pse__resource__c, pse__project__c
                                                FROM pse__assignments__r)
                                        FROM pse__proj__c
                                       WHERE id IN :projects]) {
                                           
                pmSet.add(proj.pse__project_manager__c);
                pmUserMap.put(proj.pse__project_manager__c, proj.pse__project_manager__r.pse__salesforce_user__c);
                assignmentMap.put(proj.ID,proj.pse__assignments__r);                           
                Set<String> contactSet = new Set<String>();                                       
                for (pse__assignment__c assign : proj.pse__assignments__r) {
                    contactSet.add(assign.pse__resource__c);
                    resourceSet.add(assign.pse__resource__c);               
                }   
                List<String> contactsToRemoveSharing = new List<String>(contactSet);                         
                pmResourceMap.put(proj.pse__project_manager__c, contactsToRemoveSharing);  
                if (oldProjectMap.get(proj.ID).pse__Project_Manager__c != null)  
                    pmResourceMap.put(oldProjectMap.get(proj.ID).pse__Project_Manager__c, contactsToRemoveSharing);
            }
            
            for (pse__proj__c project : oldProjectMap.values()) {
                pmSet.add(project.pse__project_manager__c);            
            }
            
            for (Contact contact : [SELECT id, name, pse__salesforce_user__c
                                      FROM Contact WHERE ID IN :pmSet]) {
                pmUserMap.put(contact.ID, contact.pse__salesforce_user__c);                       
            }
            
            System.debug('----- pmResourceMap : ' + pmResourceMap.size());
            System.debug('----- pmSet : ' + pmSet.size());
            System.debug('----- pmUserMap : ' + pmUserMap.size());
            System.debug('----- resourceSet : ' + resourceSet.size());
            
            // Get all other projects for which PMs are part of current PM set
            Map<String,String> allProjectMap = new Map<String,String>();
            for (pse__proj__c proj : [SELECT id, name, pse__project_manager__r.pse__salesforce_user__c,
                                             (select id, pse__resource__c
                                                from pse__assignments__r)
                                        FROM pse__proj__c
                                       WHERE pse__project_manager__c IN :pmSet
                                         AND pse__stage__c != 'Ready to Close'
                                         AND id NOT IN :projects]) {
                
                 for (pse__assignment__c assign : proj.pse__assignments__r) {
                     String key = assign.pse__Resource__c + '-' + proj.pse__project_manager__r.pse__salesforce_user__c;
                     allProjectMap.put(key, assign.pse__Resource__c);                           
                }   
            }
            
            System.debug('----- allProjectMap : ' + allProjectMap.size());
            
            // Get map of all contact share records with PM
            Map<String,ContactShare> conShareMap = new Map<String,ContactShare>();        
            for (ContactShare conShare : [SELECT id, userorgroupId, contactId
                                            FROM ContactShare
                                           WHERE userorgroupId IN :pmUserMap.values()
                                             AND contactId IN :resourceSet
                                             AND RowCause = 'Manual']) {
                 
                String key = conShare.contactId + '-' + conShare.userOrGroupId;
                conShareMap.put(key,conShare);                             
            }
            
            System.debug('Contact share lookup map - ' + conShareMap.size());
                   
            // Identify records to be deleted
            Set<ContactShare> conSharesToBeDeleted = new Set<ContactShare>();
            List<pse__assignment__c> assignments = new List<pse__assignment__c>();
            for (pse__proj__c project : projects) {
                
                String pmContact = project.pse__project_manager__c == null ? '' : project.pse__project_manager__c;
                System.debug('pmContact : ' + pmContact);
                
                String pmUser = pmUserMap.get(project.pse__project_manager__c) == null ? '' : pmUserMap.get(project.pse__project_manager__c);
                System.debug('pmUser : ' + pmUser);
                
                // proceed if project status has been set to Ready to Close or Close Complete
                if (project.pse__Stage__c == 'Ready to Close' || project.pse__Stage__c == 'Close Complete') {
                    
                    // Get list of contacts from assignments
                    List<String> contacts = pmResourceMap.get(pmContact);
                    
                    if (contacts != null && contacts.size() > 0) {                    
                       for (String contact : contacts) {                      
                           String key = contact + '-' + pmUser;  
                           
                           // Check if contact sharing should be deleted                   
                           if (conShareMap.get(key) != null && allProjectMap.get(key) == null) {
                               conSharesToBeDeleted.add(conShareMap.get(key));
                           }                    
                       }
                    }                                             
                }                   
                
                // Share contacts of all assignments if project manager has been changed after assignments created
                if ((oldProjectMap.get(project.Id).pse__Project_Manager__c == null && project.pse__Project_Manager__c != null) ||
                    (oldProjectMap.get(project.Id).pse__Project_Manager__c != null && project.pse__Project_Manager__c != null &&
                     oldProjectMap.get(project.Id).pse__Project_Manager__c != project.pse__Project_Manager__c)) {
                    
                     if (assignmentMap.get(project.ID) != null)
                        assignments.addAll(assignmentMap.get(project.ID)); 
                         
                     // Delete sharing with old project manager   
                     if (oldProjectMap.get(project.Id).pse__Project_Manager__c != null) {      
                         
                        String oldPmContact = oldProjectMap.get(project.Id).pse__Project_Manager__c;
                        System.debug('old pmContact : ' + oldPmContact);
                        
                        String oldPmUser = pmUserMap.get(oldPmContact);
                        System.debug('old pmUser : ' + oldPmUser);     
                         
                         List<String> contacts = pmResourceMap.get(oldProjectMap.get(project.Id).pse__Project_Manager__c); 
                         System.debug('old pm related contacts : ' + contacts.size());
                         
                         if (contacts != null && contacts.size() > 0) {                    
                             for (String contact : contacts) {                      
                                  String key = contact + '-' + oldPmUser;
                                  System.debug('old key : ' + key);
                           
                                  // Check if contact sharing should be deleted                   
                                  if (conShareMap.get(key) != null && allProjectMap.get(key) == null) {
                                      conSharesToBeDeleted.add(conShareMap.get(key));
                                  }                    
                             }
                         }  
                     }    
                    
                }
            }
            
            System.debug('----- conSharesToBeDeleted : ' + conSharesToBeDeleted.size());
            
            List<ContactShare> conShareDeleteList = new List<ContactShare>(conSharesToBeDeleted);
            Database.DeleteResult[] srList = Database.delete(conShareDeleteList, false); 
            
            if (assignments != null && assignments.size() > 0) {
                ValidateAssignmentsHandler objHandler = new ValidateAssignmentsHandler();
                objHandler.manageContactShareWithPM(assignments);
            }
            
            System.debug('Exited resetResourceSharing method');
        }    
    }

}