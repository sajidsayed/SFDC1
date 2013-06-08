public class AccountBeforeUpdateTrigger {

    static Boolean processAccountUpdatesHasRun = false;
    string Errormessage;
    
    public void beforeUpdate(Account[] oldAccs, Account[] newAccs) {

     if (!processAccountUpdatesHasRun ){

            processAccountUpdatesHasRun = true;
     
     /*****  Start Execute *****/
     list<Id> accIds = new list<Id>();
     map<id,string> partnerType  =  new map<id,string>();
   //  string partnerType ;
     for(Account oldacc: oldAccs){
         for(Account newacc : newAccs){
         
         if(oldAcc.Partner_Type__c != newAcc.Partner_Type__c){
           accIds.add(newAcc.Profiled_Account__c);
           
           partnerType.put(newAcc.Profiled_Account__c,newAcc.Partner_Type__c);
           
         }
         
         }
     }
     
     Account [] profiledAccs = [select id,Partner_Type__c from account where Id in: accIds];
      system.debug('profiledAccs ===>'+profiledAccs +partnerType);
         for(Account a: profiledAccs){
             a.Partner_Type__c = partnerType.get(a.id);
              system.debug('profiledAccs ===>'+partnerType.get(a.id));
         }
     update profiledAccs;    
     }//If Closing
    
    }//Method Closing
    
}//Class Closing