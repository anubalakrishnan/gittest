// This handler class comprises all role validations to update fields on resource requests
public class ResourceRequestValidationsHandler {

    // This method checks if user has privileges to update resource requests
    public void validateResourceRequestUpdates(List<pse__Resource_Request__c> requestList, 
                                                Map<ID,pse__Resource_Request__c> oldRequestMap) {
        
        System.debug('----- Entered validateResourceRequestUpdates method');
                                                    
        // Get cbu metadata map
        Map<String,String> cbuMetaMap = new Map<String,String>();
        for (CBU_Routing_Map__mdt cbu : [SELECT Label, DeveloperName, Queue_Owner__c
                                           FROM CBU_Routing_Map__mdt]) {
            System.debug(cbu.Label + ' - ' + cbu.Queue_Owner__c);                                   
            cbuMetaMap.put(cbu.Label, cbu.Queue_Owner__c);                                 
        } 
        System.debug(cbuMetaMap.size());                                            
                                                    
        // Get map of all CBU queues
        Map<String,Id> cbuQueueMap = new Map<String,Id>();                                                                                               
        for (queuesobject queue : [SELECT id, queue.name, queueId 
                                     FROM queuesobject 
                                    WHERE queue.type = 'Queue' 
                                      AND SobjectType = 'pse__Resource_Request__c']) {
             String value = queue.queue.name.replace('Queue', '').trim();
             System.debug('----- map value : ' + value);                             
             cbuQueueMap.put(value,queue.queueId);                    
        } 
        
        System.debug('----- cbuQueueMap size : ' + cbuQueueMap.size());
                                                            
        // Check logged in user is part of which CBU queue 
        Map<String,String> cbuMemberMap = new Map<String,String>();
        Set<String> cbuSet = new Set<String>();
        for (GroupMember grpMem : [SELECT UserOrGroupId, Group.Name
                                     FROM GroupMember where Group.Type = 'Queue'
                                      AND GroupId IN :cbuQueueMap.values()
                                      AND UserOrGroupId = :UserInfo.getUserId()]) {
             
             //isCBUQueueMember = TRUE;
             //break;
             String key = grpMem.Group.Name.replace('Queue','').trim() + '-' + grpMem.UserOrGroupId; 
             cbuMemberMap.put(key, grpMem.Id); 
             cbuSet.add(grpMem.Group.Name.replace('Queue','').trim());
             // Additional cbu values for mapped cbu queues                             
             for (String s : cbuMetaMap.keySet()) {                 
                 if (cbuMetaMap.get(s) == grpMem.Group.Name.replace('Queue','').trim()) {
                     System.debug('----- Match found, s : ' + cbuMetaMap.get(s));
                     cbuSet.add(s);
                 }                     
             }
        }    
        
        System.debug('----- cbuSet size : ' + cbuSet.size());
        System.debug('----- cbuMemberMap size : ' + cbuMemberMap);
            
        List<Id> projectList = new List<Id>();        
        for (pse__Resource_Request__c request : requestList) {        
            projectList.add(request.pse__Project__c); 
        }    
        System.debug('----- projectList size : ' + projectList.size());    
    
        // Populate contacts in CBU
        Set<String> contactSet = new Set<String>();
        for (Contact contact : [SELECT ID, Client_Business_Unit_CBU__c
                                  FROM contact
                                 WHERE Client_Business_Unit_CBU__c IN :cbuSet]) {
             contactSet.add(contact.ID);                                   
        }
        
        System.debug('Contact Set : ' + contactSet.size());
        
        Map<Id,Id> pmMap = new Map<Id,Id>();    
        for (pse__proj__c project : [SELECT id, name, pse__Project_Manager__r.pse__Salesforce_User__c
                                       FROM pse__proj__c 
                                      WHERE id IN :projectList]) {
             pmMap.put(project.Id, project.pse__Project_Manager__r.pse__Salesforce_User__c);                            
        } 
        
        System.debug('----- pmMap size : ' + pmMap.size());
        
        // Populate role and sub account map
        Map<String,String> subAccountMap = new Map<String,String>();
        for (Sub_Account_Lookup__c subAcc : [SELECT ID, name, Role__c
                                               FROM Sub_Account_Lookup__c]) {
            subAccountMap.put(subAcc.Role__c, subAcc.ID);                              
        }
        System.debug('----- subAccountMap size : ' + subAccountMap.size());  
        
        for (pse__Resource_Request__c request : requestList) {
            
            System.debug('----- request : ' + request);
                    
            // Set SubAccount value
            if (request.pse__Resource_Role__c != NULL) {
                if (subAccountMap.get(request.pse__Resource_Role__c) != NULL) {
                    request.Sub_Account_Lookup__c = subAccountMap.get(request.pse__Resource_Role__c);                
                }         
            }
            
            // Check if CBU value has been changed by queue member
            if (request.Client_Business_Unit_CBU__c != null) {            
                
                String oldCbu = '';
                if (Trigger.isUpdate) {
                    oldCbu = (oldRequestMap.get(request.ID).Client_Business_Unit_CBU__c == null) ? '' : oldRequestMap.get(request.ID).Client_Business_Unit_CBU__c;        
                System.debug('Old CBU : ' + oldCbu);
                }
                    
                String newCbu = request.Client_Business_Unit_CBU__c == null ? '' : request.Client_Business_Unit_CBU__c;        
                System.debug('New CBU : ' + newCbu);                
                
                // Check if logged in user has permission to change the CBU
                String oldMetaKey = (cbuMetaMap.get(oldCbu) == null) ? '' : cbuMetaMap.get(oldCbu);
                String oldKey = ((oldMetaKey == '') ? oldCbu : oldMetaKey) + '-' + UserInfo.getUserId();
                //String oldKey = oldCbu + '-' + UserInfo.getUserId();
                System.debug('----- oldKey : ' + oldKey);
                    
                String newMetaKey = (cbuMetaMap.get(newCbu) == null) ? '' : cbuMetaMap.get(newCbu);
                String newKey = ((newMetaKey == '') ? newCbu : newMetaKey) + '-' + UserInfo.getUserId();                
                //String newKey = newCbu + '-' + UserInfo.getUserId();
                System.debug('----- newKey : ' + newKey);                
                
                Boolean isOldCBUQueueMember = false;                           
                if (cbuMemberMap.get(oldKey) != null)
                    isOldCBUQueueMember = true;
                
                System.debug('----- isOldCBUQueueMember : ' + isOldCBUQueueMember);
                   
                Boolean isCurrentCBUQueueMember = false;    
                if (cbuMemberMap.get(newKey) != null)
                    isCurrentCBUQueueMember = true;  
                
                System.debug('----- isCurrentCBUQueueMember : ' + isCurrentCBUQueueMember);
                
                Boolean isGlobalCBUQueueMember = false;
                String globalKey = 'Global-' + UserInfo.getUserId();
                if(cbuMemberMap.get(globalKey) != null)
                   isGlobalCBUQueueMember = TRUE;
                
                System.debug('----- isGlobalCBUQueueMember : ' + isGlobalCBUQueueMember);
                
                if (Trigger.isUpdate && !isOldCBUQueueMember && 
                    oldRequestMap.get(request.Id).Client_Business_Unit_CBU__c != request.Client_Business_Unit_CBU__c) {
    
                    request.addError(Label.Resource_Request_CBU_Change_Message + ' :: ' + oldCBU);                                                         
                }
                
                // Check that only a CBU queue member is updating the status to Not Fulfilled
                if (request.pse__Status__c == 'Not Fulfilled' && !isCurrentCBUQueueMember) 
                    request.addError(Label.Resource_Request_Not_Fulfilled_Message);
                
                // Check that only PM or current queue member is updating status to Cancelled
                if (request.pse__Status__c == 'Cancelled' && pmMap.get(request.pse__Project__c) != UserInfo.getUserId() && !isCurrentCBUQueueMember)
                    request.addError(Label.Resource_Request_Cancelled_Message);
                
                // release resource if status is cancelled
                if (request.pse__Status__c == 'Cancelled' && (pmMap.get(request.pse__Project__c) == UserInfo.getUserId() || isCurrentCBUQueueMember)) {
                    request.pse__Resource_Held__c = FALSE;
                    request.pse__Preferred_Schedule__c = NULL;
                    request.pse__Staffer_Resource__c = NULL;
                }
                                    
                // Check that if assignment is mapped to request, status cannot be set to Not Fulfilled
                if (request.pse__Status__c == 'Not Fulfilled' && request.pse__Resource_Held__c && request.pse__Staffer_Resource__c != null)
                    request.addError(Label.Resource_Request_Soft_Book_Message);                
                                
                // Check that if a resource is soft-booked, status cannot be set to Not Fulfilled
                if (request.pse__Status__c == 'Not Fulfilled' && request.pse__Assignment__c != null)
                    request.addError(Label.Resource_Request_Assignment_Message);
                                                
                // Check that only queue member can soft book a resource of that CBU
                if (request.pse__Resource_Held__c && request.pse__Staffer_Resource__c != null) {  
                    if (isGlobalCBUQueueMember && newCBU == 'Global') {
                        System.debug('Global queue member and RR is in Global CBU. Allow soft-booking.');
                    } else if (!isCurrentCBUQueueMember || (isCurrentCBUQueueMember && !contactSet.contains(request.pse__Staffer_Resource__c))) {            
                        request.addError(Label.Resource_Request_Soft_Book_Insufficient_Privileges_Message);
                    }
                }                 
                
                // Check that only queue member can assign a resource
                if (request.pse__Assignment__c != null) {
                   if (isGlobalCBUQueueMember && newCBU == 'Global') {
                        System.debug('Global queue member and RR is in Global CBU. Allow assignment.');
                    } else if (!isCurrentCBUQueueMember || (isCurrentCBUQueueMember && !contactSet.contains(request.pse__Staffer_Resource__c))) { 
                       request.addError(Label.Resource_Request_Assignment_Insufficient_Privileges_Message); 
                   }
                }                          
                            
                // Get queue id based on cbu value
                if (cbuQueueMap.get(newCbu) != null || cbuQueueMap.get(cbuMetaMap.get(newCbu)) != null) {
                    
                    Id qId = (cbuQueueMap.get(newCbu) == null) ? cbuQueueMap.get(cbuMetaMap.get(newCbu)) : cbuQueueMap.get(newCbu);
                    System.debug('Queue ID : ' + qId);
                    
                    // Set relevant queue Id as owner of the request
                    request.ownerId = qId;
                    
                } else {
                    
                    request.ownerId = UserInfo.getUserId();
                    
                }
            }       
        }                                                    
        System.debug('----- Exited validateResourceRequestUpdates method');
    }
}