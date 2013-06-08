@isTest (SeeAllData = true)
private class AP_Customer_Profiling_Account_Distric_TC 
{
	static testMethod void test()
	{
		AP_Customer_Profiling_Account_District testObj = new AP_Customer_Profiling_Account_District();
		System.debug('Check map value size:'+  testObj.mapDataValueMap.isEmpty());
		System.debug('value associated with house account:'+testObj.mapDataValueMap.get('House Account For AP Exclusion').DataValue__c);
		Util.isTestCoverage = true;
		Database.executeBatch(testObj);
		
		
		
		
		
	}
}