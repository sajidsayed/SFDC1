/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req     DESCRIPTION                               
 |  ====            =========       ======     =========== 
 |                                                        
 |  02-May-2011     Anirudh Singh   2515       This class is used to execute Unit Testing for Manual Creation of contacts
 |                                             from education records.
 |  01-Nov-2011    Anil Sure           		   Removed Queries and fixed MIXED_DML Exception 
 +=========================================================================================================================*/
 

@isTest

private class PRM_ContactCreationController_TC{   
    
    static testMethod void myUnitTest() {
       User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
                   
           System.runAs(insertUser)
              {
        PRM_VPP_JobDataHelper.createVPPCustomSettingData();
         } 
         
     //Create Account Record          
        Account accout1 = new Account ( Name ='Test-AccountGrouping',Site_Duns_Entity__c='001021455678',Grouping__C = Null, selected__c=false,Partner_Programs__c='Authorised Reseller' );       
        insert accout1 ;
        for(Account acc :[select Id,IsPartner,Lead_Oppty_Enabled__c 
                            from account 
                            where Id=:accout1.Id]){
            acc.ispartner=true;
            update acc;
       }
       
       //Create Contact Record
        Contact contact1 = new Contact (Firstname ='Test',Lastname ='Contact',Accountid=accout1.id,Cert_Tracker_Contact_ID__c='EMCTestCert1234567');
        insert contact1;
       
       //Create Account Grouping Record        
        Account_Groupings__c grouping = new Account_Groupings__c(
        Name = 'TestClass3',
        Active__c = true,
        Profiled_Account__c = accout1.id,
        No_Master_Required__c = false);
        insert grouping;
             
        Account_Groupings__c grouping01 = [Select id,id__c from Account_Groupings__c where id =:grouping.id ];
        
        //Create Education Master Records
        Education_Master__c objEduMaster = new Education_Master__c();
        objEduMaster.ESBI_ID__c ='123456';
        objEduMaster.ESBI_Name__c ='123456';
        insert objEduMaster;
        
        List<CustomSettingDataValueMap__c> lstDataValue = new List<CustomSettingDataValueMap__c>();
        CustomSettingDataValueMap__c dataValueControlFlag = new CustomSettingDataValueMap__c();
        dataValueControlFlag.Name ='EMCAdmin';
        dataValueControlFlag.DataValue__c ='00570000001IkMo';
        lstDataValue.add(dataValueControlFlag);     
        try
        {
           Database.insert(lstDataValue, false);
        }catch(Exception e){
           System.debug('Check Obj Access'+e); 
        }
         
        //Create Education Records
        Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
        Education__c educationObj = new Education__c();
        educationObj.OwnerId=DataValueMap.get('EducationQueueId').DataValue__c;
        educationObj.First_Name__c = 'TestEducation';
        educationObj.Last_Name__c = 'Record';
        educationObj.Partner_Grouping__c=grouping.Id;
        educationObj.Cert_ID__c='EMCTestCert123456';
        educationObj.Email__c='EducatinTestContct@test.com';
        educationObj.Education_Master__c=objEduMaster.Id;
        insert educationObj;
        System.Debug('Value of Test Education Record' +educationObj);
        
        Education__c educationObj2 = new Education__c();
        educationObj2.First_Name__c = 'TestEducation';
        educationObj2.Last_Name__c = 'Record';
        educationObj2.Partner_Grouping__c=grouping.Id;
        educationObj2.Cert_ID__c='EMCTestCert123456';
        educationObj2.Email__c='EducatinTestContct@test.com';
        educationObj2.Education_Master__c=objEduMaster.Id;
        insert educationObj2;
        System.Debug('Value of Test Education Record' +educationObj2);
        
        Education__c educationObj3 = new Education__c();
        educationObj3.OwnerId=DataValueMap.get('EducationQueueId').DataValue__c;
        educationObj3.First_Name__c = 'TestEducation';
        educationObj3.Last_Name__c = 'Record';
        educationObj3.Partner_Grouping__c= Null;
        educationObj3.Cert_ID__c='EMCTestCert123456';
        educationObj3.Email__c='EducatinTestContct@test.com';
        educationObj3.Education_Master__c=objEduMaster.Id;
        insert educationObj3;
        System.Debug('Value of Test Education Record' +educationObj3);
        
        Education__c educationObj4 = new Education__c();
        educationObj4.OwnerId=DataValueMap.get('EducationQueueId').DataValue__c;
        educationObj4.First_Name__c = 'TestEducation';
        educationObj4.Last_Name__c = 'Record';
        educationObj4.Partner_Grouping__c= grouping.Id;
        educationObj4.Cert_ID__c='EMCTestCert1234567';
        educationObj4.Email__c='EducatinTestContct@test.com';
        educationObj4.Education_Master__c=objEduMaster.Id;
        insert educationObj4;
        System.Debug('Value of Test Education Record' +educationObj4);
        
        Test.StartTest();
          ApexPages.StandardController controller01 = new ApexPages.StandardController(educationObj); 
          ApexPages.currentPage().getParameters().put('id',educationObj.id);
          PRM_ContactCreationController ManualContCreation = New PRM_ContactCreationController(controller01);
          ManualContCreation.processEducation();
         
          ApexPages.StandardController controller02 = new ApexPages.StandardController(educationObj2); 
          ApexPages.currentPage().getParameters().put('id',educationObj2.id);
          PRM_ContactCreationController ManualContCreation1 = New PRM_ContactCreationController(controller02);
          ManualContCreation1.processEducation();
          
          ApexPages.StandardController controller03 = new ApexPages.StandardController(educationObj3); 
          ApexPages.currentPage().getParameters().put('id',educationObj3.id);
          PRM_ContactCreationController ManualContCreation2 = New PRM_ContactCreationController(controller03);
          ManualContCreation2.processEducation();
          
          ApexPages.StandardController controller04 = new ApexPages.StandardController(educationObj4); 
          ApexPages.currentPage().getParameters().put('id',educationObj4.id);
          PRM_ContactCreationController ManualContCreation3 = New PRM_ContactCreationController(controller04);
          ManualContCreation3.processEducation();
        Test.StopTest();
        
        }
        

        

}