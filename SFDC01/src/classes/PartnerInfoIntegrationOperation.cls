/*=====================================================================================================================================

History 
17th Aug 12  Kaustav Debnath    This class contains the business logic for the partner info ebusiness SFDC Integration Web Service                                 

======================================================================================================================================*/
public class PartnerInfoIntegrationOperation {
    
    /* @Method <This method is called by the trigger to update location records based upon updates on partner profiled account>
   @param <This is taking the trigger oldmap and newmap as parameters>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
   */
    public Boolean updateLocationEBizLeadAdminFields(Map<Id,Account> mapProfiledAccountsOldVal,Map<Id,Account> mapProfiledAccountsNewVal)
    {
        List<Partner_Location__c> lstPartnerLocationToUpdate=new List<Partner_Location__c>();
        Boolean isGoingToUpdateLocations=false;//This field is to check whether locations are being updated for the account or not
        if(mapProfiledAccountsOldVal.size()>0)
        {
            Map<Id,Partner_Location__c> mapPartnerLocation=new Map<Id,Partner_Location__c>([select id,eBus_Location_Enabled__c,name,street__c,city__c,state_province__c,postal_code__c,country__c,
                                                      eBus_Lead_Admin__c,eBus_Lead_Admin_Name__c,eBus_Lead_Admin_Email__c,eBus_Lead_Admin_Phone__c,
                                                      account__c
                                                      from Partner_Location__c where account__C in :mapProfiledAccountsOldVal.keyset()
                                                      and eBus_Location_Enabled__c=TRUE]);
            if(mapPartnerLocation.size()>0)
            {
                for(Partner_Location__c locObj:mapPartnerLocation.values())
                {
                    if(locObj.eBus_Lead_Admin__c==mapProfiledAccountsOldVal.get(locObj.account__c).eBus_Lead_Admin__c)
                    {
                        locObj.eBus_Lead_Admin__c=mapProfiledAccountsNewVal.get(locObj.account__c).eBus_Lead_Admin__c;
                        //locObj.eBus_Partner_Info_Delta_Include__c=true;
                        lstPartnerLocationToUpdate.add(locObj);
                    }
                }
            }
            
                
        }
        if(lstPartnerLocationToUpdate.size()>0)
        {
            System.debug('#### lstPartnerLocationToUpdate=>'+lstPartnerLocationToUpdate);
            update lstPartnerLocationToUpdate;
            isGoingToUpdateLocations=true;
        }
        return isGoingToUpdateLocations;
        
    }
    
    /* @Method <This method is called by the trigger to update location records based upon updates on partner profiled account>
   @param <This is taking the trigger oldmap and newmap as parameters>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
   */
    public void insertAccountIntegrationLog(Map<Id,Account> mapProfiledAccountsOldVal,Map<Id,Account> mapProfiledAccountsNewVal)
    {
        List<Partner_Location__c> lstPartnerLocationToUpdate=new List<Partner_Location__c>();
        List<Integration_Log__c> lstIntegrationLog=new List<Integration_Log__c>();
        //List<Integration_Log__c> lstIntegrationToUpdate=new List<Integration_Log__c>();
        List<Integration_Log__c> lstIntegrationToInsert=new List<Integration_Log__c>();
        Map<Id,Integration_Log__c> mapIntegrationLog=new Map<Id,Integration_Log__c>();
        Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
        /*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_in_proc = (mapCustomSettingEBiz.get('Integration_Log_Status_IN_PROCESS'));           
        String str_eBiz_int_log_msg_in_proc = eBus_Integration_Log_msg_in_proc.String_Values__c;*/
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_new = (mapCustomSettingEBiz.get('Integration_Log_Status_NEW'));           
        String str_eBiz_int_log_msg_new = eBus_Integration_Log_msg_new.String_Values__c;
        /*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_sync_completed = (mapCustomSettingEBiz.get('Integration_Log_Status_SYNC_COMPLETED'));           
        String str_eBiz_int_log_msg_sync_completed = eBus_Integration_Log_msg_sync_completed.String_Values__c;*/
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Account = (mapCustomSettingEBiz.get('Integration_Log_sObject_Account'));           
        String str_eBiz_int_log_sObject_Account = eBus_Integration_Log_sObject_Account.String_Values__c;
        if(mapProfiledAccountsOldVal.size()>0)
        {
            lstIntegrationLog=[select id,name,
                               //eBus_RFQ_ID__c,
                               //Error_Message__c,
                               SFDC_Object_ID__c,
                               Integration_Status__c 
                               from Integration_Log__c where SFDC_Object_ID__c in :mapProfiledAccountsNewVal.keyset()
                               and Integration_Status__c='NEW'];                                                      
            if(lstIntegrationLog.size()>0)
            {
                for(Integration_Log__c intLog:lstIntegrationLog)
                {
                    if(!mapIntegrationLog.containsKey(intLog.SFDC_Object_ID__c))
                    {
                        mapIntegrationLog.put(intLog.SFDC_Object_ID__c,intLog);
                    }
                }
            }
                for(Account accObj: mapProfiledAccountsNewVal.values())
                {
                    if(mapIntegrationLog.containsKey(accObj.id))
                    {
                        if(str_eBiz_int_log_msg_new!=null && mapIntegrationLog.containsKey(accObj.id) 
                        && !(str_eBiz_int_log_msg_new.contains((mapIntegrationLog.get(accObj.id).Integration_Status__c).toUpperCase())))
                            {
                                System.debug('#### in here mapIntegrationLog.get(accObj.id)=>'+mapIntegrationLog.get(accObj.id));
                                Integration_Log__c intLogObj=new Integration_Log__c();
                                intLogObj.SFDC_Object_ID__c=accObj.id;
                                if(str_eBiz_int_log_msg_new!=null)
                                {
                                    intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                                }
                                if(str_eBiz_int_log_sObject_Account!=null)
                                {
                                    intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                                }
                                lstIntegrationToInsert.add(intLogObj);  
                            }
                        /*else if(str_eBiz_int_log_msg_in_proc!=null && str_eBiz_int_log_msg_in_proc.contains((mapIntegrationLog.get(accObj.id).Integration_Status__c).toUpperCase()))
                            {
                                Integration_Log__c intLogObj=new Integration_Log__c();
                                intLogObj.SFDC_Object_ID__c=accObj.id;
                                if(str_eBiz_int_log_msg_new!=null)
                                {
                                    intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                                }
                                if(str_eBiz_int_log_sObject_Account!=null)
                                {
                                    intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                                }
                                lstIntegrationToInsert.add(intLogObj);      
                            }*/
                    }
                    else
                    {
                        System.debug('### inside else');
                        Integration_Log__c intLogObj=new Integration_Log__c();
                        intLogObj.SFDC_Object_ID__c=accObj.id;
                        if(str_eBiz_int_log_msg_new!=null)
                        {
                            intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                        }
                        if(str_eBiz_int_log_sObject_Account!=null)
                        {
                            intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                        }
                        lstIntegrationToInsert.add(intLogObj);  
                    }
                }
            
            
        }
        
        /*if(lstIntegrationToUpdate.size()>0)
        {
            System.debug('#### lstIntegrationToUpdate=>'+lstIntegrationToUpdate);
            update lstIntegrationToUpdate;
        }*/
        if(lstIntegrationToInsert.size()>0)
        {
            System.debug('#### lstIntegrationToInsert=>'+lstIntegrationToInsert);
            insert lstIntegrationToInsert;
        }
        
    }
    
    /* @Method <This method is called from partner loc after update trigger to insert account id to integration log>
   @param <This is taking the newMap as the parameter>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
   */ 
   public void insertAccountForLocationUpdateIntoIntegrationLog(List<Partner_Location__c> lstNewLocation)
   {
        Map<Id,Integration_Log__c> mapIntegrationLogToUpdate=new Map<Id,Integration_Log__c>();
        //List<Integration_Log__c> lstIntegrationLogToUpdate=new List<Integration_Log__c>();
        Map<Id,Integration_Log__c> mapIntegrationLogToInsert=new Map<Id,Integration_Log__c>();
        List<Integration_Log__c> lstIntegrationLogToInsert=new List<Integration_Log__c>();
        List<Integration_Log__c> lstIntegrationLog=new List<Integration_Log__c>();
        
        Map<Id,Integration_Log__c> mapIntegrationLog=new Map<Id,Integration_Log__c>(); 
        Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
        /*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_in_proc = (mapCustomSettingEBiz.get('Integration_Log_Status_IN_PROCESS'));           
        String str_eBiz_int_log_msg_in_proc = eBus_Integration_Log_msg_in_proc.String_Values__c;*/
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_new = (mapCustomSettingEBiz.get('Integration_Log_Status_NEW'));           
        String str_eBiz_int_log_msg_new = eBus_Integration_Log_msg_new.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_sync_completed = (mapCustomSettingEBiz.get('Integration_Log_Status_SYNC_COMPLETED'));           
        String str_eBiz_int_log_msg_sync_completed = eBus_Integration_Log_msg_sync_completed.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Account = (mapCustomSettingEBiz.get('Integration_Log_sObject_Account'));           
        String str_eBiz_int_log_sObject_Account = eBus_Integration_Log_sObject_Account.String_Values__c;
        
        Set<Id> setAccountIds=new Set<Id>();
        if(lstNewLocation.size()>0)
        {
            for(Partner_Location__c locObj:lstNewLocation)
            {
                setAccountIds.add(locObj.Account__c);
            }
        }
        if(setAccountIds.size()>0)
        {
            lstIntegrationLog=[select id,name,
                               //eBus_RFQ_ID__c,
                               sObject__c,
                               //Error_Message__c,
                               SFDC_Object_ID__c
                               ,Integration_Status__c 
                               from Integration_Log__c where SFDC_Object_ID__c in :setAccountIds
                               and Integration_Status__c='NEW'];
            if(lstIntegrationLog.size()>0)
            {
                for(Integration_Log__c intLog:lstIntegrationLog)
                {
                    if(!mapIntegrationLog.containsKey(intLog.SFDC_Object_ID__c))
                    {
                        mapIntegrationLog.put(intLog.SFDC_Object_ID__c,intLog);
                    }
                }
            }                          
        }
        if(lstNewLocation.size()>0)
        {
            for(Partner_Location__c locObj:lstNewLocation)
            {
                if(mapIntegrationLog.containsKey(locObj.account__c))
                {
                    if(str_eBiz_int_log_msg_new!=null && mapIntegrationLog.containsKey(locObj.account__c) && !(str_eBiz_int_log_msg_new.contains((mapIntegrationLog.get(locObj.account__c).Integration_Status__c).toUpperCase())))
                        {
                            Integration_Log__c intLogObj=new Integration_Log__c();
                            intLogObj.SFDC_Object_ID__c=locObj.account__c;
                            if(str_eBiz_int_log_msg_new!=null)
                            {
                                intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                            }
                            if(str_eBiz_int_log_sObject_Account!=null)
                            {
                                intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                            }
                            if(!mapIntegrationLogToInsert.containsKey(locObj.account__c))
                            {
                                mapIntegrationLogToInsert.put(intLogObj.SFDC_Object_ID__c,intLogObj);
                                lstIntegrationLogToInsert.add(intLogObj);
                            }   
                        }
                    /*else if(str_eBiz_int_log_msg_in_proc!=null && str_eBiz_int_log_msg_in_proc.contains((mapIntegrationLog.get(locObj.account__c).Integration_Status__c).toUpperCase()))
                        {
                            Integration_Log__c intLogObj=new Integration_Log__c();
                            intLogObj.SFDC_Object_ID__c=locObj.account__c;
                            if(str_eBiz_int_log_msg_new!=null)
                            {
                                intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                            }
                            if(str_eBiz_int_log_sObject_Account!=null)
                            {
                                intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                            }
                            if(!mapIntegrationLogToInsert.containsKey(locObj.account__c))
                            {
                                mapIntegrationLogToInsert.put(intLogObj.SFDC_Object_ID__c,intLogObj);
                                lstIntegrationLogToInsert.add(intLogObj);
                            }   
                        }*/
                    
                }
                else
                {
                    Integration_Log__c intLogObj=new Integration_Log__c();
                    intLogObj.SFDC_Object_ID__c=locObj.account__c;
                    if(str_eBiz_int_log_msg_new!=null)
                    {
                        intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
                    }
                    if(str_eBiz_int_log_sObject_Account!=null)
                    {
                        intLogObj.sObject__c=str_eBiz_int_log_sObject_Account;
                    }
                    if(!mapIntegrationLogToInsert.containsKey(locObj.account__c))
                    {
                        mapIntegrationLogToInsert.put(intLogObj.SFDC_Object_ID__c,intLogObj);
                        lstIntegrationLogToInsert.add(intLogObj);
                    }       
                    
                }
            }
        }
        /*if(lstIntegrationLogToUpdate.size()>0)
        {
            System.debug('#### lstIntegrationLogToUpdate=>'+lstIntegrationLogToUpdate); 
            
            update lstIntegrationLogToUpdate;
        }*/
        if(lstIntegrationLogToInsert.size()>0)
        {
            System.debug('#### lstIntegrationLogToInsert=>'+lstIntegrationLogToInsert);
            insert lstIntegrationLogToInsert;
        }
   }
    /* @Method <This method is called by the web service method to fetch the partner account and location information which are eBiz enabled>
   @param <This is taking no parameters>
   @return <List<PartnerInfoHeader>> -- <Returns a list of wrapper fields to be fetched by the interface>.
   @throws exception - <No Exception>
   */
    public static List<PartnerInfoHeader> getPartnerInformation ()
    {
        
        List<Integration_Log__c> lstIntegrationLog=new List<Integration_Log__c>();
        List<Integration_Log__c> lstIntegrationLogToUpdate=new List<Integration_Log__c>();
        Map<Id,Integration_Log__c> mapIntegrationLog=new Map<Id,Integration_Log__c>();
        //Map<Id,Attachment> mapAttachment;
        Map<Id,Attachment> mapLogoIdWithAttachment = new Map<Id,Attachment>();
        List<Attachment> lstAttachment = new List<Attachment>();
        Set<Id> setLogoIds=new Set<Id>();
        List<locationHeader> lstLocationHeader=new List<locationHeader>();
        List<PartnerInfoHeader> lstPartnerInfoHeader=new List<PartnerInfoHeader>();
        Boolean bQueryMore=false;
        
        Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_in_proc = (mapCustomSettingEBiz.get('Integration_Log_Status_IN_PROCESS'));           
        String str_eBiz_int_log_msg_in_proc = eBus_Integration_Log_msg_in_proc.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_query_more = (mapCustomSettingEBiz.get('Integration_Log_Query_More'));           
        String str_eBiz_int_log_query_more = eBus_Integration_Log_query_more.String_Values__c;
        /*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_new = (mapCustomSettingEBiz.get('Integration_Log_Status_NEW'));           
        String str_eBiz_int_log_msg_new = eBus_Integration_Log_msg_new.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_sync_completed = (mapCustomSettingEBiz.get('Integration_Log_Status_SYNC_COMPLETED'));           
        String str_eBiz_int_log_msg_sync_completed = eBus_Integration_Log_msg_sync_completed.String_Values__c;*/
        /*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Account = (mapCustomSettingEBiz.get('Integration_Log_sObject_Account'));           
        String str_eBiz_int_log_sObject_Account = eBus_Integration_Log_sObject_Account.String_Values__c;*/
        //Map<Id,Id> mapAccountWithLogoId=new Map<Id,Id>();
        Integer iLoopSize=0;
        System.debug('#### in here');   
            
        lstIntegrationLog=[select id,name,
                               //eBus_RFQ_ID__c,
                               sObject__c,
                               //Error_Message__c,
                               SFDC_Object_ID__c
                               ,Integration_Status__c 
                               from Integration_Log__c where sObject__c='Account' 
                               and Integration_Status__c='NEW'
                               ];
         System.debug('#### lstIntegrationLog.size()=>'+lstIntegrationLog.size());
         System.debug('#### str_eBiz_int_log_query_more.size()=>'+str_eBiz_int_log_query_more);
            if(lstIntegrationLog.size()>0)
            {
                if(str_eBiz_int_log_query_more!=null && lstIntegrationLog.size()>Integer.valueOf(str_eBiz_int_log_query_more))
                    {
                        bQueryMore=true;
                        iLoopSize=Integer.valueOf(str_eBiz_int_log_query_more);
                    }
                    else
                    {
                        bQueryMore=false;
                        iLoopSize=lstIntegrationLog.size();
                    }
                
                for(Integer iCount=0;iCount<iLoopSize;iCount++)
                {
                    if(!mapIntegrationLog.containsKey(lstIntegrationLog[iCount].SFDC_Object_ID__c))
                    {
                        mapIntegrationLog.put(lstIntegrationLog[iCount].SFDC_Object_ID__c,lstIntegrationLog[iCount]);
                    }
                }
            }   
            if(mapIntegrationLog.size()>0)
            {
                Map<Id,Account> mapAccountEBizEnabled= new Map<Id,Account>([select id,name,Partnership_Overview__c,Partner_Self_Description_Long__c,
                                                          logo__c,eBus_Lead_Admin_Email__c,Business_Focus__c,
                                                          Industry_Verticals__c,Product_Focus__c,eBus_Partner_Enabled__c,
                                                          
                                                          (select id,eBus_Location_Enabled__c,name,street__c,city__c,
                                                          state_province__c,postal_code__c,country__c,eBus_Lead_Admin__c,
                                                          eBus_Lead_Admin_Name__c,eBus_Lead_Admin_Email__c,eBus_Lead_Admin_Phone__c                                                   
                                                          from Partner_Locations__r)
                                                           
                                                          from Account where id in :mapIntegrationLog.keyset()]);
                
                if(mapAccountEBizEnabled!=null && mapAccountEBizEnabled.size()>0)
                {
                    for(Account accObj:mapAccountEBizEnabled.values())
                    {
                        setLogoIds.add(accObj.logo__c);
                    }
                    if(setLogoIds!=null && setLogoIds.size()>0)
                    {
                        lstAttachment=[SELECT ParentId, Body, BodyLength, ContentType, Id FROM Attachment where parentid in :setLogoIds];
                        if(lstAttachment.size()>0)
                        {
                            for(Attachment attachObj:lstAttachment)
                            {
                                mapLogoIdWithAttachment.put(attachObj.parentid,attachObj);
                            }
                        }
                    }
                    for(Account accObj:mapAccountEBizEnabled.values())
                    {
                        List<Partner_Location__c> lstLocObj=accObj.Partner_Locations__r;
                        PartnerInfoHeader partnerHeader=new PartnerInfoHeader();
                        System.debug('#### lstLocObj.size()=>'+lstLocObj.size());
                        if(lstLocObj!=null && lstLocObj.size()>0)
                        {
                            partnerHeader.locationHeaderObj=new List<LocationHeader>();
                            for(Partner_Location__c locObj:lstLocObj)
                            {
                                
                                LocationHeader locationHeader=new LocationHeader();
                                locationHeader.text_field01=locObj.id;
                                locationHeader.boolean_field01=locObj.eBus_Location_Enabled__c;
                                locationHeader.text_field02=locObj.name;
                                locationHeader.text_field03=locObj.street__c;
                                locationHeader.text_field04=locObj.city__C;
                                locationHeader.text_field05=locObj.state_province__c;
                                locationHeader.text_field06=locObj.postal_code__c;
                                locationHeader.text_field07=locObj.country__c;
                                locationHeader.text_field08=locObj.eBus_Lead_Admin__c;
                                locationHeader.text_field09=locObj.eBus_Lead_Admin_Name__c;
                                locationHeader.text_field10=locObj.eBus_Lead_Admin_Email__c;
                                locationHeader.text_field11=locObj.eBus_Lead_Admin_Phone__c;
                                lstLocationHeader.add(locationHeader);
                                partnerHeader.locationHeaderObj.add(locationHeader);
                                
                            }
                        }
                        
                        if(bQueryMore)
                        {
                            partnerHeader.queryMore=true;
                        }
                        else
                        {
                            partnerHeader.queryMore=false;
                        }
                        partnerHeader.text_field01=accObj.id;
                        partnerHeader.text_field02=accObj.name;
                        partnerHeader.text_field03=accObj.Partnership_Overview__c;
                        partnerHeader.text_field04=accObj.Partner_Self_Description_Long__c;
                        partnerHeader.text_field05=accObj.eBus_Lead_Admin_Email__c;
                        partnerHeader.text_field06=accObj.Business_Focus__c;
                        partnerHeader.text_field07=accObj.Industry_Verticals__c;
                        partnerHeader.text_field08=accObj.Product_Focus__c;
                        partnerHeader.text_field09=accObj.eBus_Partner_Enabled__c;
                        if(mapIntegrationLog.containsKey(accObj.id))
                        {
                            partnerHeader.text_field10=mapIntegrationLog.get(accObj.id).id;
                        }
                        if(mapLogoIdWithAttachment.containsKey(accObj.logo__c))
                        {
                            partnerHeader.blob_field01=mapLogoIdWithAttachment.get(accObj.logo__c).body;
                        }
                        System.debug('#### accObj.id=>'+accObj.id);
                        //System.debug('#### partnerHeader.locationHeaderObj.size()=>'+partnerHeader.locationHeaderObj.size());
                        lstPartnerInfoHeader.add(partnerHeader);
                    }
                }
                
            }   
            for(Integer iCount=0;iCount<iLoopSize;iCount++)
            {
                if(str_eBiz_int_log_msg_in_proc!=null)
                {
                    lstIntegrationLog[iCount].Integration_Status__c=str_eBiz_int_log_msg_in_proc;
                    lstIntegrationLogToUpdate.add(lstIntegrationLog[iCount]);
                }
            }
            if(lstIntegrationLogToUpdate!=null && lstIntegrationLogToUpdate.size()>0)
            {
                update lstIntegrationLogToUpdate;
            }
            System.debug('#### lstPartnerInfoHeader=>'+lstPartnerInfoHeader);
            System.debug('#### lstPartnerInfoHeader.size()=>'+lstPartnerInfoHeader.size());
                        
            return lstPartnerInfoHeader;
    }
    /* @Method <This method is from partner location trigger to update ebiz lead admin if profiled account has ebiz lead admin>
   @param <This is taking the newMap as the parameter>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
   */
   public void updateLocationFieldsBasedOnAccount(List<Partner_Location__c> lstPartnerLocation)
   {
        Set<Id> setAccountIds=new Set<Id>();
        Map<Id,Account> mapLocationAccounts; 
        if(lstPartnerLocation.size()>0)
        {
            for(Partner_Location__c locObj:lstPartnerLocation)
            {
                setAccountIds.add(locObj.account__c);
            }
            if(setAccountIds.size()>0)
            {
                mapLocationAccounts=new Map<Id,Account>([select id,name,Partnership_Overview__c,Partner_Self_Description_Long__c,
                                                          logo__c,eBus_Lead_Admin_Email__c,Business_Focus__c,
                                                          Industry_Verticals__c,Product_Focus__c,eBus_Partner_Enabled__c,
                                                          eBus_Lead_Admin__c from Account where id in :setAccountIds]);
                if(mapLocationAccounts!=null && mapLocationAccounts.size()>0)
                {
                    for(Partner_Location__c locObj1:lstPartnerLocation)
                    {
                        if(mapLocationAccounts.containsKey(locObj1.account__c))
                        {
                            if(mapLocationAccounts.get(locObj1.account__c).eBus_Lead_Admin__c!=null)
                            {
                                locObj1.eBus_Lead_Admin__c=mapLocationAccounts.get(locObj1.account__c).eBus_Lead_Admin__c;
                            }
                        }
                    }
                }                                                        
            }
        }
   }
    /* @Method <This method is from partner location trigger to update ebiz lead admin if profiled account has ebiz lead admin>
   @param <This is taking the newMap as the parameter>
   @return <void> -- <Returns nothing>.
   @throws exception - <No Exception>
   */
   public void insertInetgrationLogforContactUpdate(List<Contact> lstUpdatedContact)
   {
    Map<Id,Account> mapAccountToProcess = new Map<Id,Account>([Select Id,eBus_Lead_Admin_Email__c,eBus_Lead_Admin__c from Account where eBus_Lead_Admin__c in :lstUpdatedContact and                                                            eBus_Partner_Enabled__c !='']);
    if(mapAccountToProcess.size()>0){
       insertAccountIntegrationLog(mapAccountToProcess,mapAccountToProcess);
    }
   }
}