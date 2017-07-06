/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Billing Event Item object.
Date           : 22/March/2017
Action         : Check if invoice date has been updated in Billing Event Item record and 
                 update Invoiced flag in associated Billing Event record.
********************************************************************************************/
public class BillingEventItemTriggerHandler {

    // This method will check if invoiced date is not blank, then checks same criteria in 
    // all other billing event items, and update Invoiced flag in the associated Billing Event
    public void validateInvoiceDate (List<pse__Billing_Event_Item__c> billEventItemList, 
                                     Map<ID,pse__Billing_Event_Item__c> oldBillEventItemMap) {
        
        System.debug('----- Entered validateInvoiceDate method');
                                         
        List<pse__Billing_Event_Item__c> billEventItemsToProcess = new List<pse__Billing_Event_Item__c>();                                
        
        // Check if invoiced date has been changed from blank to a value
        for (pse__Billing_Event_Item__c billEventItem : billEventItemList) {
            if (billEventItem.Invoice_Date__c != oldBillEventItemMap.get(billEventItem.ID).Invoice_Date__c &&
                billEventItem.Invoice_Date__c != NULL)                
                billEventItemsToProcess.add(billEventItem);
        }                                                 
                                         
        System.debug('----- billEventItemsToProcess size : ' + billEventItemsToProcess.size());                                 
                              
        // proceed if any records are identified for processing                                 
        if (billEventItemsToProcess != NULL && billEventItemsToProcess.size() > 0) {            
            
            // Get set of billing event records
            Set<String> billEventSet = new Set<String>();
            for (pse__Billing_Event_Item__c beItem : billEventItemsToProcess) {
                billEventSet.add(beItem.pse__Billing_Event__c);    
            }
            System.debug('----- billEventSet size : ' + billEventSet.size());
            
            // Get list of billing events for which Invoiced flag should be checked
            List<pse__Billing_Event__c> billEventsToUpdate = new List<pse__Billing_Event__c>();
            for (pse__Billing_Event__c billEvent : [SELECT ID, Name, pse__Invoiced__c, pse__Invoice_Date__c,
                                                           (SELECT ID, Name, Invoice_Date__c
                                                              FROM pse__Billing_Event_Items__r)
                                                      FROM pse__Billing_Event__c
                                                     WHERE ID IN :billEventSet]) {
                System.debug('----- ' + billEvent.pse__Billing_Event_Items__r.size());
                
                Date invoiceDate = NULL;                                         
                if (billEvent.pse__Billing_Event_Items__r != NULL && billEvent.pse__Billing_Event_Items__r.size() > 0) {
                    for (pse__Billing_Event_Item__c bei : billEvent.pse__Billing_Event_Items__r) {                                        
                        if (bei.Invoice_Date__c == NULL) {
                            invoiceDate = NULL;
                            break;
                        } else {
                            invoiceDate = (invoiceDate == null || bei.Invoice_Date__c > invoiceDate) ? bei.Invoice_Date__c : invoiceDate;
                        }
                    }
                    if (invoiceDate != NULL) {
                        System.debug('----- invoiceDate : ' + invoiceDate);
                        billEvent.pse__Invoice_Date__c = invoiceDate;
                        billEvent.pse__Invoiced__c = TRUE;
                        billEventsToUpdate.add(billEvent);
                    }
                }
            }
            
            System.debug('----- billEventsToUpdate size : ' + billEventsToUpdate.size());     
            
            if (billEventsToUpdate != null && billEventsToUpdate.size() > 0)
                update billEventsToUpdate;                   
        }                                          
        
        System.debug('----- Exited validateInvoiceDate method');
    }
    
    /**************************************************************************************************
       Author : Ashwini B
       Date : 11-Apr-2017
       Description : When payment status is set to Closed in Billing Event Item, check same criteria in 
                     all other billing event items, and set Status to Paid in the parent Billing Event
    ***************************************************************************************************/
    
    public void validatePaymentStatus (List<pse__Billing_Event_Item__c> billEventItemList, 
                                Map<ID,pse__Billing_Event_Item__c> oldBillEventItemMap) {
        
        System.debug('----- Entered validateStatus method');
                                         
        List<pse__Billing_Event_Item__c> billEventItemsToProcess = new List<pse__Billing_Event_Item__c>();                                
        
        // Check if status is set to Paid
        for (pse__Billing_Event_Item__c billEventItem : billEventItemList) {
            if (billEventItem.Payment_Status__c != oldBillEventItemMap.get(billEventItem.ID).Payment_Status__c &&
                billEventItem.Payment_Status__c == 'Closed')                
                billEventItemsToProcess.add(billEventItem);
        }                                                 
                                         
        System.debug('----- billEventItemsToProcess size : ' + billEventItemsToProcess.size());                                 
                              
        // proceed if any records are identified for processing                                 
        if (billEventItemsToProcess != NULL && billEventItemsToProcess.size() > 0) {            
            
            // Get set of billing event records
            Set<String> billEventSet = new Set<String>();
            Set<String> milestoneSet = new Set<String>();
            for (pse__Billing_Event_Item__c beItem : billEventItemsToProcess) {
                billEventSet.add(beItem.pse__Billing_Event__c);                   
            }
            System.debug('----- billEventSet size : ' + billEventSet.size());                       
            
            // Get list of billing events for which status should be set to Paid    
            List<pse__Billing_Event__c> billEventsToUpdate = new List<pse__Billing_Event__c>();        
            for (pse__Billing_Event__c billEvent : [SELECT ID, Name, pse__Status__c, Paid__c,
                                                           (SELECT ID, Name, Payment_Status__c, pse__Milestone__c
                                                              FROM pse__Billing_Event_Items__r)
                                                      FROM pse__Billing_Event__c
                                                     WHERE ID IN :billEventSet]) {
                System.debug('----- ' + billEvent.pse__Billing_Event_Items__r.size());
                System.debug('----- ' + billEvent);
                
                Boolean paidStatus = FALSE;                                         
                if (billEvent.pse__Billing_Event_Items__r != NULL && billEvent.pse__Billing_Event_Items__r.size() > 0) {
                    for (pse__Billing_Event_Item__c bei : billEvent.pse__Billing_Event_Items__r) {                                        
                        if (String.isEmpty(bei.Payment_Status__c) || bei.Payment_Status__c != 'Closed') {
                            paidStatus = FALSE;
                            break;
                        } else {
                            paidStatus = TRUE;
                        }
                    }
                    System.debug('----- paidStatus : ' + paidStatus);
                    if (paidStatus) {                        
                        billEvent.Paid__c = paidStatus;
                        billEventsToUpdate.add(billEvent);
                        // Identify milestone to be updated to Paid Status
                        for (pse__Billing_Event_Item__c bei : billEvent.pse__Billing_Event_Items__r) {
                            milestoneSet.add(bei.pse__Milestone__c);
                        } 
                    }
                }
            }
            
            System.debug('----- billEventsToUpdate size : ' + billEventsToUpdate.size());
            System.debug('----- milestoneSet size : ' + milestoneSet.size());  
            
            // Get milestone records to be updated
            List<pse__Milestone__c> milestonesToUpdate;
            if (milestoneSet != null && milestoneSet.size() > 0) {
                milestonesToUpdate = [SELECT Id, Name, Invoice_Paid__c
                                        FROM pse__Milestone__c
                                       WHERE Id IN :milestoneSet
                                         AND Invoice_Paid__c = FALSE];
                                                                
                System.debug('----- milestonesToUpdate size : ' + milestonesToUpdate.size());
                
               if (milestonesToUpdate != null && milestonesToUpdate.size() > 0) {
                   for (pse__Milestone__c milestone : milestonesToUpdate) {
                       milestone.Invoice_Paid__c = TRUE;
                   }
               }                                                                 
            } 
            
            // Update billing events
            if (billEventsToUpdate != null && billEventsToUpdate.size() > 0)
                update billEventsToUpdate; 
             
            // Update milestones               
            if (milestonesToUpdate != null && milestonesToUpdate.size() > 0)  
                update milestonesToUpdate;                                    
        }                                          
        
        System.debug('----- Exited validateInvoiceDate method'); 
    }   
}