/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  31/03/2011    Anand Sharma                      Delete staging data record 
 													by manually schedule 
 +===========================================================================*/
global class PRM_ScheduleBatchDeleteStaging_Manually implements Schedulable{
	
	//Execute batch class with default constructor from schedular
    global void execute(SchedulableContext sc) {
        //execute batch job 
        database.executebatch(new PRM_BatchDeleteStaging());
   } 
}