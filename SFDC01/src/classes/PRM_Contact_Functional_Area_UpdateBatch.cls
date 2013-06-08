/*======================================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    24-Apr-2012     Anirudh Singh          189799           Batch class to update 
                                                            funtional area field on 
                                                            partner contacts    
   17/10/2012    Krishna Pydavula         197607            Added code snippet to send an email 
   15/11/2012      vivek kodi             197607            To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                                                                                                                     
========================================================================================*/
global class PRM_Contact_Functional_Area_UpdateBatch extends SequencialBatchJobScheduler{
    public String Query;

    
    global PRM_Contact_Functional_Area_UpdateBatch(String query){
       this.Query = query;
       
    }
    
    global override Database.QueryLocator start(Database.BatchableContext BC){
    	//code added for WR 197607
    	if(BC != null && BC.getJobId() !=null)
    	{
    	batchprocessid=BC.getJobId();
        List<EMCException> emailerrors = new List<EMCException>();
        SendEmailNotificationToAllBatchjobs.EmailProcessor(batchprocessid,emailerrors);
    	}   
        //End of code for  WR 197607 
        return Database.getQueryLocator(Query);
    }
    
    global override void execute(Database.BatchableContext BC, SObject[] scope){         
        List<Contact> lstContactUpdate = new List<Contact>();
            for(SObject sobjects:scope){
                Contact contactObj = (Contact)sobjects;
                lstContactUpdate.add(contactObj);
            }
            if(lstContactUpdate.size()>0) 
            {
                PRM_Contact_Functional_Area.contactFunctionalAreaUpdate(lstContactUpdate,BC.getJobid(),emailerrors);
            }
            
        }
        
       
}