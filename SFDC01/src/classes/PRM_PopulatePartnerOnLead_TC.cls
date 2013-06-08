/*====================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER     WR         DESCRIPTION                               

 |  ====          =========     ==         =========== 

 | 21/10/2010   Suman B         Req# 1117  Req# 1117  Modified the test class as per change in Profile name 
                                           'Direct Reseller Partner User' and 'Distribution VAR Partner User'.
                                           and  Account Field PartnerType value  using custom settings.
 |              Ashwini Gowda              Created data by inserting User,Contacts and Accouonts instead of
                                           Querying
 | 8/10/2010    Ashwini Gowda              Commented utils.fromGroup(usrIds)as it was taking UserIds instead
                                           of queueIds.
 | 20/10/2010   Ashwini Gowda   1318       UnCommented utils.fromGroup(usrIds) as the issue is fixed.
 | 12/11/2010   Ashwini Gowda              Fixed Validation Exception by updating the query on lead.                                                                                  
 | 11/11/2010   Saravanan C                Fixed null pointer Exception.   
 |  Aug-2011    Saravanan C            	   Test Class cleanup
 | 19/12/2011	Anil				   	   Removed Query for fetching Partner and used Custom setting Data Halper
 | 11-JAN-2012	  Anil					   Removed role Id  
 | 07-Jan-2013   Vivek		  206404	   Add new methods	
 |=============================================================================================================== */

@isTest
private Class PRM_PopulatePartnerOnLead_TC{

  private static testMethod void startTest(){
    
   list<lead> leads = new list<lead> ();
   list<lead> leadtest = new list<lead> ();
   list<lead> lstLeadPullback = new list<lead>();
	        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        list<User> inactiveUser = [Select id from User where isActive=false and usertype like '%Standard%' limit 1];
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }  
	       List<Account> acc = AccountAndProfileTestClassDataHelper.CreateCustomerAccount();       
	       insert acc;
	       for(Account acc1 : acc)
	       {
	       	acc1.Type='Partner';
	       	acc1.IsPartner=true;
	       }
	       update acc;
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
                       
           Lead l = new Lead(LastName='testlm2', firstname='testfm2', company='test2', 
                                  email='test2@test.com',ownerid=partner.Id); 
           Lead lTest = new Lead(LastName='testlm3', firstname='testfm3', company='test3', LeadOwnerchek__c = true,Last_EMC_Owner__c=inactiveUser[0].id,
                                  email='test3@test.com',ownerid=partner.Id,EMC_Pull_Back__c = true,Previous_Owner__c =partner.Id);                         
    
    
           Lead LeadPullback = new Lead(LastName='testlm2', firstname='testfm2', company='test2', DealRegOwner__c = true,
                                  email='test2@test.com',ownerid=partner.Id,LeadOwnerchek__c=true,Last_EMC_Owner__c =partner.id); 
         
     	  
     	   leads.add(l);
     	   insert leads;
     	   lstLeadPullback.add(LeadPullback);
     	   insert lstLeadPullback;
     	   leadtest.add(lTest);
     	   insert leadtest;
    
   
    PRM_PopulatePartnerOnLead obj = new PRM_PopulatePartnerOnLead();  
    obj.populatePartneronLead(leads);
    obj.UpdateOwnerforLeadPullback(lstLeadPullback);
    obj.UpdateOwnerforLeadPullback(leadtest);
    obj.UpdateOwnerforDealReg(lstLeadPullback);
    
   QueueSobject Queue = [Select SobjectType, QueueId From QueueSobject where SobjectType = 'Lead' limit 1];
    System.Debug(' Queue check here ===> ' + Queue  );
     
    for(lead a : leads){
     a.ownerId = Queue.QueueId;
     a.recordtypeId = '01270000000Q7MD';
    }
    update leads;
    
    List<Lead> LeadsToProcess = New List<Lead>();
    LeadsToProcess = [SELECT id, ownerId, Reject_Lead__c, Accept_Lead__c,Tier_2_Partner__c, Partner__c, Previous_CAM_Email__c, CAM_Email__c, Channel__c,
                          Last_Inside_Sales_Owner__c, Last_EMC_Owner__c,RecordTypeId FROM Lead 
                          where (Partner__c = NULL AND Tier_2_Partner__c = NULL ) and (Reporting_Owner__r.ContactId<> null or owner.Name like 'Partner%')limit 10];
    List<Database.SaveResult> dsrs = Database.update(LeadsToProcess, false);
    if(dsrs.size()>0){
       	  PRM_PopulatePartnerOnLead.logFailedRecords(dsrs);
    } 
   
    PRM_PopulatePartnerOnLead obj1 = new PRM_PopulatePartnerOnLead();  
    obj1.populatePartneronLead(leads); 
    obj1.leadAssignedDistiorEMCuser();
   }  
  
  
  private static User createUser(String Profilename,id ContactId){          
    
            Profile amerUserProf = [select Id from Profile where Name=:Profilename];
            System.debug('Profile---->'+amerUserProf);            
            User tempUsr = new User(
                 Username='test1234'+Math.random()+'@acme.com.test',
                 TimeZoneSidKey='America/New_York',
                 ProfileId=amerUserProf.Id,
                 LocaleSidKey='en_US',
                 FirstName='Direct',
                 LastName='Rep2',
                 email='john1@acme.com',
                 Alias='test',
                 EmailEncodingKey='ISO-8859-1',
                 LanguageLocaleKey='en_US',
                 Forecast_Group__c='Direct',
                 BU__c='NA',
                 Employee_Number__c='93237820001',
                 IsActive=true,
                 ContactId = ContactId
            );
           // insert tempUsr;
            System.debug('insert tempUsr--->'+tempUsr);
            return tempUsr;
        }
}