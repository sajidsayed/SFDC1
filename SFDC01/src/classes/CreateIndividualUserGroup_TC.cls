@isTest
private class CreateIndividualUserGroup_TC {  

    static testMethod void createGroup()
    {
        CreateIndividualUserGroup createIndGroup = new CreateIndividualUserGroup();
        List<User> users = [Select Id,Profile_Name__c,ProfileId,FirstName,LastName from User where Profile_Name__c!='System Administrator' and UserType='PowerPartner' Limit 2 ];
        
        //users.add(user);
        CreateIndividualUserGroup.CreateGroup(users);
    }
}