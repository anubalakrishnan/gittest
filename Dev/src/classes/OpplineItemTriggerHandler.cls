public class OpplineItemTriggerHandler{ 

    List<Id> listofoli= new List<Id>();
    List<pse__Budget__c> listtodeletebudget = new List<pse__Budget__c>();
    
    public void updateopplinebudget(List<opportunityLineItem> listoli){
    System.debug('Entryy oppline trigger' + listoli);
        for(OpportunityLineItem olirec : listoli){          
            listofoli.add(olirec.id);
        }     
       System.debug('listofoli===' + listofoli);
       // Access to be deleted oli related budget records
        for(pse__Budget__c relatedbgt : [select id, name, recordtypeid, pse__Include_In_Financials__c from pse__Budget__c where OLI_ID__c in: listofoli])
        {
          System.debug('Budget rec type =' + relatedbgt.recordtypeid + '==Finance chck==' + relatedbgt.pse__Include_In_Financials__c);
            if(relatedbgt.id != null){                
                relatedbgt.recordtypeid = Schema.SObjectType.pse__Budget__c.getRecordTypeInfosByName().get('Marked for Deletion').getRecordTypeId();
                relatedbgt.pse__Include_In_Financials__c = False;
                listtodeletebudget.add(relatedbgt);
            }           
        }
           // System.debug('After Budget rec type =' + relatedbgt.recordtypeid + '==Finance chck==' + relatedbgt.pse__Include_In_Financials__c);
        update listtodeletebudget;  // update budget records marked for deletion   
          //  System.debug('After update Budget rec type =' + relatedbgt.recordtypeid + '==Finance chck==' + relatedbgt.pse__Include_In_Financials__c);
    }
}