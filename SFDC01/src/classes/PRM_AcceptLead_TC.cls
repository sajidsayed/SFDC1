/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req          DESCRIPTION                               
 |  ====            =========       ==              =========== 
 |  23.09.2010      Anand Sharma    #779            Test class for the unit test of PRM_AcceptLead class.             
 |  06.10.2010      Anand Sharma                    Better code coverage. 
 |  07.10.2010      Anand Sharma                    To cover catch block in unit test, Added condition in query as true
                                                    Updated the Test Class to check
 |  13.10.2010     Ashwini Gowda    #1143           Blank out the EMC Lead Rejected checkbox 
                                                    after a lead has been accepted by a different user.
 |  14.12.2010      Anil                            Removed DML statements and created Custom Settings
 |  11-JAN-2012     Anil                            Removed role Id
 +=========================================================================================================================*/

@isTest
private class PRM_AcceptLead_TC {

    static testMethod void prmAcceptLeadUnitTest() {
        
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
       String distributorSuperUser = 'EMEA Distributor Super User';
       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
       UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
       partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
       insert partner;
       
        }
       
        
        /* create lead data */
        Lead testLead2 = new Lead(LastName='testlm2', Accept_Lead__c = false, Reject_Lead__c = false, DealReg_Deal_Registration__c= false, 
                                  Rejection_Reason__c=null, firstname='testfm2', company='test2', email='test2@test.com');
                                  
        insert testLead2;
       
        Lead testLead1 = new Lead(LastName='testlm2', Accept_Lead__c = false, Reject_Lead__c = false, 
                                  DealReg_Deal_Registration__c= true ,Rejection_Reason__c=null, firstname='testfm2', company='test2', email='test1@test.com');
                                  
        insert testLead1;        
        /* update owner of lead record */
        testLead2.OwnerId = partner.Id;
        update testLead2;
        
                
        /* run as partner user to reject lead */
        System.runAs(partner){ 
            /*call method to reject lead */
            PRM_AcceptLead.Accept(testLead2.Id);
           
            
          } 
        //check when the lead is accepted is EMC_Lead_Rejected__c false
        System.assertEquals(false, testLead2.EMC_Lead_Rejected__c);
        Lead dealregLead = new Lead(LastName='testlm2', Accept_Lead__c = false, Reject_Lead__c = false, 
                                  DealReg_Deal_Registration__c= true ,Rejection_Reason__c=null, firstname='testfm2', company='test2', email='test1@test.com');
        insert  dealregLead;

        if (dealregLead != null){
           PRM_AcceptLead.Accept(dealregLead.Id);
        } 
    }
}