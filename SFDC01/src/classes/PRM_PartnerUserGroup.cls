/*===================================================================================================+

 |  HISTORY  |                                                                           

 |  DATE          DEVELOPER                WR       DESCRIPTION                               

 |  ====          =========                ==       =========== 

 | 03/8/2010     Karthik Shivprakash     141590    This class add the users into Public 
                                                   Groups based on the user proflies.
 | 24/09/2010    Prasad Kothawade        1133      Error was occuring on production 
                                                   while changing the profile of user.
 |                                                 Catching the exception and showing 
                                                   custom message to retry. 
  20/06/2011     Anirudh Singh                     Updated CheckGroupingForUser Method
 |                                                 to fetch the Public Groups from Custom Setting
                                                   for the newly Created Partner Profiles
 |                                                 and add them to their respective Public Groups.    
  11/08/2011     Prasad                             Updated users goruping method logics - 
                                                   Parntner user - create user group and add on profile
                                                   PRM User - create only user group
                                                               
 +===================================================================================================*/
 
public class PRM_PartnerUserGroup{

/* @Method <This method is used to add the users into Public Groups when the user profile is changed>.
   @param <This is taking 2 parameter trigger.newMap and trigger.OldMap>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    public void createUserGroupOnUpdate(Map<Id,User> olduserMap,Map<Id,User> newuserMap){
        List<User> newUserList = new List<User>();
        System.debug('List of new user from trigger'+newUserList);
        
        List<User> oldUserList = new List<User>();
        System.debug('List of old user from trigger'+oldUserList);
        Map<Id,User> insertUserGroups = new Map<Id,User>();
        Map<Id,User> deleteUserGroups = new Map<Id,User>();
        for(User u:newuserMap.values()){
            System.debug('user Profile check ');
            System.debug('olduserMap.get(u.Id).ProfileId '+olduserMap.get(u.Id).ProfileId);
            System.debug('u.ProfileId '+u.ProfileId);
            if(olduserMap.get(u.Id).ProfileId!=u.ProfileId){
                System.debug('user Profile checking ');
                newUserList.add(u);
                oldUserList.add(olduserMap.get(u.id));
            }
        }
        try{
            
            if( oldUserList.size()>0){
                deleteUserGroups=checkProfileGroupingForUser(oldUserList);
                deleteProfiledUserGrouping(deleteUserGroups);
            }
            if(newUserList.size()>0 ){
                
                insertUserGroups=checkProfileGroupingForUser(newUserList);
                createProfiledUserGrouping(insertUserGroups);
            }
            // WR 1133 - The exception was occuring because group table gets locked by any DML operation.
        }catch(Exception e){
            for(User user:newuserMap.values()){
                user.addError(System.label.Error_Message);
            }
        }
    }

/* @Method <This method is used to add the users into Public Groups when the new user is inserted>.
   @param <This is taking only one parameter trigger.newMap>
   @return <void> - <Not Returning anything>
   @throws exception - <No Exception>
*/
    
    public void createUserGroupOnNew(Map<Id,User> newuserMap){
              
        if(newuserMap.size()>0){
            createIndividualUserGrouping(newuserMap);
            
        }
       
        Map<Id,User> ProfiledUserList=checkProfileGroupingForUser(newuserMap.values());
        if(ProfiledUserList.size()>0){
             createProfiledUserGrouping(ProfiledUserList);
        }
    }

/* @Method <This method is used to add the check the to which public group the user should belong>.
   @param <This is taking only one parameter list of users>
   @return <List<User>> - <Returning list of user>
   @throws exception - <No Exception>
*/

    public Map<Id,User> checkProfileGroupingForUser(List<User> usersList){
        Map<String,User__c> profile = User__c.getall();
        Map<Id,User> userGroupList = new Map<Id,User>();
        Profiles__c profiles = Profiles__c.getInstance();
        string trimProfileName;
        System.debug('Before For loop in class');
        for(User userObj: usersList){
            if(userObj.Profile_Name__c.length()>39){
            trimProfileName= userObj.Profile_Name__c.substring(0,39);
            System.Debug('TrimProfielName--->' +trimProfileName);
            }
            else{
                trimProfileName= userObj.Profile_Name__c;
            }
        System.debug('User Profile'+userObj.profileId);
        System.debug('Profile EMC Grouping Admin'+profiles.EMC_Grouping_Administrator__c);
        System.debug('After for loop in class');
        System.Debug('iF cONDITION cHECK--->' +profile.containskey(trimProfileName));
            if(profile.containskey(trimProfileName)){
               userGroupList.put(userObj.Id,userObj);            
            }
        }
        return userGroupList;
    }

/* @Method <This method is used to add the users into public groups based on their profiles>.
   @param <This is taking only one parameter list of users>
   @return <void> - <Not returning anything>
   @throws exception - <No Exception>
*/
    
    public void createProfiledUserGrouping(Map<Id,User> addUserList){
        System.debug('creation of the users'+addUserList);
        List<GroupMember> groupCreateList = new List<GroupMember>();
        Profiles__c profiles = Profiles__c.getInstance();
        Map<String,User__c> profile = User__c.getall();
        for(User usr: addUserList.values()){
            if(usr.profileId == profiles.EMC_Contract_and_Grouping_Administrator__c){
                groupCreateList.add(new GroupMember(GroupId=profile.get('EMC Contract and Grouping Admin').Group_Id__c,UserOrGroupId=usr.Id));
            }
            else{
                System.debug('profile.get(usr.Profile_Name__c)---->'+usr.Profile_Name__c);
                System.debug('profile.get(usr.Profile_Name__c)---->'+profile.get(usr.Profile_Name__c));
                groupCreateList.add(new GroupMember(GroupId=profile.get(usr.Profile_Name__c).Group_Id__c,UserOrGroupId=usr.Id));

            }
        }
        if(groupCreateList.size()>0){
            insert groupCreateList;
        }
    }

/* @Method <This method is used to add the users into public groups based on their profiles>.
   @param <This is taking only one parameter list of users>
   @return <void> - <Not returning anything>
   @throws exception - <No Exception>
*/
    
    public void createIndividualUserGrouping(Map<Id,User> addUserList){
        System.debug('creation of the users'+addUserList);
        List<Group> UserGroupToInsert =  new List<Group>();
        List<GroupMember> GroupMemberList= new List<GroupMember>();
        for(User usr: addUserList.values()){
           System.debug('usr.Name '+usr.Name);
           UserGroupToInsert.add(new group(name=usr.FirstName+' '+usr.LastName));    
        }
        if(UserGroupToInsert.size()>0){
            insert UserGroupToInsert;
        }
        System.debug(UserGroupToInsert);
        Map<String,ID >GroupMap = new Map<String,ID >();
        for( Group grp: UserGroupToInsert){
            GroupMap.put(grp.name,grp.Id);
        }
        for(User usr: addUserList.values()){
                GroupMemberList.add(new GroupMember(groupId=GroupMap.get(usr.FirstName+' '+usr.LastName),UserOrGroupId=usr.Id));
        }
        
        if(GroupMemberList.size()>0){
            insert GroupMemberList;
        }
    }
/* @Method <This method is used to remove the users from public groups based on their profiles>.
   @param <This is taking only one parameter list of users>
   @return <void> - <Not returning anything>
   @throws exception - <No Exception>
*/
    
    public void deleteProfiledUserGrouping(Map<Id,User> deleteUserList){
        System.debug('Deletion of the userList'+deleteUserList);
        List<GroupMember> groupDeleteList = new List<GroupMember>();
        Map<Id,User> userMap = new Map<Id,User>();
        Profiles__c profiles = Profiles__c.getInstance();
        Map<String,User__c> profile = User__c.getall();
        List<String> lstProfileName = new List<String>();
        for(User usr: deleteUserList.values()){
            userMap.put(usr.id,usr);
            lstProfileName.add(usr.Profile_Name__c);
            System.debug('lstProfileName--->' +lstProfileName);
        }
        groupDeleteList = [select id,GroupId from GroupMember where UserOrGroupId in :userMap.keySet() and Group.Name like :lstProfileName];
        
        System.debug('groupDeleteList---->'+groupDeleteList.size());
        if(groupDeleteList.size()>0){
            delete groupDeleteList;
        }
    }
    
}