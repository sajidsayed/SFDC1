/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
  Test Class Name 									   Populate_Detail_lines_House_Acc_Sch_TC                                                     
| 11/20/2012     Krishna Pydavula        212217        This class is used to Schedule the 'Populate_Detail_lines_House_Account' class. 
                                                                                                          
+=====================================================================================================*/
global class Populate_Detail_lines_House_Acc_Schedule implements Schedulable {
	
    global void execute(SchedulableContext SC) {
        
                Populate_Detail_lines_House_Account detaillines= new Populate_Detail_lines_House_Account();
                Database.executebatch(detaillines); 
    }
 }