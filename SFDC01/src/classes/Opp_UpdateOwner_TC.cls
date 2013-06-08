/*===========================================================================+
|  HISTORY                                                                   
| 
|  DATE       DEVELOPER       WR       DESCRIPTION                                
|
   ====       =========       ==       ===========  
|  05-Apr-2013  Prachi                 Created 
+===========================================================================*/ 
@isTest(SeeAllData = true) 
private class Opp_UpdateOwner_TC {
         public Static List<Account> acctLst = new List<Account>();
         public Static List<Opportunity> lstOpp= new List<Opportunity>();
         public Static List<OAR_Exclusion_Condition__c> lstOarExclusion=new List<OAR_Exclusion_Condition__c>();
         public Static Set<String> setCountry=new Set<String>{'ABC'};
          public Static String strNamedPartnerType='all partners';

         public void createAccount(){   
        for(Integer i=0 ; i<=3 ; i++){   
        Account acctObj = new Account();
        acctObj.Name = 'Pricing Testing'+i;
        acctObj.Synergy_Account_Number__c = '123456'+i;
        acctObj.Coverage_Model__c='B';
        acctObj.Customer_Segment__c='Global';
        acctObj.BillingCountry ='ABC';
        acctObj.BillingState ='ABC';
        acctObj.BillingPostalCode='123';
        acctObj.EMC_CLASSIFICATION__c='Text1';
        acctLst.add(acctObj);   
        }
        Database.insert(acctLst);
        System.debug('Account Created'); 
       
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
          opp_Obj.Partner__c = acctLst[1].id;
          //opp_Obj.Tier_2_Partner__c = acctLst[1].id;
          //opp_Obj.Secondary_Alliance_Partner__c = acctLst[1].id;
          //opp_Obj.Primary_Alliance_Partner__c = acctLst[1].id;
          //opp_Obj.Service_Provider__c= acctLst[1].id;
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
          opp_Obj.Partner__c = acctLst[1].id;
          //opp_Obj.Tier_2_Partner__c = acctLst[1].id;
          //opp_Obj.Secondary_Alliance_Partner__c = acctLst[1].id;
          //opp_Obj.Primary_Alliance_Partner__c = acctLst[1].id;
          //opp_Obj.Service_Provider__c= acctLst[1].id;
         }      
          lstOpp.add(opp_Obj);
        }
       Database.insert(lstOpp);

       lstOpp =[Select Id,Country__c, ownerid , Opportunity_Owner__r.FirstName, Opportunity_Owner__r.LastName,
       AccountId,Opportunity_Owner__r.District__c, Opportunity_Owner__r.Country__c,Opportunity_Owner__r.Name,Account.EMC_CLASSIFICATION__c,
       Opportunity_Owner__r.Area__c, Opportunity_Owner__r.Theater__c,Opportunity_Owner__r.State, Sales_Force__c,Opportunity_Owner__r.region__c,
       Partner__c,Partner__r.Name,Partner__r.Grouping__c,Partner__r.Master_Grouping__c,Tier_2_Partner__r.Name, Tier_2_Partner__c,Tier_2_Partner__r.Grouping__c,Tier_2_Partner__r.Master_Grouping__c,
       Tier_2_Partner_from_Deal_Reg__c,Opportunity_Owner__r.Division__c,Primary_Alliance_Partner__c,Primary_Alliance_Partner__r.Grouping__c,Primary_Alliance_Partner__r.Master_Grouping__c,
       Secondary_Alliance_Partner__c,Secondary_Alliance_Partner__r.Grouping__c,Secondary_Alliance_Partner__r.Master_Grouping__c,
       Account.Coverage_Model__c,Account.EMC_Major_Vertical__c,Account.Customer_Segment__c, Account.Theater1__c,
       Service_Provider__c,Service_Provider__r.Grouping__c,Service_Provider__r.Master_Grouping__c, Account.BillingState,Account.BillingPostalCode, Account.Grouping__c, Account.BillingCountry, CurrencyIsoCode,
       (Select OpportunityAccessLevel, OpportunityId, TeamMemberRole, UserId From OpportunityTeamMembers),
       (Select Id, OpportunityId, PricebookEntryId,UnitPrice, PricebookEntry.Product2Id, Quote_Amount__c, Product_Type__c From OpportunityLineItems)
       From Opportunity where id in:lstOpp];

       System.debug('lstOpp--->' + lstOpp.size() + lstOpp);
    }
    
    static testMethod void Opp_UpdateOwner(){
    
    Test.StartTest();
     Opp_UpdateOwner_TC objTC= new Opp_UpdateOwner_TC();
     objTC.createAccount();

        acctLst = [Select ID,Synergy_Account_Number__c,EMC_Major_Vertical__c,IsPartner,RecordTypeid,Lead_Oppty_Enabled__c,Partner_Type__c  from Account where id in: acctLst];
    
    Recordtype rt = [SELECT Name, NamespacePrefix, Id, DeveloperName FROM RecordType where SobjectType = 'Account' and DeveloperName = 'Distributor_Partner_Account_Record_Type' limit 1];

      for(Integer acc=0 ; acc<acctLst.size() ; acc++){
            
             acctLst[acc].IsPartner = true;

            
            acctLst[acc].Lead_Oppty_Enabled__c = true;
            acctLst[acc].Partner_Type__c = 'Direct Reseller';
            acctLst[acc].PROFILED_ACCOUNT_FLAG__c=TRUE;
            
         }
         update acctLst;
         List<User> lstUser = [Select id from user where IsActive = true and Theater__c in ('APJ')limit 4];
     Opportunity_Assignment_Rule__c objOAR= new Opportunity_Assignment_Rule__c();
     objOAR.Resource_Opportunity_Sales_Team_Role__c='Channel-District Manager';
     objOAR.Resource_Sales_Force__c='EMC';
     objOAR.Apply_to_House_Account__c=true;
     objOAR.Active__c=true;
     objOAR.Resource_Name__c=lstUser[0].id;
     objOAR.Overwrite_the_Account_Owner__c=true;
     objOAR.ResourceCountry__c='ABC';
     objOAR.Partner_Type__c='All Partners';
     objOAR.Zip_Postal_Code_List__c='test,123,zip';
     objOAR.ResourceState__c='ABC';
     
    
     //objCon.Exclusion_Value__c='exclusion';       
     Database.insert(objOAR);

    //Creating Grouping Record

         Account_Groupings__c grpObj = new Account_Groupings__c();
             grpObj.Profiled_Account__c = acctLst[3].id;

         insert grpObj;

    //End of Grouping 

    List<OAR_Exclusion_Condition__c> lstCon = new List<OAR_Exclusion_Condition__c>();
    
    for(Integer con=0 ; con<=2 ; con++){
         OAR_Exclusion_Condition__c objCon = new OAR_Exclusion_Condition__c();

     objCon.Opportunity_Assignment_Rule_del__c=objOAR.id;
     if(con==0)
     objCon.OAR_Field_API_Name__c ='area__c';
         if(con==1)
     objCon.OAR_Field_API_Name__c ='BillingPostalCode';
             if(con==2)
     objCon.OAR_Field_API_Name__c ='Tier_2_Partner_from_Deal_Reg__c';
     objCon.Name = 'Testing OAR Condition';
     objCon.Exclusion_Value__c = 'this,is,mytest,exlusion';
     objCon.Partner_Grouping_Excluded__c= grpObj.id;
     lstCon.add(objCon);


    }
    
      insert lstCon;
        /*acctLst = [Select ID,Synergy_Account_Number__c,IsPartner,RecordType.name,Lead_Oppty_Enabled__c  from Account where id in: acctLst];

          for(Integer acc1=0 ; acc1<acctLst.size() ; acc1++){
            
             acctLst[acc1].RecordTypeid = rt.id;

            
    
            
         }
         update acctLst;
*/
        System.debug('acctLst------>'+acctLst);
    
     objTC.createOpportunity();


     Opp_UpdateOwner objUpd=new Opp_UpdateOwner();
     Map<Id,Opportunity_Assignment_Rule__c> mapOAR= new Map<Id,Opportunity_Assignment_Rule__c>();
     Map<Id,Opportunity_Assignment_Rule__c> mapResult= new Map<Id,Opportunity_Assignment_Rule__c>();
     Map<Id,Opportunity> mapOppty= new Map<Id,Opportunity>();
     mapOppty.put(lstOpp[0].id,lstOpp[0]);
     mapOppty.put(lstOpp[1].id,lstOpp[1]);
     mapOAR.put(objOAR.id,objOAR);
     System.debug('mapOAR----'+mapOAR);
     mapResult=objUpd.updateAccountOwner(mapOppty,mapOAR); 
     Opp_UpdateOwner.processExclusionFound(lstOarExclusion,lstOpp[0],acctLst[0]);
    Test.StopTest();
}
}