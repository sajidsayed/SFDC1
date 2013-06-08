/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    04-Apr-2011     Srinivas Nallapati      139074          test class for Delete_TA_Sync_Log_Batch 
                                                             
==============================================================================*/

@isTest(SeeAllData=true)
private class TC_Delete_TA_Sync_Log_Batch 
{
    static testMethod void myUnitTest() 
   {
        //Inserting Customsetting record 'TASyncDialyLimit' in DataValueMap custom settings if not found
        CustomSettingDataValueMap__c TASyncDialyLimitCSetting = CustomSettingDataValueMap__c.getInstance('TASyncDailyLimit');
        if(TASyncDialyLimitCSetting== null)
        {
            TASyncDialyLimitCSetting = new CustomSettingDataValueMap__c(name = 'TASyncDailyLimit', dataValue__c='10');
            insert TASyncDialyLimitCSetting;
        }
        
        CustomSettingDataValueMap__c TASyncDailyLimtEnabledCSetting = CustomSettingDataValueMap__c.getInstance('TASyncDailyLimtEnabledFlag');
        if(TASyncDailyLimtEnabledCSetting== null)
        {
            TASyncDailyLimtEnabledCSetting = new CustomSettingDataValueMap__c(name = 'TASyncDailyLimtEnabledFlag', dataValue__c='false');
            insert TASyncDailyLimtEnabledCSetting;
        }
        
        CustomSettingDataValueMap__c TASyncOpenRecordsCSetting = CustomSettingDataValueMap__c.getInstance('TASyncOpenRecordsLimit');
        if(TASyncOpenRecordsCSetting== null)
        {
            TASyncOpenRecordsCSetting = new CustomSettingDataValueMap__c(name = 'TASyncOpenRecordsLimit', dataValue__c='10');
            insert TASyncOpenRecordsCSetting;
        }
        
        CustomSettingDataValueMap__c TASyncOpenLimtEnabledCSetting = CustomSettingDataValueMap__c.getInstance('TASyncOpenLimtEnabledFlag');
        if(TASyncOpenLimtEnabledCSetting== null)
        {
            TASyncOpenLimtEnabledCSetting = new CustomSettingDataValueMap__c(name = 'TASyncOpenLimtEnabledFlag', dataValue__c='true');
            insert TASyncOpenLimtEnabledCSetting;
        }
        
        boolean HasAccess = false;
        Map<String,AccessOnTASyncLog__c> AccessMap = AccessOnTASyncLog__c.getAll();
        for(AccessOnTASyncLog__c ac: AccessMap.Values()) 
        {
          id i = ac.UserID__c;
          if( i == Userinfo.getUserId() && ac.EditAccess__c == true )
             HasAccess = true;
        }
        if(HasAccess == false)
        {
            AccessOnTASyncLog__c AccessCSrecord = new AccessOnTASyncLog__c(name ='TA Test User' ,UserID__c = Userinfo.getUserId(), EditAccess__c = true );
            insert AccessCSrecord;
        }    
        //End of inserting Custom Setting record
        List<TA_Sync_Log__c> exintigTAlogs = new list<TA_Sync_Log__c>();
        exintigTAlogs = [select id from TA_Sync_Log__c];
        delete exintigTAlogs;
        
        List<user> lstUser = [select id ,name ,Last_TA_Synch_Date__c from user where isActive=true AND (NOT Profile_Name__c  like '%Partner%')AND  (NOT Profile_Name__c  like '%Education Services Case Creation Profile%')AND  (NOT Profile_Name__c  like '%Deal Registration%') AND (NOT Profile_Name__c  like '%Partner%')AND (NOT Profile_Name__c  like '%EBC%')AND (NOT Profile_Name__c  like '%Presales%') AND (NOT Profile_Name__c  like '%Distributor%') AND (NOT Profile_Name__c  like '%Reseller%') AND (NOT Profile_Name__c  like '%Distribution%')and ( Last_TA_Synch_Date__c<:System.Today()-20) limit 7];
        system.debug('lstUser ===>'+lstUser );
        //Inserting ATM for defined user.
        Profiles__c profile = Profiles__c.getOrgDefaults();
        Id apiOnlyProfileId = profile.System_Admin_API_Only__c;
        List<Account> lstAccount= new List<Account>([Select id, name from account limit 6]);
        User sysAdmAPIUser=[Select id,name from User where profileId =: apiOnlyProfileId and Isactive= true limit 1];
       // TA_Sync_Log__c ta0 = new TA_Sync_Log__c(Status__c='EIS Insertions Complete'  ,Row_Count__c=5,Sales_Resource__c =lstUser[1].id );
       // insert ta0;
        List<AccountTeamMember> lstATM= new List<AccountTeamMember>();
        System.runAs(sysAdmAPIUser)
        {
            AccountTeamMember atm1= new AccountTeamMember();
            atm1.accountId= lstAccount[0].id;
            atm1.UserId= lstUser[2].id;
            atm1.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm2= new AccountTeamMember();
            atm2.accountId= lstAccount[1].id;
            atm2.UserId= lstUser[1].id;
            atm2.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm3= new AccountTeamMember();
            atm3.accountId= lstAccount[2].id;
            atm3.UserId= lstUser[1].id;
            atm3.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm4= new AccountTeamMember();
            atm4.accountId= lstAccount[3].id;
            atm4.UserId= lstUser[2].id;
            atm4.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm5= new AccountTeamMember();
            atm5.accountId= lstAccount[4].id;
            atm5.UserId= lstUser[2].id;
            atm5.teammemberrole='Sales-Sales Rep';
            
            lstATM.add(atm1);
            lstATM.add(atm2);
            lstATM.add(atm3);
            lstATM.add(atm4);
            lstATM.add(atm5);
            
            Insert lstATM;
        }
        system.debug('lstATM===>'+lstATM);
        //END of ATM insertion from API Only User.
        
        TA_Sync_Log__c ta1 = new TA_Sync_Log__c(Status__c='Open',Sales_Resource__c =lstUser[0].id );
        TA_Sync_Log__c ta2 = new TA_Sync_Log__c(Status__c='Sync Complete',Sales_Resource__c =lstUser[1].id );
        TA_Sync_Log__c ta3 = new TA_Sync_Log__c(Status__c='EIS Insertions Complete' ,Row_Count__c=5,Sales_Resource__c =lstUser[2].id );
        TA_Sync_Log__c ta4 = new TA_Sync_Log__c(Status__c='EIS Insertions Complete' ,Row_Count__c=0,Sales_Resource__c =lstUser[3].id );
        TA_Sync_Log__c ta5 = new TA_Sync_Log__c(Status__c='EIS Insertions Complete' ,Row_Count__c=10,Sales_Resource__c =lstUser[4].id );
        TA_Sync_Log__c ta6 = new TA_Sync_Log__c(Status__c='Rowcount Validated' ,Row_Count__c=5,Sales_Resource__c =lstUser[5].id );
        TA_Sync_Log__c ta7 = new TA_Sync_Log__c(Status__c='EIS Insertions Complete' ,Sales_Resource__c =lstUser[6].id );
        
        list<TA_Sync_Log__c> lstTA = new list<TA_Sync_Log__c>();
        lstTA.add(ta1);
        lstTA.add(ta2);
        lstTA.add(ta3);
        lstTA.add(ta4);
        lstTA.add(ta5);
        lstTA.add(ta6);
        lstTA.add(ta7);
        insert lstTA ;
        system.debug('lstTA-->'+lstTA);
        Datetime sysTime = System.now();
        
        Job_Scheduler__c js = new Job_Scheduler__c();
                        js.Name = 'Inbound New Schedules';
                        js.Operations__c = 'Update TA Sync Record';
                        js.Start_Date__c = date.today();
                        js.Account_Locking__c=true;
                        js.status__c= 'Pending';
                        js.Schedule_Hour__c = sysTime.hour();
                        js.Minutes__c = sysTime.minute();
                        System.debug('Job Scheduler Name = ' + js.Name);
                        insert js;
                             
        String query = 'Select Sales_Resource__c, Status__c, LastModifiedDate, OwnerId, Name, Id, Error__c, Count__c From TA_Sync_Log__c limit 200';
        List<AccountTeamMember> lstATMeafterTASYNCCreation= new List<AccountTeamMember>();
        System.runAs(sysAdmAPIUser)
        {
            AccountTeamMember atm6= new AccountTeamMember();
            atm6.accountId= lstAccount[4].id;
            atm6.UserId= lstUser[4].id;
            atm6.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm7= new AccountTeamMember();
            atm7.accountId= lstAccount[3].id;
            atm7.UserId= lstUser[3].id;
            atm7.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm8= new AccountTeamMember();
            atm8.accountId= lstAccount[2].id;
            atm8.UserId= lstUser[2].id;
            atm8.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm9= new AccountTeamMember();
            atm9.accountId= lstAccount[1].id;
            atm9.UserId= lstUser[1].id;
            atm9.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm10= new AccountTeamMember();
            atm10.accountId= lstAccount[0].id;
            atm10.UserId= lstUser[1].id;
            atm10.teammemberrole='Sales-Sales Rep';
            
            AccountTeamMember atm11= new AccountTeamMember();
            atm11.accountId= lstAccount[0].id;
            atm11.UserId= lstUser[5].id;
            atm11.teammemberrole='Sales-Sales Rep';
            
            
            lstATMeafterTASYNCCreation.add(atm6);
            lstATMeafterTASYNCCreation.add(atm7);
            lstATMeafterTASYNCCreation.add(atm8);
            lstATMeafterTASYNCCreation.add(atm9);
            lstATMeafterTASYNCCreation.add(atm10);
            lstATMeafterTASYNCCreation.add(atm11);
            
            Insert lstATMeafterTASYNCCreation;
        system.debug('lstATMeafterTASYNCCreation===>'+lstATMeafterTASYNCCreation);
        
        List<Staging_Data__c> lststgData = new List<Staging_Data__c>();
        
        Staging_Data__c stgData0 = new Staging_Data__c();
        stgData0.Object_Name__c='TASyncDelete';
        stgData0.Text1__c=lstTA[0].id;
        stgData0.Text2__c=lstATM[0].id;
        Staging_Data__c stgData1 = new Staging_Data__c();
        stgData1.Object_Name__c='TASyncDelete';
        stgData1.Text1__c=lstTA[1].id;
        stgData1.Text2__c=lstATM[1].id;
        Staging_Data__c stgData2 = new Staging_Data__c();
        stgData2.Object_Name__c='TASyncDelete';
        stgData2.Text1__c=lstTA[2].id;
        stgData2.Text2__c=lstATM[2].id;
        Staging_Data__c stgData3 = new Staging_Data__c();
        stgData3.Object_Name__c='TASyncDelete';
        stgData3.Text1__c=lstTA[3].id;
        stgData3.Text2__c=lstATM[3].id;
        Staging_Data__c stgData4 = new Staging_Data__c();
        stgData4.Object_Name__c='TASyncDelete';
        stgData4.Text1__c=lstTA[4].id;
        stgData4.Text2__c=lstATM[4].id;
        Staging_Data__c stgData5 = new Staging_Data__c();
        stgData5.Object_Name__c='TASyncDelete';
        stgData5.Text1__c=lstTA[5].id;
        stgData5.Text2__c=lstATM[0].id;
        Staging_Data__c stgData6 = new Staging_Data__c();
        stgData6.Object_Name__c='TASyncDelete';
        stgData6.Text1__c=lstTA[6].id;
        stgData6.Text2__c=lstATM[4].id;
        
        lststgData.add(stgData1);
        lststgData.add(stgData2);
        lststgData.add(stgData3);
        lststgData.add(stgData4);
        lststgData.add(stgData5);
        lststgData.add(stgData6);
        lststgData.add(stgData0);
        
        insert lststgData;
        }
       ta1.status__c='EIS Insertions Complete'; 
       update ta1;
       Test.StartTest();
       Util.isTestCoverage=true;
       Update_TA_Sync_Records_SFDC_Count TABatch = new Update_TA_Sync_Records_SFDC_Count(js,query);
       TABatch.Query = query;
       TABatch.js=js;
       //Database.executeBatch(TABatch,200);
       ID batchprocessid = Database.executeBatch(TABatch);
        /*
        //Datetime sysTime = System.now();
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        Schedule_Delete_TA_SYNC_LOG DeleteTABatch = new Schedule_Delete_TA_SYNC_LOG(js,query);
        DeleteTABatch.Query = query;
        DeleteTABatch.js=js;
        System.schedule('DeleteTABatch' + sysTime.getTime(),chron_exp,DeleteTABatch);
        // ID batchprocessiddelete = Database.executeBatch(DeleteTABatch);*/
       // Test.StopTest();
        

// varify that second scheduled id was set
//b = BatchSchedule__c.getOrgDefaults();
//System.assert(null != batchprocessid);
System.debug('lstTA===>'+lstTA);
// run second batch
//Test.startTest();
sysTime=sysTime.addSeconds(5);
String chron_exp = '' + sysTime.second()+ ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
System.schedule('testScheduledApex2', chron_exp, new Schedule_Delete_TA_SYNC_LOG(js,query));
database.executeBatch(new Delete_TA_Sync_Log_Batch(query,js));
//Test.stopTest();
        
   }
}