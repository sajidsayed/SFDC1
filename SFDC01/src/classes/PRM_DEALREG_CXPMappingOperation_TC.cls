/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  18 May 2011        Arif                    This test class is used to test the insertion of Outbound Message Log Object record
                                               when any record of CXP Mapping is inserted,updated,deleted.
 +=========================================================================================================================*/
@isTest
private class PRM_DEALREG_CXPMappingOperation_TC {
	
/*@Method <This method is used to test insertion of record in Outbound Message Log Object on insertion CXP Mapping record.>
@param <This method will not take any parameter>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/
    static testMethod void myUnitTest(){
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        CxP_Mapping__c cxpMappingRecord;
    	Test.startTest();
    	cxpMappingRecord = createCxPMappingRecord();
    	System.assertEquals(1,[Select count() from Outbound_Message_Log__c where RecordId__c =: cxpMappingRecord.Id] );	
    	Test.stopTest();
    }
 
/*@Method <This method is used to create test CXP Mapping Object record.>
@param <This method will not take any parameter>
@return <void> - <This method will return the created CXP Mapping record>
@throws exception - <No Exception>
*/      
    static CxP_Mapping__c createCxPMappingRecord(){
    	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();	
    	 Account profiledAccount = new Account();
           profiledAccount.name = 'UNITTESTAcc';
           profiledAccount.Party_Number__c = '1234';
           profiledAccount.BillingCountry ='Colombia';
           profiledAccount.Synergy_Account_Number__c = '10';
           profiledAccount.Lead_Oppty_Enabled__c = true; 
           profiledAccount.Partner_Type__c ='Distribution VAR';
           profiledAccount.Type = 'Partner';
           profiledAccount.recordtypeid= accRecordTypeId;      
	       insert profiledAccount;
	       profiledAccount.Lead_Oppty_Enabled__c = true;
	       profiledAccount.Type = 'Partner';
	       profiledAccount.Status__c='A';
	       update profiledAccount;
        System.Debug('objAccount ----> ' + profiledAccount) ;       
      	//Account profiledAccount = [Select Id from Account where PROFILED_ACCOUNT_FLAG__c = true limit 1];
    	CxP_Mapping__c cxpMappingTestRecord = new CxP_Mapping__c();
    	cxpMappingTestRecord.Partner_Profiled_Account__c = profiledAccount.Id;
    	cxpMappingTestRecord.Type__c = 'CORE';
    	insert cxpMappingTestRecord;
    	return cxpMappingTestRecord;
    }
}