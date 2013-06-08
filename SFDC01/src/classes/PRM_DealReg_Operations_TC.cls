/*============================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER           WR      DESCRIPTION                               

 |  ====          =========           ==      =========== 

 |  5/17/2011     Shalabh Sharma           This is the coverage class for DealReg_Operations   
    24/8/2011     Anirudh Singh            Commented populateDealRegFields method for SFA Release.   
    2 Dec 2011    Arif                     Updated createLead method to populate some mandatory fields for entering in approval process. 
    3 May 2012    Arif                     Cleaned up code for EMEA decommision  
    31jan 2013    vivek            Improve code coverage                                                                                       
 +============================================================================*/

@isTest
private class PRM_DealReg_Operations_TC { 
    
    static Opportunity createOpportunity(String opportunityName,String AccountId){      
        Date closeDate = date.newinstance(2012, 11, 17);
        Date approvalDate = date.newinstance(2011, 11, 1);
        Date expirationDate = date.newinstance(2013, 11, 18);
        Opportunity Oppty = new Opportunity();
        Oppty.Name = opportunityName;
        Oppty.AccountId = AccountId;
        Oppty.Sales_Channel__c = 'Direct';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';
        Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate ;
        Oppty.bypass_validation__c = true;
        //Oppty.Primary_Outsourcer_System_Integrator__c=AccountId;
        //Oppty.Primary_ISV_Infrastructure__c=AccountId;
        //System.runAs(sytemAdminAPIUser){
            insert Oppty;
        //}
        return Oppty;
    }
     
    static testmethod void TestAllMethods(){
      PRM_DealReg_Operations objoperatins = new PRM_DealReg_Operations();
      DealRegistration_CustomSetting__c objDRCust= new DealRegistration_CustomSetting__c(Name='ApjPSCDRQueue',PSC_QueueId__c='00G70000001lWL2');
      database.insert(objDRCust,false);
      Lead emeaDRO = createLead();
      List<Lead> lstDROperation = new List<Lead>();
      lstDROperation.add(emeaDRO);
      objoperatins.populateOpptyOwnerOnLead(lstDROperation);
      objoperatins.ProcessRejectedLeads(lstDROperation);
    }
 
    
    static testmethod void testFieldRepApproval(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        Test.startTest();
         try{
         Lead emeaDR = createLead();
         system.debug('emea DR--->'+emeaDR); 
          
         Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
         req1.setComments('Submitting request for approval.');
         req1.setObjectId(emeaDR.id);
     
         Approval.ProcessResult result = Approval.process(req1);
         
         List<Id> newWorkItemIds = result.getNewWorkitemIds();
         Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
         req2.setComments('Approve Request.');
         req2.setAction('Approve');
         req2.setWorkitemId(newWorkItemIds.get(0));
         Approval.ProcessResult result2 = Approval.process(req2);
         }catch(exception ex){
     }
       
             
         
         Test.stopTest();
    }
     
    static testmethod void testFieldRepRejection(){
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
      PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
         Test.startTest();
         try{
         Lead emeaDR = createLead();        
         system.debug('emea dr--->'+emeaDR);  
         
         Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
         req1.setComments('Submitting request for approval.');
         req1.setObjectId(emeaDR.id);
         Approval.ProcessResult result = Approval.process(req1);
         
         emeaDR.DealReg_Rejection_Reason__c = 'Criteria Not Met';
         
         List<Id> newWorkItemIds = result.getNewWorkitemIds();
         Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
         req2.setComments('Rejecting Request.');
         req2.setAction('Reject');
         req2.setWorkitemId(newWorkItemIds.get(0));
         
         //emeaDR.DealReg_Deal_Registration_Status__c = 'Submitted';
         //emeaDR.Approval_Status__c = 'Rejected By Field Rep';
         emeaDR.DealReg_Rejection_Reason__c = 'Criteria Not Met';
         update emeaDR;  
         //Approval.ProcessResult result2 = Approval.process(req2);            
         }catch(exception ex){
     }
         Test.stopTest();
    }

    
    static Lead createLead(){
    Profile profile2 = [SELECT Id FROM profile WHERE name='EMEA PSC User']; 
    User usr2   = [SELECT Id from User where ProfileId=:profile2.id and IsActive=True limit 1] ; 
        user Partneruser = [Select Id,Name from User where UserType='PowerPartner' and IsActive=true limit 1];
        Map<String,Schema.RecordTypeInfo> recordTypes = Lead.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id drRecordTypeId = recordTypes.get('Deal Registration').getRecordTypeId();
        Account objAccount = createAccount('UNITTESTAcc');
        Account RelatedAccount = createRelatedAccount('RelatedAvvt');
        Account objT2Account = createT2Account('UNITTESTAcc1');
         
    Lead objLead1 = new Lead();
        objLead1.Company ='TestDealreg';
        objLead1.DealReg_Deal_Description__c ='Deal Reg description';
        objLead1.DealReg_Deal_Registration_Justification__c ='Deal Reg Justification';
        objLead1.CurrencyIsoCode ='USD';
        objLead1.DealReg_Expected_Deal_Value__c =100;
        objLead1.DealReg_Expected_Close_Date__c = System.today().addMonths(1);
        objLead1.LastName ='DealregLastName';
        objLead1.Email ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Contact_First_Name__c ='testCFName';
        objLead1.DealReg_Partner_Contact_Last_Name__c ='testLFname';
        objLead1.DealReg_Partner_E_Mail_Address__c ='Dealreg1@dealreg.com';
        objLead1.DealReg_Partner_Phone_Number__c = '98888888';
        objLead1.Status = 'Submitted';
        objLead1.DealReg_Theater__c ='EMEA';
        objLead1.DealReg_PSC_Owner__c = usr2.id;
        //objLead1.RecordTypeId = approvedDealregTypeId;
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.Related_Account__c =objAccount.Id;
        objLead1.DealReg_Deal_Registration_Status__c ='Submitted';
        objLead1.DealReg_Of_Registration_Products__c = 5;
        objLead1.DealReg_Deal_Registration__c = true;
        objLead1.DealReg_Create_New_Opportunity__c =true;
        objLead1.Tier_2_Partner__c = objT2Account.Id;
        objLead1.Partner__c = objAccount.Id;
        objLead1.Channel__c = 'INDIRECT'; 
        objLead1.City = 'Bangalore';
        objLead1.Country__c = 'India';
        objLead1.Street = 'Bangalore';
        objLead1.Sales_Force__c = 'EMC';
    objLead1.phone ='66738892';
        
    insert objLead1;
        return objLead1;
    }
    
    static Account createAccount(String accountName){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
        
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Partner_Type__c ='Distributor',
            Type = 'Partner',
            PROFILED_ACCOUNT_FLAG__c = true,
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;    
        System.Debug('objAccount ----> ' + objAccount) ;   
        
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        update objAccount;
        return objAccount;
        
        
       
    }
    
    static Account createT2Account(String accountName){
    Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('T2_Partner Profile Record Type').getRecordTypeId();
    
        Account objAccount = new Account(
            name = 'UNITTESTAcc',
            Party_Number__c = '1234',
            BillingCountry ='Colombia',
            Synergy_Account_Number__c = '10',
            Lead_Oppty_Enabled__c = true, 
            Partner_Type__c ='Distribution VAR',
            Type = 'Partner' ,
            PROFILED_ACCOUNT_FLAG__c = true,
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        objAccount.IsPartner = true;
        update objAccount;
        System.Debug('objAccount ----> ' + objAccount) ;       
        return objAccount;
    }
    
    static Account createRelatedAccount(String accountName){
        //Creating the dummy account for test class.
        Account account = new Account(
            name=accountName,
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );        
        insert account;
        return account;
    }
    
    static Extension_Request__c createExtension(String LeadId){
        Extension_Request__c extReq = new Extension_Request__c();
        extReq.Extension_Request_Status__c = 'New';
        extReq.Deal_Registration__c = LeadId;
        Insert extReq;
        return extReq;
    }
}