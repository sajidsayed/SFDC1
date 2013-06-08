/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  18-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData=true)
private Class checkAccountUpdatesEMC_Trigger_TC{

    public static testmethod void checkAccountUpdatesEMC_Trigger(){
            Account acc= new Account();
            acc.Name='Account 1';
            acc.BillingCountry='Country 1';
            acc.BillingCity='City 1';
            acc.BillingState='State 1';
            acc.BillingStreet='Street 1';
            acc.BillingPostalCode='123';
            insert acc;

            Opportunity opp= new Opportunity();
            opp.Name='Oppty1';
            opp.StageName='Won';
            opp.AccountId=acc.id;
            opp.closeDate=System.today()+2;
            opp.Opportunity_Number__c='123';
            insert opp;
            
            acc.BillingCountry='Country 2';
            acc.BillingCity='City 2';
            update acc;
           
        }  
    }