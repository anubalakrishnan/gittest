/********************************************************************
Author   : Ashwini B
Date     : 1/Apr/2017
Action   :
********************************************************************/
trigger ResourceRequestTrigger on pse__Resource_Request__c (before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        
        System.debug('----- Entered trigger ResourceRequestTrigger');
        
        ResourceRequestValidationsHandler reqObjHandler = new ResourceRequestValidationsHandler();
        reqObjHandler.validateResourceRequestUpdates(Trigger.NEW, Trigger.OldMap);
        
        System.debug('----- Exiting trigger ResourceRequestTrigger');
    }
}