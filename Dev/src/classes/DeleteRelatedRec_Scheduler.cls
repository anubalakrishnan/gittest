/********************************************************************
*Author         : Deepanshu Gupta
*Description    : This Scheduler schedules the batch apex to run evey hour
*                    for deleting the orphan records.
*Date           : 24/Feb/2017
********************************************************************/

global class DeleteRelatedRec_Scheduler implements Schedulable{

  //  public static String sched = '0 00 * * * ?';  //Every Day at Midnight 
/*
    global static String scheduleMe() {
        DeleteRelatedRec_Scheduler  SC = new DeleteRelatedRec_Scheduler(); 
        return System.schedule('My batch Job', sched, SC);
    }
*/
    global void execute(SchedulableContext sc) {

        DeleteRelatedRec delbatch = new DeleteRelatedRec();
        ID batchprocessid = Database.executeBatch(delbatch,200);           
    }
}