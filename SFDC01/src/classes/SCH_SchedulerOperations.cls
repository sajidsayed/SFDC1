/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER          WR       DESCRIPTION                               
 |  ====       =========          ==       =========== 
 |             Prasad Kothawade            Created
 |  18-JUN-09  Sandy Douglas               Updated for Account Team Member Batch Delete
    08 APR 13   Avinash K       Bug Fix     Updated class to schedule the batch class with different condition when it is 
                                            being called from a test class
 +===========================================================================*/
public class SCH_SchedulerOperations 
{ 
    public static boolean processUpdates = true;  //Flag to make sure we only run the update trigger code once  
    
    public static Datetime calcNewRunDate(Datetime oldRunDate, String recurrence){
        System.debug('****************************************SCH_SchedulerOperations.calcNewRunDate*****************************************');
        System.debug('oldRunDate = ' + oldRunDate);
        System.debug('recurrence = ' + recurrence);
        Datetime newRunDate = oldRunDate;   
        if( recurrence == 'Daily' ){
            newRunDate = oldRunDate.addDays(1); 
        }
        if( recurrence == 'Weekly' ){
            newRunDate = oldRunDate.addDays(7);               
        }
        if( recurrence == 'Fortnightly' ){
            newRunDate = oldRunDate.addDays(14);               
        }
        if( recurrence == 'Monthly' ){
            newRunDate = oldRunDate.addMonths(1);
        }
        if( recurrence == 'Quarterly' ){ 
            newRunDate = oldRunDate.addMonths(3);
        }
        if( recurrence == 'Yearly' ){
            newRunDate = oldRunDate.addYears(1);
        }
    
        System.debug('newRunDate = ' + newRunDate);
        return newRunDate;
    } // calcNewRunDate


    public static void Controller(List<Job_Scheduler__c> jobs ){
        System.debug('****************************************SCH_SchedulerOperations.Controller*****************************************');
        for(Job_Scheduler__c js : jobs )
        {
            System.Debug('Processing Job Operation = ' + js.Operations__c + ' [Job ID = ' + js.Id + ']');
            if(js.Account_Locking__c==true) continue;
            executeBatch(js);
        } // for loop
        
        List<Job_Scheduler__c> lstJobSchedulerDeleted= new List<Job_Scheduler__c>();
        List<Job_Scheduler__c> lstJobSchedulerUpdated= new List<Job_Scheduler__c>();
        List<Job_Scheduler__c> lstJobSch= new List<Job_Scheduler__c>([Select Name,Status__c,Operations__c,LastModifiedDate,Id from Job_Scheduler__c where Account_Locking__c=true order by LastModifiedDate asc]);

//Code added by Avinash K begins below...

        if(Test.isRunningTest())
        {
            lstJobSch = new List<Job_Scheduler__c>([Select Name,Status__c,Operations__c,LastModifiedDate,Id from Job_Scheduler__c where Account_Locking__c=true order by LastModifiedDate asc limit 1]);
        }

//Code added by Avinash k ends above.
        
        for(Job_Scheduler__c jsJob: lstJobSch)
        {
            System.debug('jsJob= ' + jsJob);
            if(jsJob.Status__c=='Complete')
            {
                lstJobSchedulerDeleted.add(jsJob);
            }
            if(jsJob.Status__c=='Executing')
            {
                continue;
            }
            if(jsJob.Status__c=='Pending')
            {
                jsJob.Status__c='Executing';
                
                
                executeBatch(jsJob);
                lstJobSchedulerUpdated.add(jsJob);
                break;
            }
        }
        System.debug('lstJobSchedulerUpdated= ' + lstJobSchedulerUpdated);
        System.debug('lstJobSchedulerDeleted= ' + lstJobSchedulerDeleted);   
        if(lstJobSchedulerUpdated.size()>0)
        {
            update lstJobSchedulerUpdated;
        }
        if(lstJobSchedulerDeleted.size()>0)
        {
            delete lstJobSchedulerDeleted;
        }
       //Update by Shipraa end of for loop
    } // Controller
    
    public static void executeBatch (Job_Scheduler__c jsJob)
    {
        if(jsJob.Operations__c == 'Batch Delete Account Team Members') 
        {
            //Kick off the batch apex job to delete account team members
            AT_BatchDeleteAccountTeamMembers deleteAcctBatch =  new AT_BatchDeleteAccountTeamMembers();
            ID batchProcessId = Database.executeBatch(deleteAcctBatch);
            System.Debug('Batch Process Id = ' + batchProcessId);
        }
        else if(jsJob.Operations__c == System.Label.TA_Sync_Update_Record) 
        {
            //Kick off the batch apex job to update TA Sync record for ROW COUNT VALIDATION.
            String query = '';
            Update_TA_Sync_Records_SFDC_Count UpdateTASyncForRowCount =  new Update_TA_Sync_Records_SFDC_Count(jsJob,query);
            ID batchProcessId = Database.executeBatch(UpdateTASyncForRowCount);
            System.Debug('Batch Process Id = ' + batchProcessId);
            
        }
            //#### Account Presentaion : Batch Job 1 
        else if(jsJob.Operations__c=='Core Quota Rep')
         {
  
            Integer batchID;
            Decimal maxBatchid;
            Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
            CustomSettingDataValueMap__c maxBatch = (mapCustomSettingDataValueMap.get('Max Batch Id'));
            if(maxBatch.DataValue__c!=null){
            maxBatchid = Decimal.valueOf(maxBatch.DataValue__c);
           // maxBatchid = maxBatch.DataValue__c;
            system.debug('maxBatchid--->'+maxBatchid);
            if(maxBatchid != null){
            batchID = maxBatchid.intValue();
            
            
            Core_Quota_Rep__c togetCurrentBatchId;
            //togetCurrentBatchId = [SELECT Batch_ID__c FROM Core_Quota_Rep__c where Name!='' and Batch_ID__c = :maxBatchid Limit 1];
           // batchID = Integer.ValueOf(togetCurrentBatchId.Batch_ID__c);           
            System.debug('batchID------->'+ batchID);
            AP_BatchDeleteCQRData batchDeleteCQRObj =  new AP_BatchDeleteCQRData(jsJob,batchID);  
            //ID batchProcessId = Database.executeBatch(batchDeleteCQRObj,batchSize);
            ID batchProcessId = Database.executeBatch(batchDeleteCQRObj);
           System.Debug('Batch Process Id inside CQR = ' + batchProcessId);                
           }//Not Null maxBatchId Decimal
           }//Not Null
           else{
           System.debug('Custom Setting Value Max Batch Id is null---'+maxBatch.DataValue__c);
           }
          
        }
        //return jsJob;
    }
    public static void initScheduler(List <Job_Scheduler__c> inboundJobs){

        System.debug('****************************************SCH_SchedulerOperations.initScheduler*****************************************');
             
        for(Job_Scheduler__c js : inboundJobs){

            if (js.Next_Schedule__c == null) {
                js.Next_Schedule__c = Datetime.newInstance(
                                        js.Start_Date__c.year(),
                                        js.Start_Date__c.month(),
                                        js.Start_Date__c.day(),
                                        (js.Schedule_Hour__c).intValue(), 
                                        js.Minutes__c.intValue(),0);
                
                System.debug('js.Next_Schedule__c  '+ js.Next_Schedule__c);
            }
            if (js.End_Date__c == null || System.Today() <= js.End_Date__c)        
                js.update_me__c = '0';  //will result in time-based workflow being scheduled
            else
                js.update_me__c = '1';  //we don't want to schedule the workflow today is after the end-date 
                     
            if(js.Operations__c=='Core Quota Rep')
            {
                js.Account_Locking__c = true;
                js.Status__c = 'Pending';
            }       
            }  // for loop
            
            
       

    } // initScheduler

    public static void ProcessScheduleUpdates(List <Job_Scheduler__c> inboundNewSchedules, List <Job_Scheduler__c> inboundOldSchedules) {
    
        System.debug('****************************************ProcessScheduleUpdates*****************************************');
    
        List <Job_Scheduler__c> newSchedules = new List <Job_Scheduler__c>();  //To be inserted
        List <Job_Scheduler__c> oldSchedules = new List <Job_Scheduler__c>();  //To be deleted
        List <Job_Scheduler__c> jobsToRun = new List <Job_Scheduler__c>();  //To be run
               
        if(processUpdates) 
        {
             
            processUpdates = false;  // Prevent running a second time  
    
            //Note:  We can't simply update the existing record, because updates made by a workflow
            //       won't trigger another workflow.  We must delete the old record 
            //       and insert a new one with updated NextSchedule (all the rest of the data is unchanged)
            for(integer i=0 ; i< inboundNewSchedules.size(); i++ ){
                System.debug('Processing ID = ' + inboundNewSchedules[i].Id);
                System.debug('Processing ID = ' + inboundNewSchedules[i].Id);
                if (inboundNewSchedules[i].Update_Me__c != '0') {
                    System.debug('Update flag != 0');
    
                    Job_Scheduler__c js = new Job_Scheduler__c();
                    js.Name = inboundNewSchedules[i].Name;
                    js.Operations__c = inboundNewSchedules[i].Operations__c;
                    js.Start_Date__c = inboundNewSchedules[i].Start_Date__c;
                    js.End_Date__c = inboundNewSchedules[i].End_Date__c;
                    js.Schedule_Hour__c = inboundNewSchedules[i].Schedule_Hour__c;
                    js.Minutes__c = inboundNewSchedules[i].Minutes__c;
                    js.Occurence__c = inboundNewSchedules[i].Occurence__c;
                    DateTime nextSchedule = calcNewRunDate(inboundNewSchedules[i].Next_Schedule__c, js.Occurence__c);
                    System.debug('Job Scheduler Name = ' + js.Name);
                    System.debug('End Date = ' + js.End_Date__c);
                    System.debug('Calculated Next Schedule = ' + nextSchedule);
                    //If the calculated next schedule date is after the end-date leave it unchanged
                    if ( js.End_Date__c == null ||
                            nextSchedule <= Datetime.newInstance(
                                            js.End_Date__c.addDays(1).year(),
                                            js.End_Date__c.addDays(1).month(),
                                            js.End_Date__c.addDays(1).day(),
                                            0, 
                                            0,
                                            0 ) && js.Operations__c == 'Send Opportunity Integration Logs Limit Email') 
                    {
                        double minutes=inboundNewSchedules[i].Minutes__c;
                        double hours=inboundNewSchedules[i].Schedule_Hour__c;
                        System.debug('minutes=' + minutes);
                        nextSchedule = nextSchedule.addHours(hours.intValue()); 
                        nextSchedule = nextSchedule.addMinutes(minutes.intValue());
                        js.Next_Schedule__c = nextSchedule;  //set to new, calculated value
                    }
                    else
                    {
                        js.Next_Schedule__c = inboundNewSchedules[i].Next_Schedule__c;  //keep old value
                    }
                    System.debug('Setting Next Schedule = ' + js.Next_Schedule__c);
                                                
                    js.Update_Me__c = '0';
                    
                    //Add this job to the jobs to run collection
                    jobsToRun.add(inboundNewSchedules[i]);
                    //If we have not passed the end-date, insert the new schedule record and delete the old one
                    if (js.Next_Schedule__c != inboundNewSchedules[i].Next_Schedule__c && js.Operations__c != System.Label.TA_Sync_Update_Record && js.Operations__c != 'Core Quota Rep') {
                        System.Debug('Inserting New Schedule Record and Deleting Old Record');
                        newSchedules.add(js);
                        oldSchedules.add(new Job_Scheduler__c(id=inboundNewSchedules[i].id));
                        
                    }
                    
                }  //if Update_Me__c != 0
            
            }  //for loop
            //if oration c js.acc ='pending, js.al==true
            System.debug('jobsToRun---->'+jobsToRun);
            Controller(jobsToRun); 
            insert newSchedules;                   
            delete oldSchedules;
      
        } //if processScheduleUpdates 

    }  // ProcessScheduleUpdates

    // Method used by the unit test code which will reset the processUpdates flag
    // since test code must do several updates
    public static void resetFlagsForUnitTest() {
        System.debug('****************************************resetFlagsForUnitTest*********************************');
        processUpdates = true;
    }  //resetFlagsForTest
    
}