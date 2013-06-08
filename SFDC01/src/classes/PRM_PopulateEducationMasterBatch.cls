/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 17/12/2010    Karthik Shivprakash       1314          This batch class is used to populate
                                                        education master data from staging data.
| 28/12/2010    Anand Sharma                            Added method to check duplicate record creation
                                                        for education master.   
                                                        
                                                        Called method to execute Education batch in finish method
  
  17/03/2011   Suman B                                  Added constructor with String as parameter.  
  21/11/2011   Prasad K                                 Sequenctail Batch job logic updated (theater wise)
  17/10/2012  Krishna Pydavula          197607          Added code snippet to send an email   
  15/11/2012   vivek kodi               197607          To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                                                                           
+=====================================================================================================*/

global class PRM_PopulateEducationMasterBatch extends SequencialBatchJobScheduler {
    
    //Here we are fetching the education master data from the staging data.
    final static string batchQuery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
                                    +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c from Staging_Data__c s'
                                    + ' where s.Object_Name__c=\'Education Master\'';
                 String finalquery ;
    //Used to store the data mapping for the education master using the custom setting.
    Map<String,CustomSettingEducationDataValueMapping__c> DataValueMap = CustomSettingEducationDataValueMapping__c.getAll();
    
    //Used to store level data mapping for the education master using the custom setting.
    Map<String,CustomSettingEducationMasterLevelMapping__c> LevelValueMap = CustomSettingEducationMasterLevelMapping__c.getAll();
    
    //Used to store the education master record in the list.
    List<Education_Master__c> EducationMaster = new List<Education_Master__c>();
    
    global PRM_PopulateEducationMasterBatch(){
        
        String ScheduleDeleteEducationTime = String.valueOfGmt(DateTime.Now().addMinutes(-1));
        ScheduleDeleteEducationTime  = ScheduleDeleteEducationTime.replace(' ', 'T');
        Map<String,CustomSettingDataValueMap__c> DataValueMapT = CustomSettingDataValueMap__c.getAll(); 
        finalquery = batchQuery;
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMapT.get('EducationDeleteScheduleTime');
        if(jobDeleteEducationTime != null){
            jobDeleteEducationTime.DataValue__c =ScheduleDeleteEducationTime +'.000Z';
            update jobDeleteEducationTime;
            
        }
    }
  
      global PRM_PopulateEducationMasterBatch(String query){
        
        String ScheduleDeleteEducationTime = String.valueOfGmt(DateTime.Now().addMinutes(-1));
        ScheduleDeleteEducationTime  = ScheduleDeleteEducationTime.replace(' ', 'T');
        Map<String,CustomSettingDataValueMap__c> DataValueMapT = CustomSettingDataValueMap__c.getAll(); 
        finalquery = query;
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMapT.get('EducationDeleteScheduleTime');
        if(jobDeleteEducationTime != null){
            jobDeleteEducationTime.DataValue__c =ScheduleDeleteEducationTime +'.000Z';
            update jobDeleteEducationTime;
            
        }
    }  
    
    /*@Method <The start() method gets executed acutomatically when the batch job is started.>
    @param <Database.BatchableContext BC - Batchable context>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    
   global override Database.QueryLocator start(Database.BatchableContext BC){                  
        System.debug('finalquery'+finalquery);
         //code added for WR 197607                
        if(BC != null && BC.getJobId() !=null){
	        	batchprocessid=BC.getJobId();
	        	List<EMCException> emailerrors = new List<EMCException>();
                SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
                }  
         //End of code for  WR 197607    
        return Database.getQueryLocator(finalquery);
    }
    
    /*@Method <The execute() method gets executed acutomatically when the batch job is execution mode.>
    @param <Database.BatchableContext BC - Batchable context>
    @param <List<Sobject> scope - scope>
    @return <void> - <Not returning anything>
    @throws exception - <No Exception>
    */
    
    global override void execute(Database.BatchableContext BC, list<SObject> scope){
        List<Staging_Data__c> DataStagingList =(Staging_Data__c[]) scope;
        System.debug('DataStagingList'+DataStagingList);
        if(DataStagingList.size()>0){
            populateEducationMaster(DataStagingList,BC.getjobID());
        }
    	PRM_JobFactory.loglimits('PRM_PopulateEducationMasterBatch');
    }
    
    /*@Method <The populateEducationMaster() method will fetch the data from staging data
         and populate that respective values in respective fields on education master>
      @param <This method takes the list of staging data as parameter>
      @return <Void>> - <Not returing anything>
      @throws exception - <No Exception>
    */
    
    public void populateEducationMaster(List<Staging_Data__c> DataStagingList,String Batchid){
        System.debug('DataStagingList in Populate'+DataStagingList);
        List<Staging_Data__c> lstWithDuplicateStagingRecord = new List<Staging_Data__c>();
        Education_Master__c EducationMasterObj;
        Database.SaveResult[] results;
        List <EMCException> errors = new List <EMCException>();
        if(DataStagingList.size()> 0){
            //call helper method to remove record which will create duplicate record.
            lstWithDuplicateStagingRecord = PRM_EducationMasterHelper.removeDuplicateStagingForEducationMaster(DataStagingList);
            System.debug('lstWithDuplicateStagingRecord  : -->'+lstWithDuplicateStagingRecord );
            if(lstWithDuplicateStagingRecord.size() <0) return;
            for(Staging_Data__c Obj: lstWithDuplicateStagingRecord){
                EducationMasterObj = new Education_Master__c();
                EducationMasterObj.ESBI_ID__c=Obj.Text5__c;
                EducationMasterObj.ESBI_Name__c=Obj.Text2__c;
                EducationMasterObj.ESBI_Category__c=Obj.Text3__c;
                EducationMasterObj.ESBI_Level__c=Obj.Text4__c;
                EducationMasterObj.ESBI_Type__c=Obj.Text1__c;
                EducationMasterObj.Modified_Name__c=Obj.Text2__c;
                EducationMasterObj.ESBI_Version__c = Obj.Text6__c;
                if(Obj.Text3__c!=null && DataValueMap.containsKey(Obj.Text3__c)){
                    if(DataValueMap.get(Obj.Text3__c).Category__c!='null'){
                        EducationMasterObj.Modified_Category__c=DataValueMap.get(Obj.Text3__c).Category__c;
                    }
                    else{
                        EducationMasterObj.Modified_Category__c=null;
                    }   
                }
                if(Obj.Text4__c!=null && LevelValueMap.containsKey(Obj.Text4__c)){
                    if(LevelValueMap.get(Obj.Text4__c).Level__c!='null'){
                        EducationMasterObj.Modified_Level__c=LevelValueMap.get(Obj.Text4__c).Level__c;
                    }
                    else{
                        EducationMasterObj.Modified_Level__c=null;
                    }
                }   
                if(Obj.Text1__c!=null && DataValueMap.containsKey(Obj.Text1__c)){
                    if(DataValueMap.get(Obj.Text1__c).Type__c!='null'){
                        EducationMasterObj.Modified_Type__c=DataValueMap.get(Obj.Text1__c).Type__c;
                    }
                    else{
                        EducationMasterObj.Modified_Type__c=null;
                    }
                }
                if(Obj.Text6__c!=null && DataValueMap.containsKey(Obj.Text6__c)){
                    if(DataValueMap.get(Obj.Text6__c).Version__c!='null'){
                        EducationMasterObj.Modified_Version__c = DataValueMap.get(Obj.Text6__c).Version__c;
                    }
                    else{
                        EducationMasterObj.Modified_Version__c = null;
                        System.debug('Modified Version'+EducationMasterObj.Modified_Version__c);
                    }
                }   
                else{
                    System.debug('Here its update');
                    EducationMasterObj.Modified_Version__c = Obj.Text6__c;
                }
                EducationMaster.add(EducationMasterObj);
            }
        }
            
        System.debug('EducationMaster'+EducationMaster);
        if(EducationMaster.size() >0 ){
            results= database.insert (EducationMaster,false);
            
            /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors); 
		            //send the error emails
		            emailerrors.addall(errors); 
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }		   
        }       
    }
    
    
    /*@Method <The finish() method gets executed acutomatically when the batch job is finised.>
      @param <Database.BatchableContext BC - Batchable context>
      @return <void> - <Not returning anything>
      @throws exception - <No Exception>
    */
    
   /* global void finish(Database.BatchableContext BC){
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();              
        CustomSettingDataValueMap__c jobObjectId = DataValueMap.get('EducationScheduleId');
        if(jobObjectId != null){
            try {
                //Abort the existing schedule
                Id JobId =  jobObjectId.DataValue__c;
                CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :JobId];
                if(ct != null) {
                    System.abortJob(ct.Id);
                }
            } catch (Exception e) {
                System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
            }
        }
        
        List<Staging_Data__c> lstStagingData = new List<Staging_Data__c>();
        
        lstStagingData =[Select Id from Staging_Data__c Where Object_Name__c='Education' LIMIT 1];
        
        if(lstStagingData.size()>0 ){
       /*   CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
           Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
           Integer batchId =  sequenceId -1 ;
           String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                            + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c from Staging_Data__c ' 
                            +  'where is_Header__c != true AND Object_Name__c =\'Education\' AND Batch_Id__c ='+ batchId ;  
            
            //schedule Education record creation batch job 
            PRM_BatchCreateEducationFromStaging  objSchedule= new PRM_BatchCreateEducationFromStaging(stagingQuery);
         */                       
        /*   PRM_BatchCreateEducationFromStaging  objSchedule= new PRM_BatchCreateEducationFromStaging();
           
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
            System.debug('currently scheduled. ' + scheduleString);     
            
                                        
            Id ScheduleBatchEducationId = System.schedule('Schedule Education Batch',scheduleString , objSchedule);
            
            //update custom setting value of job id.        
            if(ScheduleBatchEducationId != null){
                jobObjectId.DataValue__c =ScheduleBatchEducationId;
                update jobObjectId;
                
            } 
        }                    
    }*/
    
    //Execute batch class with default constructor
  /*  global void execute(SchedulableContext sc) {
       system.debug('INSIDE PRM_PopulateEducationMasterBatch - execute(schedulable)###'); 
        Integer batchSize = 20; // this will be overwritten in try block
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
      }

    CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
           Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
           Integer batchId =  sequenceId -1 ;
      
    string batchIdQuery = 'Select s.Date1__c, s.Date2__c, s.Id, s.Number1__c, s.Object_Name__c, s.Text1__c,'
                          +' s.Text2__c, s.Text3__c, s.Text4__c, s.Text5__c , s.Text6__c from Staging_Data__c s'
                          + ' where s.Object_Name__c=\'Education Master\' AND Batch_Id__c ='+ batchid;
                          
       //Here we are instantiating the batch class PRM_PopulateEducationMasterBatch to schedule.               
      PRM_PopulateEducationMasterBatch objSchedule = new PRM_PopulateEducationMasterBatch(batchIdQuery);          
     
        database.executebatch(objSchedule);         
   }   */ 
}