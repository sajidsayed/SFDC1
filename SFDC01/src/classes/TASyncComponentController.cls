/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    04-Apr-2011     Srinivas Nallapati      170056          To send reject count email     
==============================================================================*/
public class TASyncComponentController {
    public integer TotalRejectCount {get;set;}{TotalRejectCount =0;}
    public integer FinalRejectCount{get;set;}{FinalRejectCount=0;}
    public integer ProcessedInNextCycleCount {get;set;}{ProcessedInNextCycleCount =0;}
    public TASyncComponentController (){
         map<string,TASyncLimitCounter__c> mapTAlimitCounters = TASyncLimitCounter__c.getAll();
         if(mapTAlimitCounters.size() > 0){
             TotalRejectCount =  mapTAlimitCounters.size();
             ProcessedInNextCycleCount = 0;
             for(TASyncLimitCounter__c tal : mapTAlimitCounters.Values()){
                if(tal.IsProcessedInNextCycle__c!= null && tal.IsProcessedInNextCycle__c.contains('Processed'))
                    ProcessedInNextCycleCount++;
             }
             FinalRejectCount = TotalRejectCount - ProcessedInNextCycleCount;
          }
    }
}