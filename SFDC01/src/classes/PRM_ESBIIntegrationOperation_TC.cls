/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  24.03.2011      Suman B                		This is Test class for  PRM_ESBIIntegrationOperation 
 |  28/03/2011	  	Anand Sharma				Created custom setting value through test class 
 +=========================================================================================================================*/

@istest
private class PRM_ESBIIntegrationOperation_TC {

  	static testMethod void getControlFlagWithBatchId_Test() {
  		User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        } 
  		List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag';
    	dataValueControlFlag.DataValue__c ='START';
    	lstDataValue.add(dataValueControlFlag);
    	
    	CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
    	dataValueControlFlag1.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag1.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag1); 
    	
    	CustomSettingDataValueMap__c dataValueControlFlag2 = new CustomSettingDataValueMap__c();
    	dataValueControlFlag2.Name ='ESBI_Schedule_DeleteJobID';
    	dataValueControlFlag2.DataValue__c ='08eQ00000003iSAIAY';
    	lstDataValue.add(dataValueControlFlag2);     	
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
  	
   		PRM_ESBI_IntegrationResult objESBIResult = PRM_ESBIIntegrationOperation.getControlFlagWithBatchId();
   		objESBIResult.setBatchId(1);
   		objESBIResult.setErrorMessage('FAIL');
   		objESBIResult.getBatchId();
   		objESBIResult.getStatusMessage();
   	}
  
  	static testmethod void setControlFlagWithBatchId_Test(){
  		User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }       
  		List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
    	CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
    	dataValueControlFlag.Name ='ESBI_Int_Control_Flag';
    	dataValueControlFlag.DataValue__c ='START';
    	lstDataValue.add(dataValueControlFlag);
    	
    	CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
    	dataValueControlFlag1.Name ='ESBI_Int_Control_Flag_Sequence';
    	dataValueControlFlag1.DataValue__c ='2';
    	lstDataValue.add(dataValueControlFlag1); 
    	
    	CustomSettingDataValueMap__c dataValueControlFlag2 = new CustomSettingDataValueMap__c();
    	dataValueControlFlag2.Name ='ESBI_Schedule_DeleteJobID';
    	dataValueControlFlag2.DataValue__c ='08eQ00000003iSAIAY';
    	lstDataValue.add(dataValueControlFlag2);
    	   	
    	try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
   		PRM_ESBIIntegrationOperation.setControlFlagWithBatchId('START', 1224 );
   		PRM_ESBIIntegrationOperation.setControlFlagWithBatchId('ERROR', 1224 );
   		PRM_ESBIIntegrationOperation.setControlFlagWithBatchId('COMPLETE', 1224 );   
   	}
    
 }