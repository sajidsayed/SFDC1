/*====================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  02-Feb-2012   Anand Sharma                      This class has been scheduled for Partner Lev Jobs run.     
                                                    
 +==================================================================================================================*/
global class PRM_PartnerLev_Jobs_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        String theaters ='';
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll(); 
        CustomSettingDataValueMap__c PL_Scheduled_Theaters = DataValueMap.get('PL_Scheduled_Theaters'); 
        if(PL_Scheduled_Theaters != null && PL_Scheduled_Theaters.DataValue__c != null){
            theaters = PL_Scheduled_Theaters.datavalue__c;
        }
        List<SequencialBatchJob>LstSeqJobs=new List<SequencialBatchJob>();
      
        if(theaters.indexOf('APJ')!=-1){               
            LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().schedulePLTheaterwiseJobs('APJ'));               
        }
        if(theaters.indexOf('EMEA')!=-1){
            LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().schedulePLTheaterwiseJobs('EMEA'));               
        } 
        if(theaters.indexOf('Americas')!=-1){
            LstSeqJobs.addAll(new PRM_VPP_TEST_VelocityRuleResult().schedulePLTheaterwiseJobs('Americas')); 
        }         
        SequencialBatchJobScheduler.executeSequence(LstSeqJobs);

    } 
}