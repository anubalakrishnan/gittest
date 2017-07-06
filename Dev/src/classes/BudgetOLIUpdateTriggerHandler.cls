/********************************************************************
Author   :Ashwin
Date     :15/Mar/2017
Action   :This is handler class of Trigger 'BudgetTriggerHandler' 
          which will delete resource requests and assignments if the
          parent budget is updated
********************************************************************/
public class BudgetOLIUpdateTriggerHandler {
    
    @testVisible static private Boolean excepCoverage;
    
    // Identify budgets affected by OLI updates and pass to future method for processing 
    public void identifyAffectedBudgets (List<pse__Budget__c> newBudgets, Map<ID,pse__Budget__c> oldBudgetMap) {

        System.debug('----- Entered identifyAffectedBudgets method');
        
        Boolean runMethod = FALSE;
        
        for (pse__Budget__c budget : newBudgets) {
            if (budget.OLI_Sync_Timestamp__c != oldBudgetMap.get(budget.ID).OLI_Sync_Timestamp__c) {
                runMethod = TRUE;
                break;
        	}
        }
        
        if (runMethod) {
        
            System.debug('----- newBudgets : ' + newBudgets.size());
            System.debug('----- oldBudgetMap : ' + oldBudgetMap.size());        
    
            Set<String> budgetsAffected = new Set<String>();
            Set<String> budgetsToCascade = new Set<String>();
            
            Map<String,List<pse__Assignment__c>> budgetAssignmentMap = new Map<String,List<pse__Assignment__c>>();
            Map<String,List<pse__Resource_Request__c>> budgetRequestMap = new Map<String,List<pse__Resource_Request__c>>();
            for (pse__Budget__c budget : [SELECT id, name, 
                                                 (SELECT id, name, pse__resource_held__c, pse__Staffer_Resource__c
                                                    FROM resource_requests__r),                                      
                                                 (SELECT id, name, pse__start_date__c, pse__end_date__c 
                                                    FROM assignments__r)
                                            FROM pse__Budget__c 
                                           WHERE id IN :newBudgets]) {            
                budgetAssignmentMap.put(budget.Id, budget.assignments__r);  
                budgetRequestMap.put(budget.Id, budget.resource_requests__r);                              
            }        
            System.debug('budgetAssignmentMap in identifyAffectedBudgets - ' + budgetAssignmentMap.size()); 
            System.debug('budgetRequestMap in identifyAffectedBudgets - ' + budgetRequestMap.size()); 
            
            for (pse__budget__c budget : newBudgets) {
                
                // Check that update has happened from OLI 
                if (oldBudgetMap.get(budget.Id).OLI_Sync_Timestamp__c != budget.OLI_Sync_Timestamp__c) {                                                                                                
                        
                    System.debug('----- OLI Timestamp modified ----- ');
                    
                    // Check if quantity, amount, expected cost, expected margin, hours booked, product or product desc have changed
                    if ((budget.Quantity__c != oldBudgetMap.get(budget.Id).Quantity__c) ||
                        (budget.pse__Amount__c != oldBudgetMap.get(budget.Id).pse__Amount__c) || 
                        (budget.Expected_Cost__c != oldBudgetMap.get(budget.Id).Expected_Cost__c) ||
                        (budget.Expected_Margin__c != oldBudgetMap.get(budget.Id).Expected_Margin__c) || 
                        (budget.Hours_Booked__c != oldBudgetMap.get(budget.Id).Hours_Booked__c) || 
                        (budget.Product__c != oldBudgetMap.get(budget.Id).Product__c) ||
                        (budget.Product_Description__c != oldBudgetMap.get(budget.Id).Product_Description__c))
                        
                        budgetsAffected.add(budget.ID);          
                    
                    // If start date is changed, check if any assignment exists for the budget                   
                    if (budget.Start_Date__c != oldBudgetMap.get(budget.Id).Start_Date__c) {
                        System.debug('-----budget start date : ' + budget.Start_Date__c);
                        // Check related assignments
                        if (budgetAssignmentMap.get(budget.ID) != null && budgetAssignmentMap.get(budget.ID).size() > 0) {                                                        
                            budgetsAffected.add(budget.ID);
                        }
                        // Check related resource requests and add to appropriate budget set
                        else if (budgetRequestMap.get(budget.ID) != null && budgetRequestMap.get(budget.ID).size() > 0) {
                            Boolean addToDeleteSet = FALSE;
                            Boolean addToUpdateSet = FALSE;
                            for (pse__resource_request__c request : budgetRequestMap.get(budget.ID)) {
                                System.debug('----- request : ' + request);
                                System.debug('----- request resource : ' + request.pse__Staffer_Resource__c);
                                if (request.pse__Resource_Held__c && request.pse__Staffer_Resource__c != NULL)
                                    addToDeleteSet = TRUE;
                                else
                                    addToUpdateSet = TRUE;
                            }
                            System.debug(addToDeleteSet + ' - ' + addToUpdateSet);
                            if (addToDeleteSet) budgetsAffected.add(budget.ID);
                            if (!addToDeleteSet && addToUpdateSet && !budgetsToCascade.contains(budget.ID)) budgetsToCascade.add(budget.ID);                       
                        }                        
                    }
                                                
                    // If end date is changed, check if any assignments and resource requests exist for the budget    
                    if (budget.End_Date__c != oldBudgetMap.get(budget.Id).End_Date__c) {
                        System.debug('-----budget end date : ' + budget.End_Date__c);
                        // Check related assignments
                        if (budgetAssignmentMap.get(budget.ID) != null && budgetAssignmentMap.get(budget.ID).size() > 0) {                                                        
                            budgetsAffected.add(budget.ID);
                        }
                        // Check related resource requests and add to appropriate budget set
                        else if (budgetRequestMap.get(budget.ID) != null && budgetRequestMap.get(budget.ID).size() > 0) {
                            Boolean addToDeleteSet = FALSE;
                            Boolean addToUpdateSet = FALSE;                        
                            for (pse__resource_request__c request : budgetRequestMap.get(budget.ID)) {
                                System.debug('----- request : ' + request);
                                System.debug('----- request resource : ' + request.pse__Staffer_Resource__c);
                                if (request.pse__Resource_Held__c && request.pse__Staffer_Resource__c != NULL)
                                    addToDeleteSet = TRUE;
                                else
                                    addToUpdateSet = TRUE;
                            }
                            System.debug(addToDeleteSet + ' - ' + addToUpdateSet);
                            if (addToDeleteSet) budgetsAffected.add(budget.ID);
                            if (!addToDeleteSet && addToUpdateSet && !budgetsToCascade.contains(budget.ID)) budgetsToCascade.add(budget.ID);                       
                        }                        
                    }
                    
                    // Check if management personnel flag has been checked or unchecked
                    if (budget.Management_Personnel__c != oldBudgetMap.get(budget.Id).Management_Personnel__c) {
                        budgetsAffected.add(budget.ID);                                        
                    }
                }                
            }  
            
            System.debug('----- budgetsAffected in trigger : ' + budgetsAffected.size());
            System.debug('----- budgetsToCascade in trigger : ' + budgetsToCascade.size());
    
            // Call future method to delete requests / assignments and insert / update new resource requests
            if ((budgetsAffected != null && budgetsAffected.size() > 0) || (budgetsToCascade != null && budgetsToCascade.size() > 0))
                processAffectedBudgets(budgetsAffected, budgetsToCascade);    
            
        }
    }  
        
    // This method will delete resource requests and assignments in affected budgets
    // and create new resource requests
    @future
    static void processAffectedBudgets (Set<String> budgetIDList, Set<String> budgetCascadeList) {
                
        if (excepCoverage == null) excepCoverage = FALSE;
        
        String hostName = URL.getSalesforceBaseUrl().toExternalForm();
        String mailBody = '';
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
        System.debug('----- Entered processAffectedBudgets method');
        System.debug('----- budgetIDList in future method: ' + budgetIDList.size()); 
        System.debug('----- budgetCascadeList in future method: ' + budgetCascadeList.size());
        
        List<pse__Resource_Request__c> requestsToDelete = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> requestsToInsert = new List<pse__Resource_Request__c>();
        List<pse__Resource_Request__c> requestsToUpdate = new List<pse__Resource_Request__c>();
        List<pse__Assignment__c> assignmentsToDelete = new List<pse__Assignment__c>();
        
        try {
                        
            // Get project information from budgets
            Set<String> projectSet = new Set<String>();        
            for (pse__Budget__c budget : [SELECT ID, pse__Project__c 
                                            FROM pse__Budget__c 
                                           WHERE id IN :budgetIDList]) {
                projectSet.add(budget.pse__Project__c);
            }
            System.debug('Project Set - ' + projectSet.size());
    
            // Get resource requests and assignments from budgets
            Map<String,List<pse__Resource_Request__c>> budgetRequestMap = new Map<String,List<pse__Resource_Request__c>>();
            Map<String,List<pse__Assignment__c>> budgetAssignmentMap = new Map<String,List<pse__Assignment__c>>();
            for (pse__Budget__c budget : [SELECT id, name, (SELECT id, name, pse__start_date__c, pse__end_date__c FROM resource_requests__r),
                                          (SELECT id, name, Budget__r.name, pse__Project__r.name,
                                                  pse__Project__r.pse__Project_manager__r.name,
                                                  pse__Project__r.pse__Project_manager__r.pse__salesforce_user__c,
                                                  pse__start_date__c, pse__end_date__c
                                             FROM assignments__r)
                                          FROM pse__Budget__c 
                                          WHERE id IN :budgetIDList]) {
                budgetRequestMap.put(budget.Id, budget.resource_requests__r);
                budgetAssignmentMap.put(budget.Id, budget.assignments__r);                              
            }
            System.debug('budgetRequestMap - ' + budgetRequestMap.size());
            System.debug('budgetAssignmentMap - ' + budgetAssignmentMap.size());
    
            // Populate project map from list of shortlisted projects
            Map<Id,pse__Proj__c> projectMap = new Map<Id,pse__Proj__c>();
            for (pse__proj__c project : [SELECT id, name, currencyISOCode, pse__Region__c, pse__Practice__c, pse__Group__c,
                                         Client_BusinessUnit_CBU__c, Services_Sub_Services__c, pse__start_date__c, pse__end_date__c
                                         FROM pse__proj__c
                                         WHERE id IN :projectSet]) {
                 projectMap.put(project.Id, project);                                
            }
            System.debug('Project Map - ' + projectMap.size());   
            
            Map<String,String> pmRequestDelMap = new Map<String,String>();
            Map<String,String> pmRequestUpdMap = new Map<String,String>();
            Map<String,String> pmAssignDelMap = new Map<String,String>();            
            Set<String> pmUserSet = new Set<String>();
            
            for (pse__budget__c budget : [SELECT ID, name, Quantity__c, Management_Personnel__c, pse__Project__c, Practice__c,
                                                 pse__Opportunity__c, Hours_Booked__c, Bill_Rate__c, Start_Date__c,
                                                 pse__Effective_Date__c, End_Date__c, Product_Description__c, pse__project__r.name,
                                                 pse__project__r.pse__Project_manager__r.pse__salesforce_user__c
                                            FROM pse__Budget__c 
                                           WHERE ID IN :budgetIDList]) {
                                               
                 String pmUser = budget.pse__project__r.pse__Project_manager__r.pse__salesforce_user__c;
                 if (pmUser != null && pmUser.trim().length() > 0) pmUserSet.add(pmUser);                              
                 String reqDelBody = pmRequestDelMap.get(pmUser) == null ? '' : pmRequestDelMap.get(pmUser);
                                                                                                                                                                           
                 if (budgetRequestMap.get(budget.Id) != null && budgetRequestMap.get(budget.Id).size() > 0) {
                     requestsToDelete.addAll(budgetRequestMap.get(budget.Id));                                                  
                     // build consolidated email to PMs
                     for (pse__resource_request__c request : budgetRequestMap.get(budget.Id)) {
                         reqDelBody += '<tr><td>' + request.name + '</td><td>' + request.pse__start_date__c.format() + '</td><td>' + request.pse__end_date__c.format() + '</td><td><a href="' + hostName + '/' + budget.ID + '">' + budget.name + '</a></td><td><a href="' + hostname + '/' + budget.pse__project__c + '">' + budget.pse__project__r.name + '</a></td></tr>';
                     }
                     System.debug('----- reqDelBody : ' + reqDelBody);
                     pmRequestDelMap.put(pmUser,reqDelBody);                     
                 }   
                                                   
                 String assignDelBody = pmAssignDelMap.get(pmUser) == null ? '' : pmAssignDelMap.get(pmUser);                                               
                 if (budgetAssignmentMap.get(budget.Id) != null && budgetAssignmentMap.get(budget.Id).size() > 0) {                     
                     assignmentsToDelete.addAll(budgetAssignmentMap.get(budget.Id));                              
                     // build consolidated email to PMs
                     for (pse__assignment__c assign : budgetAssignmentMap.get(budget.Id)) {
                         assignDelBody += '<tr><td>' + assign.name + '</td><td>' + assign.pse__start_date__c.format() + '</td><td>' + assign.pse__end_date__c.format() + '</td><td><a href="' + hostName + '/' + budget.ID + '">' + budget.name + '</a></td><td><a href="' + hostname + '/' + budget.pse__project__c + '">' + budget.pse__project__r.name + '</td></tr>';
                     }
                     System.debug('----- assignDelBody : ' + assignDelBody);
                     pmAssignDelMap.put(pmUser,assignDelBody);
                 }                                      
                 
                 // Build new resource requests
                 if (budget.Management_Personnel__c && budget.Quantity__c != NULL && budget.Quantity__c > 0) {
                      
                     // Check that project info exists
                     if (projectMap.get(budget.pse__Project__c) != null) {
                            
                         pse__proj__c project = projectMap.get(budget.pse__Project__c);
                         System.debug('Retrieved project - ' + project);
                            
                         for (Integer i = 1; i <= budget.Quantity__c; i++ ) {
                               
                             try {
                                 // Create resource request
                                 pse__Resource_Request__c request = new pse__Resource_Request__c();
                                 request.pse__Opportunity__c = budget.pse__Opportunity__c;
                                 request.Budget__c = budget.Id;
                                 request.pse__SOW_Hours__c = budget.Hours_Booked__c / budget.Quantity__c;
                                 request.CurrencyIsoCode = project.CurrencyIsoCode;
                                 request.pse__Requested_Bill_Rate__c = budget.Bill_Rate__c;
                                 request.pse__Project__c = project.Id;
                                 request.pse__Start_Date__c = (budget.Start_Date__c == null) ? budget.pse__Effective_Date__c : budget.Start_Date__c;
                                 request.pse__End_Date__c = (budget.End_Date__c == null) ? project.pse__End_Date__c : budget.End_Date__c;
                                 request.pse__Region__c = project.pse__Region__c;
                                 request.pse__Practice__c = budget.Practice__c;
                                 request.pse__Group__c = project.pse__Group__c;
                                 request.Client_Business_Unit_CBU__c = project.Client_BusinessUnit_CBU__c;
                                 request.Services_Sub_Services__c = project.Services_Sub_Services__c;
                                 request.pse__Resource_Role__c = budget.Product_Description__c;  
                                    
                                 System.debug ('Request ' + i + ' to be inserted - ' + request);
                                   
                                 // add to requests list
                                 requestsToInsert.add(request);
                                 
                             } catch (exception e) {
                                 mailBody += '<font color="red">Error in building new resource request for budget : ' + budget.name + '<br>';
                                 mailBody += 'Error Cause : ' + e.getCause() + ' at line : ' + e.getLineNumber() + '</font><br><br>';
                             }                                 
                         }
                     }                                                            
                 }                                                                     
             } 
            
            // Get budget records to update resource requests
            for (pse__Budget__c budget : [SELECT ID, name, Start_Date__c, End_Date__c, pse__project__c, pse__project__r.name,
                                                 pse__project__r.pse__Project_manager__r.pse__salesforce_user__c,
                                                 (SELECT id, name, pse__Start_Date__c, pse__End_Date__c
                                                    FROM resource_requests__r)
                                            FROM pse__Budget__c 
                                           WHERE ID IN :budgetCascadeList]) {
                                  
                String pmUser = budget.pse__project__r.pse__Project_manager__r.pse__salesforce_user__c;  
                pmUserSet.add(pmUser);                               
                String reqUpdBody = pmRequestUpdMap.get(pmUser) == null ? '' : pmRequestUpdMap.get(pmUser); 
                                               
                // Set modified start and end dates in resource requests                               
                for (pse__Resource_Request__c request : budget.resource_requests__r) {
                    
                    request.pse__Start_Date__c = budget.Start_Date__c;
                    request.pse__End_Date__c = budget.End_Date__c;                                        
                    requestsToUpdate.add(request);
                                        
                    reqUpdBody += '<tr><td>' + request.name + '</td><td>' + request.pse__start_date__c.format() + '</td><td>' + request.pse__end_date__c.format() + '</td><td><a href="' + hostName + '/' + budget.ID + '">' + budget.name + '</a></td><td><a href="' + hostname + '/' + budget.pse__project__c + '">' + budget.pse__project__r.name + '</td></tr>';
                    System.debug('----- reqUpdBody : ' + reqUpdBody);
                    pmRequestUpdMap.put(pmUser,reqUpdBody);
                }                                                                                                                                                                                            
            }
            
            System.debug('----- requestsToUpdate : ' + requestsToUpdate.size());

            try {               
                if (requestsToUpdate != null && requestsToUpdate.size() > 0) {
                    System.debug('Total resource requests marked for update - ' + requestsToUpdate.size());
                    Database.saveResult[] updReqList = Database.update(requestsToUpdate, true);
                    System.debug(updReqList);
                    mailBody += 'Successfully updated ' + requestsToUpdate.size() + ' resource requests.<br><br>';
                }
            } catch (exception e) {
                mailBody += 'Error in updating resource requests :: ' + e.getMessage() + '<br><br>';
            }             
            
             try {                           
                if (assignmentsToDelete != null && assignmentsToDelete.size() > 0) {
                    System.debug('Total assignments marked for deletion - ' + assignmentsToDelete.size()); 
                    Database.deleteResult[] delAssignList = Database.delete(assignmentsToDelete, true);
                    System.debug(delAssignList); 
                    mailBody += 'Successfully deleted ' + delAssignList.size() + ' assignments<br><br>';                     
                }  
             }
             catch (exception e1) {
                mailBody += 'Error in deleting assignments :: ' + e1.getMessage() + '<br><br>';     
             }     
                
             try {               
                if (requestsToDelete != null && requestsToDelete.size() > 0) {
                    System.debug('Total resource requests marked for deletion - ' + requestsToDelete.size());
                    Database.deleteResult[] delReqList = Database.delete(requestsToDelete, true);
                    System.debug(delReqList);
                    mailBody += 'Successfully deleted ' + delReqList.size() + ' resource requests<br><br>';
                }
             } catch (exception e2) {
                 mailBody += 'Error in deleting resource requests :: ' + e2.getMessage() + '<br><br>';
             }
                
             try {                         
                if (requestsToInsert != null && requestsToInsert.size() > 0) {
                    System.debug('List of requests to be inserted - ' + requestsToInsert.size());  
                    Database.SaveResult[] srList = Database.insert(requestsToInsert, true);
                    System.debug(srList);
                    mailBody += 'Successfully inserted ' + requestsToInsert.size() + ' new resource requests<br><br>';
                }   
            } catch (exception e3) {
                mailBody += 'Error in deleting resource requests :: ' + e3.getMessage() + '<br><br>';
            }
            
            // send emails to PMs     
            String subject = Date.today().format() + ' :: Resource Request / Assignment Deletion Due To Quote Update';   
            System.debug('----- pmUserSet : ' + pmUserSet);
            for (String pmUser : pmUserSet) {
                String body = '';
                String reqDelBody = '';
                if (pmRequestDelMap.get(pmUser) != null && pmRequestDelMap.get(pmUser).trim().length() > 0) {                      
                    reqDelBody = 'Requests deleted due to quote change.<br><br>'; 
                    reqDelBody += '<table border="1" cellpadding="5" cellspacing="5" style="border-collapse:collapse;"><th>Request Name</th><th>Start Date</th><th>End Date</th><th>Budget Name</th><th>Project Name</th>';                              
                    reqDelBody += pmRequestDelMap.get(pmUser) + '</table><br><br>';
                } 
                String assignDelBody = '';
                if (pmAssignDelMap.get(pmUser) != null && pmAssignDelMap.get(pmUser).trim().length() > 0) {
                    assignDelBody = 'Assignments deleted due to quote change.<br><br>'; 
                    assignDelBody += '<table border="1" cellpadding="5" cellspacing="5" style="border-collapse:collapse;"><th>Assignment Name</th><th>Start Date</th><th>End Date</th><th>Budget Name</th><th>Project Name</th>';                              
                    assignDelBody += pmAssignDelMap.get(pmUser) + '</table><br><br>';                    
                }
                String reqUpdBody = '';
                if (pmRequestUpdMap.get(pmUser) != null && pmRequestUpdMap.get(pmUser).trim().length() > 0) {                      
                    reqUpdBody = 'Requests updated due to quote change.<br><br>'; 
                    reqUpdBody += '<table border="1" cellpadding="5" cellspacing="5" style="border-collapse:collapse;"><th>Request Name</th><th>Start Date</th><th>End Date</th><th>Budget Name</th><th>Project Name</th>';                              
                    reqUpdBody += pmRequestUpdMap.get(pmUser) + '</table>';
                }                                
                body = reqDelBody + reqUpdBody + assignDelBody;
                System.debug('---------- pmUser : ' + pmUser);
                if (body.trim().length() > 0) {
                	Messaging.SingleEmailMessage mail = PSACustomUtilityClass.buildEmail(pmUser, subject, body);
                	emails.add(mail);
                }
            }
            System.debug('----- Emails to PMs : ' + emails);     
            
            if (excepCoverage)  Integer i = 1/0;
                 
        } catch (exception e) {
            System.debug('Error msg :' + e.getLineNumber() + e.getMessage());
            mailBody += '<br>The budget update job has abruptly ended. Please forward the below error message to your administrator and get it rectified to preserve data sanity on Budgets and related Resource Request records.';
            mailBody += '<br><br>Class Name :: BudgetOLIUpdateTriggerHandler';
            mailBody += '<br>Error at line :: ' + e.getLineNumber();
            mailBody += '<br>Error Cause :: ' + e.getMessage();
            mailBody += '<br>List of Budgets to be reviewed :: ' + budgetIDList;
        }
        
        // Send status email of the entire job to a user of choice
        if (mailBody.trim().length() > 0) {
            String subject = Date.today().format() + ' :: Budget Updates to Resource Requests / Assignments :: Delete and Insert';
            mailBody = 'Number of budgets affected : ' + budgetIDList.size() + '<br><br>' + mailBody;
            Messaging.SingleEmailMessage mail = PSACustomUtilityClass.buildEmail(UserInfo.getUserID(), subject, mailBody);          
            System.debug('----- mail : ' + mail);
            emails.add(mail);            
        } 
        
        // Send all emails in one action
        if (emails != null && emails.size() > 0) {
            Messaging.sendEmail(emails);
        }
    }        
}