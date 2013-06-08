/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       	DEVELOPER     DESCRIPTION                               
 |  ====       	=========     =========== 
 | 06.12.2011	Shipra Misra  SFA: TA Assignment Rule Functionality enhancements
 |							  This functionality fires whenever a new TA AssignmentRule 
 |							  is inserted or updated.When there exist any matching account for Country, state and Classification.
 |							  Also the functionality would fire for only when one ‘TA_Assignment_Rule’ record 
 |							  is created or updated in single trigger execution. 
 							  If more records are getting updated via DataLoader at same time, 
 							  then it is advised to set batch size of data loader to 'one' record.
+===========================================================================*/
trigger AfterInsertUpdateTA_AssignmentRule on TA_Assignment_Rule__c (after insert,after update) 
{
	// this triger set to execute for only one record in batch, if there are more record it is not going to execute any code.
	if(trigger.new.size()>1)return;
	//Declare Variable.
	//Hold TA AssignmentRule id.
	TA_Assignment_Rule__c taRule;
	
	//If trigger is insert add the record to set.
	if(trigger.isInsert)
	{
	    taRule = trigger.New[0];
	}
	//If existing record is updated.
	if(trigger.isUpdate)
	{
			TA_Assignment_Rule__c newTA_Assignment = Trigger.New[0];
			TA_Assignment_Rule__c oldTA_Assignment = Trigger.Old[0];
			//Check if existing record is updated for Country, State, Classification or Group.
			if(newTA_Assignment.Country__c!=oldTA_Assignment.Country__c || 
			   newTA_Assignment.State_Or_Province__c!=oldTA_Assignment.State_Or_Province__c ||
			   newTA_Assignment.Classification__c!= oldTA_Assignment.Classification__c ||
			   newTA_Assignment.Group_Id__c!= oldTA_Assignment.Group_Id__c||
			   newTA_Assignment.Opportunity_Private_Access_Group__c!= oldTA_Assignment.Opportunity_Private_Access_Group__c)
			{
				//add the record to ta assignment id set.
				taRule = trigger.new[0];
			}
	}
	//If record's inserted or updated are more than 0 execute.
	if(taRule!=null)
	{
		//Call UpdateAccountOnTARuleUpdate to update the TA Status as "Update".
		TA_AssignmentRuleAccountUpdate assignUpdate= new TA_AssignmentRuleAccountUpdate();
		assignUpdate.UpdateAccountOnTARuleUpdate(taRule);
	}
}