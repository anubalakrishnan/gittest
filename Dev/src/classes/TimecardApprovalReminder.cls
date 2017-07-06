/********************************************************************
Author   :Suman Gupta
Date     :08/March/2017
Action   :this class covers the below functionality:
Setup email notification to send out at 5pm on Mondays to users who have timecards that have not yet been approved
********************************************************************/
global class TimecardApprovalReminder implements Schedulable {
   
    @TestVisible Boolean isTestRun;
    
	global void execute(SchedulableContext SC) {
	  
    	Map<Id, List<pse__Timecard_Header__c>> mapIdToTimecards = new Map<Id, List<pse__Timecard_Header__c>>{};
        Map<Id, String> mapIdToApproverName = new Map<Id, String>{};
        Map<Id, String> mapIdToApproverTimezone = new Map<Id,String>();
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        
        isTestRun = (isTestRun == null || isTestRun == FALSE) ? FALSE : TRUE;
        
      	//fetch all timecards which is submitted, but not approved yet  
      	List<pse__Timecard_Header__c> lstTimecards = [Select id, pse__Status__c, Name, pse__Resource__r.Name, pse__Approver__c, pse__Approver__r.Name, 
                                                             pse__Approver__r.TimezoneSidKey, pse__Total_Hours__c
                                                    from pse__Timecard_Header__c 
                                                    where pse__Status__c = 'Submitted' AND pse__Approver__c != null];
      	if(lstTimecards != null && lstTimecards.size() > 0) 
      	{
           	//create a map of approver id and corresponding timecards 
           	//create a map of approver id and its map
        	for(pse__Timecard_Header__c objTimecard :lstTimecards)
            {
                if(!mapIdToTimecards.containskey(objTimecard.pse__Approver__c))
                {
                    mapIdToTimecards.put(objTimecard.pse__Approver__c, new List<pse__Timecard_Header__c>{});
                }
                mapIdToTimecards.get(objTimecard.pse__Approver__c).add(objTimecard);
                mapIdToApproverName.put(objTimecard.pse__Approver__c, objTimecard.pse__Approver__r.Name);
                mapIdToApproverTimezone.put(objTimecard.pse__Approver__c, objTimecard.pse__Approver__r.TimezoneSidKey);
            }
      	}
        //checking if map is not empty
        if(!mapIdToTimecards.isEmpty())
        {
            //get salesforce Base URL
            String strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            //fetching OrgWideEmailAddress to set From Address in email
            List<OrgWideEmailAddress> lstFromAddress = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
                    
        	for(Id approverId :mapIdToTimecards.keySet())
            {
                if(mapIdToTimecards.get(approverId) != null && mapIdToTimecards.get(approverId).size() > 0 &&
                  mapIdToApproverName.get(approverId) != null)
                {
                    
                    // Get current time of of user using timezone
                    Timezone tz = Timezone.getTimezone(mapIdToApproverTimezone.get(approverId));
                    Datetime dt = System.now();
                    Integer offsetMinutes = tz.getOffSet(dt)/1000/60;
                    Datetime convertedDate = dt.addMinutes(offsetMinutes);
                    System.debug('----- convertedDate : ' + convertedDate);
                    
                    // Get hour value from converted date
                    Integer offSetHour = Integer.valueOf(String.valueOfGMT(converteddate).split(' ')[1].split(':')[0]);
                    
                    // Check if weekday and user local time is 5 pm
                    if ((offSetHour == 16 && !dt.format('EEE').equals('Sat') && !dt.format('EEE').equals('Sun')) || isTestRun) {                    
                                        
                        String strEmailBody = 'Hi ' + mapIdToApproverName.get(approverId) + ',' + '<br><br>';
                        strEmailBody += 'Please see the Timecards below which are Pending for your approval :<br><br>';
                        
                        //open table
                        strEmailBody += '<table border="1" style="border-collapse: collapse"><tr><th>Timecard</th><th>Resource</th><th>Total Hours</th></tr>';
                        
                        List<pse__Timecard_Header__c> lstTimecard = mapIdToTimecards.get(approverId);
                        
                        //iterate over list and output columns/data into table rows
                        for(pse__Timecard_Header__c objTimeCard :lstTimecard)
                        {
                            //strEmailBody += '<tr><td>' + objTimeCard.Name + '</td><td>' + objTimeCard.pse__Resource__r.Name + '</td><td>' + objTimeCard.pse__Total_Hours__c + '</td></tr>';
                            strEmailBody += '<tr><td><a target=\'_blank\' href=' + strBaseURL + '/' + objTimecard.Id +'>' + objTimecard.Name + '</a></td><td>' + objTimeCard.pse__Resource__r.Name + '</td><td>' + objTimeCard.pse__Total_Hours__c + '</td></tr>';
                        }
                        //close table
                        strEmailBody += '</table><br><br>';
                        strEmailBody += 'Thank you';
                        //New instance of a single email message
                        Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                        objEmail.setTargetObjectId(approverId);
                        objEmail.setSubject('Timecards Pending for Approval');
                        objEmail.setSaveAsActivity(false);
                        objEmail.setHtmlBody(strEmailBody);
                        //checking for OrgWideEmailAddress to set From Address in email
                        if(lstFromAddress != null && lstFromAddress.size() > 0)
                        {
                            objEmail.setOrgWideEmailAddressId(lstFromAddress[0].id);
                        }
                        lstSingleEmailMessage.add(objEmail); 
                    }
                } 
            }
        }
        //send email
        if(!lstSingleEmailMessage.isempty())
        {
            System.debug('----- lstSingleEmailMessage size : ' + lstSingleEmailMessage.size());
            Messaging.sendEmail(lstSingleEmailMessage);
		}
	}
}