/*==============================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  23/06/2011    Suman B                         This is a test class for PRM_VPP_VelocityScorecardController.                       
 |  14/12/2011    Anil                            Removed Query for fetching Partner and used Custom setting Data Helper
 |  16/05/2012    Kaustav                         Increased the code coverage         
 |  17/05/2012    Anand Sharma                    Grouping issue exception 
 |  04/12/2012    Anand Sharma                    Fixed for PRM_VPP_VelocityRuleResults constuctor  
 |  22/04/2013    Krishna Pydavula		223956    Increased the code coverage
 +==============================================================================================================*/

@isTest
private class PRM_VPP_VelocityScorecardController_TC {

  static testMethod void myUnitTest() {

       User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
       
     /*Creating account record*/
       Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Id accRecordTypeId = recordTypes.get('Customer Account Record Type').getRecordTypeId();
       List<Account> objAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
       insert objAccount;
       /*Creation of Grouping record */ 
       Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp',Profiled_Account__c=objAccount[0].Id);
       insert grouping;
       for(Integer iCounter=0;iCounter<objAccount.size();iCounter++)
       {
           if(iCounter==0)
           {
                objAccount[iCounter].Velocity_Solution_Provider_Tier__c='Affiliate';
           }
           else if(iCounter==1)
           {
                objAccount[iCounter].Velocity_Solution_Provider_Tier__c='SSCP';
           }
           objAccount[iCounter].Type = 'Partner';
           objAccount[iCounter].Grouping__c = grouping.Id;
           objAccount[iCounter].Partner_Type__c ='Distributor;Distribution VAR'; 
           objAccount[iCounter].Lead_Oppty_Enabled__c=true;
           objAccount[iCounter].Cluster__c='LA1';
           
       }
       update objAccount;
       
       
           Map<String,Schema.RecordTypeInfo> recordTypes1 = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName();
           Id veloRecordTypeId = recordTypes1.get('Tier Rule').getRecordTypeId();
           Velocity_Rules__c velocityRuleObj= new Velocity_Rules__c();
           velocityRuleObj.Display_Name__c='test Data';
           velocityRuleObj.Specilaity__c='Backup and Recovery';
           velocityRuleObj.Specialty_Rule_Type__c='LA1';
           velocityRuleObj.Cluster__c='LA1';
           velocityRuleObj.AND_OR__c='OR';
           velocityRuleObj.Sort__c=1;
           velocityRuleObj.recordtypeid=veloRecordTypeId;
           velocityRuleObj.Bucket__c='Post Sales';
           velocityRuleObj.Is_Total_Revenue__c= false;
           velocityRuleObj.Tier__c= 'Signature';
           insert velocityRuleObj;
           
           List<Velocity_Rule_Results__c> lstVelocityRuleResult=new List<Velocity_Rule_Results__c>();
           for(Integer iCounter=0;iCounter<4;iCounter++)
           {
                Velocity_Rule_Results__c veloRuleResultObj=new Velocity_Rule_Results__c();
                veloRuleResultObj.Speciality_RuleID__c=velocityRuleObj.id;
                veloRuleResultObj.AccountID__c=objAccount[iCounter].Id;
                veloRuleResultObj.Grouping__c = grouping.Id;
                lstVelocityRuleResult.add(veloRuleResultObj);               
           }
           insert lstVelocityRuleResult;
           ApexPages.StandardController controller01 = new ApexPages.StandardController(objAccount[0]); 
           ApexPages.currentPage().getParameters().put('id',objAccount[0].Id);
           PRM_VPP_VelocityScorecardController scorecard = new PRM_VPP_VelocityScorecardController() ;           
           scorecard.getItems();
           scorecard.getTierScoreCard();
           scorecard.getComplianceRequirementStatusItems();
           scorecard.getTierScoreCardSingle();
           scorecard.cancelUpdates();
           
           ApexPages.StandardController controller02 = new ApexPages.StandardController(objAccount[1]); 
           ApexPages.currentPage().getParameters().put('id',objAccount[1].Id);
           PRM_VPP_VelocityScorecardController scorecard1 = new PRM_VPP_VelocityScorecardController() ;           
           scorecard1.getItems();
           scorecard1.getTierScoreCard();
           scorecard1.getComplianceRequirementStatusItems();
           scorecard1.getTierScoreCardSingle();
           scorecard1.cancelUpdates();
           
           ApexPages.StandardController controller03 = new ApexPages.StandardController(objAccount[2]); 
           ApexPages.currentPage().getParameters().put('id',objAccount[2].Id);
           PRM_VPP_VelocityScorecardController scorecard2 = new PRM_VPP_VelocityScorecardController() ;           
           scorecard2.getItems();
           scorecard2.getTierScoreCard();
           scorecard2.getComplianceRequirementStatusItems();
           scorecard2.getTierScoreCardSingle();
           scorecard2.cancelUpdates();
           
          
       if(scorecard.SpecialityRulesResult == Null || scorecard.SpecialityRulesResult.size()==0){

           List<Account> listAccount = new List<Account>();
           //listAccount.add(partner.contact.Account) ;
           listAccount.addall(objAccount) ;
           PRM_VPP_VelocityRuleResults vrrresults = new PRM_VPP_VelocityRuleResults(listAccount, false) ;
            vrrresults.createVelocityRuleResults();
           scorecard.SpecialityRulesResult = [Select v.AccountID__c, v.AccountID__r.EMC_Speciality__c, v.Current__c, v.Speciality_RuleID__c, v.Speciality_RuleID__r.Bucket__c, 
                                                                 v.Speciality_RuleID__r.Display_Name__c, v.Speciality_RuleID__r.Required__c, 
                                                                 v.Speciality_RuleID__r.Specilaity__c,v.Speciality_RuleID__r.Is_Total_Revenue__c,v.Status__c,
                                                                 v.rule_theater__c,v.Speciality_RuleID__r.Tier__c ,v.Required_Value_Type__c,v.Is_Total_Revenue__c,
                                                                 v.RequiredCount__c,v.Speciality_RuleID__r.Sort__c
                                                           from Velocity_Rule_Results__c v
                                                           where Speciality_RuleID__r.RecordTypeId=: scorecard.specilalityRecordtypeId
                                                            AND v.rule_theater__c =: scorecard.clusterValue
                                                            AND v.AccountID__c=: scorecard.AccountRecord.Id
                                                            ORDER BY v.Speciality_RuleID__r.Sort__c asc
                                                            ];
         }                                                            
           System.debug('###### scorecard.SpecialityRulesResult=>'+scorecard.SpecialityRulesResult);
           scorecard.populateData();
           scorecard.updateProfileAccount();
           PRM_VPP_VelocityScorecardController.PRM_DisplayNameDataContainer namedatacntnr = new PRM_VPP_VelocityScorecardController.PRM_DisplayNameDataContainer();
                    namedatacntnr.setmapTierNameValueDataContainer('testtier','test'); 
                    
          PRM_VPP_VelocityScorecardController.PRM_BucketNameDataContainer bucketcntnr = new PRM_VPP_VelocityScorecardController.PRM_BucketNameDataContainer();
                    bucketcntnr.setmapBucketNameValueDataContainer(namedatacntnr);   
                   
          	    Account acc=[select id,name,Type,Grouping__c,Partner_Type__c,Lead_Oppty_Enabled__c,Cluster__c,Preferred_Distributor__c from Account where Preferred_Distributor__c!=null limit 1];  
          		if(acc!=null)
          		{
		           ApexPages.StandardController controller04 = new ApexPages.StandardController(acc); 
		           ApexPages.currentPage().getParameters().put('id',acc.id);
		           PRM_VPP_VelocityScorecardController scorecard3 = new PRM_VPP_VelocityScorecardController() ;           
		           scorecard2.getItems();
	          	   scorecard2.getTierScoreCard();
	               scorecard2.getComplianceRequirementStatusItems();
	               scorecard2.getTierScoreCardSingle();
	               scorecard2.cancelUpdates();
          		}
       //}
 
    }
        
}