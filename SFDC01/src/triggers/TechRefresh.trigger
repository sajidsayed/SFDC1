/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/
trigger TechRefresh on Lead (before insert, before update) {
    //Trigger BYPASS Logic
  if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
        return;
  }
    for(Lead ld : trigger.new){
        if(ld.Originator_Details__c != null && ld.DealReg_Deal_Registration__c == false)
            if(ld.Originator_Details__c.contains('Tech Refresh'))
                ld.recordTypeID = '01270000000Q7yb';
    }
  }