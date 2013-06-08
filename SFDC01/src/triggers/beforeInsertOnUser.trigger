/*===========================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 05/10/2010     Ashwini Gowda         Def#125     This trigger is used to
                                                    Populate the Contact Id associated
                                                    to a Partner User. | 
 +===========================================================================*/
trigger beforeInsertOnUser on User (before insert) {
    PRM_ContactUserSynchronization userSynchronization = new PRM_ContactUserSynchronization();
    List<User> PartnerUsers = new List<User>();
    for(User user:Trigger.New){
        if(user.IsActive && user.UserType=='PowerPartner')
        PartnerUsers.add(user);
    }
    if(PartnerUsers.size()>0){
        userSynchronization.populatePartnerContactOnUser(PartnerUsers);
    }
}