/*======================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER            WR              DESCRIPTION                               

|  ====          =========            ==              =========== 

| 12-Apr-2011    Srinivas Nallapati   139074        This trigger is invoked 
                                                    after insert which restrains creation of records 
                                                    if there already exists a record with same 
                                                    Sales Resource and was created within last 7 days.
  23 Dec 2011    Arif                               Removed hard coding
  20 Jul-2012    Anand Sharma         194847        Update according to WR      
| 30 Aug-2012    Anand Sharma         194847        Backout to code for TOP OFFENDER ristriction
  27 Nov 2012  Avinash Kaltari  212738    Added code to set the status of TOP OFFENDER Sales Resource Logs to "Error"
+======================================================================================*/
trigger Validate_TA_Sync_Log_Creation on TA_Sync_Log__c (before insert,before update, after update) 
{
    Profiles__c profile = Profiles__c.getOrgDefaults();
    Id apiOnlyProfileId = profile.System_Admin_API_Only__c;    

    Map<Id, List<AccountTeamMember>> mapAccountTeamMember = new Map<Id, List<AccountTeamMember>>();
    
    if(Trigger.isInsert)
    {
        Boolean HasAccess = true;
        List<TA_Sync_Log__c> TodayCreatedList = new List<TA_Sync_Log__c>();
        List<TA_Sync_Log__c> OpenStatusList = new List<TA_Sync_Log__c>();
        //Number of TA Sync Records created today
        TodayCreatedList = [select Sales_Resource__c from  TA_Sync_Log__c where createddate>:system.today() ];
        //Number of TA Sync Records in open status
        OpenStatusList = [select Sales_Resource__c from  TA_Sync_Log__c where status__c='Open'];
        
        Map<String,CustomSettingDataValueMap__c>  mapDataValueMap = CustomSettingDataValueMap__c.getAll();
        integer DailyLimit = integer.valueOf(mapDataValueMap.get('TASyncDailyLimit').datavalue__c);
        integer OpenRecordsLimit = integer.valueOf(mapDataValueMap.get('TASyncOpenRecordsLimit').datavalue__c);
        String EnableDailyLimit = mapDataValueMap.get('TASyncDailyLimtEnabledFlag').datavalue__c;
        String EnableOpenLimit = mapDataValueMap.get('TASyncOpenLimtEnabledFlag').datavalue__c ;
        //integer TopOffenderRecordsLimit = integer.valueOf(mapDataValueMap.get('TASyncTopOffenderLimit').datavalue__c);
        
        
        if( Userinfo.getProfileId() != apiOnlyProfileId )
        {
            HasAccess = false;
            
            //Code by Avinash begins...
            Id permissionSetId;
            List<PermissionSet> lstPS = [select name from PermissionSet where name = :System.Label.TA_Sync_Log_Permission_Set_Name limit 1];
            if(lstPS != null && lstPS.size() > 0)
            permissionSetId = lstPS.get(0).id;
            
            List<PermissionSetAssignment> lstPermissionSetAssignments = [Select p.SystemModstamp, p.PermissionSetId, p.Id, p.AssigneeId From PermissionSetAssignment p where permissionsetid = :permissionSetId  limit 50000];
            for(PermissionSetAssignment psa : lstPermissionSetAssignments)
            {
                if(psa.AssigneeId == System.Userinfo.getUserId())
                     HasAccess = true;
            }
            //Code by Avinash ends.

            /* Commented by Avinash for PoC using permission sets
            Map<String,AccessOnTASyncLog__c> AccessMap = AccessOnTASyncLog__c.getAll();
            for(AccessOnTASyncLog__c ac: AccessMap.Values()) 
            {
                  id i = ac.UserID__c;
                  if( i == Userinfo.getUserId() && ac.EditAccess__c == true )
                     HasAccess = true;
            }
            */
            if(HasAccess == false)
            for(TA_Sync_Log__c ta : Trigger.new)
                  ta.addError(System.label.TA_Sync_NoCreateAccess_Error);
                  
        }
        if((TodayCreatedList.size() >= DailyLimit && EnableDailyLimit=='true') || (OpenStatusList.size() >= OpenRecordsLimit && EnableOpenLimit=='true')) 
        {   
            Integer updateCount = 0;
            for(TA_Sync_Log__c ta : Trigger.new)
            {
                 if(TodayCreatedList.size() >= DailyLimit && EnableDailyLimit=='true')
                    ta.addError(System.label.TA_Sync_DailyLimit_Error);
                 if(OpenStatusList.size() >= OpenRecordsLimit && EnableOpenLimit=='true')
                    ta.addError(System.label.TA_Sync_OpenRecordsLimit_Error);   
                 updateCount++;
            }
            //TA_Sync_Log_Unprocessed_Notify.updateRejectedDueToLimit(updateCount);  
                
        }
        
        if(HasAccess)
        {
            Set<Id> salesResourceIds_Last7Days = new Set<Id>();//Set to store Sales Resource User Ids from TA Sync Log records created within last 7 days.
            Map<String, TA_Sync_Log__c> mapSalesResource_Last7Days = new Map<String, TA_Sync_Log__c>();//Set to store Sales Resource User Ids from TA Sync Log records created within last 7 days.
            Set<Id> salesResourceIds = new Set<Id>();//Set to store Sales Resource User Ids from currentTA Sync Log records.
            //Set<Id> salesResourceIdsForTA = new Set<Id>();//Set to store Sales Resource User Ids for TA from currentTA Sync Log records.
            
            for(Integer i=0; i<Trigger.new.size(); i++)
            {
                salesResourceIds.add(Trigger.new[i].Sales_Resource__c);
            }
            
            //Segregating Sales Resource Ids from existing TA Sync Log records.
            if(salesResourceIds.size()>0)
            {
                TA_Sync_Log__c[] existing_TA_Sync_Logs = [Select Sales_Resource__c,status__c, CreatedDate from TA_Sync_Log__c where Sales_Resource__c in: salesResourceIds and (CreatedDate >:Date.today()-7 OR status__c=:'Open' OR Status__c =:'EIS Insertions Complete' OR Status__c=:'Rowcount Validated')];
                System.debug('------------------TA SYNC LOGS FOUND>>>>'+existing_TA_Sync_Logs.size());
                //the user’s TA Synch is in process and not yet complete. In this condition, the User should not be able to have another request generated, while this existing one is still in process. 
                for(Integer i=0; i<existing_TA_Sync_Logs.size(); i++)
                {
                    salesResourceIds_Last7Days.add(existing_TA_Sync_Logs[i].Sales_Resource__c);
                    mapSalesResource_Last7Days.put(existing_TA_Sync_Logs[i].Sales_Resource__c, existing_TA_Sync_Logs[i]);
                }
            }
            
            
//Code Added by Avinash begins below..

            
            List<GroupMember> lstTopOffenderGroupMember = new List<GroupMember>();
            
            Set<Id> setSalesResourceId = new Set<Id>();

            for (TA_Sync_Log__c ta : Trigger.New) 
            {
                setSalesResourceId.add(ta.Sales_Resource__c);
            }
// system.debug('#### setSalesResourceId :: '+setSalesResourceId);

            if(Trigger.New != null)
              lstTopOffenderGroupMember = [SELECT UserOrGroupId, Group.Name 
                        FROM GroupMember 
                        WHERE (Group.Name LIKE '%TOPUB%' OR Group.Name LIKE '%TOPVT%') AND UserOrGroupId IN :setSalesResourceId
                        LIMIT 50000];

// system.debug('#### lstTopOffenderGroupMember :: '+lstTopOffenderGroupMember);
            Set<Id> setTopOffenderMemberId = new Set<Id>();

            for (GroupMember gm: lstTopOffenderGroupMember) 
            {
                setTopOffenderMemberId.add(gm.UserOrGroupId);
            }

            Set<Id> setUserId = new Set<Id>();
            List<User> lstUser = new List<User>();
//Code added by Avinash ends above.

            //Validating and adding error if TA Sync Log record created within last 7 days already exists for the Sales Resource selected in record from trigger.
            for(Integer i=0; i<Trigger.new.size(); i++)
            {
// system.debug('#### TA Record ::'+Trigger.new[i].Status__c);
                if(salesResourceIds_Last7Days.contains(Trigger.new[i].Sales_Resource__c))
                {
                    if(mapSalesResource_Last7Days.get(Trigger.new[i].Sales_Resource__c).status__c=='Open' || mapSalesResource_Last7Days.get(Trigger.new[i].Sales_Resource__c).status__c=='EIS Insertions Complete' || mapSalesResource_Last7Days.get(Trigger.new[i].Sales_Resource__c).status__c=='Rowcount Validated')
                    {
                        Trigger.new[i].addError(System.label.TA_Sync_CreatedIn7Days_Error + ' '+ mapSalesResource_Last7Days.get(Trigger.new[i].Sales_Resource__c).Createddate +' '+ System.label.TA_Sync_InProcess);    
                    }
                    else
                    {
                        Trigger.new[i].addError(System.label.TA_Sync_CreatedIn7Days_Error + ' '+ mapSalesResource_Last7Days.get(Trigger.new[i].Sales_Resource__c).Createddate +' '+ System.label.TA_Sync_CreatedIn7Days_Error1);    
                    
                    }
                }

//Code added by Avinash begins below..
                else if(Trigger.new[i].Status__c == 'Open')
                {
                    if(setTopOffenderMemberId != null && setTopOffenderMemberId.contains(Trigger.new[i].Sales_Resource__c))
                    {
                        Trigger.new[i].Status__c = 'Error';
                        if(System.Label.Error_Message_for_Top_Offender_TA_Sync_Record == null)
                            Trigger.new[i].Error__c = System.Label.Error_Message_for_Top_Offender_TA_Sync_Record;
                        else
                            Trigger.new[i].Error__c = 'Not Submitted. User is member of Top Offender Groups in SFDC.';

                        setUserId.add(Trigger.new[i].Sales_Resource__c);
                    }

                }
//Code added by Avinash ends above.

              }
// system.debug('#### SET USER IDS : '+setUserId);
            lstUser = [Select id, Last_TA_Synch_Date__c 
                        From User
                        Where id in :setUserId
                        Limit 10000];

            for (User u : lstUser) 
            {
                u.Last_TA_Synch_Date__c = System.Today();
            }

            if (lstUser != null && lstUser.size() > 0) 
            {
                update lstUser;
            }
        }    
    }
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        System.debug(' Userinfo.getProfileId() UPDATE ==== '+Userinfo.getProfileId()+'***apiOnlyProfileId*** in has next'+apiOnlyProfileId);
        Boolean HasAccess = false;
        if( Userinfo.getProfileId() != apiOnlyProfileId )
        {
            //Code by anand
            Id permissionSetId;
            List<PermissionSet> lstPS = [select name from PermissionSet where name = :System.Label.TA_Sync_Log_Permission_Set_Name limit 1];
            if(lstPS != null && lstPS.size() > 0)
            permissionSetId = lstPS.get(0).id;
            
            List<PermissionSetAssignment> lstPermissionSetAssignments = [Select p.SystemModstamp, p.PermissionSetId, p.Id, p.AssigneeId From PermissionSetAssignment p where permissionsetid = :permissionSetId  limit 50000];
            for(PermissionSetAssignment psa : lstPermissionSetAssignments)
            {
                if(psa.AssigneeId == System.Userinfo.getUserId())
                     HasAccess = true;
            }
        }
           

//Code added by Avinash begins below..
            if(HasAccess = true || Userinfo.getProfileId() == apiOnlyProfileId)
            {
                List<GroupMember> lstTopOffenderGroupMember = new List<GroupMember>();
                Set<Id> setTopOffenderMemberId = new Set<Id>();
                Set<Id> setSalesResourceId = new Set<Id>();

                for (TA_Sync_Log__c ta : Trigger.New) 
                {
                    setSalesResourceId.add(ta.Sales_Resource__c);
                }

                if(Trigger.New != null)
                    lstTopOffenderGroupMember = [SELECT UserOrGroupId, Group.Name 
                    FROM GroupMember 
                    WHERE (Group.Name LIKE '%TOPUB%' OR Group.Name LIKE '%TOPVT%') AND UserOrGroupId IN :setSalesResourceId
                    LIMIT 50000];

                for (GroupMember gm: lstTopOffenderGroupMember) 
                {
                    setTopOffenderMemberId.add(gm.UserOrGroupId);
                }

                for (TA_Sync_Log__c ta : Trigger.New) 
                {
                    if(ta.Status__c == 'Open' && setTopOffenderMemberId != null 
                    && setTopOffenderMemberId.contains(ta.Sales_Resource__c))
                    {
                        ta.Status__c = 'Error';
                        if(System.Label.Error_Message_for_Top_Offender_TA_Sync_Record == null)
                            ta.Error__c = System.Label.Error_Message_for_Top_Offender_TA_Sync_Record;
                        else
                            ta.Error__c = 'Not Submitted. User is member of Top Offender Groups in SFDC.';
                    }
                }


          
//Code added by Avinash ends above.
        }  
         else if(HasAccess == false)
            {
                for(TA_Sync_Log__c ta : Trigger.new)
                {
                      ta.addError(System.label.TA_Sync_NoEditAccess_Error);
                }
            } 
    }
    else if (Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug(' Userinfo.getProfileId() UPDATE ==== '+Userinfo.getProfileId() +'***apiOnlyProfileId***'+apiOnlyProfileId);
        Boolean HasAccess = false;
        List<OAR_Member_Added__c> lstTAUsers=new List<OAR_Member_Added__c>();
            
        if( Userinfo.getProfileId() != apiOnlyProfileId )
        {
            
            //Code by anand
            Id permissionSetId;
            List<PermissionSet> lstPS = [select name from PermissionSet where name = :System.Label.TA_Sync_Log_Permission_Set_Name limit 1];
            if(lstPS != null && lstPS.size() > 0)
            permissionSetId = lstPS.get(0).id;
            
            List<PermissionSetAssignment> lstPermissionSetAssignments = [Select p.SystemModstamp, p.PermissionSetId, p.Id, p.AssigneeId From PermissionSetAssignment p where permissionsetid = :permissionSetId  limit 50000];
            for(PermissionSetAssignment psa : lstPermissionSetAssignments)
            {
                if(psa.AssigneeId == System.Userinfo.getUserId())
                     HasAccess = true;
            }
        }
            
            if(HasAccess = true || Userinfo.getProfileId() == apiOnlyProfileId)
            {
                Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
                String strBaseURL = URL.getSalesforceBaseUrl().getHost();
                
                 // code for Job Scheduler record insertion.
                if(!Util.TA_Sync_Job_Scheduler_Inserted)
                {
                    for(Id newTAId: Trigger.newMap.keySet())
                    {
                        TA_Sync_Log__c newTASync = Trigger.newMap.get(newTAId);
                        TA_Sync_Log__c oldTASync = Trigger.oldMap.get(newTAId);
                        System.debug('++++Update Entered++++'+newTASync+'**oldTASync**'+oldTASync);
                        //Check if error is recieved from ORACLE through sys admin api only profile.AMER_Inside_Sales_SMB_User__c
                        if((newTASync.Status__c!=oldTASync.Status__c && newTASync.Status__c== System.Label.Error)||(newTASync.Error__c!=oldTASync.Error__c) )
                        {
                            String strOppURL = 'https://' + strBaseURL + '/' +newTASync.id;
                            OAR_Member_Added__c oppMemAdd= new OAR_Member_Added__c();
                            system.debug('newTASync.Error__c===>'+newTASync.Error__c);
                            if(newTASync.Error__c== System.Label.TA_Sync_No_Access_Records )
                            {
                                oppMemAdd.User_1__c=newTASync.Sales_Resource__c;
                                oppMemAdd.Text_1__c=newTASync.Sales_Resource__c;
                                oppMemAdd.Text_2__c=newTASync.Error__c;
                                oppMemAdd.Text_3__c=strOppURL;
                                oppMemAdd.Condition__c=System.Label.TA_Sync_Error;
                                system.debug('oppMemAdd  ===>'+oppMemAdd);
                                if(mapDataValueMap.get('TA_Sync_Track_DL').DataValue__c!=null)oppMemAdd.Email_notification_2__c=mapDataValueMap.get('TA_Sync_Track_DL').DataValue__c;
                                if(mapDataValueMap.get('TA_Sync_Sys_admin_DL').DataValue__c!=null)oppMemAdd.Email_notification_1__c=mapDataValueMap.get('TA_Sync_Sys_admin_DL').DataValue__c;
                                System.debug('oppMemAdd.User_1__c==='+oppMemAdd.User_1__c);
                            }
                            if(oppMemAdd.Condition__c==System.Label.TA_Sync_Error)lstTAUsers.add(oppMemAdd);
                        } 
                    }
                    if(lstTAUsers!=null)
                    {
                        insert lstTAUsers;
                    }
                    for(Id newTAId: Trigger.newMap.keySet())
                    {
                        TA_Sync_Log__c newTASyncLog = Trigger.newMap.get(newTAId);
                        TA_Sync_Log__c oldTASyncLog = Trigger.oldMap.get(newTAId);
                        System.debug('++++Update Entered++++'+newTASyncLog+'**oldTASyncLog**'+oldTASyncLog);
                      
                        //Check if status is Update to EIS Instertions Complete.
                        if(newTASyncLog.Status__c!=oldTASyncLog.Status__c && newTASyncLog.Status__c== System.Label.TA_Sync_EIS_Insertion_complete )
                        {
                            Datetime sysTime = System.now();
                            sysTime = sysTime.addSeconds(20);
                            //integer hour = datetime.now().time().hour()+7;
                            //integer minute = datetime.now().time().minute()+1;
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
                            System.debug('Job Scheduler = ' + js);
                            break;
                        }
                        
                    }
                    
                }
                Set<Id> setUserId = new Set<Id>();
                List<User> lstUser = new List<User>();

                
                for (TA_Sync_Log__c ta : Trigger.New) 
                {
                    if(Trigger.OldMap.get(ta.id).Status__c != ta.Status__c &&  (ta.Status__c == 'Error' || ta.Status__c == 'Sync Complete'))
                        setUserId.add(ta.Sales_Resource__c);
                }

                if(setUserId != null && setUserId.size() > 0)
                {
                    lstUser = [Select id, Last_TA_Synch_Date__c 
                    From User
                    Where id in :setUserId
                    Limit 10000];

                    if (lstUser != null && lstUser.size() > 0) 
                    {
                        for (User u : lstUser) 
                        {
                            u.Last_TA_Synch_Date__c = System.Today();
                        }
                    
                        update lstUser;
                        lstUser.clear();
                    }
                }
            }
            else if(HasAccess == false)
            {
                for(TA_Sync_Log__c ta : Trigger.new)
                {
                      ta.addError(System.label.TA_Sync_NoEditAccess_Error);
                }
            }
        }
 }