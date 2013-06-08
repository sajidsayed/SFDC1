/*===================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       213868      Initial Creation.  Inserts a record in CQRDelata Log object on every
                                                insert/delete of a Core Quota Rep record.
 +===================================================================================================================*/

 trigger CoreQuotaRepTrigger on Core_Quota_Rep__c (after delete, after insert) 
{
    
    List<CQR_Delta_Log__c> lstCQRDelta = new List<CQR_Delta_Log__c>();
    List<User> lstSysInteg = new List<User>();
    Set<Id> setBatchAdmin = new Set<Id>();
    List<Decimal> lstBatchId = new List<Decimal>(); 
    lstSysInteg=[Select Id, Name From User WHERE name like '%System Integration%' OR name like '%Integration%'OR name like '%Batch Admin%' limit 50000];
    
    for(user u: lstSysInteg)
    {
		setBatchAdmin.add(u.id);
    }
    
    if(Trigger.isAfter)
    {
//Stores the Account and Core Quota Rep record info after insert from Trigger.New 
        if(Trigger.isInsert)
        {
            for (Core_Quota_Rep__c cqr : Trigger.New) 
            {
                CQR_Delta_Log__c delta = new CQR_Delta_Log__c();
                delta.Account_Id__c = cqr.Account_ID__c;
                delta.Account__c = cqr.Account_ID__c;
                delta.Core_Quota_Rep_Id__c = cqr.id;
                delta.Badge_ID__c = cqr.Badge_ID__c;
                delta.District_Name__c = cqr.District_Name__c;
                delta.External_ID__c = cqr.External_ID__c;
                delta.Oracle_District_ID__c = cqr.Oracle_District_ID__c;
                delta.Role_Name__c = cqr.Role_Name__c;
                delta.SFDC_User_ID__c = cqr.SFDC_User_ID__c;
                delta.Core_Quota_Rep_Name__c = cqr.Name;
                delta.Batch_ID__c = cqr.Batch_ID__c;
                system.debug('outside delta.Badge_ID__c '+cqr.Batch_ID__c);
                lstCQRDelta.add(delta);
                
                if(setBatchAdmin.contains(Userinfo.getUserId()))
                {
                	system.debug('inside delta.Badge_ID__c '+cqr.Batch_ID__c);
                	lstBatchId.add(cqr.Batch_ID__c);
                }
            }
            
            if(lstBatchId!=null&&lstBatchId.size()>0)
            {
	            lstBatchId.sort();
	            system.debug('lstBatchId'+lstBatchId);
	            Integer lstsize = lstBatchId.size()-1;
	            Decimal decBatchId = lstBatchId.get(lstsize);
	            
	            Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
	            CustomSettingDataValueMap__c datavaluemap = data.get('Max Batch Id');
	            datavaluemap.DataValue__c = string.valueof(decBatchId);
	            update datavaluemap;
            }
            
        }
        
//Stores the Account and Core Quota Rep record info after delete from Trigger.Old 
        if(Trigger.isDelete)
        {
            for (Core_Quota_Rep__c cqr : Trigger.Old) 
            {
                CQR_Delta_Log__c delta = new CQR_Delta_Log__c();
                delta.Account_Id__c = cqr.Account_ID__c;
                delta.Account__c = cqr.Account_ID__c;
                delta.Core_Quota_Rep_Id__c = cqr.id;
                delta.Badge_ID__c = cqr.Badge_ID__c;
                delta.District_Name__c = cqr.District_Name__c;
                delta.External_ID__c = cqr.External_ID__c;
                delta.Oracle_District_ID__c = cqr.Oracle_District_ID__c;
                delta.Role_Name__c = cqr.Role_Name__c;
                delta.SFDC_User_ID__c = cqr.SFDC_User_ID__c;
                delta.Core_Quota_Rep_Name__c = cqr.Name;
                lstCQRDelta.add(delta);
            }
        }

        if (lstCQRDelta != null && lstCQRDelta.size() > 0) 
        {
            Database.Saveresult[] resultUpdAcc = database.insert(lstCQRDelta, false) ;
                        
            List <EMCException> upderrors = new List <EMCException>();
            for (integer i = 0; i < resultUpdAcc.size(); i++) 
            {
                Database.Saveresult sr = resultUpdAcc[i];
                String dataErrs = '';
                if (!sr.isSuccess()) 
                {
// if the particular record did not get updated, we log the data error 
                    for (Database.Error err : sr.getErrors()) 
                    {
                        dataErrs += err.getMessage();
                    }
// System.debug('An exception occurred while attempting an update on ' + sr.getId());
// System.debug('ERROR: ' + dataErrs);
                    upderrors.add(new EMCException(dataErrs, 'CoreQuotaRepTrigger', new String [] {lstCQRDelta[i].Id}));
                }
            }

            // log any errors that occurred
            if (upderrors.size() > 0) 
                EMC_UTILITY.logErrors(upderrors);   
        }
    }
    
}