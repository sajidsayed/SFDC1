/*=============================================================================
	HISTORY                                                                  
                                                               
	DATE          	DEVELOPER                WR       		DESCRIPTION                               
	====          	=========                ==       		=========== 
	27-May-2011		Shipra Misra			163358			Added New Field Super Division.
==============================================================================*/

@isTest
private class UA_AttributeOperation_TC{
    
    static testMethod void runDuplicateTests() {
    List<User_Attribute_Mapping__c> newAttributelist=new List<User_Attribute_Mapping__c>();
	User objUser = [Select Id, Name, username, alias, email,lastname,languagelocalekey,profileid,localesidkey,timezonesidkey, UserType, 
	   			emailencodingkey, BU__c, Employee_Number__c, Theater__c,Division__c, District__c, Country__c, IsActive, State, Forecast_Group__c from User where  UserType='Standard' and IsActive=True  limit 1];
	UserRole newRole=new UserRole(Name='Test User Attribute Mapping'); 
	insert newRole; 
    System.runAs(objUser)
    {
	User_Attribute_Mapping__c newAttribute=new User_Attribute_Mapping__c(
                                           Name='CMA AMER',
                                           BU__c='GAM',
                                           Theater__c='APJ',
                                           Super_Division__c='Mid Market',
                                           Division__c='SMB Inside Sales',
                                           Region__c='Italy',
                                           Super_Area__c='MA',
                                           Area__c='China',
                                           District__c='East',
                                           Sales_Role__c='Sales Associate',
                                           Country__c='India',
                                           Forecast_Group__c='Channels'); 
    User_Attribute_Mapping__c newAttribute2=new User_Attribute_Mapping__c(
                                           Name='CMA AMER1',
                                           BU__c='GAM',
                                           Theater__c='APJ',
                                           Super_Division__c='Mid Market',
                                           Division__c='SMB Inside Sales',
                                           Region__c='Italy',
                                           Super_Area__c='MA',
                                           Area__c='China',
                                           District__c='East',
                                           Sales_Role__c='Sales Associate',
                                           Country__c='India',
                                           Forecast_Group__c='Channel'); 
    
    User_Attribute_Mapping__c newAttribute3=new User_Attribute_Mapping__c(
                                           Name='Test User Attribute Mapping',
                                           Theater__c='Global',
                                           Super_Division__c='N/A',
                                           Division__c='N/A',
                                           Region__c='N/A',
                                           Super_Area__c='N/A',
                                           Area__c='N/A',
                                           District__c='N/A',
                                           Country__c='N/A',
                                           Sales_Role__c='N/A',
                                           BU__c='N/A',
                                           Forecast_Group__c='N/A'); 
    
    //list<User_Attribute_Mapping__c> listAttribute=new list<User_Attribute_Mapping__c>([Select Name from User_Attribute_Mapping__c limit 1000]);
    newAttributelist.add(newAttribute);
    newAttributelist.add(newAttribute2);
    newAttributelist.add(newAttribute3);
    AttributeOperation update_user=new AttributeOperation();
    update_user.CheckValidRoleName(newAttributelist);
    util.fromuserattributemapping=true;
    // update_user.UpdateUserFound(newAttributelist);
    update_user.fetchUsers(newAttributelist);
    insert newAttribute3;
    delete newAttribute3;
    }
    }

}