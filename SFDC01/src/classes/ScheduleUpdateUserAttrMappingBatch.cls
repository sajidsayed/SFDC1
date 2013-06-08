/*=============================================================================
	HISTORY                                                                  
                                                               
	DATE          	DEVELOPER                WR       		DESCRIPTION                               
	====          	=========                ==       		=========== 
	06-Sep-2010		Pratibh Prakash			136350			Scheduler class to intiate batch class UpdateUserAttrMappingfromRoleBatch.
	28/11/2011		Anand Sharma			178714   		Added few more field into query for PRM_Partner_Leverage.districtCreateEdit method to 
															populate District manage on District record.
==============================================================================*/
global class ScheduleUpdateUserAttrMappingBatch implements Schedulable{

	global void execute(SchedulableContext SC){
		String query = 'Select Id, Name, Role_ID__c,district__c, area__c,BU__c, Country__c, Division__c, Forecast_Group__c, Region__c, Sales_Role__c, Super_Area__c, Super_Division__c,Theater__c,Updated_From_Future_Call__c from User_Attribute_Mapping__c';
		System.debug('Query is---->'+Query);
		UpdateUserAttrMappingfromRoleBatch userAttrBatch = new UpdateUserAttrMappingfromRoleBatch(Query);       
        database.executebatch(userAttrBatch);
	}
}