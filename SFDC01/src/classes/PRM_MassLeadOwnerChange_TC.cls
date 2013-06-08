/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ==          =========== 
 |  10.10.2010      Anand Sharma    #1185       Test class for the unit test of PRM_MassLeadOwnerChange class. 
 |  23.11.2010      Anand Sharma                Update for better code coverage  
 |  05.07.2011      Anand Sharma                Change account creation instaed of fetching account
|   11.01.2012      Anil                        Removed role Id
 +=========================================================================================================================*/
@isTest
private class PRM_MassLeadOwnerChange_TC {
    
    private static testMethod void startTest1(){
    User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        /* Test for Partner User 
        */
        Map<Id,User> lstPartner = new Map<Id,user>();
        list<User> lstuser=new List<User>();
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();
        insert acc;
        Contact cont = UserProfileTestClassDataHelper.createContact();
        insert cont;
        cont.AccountId=acc[0].id;
        cont.Email='test24@emc.com';
        update cont;
        User partner1;
        System.runAs(insertUser)
        {
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
        Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
        //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
        partner1 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
        }
        lstuser.add(partner1);
        Contact cont1 = UserProfileTestClassDataHelper.createContact();
        insert cont1;
        cont1.AccountId=acc[1].id;
        cont1.Email='test23@emc.com';
        update cont1;
        User partner2;
        System.runAs(insertUser)
        {
        Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
        String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
        Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
        //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
        partner2 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont1.Id);
        }
        lstuser.add(partner2);
        System.runAs(insertUser)
        {
            if(lstuser.size()>0)
            {
            insert lstuser;
            }
        }
        lstPartner.put(partner2.Id,lstuser[0]);
        lstPartner.put(partner1.Id,lstuser[1]);         
        
        
                              
           
       Account objAccount = createAccount();
                                                                    
        List<Lead> lstLead = New List<Lead>();
                  
        for(Integer i=0; i<10; i++){
            Lead testLead2 = new Lead(LastName='testlm1_'+i, firstname='testfm2', company='test2',DealReg_Deal_Registration__c = true, 
                                  email='test2@test.com', Partner__c = objAccount.Id, Status='New', Sales_Force__c='EMC', city='India', Street ='bangalore',
                                  Lead_Originator__c='Field', LeadSource ='Manual', Originator_Details__c ='Core Referral', Channel__c='Direct');
            lstLead.add(testLead2); 
        }
        /* create record for the leads   */
        insert lstLead;             
        System.debug('lstLead ---->' + lstLead);
        System.runAs(lstPartner.values().get(0)){     
              
            ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lstLead);                  
            // test constructors
            PRM_MassLeadOwnerChange objLeadExtn = new PRM_MassLeadOwnerChange(stdCon); 
            /* No Record Selected */
            objLeadExtn.FetchLeadRecords();         
            
            /* All Record are selected */
            stdCon.setSelected(lstLead);            
            objLeadExtn = new PRM_MassLeadOwnerChange(stdCon);
            objLeadExtn.FetchLeadRecords();
            objLeadExtn.objSearchUserQueueCon.selectedOwnerId = lstPartner.values().get(0).Id;
            System.debug('lstLead ---->' + lstLead);            
            objLeadExtn.ChangeOwner() ;
            objLeadExtn.ValidateLeadOwnerRole(lstPartner.values().get(1), lstPartner);
            
            objLeadExtn.Cancel();
        }     
                              
    } 
       
    private static testMethod void startTest2(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
         /* Test for not Partner User */
       User nonpartner;
        System.runAs(insertUser)
            {       
           Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
           String SysAdmin = data.get('System Administrator').Name ;
           Profile SysAdminProf = [select Id from Profile where Name=: SysAdmin];
           UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='Worldwide EMC Corporate'];
           nonpartner = UserProfileTestClassDataHelper.createPortalUser(SysAdminProf.id,userRoles.Id,null);
           insert nonpartner;
            }
        
        List<Lead> lstLead = New List<Lead>();
       Account accountRecord = createAccount();
                     
            for(Integer i=0; i<2; i++){
                Lead testLead2 = new Lead(LastName='testlm1_'+i, firstname='testfm2', company='test2', DealReg_Deal_Registration__c = true, 
                                      email='test2@test.com', Status='New', Sales_Force__c='EMC', Partner__c = accountRecord.Id, city='India', Street ='bangalore',
                                      Lead_Originator__c='Field', LeadSource ='Manual', Originator_Details__c ='Core Referral', Channel__c ='Direct');
                lstLead.add(testLead2); 
            }
            /* create record for the leads   */
            insert lstLead; 
        //System.runAs(lstPartner.get(0)){ 
            ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lstLead);                  
            // test constructors
            PRM_MassLeadOwnerChange objLeadExtn = new PRM_MassLeadOwnerChange(stdCon); 
            /* No Record Selected */
            objLeadExtn.FetchLeadRecords();         
            objLeadExtn.objSearchUserQueueCon.selectedOwnerId = nonpartner.Id;
            /* All Record are selected */
            stdCon.setSelected(lstLead);             
            objLeadExtn = new PRM_MassLeadOwnerChange(stdCon);
            objLeadExtn.FetchLeadRecords();
                        
            objLeadExtn.ChangeOwner() ;                           
            objLeadExtn.Cancel();
        //}                                 
    }
    
    private static testMethod void startTest3(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }            
         /* Test to more than 200 records function */
        List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
           insert acc;
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
      /*  List<User> lstPartner = [Select  u.Id, u.Contact.Account.Owner.Email, u.Contact.Account.Name , u.UserRole.Name
                        from    User u 
                        where   u.isActive=True limit 1];*/
        List<Lead> lstLead = New List<Lead>();
        //Account accountRecord = [Select Id from Account where Type= 'Partner' AND Lead_Oppty_Enabled__c = True 
        //                        AND Account_Status__c = 'Active' limit 1]  ; 
        Account accountRecord = createAccount();           
            for(Integer i=0; i<202; i++){
                Lead testLead2 = new Lead(LastName='testlm1_'+i, firstname='testfm2', company='test2',  DealReg_Deal_Registration__c = true, 
                                      email='test2@test.com', Partner__c = accountRecord.Id, Status='New', Sales_Force__c='EMC', city='India', Street ='bangalore', 
                                      Lead_Originator__c='Field', LeadSource ='Manual', Originator_Details__c ='Core Referral', Channel__c='Direct');
                lstLead.add(testLead2); 
            }
            /* create record for the leads   */
            insert lstLead; 
            /* All Record are selected */
        System.runAs(partner){        
            ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lstLead);
            stdCon.setSelected(lstLead);                    
            // test constructors
            PRM_MassLeadOwnerChange objLeadExtn = new PRM_MassLeadOwnerChange(stdCon);

            objLeadExtn.FetchLeadRecords();
               
        }                                 
    }
    
    private static Account createAccount(){
        //Creating the dummy account for test class.
        //Creating the dummy account for test class.
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distributor',
            Type = 'Partner' ,
            PROFILED_ACCOUNT_FLAG__c= true,
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        //objAccount.PROFILED_ACCOUNT_FLAG__c = true;
        update objAccount;
        System.Debug('objAccount ----> ' + objAccount) ; 
        return objAccount;
    }
}