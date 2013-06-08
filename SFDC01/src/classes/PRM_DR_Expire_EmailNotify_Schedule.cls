/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
  Test Class Name                                     PRM_DR_Expire_EmailNotify_Schedule_TC                                                     
| 11/19/2012    Krishna Pydavula        203853        This class is used to Schedule the Expiry email Notifications class. 
                                                                                                          
+=====================================================================================================*/

global class PRM_DR_Expire_EmailNotify_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        
                PRM_DR_Expire_EmailNotify_Batchjob drexp= new PRM_DR_Expire_EmailNotify_Batchjob();
                Database.executebatch(drexp,10);
    }
 }