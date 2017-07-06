/********************************************************************************************
Author         : Ashwini B
Description    : Trigger Handler on Contact object.
Date           : 24/March/2017
Action         : Set default cost rate on contact record before insert and before update
                 Share contact record with career manager after insert and after update
********************************************************************************************/
public class ContactTriggerHandler {
    
    // This method checks if resource role and region are not blank and sends the list of contact
    // records for further processing and is called when contacts are inserted
    public void setCostRatesBeforeInsert(List<Contact> contactList) {
        System.debug('----- Entered setCostRatesBeforeInsert');
        List<contact> contactListCostRateUpdates = new List<contact>();        
        
        // Loop through list of contacts
        for (Contact contact : contactList) {
            
            if (!String.isBlank(contact.pse__Salesforce_User__c))
                contact.ownerId = contact.pse__Salesforce_User__c;
            
            // Check if role and region have values
            if (!String.isBlank(contact.pse__Resource_Role__c) && !String.isBlank(contact.pse__Region__c) )
                contactListCostRateUpdates.add(contact);                            
        }
        
        // Send for processing
        if (contactListCostRateUpdates != NULL & contactListCostRateUpdates.size() > 0)
            setDefaultCostRate(contactListCostRateUpdates);                
    }
    
    // This method checks if resource role and region have changed and sends the list of contact
    // records for further processing and is called when contacts are updated
    public void setCostRatesBeforeUpdate(List<Contact> contactList, Map<ID,Contact> oldContactMap) {
        System.debug('----- Entered setCostRatesBeforeUpdate');
        List<contact> contactListCostRateUpdates = new List<contact>();        
        
        for (Contact contact : contactList) {
            
            if (!String.isBlank(contact.pse__Salesforce_User__c))
                contact.ownerId = contact.pse__Salesforce_User__c;
            
            if (contact.pse__Resource_Role__c != oldContactMap.get(contact.ID).pse__Resource_Role__c ||
                   contact.pse__Region__c != oldContactMap.get(contact.ID).pse__Region__c)
                contactListCostRateUpdates.add(contact);           
        }
        
        if (contactListCostRateUpdates != NULL & contactListCostRateUpdates.size() > 0)
            setDefaultCostRate(contactListCostRateUpdates);               
    }
    
    // This method is called when contacts are inserted, checks if a User is associated with contact
    // before sending for processing
    public void shareContactAfterInsert(List<Contact> contactList) {
        System.debug('----- Entered shareContactAfterInsert');        
        List<contact> contactListManagerShare = new List<contact>();
        
        // Loop through contact records
        for (Contact contact : contactList) {            
            // Check if valid user exists
			if (!String.isBlank(contact.pse__Salesforce_User__c)) 
                contactListManagerShare.add(contact);            
        }
        
        // Send contact records for processing
        if (contactListManagerShare != NULL & contactListManagerShare.size() > 0)
            shareWithCareerManager(contactListManagerShare);        
    }    
    
    // This method is called when contacts are updated, checks if a User is associated with contact
    // before sending for processing
    public void shareContactAfterUpdate(List<Contact> contactList, Map<ID,Contact> oldContactMap) {
        System.debug('----- Entered shareContactAfterUpdate');                
        List<contact> contactListManagerShare = new List<contact>();
        
        // Loop through contact records
        for (Contact contact : contactList) {            
            // Check if user field is modified and if valid user exists
			if (contact.pse__Salesforce_User__c != oldContactMap.get(contact.ID).pse__Salesforce_User__c &&
                  !String.isBlank(contact.pse__Salesforce_User__c)) 
                contactListManagerShare.add(contact);            
        }
        
        // Send contact records for processing
        if (contactListManagerShare != NULL & contactListManagerShare.size() > 0)
            shareWithCareerManager(contactListManagerShare);        
    }    

    // Generic method to set default cost rate in contact records
    public void setDefaultCostRate(List<Contact> contactList) {
        System.debug('----- Entered setDefaultCostRate');                
        
        // Get unique collection of role and region from affected contacts
        Set<String> regionSet = new Set<String>();
        Set<String> roleSet = new Set<String>();
        for (Contact contact : contactList) {
            if (contact.pse__Region__c != NULL) regionSet.add(contact.pse__Region__c);
            if (contact.pse__Resource_Role__c != NULL) roleSet.add(contact.pse__Resource_Role__c);
        }
        
        // Populate cost rate map for above combination of roles and regions.
        Map<String,Double> costRateMap = new Map<String,Double>();
        for (Cost_Rate_Lookup__c costRate : [SELECT ID, Role__c, Region__c, Cost_Rate__c
                                               FROM Cost_Rate_Lookup__c
                                              WHERE Role__c IN :roleSet
                                                AND Region__c IN :regionSet]) {
            System.debug(costRate);                                        
            String key = costRate.Role__c + '-' + costRate.Region__c;
            costRateMap.put(key,costRate.Cost_Rate__c);                                     
        }
        System.debug('----- costRateMap : ' + costRateMap.size());
        
        // Loop through contacts and set default cost rate
        for (Contact contact : contactList) {
            
            if (!String.isBlank(contact.pse__Salesforce_User__c))
                contact.ownerId = contact.pse__Salesforce_User__c;
            
            String key = contact.pse__Resource_Role__c + '-' + contact.pse__Region__c;
            if (costRateMap.get(key) != NULL)
                contact.pse__Default_Cost_Rate__c = costRateMap.get(key);
            else
                contact.pse__Default_Cost_Rate__c = 0;
        }
    }
    
    // Generic method to share contact record with career manager
    public void shareWithCareerManager(List<Contact> contactList) {        
        System.debug('----- Entered shareWithCareerManager');        
        List<ContactShare> conSharesToBeInserted = new List<ContactShare>();
        
        // Loop through identified contact records, get career manager and create contact shares
        for (Contact contact : [SELECT ID, Name, pse__Salesforce_User__r.managerId, pse__Salesforce_User__r.manager.profile.name
                                  FROM Contact
                                 WHERE ID IN :contactList]) {
            System.debug(contact);
            if (!String.isEmpty(contact.pse__Salesforce_User__r.managerId)) {                      
            	ContactShare conShare = new ContactShare();
            	conShare.UserOrGroupId = contact.pse__Salesforce_User__r.managerId;
                conShare.ContactAccessLevel = 'Edit';
                conShare.ContactId = contact.ID;
                conShare.RowCause = 'Manual';
                System.debug(conShare);
                conSharesToBeInserted.add(conShare);
            }                        
        }
        
        System.debug('----- conSharesToBeInserted : ' + conSharesToBeInserted.size());
        if (conSharesToBeInserted != NULL && conSharesToBeInserted.size() > 0) 
            insert conSharesToBeInserted;
    }
}