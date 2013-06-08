/*==============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 | 17 Apr 2013    Krishna Pydavula       243649    Increased the code coverage
 +==============================================================================================================*/
 
@isTest(SeeAllData=True)
private class LeadBeforeUpdate_TC {
    
    static testMethod void Leadunittest() {
        try{
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
        List<Account> testAccount1=AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        List<Account> testAccount2=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        List<Account> testAccount3=AccountAndProfileTestClassDataHelper.CreateT2PartnerAccount();
        insert testAccount1;
        insert testAccount2;
        insert testAccount3;
        for(Account account:testAccount2){
            account.IsPartner = true;
        }
        update testAccount2;
            List<Lead> objlead = LeadTestClassDataHelper.createDealReg(testAccount1[0], null, testAccount2[0], testAccount3[0]);
            insert objlead; 
           for(Integer iCounter=0;iCounter<objlead.size();iCounter++)
           {
               if(iCounter==0)
               {
                    objlead[iCounter].DealReg_Deal_Registration_Status__c='Approved';
                    objlead[iCounter].Related_Account__c=null; 
               }
               if(iCounter==1)
               {
                    objlead[iCounter].DealReg_Deal_Registration_Status__c='Submitted';
                    objlead[iCounter].Approval_Status__c ='Approved By Field Rep'; 
                    objlead[iCounter].DealReg_Theater__c='EMEA';
               }
               else
               {
                    objlead[iCounter].DealReg_Deal_Registration_Status__c='Submitted';
                    objlead[iCounter].phone=null;
                                                               
               }
                objlead[iCounter].Accept_Lead__c=true;
                objlead[iCounter].DealReg_PSC_Owner__c=insertUser.id;
           }
            update objlead;
            for(Integer iCounter=0;iCounter<objlead.size();iCounter++)
           {
             system.assertEquals(null, objlead[iCounter].Related_Account__c);
             system.assertEquals(null, objlead[iCounter].phone);
                          
           }
       }
       
     }
    catch (Exception e){
  		if(e.getMessage().contains('Please populate Related Account before approving a deal registration'))
  		{	  	
            System.assert(e.getMessage().contains('Please populate Related Account before approving a deal registration'));
            
        }else{
        	System.assert(e.getMessage().contains('Customer Phone number is mandatory'));
        }
    }
   } 
}