/*=====================================================================================================================================

History 
2nd Aug  2012  Kaustav Debnath     Added the code for PRM Partner leverage functionality
                                  This class is used to rate partner by recording SE Skills and sales ratings for Partner SEs,
                                  record District to Partner SE mapping and capture partner performance ratings
======================================================================================================================================*/                                  
public class PRM_Lead_eBusiness_Integration {
	public void updateLeadEBusinessFields(Map<Id,Lead> newMap,String strEventMsg)
	{
		Set<Id> setLeadOwnerIds=new Set<Id>();
		Map<Id,User> mapLeadOwners;
		Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
     
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Internal_Lead_Owner_Org = (mapCustomSettingEBiz.get('eBus_Lead_Owner_Org__c'));           
        String str_eBiz_Internal_Lead_Owner_Org = eBus_Internal_Lead_Owner_Org.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Create = (mapCustomSettingEBiz.get('eBus_Lead_Status_New'));
        String str_eBiz_Lead_Create = eBus_Lead_Create.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Accept = (mapCustomSettingEBiz.get('eBus_Lead_Status_Accepted'));
        String str_eBiz_Lead_Accept = eBus_Lead_Accept.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Lead_Reject = (mapCustomSettingEBiz.get('eBus_Lead_Status_Rejected'));
        String str_eBiz_Lead_Reject = eBus_Lead_Reject.String_Values__c;
        
        
        List<Lead> lstLeadForUpdate=new List<Lead>();
        
		if(newMap.size()>0)
		{
			for(Lead leadObj:newMap.values())
			{
				if(((String)leadObj.ownerid).startsWith('005'))
				{
					setLeadOwnerIds.add(leadObj.ownerid);
				}
			}
			if(setLeadOwnerIds.size()>0)
			{
				mapLeadOwners=new Map<Id,User>([select id,name,email,phone,userType,contact.account.name from user where id in :setLeadOwnerIds]);
			} 
			
				for(Lead leadObj1:newMap.values())
				{
					if(mapLeadOwners!=null && mapLeadOwners.containsKey(leadObj1.ownerid))
					{
						if(mapLeadOwners.get(leadObj1.ownerid).userType=='PowerPartner')
						{
							leadObj1.eBus_Lead_Owner_Org__c=mapLeadOwners.get(leadObj1.ownerid).contact.account.name;
							leadObj1.eBus_Lead_Owner_Name__c=mapLeadOwners.get(leadObj1.ownerid).name;
							leadObj1.eBus_Lead_Owner_Email__c=mapLeadOwners.get(leadObj1.ownerid).email;
							leadObj1.eBus_Lead_Owner_Phone__c=mapLeadOwners.get(leadObj1.ownerid).phone;
						}
						else
						{
							leadObj1.eBus_Lead_Owner_Org__c=str_eBiz_Internal_Lead_Owner_Org;
							leadObj1.eBus_Lead_Owner_Name__c=mapLeadOwners.get(leadObj1.ownerid).name;
							leadObj1.eBus_Lead_Owner_Email__c=mapLeadOwners.get(leadObj1.ownerid).email;
							leadObj1.eBus_Lead_Owner_Phone__c=mapLeadOwners.get(leadObj1.ownerid).phone;
						}
					}
					else if(((String)leadObj1.ownerid).startswith('00G'))
					{
						leadObj1.eBus_Lead_Owner_Org__c=null;
						leadObj1.eBus_Lead_Owner_Name__c=null;
						leadObj1.eBus_Lead_Owner_Email__c=null;
						leadObj1.eBus_Lead_Owner_Phone__c=null;
					}
					
					if(str_eBiz_Lead_Create!=null && strEventMsg=='Insert')
					{
						system.debug('#### strEventMsg=>'+strEventMsg);
						leadObj1.eBus_Lead_Status__c=str_eBiz_Lead_Create;
						Util.iseBusinessLeadInsert=true;
					}
					else if(strEventMsg=='Update')
					{
						if(str_eBiz_Lead_Accept!=null && leadObj1.Accept_Lead__c==true)
						{
							system.debug('#### strEventMsg=>'+strEventMsg);
							leadObj1.eBus_Lead_Status__c=str_eBiz_Lead_Accept;
						}
						else if(str_eBiz_Lead_Reject!=null && leadObj1.EMC_Lead_Rejected__c==true)
						{
							system.debug('#### strEventMsg=>'+strEventMsg);
							leadObj1.eBus_Lead_Status__c=str_eBiz_Lead_Reject;
						}
					}
					
				}
			
		}
	}
	public void updatedLeadEbusinessToLogTable(Map<Id,Lead> newMap)
	{
		system.debug('#### in here');
		Set<Id> setLeadIds=new Set<Id>();
		List<Integration_Log__c> lstIntegrationLog;
		Map<Id,Integration_Log__c> mapIntegrationLog=new Map<Id,Integration_Log__c>();
		List<Integration_Log__c> lstIntegrationLogInsert=new List<Integration_Log__c>();
		//List<Integration_Log__c> lstIntegrationLogUpdate=new List<Integration_Log__c>();
		Map<String,CustomSetting_eBusiness_SFDC_Integration__c> mapCustomSettingEBiz = CustomSetting_eBusiness_SFDC_Integration__c.getall();
		/*CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_in_proc = (mapCustomSettingEBiz.get('Integration_Log_Status_IN_PROCESS'));           
        String str_eBiz_int_log_msg_in_proc = eBus_Integration_Log_msg_in_proc.String_Values__c;*/
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_new = (mapCustomSettingEBiz.get('Integration_Log_Status_NEW'));           
        String str_eBiz_int_log_msg_new = eBus_Integration_Log_msg_new.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_msg_sync_completed = (mapCustomSettingEBiz.get('Integration_Log_Status_SYNC_COMPLETED'));           
        String str_eBiz_int_log_msg_sync_completed = eBus_Integration_Log_msg_sync_completed.String_Values__c;
        CustomSetting_eBusiness_SFDC_Integration__c eBus_Integration_Log_sObject_Lead = (mapCustomSettingEBiz.get('Integration_Log_sObject_Lead'));           
        String str_eBiz_int_log_sObject_Lead = eBus_Integration_Log_sObject_Lead.String_Values__c;
        
        
		if(newMap!=null && newMap.size()>0)
		{
			lstIntegrationLog=new List<Integration_Log__c>(
															[select id,name,
															//eBus_RFQ_ID__c,
															//Error_Message__c,
															SFDC_Object_ID__c
															,Integration_Status__c 
															 from Integration_Log__c where SFDC_Object_ID__c in :newMap.keyset()
															 and Integration_Status__c='NEW']);
			if(lstIntegrationLog!=null && lstIntegrationLog.size()>0)
			{
				for(Integration_Log__c intLogObj:lstIntegrationLog)
				{
					mapIntegrationLog.put(intLogObj.SFDC_Object_ID__c,intLogObj);
					System.debug('#### mapIntegrationLog inside for=>'+mapIntegrationLog);
				}
			}
			
			for(Lead leadObj:newMap.values())
			{
				if(mapIntegrationLog!=null && mapIntegrationLog.containsKey(leadObj.id))	
				{
					System.debug('#### mapIntegrationLog=>'+mapIntegrationLog);
					if(str_eBiz_int_log_msg_new!=null 
					&& mapIntegrationLog.containsKey(leadObj.id)
					&& !(str_eBiz_int_log_msg_new.contains(mapIntegrationLog.get(leadObj.id).Integration_Status__c.toUpperCase()))
					)
					{
						Integration_Log__c intLogObj=new Integration_Log__c();
						intLogObj.SFDC_Object_ID__c=leadObj.id;
						if(str_eBiz_int_log_msg_new!=null)
						{
							intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
						}
						if(str_eBiz_int_log_sObject_Lead!=null)
						{
							intLogObj.sObject__c=str_eBiz_int_log_sObject_Lead;
						}
						/*if(leadObj.eBus_RFQ_ID__c!=null)
						{
							intLogObj.eBus_RFQ_ID__c=leadObj.eBus_RFQ_ID__c;
						}*/
						
						lstIntegrationLogInsert.add(intLogObj);
					}
				}
				else
				{
					Integration_Log__c intLogObj=new Integration_Log__c();
					intLogObj.SFDC_Object_ID__c=leadObj.id;
					if(str_eBiz_int_log_msg_new!=null)
					{
						intLogObj.Integration_Status__c=str_eBiz_int_log_msg_new;
					}
					if(str_eBiz_int_log_sObject_Lead!=null)
					{
						intLogObj.sObject__c=str_eBiz_int_log_sObject_Lead;
					}
					/*if(leadObj.eBus_RFQ_ID__c!=null)
					{
						intLogObj.eBus_RFQ_ID__c=leadObj.eBus_RFQ_ID__c;
					}*/
					
					lstIntegrationLogInsert.add(intLogObj);				
					
				}
			}
			if(lstIntegrationLogInsert!=null && lstIntegrationLogInsert.size()>0)
			{
				System.debug('#### lstIntegrationLogInsert=>'+lstIntegrationLogInsert);
				insert lstIntegrationLogInsert;
			}
			/*if(lstIntegrationLogUpdate!=null && lstIntegrationLogUpdate.size()>0)
			{
				System.debug('#### lstIntegrationLogUpdate=>'+lstIntegrationLogInsert);
				update lstIntegrationLogUpdate;
			}*/
																
		}
	}
	
	
}