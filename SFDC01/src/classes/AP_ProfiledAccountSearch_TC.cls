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
 |  28 Nov 2012   Hemavathi N M         Account Presentation        This Test Class is used to test search cretiria for all customer profiled account       
 +===========================================================================================================================================================*/
 
@isTest(SeeAllData=true)
private class AP_ProfiledAccountSearch_TC {
    
      public static List<Account> lstAccount = New List<Account>();
      public static List<District_Lookup__c> lstDistrictLookup = New List<District_Lookup__c>();
      public static List<Hub_Info__c> lstHubInfo = New List<Hub_Info__c>();
      
      
      // MEthod : To create customprofiledAccount record
      public void createCustomerProfiledAccount(){
        Map<String,Schema.RecordTypeInfo> recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    //    Id accRecordTypeId = recordTypes.get('Standard Account Record Type').getRecordTypeId(); 
        List<User> lstUser = [Select id from user where IsActive = true and IsPortalEnabled = false limit 4];
            
        for(Integer k=0;k<51;k++){
        Account accObj1 = new Account();
        accObj1.name = 'Test A'+k;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        accObj1.District_Lookup__c = lstDistrictLookup[1].Id; 
        accObj1.Customer_Profiled_Account__c=true;
        
        if(math.mod(k,2)==0){
        accObj1.Global_Ultimate__c =true;   
        accObj1.Hub_Info__c =lstHubInfo[0].Id;
        }
        else{
         accObj1.Business_Unit_Ultimate__c =true;   
        accObj1.Hub_Info__c =lstHubInfo[1].Id;
        }
        accObj1.Core_Quota_Rep__c=lstUser[1].id;
        lstAccount.add(accObj1);
        }
        Account accObj2 = new Account();
        accObj2.name = 'Test Account';
        accObj2.BillingCountry ='United States';
        accObj2.BillingCity = 'EDWARDS AFB'; 
        accObj2.District_Lookup__c = lstDistrictLookup[2].Id; 
        accObj2.Customer_Profiled_Account__c=true;
        
         accObj2.Business_Unit_Ultimate__c =true;   
        accObj2.Hub_Info__c =lstHubInfo[1].Id;
        
        accObj2.Core_Quota_Rep__c=lstUser[1].id;
        lstAccount.add(accObj2);
        
        Database.insert(lstAccount);
        lstAccount = [Select Id, Name,BillingCountry,Hub_Info__r.Golden_Site_Name__c, Hub_Info__c,Business_Unit_Ultimate__c,BillingCity ,Global_Ultimate__c,BUU_Golden_Site_Name__c,GU_Golden_Site_Name__c,MAP_Account_Name__c ,Core_Quota_Rep__c ,Customer_Profiled_Account__c,Account_District__c FROM Account Where id in: lstAccount];
        System.debug('lstAccount---->' + lstAccount);
      
      }//END METHOD - CreatecustomProfiledAccount
      
      // MEthod : To create districtlookup record
       public void createDistrictLookup(){
            District_Lookup__c objDistrictLookup = new District_Lookup__c();
            objDistrictLookup.Name ='TestLookup 1';
            objDistrictLookup.Area__c='EDWARDS';
            lstDistrictLookup.add(objDistrictLookup);
            District_Lookup__c objDistrictLookup1 = new District_Lookup__c();
            objDistrictLookup1.Name ='TestLookup1';
            objDistrictLookup1.Area__c='EDWARDS';
            lstDistrictLookup.add(objDistrictLookup1);
            District_Lookup__c objDistrictLookup2 = new District_Lookup__c();
            objDistrictLookup2.Name ='TestLookup2';
            objDistrictLookup2.Area__c='EDWARDS';
            lstDistrictLookup.add(objDistrictLookup2);
            District_Lookup__c objDistrictLookup3 = new District_Lookup__c();
            objDistrictLookup3.Name ='TestLookup3';
            objDistrictLookup3.Area__c='EDWARDS';
            lstDistrictLookup.add(objDistrictLookup3);
            Database.insert(lstDistrictLookup);
            lstDistrictLookup = [Select id from District_Lookup__c where id in: lstDistrictLookup limit 4]; 
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
        
        }
        
    //Method : To test the account search page
    static testMethod void accountTest() {
        // TO DO: implement unit test
        Integer strLeng;
        Account objAccount = new Account();
           
        //Call methods 
        AP_ProfiledAccountSearch_TC testObject = new AP_ProfiledAccountSearch_TC();
          testObject.createHubInfo();
          testObject.createDistrictLookup();
          testObject.createCustomerProfiledAccount();
           
        //To Test Global Search by sidebar
        PageReference pageRef = Page.AP_ProfiledAccountSearchResult;
        Test.setCurrentPage(pageRef);  
        for(Integer i = 0 ; i<5;i++){
        if(i==0){
        ApexPages.currentpage().getParameters().put('Name','Test A'); 
        ApexPages.StandardController ctlr = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl = new AP_ProfiledAccountSearch(ctlr);
        }
        
        if(i==1){
        ApexPages.currentpage().getParameters().put('Name','r  '); 
        ApexPages.StandardController ctlr1 = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl1 = new AP_ProfiledAccountSearch(ctlr1);
        }
        if(i==2){
        ApexPages.currentpage().getParameters().put('Name','123132312'); 
        ApexPages.StandardController ctlr2 = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl2 = new AP_ProfiledAccountSearch(ctlr2);
        }
        if(i==3){
        ApexPages.currentpage().getParameters().put('Name','Test Acc'); 
        ApexPages.StandardController ctlr3 = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl3 = new AP_ProfiledAccountSearch(ctlr3);
        }
        if(i==4){
        ApexPages.currentpage().getParameters().put('Name','r'); 
        ApexPages.StandardController ctlr4 = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl4 = new AP_ProfiledAccountSearch(ctlr4);
        }
        }
        
        Test.StartTest(); 
        //To Search from search result page       
        ApexPages.StandardController ctlr = new ApexPages.standardController(objAccount);
        AP_ProfiledAccountSearch accountCtrl = new AP_ProfiledAccountSearch(ctlr);  
       
        accountCtrl.clearresults();
        String inputValue = lstAccount[0].Map_Account_Name__c;
       //  String inputValue = 'test';
        strLeng = inputValue.length();
        // passValue = inputValue.subString(0,3);
        
        System.debug('inputValue---->' + inputValue + '<--->'+ strLeng);
        for(Integer i = 0 ; i<7;i++){
        if(i==0){
        accountCtrl.inputAccountName = inputValue.subString(0,3);
        accountCtrl.accountDropDown = 'StartsWith';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
        if(i==1){
       
        accountCtrl.inputAccountName = inputValue.subString(strLeng-4 , strLeng);
        //System.debug('inputAccountName 555---->' + accountCtrl.inputAccountName );
        accountCtrl.accountDropDown = 'EndsWith';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
        if(i==2){

        accountCtrl.inputAccountName = inputValue.subString(0,1);
        accountCtrl.accountDropDown = 'Contains';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
        if(i==3){
        accountCtrl.inputAccountName = inputValue.subString(0,3);
        accountCtrl.accountDropDown = 'Contains';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
        if(i==4){
        accountCtrl.inputAccountName = '12323232424';
        accountCtrl.accountDropDown = 'Contains';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
        if(i==5){
        String s = 'Test A';
        accountCtrl.inputAccountName = s;
        accountCtrl.accountDropDown = 'Contains';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
    
        if(i==6){
        String s = 'Test A123';
        accountCtrl.inputAccountName = s;
        accountCtrl.accountDropDown = 'Contains';
        accountCtrl.filterAccountSearch();
        accountCtrl.getProfileAccountDetails();
        }
     //   }
        accountCtrl.paramValue = lstAccount[0].id ;
        accountCtrl.populateselectedrecord();  
       }
        Test.StopTest(); 
        } //END Method AccountTest
}//END Class