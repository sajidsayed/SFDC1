/*==================================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  17/12/2010    Anand Sharma                      Delete education record 
    28/07/2011    Suman B                           Updated finish method for scheduling the PRM_VPP_EducationEduationMasterGroupJob
    17/10/2012  Krishna Pydavula         197607     Added code snippet to send an email  
    15/11/2012   vivek kodi              197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
 +===================================================================================================================================*/
global class PRM_BatchDeleteEducation extends SequencialBatchJobScheduler{

    //holds query string 
    global final String Query;
    
    //default constructor
    global PRM_BatchDeleteEducation (){ 
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMap.get('EducationDeleteScheduleTime');
        String strSchedule =jobDeleteEducationTime.DataValue__c;
         
        String educationQuery = 'Select Id, Name from Education__c where lastModifieddate < ' + strSchedule ;   
        System.Debug('educationQuery --->' + educationQuery);                               
        this.Query = educationQuery ;
    }
    
    //Parameterised constructor
    global PRM_BatchDeleteEducation (String query){ 
        System.Debug('Parameter constructor educationQuery --->' + query);                              
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
        List<Education__c> lstEducation = (List<Education__c>) scope;
        // call static method "PRM_EducationHelper" of "deleteEducation" helper class 
        //and pass list of Education__c as parameter  
        //PRM_EducationHelper.deleteEducation(lstEducation);
          string Batchid = BC.getJobid();
        List <EMCException> errors = new List <EMCException>();
        if(lstEducation.size() >0){
			database.DeleteResult[] results = database.delete(lstEducation,false);
			
			//capturing error records
			 /* HANDLING EXCEPTION LOG*/
		        for (Database.DeleteResult sr : results) {
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
		      system.debug('BatchidBatchidvv'+Batchid);
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }		       
		}    
        PRM_JobFactory.loglimits('PRM_BatchDeleteEducation');    
    }
    // no need to do any operation in this method as per current business logic.
   /* global void finish(Database.BatchableContext BC){
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
        System.debug('currently scheduled. time for education eduMasterGroup  ' + scheduleString); 

        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
          Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
          Integer batchId =  sequenceId -1 ;
                                            
       String mappingQuery = 'Select e.Batch_Job_Operation__c, e.Id,Education_Master__c '
                               + 'from Education__c e '
                               + 'where Batch_Job_Operation__c!=null AND Education_Batch_Number__c = '+ batchId ;
                                    
        PRM_VPP_EducationEduationMasterGroupJob  objSchedule= new PRM_VPP_EducationEduationMasterGroupJob(mappingQuery);
        Id ScheduleBatchEducationEducMasterGroupId = System.schedule('Schedule Education EduMasterGroup Batch',scheduleString , objSchedule);
    
    }*/
    
    //Execute batch class with default constructor from schedular
   /* global void execute(SchedulableContext sc) {
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        
        //Used to store the data mapping for the education master using the custom setting.
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        CustomSettingDataValueMap__c jobDeleteEducationTime = DataValueMap.get('EducationDeleteScheduleTime');
        String strSchedule =jobDeleteEducationTime.DataValue__c;
        /*
        CustomSettingDataValueMap__c   seqeunceId = DataValueMap .get('ESBI_Int_Control_Flag_Sequence');
           Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
           Integer batchId =  sequenceId -1 ;
                 
        String educationQuery = 'Select Id, Name from Education__c where lastModifieddate < ' + strSchedule + ' AND Education_Batch_Number__c ='+ batchId;
        */  
      /*  String educationQuery = 'Select Id, Name from Education__c where lastModifieddate < ' + strSchedule;
        system.debug(educationQuery);                                    
        PRM_BatchDeleteEducation  objSchedule= new PRM_BatchDeleteEducation(educationQuery);
        database.executebatch(objSchedule);
   } */
}