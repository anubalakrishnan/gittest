/********************************************************************
Author         : Mihir Kumar
Description    : The scheduler schedules 'AccountUltimateParentUpdateBatch' class to update ultimate parent on Account records
Date           : 24/Feb/2017
Action         : This schedules 'AccountUltimateParentUpdateBatch' class
********************************************************************/

global class AccountUltimateParentUpdateScheduler implements Schedulable{

    //public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 

    /*global static String scheduleMe() {
        AccountUltimateParentUpdateScheduler SC = new AccountUltimateParentUpdateScheduler(); 
        return System.schedule('Account batch Job', sched, SC);
    }*/

    global void execute(SchedulableContext sc) {

        AccountUltimateParentUpdateBatch b1 = new AccountUltimateParentUpdateBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}