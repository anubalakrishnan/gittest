/********************************************************************
Author         : Mihir Kumar
Description    : The batch class calculates Ultimate Parent ID ONLY for all accounts with Hierarchy of parent Accounts to 5 levels up.
Date           : 24/Feb/2017
Action         : This calculates Ultimate Parent of Account
********************************************************************/
global class AccountUltimateParentUpdateBatch implements Database.Batchable<SObject>, Database.Stateful 
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return  Database.getQueryLocator([select id, Name, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId from Account where ParentId != null]);
    }
    global void execute(Database.BatchableContext bc, List<SObject> batch)      
    {               
        list<Account> ListAcc = new list<Account>();
        set<id> idAcc = new set<id>();  
        for (Account a : (List<Account>) batch) 
        {
           if(a.ParentId != null)
           {
              ListAcc.add(a);
              idAcc.add(a.id);            
           }                
        }

       if(ListAcc.size() > 0)
       {                                                                        
           for(Account a: ListAcc)
           {

            if(a.Parent.Parent.Parent.Parent.ParentId != null)
            {
                a.Ultimate_Parent__c = a.Parent.Parent.Parent.Parent.ParentId;
            }           
            else
            {
                if(a.Parent.Parent.Parent.ParentId != null)
                {
                    a.Ultimate_Parent__c = a.Parent.Parent.Parent.ParentId;
                }       
                else
                {
                    if(a.Parent.Parent.ParentId != null)
                    {
                        a.Ultimate_Parent__c = a.Parent.Parent.ParentId;
                    }       
                    else
                    {
                        if(a.Parent.ParentId != null)
                        {
                            a.Ultimate_Parent__c = a.Parent.ParentId;
                        }       
                        else
                        {
                            a.Ultimate_Parent__c = a.ParentId;
                        }                   
                    }               
                }           
            }                   

          }
          update ListAcc;
       }                    
    }
    global void finish(Database.BatchableContext bc) 
    {
        
    }        
}