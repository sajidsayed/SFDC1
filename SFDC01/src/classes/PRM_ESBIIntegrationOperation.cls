/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  25.02.2011      Anand Sharma                This is used to store result for EBSI Integration Process
 |  26.08.2011      Suman B                     Modified setControlFlagWithBatchId() method , to set VPP cunstomsetting values
                                                for 'PRMVPPALLJobExecution' and 'PRMVPPDeleteJobExecutionVelocityRule' to true.
    21/11/2011   Prasad K                       Sequential Batch job logic updated (theater wise)      
    05/08/2011    Prasad                        VPP improvement                                              
 +=========================================================================================================================*/
 
global class PRM_ESBIIntegrationOperation {
    
    
    webservice static PRM_ESBI_IntegrationResult getControlFlagWithBatchId()
    {       
        PRM_ESBI_IntegrationResult objIntegrationResult = null;
        
        Map<String, String> mapBatchStatus = new Map<String, String>(); 
        CustomSettingDataValueMap__c   controlFlag = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag');
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
        if(seqeunceId.DataValue__c != null && seqeunceId.DataValue__c != ''){
            Integer intBatchIb = Integer.valueOf(seqeunceId.DataValue__c);
            objIntegrationResult = new PRM_ESBI_IntegrationResult(controlFlag.DataValue__c, intBatchIb);
        }
                    
        return objIntegrationResult;
    }

    webservice static void setControlFlagWithBatchId(String processingStatus, Integer batchid )
    {
        List<CustomSettingDataValueMap__c> lstDataValueMap = new List<CustomSettingDataValueMap__c>();
        
        CustomSettingDataValueMap__c   controlFlag = CustomSettingDataValueMap__c.getValues ('ESBI_Int_Control_Flag');
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues  ('ESBI_Int_Control_Flag_Sequence');
        
        controlFlag.DataValue__c = processingStatus;
        Integer intBatchId = batchid;
      if( processingStatus.equals('COMPLETE'))
        {      
            intBatchId = intBatchId + 1;
            seqeunceId.DataValue__c = String.valueOf(intBatchId);
            //controlFlag.DataValue__c = processingStatus;
            /* Added by Suman - 4th Mar */  
            controlFlag.DataValue__c = 'START';
            lstDataValueMap.add(seqeunceId);
            lstDataValueMap.add(controlFlag);
            System.Debug('Incrementing the sequence'+ intBatchId);          
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false);
         
         /*
          //Schedule the next batch job to run for 2 minutes later:
            Datetime dt = System.now();
            dt = dt.addMinutes(2);
            String scheduleString='0';//0 seconds
            scheduleString+=' '+ dt.minute();
            scheduleString+=' '+ dt.hour();
            scheduleString+=' '+ dt.day();
            scheduleString+=' '+ dt.month();
            scheduleString+=' ?';
            scheduleString+=' '+ dt.year();     
            System.debug('currently scheduled time for EducationMaster ' + scheduleString); 
           
           CustomSettingDataValueMap__c jobObjectDetails = CustomSettingDataValueMap__c.getValues('PRMVPPALLJobExecution');
           if(jobObjectDetails.DataValue__c=='false'){
              jobObjectDetails.DataValue__c ='true';
              update jobObjectDetails;
           }
           CustomSettingDataValueMap__c jobVelocityRuleCheckDetails = CustomSettingDataValueMap__c.getValues('PRMVPPDeleteJobExecutionVelocityRule');
           if(jobVelocityRuleCheckDetails.DataValue__c=='false'){
              jobVelocityRuleCheckDetails.DataValue__c ='true';
              update jobVelocityRuleCheckDetails;
           }
         /*   string batchIdQuery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
                                    +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c from Staging_Data__c s'
                                    + ' where s.Object_Name__c=\'Education Master\' AND Batch_Id__c ='+ batchid;
         
           PRM_PopulateEducationMasterBatch objSchedule = new PRM_PopulateEducationMasterBatch(batchIdQuery);
         */
       /* PRM_PopulateEducationMasterBatch objSchedule = new PRM_PopulateEducationMasterBatch();
        Id ScheduleBatchEducationId = System.schedule('Schedule EducationMaster Batch',scheduleString , objSchedule);
       */
    
         /*  
           
           As delinking the stuff.
           
           List<SequencialBatchJob>LstSeqJobs=getESBIJobs('APJ');
           LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().scheduleVPPJobs('APJ'));
           
           LstSeqJobs.addAll(getESBIJobs('EMEA'));
           LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().scheduleVPPJobs('EMEA'));
           
           LstSeqJobs.addAll(getESBIJobs('Americas'));
           LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().scheduleVPPJobs('Americas'));
           
            SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
           */
       }
        
        if( processingStatus.equals('ERROR'))
        {   
            controlFlag.DataValue__c = processingStatus;
            lstDataValueMap.add(controlFlag);
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false);       
            system.debug('*** Call the delete api');            
            PRM_ESBIIntegrationOperation.deleteFailBatch(intBatchId);
            
        }
     /* Added by Suman */
            if( processingStatus.equals('START'))
        {   
            controlFlag.DataValue__c = 'PROCESSING';
            lstDataValueMap.add(controlFlag);
            Database.Saveresult[] srResult = Database.update(lstDataValueMap, false);       
            system.debug('*** Changed status from START TO PROCESSING');            
        }
        
    } 
    
    public static void deleteFailBatch(Integer batchid)
    {
        system.debug('*** Deleting all jobs with the given batch id*****' + batchid);
        String strQuery = 'Select id from Staging_data__c where Batch_Id__c = ' + batchid;
        //Schedule the next batch job to run for 2 minutes later:
        Datetime dt = System.now();
        dt = dt.addMinutes(2);
        String scheduleString ='';
        scheduleString += dt.second();//0 seconds
        scheduleString +=' '+ dt.minute();
        scheduleString +=' '+ dt.hour();
        scheduleString +=' '+ dt.day();
        scheduleString +=' '+ dt.month();
        scheduleString +=' ?';
        scheduleString +=' '+ dt.year();        
        System.debug('currently scheduled time for staging data delete  ' + scheduleString); 
        
        CustomSettingDataValueMap__c   controlFlag = CustomSettingDataValueMap__c.getValues ('ESBI_Int_Control_Flag');
        controlFlag.DataValue__c = 'PROCESSING';
        update controlFlag;
        
        CustomSettingDataValueMap__c   scheduleJob = CustomSettingDataValueMap__c.getValues ('ESBI_Schedule_DeleteJobID');
        System.debug('scheduleJob.DataValue__c ++++++++++  ' + scheduleJob.DataValue__c);
        PRM_ESBIIntegrationOperation.abortScheduleJob(scheduleJob.DataValue__c);
                                
        PRM_BatchDeleteStaging  objSchedule= new PRM_BatchDeleteStaging(strQuery);
        Id ScheduleStagingBatchId = System.schedule('Schedule Staging Delete Batch Job',scheduleString , objSchedule);
        
        scheduleJob.DataValue__c = ScheduleStagingBatchId;
        update scheduleJob;
                
    } 
    
    public static void deleteStagingData(List<Staging_Data__c> lstStagingData) 
    {
        System.debug('*** Deleting lstStagingData*****' + lstStagingData);
        if(lstStagingData != null && lstStagingData.size() >0){
            Database.DeleteResult[] srResult = Database.delete(lstStagingData, false);
        }       
    }
    
    public static void abortScheduleJob(Id schedulejobId){
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :schedulejobId];
            System.debug('Already schedule job details ' + ct); 

            if(ct != null) {
                System.abortJob(ct.Id);                
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }   
    }
   
   
    
  
   
    
}