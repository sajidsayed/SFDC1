/*=====================================================================================================+
|  HISTORY  |                                                                           
|  DATE          DEVELOPER        WR            DESCRIPTION                               
|  ====          =========        ==            =========== 
|  3-Mar-2011    Saravanan C    REQ# 1823       Test Method for PRM_PopPtnrBatch/Scheduler class
|  12-Jul-2011   Anirudh Singh                  Updated Lead Creation as per Lead Validation Rules.
|  Aug-2011      Saravanan C                    Test Class cleanup
|  11/1/2011     Prasad                         Taking more than 10 mins in test run..rduced the process time   
|  01/12/2011    Suman B                        Removed creation of Account and contacts.
|  14/12/2011       Anil                        Used Custom setting Data Halper
+=====================================================================================================*/
@isTest  
private class PRM_PopulatePartneronLeadScheduler_TC {

   static testmethod void test() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List <Lead> Leads = new List<Lead>();
        for(integer i = 0; i<20; i++){
           Lead lead = new Lead(firstName = 'Test'+i, lastName = 'Sarv', email = 'noreply@yahoo.com', 
           Company = 'TestCompany',Status = 'Qualified',Sales_Force__c = 'EMC',Lead_Originator__c = 'Field',
           LeadSource = 'Manual',Partner__c =NULL , Tier_2_Partner__c =NULL , Channel__c ='INDIRECT' , city='India', Street ='bangalore',Country__c='India');
           Leads.add(lead );
        }
        Insert Leads ;
        System.Debug('Lead1ownerId--->' + Leads[0].ownerId);
        System.Debug('Lead2ownerId--->' + Leads[2].ownerId);

        Test.StartTest();
        String Query ='SELECT id, ownerId, Reject_Lead__c, Accept_Lead__c,Tier_2_Partner__c, Partner__c, Previous_CAM_Email__c, CAM_Email__c, Channel__c,' 
                + ' Last_Inside_Sales_Owner__c, Last_EMC_Owner__c FROM Lead where (Partner__c = NULL OR Tier_2_Partner__c = NULL ) limit 20';
                
        // run batch 
        PRM_PopPtnrBatch Pop=new PRM_PopPtnrBatch();
        Id batchProcessId = Database.executeBatch(new PRM_PopPtnrBatch(Query));  
        String strScheduleTime ='0 0 0 3 9 ? ';
        strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
        String jobId = System.schedule('test-PRM_PopulatePartneronLeadScheduler',strScheduleTime, new PRM_PopulatePartneronLeadScheduler());
        system.assertNotEquals(jobId , Null);
        Test.StopTest();
    }
  
}