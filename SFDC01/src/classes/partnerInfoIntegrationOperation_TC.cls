/*=====================================================================================================================================

History 
2nd Aug  2012  Kaustav Debnath     This is the test class for testing the PartnerInfoIntegrationOperation test class
======================================================================================================================================*/ 
@isTest
private class partnerInfoIntegrationOperation_TC {

    public static List<Account> createProfiledAccount()
    {
	        list<Account> lstPartnerAccount = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
	        lstPartnerAccount[0].name = 'Distributor Account for eBusiness';
	        lstPartnerAccount[2].name = 'Distributor Account for eBusiness';
	        insert lstPartnerAccount;
	        lstPartnerAccount[0].PROFILED_ACCOUNT_FLAG__c = true;
	        lstPartnerAccount[0].Ispartner=true;
	        lstPartnerAccount[1].Ispartner=true;
	        lstPartnerAccount[3].Ispartner=true;
	        lstPartnerAccount[2].PROFILED_ACCOUNT_FLAG__c = true;
	        lstPartnerAccount[2].Ispartner=true;
	        update lstPartnerAccount;
	        return lstPartnerAccount;
	}
	public static List<Contact> createContact(Integer iCount){ 
        List<Contact> lstContactReturn=new List<Contact>();
        for(Integer iCounter=0;iCounter<iCount;iCounter++)
        {
        	 Contact cont = new Contact();
	        cont.LastName = 'testContact'+iCounter;
	        cont.Active__c = true ;
	        cont.Email = 'test'+iCounter+'@emc.com' ;
	        cont.Partner_User2__c=true;
	        cont.Partner_Contact2__c=true;
	        lstContactReturn.add(cont);
        }
       
        return lstContactReturn ;   
    }  
	 public static User createPortalUser(Id profileId,Id roleId,Id contactid){
        User tempUsr = new User(
             Username='test1234'+Math.random()+'@emc.com.test',
             TimeZoneSidKey='America/New_York',
             LocaleSidKey='en_US',
             FirstName='Direct',
             LastName='Rep',
             ProfileId = profileId,
             UserRoleId = roleId,
             ContactId = contactid,
             email='john@emc.com',
             Alias='test',
             EmailEncodingKey='ISO-8859-1',
             LanguageLocaleKey='en_US',
             Forecast_Group__c='Direct',
             BU__c='NA',
             Employee_Number__c='9323782818',
             IsActive=true 
        );
        return tempUsr;
    }
	public static List<Partner_Location__c> createPartnerLocation(set<Id> setProfiledAccountsId){
        List<Partner_Location__c> partnerLocationsList = new List<Partner_Location__c>();
        List<Account> lstprofiledAccountNew = [Select a.BillingCity, a.BillingCountry, 
                                               a.BillingPostalCode, a.BillingState, 
                                               a.BillingStreet,a.Grouping__c, 
                                               a.Grouping__r.Name, a.Id, a.Website 
                                               from Account a where a.Id in:setProfiledAccountsId];
                                                  
        for(Account profiledAccount :lstprofiledAccountNew){
            Partner_Location__c partnerLocation = new Partner_Location__c(
                                                       Name = profiledAccount.Grouping__r.Name,
                                                       Account__c = profiledAccount.Id,
                                                       City__c = profiledAccount.BillingCity,
                                                       Country__c = profiledAccount.BillingCountry,
                                                       Is_Primary__c = True,
                                                       Postal_Code__c = profiledAccount.BillingPostalCode,
                                                       State_Province__c = profiledAccount.BillingState,
                                                       Street__c = profiledAccount.BillingStreet,
                                                       Website__c = profiledAccount.Website);
            partnerLocationsList.add(partnerLocation);                                         
        }
        
        Insert partnerLocationsList;
        return partnerLocationsList;
    }
    static testMethod void myUnitTest() {
        List<Account> lstAccount=createProfiledAccount();
        List<Account> lstAccountToUpdate=new List<Account>();
        List<Partner_Location__c> lstPartnerLocationToUpdate=new List<Partner_Location__c>();
        List<Contact> cont = createContact(lstAccount.size());
        
			for(Integer iCount=0;iCount<cont.size();iCount++)
			{
				cont[iCount].AccountId=lstAccount[iCount].Id;
			}
			
			insert cont;
			
			List<Contact> lstContactQuery=[select id,Partner_User2__c,Partner_Contact2__c from Contact where id in :cont];
			System.debug('### lstContactQuery=>'+lstContactQuery);
			System.debug('### lstAccount=>'+lstAccount);
			System.debug('### lstAccount.size()=>'+lstAccount.size());
			System.debug('### cont=>'+cont);
			System.debug('### cont.size()=>'+cont.size());
			List<User> partner=new List<User>();
			User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
			
			System.runAs(insertUser)
			{       
				
				Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
				String distributorSuperUser = data.get('EMEA Distributor Partner User').DataValue__c ;
				Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
				for(Integer iCount=0;iCount<cont.size();iCount++)
				{
					
					System.debug('### cont[iCount].Id=>'+cont[iCount].Id);
					System.debug('### amerUserProf.id=>'+amerUserProf.id);
					System.debug('### iCount=>'+iCount);
					User partnerObj = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont[iCount].Id);
					partner.add(partnerObj);
				}
				
				insert partner;
			}
        Set<Id> setProfiledAccIds=new Set<Id>();
        if(lstAccount.size()>0)
        {
        	for(Integer iCount=0;iCount<lstAccount.size();iCount++)
        	{
        		setProfiledAccIds.add(lstAccount[iCount].id);
        		lstAccount[iCount].eBus_Partner_Enabled__c='Finder';
        		System.debug('### lstAccount[iCount].Id=>'+lstAccount[iCount].Id);
        		System.debug('### cont[iCount].accountid=>'+cont[iCount].AccountId);
        		System.debug('### cont[iCount].Partner_User2__c=>'+cont[iCount].Partner_User2__c);
        		System.debug('### cont[iCount].Partner_Contact2__c=>'+cont[iCount].Partner_Contact2__c);
        		lstAccount[iCount].eBus_Lead_Admin__c=cont[iCount].id;
        		lstAccountToUpdate.add(lstAccount[iCount]);
        	}	
        }
        if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
        {
        	System.runAs(insertUser)
			{
        		update lstAccountToUpdate;
			}
        }
        
        if(setProfiledAccIds.size()>0)
        {
        	List<Partner_Location__c> lstPartnerLocation=createPartnerLocation(setProfiledAccIds);
        	 System.debug('### lstPartnerLocation=>'+lstPartnerLocation);
        	 System.debug('### lstPartnerLocation.size()=>'+lstPartnerLocation.size());
        	 for(Partner_Location__c partnerLocObj:lstPartnerLocation)
        	 {
        	 	partnerLocObj.eBus_Location_Enabled__c=true;
        	 	lstPartnerLocationToUpdate.add(partnerLocObj);
        	 }
        }
        if(lstPartnerLocationToUpdate!=null && lstPartnerLocationToUpdate.size()>0)
        {
        	System.runAs(insertUser)
			{
        		update lstPartnerLocationToUpdate;
			}
        }
        if(lstAccount.size()>0)
        {
        	lstAccountToUpdate.clear();
        	for(Integer iCount=0;iCount<lstAccount.size();iCount++)
        	{
        		//setProfiledAccIds.add(lstAccount[iCount].id);
        		lstAccount[iCount].eBus_Partner_Enabled__c=null;
        		/*System.debug('### lstAccount[iCount].Id=>'+lstAccount[iCount].Id);
        		System.debug('### cont[iCount].accountid=>'+cont[iCount].AccountId);
        		System.debug('### cont[iCount].Partner_User2__c=>'+cont[iCount].Partner_User2__c);
        		System.debug('### cont[iCount].Partner_Contact2__c=>'+cont[iCount].Partner_Contact2__c);*/
        		lstAccount[iCount].eBus_Lead_Admin__c=null;
        		lstAccountToUpdate.add(lstAccount[iCount]);
        	}	
        }
        if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
        {
        	System.runAs(insertUser)
			{
        		update lstAccountToUpdate;
			}
        }
        List<PartnerInfoHeader> lstPartnerInfoHeader=PartnerInfoOperation.getInfoFromSFDC('PartnerInfoQuery');
       
        
    }
}