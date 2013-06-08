/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  29/04/2011     Shalabh Sharma      This test class is used to test methods written for 
                                       PRM_PartnerOnboardingUpdates class.
|  11-JAN-2012      Anil                        Removed role Id    
|  07-Jan-2013      Vivek               Test class errors fix                                                           
 +==================================================================================================================**/
@isTest
private class PRM_PartnerOnBoardingUpdates_TC{
        private static testMethod void pobTest(){   
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];   
        Contact c = new Contact (lastname = 'Test Contact', firstname = 'Test Contact', start_date__c = System.today(),email='test12786@emc.com');
        insert c;  
               
        System.runAs(insertUser)
        {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
       
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
       
        /* Creation of Account record.*/  
        Account account = new Account();
            account.name = 'Testing Account234POB';
            account.Profiled_Account_Flag__c = true;
            insert account;
            account.IsPartner = true;
            update account;
            System.debug('account---->'+account);
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(account);
        
        Account_Groupings__c grouping = new Account_Groupings__c(
            Name = 'TestClass3',
            Active__c = true,
            Profiled_Account__c = account.id,
            No_Master_Required__c = false);
            insert grouping;
        List<Account> acc1 = AccountAndProfileTestClassDataHelper.CreatePartnerAccount();       
       insert acc1;
       Contact contact = UserProfileTestClassDataHelper.createContact();
       contact.AccountId=acc1[0].Id;
       insert contact;
       contact.email = 'test127867@emc.com';
       update contact;
       User user01;
       System.runAs(insertUser)
        {              
       Map<String,CustomSettingDataValueMap__c>  data =  CustomSettingDataValueMap__c.getall();
       String distributorSuperUser = data.get('EMEA Distributor Super User').DataValue__c ;
       Profile amerUserProf = [select Id from Profile where Name=: distributorSuperUser];
       //UserRole userRoles = [Select u.Id, u.Name from UserRole u where u.Name='AVNET TECHNOLOGY SOLUTIONS SANAYI VE TICARET A.S. Partner Executive'];
       user01 = UserProfileTestClassDataHelper.createPortalUser(amerUserProf.id,null,contact.Id);
       insert user01;
        }

        /* Creation of User record.       
        User user01 = [select Id,contactId,Email from User where usertype = 'PowerPartner'
                       and isActive=true limit 1];*/
        system.debug('created user'+user01);
        Contact con = [select Id,Email from Contact where Id =:user01.contactId];
        con.Email = 'test12456@emc.com';
        update con;
        user01.Email = con.Email;
        System.runAs(insertUser)
        {
         update user01;
        }
        
        /* Creation of Partner OnBoarding record.*/
        List<Partner_Onboarding__c> lstPOB = new List<Partner_Onboarding__c>();
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
                pobRecord.State__c='Andhra Pradesh';
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
                pobRecord.OwnerId=user01.id;
                lstPOB.add(pobRecord);  
                   
            insert lstPOB;   
                                
       
            /* if(lstPOB != null && lstPOB.size()>0){   
             System.debug('lstPOBlstPOB'+lstPOB);
             Authorized_Reseller_Onboarding_Task__c authTask = [select Id,Status__c,Account_Found_in_SFDC__c,Distributor_Approval_Status__c,EMC_Approval_Status__c from Authorized_Reseller_Onboarding_Task__c where Partner_Onboarding__c in :lstPOB limit 1];
             System.Debug('Value of task--->' +authTask);
              //if(authTask!=null){
             authTask.EMC_Approval_Status__c = 'Approved';
             List<Authorized_Reseller_Onboarding_Task__c> lstTask = new List<Authorized_Reseller_Onboarding_Task__c>();
             lstTask.add(authTask);
             update lstTask;   
                
           }
        // } */
         Test.startTest();
         PRM_PartnerOnBoardingUpdates objPOB = new PRM_PartnerOnBoardingUpdates();
         // if(lstPOB != null && lstPOB.size()>0){
             objPOB.step1updatePartnerOnBoardingOwner(lstPOB);        
             objPOB.step2createTaskforCM(lstPOB);
             objPOB.step6createTaskforExtSystems(lstPOB);
            
         //}
         PRM_PartnerOnBoardingUpdates.executeFlag = false;
         Partner_Onboarding__c pobRec = [select id,Distributor_Approver__c,Authorized_Reseller_Account__c,Account_Created_by_TRACK__c from Partner_Onboarding__c where Id in: lstPOB];
                pobRec.Distributor_Approver__c = user01.Id;
                pobRec.Distributor_Account__c = account.Id;
                pobRec.Authorized_Reseller_Account__c = account.Id;
                pobRec.Account_Created_by_TRACK__c = true;
                List<Partner_Onboarding__c> lstPOBrec = new List<Partner_Onboarding__c>(); 
                lstPOBrec.add(pobRec);
                update lstPOBrec;
                objPOB.step4sendmailtoCM(lstPOBrec);
                objPOB.step5sendmailtoTRACK(lstPOBrec);
                objPOB.step7createTaskforCMforProfileUpdationAndWelcomeEmails(lstPOBrec);
                
         Authorized_Reseller_Onboarding_Task__c authTask1 = [select Id,Partner_Onboarding__c,Status__c,Account_Found_in_SFDC__c,Partner_Account__c,Distributor_Approval_Status__c,EMC_Approval_Status__c,Distributor_Rejection_Reason__c from Authorized_Reseller_Onboarding_Task__c where Subject__c = 'Step 2a - Distributor Approval of Authorized Reseller' limit 1];      
                authTask1.Distributor_Approval_Status__c = 'Not Approved';
                authTask1.Distributor_Rejection_Reason__c = 'Not Approved';
                authTask1.Partner_Account__c = account.Id;
                List<Authorized_Reseller_Onboarding_Task__c> lstTask1 = new List<Authorized_Reseller_Onboarding_Task__c>();
                lstTask1.add(authTask1);
                update lstTask1; 
                system.debug('------>task after update'+lstTask1);
                objPOB.UpdateLocalLanguageFields(lstPOB);
                objPOB.updateRelatedProfiledAccount(lstTask1);
        
         Test.stopTest();
         }
       }   
        
 }