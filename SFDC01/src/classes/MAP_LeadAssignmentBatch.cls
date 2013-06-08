global class MAP_LeadAssignmentBatch implements Database.Batchable<SObject> {
    
    public string batchName;
    public string batchQuery;
    public Map<string, string> ruleFieldToLeadFieldMap;
    public Map<string, string> ruleFieldToOperatorMap;
    
    public MAP_LeadAssignmentBatch()
    {
        batchName = 'Lead Assignment Batch: ' + Datetime.now();
        system.debug(batchName + ' started ');

        
        batchQuery = 'SELECT Name, Related_Account__c, ownerid, Routing_Exception_Code__c, ';
        List<string> leadAttributes = MAP_LeadAssignmentUtils.getLeadAttributes();
        ruleFieldToLeadFieldMap = MAP_LeadAssignmentUtils.getRuleFieldToLeadFieldMappings();
        ruleFieldToOperatorMap = MAP_LeadAssignmentUtils.getRuleFieldToOperatorMappings();
        Iterator<string> iter = leadAttributes.iterator();
        String attrName = null;
        do
        {
            attrName = iter.next();
            batchQuery += attrName;
            if(iter.hasNext())
            {
                batchQuery += ',';
            }           
        }while(iter.hasNext());
        batchQuery += ' FROM Lead WHERE ownerid = \'' + MAP_LeadAssignmentUtils.getProfileOptionValue('Routing_Batch_Queue_Id') + '\'';
        system.debug(batchQuery);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(batchQuery);
    }
    
    global void execute(Database.BatchableContext BC, list<SObject> scope)
    {
        system.debug('Entering execute: ');
        // set flag to prevent PRM Apprivo asynch code from executing
        PRM_PopulatePartnerOnLead.LeadRoutingExecution=true;
        
        MAP_LeadAssignmentWorker worker =  new MAP_LeadAssignmentWorker(ruleFieldToLeadFieldMap, ruleFieldToOperatorMap);
        List<Lead> leadsToBeUpdated = new List<Lead>();
        ID routingExceptionQueueId = MAP_LeadAssignmentUtils.getProfileOptionValue('Routing_Exception_Queue_Id');
        for(SObject s:scope)
        {
            Lead current = (Lead)s;
            system.debug('Processing Lead ' + current.id + ', ' + current.name);
            if(!worker.processLead(current))
            {
                system.debug('Error in assigning lead - check global exception routing queue for lead# ' + current.Id);
            }
            else
            {
                system.debug('Assignment successful for lead# ' + current.Id);
            }
            leadsToBeUpdated.add(current);
        }
            
        Database.SaveResult[] firstPassResults = Database.update(leadsToBeUpdated, false);
        List<Lead> retryLeads = new List<Lead>();

        for(integer i = 0; i < leadsToBeUpdated.size(); i++)
        {
            if(!firstPassResults[i].isSuccess())
            {
                leadsToBeUpdated[i].ownerid = routingExceptionQueueId;
                leadsToBeUpdated[i].Routing_Exception_Code__c = 'Update Operation Failed: ' + firstPassResults[i].errors[0].message;
                retryLeads.add(leadsToBeUpdated[i]);
                system.debug('Initial Update Operation Failed: ' + leadsToBeUpdated[i].name + ', ' + leadsToBeUpdated[i].id);
                system.debug('Exception Message: ' + firstPassResults[i].errors[0].message);
            }
        }
        
        Database.SaveResult[] secondPassResults = Database.update(retryLeads, false);
        for(integer i = 0; i < retryLeads.size(); i++)
        {
            if(!secondPassResults[i].isSuccess())
            {
                system.debug('Retry Update Operation Failed: ' + retryLeads[i].name + ', ' + retryLeads[i].id);
                system.debug('Exception Message: ' + secondPassResults[i].errors[0].message);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
       system.debug('Batch ' + batchName + ' completed with following details');
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob where Id =:BC.getJobId()];
       system.debug('Id: ' + a.Id);
       system.debug('Status: '+ a.Status);
       system.debug('Number of Errors: ' + a.NumberOfErrors);
       system.debug('Job Items Processed: ' + a.JobItemsProcessed);
       system.debug('Total Job Items: ' + a.TotalJobItems);
       //Schedule the next batch job to run for 5 minutes later:
       Datetime dt = System.now();
       dt = dt.addMinutes(5);
       String scheduleString='0';//0 seconds
       scheduleString+=' '+ dt.minute();
       scheduleString+=' '+ dt.hour();
       scheduleString+=' '+ dt.day();
       scheduleString+=' '+ dt.month();
       scheduleString+=' ?';
       scheduleString+=' '+ dt.year();
       String jobName = 'Lead Routing Batch - ' + dt.format('MM-dd-yyyy-hh:');
       MAP_LeadAssignmentScheduler nextBatchJob = new MAP_LeadAssignmentScheduler();
       System.schedule(jobName,scheduleString,nextBatchJob);
    }   
}