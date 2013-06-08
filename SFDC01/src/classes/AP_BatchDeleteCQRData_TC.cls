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
 |  17 Dec 2012   Hemavathi N M         Account Presentation        This Test Class is used to test Batach job for CQR       
 +===========================================================================================================================================================*/
 
@isTest(SeeAllData=true)
private class AP_BatchDeleteCQRData_TC {

    public static List <Job_Scheduler__c> bulkScheds = new List <Job_Scheduler__c> ();
    public static List <Core_Quota_Rep__c> coreQuotaReplst = new List<Core_Quota_Rep__c>();    
    public static List<CQR_Delta_Log__c> lstCQRDelta = new List<CQR_Delta_Log__c>();
    public static List<Account> lstAccount = New List<Account>();
    public static List<District_Lookup__c> lstDistrictLookup = New List<District_Lookup__c>();
    public static Integer loopLimit= 3;
    public  static Job_Scheduler__c js;

   
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
   
   public void createCQR(){
    lstAccount = [Select id,District_Lookup__c from Account where id in: lstAccount];
    if(lstAccount.size()>0){
    for(Integer k=0;k<loopLimit;k++){
            Core_Quota_Rep__c objCQR = new Core_Quota_Rep__c();
            objCQR.Name ='TestCQR' + k;
            objCQR.Account_ID__c=lstAccount[k].id;
            if(k!=0)
            objCQR.Batch_ID__c=k;
            objCQR.District_Name__c=lstAccount[k].District_Lookup__c;
            objCQR.External_ID__c='Exter' + k;
        //    objCQR.LastModifiedDate=System.Today()-1;
            coreQuotaReplst.add(objCQR);
    }//END IF
    
    //END IF     
    
    }//END FOR
      Database.insert(coreQuotaReplst);
      
      coreQuotaReplst = [Select id ,Name from Core_Quota_Rep__c where id in: coreQuotaReplst]; 
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

  public static testMethod void apBatchDeleteCQRData() {
        //Call methods 
        AP_BatchDeleteCQRData_TC testObject = new AP_BatchDeleteCQRData_TC();
         User usr = [Select id from User where Id = :UserInfo.getUserId()];
          System.RunAs(usr){
          testObject.createDistrictLookup();
          testObject.createCustomerProfiledAccount();
          testObject.createCQR();
          testObject.createCQRDelta();         
        }         
          
           Test.StartTest(); 
           Core_Quota_Rep__c togetCurrentBatchId = [SELECT Batch_ID__c FROM Core_Quota_Rep__c where Batch_ID__c!=null and id in:coreQuotaReplst Order By Batch_ID__c Desc Limit 1];
           Integer  batchID = Integer.ValueOf(togetCurrentBatchId.Batch_ID__c);
           AP_BatchDeleteCQRData batchObj = new AP_BatchDeleteCQRData();
           Id batchProcessId = Database.executeBatch(new AP_BatchDeleteCQRData(js,batchID),20);            



        
    }
}