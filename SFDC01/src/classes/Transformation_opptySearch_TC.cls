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

 |  21/02/2013    Prachi Bhasin            This Test class is used to test the functionality of Transformation Recovery Oppty.   
                      
 +==================================================================================================================**/

 @isTest(SeeAllData=true) 
 private class Transformation_opptySearch_TC{
 
 
 public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<Pricing_Requests__c> lstPricing = new List<Pricing_Requests__c>();
  //Method for Creation Of Account    
    public void createAccount(){
     Account acctObj = new Account();
        acctObj.Name = 'Pricing Testing';
        acctObj.Synergy_Account_Number__c = '123456';
        acctLst.add(acctObj);
        Database.insert(acctLst);
        System.debug('Account Created'); 
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where Name =:acctLst[0].Name];
     } //end of method Creation Of Account
       
//Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ')limit 4];
       for(Integer i=0;i<3;i++){ 
         Opportunity opp_Obj = new Opportunity();
        if(i==0){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[0].id;
          opp_Obj.Name = 'TEST';
          opp_Obj.Opportunity_Number__c='1';
          opp_Obj.StageName = 'TEST';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        
         if(i==1){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[1].id;
          opp_Obj.Name = 'TEST 1';
          opp_Obj.Opportunity_Number__c='2';
          opp_Obj.StageName = 'TEST 1';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        
        if(i==2){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[2].id;
          opp_Obj.Name = 'T';
          opp_Obj.Opportunity_Number__c='3';
          opp_Obj.StageName = 'TEST 2';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }       
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c ,Opportunity_Number__c, Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }  //end of method Creation Of Opportunity
    
    //Method for creation of Pricing Requests    
    public void createPricingRequest(){
    
    List<Pricing_Requests__c> lstPric = new List<Pricing_Requests__c>();
    //Select id from Opportunity
    for(Integer i=0;i<1;i++){   
      Pricing_Requests__c priReq_Obj = new Pricing_Requests__c();
      priReq_Obj.Opportunity_Name__c = lstOpp[i].id;
      priReq_Obj.Price_Floor_Level__c = 'L4';
      priReq_Obj.How_can_we_mask_actual_discount__c = 'TEST 1234';
      priReq_Obj.Approval_Status__c ='New';
      priReq_Obj.EMC_PRODUCTS__c='test';
      lstPric.add(priReq_Obj);
     }
     Database.insert(lstPric);
     
     lstPricing =[select id,Approval_Status__c,createdById, Opportunity_Name__r.Opportunity_Owner__r.Theater__c,Opportunity_Name__r.Opportunity_Owner__c ,Opportunity_Name__r.Account_Owner_Theater__c from Pricing_Requests__c  where id in:lstPric];
  } ///end of method Creation Of Pricing Requests 
             
            

     static testMethod void testMethod1(){
        Test.startTest();
        Transformation_opptySearch_TC testObj=new Transformation_opptySearch_TC();
            testObj.createAccount();
            testObj.createOpportunity();
            testObj.createPricingRequest();
        PageReference pageRef = Page.Transformation_PAR_OpptyLookup;
        pageRef.getParameters().put('lksrch',lstOpp[0].Name);
        Test.setCurrentPage(pageRef);   
        Opportunity o = new opportunity();
        Transformation_opptySearch i = new Transformation_opptySearch(new ApexPages.StandardController(o));
        i.search();
        i.getOpptyDetails();
        i.clearresults();
        i.cancelLink();  
        
        
        
        PageReference pageRef1 = Page.Transformation_PAR_OpptyLookup;
        pageRef1.getParameters().put('lksrch','');
        Test.setCurrentPage(pageRef1);   
        Opportunity o1 = new opportunity();
        Transformation_opptySearch i1 = new Transformation_opptySearch(new ApexPages.StandardController(o1));
        i1.inputOpptyNumber =lstOpp[0].Opportunity_Number__c;
        i1.search();
        
        PageReference pageRef2 = Page.Transformation_PAR_OpptyLookup;
        pageRef2.getParameters().put('lksrch',lstOpp[0].Name);
        Test.setCurrentPage(pageRef2);   
        Opportunity o2= new opportunity();
        Transformation_opptySearch i2 = new Transformation_opptySearch(new ApexPages.StandardController(o2));
        i2.inputOpptyNumber =lstOpp[1].Opportunity_Number__c;
        i2.search();   
         
        PageReference pageRef3 = Page.Transformation_PAR_OpptyLookup;
        pageRef3.getParameters().put('lksrch','');
        Test.setCurrentPage(pageRef3);   
        Opportunity o3= new opportunity();
        Transformation_opptySearch i3 = new Transformation_opptySearch(new ApexPages.StandardController(o3));
        i3.search();  
         
         
        PageReference pageRef5 = Page.Transformation_PAR_OpptyLookup;
        pageRef5.getParameters().put('lksrch',lstOpp[2].Name);
        Test.setCurrentPage(pageRef5);   
        Opportunity o5= new opportunity();
        Transformation_opptySearch i5 = new Transformation_opptySearch(new ApexPages.StandardController(o5));
        i5.inputOpptyNumber =lstOpp[2].Opportunity_Number__c;
        i5.search();         
          Test.stopTest();
             }   
}