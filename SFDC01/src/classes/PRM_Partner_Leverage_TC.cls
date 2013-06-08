/*===================================================================================================================================

History 

17th Nov  11  Kaustav Debnath     Added the code for PRM Partner leverage functionality testing
8th  Dec  11  Kaustav Debnath     Added the partner_se field in acumen rating creation record
                                  this field has been made master detail relationship    
                                               
5 March 2012   Arif               Update Commented 
7 May   2012   Anand Sharma      Increase code coverage of class and schedular
02Aug   2012   Ganesh Soma        Reverted the code for Multtile Theater code of EMCBusinessRules
22Nov 2012     vivek kodi      Added two parameters for inserting/email error records
02/05/2013  Nimai Meher			  Commented PRM_PL_has_BRS_Accreditation__c field as part of WR - 256428 (Contact simplification) for June Release . 
====================================================================================================================================*/
@isTest
public class PRM_Partner_Leverage_TC{

     Static List<Account> acctLst = new List<Account>();
     //Static List<Account> acctLst1 = new List<Account>();
     Static List<Opportunity> lstOpp= new List<Opportunity>();
     Static List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSE = new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
     Static List<Contact> contLst = new  List<Contact>();
     Static List<User_Attribute_Mapping__c> lstAtt = new List<User_Attribute_Mapping__c>();
     Static User_Attribute_Mapping__c objUsr = new User_Attribute_Mapping__c();
     Static User_Attribute_Mapping__c objUsr1 = new User_Attribute_Mapping__c();
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
        
        
        /*acctLst[0].Lead_Oppty_Enabled__c=true;
        acctLst[0].type='Partner';*/
        acctLst[0].PROFILED_ACCOUNT_FLAG__c=true;
        acctLst[1].PROFILED_ACCOUNT_FLAG__c=false;
        Account_Groupings__c gr=new Account_Groupings__c();
        gr.Profiled_Account__c=acctLst[0].id;
        gr.name='testing Grouping';
        gr.Account__c='test';
        insert gr;
        acctLst[0].grouping__c=gr.id;
        acctLst[2].grouping__c=gr.id;
        acctLst[0].Ispartner=true;
        acctLst[1].Ispartner=true;
        Database.update(acctLst);
        
        List<Account>  acctLst1=[select id,name,theater1__c,BillingCountry,grouping__c from account where id in :setAccountIds];
        System.debug('##### acctLst[0].theater1__c'+acctLst[0].theater1__c);
        System.debug('##### acctLst1'+acctLst1);
        
        
        System.debug('Account Created');
       return acctLst1;
    }

      
   public void createOpportunity(){
        
          for(Integer i=0;i<10;i++){   
                Opportunity opp_Obj = new Opportunity();
                opp_Obj.AccountId =acctLst[0].id;
                opp_Obj.Name = 'TEST';
                //opp_Obj.StageName = 'TEST';
                opp_Obj.CloseDate = Date.today()+10;
                opp_Obj.Sales_Force__c = 'EMC';
                opp_Obj.Sales_Channel__c = 'Direct';
                opp_Obj.VMWare_Related__c = 'VMWare Backup';
                //opp_Obj.Tier_2_Partner__c = acctLst[1].id;
                opp_Obj.Update_Forecast_Amount_from_Quote__c=false;
                opp_Obj.Partner__c = acctLst[0].id;
                opp_Obj.stageName = 'Booked';
                lstOpp.add(opp_Obj);
           }
            
       insert lstOpp;
       
       
    }
    

     public List<Contact> createContact(List<Account> lstAccount){

        System.debug('### lstAccount==>'+lstAccount);
        Contact contObj = new Contact();
        contObj.LastName = 'Tester';
        contObj.Phone = '999999999';
        contObj.Email = 'xxxx@acc.com';
        contObj.accountId=lstAccount[0].Id;
        contObj.Partner_SE__c = true;
        contObj.emc_pre_sales__c='70%';
        contLst.add(contObj);
        
        Contact contObj1 = new Contact();
        contObj1.LastName = 'Tester1';
        contObj1.accountId=lstAccount[0].Id;
        contObj1.Phone = '99999999';
        contObj1.Email = 'xxx@acc.com';
        contObj1.Partner_SE__c = true;
        contObj1.emc_pre_sales__c='150%';
        contLst.add(contObj1);
        insert contLst;
        Set<Id> setContactIds=new Set<Id>();
        for(Integer i=0;i<2;i++)
        {
            setContactIds.add(contLst[i].id);
        }
        List<Contact> contLst1 = [Select ID,Email,Phone,Partner_SE__c,account_theater__c,account.name,account.id from Contact where id in:setContactIds];
        System.debug('#### contLst1'+contLst1);
        System.debug('#### contLst1[1].account.name'+contLst1[1].account.name);
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
    public List<Partner_Performance_Rating_by_Field__c> createPartnerPerformanceRecords(List<Opportunity> lstOpportunity,List<Contact> lstContact)
    {
        List<Partner_Performance_Rating_by_Field__c > lstPartnerPerf=new List<Partner_Performance_Rating_by_Field__c>();
        
        for(Integer i=0;i<10;i++)
        {
            Partner_Performance_Rating_by_Field__c partnerPerf=new Partner_Performance_Rating_by_Field__c();
            //System.debug('### i=>'+i);
            partnerPerf.opportunity__c=lstOpportunity[i].id;
            //partnerPerf.partner__c=acctLst[0].id;
            partnerPerf.partner_se__c=lstContact[1].id;
            lstPartnerPerf.add(partnerPerf);
        }
        insert lstPartnerPerf;
        return lstPartnerPerf;
    }
    
    public void deletePartnerPerformanceRecords(List<Partner_Performance_Rating_by_Field__c> lstPartnerPerfRecords)
    {
        //List<Partner_Performance_Rating_by_Field__c > lstPartnerPerf=new List<Partner_Performance_Rating_by_Field__c>();
        
        /*for(Integer i=0;i<10;i++)
        {
            Partner_Performance_Rating_by_Field__c partnerPerf=new Partner_Performance_Rating_by_Field__c();
            //System.debug('### i=>'+i);
            partnerPerf.opportunity__c=lstOpportunity[i].id;
            //partnerPerf.partner__c=acctLst[0].id;
            partnerPerf.partner_se__c=lstContact[1].id;
            lstPartnerPerf.add(partnerPerf);
        }
        insert lstPartnerPerf;*/
        delete lstPartnerPerfRecords;
    }
    public List<EMC_Business_Rules__c> createEMCBusinessRules(){
        List<EMC_Business_Rules__c> lstEMCBusinessRules=new List<EMC_Business_Rules__c>();
        List<EMC_Business_Rules__c> lstEMCBusinessRulesWithEducation=new List<EMC_Business_Rules__c>();
        EMC_BR_Education_Group_Record__c eduGroupRec=new EMC_BR_Education_Group_Record__c();
        for(integer i=0;i<12;i++)
        {
            EMC_Business_Rules__c emcBRObj=new EMC_Business_Rules__c();
            if(i==0)
            {
                emcBRObj.field_name__c='PRM_PL_Certifications__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=4;
                lstEMCBusinessRules.add(emcBRObj);
                
            }
            else if(i==1)
            {
                emcBRObj.field_name__c='PRM_PL_Expert_Certifications__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=4;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==2)
            {
                emcBRObj.field_name__c='PRM_PL_has_Consolidation_Accreditation__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=1;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==3)
            {
                emcBRObj.field_name__c='PRM_PL_has_Governance_Archive_Accred__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=1;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==4)
            {
               // emcBRObj.field_name__c='PRM_PL_has_BRS_Accreditation__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=1;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==5)
            {
                emcBRObj.field_name__c='PRM_PL_Adjusted_Product_Skill_Rating__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=2;
                emcBRObj.Maximum_Score__c=10;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==6)
            {
                emcBRObj.field_name__c='PRM_PL_Unadjusted_Product_Skill_Rating__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=2;
                emcBRObj.Maximum_Score__c=10;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==7)
            {
                emcBRObj.field_name__c='PRM_PL_Adjusted_Sales_Acumen_Rating__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=2;
                emcBRObj.Maximum_Score__c=10;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==8)
            {
                emcBRObj.field_name__c='PRM_PL_Unadjusted_Sales_Acumen_Rating__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=2;
                emcBRObj.Maximum_Score__c=10;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==9)
            {
                emcBRObj.field_name__c='PRM_PL_Other_Expertise__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=2;
                emcBRObj.Maximum_Score__c=10;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==10)
            {
                emcBRObj.field_name__c='PRM_PL_Engagements__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=4;
                lstEMCBusinessRules.add(emcBRObj);
            }
            else if(i==11)
            {
                emcBRObj.field_name__c='PRM_PL_EMC_Pre_Sales_FTE__c';
                emcBRObj.theater__c='Americas';
                emcBRObj.Unit__c=1;
                emcBRObj.Weight__c=1;
                emcBRObj.Maximum_Score__c=4;
                lstEMCBusinessRules.add(emcBRObj);
            }
            
        }
        insert lstEMCBusinessRules;
        lstEMCBusinessRulesWithEducation=[select id,field_name__c,unit__c,weight__c,maximum_score__c from EMC_Business_Rules__c where id in :lstEMCBusinessRules
        and field_name__c in ('PRM_PL_Certifications__c','PRM_PL_Expert_Certifications__c','PRM_PL_has_Consolidation_Accreditation__c','PRM_PL_has_Governance_Archive_Accred__c'
        )];
        /*insert lstEMCBusinessRules;
        lstEMCBusinessRulesWithEducation=[select id,field_name__c,unit__c,weight__c,maximum_score__c from EMC_Business_Rules__c where id in :lstEMCBusinessRules
        and field_name__c in ('PRM_PL_Certifications__c','PRM_PL_Expert_Certifications__c','PRM_PL_has_Consolidation_Accreditation__c','PRM_PL_has_Governance_Archive_Accred__c'
        ,'PRM_PL_has_BRS_Accreditation__c')];
        */
        
        return lstEMCBusinessRulesWithEducation;
        
    }
     public void createAcumenRating(List<Contact> lstContact){
         
            for(Integer k=0 ; k<3 ; k++)
            {
                Partner_SE_Skill_Sales_Acumen_Rating__c objAcumen = new Partner_SE_Skill_Sales_Acumen_Rating__c();
                if(k==0){
                objAcumen.partner_se__c=lstContact[0].id;
                objAcumen.VCE_Skill__c   = '3';
                objAcumen.Unified_Skill__c = '3';   
                objAcumen.Symmetrix_Sales__c = '3';             
                objAcumen.Symmetrix_Skill__c = '3'; 
                objAcumen.RSA_Security_Skill__c = '3';
                objAcumen.Replication_Skill__c = '3';   
                objAcumen.BRS_Avamar_Skill__c = '3';
                objAcumen.BRS_Data_Domain_Skill__c = '3';
                objAcumen.BRS_Networker_Skill__c = '3';
                objAcumen.IP_Networking_Skill__c = '3';
                objAcumen.Isilon_Skill__c = '3';
                objAcumen.VMware_Skill__c = '3';

                objAcumen.VMware_Sales__c= '3';
                objAcumen.Unified_Sales__c = '3';
                objAcumen.RSA_Security_Sales__c = '3';               
                objAcumen.BRS_Avamar_Sales__c = '3';    
                objAcumen.BRS_Data_Domain_Sales__c = '3';
                objAcumen.BRS_Networker_Sales__c = '3';
                objAcumen.IP_Networking_Sales__c = '3';         
                objAcumen.Isilon_Sales__c = '3';
                objAcumen.Replication_Sales__c = '3';   
                objAcumen.VCE_Sales__c = '3';   

                objAcumen.Dell__c = '3';                    
                objAcumen.HDS__c = '3';                 
                objAcumen.HP__c= '3';                   
                objAcumen.IBM__c= '3';                  
                objAcumen.NTAP__c= '3'; 

                objAcumen.Oracle_App_Competence__c='Yes';
                objAcumen.SAP_App_Competence__c='Yes';
                objAcumen.SQL_App_Competence__c='Yes';
                objAcumen.VCE_App_Competence__c='Yes';
                objAcumen.VMware_App_Competence__c='Yes';
            }
            if(k==1)
            {
                objAcumen.partner_se__c=lstContact[0].id;
                objAcumen.VCE_Skill__c   = 'N/A';
                objAcumen.Unified_Skill__c = 'N/A'; 
                objAcumen.Symmetrix_Sales__c= 'N/A';           
                objAcumen.Symmetrix_Skill__c = 'N/A';
                objAcumen.RSA_Security_Skill__c = 'N/A';
                objAcumen.Replication_Skill__c=  'N/A';   
                objAcumen.BRS_Avamar_Skill__c=  'N/A';
                objAcumen.BRS_Data_Domain_Skill__c=  'N/A';
                objAcumen.BRS_Networker_Skill__c=  'N/A';
                objAcumen.IP_Networking_Skill__c=  'N/A';
                objAcumen.Isilon_Skill__c=  'N/A';
                objAcumen.VMware_Skill__c=  'N/A';

                objAcumen.VMware_Sales__c=  'N/A';                    
                objAcumen.Unified_Sales__c=  'N/A';
                objAcumen.RSA_Security_Sales__c=  'N/A';               
                objAcumen.BRS_Avamar_Sales__c=  'N/A';    
                objAcumen.BRS_Data_Domain_Sales__c=  'N/A';
                objAcumen.BRS_Networker_Sales__c=  'N/A';
                objAcumen.IP_Networking_Sales__c=  'N/A';         
                objAcumen.Isilon_Sales__c=  'N/A';
                objAcumen.Replication_Sales__c=  'N/A';   
                objAcumen.VCE_Sales__c=  'N/A';   

                objAcumen.Dell__c=  'N/A';                    
                objAcumen.HDS__c=  'N/A';                 
                objAcumen.HP__c=  'N/A';                    
                objAcumen.IBM__c=  'N/A';                    
                objAcumen.NTAP__c=  'N/A';                    

            }
            if(k==2){
                objAcumen.partner_se__c=lstContact[1].id;
                objAcumen.VCE_Skill__c   = '6';
                objAcumen.Unified_Skill__c = '6';   
                objAcumen.Symmetrix_Sales__c = '6';             
                objAcumen.Symmetrix_Skill__c = '6'; 
                objAcumen.RSA_Security_Skill__c = '6';
                objAcumen.Replication_Skill__c = '6';   
                objAcumen.BRS_Avamar_Skill__c = '6';
                objAcumen.BRS_Data_Domain_Skill__c = '6';
                objAcumen.BRS_Networker_Skill__c = '6';
                objAcumen.IP_Networking_Skill__c = '6';
                objAcumen.Isilon_Skill__c = '6';
                objAcumen.VMware_Skill__c = '6';

                objAcumen.VMware_Sales__c= '6';
                objAcumen.Unified_Sales__c = '6';
                objAcumen.RSA_Security_Sales__c = '6';               
                objAcumen.BRS_Avamar_Sales__c = '6';    
                objAcumen.BRS_Data_Domain_Sales__c = '6';
                objAcumen.BRS_Networker_Sales__c = '6';
                objAcumen.IP_Networking_Sales__c = '6';         
                objAcumen.Isilon_Sales__c = '6';
                objAcumen.Replication_Sales__c = '6';   
                objAcumen.VCE_Sales__c = '6';   

                objAcumen.Dell__c = '6';                    
                objAcumen.HDS__c = '6';                 
                objAcumen.HP__c= '6';                   
                objAcumen.IBM__c= '6';                  
                objAcumen.NTAP__c= '6'; 

                objAcumen.Oracle_App_Competence__c='Yes';
                objAcumen.SAP_App_Competence__c='Yes';
                objAcumen.SQL_App_Competence__c='Yes';
                objAcumen.VCE_App_Competence__c='Yes';
                objAcumen.VMware_App_Competence__c='Yes';
                objAcumen.Ratings_Validated_by_Core_TC__c=true;
            }
            lstSE.add(objAcumen);

            }

            insert lstSE;
            
            lstSE[1].Parent_Partner_SE_Skill_Sales_Acumen__c=lstSE[0].id;
            update lstSE[1];

                
    }

    public void createUserRole(){
    UserRole objRole = new UserRole();

    }
     public void createUserAttribute(){
       Profile p = [select id from profile where name='System Administrator'];
       String orgId = UserInfo.getOrganizationId();
              User u = new User(alias = 'utest', email=orgId+'unit.test@unit.test.com',isactive=true,
              emailencodingkey='UTF-8', lastname='Unit Test', 
              languagelocalekey='en_US',
              localesidkey='en_GB', profileid = p.Id,
              timezonesidkey='Europe/London', 
              username=orgId+'unit.test@unit.test.com');
              insert u;
       System.RunAs(u){
       	system.debug('user created' +u);
        UserRole usrRole = new UserRole();
        UserRole topRole=[select id,name from UserRole where parentroleid=null limit 1];
        
        usrRole.name = 'Testing testing 1###';
        usrRole.parentRoleid=topRole.id;    
        insert usrRole;
        
        Profile p1 = [select id from profile where name='System Administrator'];
        String orgId2 = UserInfo.getOrganizationId();
         objUsr1  = [Select id,name,role_id__c from User_Attribute_Mapping__c where Sales_Role__c = 'Enterprise DM' limit 1 ];  
           //objUsr1.Sales_Role__c = 'TS District Mgr';
           User u1 = new User(alias = 'utest', email=orgId2+'unit.test@unit.test.com',isactive=true,
              userroleid=objUsr1.role_id__c,
              emailencodingkey='UTF-8', lastname='Unit Test', 
              languagelocalekey='en_US',
              localesidkey='en_GB', profileid = p.Id,
              timezonesidkey='Europe/London', 
              username=orgId2+'unit1.test1@unit.test.com');
             // insert u1;
             // update objUsr1;
            
           List<User> lstUsersWithRoles=[select id,name from user where userroleid=:objUsr.role_id__c];
           //delete 
           // System.debug('User_Attribute_Mapping__c --->' +objUsr); 
           objUsr.Name = 'Testing testing 1###';
            objUsr.Area__c = 'APJ';
            objUsr.BU__c = 'BURA';
            objUsr.Country__c = 'Albania';
            objUsr.District__c = 'ACT';
            objUsr.Division__c = 'ANZ';
            objUsr.Forecast_Group__c = 'APJ Verticals';
            objUsr.Region__c = 'AMER';
            objUsr.Sales_Role__c = 'TS District Mgr';
            objUsr.Super_Area__c = 'AMESA';
            objUsr.Super_Division__c = 'Mid Market';
            objUsr.Theater__c = 'APJ';
            objUsr.Role_Id__c= usrRole.id;
            insert objUsr;
        
        }
    }

    static testMethod void test() {
        
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        PRM_Partner_Leverage_TC testObj = new PRM_Partner_Leverage_TC();
        user SysAdmin=[Select Id,Name,Profile.Name,isActive from user where Profile.Name like 'System Administrator' and isActive=true limit 1];        
        List<Account> lstAccount=testObj.createAccount();
        System.runas(SysAdmin){
            testObj.createOpportunity();
        }
        System.debug('### lstAccount=>'+lstAccount);
        List<Contact> lstContact;
        System.runas(SysAdmin){
            lstContact=testObj.createContact(lstAccount);
        }
        Education_Groups__c eduGroup=testObj.createEducationGroupRecords();
        Education_Master__c eduMaster=testObj.createEducationMasterRecords();
        Education_Group_Member__c eduMasterEduGroup=testObj.createEducationMasterEducationGroupRecords(eduGroup,eduMaster);
        
        List<EMC_Business_Rules__c> lstEMCBRWithEducation=testObj.createEMCBusinessRules();
        testObj.createEducationEducationGroupRecords(eduGroup,lstEMCBRWithEducation);
        testObj.createAcumenRating(lstContact);
        testObj.createEducationRecords(lstContact,eduMaster);
        List<Partner_Performance_Rating_by_Field__c> lstPartnerPerfRecordsInserted = testObj.createPartnerPerformanceRecords(lstOpp,lstContact);
        Set<Id> setOpps=new Set<Id>();
        System.runas(SysAdmin){
              testObj.createUserAttribute();
              }
        
         
        for(Integer opp=0 ; opp<lstOpp.size() ; opp++){ 
        lstOpp[opp].stageName = 'Booked';
        lstOpp[opp].Update_Forecast_Amount_from_Quote__c=false;
        setOpps.add(lstOpp[opp].id);
        }
        
        update lstOpp;
        delete objUsr;
        
        /*Account profiledAccount=[select id,name,PROFILED_ACCOUNT_FLAG__c,grouping__c from account where grouping__c != null and PROFILED_ACCOUNT_FLAG__c=true limit 1];
        profiledAccount.rating_eligible__c=true;
        
        update profiledAccount;
        profiledAccount.rating_eligible__c=false;
        update profiledAccount;*/
        acctLst[0].rating_eligible__c=false;
        update acctLst;
        acctLst[0].rating_eligible__c=true;
        Test.starttest();
        //update acctLst;        
        List<Partner_SE_Skill_Sales_Acumen_Rating__c> lstSESkillToUpdate=new List<Partner_SE_Skill_Sales_Acumen_Rating__c>();
        for(Partner_SE_Skill_Sales_Acumen_Rating__c seObj:lstSE)
        {
            seObj.Ratings_Validated_by_Core_TC__c=true;
            lstSESkillToUpdate.add(seObj);
        }
        update lstSESkillToUpdate;
        
        PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContact);
        Set<Id> setGroupingIds=new Set<Id>();
        setGroupingIds.add(lstAccount[0].grouping__c);
        //setGroupingIds.add(lstAccount[1].grouping__c);
       // PRM_Partner_Leverage.accountPartnerLevFactorCalculation(setGroupingIds);
        String Batchid ='' ;
    List <EMCException> errors = new List <EMCException>();
        PRM_Partner_Leverage.accountPartnerLevFactorCalculation(setGroupingIds,Batchid,errors);
        PRM_Partner_Leverage.updateOpportunityRecordType(setOpps,true);
        // PRM_Partner_Leverage.updateOpportunityRecordType(setOpps,false);
        PRM_VPP_TEST_VelocityRuleResult batchJobObj= new PRM_VPP_TEST_VelocityRuleResult();
        batchJobObj.runJobForALLPL();
        batchJobObj.schedulePLTheaterwiseJobs('Americas');
        String Theater='Americas';
        String query = 'select id,name,partner_se__c,accountid, Account.Profiled_Account__c,Account.PROFILED_ACCOUNT_FLAG__c, Account.Profiled_Account__r.rating_eligible__c, Account.Grouping__c, emc_pre_sales__c,account.rating_eligible__c,account_theater__c from contact where id=\'' + lstContact[0].id + '\' order by account_theater__c'; 
        PartnerSEContactSummaryFieldsUpdateBatch contactBatch = new PartnerSEContactSummaryFieldsUpdateBatch(query);  
        //SelectedPLJobs.add(new SequencialBatchJob('Partner Lev Contact Calculation: ' +Theater, contactBatch,200)); 
        database.executebatch(contactBatch);
        String queryAccount ='select id,grouping__c,PROFILED_ACCOUNT_FLAG__c,Partner_Leverage_Factor_Average__c,Partner_Leverage_Factor_Total__c,name,theater1__c,(select contact.id,contact.Partner_Leverage_Factor__c from account.contacts where contact.partner_se__c=true) from account where PROFILED_ACCOUNT_FLAG__c=true and rating_eligible__c=true and id=\'' + acctLst[0].id + '\' order by theater1__c';  
        AccountPartnerSEFieldsUpdateBatch accountBatch= new AccountPartnerSEFieldsUpdateBatch(queryAccount);
        database.executebatch(accountBatch);
        testObj.deletePartnerPerformanceRecords(lstPartnerPerfRecordsInserted);       
        Test.stopTest();

        
    }
    
    public static testMethod void testSchedular_PartnerLev_Jobs() {
        
        Test.StartTest();      
      // run batch 
      String strScheduleTime ='0 0 0 3 9 ? ';
      strScheduleTime = strScheduleTime + Datetime.now().addYears(1).year();
      String jobId = System.schedule('testBasicScheduledApex',strScheduleTime, new PRM_PartnerLev_Jobs_Scheduler());
        
      Test.StopTest();
    }
}