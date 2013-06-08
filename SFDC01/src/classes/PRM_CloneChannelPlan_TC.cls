/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER          WR       DESCRIPTION                               

 |  ====          =========          ==       =========== 

 |  23/2/2011     Shalabh Sharma              Coverage class of PRM_CloneChannelPlan
 |	14/12/2011		Anil					 Used Custom Setting Data helper class
                                                                                        
 +==================================================================================================================**/
@isTest
  private class PRM_CloneChannelPlan_TC {
  
     static testMethod void myUnitTest(){
      User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
      /* creating Channel Account Plan record */ 
         SFDC_Channel_Account_Plan__c channelAccountPlan = new SFDC_Channel_Account_Plan__c (Name = 'UNITTESTCAP', Status__c = 'New');

         Insert channelAccountPlan;
         
              
         
         List<SFDC_Channel_Account_Plan__c> lstCAP = new List<SFDC_Channel_Account_Plan__c>();
         lstCAP.add(channelAccountPlan);
                            
      /* creating Objective record */     
         SFDC_Objective__c objective = new SFDC_Objective__c (Name = 'UNITTESTObj', Channel_Account_Plan__c = channelAccountPlan.Id);
         Insert objective;
     
     /* creating Strategy record */     
         Strategy__c strategy = new Strategy__c (Name = 'UNITTESTStrategy', Channel_Plan__c = channelAccountPlan.Id,Additional_Information__c='Test information');
         Insert strategy;       
         
       Test.startTest();
         String strClone =channelAccountPlan.Id;
         strClone = strClone.substring(0, 15);
         SFDC_Channel_Account_Plan__c testCAP = new  SFDC_Channel_Account_Plan__c(Name = 'UNITTESTCAP',Status__c ='New',Clone__c = strClone);
       //SFDC_Channel_Account_Plan__c testCAP = new  SFDC_Channel_Account_Plan__c(Clone__c = channelAccountPlan.Id);
       Insert testCAP;
       PRM_CloneChannelPlan obj = new PRM_CloneChannelPlan();
       //obj.cloneobjectives(lstCAP);
       Test.stopTest();
         
       }
    }