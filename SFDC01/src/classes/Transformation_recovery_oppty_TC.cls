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
/*==================================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER      WR        DESCRIPTION                               

 |  ====          =========      ==        =========== 

 |  21/02/2013    Hemavathi N M        This Test class is used to test the functionality of Transformation Recovery Oppty.   
                      
 +==================================================================================================================**/

 @isTest(SeeAllData=true) 
private class Transformation_recovery_oppty_TC {
    
    public Static List<Account> acctLst = new List<Account>();
    public Static List<Opportunity> lstOpp= new List<Opportunity>();
    public Static List<Pricing_Requests__c> lstPricing = new List<Pricing_Requests__c>();
    public Static List<Recovery_Opportunity__c> lstROppty = new List<Recovery_Opportunity__c>();
    public static Integer loopLimit= 3;
    
    //Method for Creation Of Account    
    public void createAccount(){
    List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ','EMEA')limit :loopLimit];  
     for(Integer k=0;k<loopLimit;k++){
        Account accObj1 = new Account();
        accObj1.name = 'TestAccount'+ k;
        accObj1.ownerId=lstUser[k].id;
        accObj1.BillingCountry ='United States';
        accObj1.BillingCity = 'EDWARDS AFB'; 
        acctLst.add(accObj1);
        }
        Database.insert(acctLst);
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where id in:acctLst];
     } //end of method Creation Of Account
     
     //Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ','EMEA')and Division__c not in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A')limit :loopLimit];
       for(Integer k=0;k<loopLimit;k++){
        Opportunity opp_Obj = new Opportunity();
          opp_Obj.AccountId =acctLst[k].id;
          opp_Obj.Opportunity_Owner__c = UserInfo.getUserID();
          opp_Obj.Deal_Lead__c=lstUser[k].id;
          opp_Obj.ownerId=lstUser[k].id;
          opp_Obj.Name = 'TEST'+ k;
          opp_Obj.StageName = 'upside';
          opp_Obj.Opportunity_Number__c ='123213';
          if(k==0){
          opp_Obj.StageName = 'Pipeline';
          opp_Obj.Opportunity_Number__c ='2324243';
          }
          if(k==1){
          opp_Obj.Opportunity_Number__c ='6666454';
          opp_Obj.Opportunity_Owner__c = UserInfo.getUserID();
          }
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c ,StageName, Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
    }  //end of method Creation Of Opportunity
            
    //Method for creation of Pricing Requests    
    public void createPricingRequest(){
    List<Pricing_Requests__c> lstPric = new List<Pricing_Requests__c>();
     for(Integer k=0;k<loopLimit;k++){
      Pricing_Requests__c priReq_Obj = new Pricing_Requests__c();
      priReq_Obj.Opportunity_Name__c = lstOpp[k].id;
      priReq_Obj.Price_Floor_Level__c = 'L4';
      priReq_Obj.How_can_we_mask_actual_discount__c = 'TEST 1234';
      priReq_Obj.Approval_Status__c ='New';
      priReq_Obj.Recalled_Flag__c = false;
      priReq_Obj.APJ_Request_Escalation__c = false;
      priReq_Obj.Approval_Expiration_Date__c=Date.today()+10;
      priReq_Obj.EMC_PRODUCTS__c='test';
      lstPric.add(priReq_Obj);
     }
     Database.insert(lstPric);
     
     lstPricing =[select id,Approval_Status__c,Approval_Expiration_Date__c,Expired_Request__c,createdById, Opportunity_Name__r.Opportunity_Owner__r.Theater__c,Opportunity_Name__r.Opportunity_Owner__c ,Opportunity_Name__r.Account_Owner_Theater__c from Pricing_Requests__c  where id in:lstPric];
 
  } ///end of method Creation Of Pricing Requests 
    
    //Method for creation of Recovery Opportunity
    public void createRecoveryOppty(){
        for(Integer k=0;k<2;k++){
            Recovery_Opportunity__c rObj = new Recovery_Opportunity__c();
            rObj.Opportunity_Name__c =lstOpp[k].id ;
            rObj.Pricing_Approval_ID__c = lstPricing[k].Id;
            lstROppty.add(rObj);
        }       
        Database.insert(lstROppty);
        lstROppty = [Select id ,Pricing_Approval_ID__r.Opportunity_Name__c from Recovery_Opportunity__c where id in: lstROppty];
        System.debug('lstROppty---->'+lstROppty);
    }

    static testMethod void testRecoveryOppty() {
        // TO DO: implement unit test
        Transformation_recovery_oppty  classInstance = new Transformation_recovery_oppty();
        Transformation_recovery_oppty_TC testObj = new Transformation_recovery_oppty_TC();
       User usrData = [Select id from User where Id = :UserInfo.getUserId()];
      System.RunAs(usrData)
         {
            testObj.createAccount();
            testObj.createOpportunity();
            testObj.createPricingRequest();
            testObj.createRecoveryOppty();
         }
         Test.startTest();


            Recovery_Opportunity__c reObj = new Recovery_Opportunity__c();
             lstROppty[0].Opportunity_Name__c = lstOpp[1].id;
             lstROppty[0].Pricing_Approval_ID__c  = lstPricing[1].id;
             
         
         try{
          System.RunAs(usrData)
         {
                update lstROppty;}
         }catch(Exception e){
            
         }
         
         List<Pricing_Requests__c> listPR = new List<Pricing_Requests__c>();
         Opportunity oppObj = new Opportunity();
         System.debug('lstROppty[0].Pricing_Approval_ID__r.Opportunity_Name__c---'+lstROppty[0].Pricing_Approval_ID__r.Opportunity_Name__c);
         oppObj = [Select id ,StageName from Opportunity where id =: lstROppty[0].Pricing_Approval_ID__r.Opportunity_Name__c limit 1];

         System.debug('oppObj--->'+oppObj);
         oppObj.StageName = 'Closed';
         oppObj.Closed_Reason__c ='Qualified Out';
         oppObj.Close_Comments__c='test oppty';
        
        User usrData1 = [Select id from User where Id = :UserInfo.getUserId()];
         System.RunAs(usrData1)
         {
                update oppObj;
         }
         Test.stopTest();
        
        //Create REcords
        
    }
    
  /*  static testMethod void testOpptySearch() {
    Transformation_recovery_oppty_TC testObj = new Transformation_recovery_oppty_TC();
  //  Transformation_opptySearch classObj = new Transformation_opptySearch();
    User usrData = [Select id from User where Id = :UserInfo.getUserId()];
     System.RunAs(usrData)
         {
            testObj.createAccount();
            testObj.createOpportunity();
            testObj.createPricingRequest();
        }
    //search by Name
    
    //Search by Number
   // classObj.inputOpptyNumber =lstOpp[0].Opportunity_Number__c;
    //Search by both Name and Number
    Opportunity objOppty = new Opportunity();
   ApexPages.StandardController setCon = new  ApexPages.StandardController(objOppty);
      PageReference acctPage = new PageReference('/apex/Transformation_PAR_OpptyLookup?lktp=006&oid='+lstPricing[0].id+'&lknm=CF00N70000002sgdS&lksrch=&lkfm=editPage');
      Test.setCurrentPage(acctPage);
      Transformation_opptySearch opptySearch = new Transformation_opptySearch(setCon);
    opptySearch.clearresults();
    opptySearch.cancelLink();
         
        
    }*/
}