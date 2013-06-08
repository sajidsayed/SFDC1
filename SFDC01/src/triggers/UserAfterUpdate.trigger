/*================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 07/10/2010     Karthik Shivprakash      ---      This trigger will handle 
                                                    only user after update event.
                                                    
 | 18/10/2010     Arif                     1436     Method 'createAccountShare'
                                                    and 'updateContact'is restricted to
 |                                                  call for Partner User only for 
                                                    avoiding Future call within Future call
 |                                                  exception.
  29/06/2011     Anirudh                            Updated Code to remove Users from Public Groups
 |                                                  on deactivation and adding them to Groups on activation.
  12/07/2011     Anirudh                            Updated Code to Trigger User's addition or deletion in 
 |                                                  Partner User Groups for Partner Users Only.      
 | 11/08/2011     Prasad                             Updated users goruping method calls       
 | 04/11/2011    PRasad                             Updated logic for disabled users based on IsportalEnabled flag     
 | 06/07/2012    Kaustav                            Changed the if loop condition from OR to AND                                       
 +===========================================================================*/

trigger UserAfterUpdate on User (after update) {
    
    PRM_ContactUserSynchronization contactSync = new PRM_ContactUserSynchronization();
          
    PRM_PartnerUserGroup Obj = new PRM_PartnerUserGroup();
    Map<Id,User> mapNewPartnerUsers = new Map<Id,User>();
    Map<Id,User> mapOldPartnerUsers = new Map<Id,User>();
    Map<Id,User> mapInactiveUsers = new Map<Id,User>();
    Map<Id,User> mapActiveUsers = new Map<Id,User>();
    Map<Id,User> mapDisabledUsers= new Map<Id,User>();
    if(Trigger.isUpdate)
    {
        //used to creat sharing on account during the update of profile to 
        //super user profiles.
        //WR 1436
        for(User user:Trigger.newMap.values()){
            
            // partner user disabled via active flag or disabled from contact
            //code updated from OR to AND
            if( !user.ISPORTALENABLED && ((Trigger.oldMap.get(user.id).contactId!=null) && user.contactId==null && user.isActive ==false) ){
                mapDisabledUsers.put(user.Id,user);
            }
            
            if(user.ISPORTALENABLED){
                mapNewPartnerUsers.put(user.Id,user);
                mapOldPartnerUsers.put(user.Id,Trigger.oldMap.get(user.Id));
            }
            if(user.ISPORTALENABLED && !user.IsActive && Trigger.oldMap.get(user.id).IsActive != Trigger.newMap.get(user.id).IsActive)
            {
                mapInactiveUsers.put(user.Id,user);             
            }
            if(user.ISPORTALENABLED && user.IsActive && Trigger.oldMap.get(user.id).IsActive != Trigger.newMap.get(user.id).IsActive)
            {
                mapActiveUsers.put(user.Id,user);               
            }
       }
       
       if(mapInactiveUsers.size()>0)
           {
            Obj.deleteProfiledUserGrouping(mapInactiveUsers);            
           }
       if(mapActiveUsers.size()>0)
           {
            Obj.createIndividualUserGrouping(mapActiveUsers);         
           }   
           
        if(mapNewPartnerUsers.size()>0){
            PRM_AccountVisibitlity.createAccountShare(mapNewPartnerUsers.keyset());
            
       } 
           if(mapDisabledUsers.size()>0){
               contactSync.updateContact(mapDisabledUsers,Trigger.oldMap);
            } 
            if(mapNewPartnerUsers.size()>0){
               contactSync.updateContact(mapNewPartnerUsers,mapOldPartnerUsers);
            }    
        //used to add the users on group based on their profiles on update
        Obj.createUserGroupOnUpdate(Trigger.oldMap,Trigger.newMap);
           
    }
}