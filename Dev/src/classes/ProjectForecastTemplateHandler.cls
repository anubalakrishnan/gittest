/********************************************************************
Author   : 	Praveen Kumar
Date     : 	15/March/2017
Action   : 	This is another handler class of trigger 'TriggeronProject'
			used to populate the Forecast Templates on the Project
********************************************************************/
public class ProjectForecastTemplateHandler {
    
    //Method to validate Project records to set the Forecast Templates while inserting
    public void validateProjectTemplateInsert(List<pse__Proj__c> newProj) {
        
        // This block checks if the relevant changes have been done to run this method
        Boolean runMethod = FALSE;    
        for (pse__Proj__c proj : newProj) {
        	if (proj.pse__Start_Date__c != NULL && proj.pse__End_Date__c !=NULL && proj.ffrrtemplate__c == NULL
                && proj.pse__Include_In_Forecasting__c == TRUE && proj.Revenue_Type__c == 'T&M')
            		runMethod = TRUE; 
        }
        
        if (runMethod)
        	setProjectForecastTemplates(newProj);
    }
    
    //Method to validate Project records to set the Forecast Templates while updating
    public void validateProjectTemplateUpdate(List<pse__Proj__c> newProj,Map<ID,pse__Proj__c> oldProjMap) {
        
        // This block checks if the relevant changes have been done to run this method
        Boolean runMethod = FALSE;
        
        for (pse__Proj__c proj : newProj) {
    	    if ((proj.pse__Include_In_Forecasting__c!=oldProjMap.get(proj.ID).pse__Include_In_Forecasting__c
             	 || (proj.pse__Start_Date__c != oldProjMap.get(proj.ID).pse__Start_Date__c && proj.pse__Start_Date__c != NULL)
             	 || (proj.pse__End_Date__c != oldProjMap.get(proj.ID).pse__End_Date__c && proj.pse__End_Date__c != NULL)
             	 || (proj.Revenue_Type__c != oldProjMap.get(proj.ID).Revenue_Type__c))
               ) {                        
                 	runMethod = TRUE;
                 }
        }
        if(runMethod)
            setProjectForecastTemplates(newProj);   
        
    }
	
    // Method to fetch the appropriate Project Forecast Templates
    public void setProjectForecastTemplates(List<pse__Proj__c> newProj) {
		
        system.debug('entered get ProjectForecastTemplates');
       
        //Set of months for all the Projects 
		Set<Integer> allProj_months = new Set<Integer>();
		for (pse__Proj__c proj : newProj) {
            Date forecast_start_date = proj.Forecast_Start_Date__c; //proj.pse__Start_Date__c > Date.today() ? proj.pse__Start_Date__c : Date.today();
            if(proj.pse__End_Date__c >= forecast_start_date){
            	Integer monthsBetween = forecast_start_date.monthsBetween(proj.pse__End_Date__c) + 1;
           		allProj_months.add(monthsBetween);
            }
		}        
		
        
        // Get the map of associated Project templates		
		List<ffrr__Template__c> allProjTemplates = [SELECT Id,Name,Months__c 
                                                      FROM ffrr__Template__c 
                                                     WHERE (Months__c in: allProj_months or Months__c = 18)
                                                   	   AND ffrr__RevenueSource__c = 'pse__Proj__c'];        
        system.debug('allProjTemplates:'+allProjTemplates);
        Map<Double,id> mapTemplates= new Map<Double,id>(); 	
        
        if (!allProjTemplates.isEmpty() && allProjTemplates != NULL){			
			for (ffrr__Template__c projTemplate:allProjTemplates)
			{
            	if (projTemplate.Months__c!=NULL)
			    	mapTemplates.put(projTemplate.Months__c,projTemplate.id);
			}
        } 
        system.debug('mapTemplates:'+mapTemplates);
        for (pse__Proj__c proj:newProj) {
            if(proj.pse__Include_In_Forecasting__c == TRUE && proj.Revenue_Type__c == 'T&M'){
                Date forecast_start_date = proj.Forecast_Start_Date__c;//proj.pse__Start_Date__c > Date.today() ? proj.pse__Start_Date__c : Date.today();	
                 
                if(proj.pse__End_Date__c >= forecast_start_date) {
                	Integer monthsBetween = (forecast_start_date.monthsBetween(proj.pse__End_Date__c) + 1) > 12 ? 18 : forecast_start_date.monthsBetween(proj.pse__End_Date__c) + 1;
                    system.debug('monthsBetween:'+monthsBetween);
                    proj.ffrrtemplate__c  = mapTemplates.containsKey(monthsBetween)? mapTemplates.get(monthsBetween) : NULL;
                    System.debug('proj after setting template : ' + proj);
                }
            } else
                proj.ffrrtemplate__c  = NULL;            
        } 
	}
}