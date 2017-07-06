/*
 * @Author      : Deepanshu
 * @Date        : 10th Feb, 2017 
 * @Description : This test class is used to test the CRM_ATMEmailAlertScheduler
 * ***************************************************************************************************** 
 */

@isTest
public class testATMEmailAlert
{
    public static testMethod void testATMEmailAlertmeth(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='testuser@ge.com',EmailEncodingKey='UTF-8', 
                    LastName = 'Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles', UserName='testuser1234@testorg.com');
        insert u;
        
        User u1 = new User(Alias = 'test', Email='testemailuser@ge.com',EmailEncodingKey='UTF-8', 
                    LastName = 'TestingEmail', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles', UserName='testemailuser@testorg.com');
        insert u1;
        
         User u2 = new User(Alias = 'testem', Email='testemailagnuser@ge.com',EmailEncodingKey='UTF-8', 
                    LastName = 'TestingEmailagn', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles', UserName='testemailagnuser@testorg.com');
        insert u2;
        
        Test.startTest();
            System.runas(u){
                Account a = new Account();
                a.Name = 'Test Acc';
                a.Type = 'Client';
                insert a;
                
                accountteammember atm= new accountteammember();
                atm.AccountId=a.id;
                atm.userid=u1.id;
                atm.teammemberrole='Procurement'; 
                insert atm;
                
                accountteammember atm2= new accountteammember();
                atm2.AccountId=a.id;
                atm2.userid=u2.id;
                atm2.teammemberrole='Productiont'; 
                insert atm2;
            
                CRM_ATMEmailAlertScheduler emailSch = new CRM_ATMEmailAlertScheduler();
                String sch = '0 05 * * * ?'; 
                System.schedule('Test Email alert', sch, emailSch); 
        Test.stopTest();
                      
        }           
    }
}