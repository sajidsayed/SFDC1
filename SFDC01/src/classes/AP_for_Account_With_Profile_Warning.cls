/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
|  30/05/2013       Shipra Misra            255125         SFA - Account Presentation Long Term Maintenance
==============================================================================*/
global class AP_for_Account_With_Profile_Warning implements Database.Batchable<sObject>
{
 
 //Initiate start method.
 global Database.Querylocator start(Database.BatchableContext bc)
 {
 	string query='Select ID, Name, Account_District__c,Account_District__r.name,District_Lookup__c, Customer_Profiled_Account__c, Account_Profiling_Warning_Counts__c From Account WHERE Account_type__c != '+'Partner'+'and Account_District__c != null and Account_Profiling_Warning_Counts__c>0 Order by Account_District__c asc , Customer_Profile_Value__c desc';
 	return Database.getQueryLocator(query);
 }
 //Initiate execute method.
 global void execute(Database.BatchableContext bc, List<sObject> scope)
 {
 	 Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
 	 set<string> setHouseAccountExcluded= new set<String>();
 	 if(mapDataValueMap!= null &&
        mapDataValueMap.get('House Account For AP Exclusion') != null &&
        mapDataValueMap.get('House Account For AP Exclusion').DataValue__c != null)
	 {
        system.debug('#### Entered batch calling area');
        String strHouseAccuontsExcluded = mapDataValueMap.get('House Account For AP Exclusion').DataValue__c;
        for(string s:strHouseAccuontsExcluded.split(','))
        {
        	setHouseAccountExcluded.add(s);
        }
     } 
     //holds List of Account to be updated for Profile Warning.
     List<Account> lstAccountToBeUpdated= new List<Account>();
     set<String> setAccountDistrict= new set<string>();
    //Logic to enlist Account Id involved in custom profiling.
 	 for(SObject sobjects:scope)
     {
     	Account AcDist=(Account)sobjects;
     	if(setAccountDistrict.contains(AcDist.Account_District__c))continue;	
	 	setAccountDistrict.add(AcDist.Account_District__c);
     }
     Map<String, List<Account>> mapAccDistrict= new Map<String, List<Account>>();
     List<Account> lstAccount= new List<Account>([Select id, name, Account_District__c,Customer_Profiled_Account__c,Customer_Profiled_Account_Lookup__c from Account where Account_District__c =:setAccountDistrict and Customer_Profiled_Account__c=:true]);
	 for(Account AcDistrict:lstAccount)
	 {
	 	
	 if(mapAccDistrict.containsKey(AcDistrict.Account_District__c))
            mapAccDistrict.get(AcDistrict.Account_District__c).add(AcDistrict);
        else
        {
            List<Account> temp = new List<Account>();
            temp.add(AcDistrict);
            mapAccDistrict.put(AcDistrict.Account_District__c, temp);
        }
	 }
	  
	 for(SObject sobjects:scope)
     {
     	Account AcDist=(Account)sobjects;
     	List<Account> lstAccCount=mapAccDistrict.get(AcDist.Account_District__c);
     	if(mapAccDistrict.containsKey(AcDist.Account_District__c)  )
     	{
     		if(lstAccCount.size()==1)
     		{
     			Id CustomerProfiled=lstAccCount[0].id;
     			AcDist.Customer_Profiled_Account_Lookup__c=CustomerProfiled;
     			lstAccountToBeUpdated.add(AcDist);
     		}
     	}
     	else if(!mapAccDistrict.containsKey(AcDist.Account_District__c))
     	{
     		AcDist.Customer_Profiled_Account__c=true;
     		List<Account> temp = new List<Account>();
            temp.add(AcDist);
     		lstAccountToBeUpdated.add(AcDist);
     		mapAccDistrict.put(AcDist.Account_District__c,temp);
     	}
     }  	
     	
     
   //Check if list size is greater than 0.
   if(lstAccountToBeUpdated.size()>0)
   {
   	update lstAccountToBeUpdated;
   }
   
 }
 global void finish(Database.BatchableContext BC)
 {
 	
 }
}