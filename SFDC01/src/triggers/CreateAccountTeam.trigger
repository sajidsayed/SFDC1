/*===================================================================================================================================
|22/01/2011      Accenture                              Updated trigger to incorporate ByPass Logic
|                                                       NOTE: Please write all the code after BYPASS Logic 
 ===================================================================================================================================*/

trigger CreateAccountTeam on Lead (after update) {
    //Trigger BYPASS Logic
    if(CustomSettingBypassLogic__c.getInstance()!=null){
         if(CustomSettingBypassLogic__c.getInstance().By_Pass_Lead_Triggers__c){
                return;
         }
    }
    if ( UserInfo.getUserId() != '00570000001JctWAAS'){
        System.debug('Hi not Intadmin '+UserInfo.getUserId());
        System.debug('UserInfo.getUserId() != 00570000001JctWAAS' +(UserInfo.getUserId() != '00570000001JctWAAS' ));
        return;
    }else{
        System.debug('Welcome intadmin');
        CreateAccountTeam createAccTeam = new CreateAccountTeam();
        createAccTeam.createAccountTeam(Trigger.new);
    }
  
  }