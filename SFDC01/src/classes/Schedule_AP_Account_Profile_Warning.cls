global class Schedule_AP_Account_Profile_Warning 
{
	public boolean isRunTest=false;
	global void execute(SchedulableContext sc)
	{
		string query='Select ID, Name, Account_District__c,Account_District__r.name,District_Lookup__c, Customer_Profiled_Account__c, Account_Profiling_Warning_Counts__c From Account WHERE type != '+'Partner'+'and Account_District__c != null Order by Account_District__c asc , Customer_Profile_Value__c desc) ';
		AP_for_Account_With_Profile_Warning clsBatchAccWarn = new AP_for_Account_With_Profile_Warning();
		ID idBatch = Database.executeBatch(clsBatchAccWarn, 100);
	}
}