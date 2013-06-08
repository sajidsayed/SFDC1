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

 |  23/09/2012    Hemavathi N M   204033     This Test class is used for Pricing Requests Sharing for Accoount owner and parent child Sharing     
                      
 +==================================================================================================================**/

 @isTest(SeeAllData=true) 
private class Transformation_PricingShare_TC {

 public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<Pricing_Requests__c> lstPricing = new List<Pricing_Requests__c>();
 public Static List<Pricing_Requests__c> lstPricingRecall = new List<Pricing_Requests__c>();
 public Static List<Pricing_Requests__c> lstPricingAcceptanceOwner = new List<Pricing_Requests__c>();
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
      // List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ')limit 4];
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c not in ('APJ')and Division__c in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A')limit 4];
      
       for(Integer i=0;i<3;i++){ 
         Opportunity opp_Obj = new Opportunity();
        if(i==0){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[0].id;
          opp_Obj.Name = 'TEST';
          opp_Obj.StageName = 'Pipeline';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          opp_Obj.Opportunity_Number__c='1';
          
        }
        if(i==1){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[1].id;
          opp_Obj.Name = 'TEST 1';
          opp_Obj.StageName = 'Pipeline';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
          opp_Obj.Quote_Cart_Number__c='123';
           opp_Obj.Opportunity_Number__c='2';
        }
        if(i==2){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[2].id;
          opp_Obj.Name = 'TEST 2';
          opp_Obj.StageName = 'Pipeline';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
           opp_Obj.Opportunity_Number__c='3';
        }
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }  //end of method Creation Of Opportunity
            
//Method for creation of Pricing Requests    
    public void createPricingRequest(){
    
    List<Pricing_Requests__c> lstPric = new List<Pricing_Requests__c>();
    //Select id from Opportunity
    for(Integer i=0;i<2;i++){   
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
  
  // Submit for Approval
  public void submitForApproval()
        {
          System.debug('####Inside--->');
            // Create an approval request for the Opportunity
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval automatically using Trigger');
            for(Pricing_Requests__c prObj:lstPricing){ 
            req1.setObjectId(prObj.id);
            Approval.ProcessResult result = Approval.process(req1);
            }
          //  req1.setNextApproverIds(new Id[] {opp.Next_Approver__c});
     
            // Submit the approval request for the Opportunity
            
            System.debug('#### Submitted--->');
     
        }
        //Get ProcessInstanceWorkItemId using SOQL
        public Id getWorkItemId(Id targetObjectId)
        {
            Id retVal = null;
     
            for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                where p.ProcessInstance.TargetObjectId =: targetObjectId])
            {
                retVal  =  workItem.Id;
            }
     
            return retVal;
        }
   public void approveRecord()
        {
             System.debug('####Inside--- Approve REcord>');
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request using Trigger');
            req.setAction('Approve');
            for(Pricing_Requests__c prObj:lstPricing){ 
             Id workItemId = getWorkItemId(prObj.id);
             if(workItemId != null)
               {
                   req.setWorkitemId(workItemId);
                // Submit the request for approval
                Approval.ProcessResult result = Approval.process(req);
                
               }
            }
            
            System.debug('#### Approved--- Approve REcord>');
        }

//Method to test Pricing Request Share
    static testMethod void pricingShare() { 
      Transformation_PricingShare_TC testObj = new Transformation_PricingShare_TC();
      Transformation_PricingShare_Class priceshrObj = new Transformation_PricingShare_Class();
      
      //Create Account and Opportunity      
        testObj.createAccount();
        testObj.createOpportunity();
                     
    
    List<Id> lstPrl = new List<Id>();
      List<User> lstUser = [Select id ,Theater__c from user where IsActive = true and Theater__c in ('APJ')limit 3];
      List<User> lstUser1 = [Select id ,Theater__c from user where IsActive = true and Theater__c in ('EMEA') limit 3];
      System.debug('lstUser--->' + lstUser);
      List<id> idList = new List<id>();
      // Create Pricing Request
      
      
      User usrData = [Select id from User where Id = :UserInfo.getUserId()];
     System.RunAs(usrData)
     {
      //  Test.startTest();
        testObj.createPricingRequest();
       //  Test.stopTest();
     }


    //  Test.startTest();
       
      // Update Oppty owner with acitve user
      System.debug('lstOpp size----->'+lstOpp.size());
       for(Opportunity oppObj : lstOpp)
        {
          idList.add(oppObj.Opportunity_Owner__c);
          if(lstUser.size()>0){
             for(Integer i=0;i<2;i++){ 
             if(i==0){
                oppObj.Opportunity_Owner__c = lstUser[0].id;}
             if(i==1){
             oppObj.Opportunity_Owner__c = lstUser1[0].id;}
                
                }//end of inner for
             }//end of lstUser size
        }// end of outer for 
 
        DataBase.update(lstOpp);
        System.debug('lstOpp--1-->' + lstOpp);
        
    //Update PR with oppty name
    for(Pricing_Requests__c prUpdateObj : lstPricing)
     {
         if(lstOpp.size()>0){
         for(Integer j=lstOpp.size()-1;j>0;j--){   
            prUpdateObj.Opportunity_Name__c= lstOpp[j].id;
            prUpdateObj.Approval_Expiration_Date__c = Date.today();
            prUpdateObj.Recalled_Flag__c=true;
            if(j==0){
            	prUpdateObj.APJ_Request_Escalation__c =true;
                prUpdateObj.Recalled_Flag__c=false;	
            }
           
            }//end of inner for
       
        }// end of size of oppty list
     }// end of outer for 
              
     DataBase.update(lstPricing);
     System.debug('lstPricing@@---->'+lstPricing);
     
    //Submitting for approval
       testObj.submitForApproval();

    User usr = [Select id from User where Id = :UserInfo.getUserId()];
     System.RunAs(usr)

     {

        Test.startTest();

         testObj.approveRecord();

         Test.stopTest();

     }
                           
        
   } // end of method
   
   
 //Method to test Pricing Request Acceptance
    static testMethod void pricingAcceptance() { 
      Transformation_PricingShare_TC testObj = new Transformation_PricingShare_TC();
      Transformation_PricingShare_Class priceshrObj = new Transformation_PricingShare_Class();
       
 
      //Create Account and Opportunity      
        testObj.createAccount();
        testObj.createOpportunity();
                     
          
     User usrData = [Select id from User where Id = :UserInfo.getUserId()];
     System.RunAs(usrData)
     {
       testObj.createPricingRequest();
       
	   Test.startTest();
    
       User usrAcceptanceData = [Select id from User where Id = :UserInfo.getUserId()];
       List<User> lstUser = [Select id,Theater__c ,Division__c  from user where IsActive = true and Theater__c in ('APJ') and Division__c in ('Korea','UKI','ANZ','Greater China','India','Japan','South East Asia' ) and Division__c Not in ('N/A') limit 4];
       System.RunAs(usrAcceptanceData)
        {  
        //	testObj.submitForApproval();
          lstPricingAcceptanceOwner = [select id,ownerId ,Approval_Status__c,APJ_Request_Escalation__c from Pricing_Requests__c where id in:lstPricing];
         
          for(Integer j=0;j<lstPricingAcceptanceOwner.size();j++){
            lstPricingAcceptanceOwner[j].OwnerId = lstUser[0].id;
            lstPricingAcceptanceOwner[j].APJ_Request_Escalation__c = true;
            }
            DataBase.update(lstPricingAcceptanceOwner);
        }
       Test.stopTest();

     }
  }//End Method pricingAcceptance
  
}//end of class