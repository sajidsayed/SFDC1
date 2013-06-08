/*=====================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.11.2012      Avinash K       212738      Initial Creation.  TA Sync Batch job to insert TA Sync records.
 +=====================================================================================================================*/

global class TA_Sync_Log_Insert implements Database.Batchable<sObject>
{
    global String query;
    global Map<Id,User> mapIdUser = new Map<Id,User>();
    global List<User> lstUpdateUsers = new List<User>();
    global List<TA_Sync_Log__c> lstTASyncLogs= new List<TA_Sync_Log__c>();
    global Date dteThirtyDaysBack = System.Today() - 30;

    global TA_Sync_Log_Insert(String q)
    {
        this.query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query); //May return up to 50 Million records
    }
  
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for (User u : (List<User>)scope) 
        {
            
            TA_Sync_Log__c ta = new TA_Sync_Log__c(Sales_Resource__c = u.id, Status__c = 'Open');
            lstTASyncLogs.add(ta);

            mapIdUser.put(u.id,u);

// system.debug('#### User Name :'+u.name);
// system.debug('#### USER ID :'+u.id);
            
        }
        System.debug('lstTASyncLogs***'+lstTASyncLogs);
        insert lstTASyncLogs;
        System.debug('lstTASyncLogs###'+lstTASyncLogs);
        
        for (TA_Sync_Log__c ta : lstTASyncLogs) 
        {
// system.debug('#### ID : '+ta.id);
        /*    if(mapIdUser.keyset().contains(ta.Sales_Resource__c))
            {
                mapIdUser.get(ta.Sales_Resource__c).Last_TA_Synch_Date__c = System.TODAY();
                lstUpdateUsers.add(mapIdUser.get(ta.Sales_Resource__c));
            }
            */
        }
        
        //update lstUpdateUsers;
    }
   
    global void finish(Database.BatchableContext BC)
    {
        
// Send an email to the Email ID in Custom Setting "Email ID for TA Sync Batch Results" notifying of job completion. (NOT IN REQUIREMENT)
        /*Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
        String strEmailId;

        if(mapDataValueMap!= null &&
                    mapDataValueMap.get('Email ID for TA Sync Batch Results') != null &&
                    mapDataValueMap.get('Email ID for TA Sync Batch Results').DataValue__c != null &&
                    mapDataValueMap.get('Email ID for TA Sync Batch Results').DataValue__c != '')
        {
            strEmailId = mapDataValueMap.get('Email ID for TA Sync Batch Results').DataValue__c;

            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];

            string message = 'The TA SYNC LOG Insert batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String[] toAddresses = new String[] {strEmailId};

            mail.setToAddresses(toAddresses);

            mail.setSubject('Salesforce TA Sync Log Insert Batch Result ' + a.Status);

            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }*/
    }
}