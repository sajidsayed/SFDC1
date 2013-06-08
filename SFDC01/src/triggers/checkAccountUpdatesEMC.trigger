/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     WR       DESCRIPTION                               
 |  ====       =========     ==       =========== 
 |29-Sep-2011     Shipra M  173667  Place Account Theater on the Opportunity into a Text Field
 22/01/2011      Accenture          Updated trigger to incorporate ByPass Logic
 |                                  NOTE: Please write all the code after BYPASS Logic                               
+===========================================================================*/

trigger checkAccountUpdatesEMC on Account (before update) {
   //Trigger BYPASS Logic
   	    if(CustomSettingBypassLogic__c.getInstance()!=null){
       System.Debug('1111--->');
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    }    
    if(Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG)return;
    Set<Id> newAccountList = Trigger.newMap.keySet();
    List<string> AccountIds= new List<string>();
    
    for(Id newAccountId:newAccountList){
        Account newAccount = Trigger.newMap.get(newAccountId);
        Account oldAccount = Trigger.oldMap.get(newAccountId);    
        // AccountIds.add(newAccount.Id);
        if(newAccount.BillingState!=oldAccount.BillingState || 
        newAccount.BillingCountry!=oldAccount.BillingCountry || 
        newAccount.BillingCity != oldAccount.BillingCity ||
        newAccount.BillingPostalCode!= oldAccount.BillingPostalCode ||
        newAccount.BillingStreet != oldAccount.BillingStreet||
        newAccount.Theater1__c != oldAccount.Theater1__c)
        {
            AccountIds.add(newAccount.Id);
        }    
    }
    //Checking if List size of AccountIDS>0 then proceed with the functionality.
    if(AccountIds!=null && AccountIds.size()>0)
    {
        List<Opportunity> oppList=[Select o.AccountId,o.AddressInformation__c,o.Account_Address__c, o.Account.BillingCity, o.Account.BillingCountry, o.Account.BillingPostalCode, o.Account.BillingState, o.Account.BillingStreet,o.Account_TheaterText__c, o.Id from Opportunity o where o.Account.Id in :AccountIds and o.closeDate>Today and o.Opportunity_Number__c!=null];    
        for(Opportunity Opp :oppList){
            String AccountAddress='';
            Account acc=Trigger.newMap.get(Opp.AccountId);
            if(acc.BillingStreet!=null){
                AccountAddress=AccountAddress+' '+acc.BillingStreet;
            }
            if(acc.BillingCity!=null){
                AccountAddress=AccountAddress+' '+acc.BillingCity;
            }
            if(acc.BillingState!=null){
                AccountAddress=AccountAddress+' '+acc.BillingState;
            }
            if(acc.BillingPostalCode!=null){
                AccountAddress=AccountAddress+' '+acc.BillingPostalCode;
            }
            if(acc.BillingCountry!=null){
                AccountAddress=AccountAddress+' '+acc.BillingCountry;
            }                 
            //173667
            Opp.Account_TheaterText__c=acc.Theater1__c;
            Util.IsTheaterUpdatedFromAccount=true;
            //*173667
            Opp.AddressInformation__c = AccountAddress;
            System.debug('Opp.Account_TheaterText__c--->'+Opp.Account_TheaterText__c+'acc.Theater1__c===>'+acc.Theater1__c);
            System.debug('Opp----->'+Opp.AddressInformation__c);
            System.debug('AccountAddresss'+AccountAddress);
            
        }
        Update oppList;
    }
  }