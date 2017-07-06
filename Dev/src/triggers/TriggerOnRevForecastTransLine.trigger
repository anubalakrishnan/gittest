/************************************************************************************
Author   : 	Praveen Kumar
Date     : 	29/March/2017
Action   : 	This trigger is used to Rollup the Budget FTL costs to the Project FTL
*************************************************************************************/
trigger TriggerOnRevForecastTransLine on ffrr__RevenueForecastTransactionLine__c (after update,after delete, after undelete) {
    
    if(Trigger.isAfter ){
        RevForecastTransLineHandler revHandler = new RevForecastTransLineHandler();
        if(Trigger.isUpdate){
            revHandler.validateForecastTransLineUpdate(Trigger.NEW,Trigger.oldMap);
    	}
        if(Trigger.isUndelete){        
        	revHandler.validateForecastTransLine(Trigger.NEW);
        }
        if(Trigger.isDelete){        
        	revHandler.validateForecastTransLine(Trigger.OLD);
        }
    }
    

}