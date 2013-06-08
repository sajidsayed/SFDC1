/*==================================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  22/12/2011    Anil Sure                         This batch job is to set/check the theater value on staging table 
 |  28-Dec-2011   Anand Sharma                      updated logic batchwise 
 | 17/10/2012   Krishna Pydavula          197607     Added code snippet to send an email
 14-Nov -2012   vivek kodi	             197607     To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.
+===================================================================================================================================*/
global class PRM_ESBI_VPP_StagingDataOperator extends SequencialBatchJobScheduler{
 
 //holds query string 
    global final String Query;   
    
    
    //Used to store the data mapping for the education master using the custom setting.
    Map<String,CustomSettingDataValueMap__c> DataValueMap = CustomSettingDataValueMap__c.getAll();
    List<CustomSettingDataValueMap__c > lstUpdateList = new List<CustomSettingDataValueMap__c >();
    
    //default constructor
    global PRM_ESBI_VPP_StagingDataOperator(){
        CustomSettingDataValueMap__c   seqeunceId = CustomSettingDataValueMap__c.getValues('ESBI_Int_Control_Flag_Sequence');
        Integer sequenceId =  Integer.valueOf(seqeunceId.DataValue__c);
        Integer batchId =  sequenceId -1 ;   
        
        String stagingQuery = 'Select Id, Text1__c, Text2__c, Text3__c , Text4__c, Text5__c, Text6__c, Text7__c,'
                              + ' Text8__c, text9__c, Text10__c,Text12__c, Text11__c, Date1__c , Date2__c,Batch_Id__c,Text14__c from Staging_Data__c ' 
                              +  'where is_Header__c != true AND Object_Name__c =\'Education\' AND Text14__c= null  AND Batch_Id__c ='+ batchId ;
                                
        System.Debug('stagingQuery --->' + stagingQuery);                               
        this.Query = stagingQuery ; 
    }
     //Parameterised constructor
    global PRM_ESBI_VPP_StagingDataOperator(String query){              
        System.Debug('PArameter constructor Query --->' + query);   
        this.Query = query ;                            
    }
    
    //create batch of records which is passed to execute method for processing
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
    
    //Update the list of passed account scope and break the context to handle governer limit
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        
        Set<Id> stagingidset = new Set<Id>();
        //code added for WR 197607
        Database.SaveResult[] results;
        List <EMCException> errors = new List <EMCException>();             
        String Batchid = BC.getJobId();
        List<Staging_Data__c> DataStagingList =(Staging_Data__c[]) scope;
        System.debug('DataStagingList'+DataStagingList);
        if(DataStagingList.size()>0){       
       
            /*Add Grouping Ids to Set*/         
            for(Staging_Data__c sdata : DataStagingList)
            {
                try{
                    Id groupingId = sdata.Text4__c;
                    stagingidset.add(groupingId);
                }catch(Exception ex){
                    System.debug('Invalid Grouping Id ---' + sdata.Text4__c);
                }
                
            }
            if(stagingidset.size() > 0) {
                /* Fetch ID, Theater from Account Grouping where Id is in Text4__c*/
                Map<Id,Account_Groupings__c> mapAccountgrouping  = new Map<Id,Account_Groupings__c>([SELECT Id,Theater2__c from Account_Groupings__c where Id in :stagingidset]);       
                            
                /* update Staging Data records with Theatre values */
                for(Staging_Data__c sdata : DataStagingList)
                {
                    if(mapAccountgrouping.containsKey(sdata.Text4__c)){
                        sdata.Text14__c = mapAccountgrouping.get(sdata.Text4__c).Theater2__c;
                    }
                }
                 results= database.update(DataStagingList,false);
                /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : results) {
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
		      system.debug('BatchidBatchidvv'+Batchid);
		       if (errors.size() > 0) { 
		            EMC_UTILITY.logErrors(errors);
		            emailerrors.addall(errors);
		            system.debug('emailerrorsemailerrors'+emailerrors);
		        }		        
                   
            }                   
        }
        PRM_JobFactory.loglimits('PRM_ESBI_VPP_StagingDataOperator');
    }
}