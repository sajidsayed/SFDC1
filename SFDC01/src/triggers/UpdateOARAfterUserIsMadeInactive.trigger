/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE        DEVELOPER     DESCRIPTION                               
 |  ====        =========     =========== 
 | 22.12.2011   Shipra Misra  Oppty OAR: Trigger when any user record is made inactive.It should Deactivate all the OAR's where these User's are present as Resource.
   15.06.2012   Arif          Insertion and deletion of user from group
+===========================================================================*/

trigger UpdateOARAfterUserIsMadeInactive on User (after update) 
{
    if(util.fromuserattributemapping) return;   
    Set<Id> setUserId= new Set<id>();
    list<User> lstUserToCreateGroupMember = new list<User>();
    map<Id,User> mapUserNew = new map<Id,User>();
    map<Id,User> mapUserOld = new map<Id,User>();
    set<Id> setUserIdforInsertionIntoGroup = new set<Id>();
    set<Id> setUserIdforDeletionFromGroup = new set<Id>();
    for(User userObj:trigger.new)
    {
        User userOld =Trigger.oldMap.get(userObj.Id);
        if((userOld.IsActive !=userObj.IsActive) && (!userObj.IsActive))
        {
            setUserId.add(userObj.id);
        }
        
        //added by Arif
        
        if(userObj.ProfileId != userOld.ProfileId){
            map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
            if(!mapCustomSetting.isEmpty() && mapCustomSetting.containsKey(userOld.ProfileId)){
                mapUserNew.put(userObj.Id,userObj);
                mapUserOld.put(userOld.Id,userOld); 
            }
            if(!mapCustomSetting.isEmpty() && mapCustomSetting.containsKey(userObj.ProfileId) && userObj.isActive){
                lstUserToCreateGroupMember.add(userObj);
            }
            
        } 
        if(userObj.isActive != userOld.isActive){
            map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
            if(userObj.isActive){
                if(!mapCustomSetting.isEmpty() && mapCustomSetting.containsKey(userObj.ProfileId)){
                    setUserIdforInsertionIntoGroup.add(userObj.Id);
                }
            }   
            if(!userObj.isActive){
                if(mapCustomSetting.containsKey(userObj.ProfileId)){
                    setUserIdforDeletionFromGroup.add(userObj.Id);
                }
            } 
        }  
        //ends here 
         if(!mapUserNew.isEmpty() && !mapUserOld.isEmpty()){
            PRM_InsertDeleteGroupMembers obj = new PRM_InsertDeleteGroupMembers();
            obj.deleteGroupMember(mapUserNew,mapUserOld);
        }
        if(lstUserToCreateGroupMember.size()>0){
            PRM_InsertDeleteGroupMembers obj = new PRM_InsertDeleteGroupMembers();
            obj.insertGroupMember(lstUserToCreateGroupMember);
        }
        if(setUserIdforDeletionFromGroup.size()>0){
            PRM_InsertDeleteGroupMembers.deleteGroupMember(setUserIdforDeletionFromGroup);   
        }
        if(setUserIdforInsertionIntoGroup.size()>0){
            PRM_InsertDeleteGroupMembers.insertGroupMember(setUserIdforInsertionIntoGroup );   
        }                             
    }
    if(setUserId.size()>0 && setUserId!=null)
    {
        //updateOARIfUserIsInactive UpdateOAR= NEW updateOARIfUserIsInactive();
        updateOARIfUserIsInactive.deactivateOAR(setUserId);
    }
}