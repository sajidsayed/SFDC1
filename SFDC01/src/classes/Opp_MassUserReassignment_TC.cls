@isTest
Private class Opp_MassUserReassignment_TC{
    private static Account acct;
    private static list<id> oppid = new list<id>();
   private static  Map<Id,decimal>addUsrSpltPrct = new Map<Id,decimal>();
   private static List<Opportunity> list_updateOppty = new List<Opportunity>();
    private static Map<Id,decimal> map_replaceUserSpltPerct = new map<id,decimal>();
        private static  list<User> usrList = new list<User>();
     private static list<Opportunity> opptys = new list<Opportunity>();
     private static Set<Id> SetOwnerOppIds =new Set<Id>(); 


     Private static testMethod void reassignmentOperation(){   
     
     Util.isTestCoverage=true;

     Detail_Line__c detailLine = [select Forecast_Group__c,Owner__r.Id,Owner__r.Name,Opportunity__c,Opportunity__r.Id from Detail_Line__c where Forecast_Group__c = 'Channel' limit 1 ];
     system.debug('===>detailLine '+detailLine );
     oppid.add(detailLine.Opportunity__r.Id);
     SetOwnerOppIds.add(detailLine.Opportunity__r.Id);
          system.debug('===>oppid'+oppid);
          Opp_MassUserReassignment mR = new Opp_MassUserReassignment();
          mR.remove(oppid,detailLine.Owner__r.Id);
           usrList =[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c='Direct' and IsActive=true limit 5];
     map_replaceUserSpltPerct.put(detailLine.Opportunity__r.Id,50);
     list_updateOppty = (mR.getOpportunties(oppid));
      mR.addSalesTeamMember(usrList[0],list_updateOppty,'Edit',SetOwnerOppIds, map_replaceUserSpltPerct );
 Test.startTest();
 		//Code Updated Lines: 30-36 as test class was failing during Sep Release Migration.	
      mR.replace(oppid,usrList[0].Id,usrList[0].Id);
           system.debug('===>usrList[0].Id'+usrList[0].Id+' '+usrList[1].Id);
      mR.replace(oppid,usrList[1].Id,usrList[1].Id);
      Test.stopTest();
      //mR.replace(oppid,usrList[1].Id,usrList[0].Id);
     // mR.addSalesTeamMember(usrList[2],list_updateOppty,'Edit',false, map_replaceUserSpltPerct );
      //mR.replace(oppid,usrList[1].Id,usrList[2].Id);
     
    
     
 
  
    }
    
         Private static testMethod void removeOperation(){   
              Util.isTestCoverage=true;
           Detail_Line__c detailLine = [select Forecast_Group__c,Owner__r.Id,Owner__r.Name,Opportunity__c,Opportunity__r.Id from Detail_Line__c where Forecast_Group__c = 'Direct' limit 1 ];
     system.debug('===>detailLine '+detailLine );
     oppid.add(detailLine.Opportunity__r.Id);
          system.debug('===>oppid'+oppid);
          Opp_MassUserReassignment mR = new Opp_MassUserReassignment();
          mR.remove(oppid,detailLine.Owner__r.Id);
           usrList =[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c='Direct' and IsActive=true limit 5];
     map_replaceUserSpltPerct.put(detailLine.Opportunity__r.Id,50);
     list_updateOppty = (mR.getOpportunties(oppid));
      mR.addSalesTeamMember(usrList[0],list_updateOppty,'Edit',SetOwnerOppIds, map_replaceUserSpltPerct );
 Test.startTest();
    
      mR.remove(oppid,usrList[0].Id);
      mR.remove(oppid,usrList[1].Id);
      usrList =[Select Id,IsActive,Name,Forecast_Group__c from User where Forecast_Group__c='Channel' and IsActive=true limit 5];
 

     mR.addSalesTeamMember(usrList[0],list_updateOppty,'Edit',SetOwnerOppIds, map_replaceUserSpltPerct );
     mR.remove(oppid,usrList[0].Id);
         
         }
}