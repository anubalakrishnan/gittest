/*******************************************************************************
Author   : 	Praveen Kumar
Date     : 	28/March/2017
Action   : 	This is a batch apex class used to update the Forecast Templates 
			on the Project records based on Forecast Start Date field.
********************************************************************************/
global class UpdateProjectForecastTemplateBatch implements 
		Database.Batchable<sObject>, Database.Stateful {
    
   	Exception[] errors = new Exception[0];
    List<Id> toemailid = new List<Id>();
    String mailBody = '';
    String Subject = ''; 
    
   global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([select id,name,pse__Start_Date__c,pse__End_Date__c,ffrrtemplate__c,
                                        		pse__Include_In_Forecasting__c,Revenue_Type__c,Forecast_Start_Date__c
                                          from pse__Proj__c 
                      					 where pse__Include_In_Forecasting__c = TRUE 
                     					   and ERP_Project_Type__c = 'Billable Project'
                                       	   and pse__Start_Date__c < TODAY
                                       	   and pse__End_Date__c >= TODAY ]);
   }
    
    
    global void execute(Database.BatchableContext bc, List<pse__Proj__c> scope){
		system.debug('List<pse__Proj__c> scope size:'+scope.size());
        ProjectForecastTemplateHandler projHandler = new ProjectForecastTemplateHandler();
        projHandler.setProjectForecastTemplates(scope);
        system.debug('List<pse__Proj__c> scope'+scope);
        
        try{
        	update scope;
        } catch(Exception e){
            errors.add(e);
        }
        
        // Draft Success/Failure Mail Body
            if(errors.isEmpty())
            {
                Subject = 'Forecast Template Update job on Project records completed successfully';                
                mailBody += 'Forecast Template Update job on Project records completed successfully' +  '<br></br>';
                mailBody += 'Number of Project records processed:' + scope.size() + '<br></br>';                
            }
            else
            {
                Subject = 'Forecast Template Update job on Project records encountered with errors';
                mailBody += 'Forecast Template Update job on Project records encountered with errors' + '<br><br>';
                mailBody += 'Number of Project records update failed:' + scope.size() + '<br></br>';
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