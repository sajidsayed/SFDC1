/*============================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR        DESCRIPTION                               

 |  ====          =========                ==        =========== 

 | 23/06/2011    Suman B                            This is a test class for PRM_VPP_VelocitySpecialities    
 | 10/11/2011    Suman B                            Calling createVPPCustomSettingData() in Test methods. 
 +=============================================================================================*/

@isTest
private class PRM_VPP_VelocitySpecialities_TC {
static testMethod void myUnitTest() {

	User partner;
	User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1]; 
	System.runAs(insertUser)
	{
		PRM_VPP_JobDataHelper.createVPPCustomSettingData(); 
	}
	List<Account> lstAccounts=AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
	insert lstAccounts;
	for(Account acc : lstAccounts)
	{
		acc.IsPartner=true;
		acc.PROFILED_ACCOUNT_FLAG__c =true;
		acc.Cluster__c='EMEA 1B';
	}
	update lstAccounts;
	Contact con = UserProfileTestClassDataHelper.createContact();
	insert con;
	con.AccountId=lstAccounts[0].Id;
	con.Email='test23@emc.com';
	update con;
	System.runAs(insertUser)
	{
		partner = new User(
		Username='test1234'+Math.random()+'@emc.com.test',
		TimeZoneSidKey='America/New_York',
		LocaleSidKey='en_US',
		FirstName='Direct',
		LastName='Rep',
		ProfileId = '00e70000001FhPm',
		UserRoleId = null,
		email='john@emc.com',
		Alias='test',
		EmailEncodingKey='ISO-8859-1',
		LanguageLocaleKey='en_US',
		Forecast_Group__c='Direct',
		BU__c='NA',
		Employee_Number__c='9323782818',
		IsActive=true,
		ContactId=con.Id
		
		);
		insert partner; 
		partner.IsPortalEnabled=true;
		partner.isActive=True;
		update partner; 
		
		set<Id> setRecordTypeId = new set<Id>();
	  Map<String,Schema.RecordTypeInfo> recordTypes = Velocity_Rules__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
	  Id SpeicalityRuleRecTypeId = recordTypes.get('Specialty Rule').getRecordTypeId();
	  setRecordTypeId.add(SpeicalityRuleRecTypeId);
	  SpeicalityRuleRecTypeId = recordTypes.get('Field Based Rule Type').getRecordTypeId(); 
	  setRecordTypeId.add(SpeicalityRuleRecTypeId); 
	  system.debug('setRecordTypeId--------->'+setRecordTypeId);
	  
	 RecordType rectype=[SELECT IsActive, Id,SobjectType, SystemModstamp FROM RecordType where IsActive=true and Name like'%Specialty Rule%' and SobjectType='Velocity_Rules__c' limit 1];
	  
	 Account_Groupings__c  gp = new Account_Groupings__c();
	 gp.name='test grouping';
	 gp.account__c='test account';
	 insert Gp;
	 Velocity_Rules__c vr = new Velocity_Rules__c();
	 vr.Display_Name__c='Cloud Architect';
	 vr.RecordTypeId = rectype.id ;
	 vr.Evaluation_at__c = 'Country Grouping Level';
	 vr.Specilaity__c='Backup and Recovery';
	 insert vr;
	 
	 Velocity_Rules__c vr1 = new Velocity_Rules__c();
	 vr1.Display_Name__c='Advanced Consolidate';
	 vr1.RecordTypeId = rectype.id ;
	 vr1.Evaluation_at__c = 'Country Grouping Level';
	 vr1.Specilaity__c='Advanced Consolidate';
	 insert vr1;
	 Velocity_Rules__c vr2 = new Velocity_Rules__c();
	 vr2.Display_Name__c='Governance and Archive';
	 vr2.RecordTypeId = rectype.id ;
	 vr2.Evaluation_at__c = 'Country Grouping Level';
	 vr2.Specilaity__c='Governance and Archive';
	 insert vr2;
	 Velocity_Rules__c vr3 = new Velocity_Rules__c();
	 vr3.Display_Name__c='Cloud Builder Practice';
	 vr3.RecordTypeId = rectype.id ;
	 vr3.Evaluation_at__c = 'Country Grouping Level';
	 vr3.Specilaity__c='Cloud Builder Practice';
	 insert vr3;
	  Velocity_Rules__c vr4 = new Velocity_Rules__c();
	 vr4.Display_Name__c='Consolidate';
	 vr4.RecordTypeId = rectype.id ;
	 vr4.Evaluation_at__c = 'Country Grouping Level';
	 vr4.Specilaity__c='Consolidate';
	 insert vr4;
	 
	 Velocity_Rule_Results__c vrr = new Velocity_Rule_Results__c();
	 vrr.AccountID__c =partner.contact.Account.id;
	 vrr.Speciality_RuleID__c = vr.id;
	 vrr.Grouping__c = gp.id;
	 insert vrr;
	 Velocity_Rule_Results__c vrr1 = new Velocity_Rule_Results__c();
	 vrr1.AccountID__c =partner.contact.Account.id;
	 vrr1.Speciality_RuleID__c = vr1.id;
	 vrr1.Grouping__c = gp.id;
	 insert vrr1;
	 Velocity_Rule_Results__c vrr2 = new Velocity_Rule_Results__c();
	 vrr2.AccountID__c =partner.contact.Account.id;
	 vrr2.Speciality_RuleID__c = vr2.id;
	 vrr2.Grouping__c = gp.id;
	 insert vrr2;
	 Velocity_Rule_Results__c vrr3 = new Velocity_Rule_Results__c();
	 vrr3.AccountID__c =partner.contact.Account.id;
	 vrr3.Speciality_RuleID__c = vr3.id;
	 vrr3.Grouping__c = gp.id;
	 insert vrr3;
	 Velocity_Rule_Results__c vrr4 = new Velocity_Rule_Results__c();
	 vrr4.AccountID__c =partner.contact.Account.id;
	 vrr4.Speciality_RuleID__c = vr4.id;
	 vrr4.Grouping__c = gp.id;
	 insert vrr4;
	
	 
	 List<Velocity_Rule_Results__c> specialityResultRecords = [Select v.Account_Theater__c, v.AccountID__c,
	                                                                     v.CurrencyIsoCode, v.Current__c, v.Grouping__c,
	                                                                   v.Id, v.IsDeleted, v.Name, 
	                                                                      v.Rule_theater__c, v.Speciality_RuleID__c, 
	                                                                     v.Speciality_RuleID__r.RecordTypeId, 
	                                                                     v.Speciality_RuleID__r.Required__c, v.Status__c,
	                                                                     v.Speciality_RuleID__r.Bucket__c,
	                                                                      v.Speciality_RuleID__r.Name,
	                                                                      v.Speciality_RuleID__r.Required_Type__c,
	                                                                    v.Speciality_RuleID__r.Display_Name__c,
	                                                                      v.Speciality_RuleID__r.Id,
	   
	                                                                       v.Speciality_RuleID__r.Sort__c,
	                                                                   v.Speciality_RuleID__r.BR_Sub_category__c,
	                                                                      v.Required_Value_Type__c,v.RequiredCount__c,
	                                                                       v.SystemModstamp,v.Speciality_RuleID__r.Specilaity__c 
	                                                                       from Velocity_Rule_Results__c v  
	                                                                      where 
	                                                                       v.Speciality_RuleID__r.RecordTypeId in :setRecordTypeId 
	                                                                      and AccountID__c=:partner.contact.Account.id
	                                                                      AND v.Speciality_RuleID__r.Evaluation_at__c ='Country Grouping Level'
	                                                                       ORDER BY v.Speciality_RuleID__r.Sort__c];
	        
	}
	System.runAs(partner){
	                                         
	PRM_VPP_VelocitySpecialities velspObj = new PRM_VPP_VelocitySpecialities();
	velspObj.getEMCSpecialityStatusItems();
	velspObj.fetchSpecialityRuleResults(partner.contact.Account.id);
	velspObj.cancelUpdates();
	velspObj.updateProfileAccount();
	velspObj.preferredDistributorCheck(partner.contact.Account.id,partner.contact.Account.id);
	PRM_VPP_VelocitySpecialities.SpecialitySubDataContainer spesubdata=new PRM_VPP_VelocitySpecialities.SpecialitySubDataContainer();
	spesubdata.subCategoryName='Consolidate';
	spesubdata.subSpecialityStatus='Not deployed';
	
	} 
  }
}