/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      =========== 

 |  02.05.2011       Anil Sure                     This will used for unit testing of 
 |                                                PRM_OnBoardingPDFViewController Class.
 +=========================================================================================================================*/

@isTest
private class PRM_OnBoardingPDFViewController_TC {
static testMethod void myUnitTest() {
	   
	  
	   		User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
	        System.runAs(insertUser)
	        {
	    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
	        }
        	Map<String,Custom_Settings_Partner_OnBoarding__c>  pobdata =  Custom_Settings_Partner_OnBoarding__c.getall();
	   		String TestQueue = pobdata.get('STEP1.0Americas').Owner__c ;
	   		List<GroupMember> lstgroupmambers= [SELECT UserOrGroupId  FROM GroupMember where Group.Id =: TestQueue];
	   		Set<Id> idset=new Set<Id>();
	   		for(GroupMember gm : lstgroupmambers)
	   		{
	   			idset.add(gm.UserOrGroupId);
	   		}
	   		User user1= [SELECT Email FROM User where Id in :idset limit 1];
	     	List<Account> acc = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
	        insert acc;
	        Contact cont = UserProfileTestClassDataHelper.createContact();
	        cont.AccountId=acc[0].Id;
	        insert cont; 
	        cont.Email=user1.Email;
	        update cont;     
	      
       Partner_Onboarding__c pobRecord = new Partner_Onboarding__c();
                pobRecord.Region_you_are_applying_for__c = 'APJ';
                pobRecord.EMC_Sponsoring_Distributor__c = 'UNITTESTdistri';
                pobRecord.First_Name__c = 'UNITTESTFrstName';
                pobRecord.Last_Name__c = 'UNITTESTLastName';
                pobRecord.E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.Title__c = 'UNITTESTTitle';
                pobRecord.Contact_Office_Number__c = '54485871';
                pobRecord.Corporate_URL__c = 'UNITTESTUrl@test.com' ;
                pobRecord.Legal_Parent_Company_Name__c = 'UNITTESTCompany';
                pobRecord.Country__c = 'India';
                pobRecord.Main_Company_Phone_Number__c = '54634656';
                pobRecord.Address_1__c = 'UNITTESTAddress1';
                pobRecord.City__c = 'UNITTESTCity';
                pobRecord.Zip_Postal_Code__c = '4515';
                pobRecord.Primary_EMC_Business_Line_Interest__c = 'Storage';
                pobRecord.Vertical_Market_Specialization__c = 'Construction';
                pobRecord.Application_Environments__c = 'Oracle';
                pobRecord.Company_Overview_1000_characters_max__c = 'UNITTESTCmpnyOverview';
                pobRecord.Primary_Business_Contact_First_Name__c = 'UNITTESTFrstNameBusiness';
                pobRecord.President_CEO_First_Name__c = 'UNITTESTFrstNameCEO';
                pobRecord.Primary_Business_Contact_Last_Name__c = 'UNITTESTLastNameBusiness';
                pobRecord.President_CEO_Last_Name__c = 'UNITTESTLastNameCEO';
                pobRecord.Primary_Business_Contact_E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.President_CEO_E_mail_Address__c = 'UNITTESTEmail@test.com' ;
                pobRecord.Primary_Business_Contact_Title__c = 'UNITTESTTitleBusiness';
                pobRecord.President_CEO_Phone_Number__c = '16831655';
                pobRecord.Primary_Business_Contact_Phone_Number__c = '15461645';
                pobRecord.I_Accept__c = True;
        Insert pobRecord ;
        //return pob_rec1;
        
    Test.StartTest();
    ApexPages.StandardController controller01 = new ApexPages.StandardController(pobRecord ); 
    ApexPages.currentPage().getParameters().put('id',pobRecord.Id);
    PRM_OnBoardingPDFViewController objPdfViewController = New PRM_OnBoardingPDFViewController(controller01);
    objPdfViewController.getPOB();
    Test.StopTest();
     
    }
}