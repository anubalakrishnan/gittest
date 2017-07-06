/***********************************************************************
Author   : 	Praveen Kumar
Date     : 	28/March/2017
Action   : 	This is a batch apex class used to update the Forecast Templates 
			on the Budget records based on Forecast Start Date field.
************************************************************************/
global class UpdateBudgetForecastTemplateBatch implements 
			Database.Batchable<sObject>, Database.Stateful {
                
   	Exception[] errors = new Exception[0];
    List<Id> toemailid = new List<Id>();
    String mailBody = '';
    String Subject = ''; 
     
   global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([select id,name,Start_Date__c,End_Date__c,ffrrtemplate__c,Forecast_Start_Date__c,Include_in_Forecast__c 
                                          from pse__Budget__c 
                      					 where Start_Date__c < TODAY
                                           and End_Date__c >= TODAY ]);
   }
    
    global void execute(Database.BatchableContext bc, List<pse__Budget__c> scope){
		system.debug('List<pse__Budget__c> scope size:'+scope.size());
        BudgetForecastTriggerHandler budgHandler = new BudgetForecastTriggerHandler();
        budgHandler.setBudgetForecastTemplates(scope);
        system.debug('List<pse__Budget__c> scope'+scope);
        
        try{
        	update scope;
        } catch(Exception e){
            errors.add(e);
        }
        
        // Draft Success/Failure Mail Body
            if(errors.isEmpty())
            {
                Subject = 'Forecast Template Update job on Budget records completed successfully';                
                mailBody += 'Forecast Template Update job on Budget records completed successfully' +  '<br></br>';
                mailBody += 'Number of Budget records processed:' + scope.size() + '<br></br>';                
            }
            else
            {
                Subject = 'Forecast Template Update job on Budget records encountered with errors';
                mailBody += 'Forecast Template Update job on Budget records encountered with errors' + '<br><br>';
                mailBody += 'Number of Budget records update failed:' + scope.size() + '<br></br>';
            }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        List<Group> grpid = [SELECT id, Name, RelatedId FROM Group where DeveloperName = 'System_Administrators'];
        List<GroupMember> grpmem = [SELECT id, UserOrGroupId FROM GroupMember where groupid IN: grpid];
        //Accessing group Member to send email
        for(GroupMember grpemailadd: grpmem){
            if(grpemailadd.id != null){
                toemailid.add(grpemailadd.UserOrGroupId);    
            }
        }
        
        if(toemailid.size() > 0 && Subject != '' && mailBody != '')
        {
            // Send Success/Failure email to Sys Admin Public Group
            PSACustomUtilityClass.sendEmailToMultipleRecipient(toemailid,Subject,mailBody);
        }
    }


}