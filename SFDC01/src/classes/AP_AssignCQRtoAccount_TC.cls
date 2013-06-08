/*============================================================================================================+
 |  HISTORY  |
 |  DATE          DEVELOPER               WR                        DESCRIPTION 
 |  ====          =========               ==                        =========== 
 | 15 Jan 2013   Hemavathi N M         Account Presentation        This Test Class is used to test Batch job for CQR       
 +============================================================================================================*/
 
@isTest(SeeAllData=true)
private class AP_AssignCQRtoAccount_TC {

    public static List <Job_Scheduler__c> bulkScheds = new List <Job_Scheduler__c> ();
    public static List <Core_Quota_Rep__c> coreQuotaReplst = new List<Core_Quota_Rep__c>();
    public static List<CQR_Delta_Log__c> lstCQRDelta = new List<CQR_Delta_Log__c>();
    public static List<Account> lstAccount = New List<Account>();
    public static List<District_Lookup__c> lstDistrictLookup = New List<District_Lookup__c>();
    public static Integer loopLimit= 3;
    public static Job_Scheduler__c js;
    public static id HouseUserId;

   
   // MEthod : To create customprofiledAccount record
      public void createCustomerProfiledAccount(){
        
       List<User> lstUser = [Select id from user where IsActive = true and IsPortalEnabled = false limit: loopLimit];
       
       List<User> lstHouseUser = [select id from User where name = 'House Account' limit 1];
       User HouseUser;
       if(lstHouseUser != null && lstHouseUser.get(0) != null)
        {
            HouseUser = lstHouseUser.get(0);
            HouseUserId = HouseUser.id;
        }

       System.debug('lstUser-------->'+lstUser.size());
            
        for(Integer k=0;k<loopLimit;k++){
        if(k==0){
        Account accObj1 = new Account();
        accObj1.name = 'TestAccount'+ k;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        accObj1.District_Lookup__c = lstDistrictLookup[k].Id; 
        accObj1.Customer_Profiled_Account__c=true;
        accObj1.Core_Quota_Rep__c=lstUser[0].id;
        lstAccount.add(accObj1);
        }
        else if(k==1){
        Account accObj = new Account();
        accObj.name = 'TestAccount Quota House '+ k;
        accObj.BillingCountry ='United States';
        accObj.BillingCity = 'EDWARDS AFB'; 
        accObj.District_Lookup__c = lstDistrictLookup[k].Id; 
        accObj.Customer_Profiled_Account__c=true;
        accObj.Core_Quota_Rep__c=lstUser[1].id;
        lstAccount.add(accObj);
        }
        else{
        Account accObj2 = new Account();
        accObj2.name = 'TestAccount'+ k;
        accObj2.BillingCountry ='United States';
        accObj2.BillingCity = 'EDWARDS AFB'; 
        accObj2.District_Lookup__c = lstDistrictLookup[k].Id; 
        accObj2.Customer_Profiled_Account__c=true;
        accObj2.Core_Quota_Rep__c=lstUser[2].id;

        if(HouseUser != null)
            accObj2.Core_Quota_Rep__c = HouseUser.id;

        lstAccount.add(accObj2);
        }
        }
        
        Database.insert(lstAccount);
        lstAccount = [Select Id,District_Lookup__c, Name,District_Lookup__r.Oracle_District_ID__c,BillingCountry,Hub_Info__r.Golden_Site_Name__c, Hub_Info__c,Business_Unit_Ultimate__c,BillingCity ,Global_Ultimate__c,BUU_Golden_Site_Name__c,GU_Golden_Site_Name__c,MAP_Account_Name__c ,Core_Quota_Rep__c ,Customer_Profiled_Account__c,Account_District__c FROM Account Where id in: lstAccount];
        System.debug('lstAccount---->' + lstAccount);
      }//END METHOD - CreatecustomProfiledAccount
      
      // MEthod : To create districtlookup record
       public void createDistrictLookup(){
        for(Integer k=0;k<loopLimit;k++){
            District_Lookup__c objDistrictLookup = new District_Lookup__c();
            objDistrictLookup.Name ='TestLookup' + k;
            objDistrictLookup.Area__c='EDWARDS';
            objDistrictLookup.Oracle_District_ID__c = '3213243241';
            if(k==0){
            objDistrictLookup.Area__c='EDWARDS';
            objDistrictLookup.Oracle_District_ID__c = '11111111';}
            if(k==1){
            objDistrictLookup.Area__c='EDWARDS';
            objDistrictLookup.Oracle_District_ID__c = '22222222';}
            
            
            lstDistrictLookup.add(objDistrictLookup);
        }
      Database.insert(lstDistrictLookup);
      lstDistrictLookup = [Select id ,Name ,Oracle_District_ID__c from District_Lookup__c where id in: lstDistrictLookup ]; 
      System.debug('lstDistrictLookup------>' + lstDistrictLookup);
        }//END MEthod - createDistrictLookup
   
   public void createCQR(){
    if(lstAccount.size()>0){
    for(Integer k=0;k<loopLimit;k++){
            Core_Quota_Rep__c objCQR1 = new Core_Quota_Rep__c();
            objCQR1.Name ='TestCQR' + k;
            objCQR1.Batch_ID__c=10;
            objCQR1.Badge_ID__c = '611111';
            objCQR1.Account_ID__c=lstAccount[k].id;
            objCQR1.District_Name__c=lstAccount[k].District_Lookup__c;
            objCQR1.Oracle_District_ID__c = lstAccount[k].District_Lookup__r.Oracle_District_ID__c;
            coreQuotaReplst.add(objCQR1);
        
            Core_Quota_Rep__c objCQR = new Core_Quota_Rep__c();
            objCQR.Name ='TestCQR' + k;
            if(k!=2)
            if(k!=0)
            objCQR.Batch_ID__c=k;
            objCQR.Badge_ID__c = '611112';
            objCQR.District_Name__c=lstAccount[k].District_Lookup__c;
            objCQR.Oracle_District_ID__c = lstAccount[k].District_Lookup__r.Oracle_District_ID__c;
            coreQuotaReplst.add(objCQR);
            
            Core_Quota_Rep__c objCQR2 = new Core_Quota_Rep__c();
            objCQR2.Name ='TestCQR Quota' + k;
            objCQR2.Batch_ID__c=10;
            objCQR2.Badge_ID__c = 'D61234';
            objCQR2.Account_ID__c=lstAccount[k].id;
            objCQR2.District_Name__c=lstAccount[k].District_Lookup__c;
            objCQR2.Oracle_District_ID__c = lstAccount[k].District_Lookup__r.Oracle_District_ID__c;
            objCQR2.SFDC_User_ID__c = HouseUserId;
            coreQuotaReplst.add(objCQR2);

            Core_Quota_Rep__c objCQR3 = new Core_Quota_Rep__c();
            objCQR3.Name ='TestCQR Quota 2' + k;
            objCQR3.Batch_ID__c=10;
            objCQR3.Badge_ID__c = 'D61235';
            objCQR3.Account_ID__c=lstAccount[k].id;
            objCQR3.District_Name__c=lstAccount[k].District_Lookup__c;
            objCQR3.Oracle_District_ID__c = lstAccount[k].District_Lookup__r.Oracle_District_ID__c;
            coreQuotaReplst.add(objCQR3);

    }//END IF     
    
    }//END FOR
      Database.insert(coreQuotaReplst);
      coreQuotaReplst = [Select id ,Name,Account_ID__c,Account_ID__r.Name from Core_Quota_Rep__c where id in: coreQuotaReplst]; 
      System.debug('coreQuotaReplst------>' + coreQuotaReplst);
    
    
   } //END MEthod - createCQR

 // Method : To create CQR Delta Log
        public void createCQRDelta(){
             for(Integer k=0;k<loopLimit;k++){
            CQR_Delta_Log__c objCQRDelta = new CQR_Delta_Log__c();
            objCQRDelta.Account__c = lstAccount[k].Id ;
            objCQRDelta.Account_Id__c = lstAccount[k].Id ;
            objCQRDelta.Core_Quota_Rep_Id__c =coreQuotaReplst[k].Id ;
            objCQRDelta.Core_Quota_Rep_Name__c = coreQuotaReplst[k].Name;
            objCQRDelta.External_ID__c = 'Test' + k;
            objCQRDelta.District_Name__c = lstDistrictLookup[k].Name;
            objCQRDelta.Batch_ID__c = k;
            lstCQRDelta.add(objCQRDelta);
             }
            Database.insert(lstCQRDelta);
            lstCQRDelta = [Select id from CQR_Delta_Log__c where id in: lstCQRDelta]; 
            System.debug('lstCQRDelta------>' + lstCQRDelta);
            
        }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public static testMethod void testAssignCQR() 
  {
        //Call methods 
        AP_AssignCQRScheduler batchExecute = new AP_AssignCQRScheduler(js);
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            testObject.createDistrictLookup();
            testObject.createCustomerProfiledAccount();
            testObject.createCQR();
            testObject.createCQRDelta();
        } 
        String sch = '0 0 0 4 10 ?' ;
     
    Test.StartTest();
    try
    {
        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        batchExecute.isRunTest = true;
        system.schedule('Test Assign CQR Account', sch,batchExecute);
    }
    catch(Exception e) 
    {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e );   
    }

    Test.StopTest();
  }


//Test method added by Avinash begins below...
  public static testMethod void testAssignCQR_NoCQR() 
  {
        AP_AssignCQRScheduler batchExecute = new AP_AssignCQRScheduler(js);
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            testObject.createDistrictLookup();
            testObject.createCustomerProfiledAccount();
            testObject.createCQR();

            Set<Id> setAccIds = new Set<Id>();

            for (Account acc : AP_AssignCQRtoAccount_TC.lstAccount) 
            {
                setAccIds.add(acc.id);
            }

            List<Core_Quota_Rep__c> lstDeleteCQR = new List<Core_Quota_Rep__c>();
            lstDeleteCQR = [select id from Core_Quota_Rep__c where Account_ID__c IN :setAccIds limit 50000];

            delete lstDeleteCQR;

        } 
        String sch = '0 0 0 4 10 ?' ;
     
    Test.StartTest();
    try
    {
        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        batchExecute.isRunTest = true;
        system.schedule('Test Assign CQR Account', sch,batchExecute);
    }
    catch(Exception e) 
    {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e );   
    }

    Test.StopTest();
  }

//Test method added by Avinash ends above.


//Test method added by Avinash begins below...
  public static testMethod void testAssignCQR_LoneHouseCQR() 
  {
        AP_AssignCQRScheduler batchExecute = new AP_AssignCQRScheduler(js);
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            testObject.createDistrictLookup();
            testObject.createCustomerProfiledAccount();
            testObject.createCQR();

            Set<Id> setAccIds = new Set<Id>();

            for (Account acc : AP_AssignCQRtoAccount_TC.lstAccount) 
            {
                setAccIds.add(acc.id);
            }

            List<Core_Quota_Rep__c> lstDeleteCQR = new List<Core_Quota_Rep__c>();
            lstDeleteCQR = [select id from Core_Quota_Rep__c where Account_ID__c IN :setAccIds order by Badge_ID__c ASC limit 3];

            delete lstDeleteCQR;

        } 
        String sch = '0 0 0 4 10 ?' ;
     
    Test.StartTest();
    try
    {
        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        batchExecute.isRunTest = true;
        system.schedule('Test Assign CQR Account', sch,batchExecute);
    }
    catch(Exception e) 
    {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e );   
    }

    Test.StopTest();
  }

//Test method added by Avinash ends above.


//Test method added by Avinash begins below...
  public static testMethod void testAssignCQR_LoneCQR() 
  {
        AP_AssignCQRScheduler batchExecute = new AP_AssignCQRScheduler(js);
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            testObject.createDistrictLookup();
            testObject.createCustomerProfiledAccount();
            testObject.createCQR();

            Set<Id> setAccIds = new Set<Id>();

            for (Account acc : AP_AssignCQRtoAccount_TC.lstAccount) 
            {
                setAccIds.add(acc.id);
            }

            List<Core_Quota_Rep__c> lstDeleteCQR = new List<Core_Quota_Rep__c>();
            lstDeleteCQR = [select id from Core_Quota_Rep__c where Account_ID__c IN :setAccIds order by Badge_ID__c DESC limit 3];

            delete lstDeleteCQR;

        } 
        String sch = '0 0 0 4 10 ?' ;
     
    Test.StartTest();
    try
    {
        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        batchExecute.isRunTest = true;
        system.schedule('Test Assign CQR Account', sch,batchExecute);
    }
    catch(Exception e) 
    {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e );   
    }

    Test.StopTest();
  }

//Test method added by Avinash ends above.

//Test method added by Avinash begins below...
  public static testMethod void testAssignCQR_AccHouseCQR() 
  {
        AP_AssignCQRScheduler batchExecute = new AP_AssignCQRScheduler(js);
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            testObject.createDistrictLookup();
            testObject.createCustomerProfiledAccount();
            testObject.createCQR();

            Set<Id> setAccIds = new Set<Id>();

            for (Account acc : AP_AssignCQRtoAccount_TC.lstAccount) 
            {
                setAccIds.add(acc.id);
            }

            List<Core_Quota_Rep__c> lstDeleteCQR = new List<Core_Quota_Rep__c>();
            lstDeleteCQR = [select id from Core_Quota_Rep__c where Account_ID__c IN :setAccIds AND Badge_ID__c like '6%' limit 50000];

            delete lstDeleteCQR;
        } 
        String sch = '0 0 0 4 10 ?' ;
     
    Test.StartTest();
    try
    {
        String Query = 'Select Id, Account__c,Account_Id__c,Badge_ID__c,Batch_ID__c,Core_Quota_Rep_Id__c,Core_Quota_Rep_Name__c,District_Name__c ,External_ID__c,Oracle_District_ID__c,Role_Name__c,SFDC_User_ID__c from CQR_Delta_Log__c order by Account__c';
        batchExecute.isRunTest = true;
        system.schedule('Test Assign CQR Account', sch,batchExecute);
    }
    catch(Exception e) 
    {
        system.debug('Exception Inside AuditReportingSchedulerTest()' + e );   
    }

    Test.StopTest();
  }

//Test method added by Avinash ends above.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Test Method created by Avinash
    public static testMethod void testAP_AccountBeforeUpdate()
    {
        AP_AssignCQRtoAccount_TC testObject = new AP_AssignCQRtoAccount_TC();
        
        AP_AssignCQRtoAccount_TC.bulkScheds = new List <Job_Scheduler__c> ();
        AP_AssignCQRtoAccount_TC.coreQuotaReplst = new List<Core_Quota_Rep__c>();
        AP_AssignCQRtoAccount_TC.lstCQRDelta = new List<CQR_Delta_Log__c>();
        AP_AssignCQRtoAccount_TC.lstAccount = New List<Account>();
        AP_AssignCQRtoAccount_TC.lstDistrictLookup = New List<District_Lookup__c>();
        AP_AssignCQRtoAccount_TC.loopLimit= 3;

        testObject.createDistrictLookup();
        testObject.createCustomerProfiledAccount();
        testObject.createCQR();

        for (Core_Quota_Rep__c cqr : AP_AssignCQRtoAccount_TC.coreQuotaReplst) 
        {
            if(AP_AssignCQRtoAccount_TC.lstAccount != null && AP_AssignCQRtoAccount_TC.lstAccount.size() > 0 && 
              AP_AssignCQRtoAccount_TC.lstAccount[0].Core_Quota_Rep__c != null)
                cqr.SFDC_User_ID__c = AP_AssignCQRtoAccount_TC.lstAccount[0].Core_Quota_Rep__c;
        }
        
        try
        {
            update AP_AssignCQRtoAccount_TC.coreQuotaReplst;
        }
        catch(Exception e)
        {
            system.debug('#### Exception occurred');
        }


        if(AP_AssignCQRtoAccount_TC.coreQuotaReplst != null && AP_AssignCQRtoAccount_TC.coreQuotaReplst.size() > 1)
            for (Account acc : AP_AssignCQRtoAccount_TC.lstAccount) 
            {
                acc.Core_Quota_Rep__c = AP_AssignCQRtoAccount_TC.coreQuotaReplst[1].SFDC_User_ID__c;
            }

        try
        {
            update AP_AssignCQRtoAccount_TC.lstAccount;
        }
        catch(Exception e)
        {
            system.debug('#### Exception occurred');
        }
    }
}