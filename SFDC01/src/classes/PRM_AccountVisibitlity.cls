/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 19/7/2010      Prasad Kothawade        141590    This is class is used to provide the account share access for the user.
 
 | 02/08/2010     Karthik Shivprakash     Defect#66 Adding one more profile Id to provide access share on account.  
  
 | 15/09/2011     Anirudh Singh           WR3826    Updated CreateAccountShare Method to create sharing for all the 
                                                    super user Profiles
 | 09/01/2012    Accenture                183430    Updated Code to invoke createAccountShareforGroup() in order to create sharing
 |                                                   if the Profiled Account is getting Rating Eligible or if a New Account Is Added in Grouping.
 | 17 Feb 2012   Arif                                Modified the query to include active users in createAccountShare method.                                                      
 +===========================================================================*/


public class PRM_AccountVisibitlity {

/* @Method <This method is used to create the sharing access on account>.
   @param <This is method is taking only on parameter set of ID's>
   <Set<Id> -- Which contains user ID's>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

@future public static void createAccountShare(Set<Id>UserIds){
      // 17 Feb 2012
      List<User> users= [select name,email,isActive,ContactId,profileId,Id from user where Id in :UserIds and isActive = true];
      Map<String,CustomSettingDataValueMap__c> DataValueMap= CustomSettingDataValueMap__c.getall();
      string superusers = DataValueMap.get('Super User').DataValue__c+DataValueMap.get('Super User1').DataValue__c;
      /* Profiles__c profiles = Profiles__c.getInstance();
       string superusers= profiles.Tier1_Super_User__c+profiles.Tier2_Super_User__c
                           +profiles.Distributor_Super_User__c+profiles.Non_Reseller_Super_User__c; //Added Non_Reseller_Super_User profile Id to provide access for Defect#66*/
       Map<Id,Id>UserContactMap = new Map<Id,Id>();
       for(user u: users){
           if(superusers.contains(u.profileId) ){ 
                UserContactMap.put(u.id,u.contactId);
           }
       }
       if(UserContactMap.size()==0){
           return;
       }
       Map<Id,Contact> contactMap =new Map<Id,Contact>([select id,AccountId from contact where Id in :UserContactMap.values()]);
       List<AccountShare> accountshare=new List<AccountShare> ();
       for(Id superuserId :UserContactMap.keySet()){
            accountshare.add(new AccountShare(AccountId=contactMap.get(UserContactMap.get(superuserId)).AccountId,
                                   UserOrGroupId=superuserId,
                                   AccountAccessLevel='Edit',
                                   OpportunityAccessLevel='None',
                                   CaseAccessLevel='None'));
       }
       insert accountshare;
   }
   
   
/* @Method <This method is used to create the sharing access on Non Profiled Account>.
   @param <This is method is taking list of Accounts>   
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/

@future public static void createAccountShareforGroup(set<Id> setFromTrigger){
      Group GroupToShareAccount = [Select Id,name from Group where Name like 'TSG Channels%'];
      
      Map<Id,Account> AccountsToShare = new Map<Id,Account>([Select Id,Name,Profiled_Account__c,Profiled_Account_Flag__c from Account
                                                            where (Profiled_Account__c in :setFromTrigger or id in:setFromTrigger) 
                                                            and Profiled_Account__r.Rating_Eligible__c=true and Profiled_Account_Flag__c=false]);
       List<AccountShare> accountshare=new List<AccountShare> ();
       if(AccountsToShare!=null && AccountsToShare.size()>0){
           for(Id accToShareId :AccountsToShare.keySet()){
                accountshare.add(new AccountShare(AccountId=accToShareId,
                                       UserOrGroupId=GroupToShareAccount.Id,
                                       AccountAccessLevel='Edit',
                                       OpportunityAccessLevel='None',
                                       CaseAccessLevel='None'));
           }       
       }
       insert accountshare;
   }   
}