/*=====================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 

| 24/11/2010     Karthik Shivprakash      846           This scheduler class is used to fetch the 
                                                        newly created associated accounts to create
                                                        the association with its related accounts.  
|
+=====================================================================================================*/

global class PRM_GroupingAssociationScheduler implements Schedulable{
	
PRM_GroupingAssociationOperation Obj = new PRM_GroupingAssociationOperation();


/* @Method <This method execute is used to schedule to create
			association within the group>
@param <SchedulableContext to keep track of the scheduled job once it's scheduled>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

 	global void execute(SchedulableContext SC){
 		Obj.fetchingOfBulkAccounts();
    }
}