/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  13/04/2011     Shalabh Sharma          Req#162077 This trigger used to invoke methods of PRM_PartnerOnBoarding class  
 	25 Aug 2011    Arif                    Added custom setting.                                        
 +==================================================================================================================**/
trigger authorizedResellerOnBoardingTaskTrigger on Authorized_Reseller_Onboarding_Task__c (before insert,after update) {
   PRM_PartnerOnBoardingUpdates obj = new PRM_PartnerOnBoardingUpdates();
   List<Authorized_Reseller_Onboarding_Task__c> TaskList=new List<Authorized_Reseller_Onboarding_Task__c>();
   map<string,Custom_Settings_Partner_OnBoarding__c> customSettingRecords  = Custom_Settings_Partner_OnBoarding__c.getAll();
     for(Authorized_Reseller_Onboarding_Task__c  obj1 :Trigger.New)
    {
    if(obj1.Status__c=='Complete' && obj1.Account_added_on_grouping__c && obj1.Subject__c==customSettingRecords.get('STEP6.1Americas').Task_Name__c)
        {
            TaskLIst.add(obj1);
            System.Debug('List of Grouping Task--->' +TaskLIst.size());
        }
    }
        if(Trigger.isUpdate){
            obj.updatePOBStatus(Trigger.newMap,Trigger.oldMap);
        if(TaskLIst.size()>0){

        System.debug('Hi====================<<<<<<<<<<<');
        obj.updateRelatedProfiledAccount(TaskLIst);
        }
        }
        if(Trigger.isInsert){
            obj.updateAuthorizedResellerOnboardingTaskList(Trigger.new);
        }  
}