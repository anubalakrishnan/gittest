/********************************************************************
Author   :Mihir Kumar
Date     :3/March/2017
Action   :This is handler class of trigger 'TriggerOnOpportunity'
********************************************************************/

public class OpportunityTriggerHandler {
    
    // This method checks if opportunity stage was set to Closed Won
    // and creates milestone records
    public void createMilestones(List<Opportunity> newOpp, Map<ID,Opportunity> oldOppMap) {
        
        System.debug('----- Entered createMilestones method');
        
        Boolean runMethod = FALSE;
        for (Opportunity opp : newOpp) {
            if (opp.StageName != oldOppMap.get(opp.ID).StageName && opp.StageName != NULL && opp.StageName == 'Closed Won') {
                runMethod = TRUE;
            }
        }
        
        if (runMethod) {
        
            // Get primary oracle quote for opportunities
            Map<ID, BigMachines__Quote__c> oppQuoteMap = new Map<ID, BigMachines__Quote__c>();
            for (BigMachines__Quote__c quote : [SELECT ID, Name, Provincial_Tax_To_Apply__c, Agency_Fees_Billing_Schedule__c, 
                                                BigMachines__Opportunity__c
                                                  FROM BigMachines__Quote__c
                                                 WHERE BigMachines__Is_Primary__c = TRUE
                                                   AND BigMachines__Opportunity__c IN :newOpp]) {
                 oppQuoteMap.put(quote.BigMachines__Opportunity__c, quote);                                   
            }
            
            System.debug('----- oppQuoteMap : ' + oppQuoteMap.size());
            
            Set<String> accountSet = new Set<String>();
            for (Opportunity opp : newOpp) {
                accountSet.add(opp.AccountId);
            }
            
            // Populate account info map
            Map<ID,Account> accountMap = new Map<ID,Account>();
            for (Account acc : [SELECT ID, Name, PO_Required_for_Billing__c, ERP_Unique_ID__c 
                                  FROM Account
                                 WHERE ID IN :accountSet]) {                                    
                 accountMap.put(acc.ID, acc);                       
            }
            
            System.debug('----- accountMap : ' + accountMap.size());
            
            List<pse__milestone__c> milestoneList = new List<pse__milestone__c>();
            
            for (Opportunity opp : newOpp) {
                
                // Check if opportunity has been changed to closed won
                if (opp.StageName != oldOppMap.get(opp.ID).StageName && opp.StageName != NULL && opp.StageName == 'Closed Won') {
                    
                    // if opp quote exists
                    if (oppQuoteMap.get(opp.ID) != NULL) {
                        
                        BigMachines__Quote__c quote = oppQuoteMap.get(opp.ID);
                        System.debug('Primary quote : ' + quote);
                        
                        // Check if milestone info exists
                        if((!(String.isBlank(quote.Agency_Fees_Billing_Schedule__c))) && (quote.Agency_Fees_Billing_Schedule__c!=Null) && (quote.Agency_Fees_Billing_Schedule__c!='')){
                            if (quote.Agency_Fees_Billing_Schedule__c.trim().length() > 0) {
                                
                                List<String> milestoneRecords = quote.Agency_Fees_Billing_Schedule__c.split('##');
                                System.debug('----- milestoneRecords : ' + milestoneRecords.size());
                                
                                if (milestoneRecords != NULL && milestoneRecords.size() > 0) {
                                    
                                    for (String milestoneRecord : milestoneRecords) {
                                        
                                        List<String> milestoneFields = milestoneRecord.split('@@');
                                        System.debug('----- milestoneFields : ' + milestoneFields.size());
                                        
                                        // Build milestone records
                                        pse__Milestone__c milestone = new pse__Milestone__c();
                                        milestone.Milestone__c = Decimal.valueOf(milestoneFields[0]);
                                        milestone.name = milestoneFields[1];
                                        milestone.pse__Target_Date__c = Date.valueOf(milestoneFields[2]);
                                        milestone.Terms__c = milestoneFields[3];
                                        //milestone.pse__Actual_Date__c = Date.valueOf(milestoneFields[4]);
                                        milestone.pse__Milestone_Amount__c = Decimal.valueOf(milestoneFields[6]);
                                        milestone.Tax_Amount__c = Decimal.valueOf(milestoneFields[7]);
                                        milestone.Total_Amount__c = Decimal.valueOf(milestoneFields[8]);
                                        milestone.pse__Status__c = 'Approved';
                                        milestone.PO_Required_for_Billing__c = accountMap.get(opp.AccountID).PO_Required_for_Billing__c;
                                        //milestone.ERP_Unique_ID__c = accountMap.get(opp.AccountID).ERP_Unique_ID__c;
                                        milestone.Account__c = opp.AccountID;
                                        milestone.pse__Project__c = opp.pse__Primary_Project__c;
                                        if(oppQuoteMap.get(opp.ID).Provincial_Tax_To_Apply__c!=Null && oppQuoteMap.get(opp.ID).Provincial_Tax_To_Apply__c!='')
                                            milestone.Province_of_Billing__c = oppQuoteMap.get(opp.ID).Provincial_Tax_To_Apply__c;
                                        milestoneList.add(milestone);
                                    }
                                }                                                
                            }  
                        }
                    }
                    
                }
            
            }
            
            // Insert milestone records 
            if (milestoneList.size() > 0)
                insert milestoneList;
            
            System.debug('----- Exited createMilestones method');
        }
    }
}