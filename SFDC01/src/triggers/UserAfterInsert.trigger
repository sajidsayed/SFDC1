/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 07/10/2010     Karthik Shivprakash      --       This trigger will handle 
                                                    only user after insert
 |                                                  event. 
 
 | 18/10/2010     Arif                     1436     Method 'createAccountShare'
                                                    and 'updateContact'is restricted to
 |                                                  call for Partner User only for 
                                                    avoiding Future call within Future call
 |                                                  exception. 
 
 | 26/10/2010    Arif                      1436     Changed the logic of Identifying Partner
                                                    User by adding Profile.UserLicence.Name 
                                                    
 | 02/01/2012   Accenture              Added method to create Queue    
 
 | 22-Feb-12    Leonard V                            Restirct execution of code for Users 
                                                     having Chatter free licence  
                                                     
 |05-Apr-12    Leonard V                            Changed Execution logic for Chatter free user 
                                                      
 +===========================================================================*/
trigger UserAfterInsert on User (after insert) {

  
  
  Set<Id> chatterFreeProfSet = new Set<Id>();
 
	 Map<Id,User> mapNotChatterUsers = new Map<Id,User>();
	
	//Added for Chatter Free User Restriction
        				
        			Map<String,Presales_ChatterFree__c> mapChatterProfId = Presales_ChatterFree__c.getall();
					
					for(Presales_ChatterFree__c chatFree : mapChatterProfId.values()){
						chatterFreeProfSet.add(chatFree.Profile_Id__c);
					}
        			
        			for (User usr : Trigger.new){
        				if(!(chatterFreeProfSet.contains(usr.ProfileId))){
        					mapNotChatterUsers.put(usr.id,usr);
        				}
        			}
        			
        			//End Of Chatter Free 

 
 
    PRM_ContactUserSynchronization contactSync = new PRM_ContactUserSynchronization();     
    PRM_PartnerUserGroup Obj = new PRM_PartnerUserGroup();
    set<string> setAccountIdsToCreateQueue = new set<string>();
    Map<Id,User> mapPartnerUsers = new Map<Id,User>();
    Set<Id> partnerUserId = new Set<Id>();
    if(Trigger.isInsert)
    {
        //used to add the users on group based on their profiles on update
//        Obj.createUserGroupOnNew(Trigger.newMap);
        Obj.createUserGroupOnNew(mapNotChatterUsers);
        //used to creat sharing on account during the update of profile to 
        //super user profiles.
        
        //added by Arif(changed the logic)(1436)
        for(User user:[Select Profile.UserLicense.Name,Id
                       from user where Profile.UserLicense.Name = 'Gold Partner' 
                       and Id in:Trigger.newMap.Keyset()]){
           partnerUserId.add(user.Id);             
        }
        if(partnerUserId.size()>0){ 
            for(Id user:partnerUserId){
                if(user == Trigger.newMap.get(user).Id){ 
                    mapPartnerUsers.put(user,Trigger.newMap.get(user));   
                }
            }
             
        } 
        //till this part      
        if(mapPartnerUsers.size()>0){              
            PRM_AccountVisibitlity.createAccountShare(mapPartnerUsers.keyset());
            //This is used to call the updateContact method of PRM_ContactUserSynchronization
            //and pass the New Map and null Map to it.
            contactSync.updateContact(mapPartnerUsers,null);            
        }    
    }


   // for(User userObj :trigger.new){
    for(User userObj :mapNotChatterUsers.values()){
        if(userObj.UserType=='PowerPartner' && userObj.AccountId!=null ){
           setAccountIdsToCreateQueue.add(userObj.AccountId);
        }
    }
    if(setAccountIdsToCreateQueue.size()>0){
       QueueHelper.generateQueueNamesToCreateQueue(setAccountIdsToCreateQueue);
       QueueHelper.QueueCreationExecuted=false;
    }
    
}