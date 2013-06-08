/***

Updated On: 05-Jan-2011
Updated by: Sunil Bansal
Update for: To update the batch size and make the batch size updatable using custom settings, also to select updated Opportunities in 'pastDays'.

Updated On: 18-Nov-2011
Updated by: Shipra Misra
Update for: Updated this scheduler class so that it runs different query on Saturday and different quesry on rest of the other days. This also helps us in removing one scheduler class 'scheduleOpp_WeeklyUserAssignmentDelete'

*/
global class scheduleOpportunityVisibility implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
//       String Query = 'Select o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId, o.IsClosed from Opportunity o where o.IsClosed = false and (LastModifiedDate > :Date.Today() - 15) and o.AccountId<>'+ '\'0017000000YiRfS\''+' order by o.AccountId';

        Integer pastDays = 10;
        Integer batchSize = 200; // this will be overwritten in try block
        DateTime dt = DateTime.Now();
        String currentDay = dt.format('E'); 
        try
        {
            Map<String, CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
            batchSize  = Integer.valueOf(DataValueMap.get('UserAssignmentRecordsCreationBatchSize').DataValue__c);
            
            if(currentDay == 'Sat' || currentDay == 'Saturday')
                pastDays = Integer.valueOf(DataValueMap.get('UserAssignmentRecsDeletePastOpptysIn').DataValue__c);
            else
                pastDays = Integer.valueOf(DataValueMap.get('UserAssignmentRecordsForPastOpptysIn').DataValue__c);
        }
        catch(Exception e)
        {
            batchSize = 200;
        }

        // for selecting opportunities which are updated in last 'pastDays',configured thru CustomSettings.
        dt = dt.addDays(-pastDays);
        String strDate = dt.format('yyyy-MM-dd')+'T00:00:00.000Z';
        String strQuery = '';
        if(currentDay == 'Sat' || currentDay == 'Saturday')
            strQuery = 'Select o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId, o.IsClosed from Opportunity o where LastModifiedDate > '+strDate+' and o.AccountId<> \'0017000000YiRfS\' order by o.AccountId';
        else
            strQuery = 'SELECT o.AccountId ,o.CloseDate, o.Id, o.Partner__c,o.Tier_2_Partner__c, o.Name, o.Opportunity_Owner__c ,o.OwnerId, o.IsClosed FROM Opportunity o where o.IsClosed = false and LastModifiedDate > '+strDate+' and o.AccountId<> \'0017000000YiRfS\' order by o.AccountId';

        System.debug('Query is----> '+strQuery);

        OpportunityBatch opportunityBatch = new OpportunityBatch(strQuery);
        database.executebatch(opportunityBatch,batchSize);
    }
}