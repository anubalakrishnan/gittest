/********************************************************************
Author   :Suman Gupta
Date     :28/Feb/2017
Action   :This is handler class of Trigger 'TriggerOnTimecard'
********************************************************************/
public class TimecardTriggerHandler
{   
    //Author   :Suman Gupta
    //Date     :28/Feb/2017
    //Action   :this method covers the below functionality:
    //Comments should be mandatory at the time of Timecard Rejection
    public void validateRejectionComments(List<pse__Timecard_Header__c> lstTimecard, Map<id, pse__Timecard_Header__c> mapTimecard)
    {
        Map<Id, pse__Timecard_Header__c> mapRejectedStatements = new Map<Id, pse__Timecard_Header__c>{};
        
        //looping through timecard list
        for(pse__Timecard_Header__c objTimecard: lstTimecard)
        {
            pse__Timecard_Header__c objOldTimecard = mapTimecard.get(objTimecard.Id);

            if (objOldTimecard.pse__Status__c != 'Rejected' && objTimecard.pse__Status__c == 'Rejected')
            { 
                mapRejectedStatements.put(objTimecard.Id, objTimecard);
            }
        }
        System.debug('----- mapRejectedStatements : ' + mapRejectedStatements);
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
            System.debug('----- objProcessInstance : ' + objProcessInstance.Steps);
            //if comments is null, then add the error  
            if (!objProcessInstance.Steps.isEmpty() && (objProcessInstance.Steps[0].Comments == null || objProcessInstance.Steps[0].Comments.trim().length() == 0))
            {
                mapRejectedStatements.get(objProcessInstance.TargetObjectId).addError(System.label.Timecard_Mandatory_Rejection_Comments);
            }
        }
    }
    
    //Author   :Suman Gupta
    //Date     :01/March/2017
    //Action   :this method covers the below functionality:
    //Update total number of hours entered for timecards against assignment to compare it with scheduled hours
    public void calculateTotalSubmittedHours(List<pse__Timecard_Header__c> lstTimecard, List<pse__Timecard_Header__c> lstOldTimecard, Map<Id, pse__Timecard_Header__c> mapTimecard, String strTriggerContext)
    {
        set<Id> setAssignmentId = new set<Id>();
        List<pse__Assignment__c> lstAssignmentToUpdate = new List<pse__Assignment__c>{};
    	//insert & upsert scenario
        if(strTriggerContext == 'Insert_Undelete')
        {
            for(pse__Timecard_Header__c objTimecard: lstTimecard)
            {
                if(objTimecard.pse__Assignment__c != null && (objTimecard.pse__Status__c == 'Approved' || objTimecard.pse__Status__c == 'Submitted'))
                {
                    setAssignmentId.add(objTimecard.pse__Assignment__c);
                }
            }
        }
        //delete scenario
        if(strTriggerContext == 'Delete')
        {
            for(pse__Timecard_Header__c objTimecard: lstOldTimecard)
            {
                if(objTimecard.pse__Assignment__c != null && (objTimecard.pse__Status__c == 'Approved' || objTimecard.pse__Status__c == 'Submitted'))
                {
                    setAssignmentId.add(objTimecard.pse__Assignment__c);
                }
            }
        }
        //update scenario
        if(strTriggerContext == 'Update')
        {
            for(pse__Timecard_Header__c objTimecard: lstTimecard)
            {
                if(objTimecard.pse__Assignment__c != null && (mapTimecard.get(objTimecard.id).pse__Assignment__c != objTimecard.pse__Assignment__c ||
                                                      			mapTimecard.get(objTimecard.id).pse__Status__c != objTimecard.pse__Status__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Monday_Hours__c != objTimecard.pse__Monday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Tuesday_Hours__c != objTimecard.pse__Tuesday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Wednesday_Hours__c != objTimecard.pse__Wednesday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Thursday_Hours__c != objTimecard.pse__Thursday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Friday_Hours__c != objTimecard.pse__Friday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Saturday_Hours__c != objTimecard.pse__Saturday_Hours__c ||
                                                             	mapTimecard.get(objTimecard.id).pse__Sunday_Hours__c != objTimecard.pse__Sunday_Hours__c))
                {
                    setAssignmentId.add(objTimecard.pse__Assignment__c);
                    if(mapTimecard.get(objTimecard.id).pse__Assignment__c != objTimecard.pse__Assignment__c)
                        setAssignmentId.add(mapTimecard.get(objTimecard.id).pse__Assignment__c);
                }
            }
        }
        //list not empty
        if(!setAssignmentId.isEmpty())
        {
            //fetching Assignment and related timecards
            List<pse__Assignment__c> lstAssignment = [Select id, Submitted_hours__c, (Select id, pse__Total_Hours__c from pse__Timecards__r where pse__Status__c = 'Approved' OR pse__Status__c = 'Submitted') from pse__Assignment__c where id in :setAssignmentId];
            //checking list is not empty
            if(lstAssignment != null && lstAssignment.size() > 0)
            {
                for(pse__Assignment__c objAssignment :lstAssignment)
                {
                    Double dbTotalhours = 0;
                    //timecards
                    if(objAssignment.pse__Timecards__r != null && objAssignment.pse__Timecards__r.size() > 0)
                    {
                        List<pse__Timecard_Header__c> lstTimecards = objAssignment.pse__Timecards__r;
                        
                        for(pse__Timecard_Header__c objTimecard :lstTimecards)
                        {
                        	dbTotalhours = dbTotalhours + objTimecard.pse__Total_Hours__c;
                        }
                    }
                    //update submitted hours on assignment
                    objAssignment.Submitted_hours__c = dbTotalhours;
                    lstAssignmentToUpdate.add(objAssignment);
                }
                //check if list is not empty
                if(!lstAssignmentToUpdate.isEmpty())
                {
                    update lstAssignmentToUpdate; 
                }
            }
        }
    }
    
    //Author   :Suman Gupta
    //Date     :06/March/2017
    //Action   :this method covers the below functionality:
    //Send user a notification if a timecard has been rejected. In the email notification, need to include the rejected comments as well as the timecard record.
    public void timecardRejectionNotification(List<pse__Timecard_Header__c> lstTimecard, Map<id, pse__Timecard_Header__c> mapTimecard)
    {
        set<Id> setTimecardIds = new set<Id>{};
        Map<Id, String> mapTimecardIdToComments = new Map<Id, String>{};
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        
        //looping through timecard list
        for(pse__Timecard_Header__c objTimecard: lstTimecard)
        {
            pse__Timecard_Header__c objOldTimecard = mapTimecard.get(objTimecard.Id);

            if (objOldTimecard.pse__Status__c != 'Rejected' && objTimecard.pse__Status__c == 'Rejected')
            { 
                setTimecardIds.add(objTimecard.id);
            }
        }
        //check if set is not empty
        if(!setTimecardIds.isEmpty())
        {
            List<pse__Timecard_Header__c> lstFilteredTimecard = [Select id, Name, pse__Resource__c, pse__Resource__r.Name, pse__Resource__r.pse__Salesforce_User__c, pse__Resource__r.pse__Salesforce_User__r.Email
                                                                from pse__Timecard_Header__c where id in :setTimecardIds];
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
                                     :setTimecardIds
                                   ORDER BY CreatedDate ASC
                                  ])
            {   
                if(objProcessInstance.Steps != null && objProcessInstance.Steps.size() > 0)
                {
                    //if rejected comments is not null  
                    if (objProcessInstance.Steps[0].Comments != null && objProcessInstance.Steps[0].Comments.trim().length() > 0)
                    {
                        mapTimecardIdToComments.put(objProcessInstance.TargetObjectId, objProcessInstance.Steps[0].Comments);
                    }
                }
            }
            
            //looping through all rejected timecards
            for(pse__Timecard_Header__c objTimecard :lstFilteredTimecard)
            {
                if(objTimecard.pse__Resource__c != null && objTimecard.pse__Resource__r.pse__Salesforce_User__c != null 
                   && objTimecard.pse__Resource__r.pse__Salesforce_User__r.Email != null && objTimecard.pse__Resource__r.pse__Salesforce_User__r.Email != '')
                {
                    String strtEmail = objTimecard.pse__Resource__r.pse__Salesforce_User__r.Email;
                    if(!mapTimecardIdToComments.isEmpty() && mapTimecardIdToComments.containsKey(objTimecard.id))
                    {
                        String strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                        String strPlainBody = 'Hi ' + objTimecard.pse__Resource__r.Name + ',' + '<br><br>';
                        strPlainBody += 'This Timecard \'' + objTimecard.Name  + '\' has been rejected.<br><br>';
                        strPlainBody += 'Please see rejection reason below:<br>';
                        strPlainBody += mapTimecardIdToComments.get(objTimecard.id) + '<br><br>';
                        strPlainBody += 'Please <a target=\'_blank\' href=' + strBaseURL + '/' + objTimecard.Id +'>click here</a> to go to Timecard record.<br><br>';
                        strPlainBody += 'Thank you';
                        
                        //New instance of a single email message
                        Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                        objEmail.setToAddresses(new String[] {strtEmail});
                        objEmail.setSubject('Timecard \'' + objTimecard.Name + '\' Rejected !');
                        objEmail.setSaveAsActivity(false);
                        objEmail.setHtmlBody(strPlainBody);
                        lstSingleEmailMessage.add(objEmail);
                    }
                }
    		}
        }
        //send email
        if(!lstSingleEmailMessage.isempty())
        {
            Messaging.sendEmail(lstSingleEmailMessage);
		}
    }
}