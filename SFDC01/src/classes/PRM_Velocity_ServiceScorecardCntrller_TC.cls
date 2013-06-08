/*=========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 

 |  06.04.2012      Anand Sharma    188152      This will be used for unit testing
                                                RM_Velocity_ServiceScorecardController Class                                            
 +==========================================================================================================================*/

@isTest
public class PRM_Velocity_ServiceScorecardCntrller_TC {
    static testMethod void myUnitTest() {
    
        /*Creating account record*/
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId();
        List<Account> objAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert objAccount;
        for(Account accs : objAccount){
            accs.Type = 'Partner';
            accs.Partner_Type__c ='Distributor;Distribution VAR'; 
            accs.Lead_Oppty_Enabled__c=true;
            accs.Cluster__c='EMEA';
        }
        update objAccount;
        
        User insertUser = [Select id , profileid from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
            List<VelocityRules__c> lstVR = new List<VelocityRules__c>();
            VelocityRules__c objVR1 = new VelocityRules__c();
            objVR1.Name ='ServiceRule1';            
            objVR1.SpecialityRules__c='QSS Implement';
            lstVR.add(objVR1);
            VelocityRules__c objVR2 = new VelocityRules__c();
            objVR2.Name ='ServiceRule2';
            objVR2.SpecialityRules__c='QSS Support';
            lstVR.add(objVR2);
            VelocityRules__c objVR3 = new VelocityRules__c();
            objVR3.Name ='ServiceRule3';
            objVR3.SpecialityRules__c='VS Implement';
            lstVR.add(objVR3);
            VelocityRules__c objVR4 = new VelocityRules__c();
            objVR4.Name ='ServiceRule4';
            objVR4.SpecialityRules__c='VS Support';
            lstVR.add(objVR4);
            VelocityRules__c objVR5 = new VelocityRules__c();
            objVR5.Name ='ServiceRule5';
            objVR5.SpecialityRules__c='VS Manage';
            lstVR.add(objVR5);
            VelocityRules__c objVR6 = new VelocityRules__c();
            objVR6.Name ='ServiceRule6';
            objVR6.SpecialityRules__c='VS Assembly';
            lstVR.add(objVR6);
            
            Database.insert(lstVR, false);
            
            List<CustomSettingDataValueMap__c> lstCDVM = new List<CustomSettingDataValueMap__c>();
            CustomSettingDataValueMap__c objCDVM = new CustomSettingDataValueMap__c();
            objCDVM.Name = 'Service Scorecard profile';
            objCDVM.DataValue__c = insertUser.profileid;
            lstCDVM.add(objCDVM);
        
            CustomSettingDataValueMap__c objCDVM2 = new CustomSettingDataValueMap__c();
            objCDVM2.Name = 'Service Scorecard theater';
            objCDVM2.DataValue__c = 'Americas,EMEA';
            lstCDVM.add(objCDVM2);
            Database.insert(lstCDVM, false);      

            Map<String,Schema.RecordTypeInfo> recordTypesVR = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id vrRecordTypeId = recordTypesVR.get('Services Rule').getRecordTypeId();
        
            List<Velocity_Rules__c> lstVelocityRules = new List<Velocity_Rules__c>();
            Velocity_Rules__c objVRule1 = new Velocity_Rules__c();
            objVRule1.Display_Name__c ='VNXe';
            objVRule1.VS_Section__c = 'QSS Implement';
            objVRule1.AND_OR__c ='OR';
            objVRule1.Required__c = '1';
            objVRule1.Sort__c =1;
            objVRule1.Required_Type__c ='Number/Count';
            objVRule1.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule1);
            
            Velocity_Rules__c objVRule2 = new Velocity_Rules__c();
            objVRule2.Display_Name__c ='VNXe';
            objVRule2.VS_Section__c = 'QSS Support';
            objVRule2.AND_OR__c ='OR';
            objVRule2.Required__c = '1';
            objVRule2.Sort__c =2;
            objVRule2.Required_Type__c ='Number/Count';
            objVRule2.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule2);
            
            Velocity_Rules__c objVRule3 = new Velocity_Rules__c();
            objVRule3.Display_Name__c ='RecoverPoint';
            objVRule3.VS_Section__c = 'VS Implement';
            objVRule3.AND_OR__c ='OR';
            objVRule3.Required__c = '1';
            objVRule3.Sort__c =3;
            objVRule3.Required_Type__c ='Number/Count';
            objVRule3.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule3);
            
            Velocity_Rules__c objVRule4 = new Velocity_Rules__c();
            objVRule4.Display_Name__c ='RecoverPoint';
            objVRule4.VS_Section__c = 'VS Support';
            objVRule4.AND_OR__c ='OR';
            objVRule4.Required__c = '1';
            objVRule4.Sort__c =4;
            objVRule4.Required_Type__c ='Number/Count';
            objVRule4.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule4);
            
            Velocity_Rules__c objVRule5 = new Velocity_Rules__c();
            objVRule5.Display_Name__c ='CLARiiON';
            objVRule5.VS_Section__c = 'VS Manage';
            objVRule5.AND_OR__c ='OR';
            objVRule5.Required__c = '1';
            objVRule5.Sort__c =5;
            objVRule5.Required_Type__c ='Number/Count';
            objVRule5.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule5);            
           
            
            Velocity_Rules__c objVRule6 = new Velocity_Rules__c();
            objVRule6.Display_Name__c ='VNXe';
            objVRule6.VS_Section__c = 'VS Assembly';
            objVRule6.AND_OR__c ='OR';
            objVRule6.Required__c = '1';
            objVRule6.Sort__c =6;
            objVRule6.Required_Type__c ='Number/Count';
            objVRule6.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule6);
            
            Database.insert(lstVelocityRules, false);
            
            List<Velocity_Rule_Results__c> ServiceRuleList = new List<Velocity_Rule_Results__c>();
            Velocity_Rule_Results__c objVRR1 = new Velocity_Rule_Results__c();
            objVRR1.Speciality_RuleID__c = lstVelocityRules[0].Id;
            objVRR1.AccountID__c =objAccount[0].Id;
            objVRR1.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR1);
            
            Velocity_Rule_Results__c objVRR2 = new Velocity_Rule_Results__c();
            objVRR2.Speciality_RuleID__c = lstVelocityRules[1].Id;
            objVRR2.AccountID__c =objAccount[0].Id;
            objVRR2.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR2);
            
            Velocity_Rule_Results__c objVRR3 = new Velocity_Rule_Results__c();
            objVRR3.Speciality_RuleID__c = lstVelocityRules[2].Id;
            objVRR3.AccountID__c =objAccount[0].Id;
            objVRR3.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR3);
            
            Velocity_Rule_Results__c objVRR4 = new Velocity_Rule_Results__c();
            objVRR4.Speciality_RuleID__c = lstVelocityRules[3].Id;
            objVRR4.AccountID__c =objAccount[0].Id;
            objVRR4.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR4);
            
            Velocity_Rule_Results__c objVRR5 = new Velocity_Rule_Results__c();
            objVRR5.Speciality_RuleID__c = lstVelocityRules[4].Id;
            objVRR5.AccountID__c =objAccount[0].Id;
            objVRR5.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR5);
            
            Velocity_Rule_Results__c objVRR6 = new Velocity_Rule_Results__c();
            objVRR6.Speciality_RuleID__c = lstVelocityRules[5].Id;
            objVRR6.AccountID__c =objAccount[0].Id;
            objVRR6.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR6);
            
            Database.insert(ServiceRuleList, false);
        }
          Map<String,Schema.RecordTypeInfo> recordTypesVR = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id vrRecordTypeId = recordTypesVR.get('Services Rule').getRecordTypeId();
        List<Velocity_Rules__c> lstVelocityRules1 = new List<Velocity_Rules__c>();
            Velocity_Rules__c objVRule7 = new Velocity_Rules__c();
            objVRule7.Display_Name__c ='VNXe';
            objVRule7.VS_Section__c = 'QSS Implement';
            objVRule7.AND_OR__c ='OR';
            objVRule7.Required__c = '1';
            objVRule7.Sort__c =1;
            objVRule7.Required_Type__c ='Number/Count';
            objVRule7.RecordTypeId = vrRecordTypeId;
            lstVelocityRules1.add(objVRule7);
            
            Velocity_Rules__c objVRule8 = new Velocity_Rules__c();
            objVRule8.Display_Name__c ='VNXe';
            objVRule8.VS_Section__c = 'QSS Support';
            objVRule8.AND_OR__c ='OR';
            objVRule8.Required__c = '1';
            objVRule8.Sort__c =2;
            objVRule8.Required_Type__c ='Number/Count';
            objVRule8.RecordTypeId = vrRecordTypeId;
            lstVelocityRules1.add(objVRule8);
            Database.insert(lstVelocityRules1, false);
            
        
         List<Velocity_Rule_Results__c> ServiceRuleList1 = new List<Velocity_Rule_Results__c>();
            Velocity_Rule_Results__c objVRR7 = new Velocity_Rule_Results__c();
            objVRR7.Speciality_RuleID__c = lstVelocityRules1[0].Id;
            objVRR7.AccountID__c =objAccount[0].Id;
            objVRR7.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList1.add(objVRR7);
            
            Velocity_Rule_Results__c objVRR8 = new Velocity_Rule_Results__c();
            objVRR8.Speciality_RuleID__c = lstVelocityRules1[1].Id;
            objVRR8.AccountID__c =objAccount[0].Id;
            objVRR8.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList1.add(objVRR8);
            
            Database.insert(ServiceRuleList1, false);
        
        
        /*Creating Custom Setting Record*/
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        ApexPages.StandardController controller01 = new ApexPages.StandardController(objAccount[0]); 
        ApexPages.currentPage().getParameters().put('id',objAccount[0].Id);
        PRM_Velocity_ServiceScorecardController VSscorecard = new PRM_Velocity_ServiceScorecardController() ;
        VSscorecard.fetchSpecialityRuleResults(objAccount[0].Id);
        VSscorecard.updateProfileAccount();
        VSscorecard.cancelUpdates();
        VSscorecard.UpdateDeploymentStatus(ServiceRuleList1);
        
    }
    
    static testMethod void myUnitTestComponent() {
        /*Creating Custom Setting Record*/
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
        /*Creating account record*/
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId();
        List<Account> objAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
        insert objAccount;
        for(Account accs : objAccount){
            accs.Type = 'Partner';
            accs.Partner_Type__c ='Distributor;Distribution VAR'; 
            accs.Lead_Oppty_Enabled__c=true;
            accs.Cluster__c='EMEA';
        }
        update objAccount;
        
        User insertUser = [Select id , profileid from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
            Map<String,Schema.RecordTypeInfo> recordTypesVR = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id vrRecordTypeId = recordTypesVR.get('Services Rule').getRecordTypeId();
        
            List<Velocity_Rules__c> lstVelocityRules = new List<Velocity_Rules__c>();
            Velocity_Rules__c objVRule1 = new Velocity_Rules__c();
            objVRule1.Display_Name__c ='VNXe';
            objVRule1.VS_Section__c = 'QSS Implement';
            objVRule1.AND_OR__c ='OR';
            objVRule1.Required__c = '1';
            objVRule1.Sort__c =1;
            objVRule1.Required_Type__c ='Number/Count';
            objVRule1.RecordTypeId = vrRecordTypeId;
            lstVelocityRules.add(objVRule1);
            
            Database.Insert(lstVelocityRules, false);
            List<Velocity_Rule_Results__c> ServiceRuleList = new List<Velocity_Rule_Results__c>();
            Velocity_Rule_Results__c objVRR5 = new Velocity_Rule_Results__c();
            objVRR5.Speciality_RuleID__c = lstVelocityRules[0].Id;
            objVRR5.AccountID__c =objAccount[0].Id;
            objVRR5.VS_Rule_Result_Status__c ='Deployed';
            ServiceRuleList.add(objVRR5);
            Database.insert(ServiceRuleList, false);
            
            PRM_VelocityServiceComponentController obj = new PRM_VelocityServiceComponentController ();
            obj.setServiceResourceLabel(true);
            obj.setSpecialityList(ServiceRuleList);
            obj.getSpecialityList();
            obj.getServiceResourceLabel();
        }
    }
}