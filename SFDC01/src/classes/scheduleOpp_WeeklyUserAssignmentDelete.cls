/*
Description	: Scheduler class for initiation of User Assignment record deletion and then create.
Author		: Pratibh Prakash
Created Date: 12-Aug-2010
Modified	:	
Updated On: 05-Jan-2011
Updated by: Sunil Bansal
Update for: To update the batch size and make the batch size updatable using custom settings, also to select updated Opportunities in 'pastDays'.

*/
global class scheduleOpp_WeeklyUserAssignmentDelete implements Schedulable{
	global void execute(SchedulableContext SC){
		
		/*Fetching Custom Setting and setting flag to true in order 
		to initiate delete process in Opportunity Batch class.*/
		DeleteUserAssignments__c deletionParameters = DeleteUserAssignments__c.getValues('UserAssignmentsDeletionParameters');
		deletionParameters.DeleteUnassigned__c = true;
		update deletionParameters;
		
        Integer pastDays = 15;
        Integer batchSize = 200; // this will be overwritten in try block
        try
        {
            Map<String, CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
            batchSize  = Integer.valueOf(DataValueMap.get('UserAssignmentRecordsCreationBatchSize').DataValue__c);
            pastDays = Integer.valueOf(DataValueMap.get('UserAssignmentRecsDeletePastOpptysIn').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 200;
        }

		// for selecting opportunities which are updated in last 'pastDays',configured thru CustomSettings.
        DateTime dt = DateTime.now();
        dt = dt.addDays(-pastDays);
        String strDate = dt.format('yyyy-MM-dd')+'T00:00:00.000Z';

		//Initiating and starting execution of OpportunityBatch class.
        String Query = 'Select o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId, o.IsClosed from Opportunity o where LastModifiedDate > '+strDate+' and o.AccountId<> \'0017000000YiRfS\' order by o.AccountId';
        System.debug('Query is---->'+Query);

        OpportunityBatch opportunityBatch = new OpportunityBatch(Query);
        database.executebatch(opportunityBatch,batchSize);
    }
    
    
}