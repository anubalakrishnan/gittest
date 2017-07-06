/************************************************************************************
Author   		: 	Praveen Kumar
Date     		: 	3/April/2017
Description   	: 	This is the Helper class to the RevForecastTransLineHandler class
					And also called from 'TriggerOnRevForecastTransaction'. 
					Used to Rollup the budget costs to the Project FTLs
*************************************************************************************/
public class RevForecastTransLineHelper {
    
    public void processTransactionsOnInsert(List<ffrr__RevenueForecastTransaction__c> transList){
        Set<Id> transSet = new Set<Id>();
          for (ffrr__RevenueForecastTransaction__c trans : transList) {
               if (trans.ffrr__Latest__c && trans.ffrr_exp__Project__c == NULL
                  && trans.ffrr__Status__c != 'Draft')                             
                   transSet.add(trans.Id);                 
          }                                                                       
          if (!transSet.isEmpty()) {
				getTransactionLines(transSet);              
          }
    }   
    
    
    public void processTransactionsOnUpdate(List<ffrr__RevenueForecastTransaction__c> transList, 
                                    Map<Id,ffrr__RevenueForecastTransaction__c> oldTransMap) {
          
          Set<Id> transSet = new Set<Id>();
          for (ffrr__RevenueForecastTransaction__c trans : transList) {
               if (trans.ffrr__Latest__c != oldTransMap.get(trans.Id).ffrr__Latest__c && trans.ffrr__Latest__c 
                   && trans.ffrr_exp__Project__c == NULL && trans.ffrr__Status__c != 'Draft')                             
                   	transSet.add(trans.Id);                 
          }
                                                                       
          if (!transSet.isEmpty()) {
              getTransactionLines(transSet);
          }
    }
    
    public void getTransactionLines(Set<Id> transSet)
    {
        List<ffrr__RevenueForecastTransactionLine__c> Lines = [select id,name,ffrr__RevenueForecastTransaction__c,ffrr_exp__Project__c,
                                                                    		ffrr_Budget__c,ffrr__Period__c,Status_formula__c,
                                                                     		Category_Latest_formula__c,Category_formula__c
                                                                       from ffrr__RevenueForecastTransactionLine__c 
                                                                      where ffrr__RevenueForecastTransaction__c in:transSet];
              
          if(!Lines.isEmpty())  
               processTransLines(Lines);                                            
    }
    
    public void processTransLines(List<ffrr__RevenueForecastTransactionLine__c> Lines){
        
        List<ffrr__RevenueForecastTransactionLine__c> revLineList = new List<ffrr__RevenueForecastTransactionLine__c>();
        Set<Id> budgIds = new Set<Id>();
        Set<Id> periodIds = new Set<Id>();        
        Set<String> categories = new Set<String>();
        for(ffrr__RevenueForecastTransactionLine__c line:Lines){            
            if(line.ffrr__RevenueForecastTransaction__c != NULL && line.ffrr_exp__Project__c == NULL &&
               line.ffrr_Budget__c != NULL && line.ffrr__Period__c != NULL && 
               line.Status_formula__c != 'Draft' && line.Category_Latest_formula__c == TRUE){
                   revLineList.add(line);
                   budgIds.add(line.ffrr_Budget__c);
                   periodIds.add(line.ffrr__Period__c);
                   categories.add(line.Category_formula__c);
             }
        }
        
        List<ffrr__RevenueForecastTransactionLine__c> dbbudglines = [select id,name,ffrr__RevenueForecastTransaction__c,ffrr_Budget__c,ffrr_Budget__r.pse__Project__c,
                                                                    		ffrr__Period__c,Status_formula__c,ffrr_exp__ValueCurrency__c,
                                                                     		Rollup_of_Budget_Costs__c,Category_formula__c
                                                                       from ffrr__RevenueForecastTransactionLine__c
                                                                      where ffrr_Budget__c in:budgIds 
                                                                    	and ffrr__Period__c in:periodIds
                                                                    	and Category_formula__c in:categories
                                                                    	and Category_Latest_formula__c = TRUE
                                                                    	and Status_formula__c != 'Draft'];
        
        Map<String,Double> dbbudgMap = new Map<String,Double>();
        Map<String,Id> dbbudgProjMap = new Map<String,Id>();
               
        for(ffrr__RevenueForecastTransactionLine__c dbbudgline:dbbudglines){
            
            String key = dbbudgline.ffrr_Budget__r.pse__Project__c+'_'+dbbudgline.ffrr__Period__c+'_'+dbbudgline.Category_formula__c;
            
            if (dbbudgMap.get(key) == null)
            	dbbudgMap.put(key,dbbudgline.ffrr_exp__ValueCurrency__c);
            else {
                Double value = dbbudgMap.get(key);
                value = value + dbbudgline.ffrr_exp__ValueCurrency__c;
                System.debug(value);                
                dbbudgMap.put(key,value);
        	}
            dbbudgProjMap.put(key, dbbudgline.ffrr_Budget__r.pse__Project__c);
        }
        System.debug('----- dbbudgMap : ' + dbbudgMap);
         
               
        List<ffrr__RevenueForecastTransactionLine__c> dbProjLines = [select id,name,ffrr__RevenueForecastTransaction__c,ffrr_Budget__c,ffrr_exp__Project__c,
                                                                    		ffrr__Period__c,Status_formula__c,ffrr_exp__ValueCurrency__c,
                                                                     		Rollup_of_Budget_Costs__c,Category_formula__c
                                                                       from ffrr__RevenueForecastTransactionLine__c
                                                                      where ffrr_exp__Project__c in:dbbudgProjMap.values()
                                                                     	and ffrr__Period__c in :periodIds
                                                                     	and Category_formula__c in:categories
                                                                        and Category_Latest_formula__c = TRUE
                                                                    	and Status_formula__c != 'Draft'];
		
        List<ffrr__RevenueForecastTransactionLine__c> projectRevTransLinesToUpdate = new List<ffrr__RevenueForecastTransactionLine__c>();
        // Map<String,ffrr__RevenueForecastTransactionLine__c> dbProjMap = new Map<String,ffrr__RevenueForecastTransactionLine__c>();
        for(ffrr__RevenueForecastTransactionLine__c dbProjLine:dbProjLines){
            String keyProj = dbProjLine.ffrr_exp__Project__c +'_'+dbProjLine.ffrr__Period__c+'_'+dbProjLine.Category_formula__c;
            dbProjLine.Rollup_of_Budget_Costs__c = dbProjLine.Rollup_of_Budget_Costs__c == NULL ? 0 : dbProjLine.Rollup_of_Budget_Costs__c;
            dbProjLine.Rollup_of_Budget_Costs__c = dbbudgMap.get(keyProj) ;
            projectRevTransLinesToUpdate.add(dbProjLine);
        }
        System.debug('----- projectRevTransLinesToUpdate : ' + projectRevTransLinesToUpdate);
        
		if (!projectRevTransLinesToUpdate.isEmpty())
            update projectRevTransLinesToUpdate;
        
        
    }
}