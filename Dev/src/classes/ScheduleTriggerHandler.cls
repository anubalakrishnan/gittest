public class ScheduleTriggerHandler {
    
    // This method will round up the scheduled hours to the nearest integer if coming from Resource Request page
    public void roundScheduledHours (List<pse__Schedule__c> schedules) {
        
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null && 
            ApexPages.currentPage().getUrl().containsIgnoreCase('/pse__assignresource')) {
                
            for (pse__Schedule__c schedule : schedules) { 
                System.debug(schedule);
                
                if (schedule.pse__Scheduled_Hours__c == null) {
                    Date dat = schedule.pse__Start_Date__c;
                    Integer dayCount = 0;
                    while (dat <= schedule.pse__End_Date__c) {
                        Datetime dt = Datetime.newInstance(dat.year(),dat.month(),dat.day(),0,0,0);
                        if (dt.format('EEE') != 'Sat' && dt.format('EEE') != 'Sun')
                            dayCount++;
                        dat = dat.addDays(1);
                    }
                    System.debug(dayCount);
                    
                    Double hours = 0.0;
                    if (schedule.pse__Monday_Hours__c == schedule.pse__Tuesday_Hours__c && 
                        schedule.pse__Tuesday_Hours__c == schedule.pse__Wednesday_Hours__c &&
                        schedule.pse__Wednesday_Hours__c == schedule.pse__Thursday_Hours__c &&
                        schedule.pse__Thursday_Hours__c == schedule.pse__Friday_Hours__c)
                        hours = (dayCount * schedule.pse__Monday_Hours__c).round(System.RoundingMode.HALF_DOWN);   
                    
                    pse__Schedule__c schedule2 = new pse__Schedule__c(id = schedule.Id);
                    schedule2.pse__Scheduled_Hours__c = hours;
                    schedule2.pse__Scheduled_Days__c = dayCount;
                    update schedule2;
                }
            }                
        }
    }

    // This method will calculate scheduled hours and update on related assignments
    public void rollupScheduleToAssignment (List<pse__Schedule__c> schedules, Boolean setHoursZero) {
                
        System.debug('----- Entered rollupScheduleToAssignment');
        System.debug('----- schedules : ' + schedules.size());
        System.debug('----- setHoursZero : ' + setHoursZero);
        
        List<pse__Assignment__c> assignments = new List<pse__Assignment__c>();                        
                
        for (pse__Schedule__c schedule : [SELECT id, name, pse__Scheduled_Hours__c,
                                      		     (SELECT id, name, Scheduled_Hours_Rollup__c
                                       			    FROM pse__Assignments__r)
                                            FROM pse__Schedule__c 
                                           WHERE id IN :schedules]) {                                                      
             
             for (pse__assignment__c assign : schedule.pse__assignments__r) {   
                 System.debug('------ assign.Scheduled_Hours_Rollup__c : ' + assign.Scheduled_Hours_Rollup__c);
                 System.debug('------ schedule.pse__Scheduled_Hours__c : ' + schedule.pse__Scheduled_Hours__c);
                 if (!setHoursZero) {
                      assign.Scheduled_Hours_Rollup__c = schedule.pse__Scheduled_Hours__c == null ? 0 : schedule.pse__Scheduled_Hours__c;
                 } else {
                      assign.Scheduled_Hours_Rollup__c = 0;                                         
                 }
                 System.debug('----- assignment : ' + assign);
                 assignments.add(assign);
             }                                                                                   
        } 
        
        System.debug('----- assignments : ' + assignments.size());
        if (assignments.size() > 0) {
            try {
            update assignments;
            } catch (exception e) {
                
            }
        }
        
        System.debug('----- Exited rollupScheduleToAssignment');
        
    }
}