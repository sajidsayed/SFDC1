/*=====================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER        WR            DESCRIPTION                               
|  ====          =========        ==            =========== 
| 21-Feb-2011    Saravanan C    REQ# 1823       This scheduler class is used to schedule the 
|                                               PRM_PopPtnrBatch class
| 17-Mar-2011    Anirudh Singh  Req# 2470       This Scheduler class will populate Tier1 and Tier 2 Fields on Leads.
|                                               This will be scheduled to run only once a day.
| 12-Jul-2011    Anirudh Singh                  Updated Database.update to pass false as save result parameter.	
+=====================================================================================================*/

global class PRM_PopulatePartneronLeadScheduler implements Schedulable{


/* @Method <This method execute is used to populate partner on leads.
            This is schedular class which is scheduled automatically using custom setting>
@param <SchedulableContext to keep track of the scheduled job once it's scheduled>
@return <void> - <Not Returning anything>
@throws exception - <No Exception>
*/

    global void execute(SchedulableContext SC){
        try 
        {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null)
            {
                System.abortJob(ct.Id); 
            }
        }
        catch(Exception e) 
        {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        
        List<Lead> LeadsToProcess = New List<Lead>();
        LeadsToProcess = [SELECT id, ownerId, Reject_Lead__c, Accept_Lead__c,Tier_2_Partner__c, Partner__c, Previous_CAM_Email__c, CAM_Email__c, Channel__c,
                          Last_Inside_Sales_Owner__c, Last_EMC_Owner__c,RecordTypeId FROM Lead 
                          where (Partner__c = NULL AND Tier_2_Partner__c = NULL ) and (Reporting_Owner__r.ContactId<> null or owner.Name like 'Partner%')];
       PRM_PopulatePartnerOnLead pp = new PRM_PopulatePartnerOnLead();
       pp.populatePartneronLead(LeadsToProcess);
        
       List<Database.SaveResult> dsrs = Database.update(LeadsToProcess, false);
       if(dsrs.size()>0){
       	  PRM_PopulatePartnerOnLead.logFailedRecords(dsrs);
       }                   
                         
    }
       
}