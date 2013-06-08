/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  19.01.2012      Anand Sharma                This is used to perform opeartion between SFDC and Oracle for TA Process
 +=========================================================================================================================*/
global class TA_Sync_IntegrationOperation {
	
	webservice static Integer getBatchId()
    {  
    	Integer intBatchIb;
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('TASync_Int_Control_Flag_Sequence');
        if(seqeunceId.DataValue__c != null && seqeunceId.DataValue__c != ''){
            intBatchIb = Integer.valueOf(seqeunceId.DataValue__c);           
        }                    
        return intBatchIb;
    }

    webservice static void setControlFlagWithBatchId(String processingStatus, Integer batchid )
    {
        List<CustomSettingDataValueMap__c> lstDataValueMap = new List<CustomSettingDataValueMap__c>();        
        CustomSettingDataValueMap__c   controlFlag = CustomSettingDataValueMap__c.getValues ('TASync_Int_Control_Flag');
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues  ('TASync_Int_Control_Flag_Sequence');
        
        controlFlag.DataValue__c = processingStatus;
        Integer intBatchId = batchid;
      	if( processingStatus.equals('COMPLETE')){      
            intBatchId = intBatchId + 1;
            seqeunceId.DataValue__c = String.valueOf(intBatchId);          
            controlFlag.DataValue__c = 'START';
            lstDataValueMap.add(seqeunceId);
            lstDataValueMap.add(controlFlag);
            System.Debug('Incrementing the sequence'+ intBatchId);          
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false);
         	
         	String accountTAQuery =  'Select Id, Text5__c, Text4__c, Text3__c, Text2__c, Text1__c, Object_Name__c, Batch_Id__c From Staging_Data__c '
                                  + 'WHERE Object_Name__c = \'TASync\' AND Batch_Id__c ='+ (batchid)  ;
                               
         	database.executeBatch(new TASynch_AccountTeamJob(accountTAQuery) , 200);
         	
       	}
         
        if( processingStatus.equals('ERROR'))
        {   
            controlFlag.DataValue__c = processingStatus;
            lstDataValueMap.add(controlFlag);
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false); 
            
            String accountTAQuery =  'Select Id, Text5__c, Text4__c, Text3__c, Text2__c, Text1__c, Object_Name__c, Batch_Id__c From Staging_Data__c '
                                  + 'WHERE Object_Name__c = \'TASync\' AND Batch_Id__c ='+ (batchid)  ;
                                  
            database.executeBatch(new PRM_BatchDeleteStaging(accountTAQuery) , 200);
        }
    
        if( processingStatus.equals('START'))
        {   
            controlFlag.DataValue__c = 'PROCESSING';
            lstDataValueMap.add(controlFlag);
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false);       
            system.debug('*** Changed status from START TO PROCESSING');            
        }
        
    } 

}