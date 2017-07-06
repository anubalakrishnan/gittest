/********************************************************************
Author   :Mihir Kumar
Date     :17/Feb/2017
Action   :This is test class of Trigger 'TriggerOnAssignment'
/********************************************************************/
@isTest
public class AccountUltimateParentUpdateTest
{
    private static testMethod void test1() 
    {
        Test.startTest(); 
        Account Acc1 = new Account();
        Acc1.Name = 'Test1';
        insert Acc1;
        System.Assert(Acc1.Id!=Null);
        Account Acc2 = new Account();
        Acc2.Name = 'Test2';        
        Acc2.ParentId = Acc1.id;
        insert Acc2;
        System.Assert(Acc2.Id!=Null);
        update Acc2;
        
        Account Acc3 = new Account();
        Acc3.Name = 'Test3';        
        Acc3.ParentId = Acc2.id;
        insert Acc3;
        System.Assert(Acc3.Id!=Null);
        update Acc3;
        
        Account Acc4 = new Account();
        Acc4.Name = 'Test4';        
        Acc4.ParentId = Acc3.id;
        insert Acc4;
        System.Assert(Acc4.Id!=Null);
        update Acc4;
        
        Account Acc5 = new Account();
        Acc5.Name = 'Test5';        
        Acc5.ParentId = Acc4.id;
        insert Acc5;
        System.Assert(Acc5.Id!=Null);
        update Acc5;
        
        Account Acc6 = new Account();
        Acc6.Name = 'Test6';        
        Acc6.ParentId = Acc5.id;
        insert Acc6;
        System.Assert(Acc6.Id!=Null);
        update Acc6;        
        //System.schedule('AccountUltimateParentUpdateScheduler', '0 0 0 * * ?', new AccountUltimateParentUpdateScheduler()); 
        //AccountUltimateParentUpdateScheduler.scheduleMe();
        //call the scheduler class
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String strJobId = System.schedule('ParentAccountBatchUpdate', CRON_EXP, new AccountUltimateParentUpdateScheduler()); 
           
        // Call Batch Apex
        AccountUltimateParentUpdateBatch delbatch = new AccountUltimateParentUpdateBatch();
        Database.executebatch(delbatch);
        Test.stopTest();      
    }   
}