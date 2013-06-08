trigger Presales_afterUpdateOfUserStatus on User (after update) {
    Set<Id> setUser = new Set<Id>();
    Boolean isDelete=false;
    for(User usr:trigger.new){
        if(usr.CurrentStatus!=null && usr.CurrentStatus!=trigger.oldMap.get(usr.Id).CurrentStatus){
            setUser.add(usr.id);
        }
    }
    //Presales_OpportunityReporting obj = new Presales_OpportunityReporting();
    if(setUser.size()>0){
    Presales_OpportunityReporting.mapStatusUpdates(setUser, isDelete);
    }
}