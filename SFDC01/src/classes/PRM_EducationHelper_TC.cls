/*=======================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  16/12/2010    Anand Sharma                      Unit Test for PRM_EducationHelper class 
 |  28/03/2011    Anand Sharma                      Created custom setting value through test class
 |  14/12/2011		Anil							Used Custom setting Data Helper 
 +=======================================================================================================*/
@isTest
private class PRM_EducationHelper_TC {

    static testMethod void myUnitTest() {
        
        // TO DO: implement unit test
        // Creation of Account Grouping record.
        Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
        insert grouping;
        User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];            
        System.runAs(insertUser)
        {
    	PRM_VPP_JobDataHelper.createVPPCustomSettingData();   
        }
        // Creation of Account record.  
        Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
        insert objAccount;
        /**/
        //Account objAccount = [Select Id, Name, Grouping__c From Account where Grouping__c != null limit 1];
        
        //Create Contact Records
        List<Contact> contactList = new List<Contact>();
        Contact objContact = new Contact();
        objContact.LastName ='TestEducationContact1';
        objContact.Email ='anand.sharma5@emc.com';
        objContact.AccountId = objAccount.Id;
        objContact.Active__c = true;
        objContact.Cert_Tracker_Contact_ID__c ='A100003';
        contactList.add(objContact);
        
        Contact objContact1 = new Contact();
        objContact1.LastName ='TestEducationContact1';
        objContact1.Email ='anand.sharma8@emc.com';
        objContact1.AccountId = objAccount.Id;
        objContact1.Active__c = true;
        objContact1.Cert_Tracker_Contact_ID__c ='A100004';
        contactList.add(objContact1);
        insert contactList;
        
        //Create Education Master Records
        Education_Master__c objEduMaster = new Education_Master__c();
        objEduMaster.ESBI_ID__c ='123456';
        objEduMaster.ESBI_Name__c ='123456';
        insert objEduMaster;
        
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003';
        objStagedata.Text2__c ='A1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='123456';
        objStagedata.Text8__c ='123456';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004';
        objStagedata1.Text2__c ='A1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c =objAccount.Grouping__c;
        objStagedata1.Text5__c ='123456';
        objStagedata1.Text8__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
        CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        dataValueControlFlag.Name ='EducationTypeTraining';
        dataValueControlFlag.DataValue__c ='Training';
        lstDataValue.add(dataValueControlFlag);
        
        CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
        dataValueControlFlag1.Name ='EducationTypeCertAccred';
        dataValueControlFlag1.DataValue__c ='Cert/Accred';
        lstDataValue.add(dataValueControlFlag1);        
        try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
        //Call createEducationAndpopulateContact method of  PRM_EducationHelper class for unit test
        PRM_EducationHelper.createEducationAndpopulateContact(stagingDataList );        
        
        List<Education__c> lstEdu = [Select Id from Education__c where lastModifieddate =: System.today()];
        //Call deleteEducation method of  PRM_EducationHelper class for unit test
        PRM_EducationHelper.deleteEducation(lstEdu );        
        
    }
    
    static testMethod void unitTestContactIDOnContact() {
        
        // Creation of Account Grouping record.
        Account_Groupings__c grouping = new Account_Groupings__c (Name = 'UNITTESTGrp');
        Insert grouping;
          
        // Creation of Account record.  
        Account objAccount =  new Account (Name = 'UNITTESTAcc', Country_Local__c = 'Japan',cluster__C = 'APJ', Grouping__c = grouping.Id, Batch_Job_Operation__c = 'Clustor/Theather Updated', profiled_Account_flag__c=true);
        Insert objAccount;  
        /**/ 
        //Test.startTest();     
        //Account objAccount = [Select Id, Name, Grouping__c From Account where Grouping__c != null limit 1];
                       
        Contact objContact1 = new Contact();
        objContact1.LastName ='TestEducationContact1';
        objContact1.Email ='anand.sharma9@emc.com';
        objContact1.AccountId = objAccount.Id;
        objContact1.Active__c = true;
        insert objContact1;
        
        List<Education__c> lstEdu = new List<Education__c>();
        
        Education__c objEdu = new Education__c();
        objEdu.Cert_ID__c ='1111111A123'; 
        objEdu.Contact__c = objContact1.Id;     
        lstEdu.add(objEdu);        
        
        insert lstEdu;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
        CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        dataValueControlFlag.Name ='EducationTypeTraining';
        dataValueControlFlag.DataValue__c ='Training';
        lstDataValue.add(dataValueControlFlag);
        
        CustomSettingDataValueMap__c dataValueControlFlag1 = new CustomSettingDataValueMap__c();
        dataValueControlFlag1.Name ='EducationTypeCertAccred';
        dataValueControlFlag1.DataValue__c ='Cert/Accred';
        lstDataValue.add(dataValueControlFlag1);        
        try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
        
        //Call populateCertTrackerContactIDOnContact of PRM_EducationHelper class for unit test
        PRM_EducationHelper.populateCertTrackerContactIDOnContact(lstEdu);
        
       // Test.StopTest();
    }
}