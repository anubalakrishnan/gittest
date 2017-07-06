public with sharing class NewOpportunityCreationAccountController {

    public Opportunity newOpp {get; set;}
    
    public NewOpportunityCreationAccountController(ApexPages.StandardController controller) {
        newOpp = new Opportunity();
        newOpp.AccountId = System.currentPageReference().getParameters().get('id');
        newOpp.OwnerId= Userinfo.getUserId();
        List<RecordType> opprec = [SELECT Id From RecordType WHERE SobjectType = 'Opportunity' AND Name = 'New Opportunity' LIMIT 1];
        newOpp.RecordTypeId = opprec[0].Id;
        List<RecordType> conrec = [SELECT Id From RecordType WHERE SobjectType = 'Contact' AND Name = 'Resource Contact' LIMIT 1];
        List<Contact> contactRec = [SELECT Client_Business_Unit_CBU__c, pse__Group__c, pse__Practice__c, Director__c, MOF__c, pse__Region__c, 
                                    User__c, Senior_Vice_President__c, President__c, Project_Accounting__c, Executive__c 
                                        FROM Contact 
                                        WHERE RecordTypeId =: conrec[0].Id AND pse__Salesforce_User__c =: Userinfo.getUserId()];
        newOpp.pse__Region__c = contactRec[0].pse__Region__c;
        newOpp.pse__Practice__c = contactRec[0].pse__Practice__c;
        newOpp.pse__Group__c = contactRec[0].pse__Group__c;
        newOpp.Client_Business_Unit_CBU__c = contactRec[0].Client_Business_Unit_CBU__c;
        newOpp.MOF__c = contactRec[0].MOF__c;
        newOpp.Senior_Vice_President__c = contactRec[0].Senior_Vice_President__c;
        newOpp.Director__c = contactRec[0].Director__c;
        newOpp.President__c = contactRec[0].President__c;
        newOpp.Vice_President__c = contactRec[0].User__c;
        newOpp.Project_Accounting__c = contactRec[0].Project_Accounting__c;
        newOpp.Executive__c = contactRec[0].Executive__c ;
        newOpp.Probability = 0;
        newOpp.StageName = 'New';
    }
    
    public PageReference saveData(){
        try{
            insert newOpp;
            pagereference pr = new pagereference('/' + newOpp.id);
            return pr;
        }
        catch(Exception ex){
            //ApexPages.addMessages(ex);
        }
        return null;        
    }

}