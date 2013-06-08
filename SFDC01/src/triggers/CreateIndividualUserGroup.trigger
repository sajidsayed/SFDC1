trigger CreateIndividualUserGroup on User (after insert) {

    //Apex class called to create User Grops and Group Members
    //User CheckUser=[Select id from User where id=:'00570000001JNZ9'];
    list<User> lstUserToCreateGroupMember = new list<User>();
    System.debug('UserInfo.getUserId()***'+UserInfo.getUserId());
    if(!(UserInfo.getUserId().contains('00570000001JNZ9')))
    
    {
        CreateIndividualUserGroup.CreateGroup(Trigger.New);
    }
    for(User userNew:trigger.new){
        map<string,ProfilesAndGroups__c> mapCustomSetting = ProfilesAndGroups__c.getall();
        if(!mapCustomSetting.isEmpty() && mapCustomSetting.containsKey(userNew.ProfileId)&& userNew.isActive){
            lstUserToCreateGroupMember.add(userNew);
        }      
    }
    if(lstUserToCreateGroupMember.size()>0){
        PRM_InsertDeleteGroupMembers obj = new PRM_InsertDeleteGroupMembers();
        obj.insertGroupMember(lstUserToCreateGroupMember);
    }    
}