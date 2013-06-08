/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  03-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true) 
private class MassUpdater_TC {

           public Static List<Account> acctLst = new List<Account>();
           public Static List<Opportunity> lstOpp= new List<Opportunity>();
           public static Schema.SObjectField field=Opportunity.Next_Steps__c;
           public static Object value ='Next step';
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
          opp_Obj.Name = 'test for owner';
          opp_Obj.Opportunity_Number__c='1';
          opp_Obj.StageName = 'TEST';
          opp_Obj.Next_Steps__c='next1';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        
         if(i==1){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[1].id;
          opp_Obj.Name = 'test for owner2';
          opp_Obj.Opportunity_Number__c='2';
          opp_Obj.StageName = 'TEST 1';
          opp_Obj.Next_Steps__c='next2';
          opp_Obj.CloseDate = Date.today()+10;
          opp_Obj.Sales_Force__c = 'EMC';
          opp_Obj.Sales_Channel__c = 'Direct';
          opp_Obj.VMWare_Related__c = 'VMWare Backup';
          opp_Obj.Amount = 222.00;
        }
        
        if(i==2){  
          opp_Obj.AccountId =acctLst[0].id;
          opp_Obj.Opportunity_Owner__c = lstUser[2].id;
          opp_Obj.Name = 'test for owner3';
          opp_Obj.Opportunity_Number__c='3';
          opp_Obj.StageName = 'TEST 2';
          opp_Obj.Next_Steps__c='next3';
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
    }
   static testMethod void MassUpdater(){
    
    Test.StartTest();
    MassUpdater_TC objTC=new MassUpdater_TC();
      objTC.createAccount(); 
      objTC.createOpportunity();
    //oppList=[Select id from Opportunity where name in ('test for owner', 'test for owner2','test for owner3') limit 10];
    //ApexPages.StandardController sc = new ApexPages.StandardController(accList);
    MassUpdater act = new MassUpdater(lstOpp,field,value);
    act.massUpdate();

    Test.StopTest();
}
}