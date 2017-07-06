/***********************************************************************************
Author         : Praveen Kumar
Description    : 1.This trigger is used to update the 'Month Project Actual' field 
                   on 'Revenue Forecast Transaction Line' Object
				   with the 'Revenue Actuals' value on Project_Actuals__c object
Date           : 21/March/2017
Action         : This invokes the handler class 'ProjectActualsTriggerHandler'
************************************************************************************/

trigger TriggerOnProjectActuals on Project_Actuals__c (after insert) {
    
    ProjectActualsTriggerHandler paHandler = new ProjectActualsTriggerHandler();    
    if (Trigger.isAfter && Trigger.isInsert) {
        paHandler.updateRevenueForecastTransLine(TRIGGER.NEW);
    }
}