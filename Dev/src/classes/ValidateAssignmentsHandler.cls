public class ValidateAssignmentsHandler {
    
    public void setFieldsFromResourceRequest(List<pse__Assignment__c> assignments) {
        
        for (pse__Assignment__c assign : assignments) {
            
            System.debug('----- Assignment record : ' + assign); 
            
            // Check if assignment is getting created from Resource Request
            if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
                ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__assignresource?')) {                                
                    
                // Get ID from page url
                Id reqId = ApexPages.currentPage().getParameters().get('Id');
                    
                System.debug('----- Resource Request Id : ' + reqId);
                    
                // Get linked resource request
                List<pse__Resource_Request__c> requests = [SELECT id, Budget__c, pse__Resource_Role__c, pse__Requested_Bill_Rate__c,
                                                                  pse__Staffer_Resource__r.pse__Default_Cost_Rate__c, Budget__r.Practice__c, 
                                                                  pse__Project__r.CurrencyISOCode, Client_Business_Unit_CBU__c, Sub_Account_Lookup__c
                                                             FROM pse__Resource_Request__c
                                                            WHERE id = :reqId LIMIT 1];   
                    
                System.debug('------ requests : ' + requests);
                    
                if (requests != null && requests.size() > 0) {
                        
                    // Set assignment values from linked Resource Request record
                    assign.Budget__c = requests[0].Budget__c;
                    assign.pse__Role__c = requests[0].pse__Resource_Role__c;
                    assign.pse__Bill_Rate__c = requests[0].pse__Requested_Bill_Rate__c;               
                    assign.pse__Cost_Rate_Amount__c = requests[0].pse__Staffer_Resource__r.pse__Default_Cost_Rate__c;
                    assign.pse__Cost_Rate_Currency_Code__c = requests[0].pse__Project__r.CurrencyISOCode;
                    assign.Client_Business_Unit_CBU__c = requests[0].Client_Business_Unit_CBU__c;
                    assign.Sub_Account_Lookup__c = requests[0].Sub_Account_Lookup__c;
                    /*
                    if (requests[0].Sub_Account_Lookup__c == null)
                        requests[0].addError('A valid Sub-Account should be selected for the assignment record'); */
                     
                }    
                    
                System.debug('----- Assignment final : ' + assign);
            }   
        }
    }        
    
    public void manageContactShareWithPM(List<pse__Assignment__c> assignments) {
        
        System.debug('Entered manageContactShareWithPM method');
        
        // Get set of projects from assignments
        Set<ID> projectSet = new Set<ID>();
        Set<String> resourceSet = new Set<String>();
        for (pse__Assignment__c assign : assignments) {
            projectSet.add(assign.pse__Project__c);
            resourceSet.add(assign.pse__Resource__c);
        } 
        System.debug('----- Project Set : ' + projectSet.size());
        System.debug('----- Resource Set : ' + resourceSet.size());
        
        // Get PM User map of linked project
        Map<ID,ID> projectMap = new Map<ID,ID>();
        Map<String,String> projectStatusMap = new Map<String,String>();
        for (pse__proj__c project : [SELECT id, pse__project_manager__r.pse__salesforce_user__c,
                                            pse__stage__c
                                       FROM pse__proj__c
                                      WHERE ID IN :projectSet]) {
             projectMap.put(project.ID, project.pse__project_manager__r.pse__salesforce_user__c); 
             projectStatusMap.put(project.ID,project.pse__stage__c);                            
        }
        System.debug('----- Project Map : ' + projectMap.size());
        System.debug('----- Project Status Map : ' + projectStatusMap.size());
        
        // Populate sharing map
        Map<String,ID> contactShareMap = new Map<String,ID>();
        for (ContactShare conShare : [SELECT ID, userorgroupId, ContactId, RowCause, ContactAccessLevel
                                        FROM ContactShare
                                       WHERE userorgroupid IN :projectMap.values()
                                         AND ContactID in :resourceSet
                                         AND RowCause = 'Manual']) {
             String key = conShare.contactId + '-' + conShare.userOrGroupId;
             contactShareMap.put(key,conShare.ID);
        }
        System.debug('----- contactShareMap : ' + contactShareMap.size());
        
        List<ContactShare> conShares = new List<ContactShare>();
        
        for (pse__Assignment__c assign : assignments) {
            
            String projectID = (assign.pse__Project__c == null) ? '' : assign.pse__Project__c;
            
            if (projectMap.get(projectID) != null && projectStatusMap.get(projectID) != null && projectStatusMap.get(projectID) != 'Ready to Close') {
                
                String key = assign.pse__Resource__c + '-' + projectMap.get(assign.pse__Project__c);
                System.debug('----- key : ' + key);
                
                // Check if sharing is not done and add to sharing
                if (contactShareMap.get(key) == null) {
                    
                    ContactShare conShare = new ContactShare();
                    conShare.ContactId = assign.pse__Resource__c;
                    conShare.UserOrGroupId = projectMap.get(assign.pse__Project__c);
                    conShare.ContactAccessLevel = 'Read';
                    conShare.RowCause = 'Manual';
                    
                    conShares.add(conShare);
                }
            }
        }
        
        System.debug('----- Number of shares inserted : ' + conShares.size());
        
        Database.SaveResult[] srList = Database.insert(conShares, false);
        
        System.debug('Exited manageContactShareWithPM method');
        
    }    
}