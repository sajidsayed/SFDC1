/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |   
    21-Nov-2011    Prasad                           Sequential batch logic 
 +===========================================================================*/
global class SequencialBatchJob {
    
    String JobName;
    SequencialBatchJobScheduler SequencialJob;
    integer BatchSize=200;
    String Status;
    integer StartAfterMins=2;
    
    public SequencialBatchJob(String JobName,SequencialBatchJobScheduler SequencialJob,integer BatchSize){
            this.BatchSize=BatchSize;
            this.JobName=JobName;
            this.SequencialJob=SequencialJob;
    }
    public SequencialBatchJob(String JobName,SequencialBatchJobScheduler SequencialJob){
            
            this.JobName=JobName;
            this.SequencialJob=SequencialJob;
    }
    public SequencialBatchJobScheduler getBatchJob(){
        return SequencialJob;
    }
    public string getJobName(){
        return JobName;
    }
    public integer getBatchSize(){
        return BatchSize;
    }
    public integer getStartAfterMins(){
        return StartAfterMins;
    }
    public void setStatus(String Status){
        this.Status=Status;
    }
}