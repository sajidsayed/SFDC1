@isTest(SeeAllData=true) 
private class Transformation_ProcessInstance_TC {
 public Static List<Account> acctLst = new List<Account>();
 public Static List<Opportunity> lstOpp= new List<Opportunity>();
 public Static List<Pricing_Requests__c> lstPricing = new List<Pricing_Requests__c>();
 
 public void createAccount(){
     Account acctObj = new Account();
        acctObj.Name = 'Pricing Testing';
        acctObj.Synergy_Account_Number__c = '123456';
        acctLst.add(acctObj);
        Database.insert(acctLst);
        System.debug('Account Created'); 
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where Name =:acctLst[0].Name];
     } //end of method Creation Of Account
     
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ')limit 4];
       for(Integer i=0;i<3;i++){ 
         Opportunity opp_Obj = new Opportunity();
         
        if(i==0){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[0].id;
          opp_Obj.Name = 'TEST';
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
          opp_Obj.Name = 'TEST 2';
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
       lstOpp =[select ID,Name,Opportunity_Owner__c , Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }  //end of method Creation Of Opportunity
         
   
   
    
public void createPricingRequest(){
    
    List<Pricing_Requests__c> lstPric = new List<Pricing_Requests__c>();
    //Select id from Opportunity
    for(Integer i=0;i<3;i++){   
      Pricing_Requests__c priReq_Obj = new Pricing_Requests__c();
      priReq_Obj.Opportunity_Name__c = lstOpp[i].id;
      priReq_Obj.Price_Floor_Level__c = 'L4';
      priReq_Obj.How_can_we_mask_actual_discount__c = 'TEST 1234';
      priReq_Obj.Approval_Status__c ='New';
      priReq_Obj.APJ_Request_Escalation__c =false;
      priReq_Obj.Recalled_Flag__c=false;
      priReq_Obj.EMC_PRODUCTS__c='test';
      lstPric.add(priReq_Obj);
     }
     Database.insert(lstPric);
     
     lstPricing =[select id,Approval_Status__c,createdById, Opportunity_Name__r.Opportunity_Owner__r.Theater__c,Opportunity_Name__r.Opportunity_Owner__c ,Opportunity_Name__r.Account_Owner_Theater__c from Pricing_Requests__c  where id in:lstPric];
     System.debug('lstPricing--------->'+lstPricing .size());
  } ///end of method Creation Of Pricing Requests 
  
static testMethod void Transformation_ProcessInstanceController()
    {
    Transformation_ProcessInstance_TC instanceObj = new Transformation_ProcessInstance_TC();
       instanceObj.createAccount();
        instanceObj.createOpportunity();
        instanceObj.createPricingRequest();
        User usrData = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usrData)
       {
        PageReference pageRef = Page.Transformation_RecallVF; 
        Test.setCurrentPage(pageref);
        ApexPages.currentPage().getParameters().put('id', lstPricing[0].ID); 
          Transformation_ProcessInstanceController  controller = new Transformation_ProcessInstanceController();

       String  nextPage = controller.recall().getUrl();
       
       String  nextPageCancel = controller.Cancel().getUrl();
        }

}
}