/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR         DESCRIPTION                               

 |  ====          =========      ==         =========== 

 |  04/07/2011    Ashwini Gowda             Test class for PRM_DEALREG_EMEARoutingBatch.
 |  01/12/2011    Anil Sure                 Fixed MIXED_DML Exception
                                 
 |=============================================================================================================== */

@isTest
Private Class PRM_DEALREG_EMEARoutingBatch_TC{
    static TestMethod void PRM_DEALREG_EMEARoutingBatch_TC(){
    /* @Method <This method is used for EMEA Routing Approval Process>.   
        @param - <void>  
        @return <void> - <Not Returning anything   
        @throws exception - <No Exception>
    */ 
        Test.startTest();
            User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
            System.runAs(insertUser)
            {
                PRM_VPP_JobDataHelper.createVPPCustomSettingData();
            }
            
            Lead emeaDR = createLead();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for rejection.');
            req1.setObjectId(emeaDR.id);
            Approval.ProcessResult result = Approval.process(req1);        
            ProcessInstanceWorkitem objPIWI = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.Status, 
                                                        p.ProcessInstance.TargetObjectId,OriginalActorId,ActorId 
                                                        from ProcessInstanceWorkitem p
                                                        where p.ProcessInstance.TargetObjectId =:emeaDR.Id 
                                                        and ProcessInstance.Status='Pending' limit 1]; 
           createDealRegProcessRecord(Userinfo.getUserId(),objPIWI.id);
           // Database.executebatch(new PRM_DEALREG_EMEARoutingBatch());
           // My code begins
           PRM_DEALREG_EMEARoutingBatch obj=new PRM_DEALREG_EMEARoutingBatch();
           ID batchprocessid = Database.executebatch(obj);
           Database.batchablecontext bc;
           List<sobject> st=new List<sobject>();
           obj.Execute(bc,st);
           // obj.Finish(bc);
           
           // Mycode ends
       Test.stopTest();
    }
    static PRM_DealReg_EMEAProcessItem__c createDealRegProcessRecord(String ActorId,String ProcessId){
        PRM_DealReg_EMEAProcessItem__c emeaPRocessItem = new PRM_DealReg_EMEAProcessItem__c();
        emeaPRocessItem.DealReg_ActorId__c =  ActorId;
        emeaPRocessItem.DealReg_ProcessId__c = ProcessId;
        insert emeaPRocessItem;
        return emeaPRocessItem;
    }
    
    static Lead createLead(){
    
        Lead newLead = new lead();
        newLead.DealReg_Department_Project_Name__c = 'ABCL';
        newLead.DealReg_Expected_Deal_Value__c = 12345.5;
        newLead.Email = 'abc@abc.com';
        newLead.DealReg_Partner_Contact_First_Name__c = 'Test';
        newLead.DealReg_Partner_Contact_Last_Name__c = 'Test';
        newLead.lastname = 'Test Lead';
        newLead.company = 'EMC';
        newLead.DealReg_PSC_Owner__c = Userinfo.getUserId();
        newLead.DealReg_Deal_Registration_Status__c = 'New';
        newLead.DealReg_Of_Registration_Products__c = 3;
        newLead.DealReg_Deal_Description__c = 'test';
        newLead.DealReg_Deal_Registration_Justification__c = 'test';
        newLead.Partner__c = createAccount('Test').ID;
        newLead.DealReg_Theater__c = 'APJ';
        newLead.DealReg_Create_New_Opportunity__c = True;
        newLead.DealReg_Deal_Registration__c = true;  
        newLead.City ='India';
        newLead.Street ='Bangalore';
        insert newLead;
        return newLead;
    }
    
    static Account createAccount(String accountName){
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
            recordtypeid= accRecordTypeId           
        );
        insert objAccount;
        objAccount.Lead_Oppty_Enabled__c = true;
        objAccount.Type = 'Partner';
        objAccount.Status__c='A';
        objAccount.PROFILED_ACCOUNT_FLAG__c = true;
        update objAccount;
        System.Debug('objAccount ----> ' + objAccount) ;       
        return objAccount;
    }
    
}