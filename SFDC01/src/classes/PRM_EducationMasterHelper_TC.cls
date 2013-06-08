/*=======================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  03/01/2011    Anand Sharma                      Unit Test for PRM_EducationMasterHelper class
 |  14/12/2011      Anil                            Created Account Records Manually 
 +=======================================================================================================*/
@isTest
private class PRM_EducationMasterHelper_TC {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //Account objAccount = [Select Id, Name, Grouping__c From Account where Grouping__c != null limit 1];
        Account objAccount = new Account(
            name='testDataAccount',
            CurrencyIsoCode='USD',
            Site_DUNS_Entity__c = '123456',
            Global_DUNS_Entity__c = '663399'
        );        
        insert objAccount;
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
        insert objEduMaster;
        
        //Create Staging Data Records
        List<Staging_Data__c> stagingDataList = new List<Staging_Data__c>();
        Staging_Data__c objStagedata = new Staging_Data__c();
        objStagedata.Text1__c = 'A100003';
        objStagedata.Text2__c ='A1111111';
        objStagedata.Text3__c ='anand.sharma5@emc.com';
        objStagedata.Text4__c ='a0F70000004CljX';
        objStagedata.Text5__c ='123456';
        objStagedata.Date1__c = System.today();
        objStagedata.Date2__c = System.today();
        stagingDataList.add(objStagedata);
        
        Staging_Data__c objStagedata1 = new Staging_Data__c();
        objStagedata1.Text1__c = 'A100004';
        objStagedata1.Text2__c ='A1111112';
        objStagedata1.Text3__c ='anand.sharma8@emc.com';
        objStagedata1.Text4__c =objAccount.Grouping__c;
        objStagedata1.Text5__c ='123456';
        objStagedata1.Date1__c = System.today();
        objStagedata1.Date2__c = System.today();
        stagingDataList.add(objStagedata1);
        insert stagingDataList;
        
        //Call createEducationAndpopulateContact method of  PRM_EducationHelper class for unit test
        PRM_EducationMasterHelper.removeDuplicateStagingForEducationMaster(stagingDataList );        
        
    }

    static testMethod void myUnitTestModifyMasterInfo() {
        //Create Education Master Records
        List<Education_Master__c> lstEduMaster = new List<Education_Master__c>();
        Education_Master__c objEduMaster = new Education_Master__c();
        objEduMaster.ESBI_ID__c ='123456';
        objEduMaster.ESBI_Category__c ='SAL';
        objEduMaster.ESBI_Level__c ='x';
        objEduMaster.ESBI_Type__c = 'New';
        objEduMaster.ESBI_Version__c ='New';
        lstEduMaster.add(objEduMaster);
        
        insert lstEduMaster;
        PRM_EducationMasterHelper.populateModifiedInfo(lstEduMaster);
        
       
        
    }
  
}