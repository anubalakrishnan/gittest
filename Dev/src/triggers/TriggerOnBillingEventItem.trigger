/********************************************************************************************
Author         : Ashwini B
Description    : Trigger on Billing Event Item object.
Date           : 22/March/2017
Action         : Invoke validateInvoiceDate and validatePaymentStatus methods
                 in BillingEventItemTriggerHandler class
********************************************************************************************/
trigger TriggerOnBillingEventItem on pse__Billing_Event_Item__c (after update) {

    System.debug('----- Entered TriggerOnBillingEventItem');
    
    BillingEventItemTriggerHandler objHandler = new BillingEventItemTriggerHandler();
    objHandler.validateInvoiceDate(Trigger.NEW, Trigger.OLDMAP);
    objHandler.validatePaymentStatus(Trigger.NEW, Trigger.OLDMAP);
    
    System.debug('----- Exited TriggerOnBillingEventItem');
}