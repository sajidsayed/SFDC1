/** 
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * 
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*================================================================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 |  03 Dec 2012   Hemavathi N M         Account Presentation         This will used for unit testing of AP_Customer_Profile_Auditing      
 +===========================================================================================================================================================*/
 
@isTest(SeeAllData=true)
private class AP_Customer_Profile_Auditing_TC {
           
      public static List<Account> lstAccount = New List<Account>();
      public static List<District_Lookup__c> lstDistrictLookup = New List<District_Lookup__c>();
      public static List<Hub_Info__c> lstHubInfo = New List<Hub_Info__c>();
      public static Integer loopLimit= 3;
      
   // MEthod : To create customprofiledAccount record
      public void createCustomerProfiledAccount(){
        
       List<User> lstUser = [Select id from user where IsActive = true and IsPortalEnabled = false limit 4];
            
        for(Integer k=0;k<loopLimit;k++){
        Account accObj1 = new Account();
        accObj1.name = 'TestAccount'+ k;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        accObj1.District_Lookup__c = lstDistrictLookup[k].Id; 
        accObj1.Customer_Profiled_Account__c=true;
        accObj1.Core_Quota_Rep__c=lstUser[1].id;
        lstAccount.add(accObj1);
        }
        
        Database.insert(lstAccount);
        lstAccount = [Select Id,District_Lookup__c, Name,BillingCountry,Hub_Info__r.Golden_Site_Name__c, Hub_Info__c,Business_Unit_Ultimate__c,BillingCity ,Global_Ultimate__c,BUU_Golden_Site_Name__c,GU_Golden_Site_Name__c,MAP_Account_Name__c ,Core_Quota_Rep__c ,Customer_Profiled_Account__c,Account_District__c FROM Account Where id in: lstAccount];
        System.debug('lstAccount---->' + lstAccount);
      }//END METHOD - CreatecustomProfiledAccount
      
      // MEthod : To create districtlookup record
       public void createDistrictLookup(){
        for(Integer k=0;k<loopLimit;k++){
            District_Lookup__c objDistrictLookup = new District_Lookup__c();
            objDistrictLookup.Name ='TestLookup' + k;
            objDistrictLookup.Area__c='EDWARDS';
            lstDistrictLookup.add(objDistrictLookup);
        }
      Database.insert(lstDistrictLookup);
      lstDistrictLookup = [Select id ,Name from District_Lookup__c where id in: lstDistrictLookup ]; 
      System.debug('lstDistrictLookup------>' + lstDistrictLookup);
        }//END MEthod - createDistrictLookup
        
     //Method : To create Hub_Info
        public void createHubInfo(){
            
        Hub_Info__c objHubInfo = new Hub_Info__c();
        objHubInfo.Name = 'Test1';
        objHubInfo.Golden_Site_Identifier__c = 100;
        objHubInfo.Golden_Site_Name__c = 'TestGold1';
        objhubInfo.Global_Ultimate__c=true;
        objHubInfo.Global_Ultimate_Golden_Site_Identifier__c =100;
        lstHubInfo.add(objHubInfo);
        
        Hub_Info__c objHubInfo1 = new Hub_Info__c();
        objHubInfo1.Name = 'Test2';
        objHubInfo1.Business_Unit_Ultimate_Golden_Site_ID__c = 101;
        objHubInfo1.Golden_Site_Name__c = 'TestGold2';
        objhubInfo1.Business_Unit_Ultimate__c=true;
        objHubInfo1.Golden_Site_Identifier__c =101;
        lstHubInfo.add(objHubInfo1);
        
        
        Database.insert(lstHubInfo);
        lstHubInfo = [Select id ,Golden_Site_Identifier__c,Business_Unit_Ultimate_Golden_Site_ID__c,Business_Unit_Ultimate__c,Global_Ultimate_Golden_Site_Identifier__c,Golden_Site_Name__c from Hub_Info__c where id in: lstHubInfo limit 2]; 
        System.debug('lstHubInfo------>' + lstHubInfo);
        
        }//END Method - createHub
 private static testmethod void batchSchedulerTest() {

     Test.StartTest();
   // String sch = '0 0 0 4 9 ?' ;
    String sch1 = '0 0 0 4 9 ?' ;
       AP_Customer_Profile_Auditing_TC testObj = new AP_Customer_Profile_Auditing_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr){
        testObj.createHubInfo();
        testObj.createDistrictLookup();
        testObj.createCustomerProfiledAccount(); 
        }
      try{
          String accountQuery = 'Select ID, Name, Account_District__c, Customer_Profiled_Account__c, District_Lookup__c,Account_Profiling_Warning_Counts__c From Account WHERE type != \'Partner\' and isPartner = false and Account_District__c != null limit 50 ';
          AP_Customer_Profile_Auditing batchExecute = new AP_Customer_Profile_Auditing();
          batchExecute.isRunTest = true;
       //   Id batchProcessId = Database.executeBatch(new AP_Customer_Profile_Auditing(accountQuery)); 
       system.schedule('Test Audit Reporting', sch1, batchExecute);
     // System.debug('batchProcessId --->'+batchProcessId );
         } catch(Exception e) {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e.getMessage() );   
     }
    Test.StopTest();
   
  }
  
  
   
   
}