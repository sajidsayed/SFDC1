/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  23.09.2010      Anand Sharma    #779        Test class for the unit test of PRM_LeadAcceptReject class.             
 |  06.10.2010      Anand Sharma                Better code coverage.
 |  14/12/2011		Anil						Removed Query for fetching Partner and used Custom setting Data Helper
 |  11-JAN-2012	  Anil						Removed role Id            
 +=========================================================================================================================*/
@isTest
private class PRM_LeadAcceptReject_TC {

    static testMethod void prmLeadAcceptRejectUnitTest() {
               
       User partner;
       User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
       insert acc;
       Contact cont = UserProfileTestClassDataHelper.createContact();
       cont.AccountId=acc[0].Id;
       insert cont; 
        System.runAs(insertUser)
        {      
       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
       partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
       insert partner;
        }
       
        
        /* create lead data */
        Lead testLead2 = new Lead(LastName='testlm2', Accept_Lead__c = false, Reject_Lead__c = false, 
                                  Rejection_Reason__c=null, firstname='testfm2', company='test2', email='test2@test.com');
        insert testLead2;
        
        /* update owner of lead record */
        testLead2.OwnerId = partner.Id;
        update testLead2;
        
        /* run as partner user to reject lead */
        System.runAs(partner){          
            
            /* set the lead id and parent value */          
            System.currentPageReference().getParameters().put('Id',testLead2.Id);
            System.currentPageReference().getParameters().put('parent','true'); 
        
            /* Create a new instance of the object */ 
            PRM_LeadAcceptReject objLeadAcceptReject = new PRM_LeadAcceptReject();
            
            /* set rejection reason on lead */          
            objLeadAcceptReject.leadObject.Rejection_Reason__c = 'insufficent reason';
            
            /*call method to reject lead */
            objLeadAcceptReject.Reject();
        }         
    }
}