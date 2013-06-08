/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 | 29/12/2011     Leoanrd Victor          Trigger for populating Presales_Account__c object bassed on account creation and updation
   22/01/2011     Accenture               Updated trigger to incorporate ByPass Logic
 |                                        NOTE: Please write all the code after BYPASS Logic 
                                                                                  
 +==================================================================================================================**/
trigger Presales_afterInsertUpdateOfAccount on Account (after insert,after update) {
  //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
       System.Debug('1111--->');
       if(CustomSettingBypassLogic__c.getInstance().By_Pass_Account_Triggers__c){
                return;
       }
    }
    List<Account> lstPresalesAcc = new List<Account>();
    List<Account> lstNewAcc = Trigger.new;
    
    Presales_Account_Operation preAccObj = new Presales_Account_Operation();
    // Iteration based on Trigger.new values and calling the insert method for Presales_Account__c insertion 
     if(trigger.isAfter && trigger.isInsert){
        
        for(Account acc : lstNewAcc){
            
            if(acc.Synergy_Account_Number__c!=null){
                lstPresalesAcc.add(acc);
            }
            
        }
        preAccObj.insertPresalesAccount(lstPresalesAcc);
     }


    if(trigger.isAfter && trigger.isUpdate){
    // Iteration based on Trigger.new values and calling the update method for Presales_Account__c insertion 
        for(Account acc : lstNewAcc){
            if(acc.Synergy_Account_Number__c!=Trigger.oldMap.get(acc.id).Synergy_Account_Number__c){
                lstPresalesAcc.add(acc);
                
            }
            
        }
            preAccObj.updatePresalesAccount(lstPresalesAcc);
     }
   }