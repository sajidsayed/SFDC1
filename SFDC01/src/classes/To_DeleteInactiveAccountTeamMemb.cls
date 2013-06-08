/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       		DEVELOPER     WR      	DESCRIPTION                               
 |  ====       		=========     ==       	=========== 
 |  13 Dec 2011		Shipra	   	177094		SFA - Remove inactive users from Account Team.
 |  15 OCT 2012		Vivek	   	204934		SFA - Bug Fix for Batch Job that Removes Inactive Account Team Members. 
  +===========================================================================*/
global class To_DeleteInactiveAccountTeamMemb implements Database.Batchable<Sobject> 
{
	public String Query;
	String PROC_EXC='TA_InsertInactiveUser';
	List <EMCException> errors_Lst = new List <EMCException>();
	String UserID = Userinfo.getUserId();
	boolean Flag;
	RunInactiveATbatch__c RIA;	
	
	
	final static String strlmt = ATMLimit__c.getInstance().LimitNumber__c;
	//Main Query
	
	 final static String Default_AccountTeamMember_Query='Select a.AccountAccessLevel, a.AccountId, a.Id, a.LastModifiedDate, a.TeamMemberRole, a.UserId, a.User.IsActive, a.User.LastModifiedDate, a.User.Name from AccountTeamMember a where a.User.IsActive = false LIMIT '+strlmt+'';
	
	
   	global Database.Querylocator start(Database.BatchableContext BC)
	{		
		if(Query==null|| Query.length()==0)
		{
			Query=Default_AccountTeamMember_Query;			
			System.debug('Query----------'+Query);
		}	
		return Database.getQueryLocator(Query);
	}
	global void execute(Database.BatchableContext BC,List<sObject> scope)
	{	
		     system.debug('Testing limit'+ATMLimit__c.getInstance().LimitNumber__c);
		     RIA = RunInactiveATbatch__c.getValues('FlagStatus');
		     if(RIA.StatusFlag__c !=null){
		       Flag = RIA.StatusFlag__c;
		     }
		     system.debug('Flag'+Flag);
		     //Start:Inserting Data into AccountTeamDelete Object
		     try{
			       if (Flag !=false)
			       {   			     
						  Database.SaveResult[] saveResults = null;//This array is used here to get delete results.
						  List<AccountTeamDelete__c> lstATD = new List<AccountTeamDelete__c>();
						  List<AccountTeamMember> objATM = scope;
						  for(AccountTeamMember a:objATM)
						  {
						     AccountTeamDelete__c objATD = new AccountTeamDelete__c();
						     objATD.UserID__c = a.UserId;
						     objATD.AccountID__c = a.AccountId;		    	    
						     lstATD.add(objATD);     
						  }	  
						 	 system.debug('lstATDvvvv'+lstATD);
				       	     saveResults=Database.Insert(lstATD);
				       	     InsertAccntDel(saveResults);
				       	     lstATD.clear();
			       }
		       }
		       catch (Exception Ex){
		       //  for (Integer i = 0; i < Ex.getNumDml(); i++) { System.DmlException  
        			System.debug('---To_DeleteInactiveAccountTeamMemb----'+Ex); 
   				// }
		       } 
		       //End   
       
	}
	public void InsertAccntDel(Database.SaveResult[] SaveResults)
	{
		for(Integer i=0;i<SaveResults.size();i++)
		{
			String dataError='';
			Database.SaveResult result=SaveResults[i];
			if(!result.isSuccess())
			{
				for(Database.Error dr:result.getErrors())
				{
					dataError+=dr.getMessage();	
				}
				errors_Lst.add(new EMCException(dataError,'To_InsertInactiveAccountTeamMemb',new String[] {SaveResults[i].id}));
				EMC_UTILITY.logErrors(errors_Lst);
                errors_Lst.clear();
			}
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{        
		     //WR204934 finally Set to false the statusFlag
		      RIA = RunInactiveATbatch__c.getValues('FlagStatus');
		      if(RIA.StatusFlag__c !=null){
		          RIA.StatusFlag__c = false;
		          update RIA;
		      }
	          system.debug('Flag'+RIA.StatusFlag__c);
	}

}