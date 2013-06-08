/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR         DESCRIPTION                               

 |  ====          =========      ==         =========== 

 |  22/12/2010    Ashwini Gowda  Req# 1155  Test class for allow partners users
                                            and CAMs to access the channel account plan.
 |  01/03/2011    Anil Sure     2430        udpated the code for EMC channel User profile name used    

 |  23-Jul-2011   Anand Sharma              Updated email field value of user record creation
 |  28-Sep-2011   Anil                      Created Account record instead of fetching using Query
 |  11-JAN-2012   Anil                      Removed role Id
 |=============================================================================================================== */

@isTest
Private Class PRM_CAPVisibility_TC{
    Private static testMethod void startTest(){ 
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String AmericasDistributorCAP = data.get('AmericasDistributorCAP').DataValue__c;
        String AmericasResellerCAP = data.get('AmericasResellerCAP').DataValue__c;
        String APJDistributorCAP = data.get('APJDistributorCAP').DataValue__c;
        String APJResellerCAP = data.get('APJResellerCAP').DataValue__c; 
        String EMEADistributorCAP = data.get('EMEADistributorCAP').DataValue__c;
        String EMEAResellerCAP = data.get('EMEAResellerCAP').DataValue__c;
        String AmericasObjective = data.get('AmericasObjective').DataValue__c;
        String APJObjective = data.get('APJObjective').DataValue__c;
        String EMEAObjective = data.get('EMEAObjective').DataValue__c; 
        
        String AmericasStrategy = data.get('AMERStrategy').DataValue__c;
        String APJStrategy = data.get('APJStrategy').DataValue__c;
        String EMEAStrategy = data.get('EMEAStrategy').DataValue__c;      
    
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
           insert acc;
           Contact cont = UserProfileTestClassDataHelper.createContact();
           cont.AccountId=acc[0].Id;
           insert cont;
           User PartnerUser;
           System.runAs(insertUser)
            {       
           String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
           //contact con = [Select Id,Name from Contact where id='0037000000sMZmP'];
           
           Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
           //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
           PartnerUser = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
           insert PartnerUser;
            }
        //Added By Anil
        PRM_NotificationToAccountOwners sendNotification = new PRM_NotificationToAccountOwners();
        // My code
        sendNotification.updateProfiledAccountsForAPJEMEA();
        sendNotification.updateProfiledAccountsForAmericas();
        
        // My code
        
        List<Account> partnerAccount=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        
        insert partnerAccount[0];
        partnerAccount[0].isPartner=true;
        partnerAccount[0].PROFILED_ACCOUNT_FLAG__c=true;
        update partnerAccount[0];
        Account_Groupings__c grouping = AccountAndProfileTestClassDataHelper.createAccountGrouping(partnerAccount[0].Id);
        insert grouping; 
                 
        User EMCUser1;
        SFDC_Channel_Account_Plan__c channelPlan1;
        SFDC_Channel_Account_Plan__c channelPlan2;
        SFDC_Channel_Account_Plan__c channelPlan3;
        SFDC_Channel_Account_Plan__c channelPlan4;
        SFDC_Channel_Account_Plan__c channelPlan5;
        SFDC_Channel_Account_Plan__c channelPlan6;
        list<SFDC_Channel_Account_Plan__c> channelPlanList = new List<SFDC_Channel_Account_Plan__c>();
        SFDC_Objective__c objective1;
        SFDC_Objective__c objective2;
        SFDC_Objective__c objective3;
        
        Strategy__c strategy1;
        Strategy__c strategy2;
        Strategy__c strategy3;
                  
        
        System.runAs(insertUser){
            EMCUser1 = createUser('AMER Channels User');//Changed from EMC Channel User By Anil
            System.debug('EMC user'+EMCUser1);
        }
         System.runAs(EMCUser1){
        Test.startTest();

        //Create CAPs of all RecordType Ids
        
            channelPlan1 = createChannelPlan(EMCUser1.id,'ChannelPlan1',
                                            PartnerUser.id,partnerAccount[0].id,AmericasDistributorCAP);
            channelPlanList.add(channelPlan1);                              
            channelPlan2 = createChannelPlan(EMCUser1.id,'ChannelPlan2',
                                            PartnerUser.id,partnerAccount[0].id,APJDistributorCAP); 
            channelPlanList.add(channelPlan2);                                                                             
            channelPlan3 = createChannelPlan(EMCUser1.id,'ChannelPlan3',
                                            PartnerUser.id,partnerAccount[0].id,EMEADistributorCAP);
            channelPlanList.add(channelPlan3);                                             
            channelPlan4 = createChannelPlan(EMCUser1.id,'ChannelPlan4',
                                            PartnerUser.id,partnerAccount[0].id,AmericasResellerCAP);
            channelPlanList.add(channelPlan4);                                  
            channelPlan5 = createChannelPlan(EMCUser1.id,'ChannelPlan5',
                                            PartnerUser.id,partnerAccount[0].id,APJResellerCAP);
            channelPlanList.add(channelPlan5);                                  
            channelPlan6 = createChannelPlan(EMCUser1.id,'ChannelPlan6',
                                            PartnerUser.id,partnerAccount[0].id,EMEAResellerCAP);
            channelPlanList.add(channelPlan6);                                  
                                                                                                                        
         objective1 = createObjective(channelPlan1.id,'Objective1',AmericasObjective);
         objective2 = createObjective(channelPlan2.id,'Objective2',APJObjective);
         objective3 = createObjective(channelPlan3.id,'Objective3',EMEAObjective);
         
         strategy1 = createstrategy(channelPlan1.id,'strategy1',AmericasStrategy); 
         strategy2 = createstrategy(channelPlan2.id,'strategy2',APJStrategy);
         strategy3 = createstrategy(channelPlan3.id,'strategy3',EMEAStrategy );  
        sendNotification.updateQtrNotificationDateOnCAP();
                
         }
        System.assertEquals(AmericasDistributorCAP,channelPlan1.RecordTypeId);
        System.assertEquals(APJDistributorCAP,channelPlan2.RecordTypeId); 
        System.assertEquals(EMEADistributorCAP,channelPlan3.RecordTypeId);  
        System.assertEquals(AmericasResellerCAP,channelPlan4.RecordTypeId);
        System.assertEquals(APJResellerCAP,channelPlan5.RecordTypeId); 
        System.assertEquals(EMEAResellerCAP,channelPlan6.RecordTypeId);  
        
        System.assertEquals(AmericasObjective,objective1.RecordTypeId);
        System.assertEquals(APJObjective,objective2.RecordTypeId); 
        System.assertEquals(EMEAObjective,objective3.RecordTypeId);
        //Update the CAP Status to Approved
        Map<String,Schema.RecordTypeInfo> recordTypes = Task.sObjectType.getDescribe().getRecordTypeInfosByName(); 
        Id TaskRecTypeId = recordTypes.get('Master Record Type').getRecordTypeId(); 
        
        Task task1 = createTask(objective2.id,TaskRecTypeId);
        
        Map<String,Schema.RecordTypeInfo> eventRecordTypes = Event.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id EventRecTypeId = eventRecordTypes.get('Standard Event').getRecordTypeId();
        
        Event event1 = createEvent(objective2.id,EventRecTypeId);
        
        channelPlan1.Status__c='Approved';
        update channelPlan1;
        
        channelPlan2.Status__c='Approved';
        update channelPlan2;
        
        channelPlan3.Status__c='Approved';
        update channelPlan3;    
        
        channelPlan4.Status__c='Approved';
        update channelPlan4;
        
        channelPlan5.Status__c='Approved';
        update channelPlan5;
        
        channelPlan6.Status__c='Approved';
        update channelPlan6;
        
       /* channelPlan1.Lock_CAP__c = true;
        update channelPlan1;
        */
        
        Test.stopTest();
       
        
        Map<Id,Task> TaskDetails = new Map<Id,Task>();
        TaskDetails.put(channelPlan2.id,task1);
        
        Map<Id,Event> EventDetails = new Map<Id,Event>();
        EventDetails.put(channelPlan2.id,event1);
        
        Set<Id> channelplanId = new Set<Id>();
        channelplanId.add(channelPlan2.id);
        channelplanId.add(channelPlan3.id);
        
        PRM_ActivityLockonCAP activityLock = new PRM_ActivityLockonCAP();
        activityLock.getTaskErrorMessage(TaskDetails,channelplanId);
        activityLock.getEventErrorMessage(EventDetails,channelplanId);
        

        List<Account> profiledAccounts = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert profiledAccounts;
        for(Account profiledAccount :profiledAccounts){
            profiledAccount.CAP_Required__c='Yes';
        }
        update profiledAccounts;
        sendNotification.updateProfiledAccountsForAPJEMEA();
        sendNotification.updateProfiledAccountsForAmericas();
        
        
        System.runAs(EMCUser1){
            for(SFDC_Channel_Account_Plan__c channelPlan :channelPlanList){
                channelPlan.Lock_CAP__c=false;
            }
            update channelPlanList;
        }
        
    }
    
/* @Method <This method is used create user for the test class>.   
    @param <Taking Id and String as paramters which contains newly created             
    contactId and profileName>   
    @return <void> - <User record>   
    @throws exception - <No Exception>
    */
    private static User createUser(String Profilename){
        Profile emcUser = [select Id from Profile where Name=:Profilename]; 
        System.Debug('emcUser '+emcUser);       
        UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='IIG APJ'];        
        User tempUsr = new User(
             Username='testing123'+Math.random()+'@acme4.com.test34',
             TimeZoneSidKey='America/New_York',
             ProfileId = emcUser.Id,
             FirstName='TestingCAP',
             LastName='LastCAP',
             email='john12456@emc.com',
             Alias='test1',             
             LocaleSidKey='en_US',             
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Role__c='N/A',
             UserRoleId=userRoles.Id,
             Forecast_Group__c='Direct',
             BU__c='NA',
             CAP_Approver__c=true,
             IsActive=true);
        insert tempUsr;    
        return tempUsr;
    }
    /* @Method <This method is used create CAP for the test class>.   
    @param <Taking Name and RecordType Id has  parameters>   
    @return <CAP> - <CAP record>   
    @throws exception - <No Exception>
*/    
    public static SFDC_Channel_Account_Plan__c createChannelPlan(Id emcApprover,String CAPName,
                                    Id PartnerApprover,Id PartnerAccount,String RecordTypeId){  
        SFDC_Channel_Account_Plan__c channelPlan = new SFDC_Channel_Account_Plan__c( 
        Active__c = true,
        EMC_Sales_Mgt_Approver__c = emcApprover,
        Partner_Approver__c = PartnerApprover,
        Name = CAPName,
        Partner_Account__c = PartnerAccount,
        Plan_Period__c = 'Q1',
        Status__c = 'New', 
        RecordTypeId = RecordTypeId,
        EMC_CAM__c = emcApprover,
        Plan_End__c = System.today()); 
        insert channelPlan;        
        return channelPlan;    
    }    
    
/* @Method <This method is used create CAP for the test class>.   
    @param <Taking Name and RecordType Id has  parameters>   
    @return <CAP> - <CAP record>   
    @throws exception - <No Exception>
*/    
    public static SFDC_Objective__c createObjective(Id channelPlanId,String ObjectiveName,
                                                                String RecordTypeId){  
        SFDC_Objective__c objective = new SFDC_Objective__c( 
        Name = ObjectiveName,
        Channel_Account_Plan__c = channelPlanId,
        RecordTypeId = RecordTypeId); 
        insert objective;        
        return objective;    
    }
    
/* @Method <This method is used create strategy date for the test class>.   
    @param <Taking Name and RecordType Id as  parameters>   
    @return <Strategy> - <strategy record>   
    @throws exception - <No Exception>
*/    
    public static Strategy__c createStrategy(Id channelPlanId,String StrategyName,
                                                                String RecordTypeId){  
        Strategy__c strategy= new Strategy__c( 
        Name = StrategyName,
        Channel_Plan__c = channelPlanId,
        RecordTypeId = RecordTypeId); 
        insert strategy;        
        return strategy;    
    }

/* @Method <This method is used create Task for the test class>.   
    @param <Taking Objective Id has  parameters>   
    @return <Task> - <Task record>   
    @throws exception - <No Exception>
*/    
   public static Task createTask(Id WhatId,Id TaskRecTypeId){                       
        Task task = new Task( 
        ReminderDateTime = System.now(),
        WhatId = WhatId,
        Subject = 'TestTask',
        Type = 'Power Day',
        RecordTypeId = TaskRecTypeId); 
        insert task;        
        return task;    
    }  
    
/* @Method <This method is used create Event for the test class>.   
    @param <Taking Objective Id has  parameters>   
    @return <Event> - <Event record>   
    @throws exception - <No Exception>
*/    
   public static Event createEvent(Id WhatId,Id EventRecTypeId){             
        Event event = new Event( 
        WhatId = WhatId,
        Subject = 'TestTask',
        Type = 'Power Day',
        RecordTypeId = EventRecTypeId,
        DurationInMinutes = 30,
        ActivityDateTime = System.now()); 
        insert event;        
        return event;    
    }     
}