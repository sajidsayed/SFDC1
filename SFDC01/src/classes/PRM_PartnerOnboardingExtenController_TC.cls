/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  28/03/2011        Arif      Req#162077 This test class is used to test method written for 
                                           PRM_PartnerOnboardingExtensionController class.
 |  24/05/2012        Anil                 Fixed for June Release
 +==================================================================================================================**/

@isTest
private class PRM_PartnerOnboardingExtenController_TC

{ static Partner_Onboarding__c testpob_rec1;

static testMethod void myUnitTest() {
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }           Map<String,Custom_Settings_Partner_OnBoarding__c>  pobdata =  Custom_Settings_Partner_OnBoarding__c.getall();
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
            cont.Email='test03@abc.com';
            update cont;
    
    testpob_rec1 = Create_POB_Record('EMEA');
    testpob_rec1.I_will_be_the_primary_business_contact_f__c = true;
    update testpob_rec1;
    ApexPages.StandardController stdCon = new ApexPages.StandardController(testpob_rec1);
    
    PRM_PartnerOnboardingExtensionController pobextn= new PRM_PartnerOnboardingExtensionController(stdcon);
    pobextn.save();
//  pobextn.getApplicationID();
    pobextn.getflag();
    pobextn.setflag(false);
    pobextn.populatefields();
    pobextn.reset();
    pobextn.chnageLang();
    pobextn.getItems();
    pobextn.primaryContactAction();
}
/*@Method <This method is used to create Partner Onboarding Records.>*/ 
    static Partner_Onboarding__c Create_POB_Record(String Region)
    {
        Partner_Onboarding__c pob_rec1 = new Partner_Onboarding__c(
                                                Region_you_are_applying_for__c = Region,
                                                First_Name__c = 'Adam',
                                                Last_Name__c = 'Trott',
                                                Title__c = 'Mr.',
                                                E_mail_Address__c = 'adam@emc.com',
                                                Contact_Office_Number__c = '987654232',
                                                Legal_Parent_Company_Name__c = 'EMC',
                                                Corporate_URL__c = 'www.emc.com',
                                                Address_1__c = 'Boston',
                                                Main_Company_Phone_Number__c = '987654232',
                                                City__c = 'California',
                                                Zip_Postal_Code__c = '123456',
                                                EMC_Sponsoring_Distributor__c = 'Accenture',
                                                Primary_Business_Contact_First_Name__c = 'Alex',
                                                Primary_Business_Contact_Last_Name__c  = 'Stuart',
                                                Primary_Business_Contact_Title__c = 'Mr.',
                                                Primary_Business_Contact_E_mail_Address__c = 'alex@emc.com',
                                                Primary_Business_Contact_Phone_Number__c = '123456',
                                                President_CEO_First_Name__c = 'Alex',
                                                President_CEO_Last_Name__c  = 'Steward',
                                                President_CEO_E_mail_Address__c = 'alexst@emc.com',
                                                President_CEO_Phone_Number__c = '987654232',
                                                I_Accept__c = True
                                            );
        Insert pob_rec1;
        return pob_rec1;
     
    }
}