/*=====================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR         DESCRIPTION 
 |  ====          =========               ==         =========== 
 |  28/06/2011    Arif                         	This class is used to unit test  PRM_DEALREG_SLACalculation
 |  08/11/2011    Anand Sharma            		Fixed test class issue for Partner Field of opportinity record
 |  01/11/2011    Anil Sure              		Fixed MIXED_DML Exceptions and removed Deal REG SLA Quuery Fetch
 +=====================================================================================================*/

@isTest
private class PRM_DEALREG_SLACalculation_TC{
    
     private static testmethod void calculateSLA(){
   	 User insertUser = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];          
     System.runAs(insertUser)
          {
           PRM_VPP_JobDataHelper.createVPPCustomSettingData();
          }
        
     /*Creating account record*/
     Account account = new Account();
     account.name = 'UNITTESTAcc';
     account.Party_Number__c = '1234';
     insert account;        
     
     map<Id,DEALREG_Approvers_SLA__c> mapApproversSLAAndWorkHours = new map<Id,DEALREG_Approvers_SLA__c>();                                                                                                        
     if(mapApproversSLAAndWorkHours.size()== 0){
         DEALREG_Work_Hours__c dealRegWorkHours = new DEALREG_Work_Hours__c();
         dealRegWorkHours.Theater__c = 'Americas';
         dealRegWorkHours.Business_Hours_Starts_At__c = 8.00;
         dealRegWorkHours.Monday__c = true;
         dealRegWorkHours.Tuesday__c = true;
         dealRegWorkHours.Wednesday__c = true;
         dealRegWorkHours.Thursday__c = true;
         dealRegWorkHours.Friday__c = true;
         dealRegWorkHours.Daylight_Saving_Starting_Month__c = '03';
         dealRegWorkHours.Daylight_Saving_Starting_Day__c = 'Sun';
         dealRegWorkHours.Daylight_Saving_Starts_On__c = 'SECOND';
         dealRegWorkHours.Daylight_Saving_Hours_Adjustment__c = '+1.00';
         dealRegWorkHours.Business_Hours_in_1_Working_Day__c = 9.00;
         dealRegWorkHours.Business_Hrs_Ends_At__c = 17.00;
         dealRegWorkHours.Time_Zone__c = 'GMT-05.00';
         dealRegWorkHours.Daylight_Saving_Ending_Month__c = '11';
         dealRegWorkHours.Daylight_Saving_Ending_Day__c = 'Sun'; 
         dealRegWorkHours.Daylight_Saving_Ends_On__c = 'FIRST';
    
         insert dealRegWorkHours;
    
         /*Creating DEALREG_Approvers_SLA__c record*/
         DEALREG_Approvers_SLA__c dealregApproversSLA = new DEALREG_Approvers_SLA__c();
         dealregApproversSLA.Region__c = dealRegWorkHours.Id;
         dealregApproversSLA.Starts_On__c = 'Submitted By Field Rep';
         dealregApproversSLA.Field_To_Stamp_On_Lead__c = 'DealReg_PSC_SLA_Expire_On__c';
         dealregApproversSLA.SLA_Type__c = 'PSC';
         dealregApproversSLA.Business_Hours_For_All_Accounts__c = 18.00;
    
         insert dealregApproversSLA;
     }
     
       Account account1 = new Account();
        account1.name = 'testAccount123';
        account1.Partner_Type__c='ISV';  
    insert account1; 
    
        Opportunity Oppty = new Opportunity();
        Date closeDate = date.newinstance(2012, 11, 17);
        Date approvalDate = date.newinstance(2011, 11, 1);
        Date expirationDate = date.newinstance(2013, 11, 18);
      Oppty.Name = 'Test Oppty';
        Oppty.AccountId = account1.Id;
        Oppty.Sales_Channel__c = 'Direct';
        Oppty.Sales_Force__c = 'EMC';
        Oppty.StageName = 'Pipeline';
        Oppty.Closed_Reason__c = 'Loss';
        Oppty.Close_Comments__c = 'Lost';
        Oppty.CloseDate = closeDate;
        Oppty.Sell_Relationship__c = 'Direct';
        Oppty.Quote_Version__c='v13';
        Oppty.Quote_Type__c='New';        
        //Oppty.Primary_Outsourcer_System_Integrator__c=account1.Id;
      //Oppty.Primary_ISV_Infrastructure__c=account1.Id;
      Oppty.Approval_Date__c=approvalDate ;
        Oppty.Expiration_Date__c=expirationDate ;
      Oppty.bypass_validation__c = true;
        insert Oppty; 

        
     RecordType recordTypeDR = [select Id from RecordType where name = 'Deal Registration']; 
        
     /*Creating Lead record*/
     List<Lead> lstLeads = new List<Lead>();
     Lead leadRecord = new Lead();
         leadRecord.Related_Account__c = account.Id;
         leadRecord.Company = 'UNITTESTCompany';
         leadRecord.DealReg_Theater__c = 'Americas';
         leadRecord.Country = 'United States';
         leadRecord.lastname = 'UNITTESTLastName';
         leadRecord.State_Province_Local__c = 'UNITTESTState';
         leadRecord.Street_Local__c = 'UNITTESTStreet';
         leadRecord.City_Local__c = 'UNITTESTCity';
         leadRecord.Zip_Postal_Code_Local__c = '1234';
         leadRecord.Contact_First_Name_Local__c = 'UNITTESTFirstCon';
         leadRecord.Contact_Last_Name_Local__c = 'UNITTESTLastCon';
         leadRecord.Email = 'unittest@test.com';
         leadRecord.Phone = '1234';
         leadRecord.DealReg_Partner_Contact_First_Name__c = 'UNITTESTFirstPartner';
         leadRecord.DealReg_Partner_Contact_Last_Name__c = 'UNITTESTLastPartner';
         leadRecord.DealReg_Deal_Description__c = 'UNITTESTDescription';
         leadRecord.DealReg_Expected_Deal_Value__c = 1234;
         leadRecord.DealReg_Expected_Close_Date__c = system.today()+1;
         leadRecord.status = 'New';
         leadRecord.RecordTypeId = recordTypeDR.Id; 
         leadRecord.DealReg_Deal_Registration__c = true;
         leadRecord.Related_Opportunity__c = oppty.Id; 
         leadRecord.DealReg_Deal_Registration_Status__c = 'New';
         leadRecord.isConverted__c = false;
         leadRecord.S_Control_Converted__c = false; 
         leadRecord.DealReg_Pre_Sales_Engineer_Email__c='test@emc.com';
         leadRecord.DealReg_Pre_Sales_Engineer_Name__c='test engineer';
         leadRecord.DealReg_Pre_Sales_Engineer_Phone__c='12345';
         leadRecord.DealReg_EMCTA_Certified_Email__c='test3@emc.com';   
       lstLeads.add(leadRecord);
       insert lstLeads;
       Map<Id,Lead> mapOldLeads = new Map<Id,Lead>();
       Map<Id,Lead> mapNewLeads = new Map<Id,Lead>();
       mapOldLeads.put(leadRecord.Id,leadRecord);
      for(lead leadRecords: lstLeads){
        leadRecords.Approval_Status__c = 'Submitted By Field Rep';       
            mapNewLeads.put(leadRecords.Id,leadRecords); 
      }
      update lstLeads;


/*Creating Extension Request record*/
     List<Extension_Request__c> lstExtRequest = new List<Extension_Request__c>();
     Extension_Request__c extRequestRecord = new Extension_Request__c();
     extRequestRecord.Deal_Registration__c = leadRecord.Id;
     lstExtRequest.add(extRequestRecord);
     insert lstExtRequest;
     Map<Id,Extension_Request__c> mapOldExtRequest = new Map<Id,Extension_Request__c>();
     Map<Id,Extension_Request__c> mapNewExtRequest = new Map<Id,Extension_Request__c>();
     mapOldExtRequest.put(extRequestRecord.Id,extRequestRecord);
     for(Extension_Request__c extReqRecords: lstExtRequest){
        extReqRecords.Approval_Status__c = 'Submitted By Field Rep';       
        mapNewExtRequest.put(extRequestRecord.Id,extRequestRecord); 
      }
      update lstExtRequest;

      Test.startTest();
        PRM_DEALREG_SLACalculation obj = new PRM_DEALREG_SLACalculation();
        obj.slaCalculation(mapNewLeads,mapOldLeads);
        datetime dtTempValue = obj.getStartDateTime(system.now(),2.00);
        set<string> workingDays = new set<string>{'Mon','Tue','Wed','Thu','Fri'};
        dtTempValue = obj.getNextWorkingDate(system.now(),workingDays);
        dtTempValue = obj.getExpirationDateIfLessThanWorkingHour(4.00,9.00,system.now(),workingDays,8.00,17.00);
        obj.slaCalculationForExtensionRequest(mapNewExtRequest,mapOldExtRequest);
      Test.stopTest();  
    }
 }