/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    03-Sep-2010     Pratibh Prakash         141883          This apex class is helper class which will retrieve information of all 
                                                            the user records that could be used in the code without querying user info again.
                                                            
    12-Jan-2011     Srinivas Nallapati      155951          Created new map "userNameMap" to hold User name --> User, and changed the userInfo map 
                                                            from map of String-->User to id-->User, Chnaged the methods accordingly                                                                                                             
==============================================================================*/
public class UserHelper {
    private static Map<id, User> userInfo = new Map<id,User>();
    private static Map<String,User> userNameMap = new Map<String,User>(); 
    
    /*
    Method to retrieve the User information.
    @param userIds: Set of User ids for which information is to be retrieved
    */
    public static void retrieveUserData(Set<id> userIds)
    {
        for(User usr: [Select Username, UserType, UserRoleId, Title, Theater__c, SFDC_User_ID__c, Role__c, Region__c, Profile_Name__c, ProfileId, Opportunity_Re_Open_Permission__c, Name,
                                Manual_Opportunity_Booking_Permission__c, Manager__c, ManagerId, IsActive, Id, Forecast_Group__c, Employee_Number__c, Email, Division__c, District__c, Country__c, Country, BU__c, Allow_Mass_Reassignment__c from User where Id in: userIds or Name='Renewals Rep Maintenance' or Name='House Account'])
        {
            userNameMap.put(usr.Name,usr);
            userInfo.put(usr.Id,usr);
        }
    }
    
    public static void retrieveUserData(Set<string> userIds)
    {
        for(User usr: [Select Username, UserType, UserRoleId, Title, Theater__c, SFDC_User_ID__c, Role__c, Region__c, Profile_Name__c, ProfileId, Opportunity_Re_Open_Permission__c, Name,
                                Manual_Opportunity_Booking_Permission__c, Manager__c, ManagerId, IsActive, Id, Forecast_Group__c, Employee_Number__c, Email, Division__c, District__c, Country__c, Country, BU__c, Allow_Mass_Reassignment__c from User where Id in: userIds or Name='Renewals Rep Maintenance' or Name='House Account'])
        {
            userNameMap.put(usr.Name,usr);
            userInfo.put(usr.Id,usr);
        }
    }
    
    /*
    12-Jan-2011     Srinivas Nallapati      WR-155951
    Method to retrieve the User information by name.
    @param userName: Name of the User
    */
    public static void retrieveUserDataFromNames(set<String> userNames)
    {
        for(User usr: [Select Username, UserType, UserRoleId, Title, Theater__c, SFDC_User_ID__c, Role__c, Region__c, Profile_Name__c, ProfileId, Opportunity_Re_Open_Permission__c, Name,
                                Manual_Opportunity_Booking_Permission__c, Manager__c, ManagerId, IsActive, Id, Forecast_Group__c, Employee_Number__c, Email, Division__c, District__c, Country__c, Country, BU__c, Allow_Mass_Reassignment__c from User where Name in: userNames or Name='Renewals Rep Maintenance' or Name='House Account'])
        {
            userNameMap.put(usr.Name,usr);
            userInfo.put(usr.Id,usr);
        }
    }

    
    /*
    Method return true/false depending on user is active or inactive.
    @param userRecordId: User record Id for which info is required.
    */
    public static Boolean isActiveUserId(id userRecordId)
    {
        if(userInfo.size() < 1 || userInfo.get(userRecordId) == null)
        {
            Set<id> userIds = new Set<id>();
            userIds.add(userRecordId);
            retrieveUserData(userIds);
        }

        if(userInfo.get(userRecordId) != null)
        {
            return userInfo.get(userRecordId).IsActive;
        }
        else
        {
            return false;
        }
    }
    public static Boolean isActiveUserName(String userName)
    {
        if(userNameMap.size() < 1 || userNameMap.get(userName) == null)
        {
            Set<String> userNames = new Set<String>();
            userNames.add(userName);
            retrieveUserDataFromNames(userNames);
        }

        if(userNameMap.get(userName) != null)
        {
            return userNameMap.get(userName).IsActive;
        }
        else
        {
            return false;
        }
    }
    
    /*
    Method return true/false depending on userRecordId passed is valid/invalid.
    @param userRecordId: User record Id for which info is required.
    */
    public static Boolean isValidUserId(id userRecordId)
    {
        if(userInfo.size() < 1 || userInfo.get(userRecordId) == null)
        {
            Set<id> userIds = new Set<id>();
            userIds.add(userRecordId);
            retrieveUserData(userIds);
        }

        if(userInfo.get(userRecordId) != null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public static Boolean isValidUserName(String userName)
    {
        if(userNameMap.size() < 1 || userNameMap.get(userName) == null)
        {
            Set<String> userNames = new Set<String>();
            userNames.add(userName);
            retrieveUserDataFromNames(userNames);
        }

        if(userNameMap.get(userName) != null)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /*
    Method return User Record depending on userRecordId passed is valid/invalid.
    @param userRecordId: User record Id for which info is required.
    */
    public static User getUserRecord(id userRecordId)
    {
        if(userInfo.size() < 1 || userInfo.get(userRecordId) == null)
        {
            Set<id> userIds = new Set<id>();
            userIds.add(userRecordId);
            retrieveUserData(userIds);
        }

        if(userInfo.get(userRecordId) != null)
        {
            return userInfo.get(userRecordId);
        }
        return null;
    }

    /*
    Method return Map of User Records depending on userIds passed
    @param userIds: User record Ids for which info is required.
    */
    public static Map<Id,User> getUserRecords(Set<id> userIds)
    {
        Map<id, User> users = new Map<id,User>();
        system.debug(userInfo.keyset().containsAll(userIds));
        if(userInfo.keyset().containsAll(userIds) == false)
        {
            /*//.debug();
            set<id> existingIds = userIds.clone();
            existingIds.retainAll(userInfo.keyset());
            system.debug('existingIds'+existingIds);
            set<id> newIds = userIds.clone();
            newIds.removeAll(existingIds);
            system.debug('newIds'+newIds);*/
            retrieveUserData(userIds);
        }
        system.debug('userIds'+userIds);
        for(id i : userIds )
        {
            if(userInfo.get(i) != null)
              users.put(i, userInfo.get(i));
        }
              
        return users;
    }

    
    /*
    Method return user record Id of User corresponding to Full Name passes to the method.
    @param name: User record FullName
    */
    public static Id retrieveUserId(String name)
    {
        if(userNameMap.size() < 1 || userNameMap.get(name) == null)
        {
            Set<String> userNames = new Set<String>();
            userNames.add(name);
            retrieveUserDataFromNames(userNames);
        }
        
        if(userNameMap.get(name) != null)
        {
            return userNameMap.get(name).Id;
        }
        else
        {
            return null;
        }
    }
}