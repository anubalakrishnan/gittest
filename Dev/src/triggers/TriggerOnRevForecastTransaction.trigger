/************************************************************************************
Author   : 	Praveen Kumar
Date     : 	3/April/2017
Action   : 	This trigger is used to Rollup the Budget FTL costs to the Project FTL
			upon the action on the FT records.
*************************************************************************************/
trigger TriggerOnRevForecastTransaction on ffrr__RevenueForecastTransaction__c (after insert,after update) {

    system.debug('---->'+Trigger.NEW);
    if(Trigger.isAfter){
        RevForecastTransLineHelper TransObj = new RevForecastTransLineHelper();
        if(Trigger.isUpdate)
        	TransObj.processTransactionsOnUpdate(Trigger.NEW,Trigger.oldMap);
        if(Trigger.isInsert)
            TransObj.processTransactionsOnInsert(Trigger.NEW);
    }    
    
}