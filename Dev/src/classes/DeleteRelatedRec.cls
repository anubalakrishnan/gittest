/********************************************************************
Author         : Deepanshu Gupta
Description    : The batch class deletes all the orphan records Budget, Resource 
                 Request and Assignment records for which OLI record is deleted.
Date           : 23/Feb/2017
********************************************************************/

global class DeleteRelatedRec implements 
    Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private static Integer testvar;  
   // Integer i = CustomUtilityClass.testvar;
  
  //  global Integer recordsProcessed = 0;
    Exception[] errors = new Exception[0];
    Exception[] Bgterrors = new Exception[0];
    Exception[] Asgnmnterrors = new Exception[0];
    Exception[] Resreqerrors = new Exception[0];
    List<Id> toemailid = new List<Id>();
    String mailBody = '';
    String Subject = '';
    List<pse__Budget__c> DeletedBgt = new List<pse__Budget__c>();
    List<pse__Resource_Request__c> Deletedresreq = new List<pse__Resource_Request__c>();
    List<pse__Assignment__c> Deletedasgmnt = new List<pse__Assignment__c>();  
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([select id, Name, OLI_ID__c,pse__Include_In_Financials__c, recordtypeid from pse__Budget__c where recordtype.developername = 'Marked_for_Deletion' and pse__Include_In_Financials__c = False]);
    }
    
    global void execute(Database.BatchableContext bc, List<pse__Budget__c> scope){        
        
        Set<Id> setofBgtid = new Set<Id>();
        System.debug('Scope of bud rrec=== >>' + scope);
        
        // Accessing subsequent Budget records
        for(pse__Budget__c relbgt : scope){
            if(relbgt.id != null  && relbgt.pse__Include_In_Financials__c == False){
                setofBgtid.add(relbgt.id);
                DeletedBgt.add(relbgt);
            }           
        }
        
        System.debug('setofBgtid ==' + setofBgtid);
        System.debug('DeletedBgt == >' + DeletedBgt);
        
        // Accessing subsequent Resource Request records
        for(pse__Resource_Request__c resreq: [Select id from pse__Resource_Request__c where Budget__c IN: setofBgtid]){
            if(resreq.id != null){
                Deletedresreq.add(resreq);
            }
        }        
        System.debug('Deletedresreq == >' + Deletedresreq);
        // Accessing subsequent Assignment records
        for(pse__Assignment__c assnmnt:[Select id from pse__Assignment__c where Budget__c IN: setofBgtid])
        {
            if(assnmnt.id != null){
                Deletedasgmnt.add(assnmnt);
            }
        }
        
      //  System.debug('Deletedasgmnt == >' + Deletedasgmnt);
      //  System.debug('Deletedasgmnt.size()==' + Deletedasgmnt.size()  + 'Deletedresreq.size()==' + Deletedresreq.size() + 'DeletedBgt.size()=='  + DeletedBgt.size());
        if(testvar== null){
            testvar=1;
        }
        //Delete records marked for deletion
        
        try{
            if(Deletedasgmnt.size() > 0){
                Delete Deletedasgmnt;
            }
        }
        catch(Exception e){
            errors.add(e);
            Asgnmnterrors.add(e);
        }
        
        if(Deletedresreq.size() > 0){
            try{
                testvar= 1/testvar;
                Delete Deletedresreq;
            }
        
            catch(Exception e){
                errors.add(e);
                Resreqerrors.add(e);
            }
        }
        try{
            if(DeletedBgt.size() > 0){
                Delete DeletedBgt;
            } 
        }    
        catch(Exception e){
            errors.add(e);
            Bgterrors.add(e);
        }
        
     //   recordsProcessed = recordsProcessed + 1;  
  
            // Draft Success/Failure Mail Body
            if(errors.isEmpty())
            {
                Subject = 'Budget record delete job completed successfully';                
                mailBody += 'Budget and associated record deletion job has completed successfully' +  '<br></br>';
                mailBody += 'Number of Budget records deleted:' + DeletedBgt.size() + '<br></br>';
                mailBody += 'Number of Resource request records deleted:' + Deletedresreq.size() + '<br></br>';
                mailBody += 'Number of Assignment records deleted:' + Deletedasgmnt.size() + '<br></br>';
            }
            else
            {
                Subject = 'Budget record delete job encountered errors';
                mailBody += 'Budget and associated record deletion job has encountered errors' + '<br><br>';
                mailBody += 'Number of Budget records deletion failed:' + DeletedBgt.size() + '<br></br>';
                mailBody += 'Number of Resource request records deletion failed:' + Deletedresreq.size() + '<br></br>';
                mailBody += 'Number of Assignment records deletion failed:' + Deletedasgmnt.size() + '<br></br>';
            //    mailBody += 'Error in deletion :: ' + e.getMessage() + '<br><br>';
            //  mailBody += 'Error Cause : ' + e.getCause() + ' at line : ' + e.getLineNumber() + '</font><br><br>';                
            }
    }    
    global void finish(Database.BatchableContext bc) 
    {
       // System.debug('recordsProcessed in finish===' + recordsProcessed); 
        String uid = userinfo.getuserid();
        List<Group> grpid = [SELECT id, Name, RelatedId FROM Group where DeveloperName = 'System_Administrators'];
        List<GroupMember> grpmem = [SELECT id, UserOrGroupId FROM GroupMember where groupid IN: grpid];
        //Accessing group Member to send email
        for(GroupMember grpemailadd: grpmem){
            if(grpemailadd.id != null){
                toemailid.add(grpemailadd.UserOrGroupId);    
            }
        }
     //   System.debug('To mail id address==' + toemailid); 
     //   System.debug('==Sub==' + Subject + '==MailBody==' + MailBody);
        
        if(toemailid.size() > 0 && Subject != '' && mailBody != '')
        {
            // Send Success/Failure email to Sys Admin Public Group
            PSACustomUtilityClass.sendEmailToMultipleRecipient(toemailid,Subject,mailBody);
        }      
    }   
}