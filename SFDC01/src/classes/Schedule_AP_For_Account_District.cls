global class Schedule_AP_For_Account_District implements schedulable
{
	public boolean isRunTest=false;
	global void execute(SchedulableContext sc)
	{
		string query='Select Account_District__c  From Customer_Profile_Audit_Master__c where Profiled_Account_Total__c>1 ';
	/* 	AP_Customer_Profiling_Account_District schApDistrict = new AP_Customer_Profiling_Account_District(query);
		database.executeBatch(schApDistrict);*/ 
		AP_Customer_Profiling_Account_District clsBatchAccDist = new AP_Customer_Profiling_Account_District();
		ID idBatch = Database.executeBatch(clsBatchAccDist, 100);
	}
}