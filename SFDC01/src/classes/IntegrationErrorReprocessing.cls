/*===========================================================================+
 |  HISTORY  |                                                                          
 |  DATE          DEVELOPER           WR      DESCRIPTION                               
 |  ====          =========           ==      =========== 
 |  6/23/2011     Sajid sayed                    This class is used to reprocess integration errors.                                                                                              
 +===========================================================================*/
global class IntegrationErrorReprocessing {
	
/* @Method <updateIntegration> updates the respective objects to generate outbound workflow
@param <List<String> integrationID >
@return <void> - <The method is not returning anything>
@throws exception - <No Exception>
*/
	public static webservice  void  updateIntegration (List<String> integrationID )
	{	
		System.debug('IntegrationErrorReprocessing'+ 'integrationID '+ integrationID);	
		
		Integration_error_log__c[] integErrorlog=  [SELECT id,Resubmit__c, Integration_ID__c, Integration_Name__c FROM Integration_error_log__c where id in: integrationID];
		
		//List<Lead> listDealReg = new List<Lead>();
		//List<Account> listPRMprofile = new List<Account>();
		
		List<id> listDealRegID = new List<id>();
		List<id> listPRMprofileID = new List<id>();
		List<String> listAccAssnID = new List<String>();
		List<id> listCXPMappingID = new List<id>();
		Boolean resubmit = false;
		
		for(Integration_error_log__c intgLog: integErrorlog) {
				
				
				
				if (intgLog.Integration_Name__c =='Deal Registration Integration')// 
				{
					listDealRegID.add(intgLog.Integration_ID__c);
					
					resubmit=true;
					 	
				}
				else if (intgLog.Integration_Name__c =='Profiled Account Integration')//
				{
					listPRMprofileID.add(intgLog.Integration_ID__c);
					 resubmit=true;
				}
				else if (intgLog.Integration_Name__c =='Account Association Integration')// Used for CXP Mapping as well
				{
					listAccAssnID.add(intgLog.Integration_ID__c);
					resubmit=true;
				}
				/*else if (intgLog.Integration_Name__c =='CXP Mapping Integration')//
				{
					listCXPMappingID.add(intgLog.Integration_ID__c);
					resubmit=true;
				}*/
				  
				if (resubmit)
				{
					intgLog.Resubmit__c=true;
					update intgLog;
				}  
			}
		
		if (listDealRegID.size()!=0)
		{
				Lead [] lead=  [SELECT id,SendOutboundNotification__c  FROM Lead where id in: listDealRegID];
				
				for (Lead ld:lead)
				{
					ld.SendOutboundNotification__c=true;
				}
				update lead;
				
				
		}
		if (listPRMprofileID.size()!=0)
		{
				Account [] accn=  [SELECT id,name,SendOutboundNotification__c  FROM Account where id in: listPRMprofileID];
				
				for (Account acn:accn)
				{
					acn.SendOutboundNotification__c=true;
				}	
				
				update accn;
				
				
		}
		if (listAccAssnID.size()!=0)
		{
				//APPR_MTV__RecordAssociation__c [] accAssnID=  [SELECT id  FROM APPR_MTV__RecordAssociation__c where id in: listAccAssnID];
				Outbound_Message_Log__c [] accAssnID = [SELECT id, Integration_Operation__c,  Name, RecordId__c, SendOutboundNotification__c FROM Outbound_Message_Log__c where RecordId__c in:listAccAssnID ];
				
				for (Outbound_Message_Log__c obmLog:accAssnID)
				{
					obmLog.SendOutboundNotification__c=true;
				}
				update accAssnID;
				
			 
		}
	
	}	
		
}