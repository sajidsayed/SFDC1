/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 19/7/2010       Karthik Shivprakash     141592    This trigger is used update the account with grouping details before update.
                                                      
 | 05/08/2010      Karthik Shivprakash     Defect#70 Added the condition to cehck for grouping null and calling the remove method.
 
 | 20/08/2010      Prasad Kothawade         --        To resolve recursive update of trigger itself "SELF_REFERENCE_FROM_TRIGGER".
 | 12/09/2011      Anirudh Singh          WR3809      Updated trigger to Update Local Language fields on Deal Reg if Related Account 
 |                                                    fields are updated.
 | 18/11/2011      Suman B                IM7312572   Removed code to Update Local Language fields on Deal Reg if Related Account
 |                                                    fields are updated. 
   22/01/2012      Accenture                          Updated trigger to incorporate ByPass Logic
 |                                                    NOTE: Please write all the code after BYPASS Logic. 
 
 | 03-Feb-2012     Anand Sharma                       Added code to nullify partner leverage fields on account
                                                      when rating eligible flag is unchecked

   28-Dec-2012      Smitha Thomas     213868      Added code for CQR field update when the record is being updated
   18 Mar 2013      Avinash Kaltari     239205      Added a condition before the AP_AccountBeforeUpdate.updateCoreQuotaRep method is called.
                                                    The condition checks for a global static boolean variable from a batch class, if true 
                                                    i.e. if the trigger is invoked from the batch class (AP_AssignCQRtoAccount), 
                                                    it does not make the method call, else it makes the method call.
 +===========================================================================*/


trigger AccountBeforeUpdate on Account (before update) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    } 
     if(Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG)return;
     Account[] oldAccs = Trigger.old;
     Account[] newAccs = Trigger.new;
     List<Account> lstAccounttoUpdate = New list<Account>();
     Map<Id,Account> accountsWithGroupingId = new Map<Id,Account>();
     PRM_GroupingOfAssignment Obj = new PRM_GroupingOfAssignment();
     PRM_DEALREG_UpdateLocalFieldsOnDR objAccount = new PRM_DEALREG_UpdateLocalFieldsOnDR();
    if(PRM_GroupingOfAssignment.PartnerGroupingCreation){
        return;
    }
    else{
        System.debug('I am in account trigger');
        Map<String,String> accountsToUpdate= new Map<String,String>(); //Map  which contains SITE_DUNS/ENTITY_ID along with Grouping Name
        List<Account>accounts=new List<Account>();
        Set<Id> accountsID = new Set<Id>();
        Set<Id> newGroupingIds = Obj.validate(Trigger.newMap,Trigger.oldMap,Trigger.newMap.keySet());
        System.debug('Account after validation'+newGroupingIds);
        Set<String> siteDuns = new Set<String>();
        if(newGroupingIds.size()>0){
            for(Id newAccountId: newGroupingIds){
                Account newAccountValue = Trigger.newMap.get(newAccountId);
                System.debug('New value of Group'+newAccountValue );
                Account oldAccountValue = Trigger.oldMap.get(newAccountId);
                System.debug('Old value of Group'+oldAccountValue );
                //Defect#70 changed the condition of checking newValue.Grouping!=null
                if(newAccountValue.Grouping__c!=oldAccountValue.Grouping__c && newAccountValue.PROFILED_ACCOUNT_FLAG__c==false ){ //comparing old value with new value of grouping
                    /*if(newAccountValue.Grouping__c==null){
                        newAccountValue.Grouping_Batch_Operation__c = 'Grouping Nullified';
                    }*/
                    accountsToUpdate.put(newAccountValue.Id,newAccountValue.Grouping__c);
                    accounts.add(newAccountValue);
                    //Defect#70 Added the condition to call the remove method on accounts.
                    if(newAccountValue.Grouping__c==null){
                        accountsID.add(newAccountValue.Id);
                        siteDuns.add(newAccountValue.Site_DUNS_Entity__c);
                    }
                }
            }
        }
        if(accountsToUpdate.size()>0){
            Obj.updateAccounts(accountsToUpdate,accounts); 
        }
        if(siteDuns.size()>0 && accountsID.size()>0){
            Obj.removeGroupingFromAccount(siteDuns,accountsID);
        }
        //Commented to resolve the recursive update of trigger to itself "SELF_REFERENCE_FROM_TRIGGER".
        //AccountBeforeUpdateTrigger updateTrigger = new AccountBeforeUpdateTrigger ();
        //updateTrigger.beforeUpdate(oldAccs,newAccs);
    

    
    }
    /*Populate local address fields on Deal Reg from related account*/
     // Commented the code and checking the condtion in afterUpdate Trigger --IM7312572
    /*
    Map<Id,Account> mapAccount = new Map<Id,Account>();
    for(Account account : trigger.newMap.values()){
        if(account.Address_Local__c != trigger.oldMap.get(account.Id).Address_Local__c || 
           account.City_Local__c != trigger.oldMap.get(account.Id).City_Local__c ||
           account.Country_Local__c != trigger.oldMap.get(account.Id).Country_Local__c ||
           account.State_Province_Local__c != trigger.oldMap.get(account.Id).State_Province_Local__c ||
           account.Street_Local__c != trigger.oldMap.get(account.Id).Street_Local__c ||
           account.NameLocal!= trigger.oldMap.get(account.Id).NameLocal||                 
           account.Zip_Postal_Code_Local__c != trigger.oldMap.get(account.Id).Zip_Postal_Code_Local__c ||
           account.EMC_Classification__c!=trigger.oldMap.get(account.Id).EMC_Classification__c){
            mapAccount.put(account.Id,account);
        }   
    }
    if(mapAccount.keyset().size()>0){        
        objAccount.updateAddressOnDR(mapAccount);
    } */    
    for (integer i = 0 ; i < trigger.New.size(); i++){
         if(trigger.new[i].RecordTypeId != trigger.old[i].RecordTypeId){
            lstAccounttoUpdate.add(trigger.new[i]); 
         }
         //Added by anand to nullify Partner Lev factor once account changed to rating eligible false.
         if(trigger.new[i].Rating_Eligible__c== false  ){
            trigger.new[i].Partner_Leverage_Factor_Total__c = null;
            trigger.new[i].Partner_Leverage_Factor_Average__c = null;
         }
    }
    if (lstAccounttoUpdate.size()>0){
        objAccount.updateAccountType(lstAccounttoUpdate);
    }

    
//system.debug('#### Batch Code variable :: '+AP_AssignCQRtoAccount.blnBatchInvocation);

    if (Trigger.isBefore && Trigger.isUpdate && Trigger.New != null && !AP_AssignCQRtoAccount.blnBatchInvocation) 
    {        
        for (integer i = 0 ; i < trigger.New.size(); i++)
        {
            if(trigger.new[i].Core_Quota_Rep__c != trigger.old[i].Core_Quota_Rep__c)
            {
                AP_AccountBeforeUpdate.updateCoreQuotaRep(Trigger.NewMap, Trigger.OldMap);
            }
        }
    }

  }