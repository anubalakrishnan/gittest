/********************************************************************
Author   : Praveen Kumar
Date     : 15/March/2017
Action   : This is handler class of trigger 'TriggerOnOpportunity' 
			used to populate the Templates on the Opportunity
********************************************************************/

public class Opportunity_ForecastTemplate_Handler {
    
    public void validateOpportunityForecastInsert(List<Opportunity> newOpp) {
        Boolean runMethod = FALSE;
    
        for (Opportunity opp : newOpp) {
              //Opportunity insertion scenario
                if (opp.Services_Sub_Services__c != NULL && opp.Start_Date__c != NULL && opp.End_Date__c !=NULL 
                    && opp.ffrrtemplate__c == NULL && opp.MOF_Approved__c ==TRUE)
                   runMethod = TRUE; 
            }
        if(runMethod)
            setOpportunityForecastTemplates(newOpp);
    }
    
    public void validateOpportunityForecastUpdate(List<Opportunity> newOpp,Map<ID,Opportunity> oldOppMap) {
        Boolean runMethod = FALSE;
    
        for (Opportunity opp : newOpp) {
              //Opportunity update scenario, checking here for any of the three values got changed from its old values.
                if ((opp.Services_Sub_Services__c != oldOppMap.get(opp.ID).Services_Sub_Services__c && opp.Services_Sub_Services__c != NULL)
                    || (opp.Start_Date__c != oldOppMap.get(opp.ID).Start_Date__c && opp.Start_Date__c != NULL)
                    || (opp.End_Date__c != oldOppMap.get(opp.ID).End_Date__c && opp.End_Date__c != NULL)
                    || (opp.MOF_Approved__c != oldOppMap.get(opp.ID).MOF_Approved__c)) {
                        
                        runMethod = TRUE;
                }
            }
        if(runMethod)
            setOpportunityForecastTemplates(newOpp);
    }
	
    // This method checks is to fetch the appropriate Opportunity Forecast Templates
    
    public void setOpportunityForecastTemplates(List<Opportunity> newOpp) {
	
        system.debug('entered getOpportunityForecastTemplates');
       //set of services for all the Opportunities
	   //set of months for all the Opportunities
		Set<String> allOpp_Services = new Set<String>();
        Set<Integer> allOpp_months = new Set<Integer>();
		
		for (Opportunity opp : newOpp) {
           
            if (!opp.Services_Sub_Services__c.contains(';'))
            	allOpp_Services.add(opp.Services_Sub_Services__c.trim());
            Integer monthsBetween = opp.Start_Date__c.monthsBetween(opp.End_Date__c)+1;
			allOpp_months.add(monthsBetween);
		}        

		system.debug('***'+allOpp_Services+'***'+allOpp_months);

           // Get map of associated opportunity templates
		
		List<ffrr__Template__c> allOppTemplates=[select id,name,Months__c,Opportunity_Service__c 
                                                   from ffrr__Template__c 
                                                  where ((Opportunity_Service__c in : allOpp_Services or Opportunity_Service__c = null) 
                                                    and (Months__c in: allOpp_months or Months__c = 18))
                                                    and ffrr__RevenueSource__c = 'Opportunity'];
        
		Map<String,id> mapTemplates= new Map<String,id>();          
        if(!allOppTemplates.isEmpty() && allOppTemplates != NULL){
            for(ffrr__Template__c oppTemplate:allOppTemplates)
            {
                if(!String.isBlank(oppTemplate.Opportunity_Service__c))
                   mapTemplates.put(oppTemplate.Opportunity_Service__c+'_'+oppTemplate.Months__c,oppTemplate.id);
                else
                   mapTemplates.put(''+'_'+oppTemplate.Months__c,oppTemplate.id);
            }
        }
        system.debug('mapTemplates:'+mapTemplates);

        for (Opportunity opp:newOpp) {
            if(opp.MOF_Approved__c == true){
                Boolean isMultipleVal = FALSE;
                String key;
                Integer monthsBetween = (opp.Start_Date__c.monthsBetween(opp.End_Date__c)+1 > 12) ? 18 : opp.Start_Date__c.monthsBetween(opp.End_Date__c)+1;
                isMultipleVal = opp.Services_Sub_Services__c.contains(';') ? TRUE : FALSE;
                if (!isMultipleVal)
                    key = opp.Services_Sub_Services__c.trim() + '_' + monthsBetween;
                else {
                    key = '_' + monthsBetween;
                }
                system.debug('key:'+key);
                key = mapTemplates.containsKey(key) ? key : '_' + monthsBetween; 
                //system.debug('key:'+key); 
                opp.ffrrtemplate__c = mapTemplates.containsKey(key) ? mapTemplates.get(key) : NULL;
                
                System.debug('Opp after setting template : ' + opp);
        	} else
                opp.ffrrtemplate__c = NULL;
        }
	}
}