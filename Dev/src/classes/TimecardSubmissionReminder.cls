/********************************************************************
Author   :Suman Gupta
Date     :09/March/2017
Action   :this class covers the below functionality:
Setup email notifications to send to users who have not submitted previous week timecards at 10am on Monday.
The email should be triggered at 10 am as per timezone of the user.
********************************************************************/
global class TimecardSubmissionReminder implements Schedulable {        
   
    @TestVisible Boolean isTestRun;
    
	global void execute(SchedulableContext SC) {
	  
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Contact> lstContact = [Select Id, Name, pse__Salesforce_User__c, pse__Is_Resource__c, pse__Is_Resource_Active__c, pse__Salesforce_User__r.TimezoneSidKey,
                                   (Select id, Name, pse__Total_Hours__c, pse__Status__c from pse__Timecards__r where pse__Start_Date__c = :System.today().adddays(-7) 
                                    AND pse__End_Date__c = :System.today().adddays(-1) AND (pse__Status__c = 'Submitted' OR pse__Status__c = 'Approved'))
                                   from Contact where pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true 
                                   AND pse__Salesforce_User__c != null];  
        
        isTestRun = (isTestRun == null || isTestRun == FALSE) ? FALSE : TRUE;
        
        //check if list is not empty
        If(lstContact != null && lstContact.size() > 0)
        {
            //get salesforce Base URL
            String strBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            //fetching OrgWideEmailAddress to set From Address in email
            List<OrgWideEmailAddress> lstFromAddress = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
            for(Contact objContact :lstContact)
            {
                List<pse__Timecard_Header__c> lstTimecard = new List<pse__Timecard_Header__c>{};
                lstTimecard = objContact.pse__Timecards__r;
                decimal decTotalHours = 0; 
                if(!lstTimecard.isEmpty())
                {
                    for(pse__Timecard_Header__c objTimecard :lstTimecard)
                    {
                        decTotalHours += objTimecard.pse__Total_Hours__c; 
                    }
                }
                if(lstTimecard.isEmpty() || decTotalHours < 40)
                {
                    
                    // Get current time of of user using timezone
                    Timezone tz = Timezone.getTimezone(objContact.pse__Salesforce_User__r.TimezoneSidKey);
                    Datetime dt = System.now();
                    Integer offsetMinutes = tz.getOffSet(dt)/1000/60;
                    Datetime convertedDate = dt.addMinutes(offsetMinutes);
                    System.debug('----- convertedDate : ' + convertedDate);
                    
                    // Get hour value from converted date
                    Integer offSetHour = Integer.valueOf(String.valueOfGMT(converteddate).split(' ')[1].split(':')[0]);
                    
                    // Check if weekday is Monday and time is 10 am
                    // if ((offSetHour == 10 && dt.format('EEE').equals('Mon')) || isTestRun) { 
                    if ((offSetHour == 10 && dt.format('EEE').equals('Mon')) || isTestRun) { 
                    
                        String strEmailBody = 'Hi ' + objContact.Name + ',' + '<br><br>';
                        strEmailBody += 'This is a reminder to submit a 40 hour timecard for the previous week.<br><br>';
                        strEmailBody += 'Thank you';
                        //New instance of a single email message
                        Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
                        objEmail.setTargetObjectId(objContact.pse__Salesforce_User__c);
                        objEmail.setSubject('Weekly Time Reminder');
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