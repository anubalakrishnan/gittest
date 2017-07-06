/****************************************************
*
*Class Name  : CRM_ATMEmailAlertScheduler
*Description : Batch class to schedule CRM_ATMEmailAlert 
*Created By  : Mihir Kumar :: 1/27/2017
*Modified By : 
*
****************************************************/


global class CRM_ATMEmailAlertScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC)
    {

        Map<ID,Set<ID>> aTeams = New Map<ID,Set<ID>>();
        Map<Id, Account> mapofacc = New Map<ID, Account>();
        Map<ID,String> usrnamenid = New Map<ID,String>();
        List<Id> toadd = new List<Id>();
        List<Id> usrlst = new List<Id>();     

        DateTime dt = System.Now().addHours(-1);
        System.debug('Date==' + dt);
        List<AccountTeamMember> act = [SELECT ID,Title,UserId,accountid FROM AccountTeamMember where CreatedDate >=: System.Now().addHours(-1)];
        System.debug('ACT rec ==' + act);
        for(AccountTeamMember atm : act)
        {         
            usrlst.add(atm.userid);
            if(aTeams.get(atm.accountid) != null)
            {
                aTeams.get(atm.accountid).add(atm.userid);
            } 
            else
            {
                aTeams.put(atm.accountid,New Set<ID>());
                aTeams.get(atm.accountid).add(atm.UserId);
            }
             
        }   
        List<Account> acnt =[Select id,name,ownerid,owner.name from account where id in:aTeams.keyset()];
        {
            for(Account acc: acnt)
            {
                if(acc.id != null)
                {
                    mapofacc.put(acc.id,acc);
                }
            }
        }
         
        List<User> usr = [Select id,name from User where id in: usrlst];
        {
            for(User u : usr)
            {   
                if(u.id != null)
                {     
                    usrnamenid.put(u.id,u.name);
                }    
            }
        }
       
        for(AccountTeamMember key: act)
        {
            ID toAddresses = mapofacc.get(Key.accountid).ownerid;
            String Ownername = mapofacc.get(Key.accountid).owner.Name;
            String actmemname = usrnamenid.get(key.userid);    
            String accname = mapofacc.get(Key.accountid).Name;
           // toadd.add(toAddresses);
            System.debug('toAddresses ==' + toAddresses + '==ownername==' + ownername + '==actmemname==' + actmemname + '==accname==' + accname);  
            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm();
                        
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            String body =  actmemname;
            body += ' has been added to the ';
            body +=  accname;
            body += ' client team.Please visit the client record to review: ' + '<br/><br/>';
           // body += '<br></font><font size=\'1\' face=\'Arial,Sans-Serif\'> <a target=\'_blank\' href=\'' +fullRecordURL + '/'+accid+'\'>'+fullRecordURL+'/'+accid+'</a>';
            body += '<a target=\'_blank\' href='+fullRecordURL+'/'+key.accountid+'>'+accname+'</a>'  + '<br/><br/>'; 
            body += 'Thank You'; 
         
            email.setSubject( actmemname + ' has been added to the '+ accname  + ' client team');
         //   email.setToAddresses(toAdd);
            email.setTargetObjectId(toAddresses);
            email.setHTMLBody(body);
            email.setSaveAsActivity(false);
            System.debug('Email==' + email);
            mails.add(email);
         //   Messaging.sendEmail(mails);
          //  List<Messaging.SendEmailResult> emailresults=Messaging.sendEmail(mails);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
            
        }
    }  
}