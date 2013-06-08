/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 9/9/2010       Ashwini Gowda        Req # 991    This class is used for the Scheduling Purpose if,
 													the accounts with same SiteDuns are exceeding the DML Limits
 													in the following scenarios:
 													1. Creation of a Grouping 
 |													2. Updation of a Grouping 
 													3. Deactivation of a Grouping 
 |													4. Updating a Non Profiled Account. 
 													Its coming across this Limit because there are multiple accounts
 													with same SITE_DUNS/ENTITY_ID. 
 +===========================================================================*/

global class PRM_GroupingScheduler implements Schedulable{
    
/* @Method <execute(): for scheduling>
   @param <SchedulableContext SC>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    global void execute(SchedulableContext SC){
        PRM_GroupingSchedulerOperation scheduleOperations = 
        new PRM_GroupingSchedulerOperation();
        scheduleOperations.operateSimilarAccounts();
    }
}