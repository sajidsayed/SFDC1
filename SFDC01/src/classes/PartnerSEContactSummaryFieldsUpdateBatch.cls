/*======================================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    20-Dec-2011     Kaustav Debnath         183071          Batch class to update 
                                                            contact summary fields
                                                            for partner se contacts
    17-Dec-2012		Anand Sharma							Update for Sequecial Jobs  
    03-Feb-2012		Anand Sharma							Added code to nullify Partner Lev factor before start calculation
    03-feb-2012		Anand Sharma							Added exception handling
    10/17/2012    Krishna Pydavula         197607           Added code snippet to send an email 
    15/11/2012      vivek kodi             197607           To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.														                                                      
========================================================================================*/
global class PartnerSEContactSummaryFieldsUpdateBatch extends SequencialBatchJobScheduler{
    public String Query;

    
    global PartnerSEContactSummaryFieldsUpdateBatch(String query){
       this.Query = query;
       System.debug('Query is---->'+query);
    }
    
    global override Database.QueryLocator start(Database.BatchableContext BC){
    	//code added for WR 197607
       if(BC != null && BC.getJobId() !=null){
        batchprocessid=BC.getJobId();
        List<EMCException> emailerrors = new List<EMCException>();
        SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
    	}
         //End of code for  WR 197607 
        return Database.getQueryLocator(Query);
    }
    
    global override void execute(Database.BatchableContext BC, SObject[] scope){    
        Set<String> contactAccountIds =  new Set<String>();
        //Map to Store RoleIds and corresponding User Attribute Mapping record.
        Map<String,Contact> mapPartnerSEContactAccount = new Map<String,Contact>(); 
        List<Contact> lstContactUpdate = new List<Contact>();
        List<Contact> lstContactWithoutProfileAccountUpdate = new List<Contact>();
        String Batchid = BC.getjobid();
        // Exception Handling.
    	List <EMCException> errors = new List <EMCException>();
    
        //Populating RoleId and corresponding User Attribute Mapping record map.
        for(SObject sobjects:scope){
            Contact contactObj = (Contact)sobjects;
            contactObj.Partner_Leverage_Factor__c = null;
            contactObj.PRM_PL_Factor_Calculated__c =false;
            if(contactObj.partner_se__c){
                System.debug('#### contactObj.emc_pre_sales__c=>'+contactObj.emc_pre_sales__c);
                mapPartnerSEContactAccount.put(contactObj.id,contactObj);
                contactAccountIds.add(contactObj.accountid);
            }
        }
        
        //Processing User Attribute Mapping records
        if(contactAccountIds.size()>0){
        	Map<Id, Account> mapAccount= new Map<Id, Account>([select id,grouping__c,rating_eligible__c,Profiled_Account__c,
        													Profiled_Account__r.rating_eligible__c from account 
        													where id in :contactAccountIds]);
        	for(SObject sobjects:scope){
	            Contact contactObj = (Contact)sobjects;
	            contactObj.Partner_Leverage_Factor__c = null;
	            contactObj.PRM_PL_Factor_Calculated__c =false;
	            if(mapAccount.containskey(mapPartnerSEContactAccount.get(contactObj.id).accountid) && 
	                mapAccount.get(mapPartnerSEContactAccount.get(contactObj.id).accountid).Profiled_Account__c!=null &&
	                mapAccount.get(mapPartnerSEContactAccount.get(contactObj.id).accountid).Profiled_Account__r.rating_eligible__c==true){
	                lstContactUpdate.add(contactObj);
                }else if(mapAccount.containskey(mapPartnerSEContactAccount.get(contactObj.id).accountid) && 
	                mapAccount.get(mapPartnerSEContactAccount.get(contactObj.id).accountid).Profiled_Account__c==null &&
	                mapAccount.get(mapPartnerSEContactAccount.get(contactObj.id).accountid).rating_eligible__c==true){
	                lstContactUpdate.add(contactObj);
                }else{
                	lstContactWithoutProfileAccountUpdate.add(contactObj);
                }
        	}
            if(lstContactUpdate.size()>0) 
            {
                PRM_Partner_Leverage.contactPartnerLevFactorCalculation(lstContactUpdate);
            }
            if(lstContactWithoutProfileAccountUpdate.size() >0){
            	Database.Saveresult[] result =  Database.update(lstContactWithoutProfileAccountUpdate, false);
            	
            	/* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : result) {
		            String dataErrs = '';
		            if (!sr.isSuccess()) {
		                // if the particular record did not get updated, we log the data error 
		                for (Database.Error err : sr.getErrors()) {
		                    dataErrs += err.getMessage();
		                }
		                System.debug('An exception occurred while attempting an update on ' + sr.getId());
		                System.debug('ERROR: ' + dataErrs);
		                errors.add(new EMCException(dataErrs, Batchid, new String [] {sr.getId()}));
		            }
		        }		        
		      // log any errors that occurred
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors); 
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors); 
		        }
            }
        }
       PRM_JobFactory.loglimits('PartnerSEContactSummaryFieldsUpdateBatch');  
    }    
}