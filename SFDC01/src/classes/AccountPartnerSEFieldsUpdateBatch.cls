/*======================================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    20-Dec-2011     Kaustav Debnath         183071          Batch class to update 
                                                            contact summary field
                                                            values on account
    17-Dec-2012		Anand Sharma							Update code to remove extra logic and Sequecial Jobs 
    17/10/2012     Krishna Pydavula         197607           Added code snippet to send an email  
    15/11/2012     vivek kodi              197607          To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                        
========================================================================================*/
global class AccountPartnerSEFieldsUpdateBatch extends SequencialBatchJobScheduler{
    public String Query;
    
    global AccountPartnerSEFieldsUpdateBatch(String query){
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
		Set<Id> setGroupingIds =  new Set<Id>();
		//Populating RoleId and corresponding User Attribute Mapping record map.
        Account accountObj;
        for(SObject sobjects:scope){
            accountObj = (Account)sobjects;
            if(accountObj.grouping__c != null){
            	setGroupingIds.add(accountObj.grouping__c);
            }                         
        }
        if(setGroupingIds!=null && setGroupingIds.size()>0){
            PRM_Partner_Leverage.accountPartnerLevFactorCalculation(setGroupingIds,BC.getjobId(),emailerrors);
        }        
    	 PRM_JobFactory.loglimits('AccountPartnerSEFieldsUpdateBatch'); 
    }
    
}