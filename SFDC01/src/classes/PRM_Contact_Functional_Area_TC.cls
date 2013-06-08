/*===================================================================================================================================

History 
DATE          DEVELOPER      WR         DESCRIPTION                               
====          =========      ==         =========== 
4 May  2012   Anirudh Singh  189799     This Test class is used to perform unit testing for PRM_Contact_Functional_Area_UpdateBatch
                                        and PRM_Contact_Functional_Area Class 
====================================================================================================================================*/
@isTest
public class PRM_Contact_Functional_Area_TC{

     Static List<Account> acctLst = new List<Account>();     
     Static List<Contact> contLst = new  List<Contact>();
     
     //Method for Creation Of Account    
    public List<Account> createAccount(){
       
       for(Integer acc=0 ; acc<3 ; acc++){
        System.debug('Inside Account Creation');     
        Account acctObj = new Account();
        acctObj.Name = 'Partner Account';
        acctObj.Partner_Type__c='Direct Reseller';
        acctObj.rating_eligible__c = true;
        acctObj.BillingCountry='Colombia';
        //acctObj.theater1__c='Americas';
        acctObj.Lead_Oppty_Enabled__c=true;
        acctObj.type='Partner';
        acctObj.Site_DUNS_Entity__c='test999999999';
        //acctObj.Ispartner=true;
        acctLst.add(acctObj);

       }
        insert acctLst;
        Set<Id> setAccountIds=new Set<Id>();
        for(Integer acc=0 ; acc<3 ; acc++){
            setAccountIds.add(acctLst[acc].id);
        }
        
        
        acctLst[0].PROFILED_ACCOUNT_FLAG__c=true;
        acctLst[1].PROFILED_ACCOUNT_FLAG__c=false;
        Account_Groupings__c testgrouping=new Account_Groupings__c();
        testgrouping.Profiled_Account__c=acctLst[0].id;
        testgrouping.name='testing Grouping';
        testgrouping.Active__c = true;
        testgrouping.No_Master_Required__c = false;
        insert testgrouping;
        acctLst[0].grouping__c=testgrouping.id;
        acctLst[2].grouping__c=testgrouping.id;
        acctLst[0].Ispartner=true;
        acctLst[1].Ispartner=true;
        Database.update(acctLst);
        
        List<Account>  acctLst1=[select id,name,theater1__c,BillingCountry,grouping__c from account where id in :setAccountIds];        
       return acctLst1;
    }

      
  
    

     public List<Contact> createContact(List<Account> lstAccount){

        System.debug('### lstAccount==>'+lstAccount);
        Contact contObj = new Contact();
        contObj.LastName = 'Tester';
        contObj.Phone = '999999999';
        contObj.Email = 'xxxx@acc.com';
        contObj.accountId=lstAccount[0].Id;
        contObj.Partner_SE__c = true;
        contObj.Functional_Area1__c = 'Pre-Sales';
        contObj.emc_pre_sales__c='70%';
        contLst.add(contObj);
        
        Contact contObj1 = new Contact();
        contObj1.LastName = 'Tester1';
        contObj1.accountId=lstAccount[0].Id;
        contObj1.Phone = '99999999';
        contObj1.Email = 'xxx@acc.com';
        contObj1.Partner_SE__c = true; 
        contObj.Functional_Area1__c=null;       
        contObj1.emc_pre_sales__c='150%';
        contLst.add(contObj1);
        insert contLst;
        Set<Id> setContactIds=new Set<Id>();
        for(Integer i=0;i<2;i++)
        {
            setContactIds.add(contLst[i].id);
        }
        List<Contact> contLst1 = [Select ID,Email,Phone,Partner_SE__c,account_theater__c,account.name,account.id from Contact where id in:setContactIds];        
        return contLst1;
    }
    
    public Education_Groups__c createEducationGroupRecords()
    {
        Education_Groups__c eduGroupObj=new Education_Groups__c();
        eduGroupObj.Education_Group_Name__c='testGroup';
        insert eduGroupObj;
        return eduGroupObj;     
    }
    public Education_Master__c createEducationMasterRecords()
    {
        Education_Master__c eduMasterObj=new Education_Master__c();
        eduMasterObj.ESBI_Name__c='test';
        eduMasterObj.ESBI_ID__c='test1234';
        insert eduMasterObj;
        return eduMasterObj;
    }
    public Education_Group_Member__c createEducationMasterEducationGroupRecords(Education_Groups__c eduGroup,Education_Master__c eduMaster)
    {
        System.debug('#### eduGroup=>'+eduGroup);
        System.debug('#### eduMaster=>'+eduMaster);
        Education_Group_Member__c eduMember=new Education_Group_Member__c();
        eduMember.Education_Group__c=eduGroup.id;
        eduMember.Education_Master__c=eduMaster.id;
        insert eduMember;
        return eduMember;
    }
    public void createEducationEducationGroupRecords(Education_Groups__c eduGroup,List<EMC_Business_Rules__c> lstEMCBR)
    {
        List<EMC_BR_Education_Group_Record__c> lstEMCBREduGroupRecord=new List<EMC_BR_Education_Group_Record__c>();
        for(EMC_Business_Rules__c emcBRObj:lstEMCBR)
        {
            EMC_BR_Education_Group_Record__c eduGroupEMCBR=new EMC_BR_Education_Group_Record__c();
            eduGroupEMCBR.Group__c=eduGroup.id;
            eduGroupEMCBR.Speciality_Rule__c=emcBRObj.id;
            lstEMCBREduGroupRecord.add(eduGroupEMCBR);          
        }
        insert lstEMCBREduGroupRecord;
        //return eduGroupEMCBR;
    }
    
    public void createEducationRecords(List<Contact> lstContact,Education_Master__c eduMaster)
    {
        List<Education__c> lstEducation=new List<Education__c>();
        
        for(Integer i=0;i<10;i++)
        {
            Education__c eduRec=new Education__c();
            System.debug('### i=>'+i);
            eduRec.contact__c=lstContact[0].id;
            if(Math.mod(i,3)==0)
            {
                eduRec.type__c='Certification';
                eduRec.Education_Master__c=eduMaster.id;
            }
            else if(Math.mod(i,3)==1)
            {
                eduRec.type__c='Certification';
                eduRec.level__c='Expert';
                eduRec.Education_Master__c=eduMaster.id;
            }
            else if(Math.mod(i,3)==2)
            {
                eduRec.type__c='Accreditation';
                eduRec.category__c='Governance & Archive';
                eduRec.Education_Master__c=eduMaster.id;
            }
            lstEducation.add(eduRec);
        }
        insert lstEducation;
    }
       
    
    public List<EMC_Business_Rules__c> createEMCBusinessRules(){
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();         
        CustomSettingDataValueMap__c FA_EMC_BR_RecordtypeId = (mapCustomSettingDataValueMap.get('PRM_FA_EMC_BR_Rec_Type'));
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();
        List<EMC_Business_Rules__c> lstEMCBusinessRulesWithEducation=new List<EMC_Business_Rules__c>();
        EMC_BR_Education_Group_Record__c eduGroupRec=new EMC_BR_Education_Group_Record__c();
        for(integer i=0;i<12;i++)
        {
            EMC_Business_Rules__c emcBRObj=new EMC_Business_Rules__c();
            if(i==0)
            {
                emcBRObj.AND_OR__c='OR';
                emcBRObj.theater__c='Americas';
                emcBRObj.Functional_Area__c='Sales';
                emcBRObj.RecordTypeId = FA_EMC_BR_RecordtypeId.DataValue__c ;                
                lstEMCBusinessRules.add(emcBRObj);
                
            }
            else if(i==1)
            {
                emcBRObj.AND_OR__c='OR';
                emcBRObj.theater__c='Americas';
                emcBRObj.Functional_Area__c='Sales';
                emcBRObj.RecordTypeId=FA_EMC_BR_RecordtypeId.DataValue__c ; 
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==2)
            {
                emcBRObj.AND_OR__c='AND';
                 emcBRObj.theater__c='Americas';
                emcBRObj.Functional_Area__c='Pre-Sales';
                emcBRObj.RecordTypeId=FA_EMC_BR_RecordtypeId.DataValue__c ; 
                lstEMCBusinessRules.add(emcBRObj);
            }
        }   
        insert lstEMCBusinessRules;       
        return lstEMCBusinessRules;
        
    }
    

    static testMethod void test() {
        
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        PRM_Contact_Functional_Area_TC testObj = new PRM_Contact_Functional_Area_TC();
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1];        
        List<Account> lstAccount=testObj.createAccount();        
        List<Contact> lstContact;
        System.runas(SysAdmin){
            lstContact=testObj.createContact(lstAccount);
        }
        Education_Groups__c eduGroup=testObj.createEducationGroupRecords();
        Education_Master__c eduMaster=testObj.createEducationMasterRecords();
        Education_Group_Member__c eduMasterEduGroup=testObj.createEducationMasterEducationGroupRecords(eduGroup,eduMaster);
        
        List<EMC_Business_Rules__c> lstEMCBRWithEducation=testObj.createEMCBusinessRules();
        testObj.createEducationEducationGroupRecords(eduGroup,lstEMCBRWithEducation);        
        testObj.createEducationRecords(lstContact,eduMaster);        
        Test.starttest();        
        //PRM_VPP_TEST_VelocityRuleResult batchJobObj= new PRM_VPP_TEST_VelocityRuleResult();
       // batchJobObj.runJobForALLPL();
       // batchJobObj.schedulePLTheaterwiseJobs('Americas');
        String Theater='Americas';
        String query = 'select id,name,Account_Theater__c,functional_Area__c,functional_Area1__c,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c from contact where Active__c = true and account.IsPartner=true and accountid =\''+lstAccount[0].id+'\'';
        //PRM_Contact_Functional_Area_UpdateBatch contactBatch = new PRM_Contact_Functional_Area_UpdateBatch(query);         
        database.executebatch(new PRM_Contact_Functional_Area_UpdateBatch(query),10);              
        Test.stopTest();

        
    }
}