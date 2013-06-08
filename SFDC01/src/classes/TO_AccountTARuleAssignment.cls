/*
* Created By   :-  Sunil Arora
* Created Date :-  30th Sep,2009 
* Modified By  :-  Sunil Arora
* Modified Date:-  12th Oct,2009
* Modify Reason:-  Updated code as per code review comments.
* Description  :-  This is a batch apex class, used to create/delete Account share records and to update Account fields.

  Modified By   :-   Karthik Shivprakash
  Created Date  :-   18th May,2010
  Modify Reason :-   Update the code for giving the access on account and opportunity for both public and private groups.
  
  Modified By   :-   Karthik
  Modified Date :-   08th June, 2010
  Modify Reason :-   Made case insensitive for the comparison and added condition to check for the billing state for the Defect#686

  Modified By   :-   Sunil
  Modified Date :-   27th September, 2011
  Modify Reason :-   IM7118737 - WR# 176897 - This program was deleting sharings created by other programs as well, fixed to delete sharings for only created by TO (this) program only

  Modified By   :-   Srinivas Nallapati
  Modified Date :-   8th November, 2011
  Modify Reason :-   WR-180005
   
*/
global class TO_AccountTARuleAssignment implements Database.Batchable<SObject> {
    
  //This call is used here to fetch Account records.
   final static String DEFAULT_QUERY = 'Select id,BillingCountry,EMC_Classification__c,TA_Assignment_Rule__c, TA_Assignment_Type__c, BillingState,(Select id,UserOrGroupId from Shares where RowCause=\'Manual\' OR RowCause=\'TA-Top Offenders\')  from Account where (TA_Assignment_Type__c=\'Create\' or TA_Assignment_Type__c=\'Update\') or(TA_Assignment_Type__c=\'Exempt\' and TA_Assignment_Rule__c !=null)';
   //final static String DEFAULT_QUERY = 'Select id,BillingCountry,EMC_Classification__c,TA_Assignment_Rule__c, TA_Assignment_Type__c, BillingState,(Select id,UserOrGroupId from Shares where RowCause=\'Manual\')  from Account where BillingCountry != \'US\' and (TA_Assignment_Type__c=\'Create\' or TA_Assignment_Type__c=\'Update\')';
   public String query;
   
   private final static String EXC_PROCID = 'TO_AccountTARuleAssignment';
   
   final static Integer INT_COLLECTION_LIMIT = 1000;
   public Integer COLLECTION_LIMIT=0; 
   
    List <EMCException> errors_Lst = new List <EMCException>();
   //This method is used here to start context.
   global database.querylocator start(Database.BatchableContext BC) 
   {
        //If the caller has not set the value of query, use the default query
        if(COLLECTION_LIMIT == 0)
            COLLECTION_LIMIT = INT_COLLECTION_LIMIT;
        if (query == null || query.length() == 0)
            { query = DEFAULT_QUERY; }
        return Database.getQueryLocator(query);
   }

    //This method is used here to excecute context.  
    global void execute(Database.BatchableContext BC,SObject[] scope)
    {
        String concatenatedValue;
        
        Set<String> countryStateClassification_Lst =new Set<String>();//This Set is used here to get concatenated value of Country,State and Classification.
        List<Account> updateAccount_Lst = new List<Account>();//This List is used here to update Account records.
        List<AccountShare> accShare_Lst=new List<AccountShare>();//This List is used here to insert Account Share records.
        List<AccountShare> accountSharerecords_Lst=new List<AccountShare>(); //This List is used here to delete Account Share records.
        //for WR-180005
        List<Account> updateExemptAccount_Lst = new List<Account>();//This List is used here to update Account records.
        
        Database.DeleteResult[] delResults = null;//This array is used here to get delete results.
        Database.SaveResult[] saveResults = null; //This array is used here to get save results.
        Map<String,Account[]> accountsmap=new  Map<String,List<Account>>();//Key=Country+State+Classification,Value=Account
		//setting Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG to true so that Account triggers donot fire again when flag is true.
		Util.UPDATED_FROM_TO_TA_ASSIGNMENT_JOB_FLAG=true;
		// updates by Sunil start
        Set<id> oldTaIds = new Set<ID>();
        	        
        for(SObject s: scope)
        {
        	Account acc = (Account)s;

        	if(acc.TA_Assignment_Type__c=='Update' && acc.TA_Assignment_Rule__c != null)
        	{
        		oldTaIds.add(acc.TA_Assignment_Rule__c);
        	}
        	
        }
        
        Map<Id, TA_Assignment_Rule__c> mapOldTAs= new Map<Id, TA_Assignment_Rule__c>([Select Id,Group_Id__c,Opportunity_Private_Access_Group__c from TA_Assignment_Rule__c where Id in :oldTaIds]);
        // updates by Sunil end
        
        for(SObject s: scope)
        {
           Account acc = (Account)s;
           System.debug('## Account Id ##===='+acc.id);
           //To get Ids for Accounts where TA_Assignment_Type__c=Update.
           //Change for WR-180005
           if(acc.TA_Assignment_Type__c=='Update' || (acc.TA_Assignment_Type__c=='Exempt' && acc.TA_Assignment_Rule__c != null))// If it is update 
           {
                
                for(Integer i=0;i<acc.Shares.size();i++)
                {
                    String groupId = acc.Shares[i].UserOrGroupId;
                    // updates by Sunil start
                    if(groupId.startswith('00G'))
                    {
                    	TA_Assignment_Rule__c oldTA;
                    	if(acc.TA_Assignment_Rule__c != null)
                    		oldTA = mapOldTAs.get(acc.TA_Assignment_Rule__c);

                    	if(oldTA != null)
                    	{
                    		if(acc.Shares[i].UserOrGroupId == oldTA.Group_Id__c || acc.Shares[i].UserOrGroupId == oldTA.Opportunity_Private_Access_Group__c)
                        		accountSharerecords_Lst.add(acc.Shares[i]);//adding the records in the list for deleting as it is the update status
                    	}
                    	// updates by Sunil end
                        if(accountSharerecords_Lst.size()==COLLECTION_LIMIT || accountSharerecords_Lst.size()==limits.getLimitDmlRows())
                        {
                        		System.debug('########### Delete Shares method is called 1.');
                            // now we delete the list of AccountShare records
                                delResults = database.delete(accountSharerecords_Lst);
                                delShares(delResults);
                                accountSharerecords_Lst.clear();
                        }
                        
                    }
                }
               
                if(acc.TA_Assignment_Type__c=='Update')
                {
                	acc.TA_Assignment_Type__c=null;
                }

            	acc.TA_Assignment_Rule__c = null;
            	updateExemptAccount_Lst.add(acc);
               //End of Change for WR-180005 
           }
           
           
           //If Account Country is United States or Canada
           if((acc.BillingCountry=='United States' || acc.BillingCountry=='Canada'))
           {
               if(acc.BillingState!=null)//To check if the billing state is null, Added by karthik
               {
                    countryStateClassification_Lst.add(acc.BillingCountry+acc.BillingState+acc.EMC_Classification__c);
                    concatenatedValue=(acc.BillingCountry+acc.BillingState+acc.EMC_Classification__c).toUpperCase();
               }
               else
               {
                    countryStateClassification_Lst.add(acc.BillingCountry+acc.EMC_Classification__c);
                    concatenatedValue=(acc.BillingCountry+acc.EMC_Classification__c).toUpperCase();
               }
           } 
           else
           {
                countryStateClassification_Lst.add(acc.BillingCountry+acc.EMC_Classification__c);
                concatenatedValue=(acc.BillingCountry+acc.EMC_Classification__c).toUpperCase();
           }
           //If key is already available in the map.
           if(accountsmap.containsKey(concatenatedValue))
            {   
                List<Account> acc_Lst = accountsmap.get(concatenatedValue);
                acc_Lst.add(acc);
                accountsmap.put(concatenatedValue,acc_Lst);  
            }
            else
            {
                List<Account> acc_Lst=new List<Account>();
                acc_Lst.add(acc);
                accountsmap.put(concatenatedValue,acc_Lst);     
            } 
        }
        //Update Exempt Account.180005.
        if(updateExemptAccount_Lst.size() > 0)
                update updateExemptAccount_Lst;
           
    //From here the code is for provding the access to the oppty over the account -- karthik
       //This querey is used here to fetch TA_Assignment_Rule__c where country,State and Classification matches with Accounts.
       system.debug('Country Data #####################' + countryStateClassification_Lst);
       for(TA_Assignment_Rule__c rule: [Select Id,Group_Id__c,Opportunity_Private_Access_Group__c,Country__c,State_Or_Province__c,Classification__c,Country_State_Classification__c 
                                        from TA_Assignment_Rule__c where Country_State_Classification__c 
                                             IN:countryStateClassification_Lst])
        {
           if(accountsmap.containsKey((rule.Country_State_Classification__c).toUpperCase()))//Added to convert to uppercase to make case insensitive, by karthik
           {
            List<Account> acc_Lst = accountsmap.get(rule.Country_State_Classification__c.toUpperCase());
            for(Integer i=0;i<acc_Lst.size();i++)
            {
                acc_Lst[i].TA_Assignment_Rule__c=rule.Id;
                acc_Lst[i].TA_Assignment_Type__c=null;
                //adding account records in the List
                updateAccount_Lst.add(acc_Lst[i]);
                System.debug('Updated List contains'+updateAccount_Lst);
                System.debug('Public User Id'+rule.Group_Id__c);
                System.debug('Private User ID : ' + rule.Opportunity_Private_Access_Group__c);
                //adding accountshare records in the List
                //added by karthik
                if(rule.Group_Id__c!=null){
                    accShare_Lst.add(new AccountShare(UserOrGroupId=rule.Group_Id__c,accountId=acc_Lst[i].Id,AccountAccessLevel='Edit',
                                                          OpportunityAccessLevel='Edit',CaseAccessLevel='Edit'));
                }
                
                if(rule.Opportunity_Private_Access_Group__c!=null){
                    accShare_Lst.add(new AccountShare(UserOrGroupId=rule.Opportunity_Private_Access_Group__c,accountId=acc_Lst[i].Id,AccountAccessLevel='Edit',
                                                          OpportunityAccessLevel='None',CaseAccessLevel='Edit'));
                }
                    if(accShare_Lst.size()==COLLECTION_LIMIT || accShare_Lst.size()==limits.getLimitDmlRows())
                     {
                         //Inserting AccountShare records.
                         saveResults = database.insert(accShare_Lst);
                         createorUpdateRecords(saveResults);
                         accShare_Lst.clear();
                     }
                     
                    if(updateAccount_Lst.size()==COLLECTION_LIMIT || updateAccount_Lst.size()==limits.getLimitDmlRows())
                    {
                         //updating the accounts with the new values
                          saveResults = database.update(updateAccount_Lst);
                          createorUpdateRecords(saveResults);
                          updateAccount_Lst.clear();
                    }
            }
           }   
        }                                       
        if(accountSharerecords_Lst.size()>0)
        {
            // now we delete the list of AccountShare records
            System.debug('###################### Delete Shares 2');
            delResults = database.delete(accountSharerecords_Lst);
            delShares(delResults);
        }
        System.debug('Before inserting'+accShare_Lst);
        if(accShare_Lst.size()>0)
        {
            //Inserting AccountShare records.
            saveResults = database.insert(accShare_Lst);
            createorUpdateRecords(saveResults);
        }
        
        if(updateAccount_Lst.size()>0)
        {
            //updating the accounts with the new values
            saveResults = database.update(updateAccount_Lst);
            createorUpdateRecords(saveResults);
        }
  }  //execute
   
  //This method is used here to delete account Share records.
   public void delShares(Database.DeleteResult[] delResults)
   {
     for (integer j = 0; j < delResults.size(); j++) {
        Database.DeleteResult dr = delResults[j];
        String dataErrs = '';
        if (!dr.isSuccess()) {
            // if the particular record did not get deleted, we log the data error 
            
            for (Database.Error err : dr.getErrors()) {
                dataErrs += err.getMessage();
            }
             errors_Lst.add(new EMCException(dataErrs, EXC_PROCID + ':DeleteAccountTeamMember', new String [] {delResults[j].Id}));
             EMC_UTILITY.logErrors(errors_Lst);
             errors_Lst.clear();
        }
    }
   }
   
        //This methoid is used to create Share records and update Account records
        public void createorUpdateRecords(Database.SaveResult[] saveResults)
            {
                for (integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult sr = saveResults[i];
                String dataErrs = '';
                if (!sr.isSuccess()) {
                    // if the particular record did not get deleted, we log the data error                    
                    for (Database.Error err : sr.getErrors()) {
                        dataErrs += err.getMessage();
                    }
                    errors_Lst.add(new EMCException(dataErrs, EXC_PROCID + ':UpdateProcessedFlag', new String [] {}));
                    EMC_UTILITY.logErrors(errors_Lst);
                    errors_Lst.clear();
                }
                }
            }
  
          //This method is used here to finish context.
          global void finish(Database.BatchableContext BC)
          { //We don't need to do anything.
          }

}