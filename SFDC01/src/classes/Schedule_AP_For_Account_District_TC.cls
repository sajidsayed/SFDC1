@isTest
private class Schedule_AP_For_Account_District_TC
{
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	
	
	private static testMethod void myTest()
	{	
		Test.startTest();
		
			String jobId = System.schedule('firstTest', CRON_EXP, new Schedule_AP_For_Account_District());
		
		
		Test.stopTest();
	}

}