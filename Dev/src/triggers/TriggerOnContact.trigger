/********************************************************************************************
Author         : Ashwini B
Description    : Trigger on Contact object.
Date           : 24/March/2017
Action         : Set default cost rate on contact record 
                 Share contact record with career manager
********************************************************************************************/
trigger TriggerOnContact on Contact (before insert, before update, after insert, after update) {

    ContactTriggerHandler objHandler = new ContactTriggerHandler();
    
    // Call method to set cost rate before insert
    if (Trigger.isInsert && Trigger.isBefore)
        objHandler.setCostRatesBeforeInsert(Trigger.NEW);
    
    // Call method to set cost rate before update
    if (Trigger.isUpdate && Trigger.isBefore)
        objHandler.setCostRatesBeforeUpdate(Trigger.NEW, Trigger.OLDMAP);
    
    // Call method to share contact with career manager after insert
    if (Trigger.isInsert && Trigger.isAfter)
        objHandler.shareContactAfterInsert(Trigger.NEW);
    
    // Call method to share contact with career manager after update
    if (Trigger.isUpdate && Trigger.isAfter)
        objHandler.shareContactAfterUpdate(Trigger.NEW, Trigger.OLDMAP);    

}