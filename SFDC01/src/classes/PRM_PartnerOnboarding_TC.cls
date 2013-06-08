@isTest
private class PRM_PartnerOnboarding_TC{
        /*private static testMethod void pobTest(){   
       
       //Creation of Custom Setting.
       List<Custom_Settings_Partner_OnBoarding__c> lstDataValue = new List<Custom_Settings_Partner_OnBoarding__c>();
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag.Name ='STEP1.0Americas';
        dataValueControlFlag.Description__c ='Step to decide the owner of POB record.';
        dataValueControlFlag.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag);

        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag1 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag1.Name ='STEP1.0APJ';
        dataValueControlFlag1.Description__c ='Step to decide the owner of POB';
        dataValueControlFlag1.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag1);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag2 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag2.Name ='STEP1.0EMEA';
        dataValueControlFlag2.Description__c ='Step to decide the owner of POB';
        dataValueControlFlag2.Owner__c='00G70000001lIsO';
        lstDataValue.add(dataValueControlFlag2);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag3 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag3.Name ='STEP2.0Americas';
        dataValueControlFlag3.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag3.Owner__c='00G70000001lIsO';
        dataValueControlFlag3.Send_Email__c=True;
        dataValueControlFlag3.Template__c='00X70000001Rv6c';
        dataValueControlFlag3.Create_Task__c=True;
        dataValueControlFlag3.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag3.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag3);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag4 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag4.Name ='STEP2.0APJ';
        dataValueControlFlag4.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag4.Owner__c='00G70000001lIsO';
        dataValueControlFlag4.Send_Email__c=True;
        dataValueControlFlag4.Template__c='00X70000001Rv6c';
        dataValueControlFlag4.Create_Task__c=True;
        dataValueControlFlag4.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag4.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag4);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag5 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag5.Name ='STEP2.0EMEA';
        dataValueControlFlag5.Description__c ='Send a mail to CM and create a task for CM to accept/reject new Distributor VAR';
        dataValueControlFlag5.Owner__c='00G70000001lIsO';
        dataValueControlFlag5.Send_Email__c=True;
        dataValueControlFlag5.Template__c='00X70000001Rv6c';
        dataValueControlFlag5.Create_Task__c=True;
        dataValueControlFlag5.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag5.Task_Name__c='Step 1 - EMC Application Translation/Approval';
        lstDataValue.add(dataValueControlFlag5);        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag6 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag6.Name ='STEP3.0';
        dataValueControlFlag6.Description__c ='Send a mail to Distributor and create a task for Distributor to accept/reject new Distributor VAR';      
        dataValueControlFlag6.Send_Email__c=True;
        dataValueControlFlag6.Template__c='00X70000001Rv6c';
        dataValueControlFlag6.Create_Task__c=True;
        dataValueControlFlag6.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag6.Task_Name__c='Step 2a - Distributor Approval of Authorized Reseller';
        lstDataValue.add(dataValueControlFlag6);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag35 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag35.Name ='STEP3.1Americas';
        dataValueControlFlag35.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';     
        dataValueControlFlag35.Owner__c='00G70000001lIsO';
        dataValueControlFlag35.Send_Email__c=True;
        dataValueControlFlag35.Template__c='00X70000001Rv6c';
        dataValueControlFlag35.Create_Task__c=True;
        dataValueControlFlag35.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag35.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag35);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag7 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag7.Name ='STEP3.1APJ';
        dataValueControlFlag7.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';      
        dataValueControlFlag7.Owner__c='00G70000001lIsO';
        dataValueControlFlag7.Send_Email__c=True;
        dataValueControlFlag7.Template__c='00X70000001Rv6c';
        dataValueControlFlag7.Create_Task__c=True;
        dataValueControlFlag7.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag7.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag7);    
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag8 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag8.Name ='STEP3.1EMEA';
        dataValueControlFlag8.Description__c ='Send a mail to CM and create a task for CM to identify accout for new Distributor VAR';      
        dataValueControlFlag8.Owner__c='00G70000001lIsO';
        dataValueControlFlag8.Send_Email__c=True;
        dataValueControlFlag8.Template__c='00X70000001Rv6c';
        dataValueControlFlag8.Create_Task__c=True;
        dataValueControlFlag8.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag8.Task_Name__c='Step 2b - Contract Manager Account Identification';
        lstDataValue.add(dataValueControlFlag8);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag9 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag9.Name ='STEP4.0Americas';
        dataValueControlFlag9.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';     
        dataValueControlFlag9.Owner__c='00G70000001lIsO';
        dataValueControlFlag9.Send_Email__c=True;
        dataValueControlFlag9.Template__c='00X70000001Rv6c';        
        lstDataValue.add(dataValueControlFlag9);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag33 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag33.Name ='STEP4.0APJ';
        dataValueControlFlag33.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';        
        dataValueControlFlag33.Owner__c='00G70000001lIsO';
        dataValueControlFlag33.Send_Email__c=True;
        dataValueControlFlag33.Template__c='00X70000001Rv6c';       
        lstDataValue.add(dataValueControlFlag33);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag10 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag10.Name ='STEP4.0EMEA';
        dataValueControlFlag10.Description__c ='Send a mail to Contract Manager if Distributor rejects the Distributor VAR';        
        dataValueControlFlag10.Owner__c='00G70000001lIsO';
        dataValueControlFlag10.Send_Email__c=True;
        dataValueControlFlag10.Template__c='00X70000001Rv6c';       
        lstDataValue.add(dataValueControlFlag10);
        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag11 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag11.Name ='STEP5.0Americas';
        dataValueControlFlag11.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag11.Owner__c='00G70000001lIsO';
        dataValueControlFlag11.Send_Email__c=True;
        dataValueControlFlag11.Template__c='00X70000001Rv6c';
        dataValueControlFlag11.Email__c ='sharma_shalabh2@emc.com';
        lstDataValue.add(dataValueControlFlag11);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag12 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag12.Name ='STEP5.0APJ';
        dataValueControlFlag12.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag12.Owner__c='00G70000001lIsO';
        dataValueControlFlag12.Send_Email__c=True;
        dataValueControlFlag12.Template__c='00X70000001Rv6c';
        dataValueControlFlag12.Email__c ='sobhanan.bindu@accenture.com';
        lstDataValue.add(dataValueControlFlag12);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag13 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag13.Name ='STEP5.0EMEA';
        dataValueControlFlag13.Description__c ='Send a mail to TRACK if CM doesnt found the account.';      
        dataValueControlFlag13.Owner__c='00G70000001lIsO';
        dataValueControlFlag13.Send_Email__c=True;
        dataValueControlFlag13.Template__c='00X70000001Rv6c';
        dataValueControlFlag13.Email__c ='sobhanan.bindu@accenture.com';
        lstDataValue.add(dataValueControlFlag13);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag14 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag14.Name ='STEP6.0Americas';
        dataValueControlFlag14.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag14.Owner__c='00G70000001lIsO';
        dataValueControlFlag14.Send_Email__c=True;
        dataValueControlFlag14.Template__c='00X70000001Rv6c';
        dataValueControlFlag14.Create_Task__c=True;
        dataValueControlFlag14.Email__c ='sharma_shalabh2@emc.com';
        dataValueControlFlag14.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag14.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag14);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag15 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag15.Name ='STEP6.0APJ';
        dataValueControlFlag15.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag15.Owner__c='00G70000001lIsO';
        dataValueControlFlag15.Send_Email__c=True;
        dataValueControlFlag15.Template__c='00X70000001Rv6c';
        dataValueControlFlag15.Create_Task__c=True;
        dataValueControlFlag15.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag15.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag15.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag15);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag16 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag16.Name ='STEP6.0EMEA';
        dataValueControlFlag16.Description__c ='Send a mail to CXP admin for account setup';        
        dataValueControlFlag16.Owner__c='00G70000001lIsO';
        dataValueControlFlag16.Send_Email__c=True;
        dataValueControlFlag16.Template__c='00X70000001Rv6c';
        dataValueControlFlag16.Create_Task__c=True;
        dataValueControlFlag16.Email__c ='sobhanan.bindu@accenture.com';
        dataValueControlFlag16.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag16.Task_Name__c='Step 3b - CXP Setup';
        lstDataValue.add(dataValueControlFlag16);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag17 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag17.Name ='STEP6.1Americas';
        dataValueControlFlag17.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag17.Owner__c='00G70000001lIsO';
        dataValueControlFlag17.Send_Email__c=True;
        dataValueControlFlag17.Template__c='00X70000001Rv6c';
        dataValueControlFlag17.Create_Task__c=True;
        dataValueControlFlag17.Email__c ='sharma_shalabh2@emc.com';
        dataValueControlFlag17.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag17.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag17);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag18 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag18.Name ='STEP6.1APJ';
        dataValueControlFlag18.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag18.Owner__c='00G70000001lIsO';
        dataValueControlFlag18.Send_Email__c=True;
        dataValueControlFlag18.Template__c='00X70000001Rv6c';
        dataValueControlFlag18.Create_Task__c=True;
        dataValueControlFlag18.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag18.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag18.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag18);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag19 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag19.Name ='STEP6.1EMEA';
        dataValueControlFlag19.Description__c ='Send a mail to Powerlink admin for account setup';      
        dataValueControlFlag19.Owner__c='00G70000001lIsO';
        dataValueControlFlag19.Send_Email__c=True;
        dataValueControlFlag19.Template__c='00X70000001Rv6c';
        dataValueControlFlag19.Create_Task__c=True;
        dataValueControlFlag19.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag19.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag19.Task_Name__c='Step 3a - Powerlink Setup';
        lstDataValue.add(dataValueControlFlag19);       
    
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag20 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag20.Name ='STEP6.2Americas';
        dataValueControlFlag20.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag20.Owner__c='00G70000001lIsO';
        dataValueControlFlag20.Send_Email__c=True;
        dataValueControlFlag20.Template__c='00X70000001Rv6c';
        dataValueControlFlag20.Create_Task__c=True;
        dataValueControlFlag20.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag20.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag20.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag20);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag21 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag21.Name ='STEP6.2APJ';
        dataValueControlFlag21.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag21.Owner__c='00G70000001lIsO';
        dataValueControlFlag21.Send_Email__c=True;
        dataValueControlFlag21.Template__c='00X70000001Rv6c';
        dataValueControlFlag21.Create_Task__c=True;
        dataValueControlFlag21.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag21.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag21.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag21);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag22 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag22.Name ='STEP6.2EMEA';
        dataValueControlFlag22.Description__c ='Send a mail to Synergy admin for account setup';        
        dataValueControlFlag22.Owner__c='00G70000001lIsO';
        dataValueControlFlag22.Send_Email__c=True;
        dataValueControlFlag22.Template__c='00X70000001Rv6c';
        dataValueControlFlag22.Create_Task__c=True;
        dataValueControlFlag22.Email__c ='shreya.ravivarmaraj@accenture.com';
        dataValueControlFlag22.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag22.Task_Name__c='Step 3c - Synergy Setup';
        lstDataValue.add(dataValueControlFlag22);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag23 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag23.Name ='STEP6.3Americas';
        dataValueControlFlag23.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag23.Owner__c='00G70000001lIsO';
        dataValueControlFlag23.Send_Email__c=True;
        dataValueControlFlag23.Template__c='00X70000001Rv6c';
        dataValueControlFlag23.Create_Task__c=True;     
        dataValueControlFlag23.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag23.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag23);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag24 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag24.Name ='STEP6.3APJ';
        dataValueControlFlag24.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag24.Owner__c='00G70000001lIsO';
        dataValueControlFlag24.Send_Email__c=True;
        dataValueControlFlag24.Template__c='00X70000001Rv6c';
        dataValueControlFlag24.Create_Task__c=True;     
        dataValueControlFlag24.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag24.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag24);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag25 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag25.Name ='STEP6.3EMEA';
        dataValueControlFlag25.Description__c ='Send a mail to Grouping admin for grouping creation';       
        dataValueControlFlag25.Owner__c='00G70000001lIsO';
        dataValueControlFlag25.Send_Email__c=True;
        dataValueControlFlag25.Template__c='00X70000001Rv6c';
        dataValueControlFlag25.Create_Task__c=True;     
        dataValueControlFlag25.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag25.Task_Name__c='Step 3d - Grouping Setup';
        lstDataValue.add(dataValueControlFlag25);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag26 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag26.Name ='STEP7.0Americas';
        dataValueControlFlag26.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag26.Owner__c='00G70000001lIsO';
        dataValueControlFlag26.Send_Email__c=True;
        dataValueControlFlag26.Template__c='00X70000001Rv6c';
        dataValueControlFlag26.Create_Task__c=True;     
        dataValueControlFlag26.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag26.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag26);       
        
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag28 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag28.Name ='STEP7.0APJ';
        dataValueControlFlag28.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag28.Owner__c='00G70000001lIsO';
        dataValueControlFlag28.Send_Email__c=True;
        dataValueControlFlag28.Template__c='00X70000001Rv6c';
        dataValueControlFlag28.Create_Task__c=True;     
        dataValueControlFlag28.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag28.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag28);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag29 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag29.Name ='STEP7.0EMEA';
        dataValueControlFlag29.Description__c ='Create a task and send a mail for CM for profile updation and creation of association';     
        dataValueControlFlag29.Owner__c='00G70000001lIsO';
        dataValueControlFlag29.Send_Email__c=True;
        dataValueControlFlag29.Template__c='00X70000001Rv6c';
        dataValueControlFlag29.Create_Task__c=True;     
        dataValueControlFlag29.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag29.Task_Name__c='Step 4 - Update Profile and Create Associations';
        lstDataValue.add(dataValueControlFlag29);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag30 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag30.Name ='STEP7.1Americas';
        dataValueControlFlag30.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag30.Owner__c='00G70000001lIsO';      
        dataValueControlFlag30.Create_Task__c=True;     
        dataValueControlFlag30.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag30.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag30);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag31 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag31.Name ='STEP7.1APJ';
        dataValueControlFlag31.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag31.Owner__c='00G70000001lIsO';      
        dataValueControlFlag31.Create_Task__c=True;     
        dataValueControlFlag31.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag31.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag31);
        
        Custom_Settings_Partner_OnBoarding__c dataValueControlFlag32 = new Custom_Settings_Partner_OnBoarding__c();
        dataValueControlFlag32.Name ='STEP7.1EMEA';
        dataValueControlFlag32.Description__c ='Create a task for CM for sending welcome emails.';      
        dataValueControlFlag32.Owner__c='00G70000001lIsO';      
        dataValueControlFlag32.Create_Task__c=True;     
        dataValueControlFlag32.Record_Type__c='01270000000Q6ux';
        dataValueControlFlag32.Task_Name__c='Step 5 - Status of Welcome Emails/Legal Agreement';
        lstDataValue.add(dataValueControlFlag32);
try
{
 Database.insert(lstDataValue, false);
}catch(Exception e){
 System.debug('Check Obj Access'+e);
}
       
        // Creation of Account record. 
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
            
         //Creation of Contact record.  
        Contact contact = new Contact();
            contact.AccountId = account.id;
            contact.Active__c = true;
            contact.LastName = 'test';
            contact.FirstName = 'test';
            contact.email = 'test12456@emc.com';
            insert contact;
            System.debug('contact----->'+contact);

        // Creation of User record.       
        User user01 = [select Id,contactId,Email from User where usertype = 'PowerPartner'
                       and isActive=true limit 1];
        system.debug('created user'+user01);
        Contact con = [select Id,Email from Contact where Id =:user01.contactId];
        con.Email = 'test12456@emc.com';
        update con;
        user01.Email = con.Email;
        update user01;  
        
        // Creation of Partner OnBoarding record.
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
                
                lstPOB.add(pobRecord);  
                insert lstPOB;
       
             Authorized_Reseller_Onboarding_Task__c authTask = [select Id,Status__c,Account_Found_in_SFDC__c,Distributor_Approval_Status__c,EMC_Approval_Status__c from Authorized_Reseller_Onboarding_Task__c where Partner_Onboarding__c in :lstPOB];
             System.Debug('Value of task--->' +authTask);
             if(authTask!=null){
             authTask.EMC_Approval_Status__c = 'Approved';
             List<Authorized_Reseller_Onboarding_Task__c> lstTask = new List<Authorized_Reseller_Onboarding_Task__c>();
             lstTask.add(authTask);
             update lstTask;      
             }
         Test.startTest();
         PRM_PartnerOnBoardingUpdates objPOB = new PRM_PartnerOnBoardingUpdates();
         objPOB.step1updatePartnerOnBoardingOwner(lstPOB);        
         objPOB.step2createTaskforCM(lstPOB);
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
       } */  
 }