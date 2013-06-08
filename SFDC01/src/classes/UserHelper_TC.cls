/*=============================================================================
	HISTORY                                                                  
                                                               
	DATE          	DEVELOPER                WR       		DESCRIPTION                               
	====          	=========                ==       		=========== 
	03-Sep-2010		Pratibh Prakash			141883			Test class for UserHelper class.
	12-Jan-2011     Srinivas Nallapati      155951          Modified the class to make "userIds" from set of strings to set of ids    
==============================================================================*/
@isTest
private class UserHelper_TC {
	private static testMethod void testUserHelper(){
		Boolean testFlag;
		Set<id> userIds = new Set<id>();
		userIds.add(UserInfo.getUserId());
		
		//Passing User Ids for retrieving info.
		UserHelper.retrieveUserData(userIds);
		
		//Passing valid User Id
		testFlag = UserHelper.isActiveUserid(UserInfo.getUserId());
		UserHelper.getUserRecord(UserInfo.getUserId());
		
		Set<id> tempSet = new Set<id>();
		tempSet.add(UserInfo.getUserId());
		UserHelper.getUserRecords(tempSet);
		//Passing invalid User Id
		testFlag = UserHelper.isActiveUserid('005Q00000hf00ax');
		testFlag = UserHelper.isActiveUserName('House Account');
		testFlag = UserHelper.isActiveUserName('Test User');
		UserHelper.getUserRecord('005Q00000hf00ax');
		tempSet.add('005Q00000hf00ax');
        UserHelper.getUserRecords(tempSet);
		//Passing valid User Id
		testFlag = UserHelper.isValidUserid(UserInfo.getUserId());
		//Passing invalid User Id
		testFlag = UserHelper.isValidUserid('005Q00000hf00ax');
		testFlag = UserHelper.isValidUserName('House Account');
		testFlag = UserHelper.isValidUserName('Test User');
		//Passing valid User Name
		UserHelper.retrieveUserId('House Account');
		//Passing invalid User Name
		UserHelper.retrieveUserId('Test User');
		
	}
}