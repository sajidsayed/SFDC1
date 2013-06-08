/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  02-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true)
private class Opp_PrimaryComptetorAndProduct_TC {
    public Static List<Account> acctLst = new List<Account>();
          public Static List<Opportunity> lstOpp= new List<Opportunity>();
          public void createAccount(){
          
        Account acctObj = new Account();
        acctObj.Name = 'Pricing Testing';
        acctObj.Synergy_Account_Number__c = '123456';
        acctLst.add(acctObj);        
        Database.insert(acctLst);
        System.debug('Account Created'); 
        acctLst = [Select ID,Synergy_Account_Number__c  from Account where id in: acctLst];
     } //end of method Creation Of Account
       
//Method for Creation Of Opportunity
    public void createOpportunity(){
       List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ')limit 4];
       for(Integer i=0;i<2;i++){ 
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
          opp_Obj.Competitor__c='Avere';
          opp_Obj.Product_Model__c='3PAR';
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
          opp_Obj.Competitor__c='CSC';
          opp_Obj.Product_Model__c='6140';
         }      
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);
       lstOpp =[select ID,Name,Opportunity_Owner__c ,Opportunity_Number__c, Account_Owner_Theater__c , Opportunity_Owner__r.Theater__c from Opportunity where id in:lstOpp];
       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }
static testMethod void Opp_PrimaryComptetorAndProduct(){
    Test.StartTest();
     Opp_PrimaryComptetorAndProduct_TC  cons=new Opp_PrimaryComptetorAndProduct_TC();
     cons.createAccount();
     cons.createOpportunity();
     Opportunity opt=new Opportunity();
     opt=lstOpp[0];
     ApexPages.StandardController sc = new ApexPages.StandardController(opt);
     Opp_PrimaryComptetorAndProduct obj=new Opp_PrimaryComptetorAndProduct(sc);
 Test.StopTest();
}
}