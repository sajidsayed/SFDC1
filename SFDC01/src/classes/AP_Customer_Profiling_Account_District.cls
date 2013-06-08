/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
|  28/05/2013       Shipra Misra            255125         SFA - Account Presentation Long Term Maintenance
==============================================================================*/
global class AP_Customer_Profiling_Account_District implements Database.Batchable<sObject>
{
 public Map<String,CustomSettingDataValueMap__c> mapDataValueMap = CustomSettingDataValueMap__c.getAll();
 global set<string> setHouseAccountExcluded= new set<String>();
 	        
 global Database.QueryLocator start(Database.BatchableContext BC)
 {
    if(mapDataValueMap!= null &&
	    mapDataValueMap.get('House Account For AP Exclusion') != null &&
	    mapDataValueMap.get('House Account For AP Exclusion').DataValue__c != null )
    {
        System.debug('#### Entered batch calling area');
        String strHouseAccuontsExcluded = mapDataValueMap.get('House Account For AP Exclusion').DataValue__c;
         
        for(string s:strHouseAccuontsExcluded.split(','))
        {
        	setHouseAccountExcluded.add(s);
   
        }
    }  
    if(Util.isTestCoverage)
    {
        return Database.getQueryLocator([Select Account_District__c  From Customer_Profile_Audit_Master__c where Profiled_Account_Total__c>1 limit 2]);
    }
    else
    {
       return Database.getQueryLocator([Select Account_District__c  From Customer_Profile_Audit_Master__c where Profiled_Account_Total__c>1 ]);
    }
 }
 global void execute(Database.BatchableContext BC, List<SObject> scope)
 {
 	List<Account> lstAccUpdate= new List<Account>();
 	system.debug('setHouseAccountExcluded===>'+setHouseAccountExcluded);
 	for(SObject sobjects:scope)
    {
      Integer count=0;
      Id customerProfiledAccount;
      Customer_Profile_Audit_Master__c AccDistrict=(Customer_Profile_Audit_Master__c)sobjects;
      string strAccDistrict=AccDistrict.Account_District__c;
      if(setHouseAccountExcluded.contains(strAccDistrict))return;
      Map<Id,Account> mapAcc=new Map<id,account>([select id, name,Account_District__c,Party_ID__c,Customer_Profiled_Account_Lookup__c, Customer_Profiled_Account__c from account where Account_District__c=:strAccDistrict and Customer_Profiled_Account__c=:true order by Customer_Profile_Value__c Desc ,Party_ID__c Asc ]); 
      system.debug('mapAcc===>'+mapAcc);
      for(Account acc: mapAcc.Values())
      {
      	if(count==0)
      	{
      		customerProfiledAccount=acc.Id;
      	}
      	else if(count>0)
      	{
      		acc.Customer_Profiled_Account_Lookup__c=customerProfiledAccount;
      		acc.Customer_Profiled_Account__c=false;
      		lstAccUpdate.add(acc);
      	}
      	count ++;
      	system.debug('Count==>'+count);
      	
      } 
    }
    if(lstAccUpdate.size()>0)
    {
    	update lstAccUpdate;
    }
 }
 global void finish(Database.BatchableContext BC)
 {
 	
 }
 
 
}