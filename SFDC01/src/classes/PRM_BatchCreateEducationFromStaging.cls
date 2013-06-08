/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  15/12/2010    Anand Sharma                      Populate Contact id on education record 
    21-Nov-2011    Prasad                           Sequentail batch logic
    17/10/2012  Krishna Pydavula         197607     Added code snippet to send an email 
    15/11/2012     vivek kodi            197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 +===========================================================================*/

global class PRM_BatchCreateEducationFromStaging extends SequencialBatchJobScheduler {

    //holds query string 
    global final String Query;
    
    
    //Used to store the data mapping for the education master using the custom setting.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    List<CustomSettingDataValueMap__c > lstUpdateList = new List<CustomSettingDataValueMap__c >();
    
    //default constructor
    global PRM_BatchCreateEducationFromStaging (){              
        String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                            + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c, Batch_Id__c from Staging_Data__c ' 
                            +  'where is_Header__c != true AND Object_Name__c =\'Education\'';  
                                
        System.Debug('stagingQuery --->' + stagingQuery);                               
        this.Query = stagingQuery ;
    }
   
   //Parameterised constructor
    global PRM_BatchCreateEducationFromStaging (String query){              
        System.Debug('PArameter constructor Query --->' + query);   
        this.Query = query ;                            
    }
    
    //create batch of records which is passed to execute method for processing
    global override Database.QueryLocator start(Database.BatchableContext BC){
    	 //code added for WR 197607
	    	 if(BC != null && BC.getJobId() !=null){
	        	batchprocessid=BC.getJobId();
	        	 List<EMCException> emailerrors = new List<EMCException>();
                 SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
                }  
         //End of code for  WR 197607
        return Database.getQueryLocator(query);
    }
    
    //Update the list of passed account scope and break the context to handle governer limit
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Staging_Data__c> lstEduStaging = (List<Staging_Data__c>) scope;
        // call static method "PRM_EducationHelper" of "createEducationAndpopulateContact" helper class 
        //and pass list of Education_Staging__c as parameter  
        //PRM_EducationHelper.createEducationAndpopulateContact(lstEduStaging);
        //PRM_EducationHelper.verifyExistingEducationStagingData(lstEduStaging);
         PRM_EducationHelper.verifyExistingEducationStagingData(lstEduStaging,BC.getjobId(),emailerrors);
        
        PRM_JobFactory.loglimits('PRM_BatchCreateEducationFromStaging');
        
            
    }
    // no need to do any operation in this method as per current business logic.
   /* global void finish(Database.BatchableContext BC){       
        
        CustomSettingDataValueMap__c jobObjectId = DataValueMap.get('EducationDeleteScheduleId');
        if(jobObjectId != null){
            try {
                //Abort the existing schedule 
                CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobObjectId.DataValue__c];
                if(ct != null) {
                    System.abortJob(ct.Id);
                }
            } catch (Exception e) {
                System.debug('There are no jobs currently scheduled for delete. ' + e.getMessage()); 
            }
        }
        
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
        System.debug('currently scheduled. time for delete ' + scheduleString); 
   */
        //Used to store the data mapping for the education master using the custom setting.
/*      Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMap.get('EducationDeleteScheduleTime');
        String strSchedule =jobDeleteEducationTime.DataValue__c;
        CustomSettingDataValueMap__c   seqeunceId = DataValueMap .get('ESBI_Int_Control_Flag_Sequence');
           Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
           Integer batchId =  sequenceId -1 ;
                 
        String educationQuery = 'Select Id, Name from Education__c where lastModifieddate < ' + strSchedule + ' AND Education_Batch_Number__c ='+ batchId;  
                                    
        PRM_BatchDeleteEducation  objSchedule= new PRM_BatchDeleteEducation(educationQuery);
 */        
  /*     PRM_BatchDeleteEducation  objSchedule= new PRM_BatchDeleteEducation();
        Id ScheduleBatchEducationId = System.schedule('Schedule Education Delete Batch',scheduleString , objSchedule);
        if(ScheduleBatchEducationId != null){
            jobObjectId.DataValue__c =ScheduleBatchEducationId;
            update jobObjectId;
        }   
    }*/
    
    //Execute batch class with default constructor
   /* global void execute(SchedulableContext sc) {
        
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
        try
        {            
            batchSize  = Integer.valueOf(DataValueMap.get('EducationBatchSize').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 1;
        }
     CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
     Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
     Integer batchId =  sequenceId -1 ;
     String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                  + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c from Staging_Data__c ' 
                  +  'where is_Header__c != true AND Object_Name__c =\'Education\' AND Batch_Id__c ='+ batchId ;  

            //schedule Education record creation batch job 
           database.executebatch(new PRM_BatchCreateEducationFromStaging(stagingQuery), batchSize);
   } */
}