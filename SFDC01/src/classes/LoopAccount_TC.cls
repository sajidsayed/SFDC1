@isTest 
private class LoopAccount_TC {


	 private static testmethod void runTest1()
	{
		
		String adminUserProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		
		User adminUser = createNewUser(adminUserProfileId);
		
		test.startTest();
		System.RunAs(adminUser)
		{
			LoopAccount obj = new LoopAccount();
			obj.dummyMethod();
		}
		test.stopTest();
		
	}
	
	private static User createNewUser(String profileId) {
        return returnUser(profileId);    
    }
    
    
    private static User returnUser(String profilesId) {
        User testUser = [Select Alias,email,lastname,username,ProfileId,BU__c, Employee_Number__c from User where ProfileId=:profilesId and IsActive =true limit 1];       
        return testUser;    
    }
	
	
}