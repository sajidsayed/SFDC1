/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 
 |  23.09.2010      Anand Sharma    #779        Test class for the unit test of PRM_LeadInbox class.             
 
 |  06.10.2010      Anand Sharma                Better code coverage.
 
 |  08/10/2010      Karthik Shivprakash         Added startTest and stopTest 
                                                method to avoid too many DML
 |                                              Exception error. 
 |  13.10.2010      Ashwini Gowda    #1143      Blank out the EMC Lead Rejected checkbox 
 |                                              after a lead has been accepted by a different user.
 |  14/12/2011		Anil						Removed Query for fetching Partner and used Custom setting Data Helper
 |  11-JAN-2012	  	Anil						Removed role Id
 +=========================================================================================================================*/

@isTest
private class PRM_LeadInbox_TC {

    static testMethod void leadInboxUnitTest() {
       

        
        /* Create a new instance of the object */
        PRM_LeadInbox objLeadInbox = new PRM_LeadInbox();
        
        //Create Partner User
        
	        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }
           List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
	       insert acc;
	       for(Account acc1 : acc)
	       {
	       	acc1.Type='Partner';
	       	acc1.IsPartner=true;
	       }
	       update acc;
	       Contact cont = UserProfileTestClassDataHelper.createContact();
	       cont.AccountId=acc[0].Id;
	       insert cont;
	       User partner;
	       System.runAs(insertUser)
	       {       
	       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
	       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
	       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
	       //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
	       partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
	       insert partner;
	       }
                       
        Lead testLead2 = new Lead(LastName='testlm2', firstname='testfm2', company='test2', 
                                  email='test2@test.com',ownerid=partner.Id);
        insert testLead2;
        
        System.currentPageReference().getParameters().put('selectedRow',testLead2.Id);
        /* call accept method */
        
        Test.startTest();
        
        objLeadInbox.accept();
        
        //check when the lead is accepted is EMC_Lead_Rejected__c false
        System.assertEquals(false, testLead2.EMC_Lead_Rejected__c);  
        
        /* call getLeadInbox property */ 
        objLeadInbox.getLeadInbox();
        
        /*get Full Lead List */
        objLeadInbox.FullLead();
        
        /* get only limited number of record */
        objLeadInbox.limitLeadInbox();
        
        objLeadInbox.transferToLead();
        
        Test.stopTest();
    }
}