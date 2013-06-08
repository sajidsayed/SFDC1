/*=========================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER         WR        DESCRIPTION                               

 |  ====          =========         ==        =========== 

 |  28/06/2011    Suman B                       This is a Test Class for PRM_EducationViewController_TC.
 |  14/12/2011	  Anil							Removed Query for fetching Partner and used Custom setting Data Helper   
 	27 Dec 2011   Arif                        	Eliminated Mixed DML exception as well as null pointer exceptions.
 |  11-JAN-2012	  Anil							Removed role Id
 +=========================================================================================*/

@isTest
private class PRM_EducationViewController_TC {

 static testmethod void EducationViewController_test(){
       User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
       User partner;
       List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();
       System.runAs(insertUser){
	       insert acc;
	       for(Account accounts:acc)
	       {
	       	accounts.Type='Partner';
	       	accounts.IsPartner=true;
	       }
	       
	       update acc;
	       
	       System.debug('acc[0].id'+acc[0].id);
	       Contact cont = UserProfileTestClassDataHelper.createContact();
	       insert cont;
	       cont.AccountId=acc[0].id;
	       cont.Email='test23@emc.com';
	       cont.Partner_Contact2__c=true;
	       update cont;
	       System.debug('cont.AccountId'+cont.AccountId);
	       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
	       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
	       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
	       partner = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,cont.Id);
	       insert partner;
	       system.debug('partnerAccountID'+partner.Contact.AccountId);
	       system.debug('partnerContactID'+partner.ContactId);
		   partner.IsPortalEnabled = true;
		   update partner;
       }
       //insert partner;

            
   system.runAs(partner){

     PRM_EducationViewController contrlr = new PRM_EducationViewController();
        contrlr.getstatus() ;
        contrlr.getflag() ;
        contrlr.getName();
        contrlr.getNameDetail();
        contrlr.getOwner();
        contrlr.getContact();
        contrlr.getEducationType();
        contrlr.getDate_Achieved();
        contrlr.getCategory();
        contrlr.getExpiration_Date();
        contrlr.getLevel();
        contrlr.getDays_to_Expiration();
        contrlr.getMentoring_Required();
        contrlr.getEducation_Master();
        contrlr.getTransaction_Id();
        contrlr.getPartner_Grouping_ID();
        contrlr.getMentoring_Completed();
        contrlr.getMentoring_Date();
        contrlr.getMentoring_Type();
        contrlr.getMentoring_Schduled();
        contrlr.getEMC_Mentoring_Location();
        contrlr.getMentoring_Scheduled_Date();
        contrlr.getEMC_Mentor_Name();
        contrlr.getCLARiiON();
        contrlr.getBACKUP_NETWORKER();
        contrlr.getFirst_Name();
        contrlr.getLast_Name();
        contrlr.getESBI_Name();
        contrlr.getPartner_Grouping();
        contrlr.getCert_Id();
        contrlr.getCountry();
        contrlr.getEducation_Id();
        contrlr.getSABA_Contact_ID();
        contrlr.getEmail();
        contrlr.getAttention_Partners();
        contrlr.getAttention_EMC_Employees();
        contrlr.getCreatedBy();
        contrlr.getLastModifiedBy();
        contrlr.getComments(); 
        contrlr.setMentoring_Schduled(true);
        contrlr.setCLARiiON(true);
        contrlr.setBACKUP_NETWORKER(true);
        contrlr.setNAS(true);
        contrlr.getNAS() ;
     }
     
 }
}