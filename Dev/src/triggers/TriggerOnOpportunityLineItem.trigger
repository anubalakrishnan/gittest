trigger TriggerOnOpportunityLineItem on OpportunityLineItem (after update) {
    
    if (CustomUtilityClass.runTriggerOnce) {
    
    System.debug('----- Entered TriggerOnOpportunityLineItem');       
    List<Opportunitylineitem> listofolirec = new List<Opportunitylineitem>();
    Set<String> oppSet = new Set<String>();
    Set<String> productSet = new Set<String>();
    Set<String> oliSet = new Set<String>();
    for (OpportunityLineItem oli : Trigger.NEW) {
        oppSet.add(oli.OpportunityId);
        productSet.add(oli.Product2Id);
        oliSet.add(oli.ID);
    }
    System.debug('----- oppSet : ' + oppSet.size());
    System.debug('----- productSet : ' + productSet.size());
    System.debug('----- oliSet : ' + oliSet.size());
    
    Map<String,String> oliBudgetMap = new Map<String,String>();
    for (pse__Budget__c budget : [SELECT id, oli_id__c, product__c
                                    FROM pse__Budget__c
                                   WHERE oli_id__c IN :oliSet]) {
        oliBudgetMap.put(budget.oli_id__c, budget.ID);                              
    }
    System.debug('----- oliBudgetMap : ' + oliBudgetMap.size());     
    
    Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
    for (Opportunity opp : [SELECT id, name, Shell_Project_Created__c, RecordType.Name, AccountID, pse__Primary_Project__c
                              FROM Opportunity
                            WHERE ID IN :oppSet]) {
         oppMap.put(opp.ID, opp);                       
    }
    System.debug('----- oppMap : ' + oppMap.size());
    
    Map<String,Product2> productMap = new Map<String,Product2>();
    for (Product2 product : [SELECT ID, name, Family, Description
                               FROM Product2
                              WHERE ID IN :productSet]) {
         productMap.put(product.ID, product);                       
    }
    System.debug('----- productMap : ' + productMap.size());

    List<pse__Budget__c> budgets = new List<pse__Budget__c>();
    
    for (OpportunityLineItem oli : Trigger.NEW) {
        System.debug('Creation =='+ oli.Budget_Created__c  + '==verbal commit val==' + oli.IsOppVerbalCommit__c);
        Opportunity opp = oppMap.get(oli.OpportunityId);
        System.debug('Opportunity : ' + opp);
        
        Product2 product = productMap.get(oli.Product2Id);
        System.debug('Product : ' + product);
                        
        if ((!oli.Budget_Created__c && oli.IsOppVerbalCommit__c) ||
            (oliBudgetMap.get(oli.ID) != null)) { 
            
            pse__Budget__c budget = new pse__Budget__c();
            if (oliBudgetMap.get(oli.ID) != null) 
                budget.ID = oliBudgetMap.get(oli.ID);
            budget.Auto_Created__c = TRUE;            
            budget.Expected_Cost__c = oli.Total_cost__c;
            budget.Expected_Margin__c = oli.Internal_True_Margin_Percent__c;
            budget.Hours_Booked__c = oli.Total_Hours__c;
            budget.Management_Personnel__c = (product.family == 'Management') ? TRUE : FALSE;
            budget.Name = product.Description;
            budget.OLI_ID__c = oli.ID;
            budget.OLI_Sync_Timestamp__c = System.now();
            budget.Product_Description__c = oli.Description;
            budget.Product__c = oli.Product2Id;
            budget.Quantity__c = oli.Quantity;
            budget.Start_Date__c = oli.Start_Date__c;
            budget.End_Date__c = oli.End_Date__c;
            budget.Total_Bonus__c = oli.Total_Bonus__c;
            budget.Total_Car_Allowance__c = oli.Total_Car_Allowance__c;
            budget.Total_Comm__c = oli.Total_Comm__c;
            budget.Total_Holiday_Hours_Cost__c = oli.Total_Holiday_Hours_Cost__c;
            budget.Total_Hourly_Incentive_Costs__c = oli.Total_Holiday_Incentive_Costs__c;
            budget.Total_KM_Mileage__c = oli.Total_KM_Mileage__c;
            budget.Total_Meals__c = oli.Total_Meals__c;
            budget.Total_OT_Hours_Cost__c = oli.Total_OT_Hour_Costs__c;
            budget.Total_Parking__c = oli.Total_Parking__c;
            budget.Total_Regular_Execution_Hour_Costs__c = oli.Total_Regular_Execution_Hour_Costs__c;
            budget.Total_Supplies_Expense__c = oli.Total_Supplies_Expense__c;
            budget.Total_Training_Hour_Costs__c = oli.Total_Training_Hour_Costs__c;
            budget.pse__Account__c = opp.AccountID;
            budget.pse__Amount__c = oli.TotalPrice;
            budget.pse__Approved__c = TRUE;
            budget.pse__Description__c = (oli.Client_Description__c == null) ? '' : oli.Client_Description__c;
            budget.pse__Opportunity__c = oli.OpportunityId;
            budget.pse__Project__c = opp.pse__Primary_Project__c;
            budget.pse__Status__c = 'Approved';
            budget.pse__Type__c = 'Customer Purchase Order';
              
            budgets.add(budget);
            System.debug('----- Budget to upsert : ' + budget);
            
        }     
        if(budgets.size() > 0 && !oli.Budget_Created__c){
        System.debug('Budget created once==' + oli.Budget_Created__c);
            Opportunitylineitem olirec = new Opportunitylineitem(id= oli.id);
            olirec.Budget_Created__c = true;
            listofolirec.add(olirec);
        }   
    }
    
    System.debug('----- All budgets to be upserted : ' + budgets);
    upsert budgets;
    System.debug('----- Exited TriggerOnOpportunityLineItem');
    update listofolirec;    
    CustomUtilityClass.runTriggerOnce = FALSE;
    }
}