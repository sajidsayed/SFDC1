/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  22-Nov-2011   Prasad                            This class has been scheduled for Matching and VPP jobs run. 
                                                    This has been taken out from ESBI webserive. 
                                                    
 | 28-Dec-2011    Anand Sharma                      Added  Theater Job to run getStagingTheaterJob
 | 02-Feb-2012    Anand Sharma                      Added Partner Lev Jobs  
 | 03-May-2012    Anirudh Singh                     Added Functional Area Job    
   05/08/2012    Prasad                             VPP improvement 
   09/05/2012    Prasad                             VPP PAN Delta   
 +==================================================================================================================*/
global class PRM_ESBI_VPP_Jobs_Scheduler implements Schedulable {       
    
     Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
     PRM_JobFactory JobFactory = new PRM_JobFactory();
        
    global void execute(SchedulableContext sc){
        
        CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Theaters = DataValueMap.get('ESBI_VPP_Scheduled_Theaters'); 
        String theaters=ESBI_VPP_Scheduled_Theaters.datavalue__c;
        List<SequencialBatchJob>LstSeqJobs=new List<SequencialBatchJob>();
         
        // Verify Grouping theaters
        LstSeqJobs.add(JobFactory.getStagingTheaterJob());
        //Create Education Master
        LstSeqJobs.add(JobFactory.getEducationMasterJob());    
              
           if(theaters.indexOf('All')!=-1){ 
               LstSeqJobs.addALL(getJobs('All'));
               SequencialBatchJobScheduler.executeSequence(LstSeqJobs);
               
               System.debug(LstSeqJobs.size());
               for(SequencialBatchJob job :LstSeqJobs){
                   System.debug('name  ' +job.getjobName());
               }                
               return;
            }
           if(theaters.indexOf('APJ')!=-1){ 
               LstSeqJobs.addALL(getJobs('APJ'));
               
            }
           if(theaters.indexOf('EMEA')!=-1){ 
              LstSeqJobs.addALL(getJobs('EMEA'));
          } 
           if(theaters.indexOf('Americas')!=-1){ 
               LstSeqJobs.addAll(getJobs('Americas'));
          }            
       System.debug(LstSeqJobs.size());
       for(SequencialBatchJob job :LstSeqJobs){
           System.debug('name  ' +job.getjobName());
       }           
            
       SequencialBatchJobScheduler.executeSequence(LstSeqJobs);

    } 
    
    private List<SequencialBatchJob> getJobs(String Theater){
    
         List<SequencialBatchJob>LstSeqJobs=new List<SequencialBatchJob>();
         
        
         CustomSettingDataValueMap__c ESBI_VPP_Scheduled_Jobs = DataValueMap.get('ESBI_VPP_Scheduled_Jobs');
         String jobs = ESBI_VPP_Scheduled_Jobs.datavalue__c;
          
          LstSeqJobs.addAll(JobFactory.getEducationMatchingJobs(Theater));
          if(jobs.indexOf('VPP - Country Level,VPP - Logical Block Level,VPP - PAN Theater Level')!=-1){ 
             LstSeqJobs.addAll(JobFactory.getVPPJobs(Theater,'All')); 
          
          }else {
              if(jobs.indexOf('VPP - Country Level')!=-1){ 
                  LstSeqJobs.addAll(JobFactory.getVPPJobs(Theater,'Country')); 
              
              }if(jobs.indexOf('VPP - Logical Block Level')!=-1){ 
                  LstSeqJobs.addAll(JobFactory.getVPPJobs(Theater,'Logical Block')); 
              
              }if(jobs.indexOf('VPP - PAN Theater Level')!=-1){ 
                  LstSeqJobs.addAll(JobFactory.getVPPJobs(Theater,'PAN Theater')); 
              }
          }
          if(jobs.indexOf('Partner Leverage')!=-1){ 
              LstSeqJobs.addAll(JobFactory.getPartnerLevrageJobs(Theater)); 
          } 
          if(jobs.indexOf('Funcational Area')!=-1){ 
              LstSeqJobs.add( JobFactory.getFunctionalAreaJob(Theater));
          } 
         
         return LstSeqJobs; 
    }
}