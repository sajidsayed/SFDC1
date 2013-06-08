/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       		DEVELOPER     WR      	DESCRIPTION                               
 |  ====       		=========     ==       	=========== 
 |  13 Dec 2011		Shipra	   	177094		SFA - Remove inactive users from Account Team.
 |  19 Oct 2012     Vivekananda 204934      SFA - Bug Fix for Batch Job that Removes Inactive Account Team Members.
  +===========================================================================*/
global class Schedule_ToDeleteInactiveAccountTeamMemb implements Schedulable 
{
	global void execute (SchedulableContext sc)
	{
		boolean Flag;
		RunInactiveATbatch__c RIA = RunInactiveATbatch__c.getValues('FlagStatus');
		if(RIA.StatusFlag__c !=null){
		   Flag = RIA.StatusFlag__c;
		}
		To_DeleteInactiveAccountTeamMemb TobjDeleteAccTeamMem= new To_DeleteInactiveAccountTeamMemb();
		if(Flag !=false){                
           Id BatchId = Database.executeBatch(TobjDeleteAccTeamMem);           
        }
	}

}