/*================================================================================
Name     WR       Description
Prasad    -       This trigger hnadles only lead before update event
22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                        NOTE: Please write all the code after BYPASS Logic  
===================================================================================*/

trigger LeadOnDelete on Lead (before delete) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
    }
       new PRM_DealReg_Operations().takeAwayDelete(Trigger.old);
    }