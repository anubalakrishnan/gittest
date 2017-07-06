@isTest
private class ContactTriggerHandlerTest {

	@testSetup static void createTestData() {        
        
        // Create test manager
        User manager = new User();
        manager.Username = 'testprojmanager@acostamosaic.com';
        manager.LastName = 'Test Manager';
        manager.email = 'testprojmanager@acostamosaic.com';
        manager.alias = 'test';
        manager.CommunityNickname = 'test mgr name';
        manager.TimeZoneSidKey = 'Asia/Kolkata';
        manager.LocaleSidKey = 'en_US';
        manager.EmailEncodingKey = 'UTF-8';
        manager.ProfileId = [SELECT id FROM profile WHERE name = 'Standard User' LIMIT 1].Id;
        manager.LanguageLocaleKey = 'en_US';

        insert manager;
        System.debug('Inserted manager - ' + manager);
        
        // Create test user
        User user = new User();
        user.Username = 'testprojuser@acostamosaic.com';
        user.LastName = 'Test User';
        user.email = 'testprojuser@acostamosaic.com';
        user.alias = 'test';
        user.CommunityNickname = 'test name';
        user.TimeZoneSidKey = 'Asia/Kolkata';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = [SELECT id FROM profile WHERE name = 'Standard User' LIMIT 1].Id;
        user.LanguageLocaleKey = 'en_US';
        user.ManagerId = manager.ID;

        insert user; 
        System.debug('Inserted user - ' + user);
        
        pse__Region__c region = new pse__Region__c(name = 'Test Region');
        insert region;
        System.debug('Inserted region - ' + region);
        
        Cost_Rate_Lookup__c costLkp = new Cost_Rate_Lookup__c();
        costLkp.Cost_Rate__c = 10;
        costLkp.Role__c = 'Team Lead';
        costLkp.Region__c = region.ID;
        insert costLkp;
        System.debug('Inserted cost rate lookup - ' + costLkp);
    }
    
    static testMethod void insertContactTest() {

        User user = [SELECT ID, name, managerId FROM User WHERE email = 'testprojuser@acostamosaic.com' LIMIT 1];
        pse__Region__c region = [SELECT ID, name from pse__Region__c LIMIT 1];
        Cost_Rate_Lookup__c costLkp = [SELECT ID, name, Cost_Rate__c from Cost_Rate_Lookup__c LIMIT 1];
        
        // Create test contact
        Contact contact = new Contact();
        contact.FirstName = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;
        contact.pse__Salesforce_User__c = user.ID;
        contact.pse__Resource_Role__c = 'Team Lead';
        contact.pse__Region__c = region.ID;
        insert contact;
        
        System.debug('Inserted contact - ' + contact);
        
        Contact contact2 = [SELECT ID, Name, pse__Default_Cost_Rate__c FROM Contact WHERE ID = :contact.ID];
        
        System.assertEquals(costLkp.Cost_Rate__c, contact2.pse__Default_Cost_Rate__c);        
    }
    
    static testMethod void updateContactTest() {

        User user = [SELECT ID, name, managerId FROM User WHERE email = 'testprojuser@acostamosaic.com' LIMIT 1];
        pse__Region__c region = [SELECT ID, name from pse__Region__c LIMIT 1];
        Cost_Rate_Lookup__c costLkp = [SELECT ID, name, Cost_Rate__c from Cost_Rate_Lookup__c LIMIT 1];
        
        // Create test contact
        Contact contact = new Contact();
        contact.FirstName = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;        
        contact.pse__Resource_Role__c = 'Team Lead';        
        insert contact;
        
        System.debug('Inserted contact - ' + contact);
        
        contact.pse__Salesforce_User__c = user.ID;
        contact.pse__Region__c = region.ID;
        update contact;
        
        Contact contact2 = [SELECT ID, Name, pse__Default_Cost_Rate__c FROM Contact WHERE ID = :contact.ID];
        
        System.assertEquals(costLkp.Cost_Rate__c, contact2.pse__Default_Cost_Rate__c);        
    }    
    
    static testMethod void updateCostRateZeroTest() {

        User user = [SELECT ID, name, managerId FROM User WHERE email = 'testprojuser@acostamosaic.com' LIMIT 1];    
        pse__Region__c region = [SELECT ID, name from pse__Region__c LIMIT 1];
        
        // Create test contact
        Contact contact = new Contact();
        contact.FirstName = 'Mosaic';
        contact.lastname = 'Test contact';
        contact.pse__Is_Resource__c = TRUE;
        contact.pse__Is_Resource_Active__c = TRUE;        
        contact.pse__Resource_Role__c = 'Team Lead';
        contact.pse__Region__c = region.ID;
        contact.pse__Salesforce_User__c = user.ID;
        insert contact;
        
        System.debug('Inserted contact - ' + contact);
        
        contact.pse__Region__c = NULL;
        update contact;
        
        Contact contact2 = [SELECT ID, Name, pse__Default_Cost_Rate__c FROM Contact WHERE ID = :contact.ID];
        
        System.assertEquals(0, contact2.pse__Default_Cost_Rate__c);        
    }     
    
}