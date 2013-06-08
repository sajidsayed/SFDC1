/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
                                                       
| 11/20/2012     Krishna Pydavula        203853        This test class is used to coverage the code for "PRM_DR_Expire_EmailNotify_Schedule" 
													   and "PRM_DR_Expire_EmailNotify_Batchjob" Classes. 
|1/18/2013		 Krishna Pydavula		 220545		   Added custom setting.		                                                                                                          
+=====================================================================================================*/
@IsTest
private class PRM_DR_Expire_EmailNotify_Schedule_TC {

    static testMethod void populatedetails() {
    	
    	List<Dealreg_Expiry_Notification_days__c> expdays=new List<Dealreg_Expiry_Notification_days__c>();
    	
    	Dealreg_Expiry_Notification_days__c noofdays1=new Dealreg_Expiry_Notification_days__c();
    	noofdays1.name='Expiry no of days1';
    	noofdays1.no_of_days__c=10;
    	expdays.add(noofdays1);
    	
    	Dealreg_Expiry_Notification_days__c noofdays2=new Dealreg_Expiry_Notification_days__c();
    	noofdays2.name='Expiry no of days2';
    	noofdays2.no_of_days__c=45;
    	expdays.add(noofdays2);
    	
    	Dealreg_Expiry_Notification_days__c noofdays3=new Dealreg_Expiry_Notification_days__c();
    	noofdays3.name='Expiry no of days3';
    	noofdays3.no_of_days__c=30;
    	expdays.add(noofdays3);
    	
    	Database.upsert(expdays,false);
    	
    	date d =system.today().addDays(10);
		date d1=system.today().addDays(45);
		date d2=system.today().addDays(30);
		PRM_DR_Expire_EmailNotify_Batchjob DRexp=new PRM_DR_Expire_EmailNotify_Batchjob();
		DRexp.query ='select id,name,DealReg_Deal_Registration_Number__c,DealReg_Theater__c,DealReg_Expected_Deal_Value__c,DealReg_Expiration_Date__c,DealReg_Additional_Contact_Email_Address__c,Linked_Opportunity_Owner__c,DealReg_Deal_Submitter_Rep_Email__c,DealReg_Deal_Description__c,DealReg_Distributor_Direct_Reseller__c,Company,City,State,Country,DealReg_Distribution_VAR_Name__c,CreatedBy.Name,CreatedBy.Email,DealReg_Registered_Products__c,CurrencyIsoCode,DealReg_Deal_Registration_Status__c,DealReg_PSC_Approval_Rejection_Date_Time__c from Lead where (DealReg_Expiration_Date__c=:d OR DealReg_Expiration_Date__c=:d1 OR DealReg_Expiration_Date__c=:d2) AND  (DealReg_Deal_Registration_Status__c=\'Approved\') AND (DealReg_Expiration_Date__c!=null) limit 1';
		PRM_DR_Expire_EmailNotify_Schedule sh1 = new PRM_DR_Expire_EmailNotify_Schedule();        
        String sch = '0 0 23 * * ?';
        System.Test.startTest();
        system.schedule('Test Check', sch, sh1);
        id  batchid = Database.executeBatch(DRexp);
        System.Test.stopTest();
		
		          
    }
}