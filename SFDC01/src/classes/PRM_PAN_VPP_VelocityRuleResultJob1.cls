/*========================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE            DEVELOPER                WR       DESCRIPTION                               
 |  ====            =========                ==       =========== 
 |  16-July-2012    Prasad Kothawade                  To create Velocity rule results for PAN Theater model.
 |  17/10/2012      Krishna Pydavula         197607   Added code snippet to send an email       
    15/11/2012      vivek kodi               197607   To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.\
 | 22/05/2013       Suresh Dornadula         239600   Added the Isilon_Track_Specialty__c to the query                                                                                        
 +===========================================================================================================================*/

global class PRM_PAN_VPP_VelocityRuleResultJob1 extends SequencialBatchJobScheduler {
    
    // Data members
    global final String Query; 
    
    /* @Constructor <PRM_PAN_VPP_VelocityRuleResultJob1(): This constructor would be used for   
                                                settingup the query for evaluation of job.>
       @param - <Not accepting anything>
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
    global PRM_PAN_VPP_VelocityRuleResultJob1(){ 
                             
        String ruleResultQuery =  'SELECT Account__c, Advanced_Consolidate_Specialty__c, Backup_and_Recovery_Specialty__c, Cluster__c, '+
                                  ' Compliance_Period_Requirments_Met__c, Consolidate_Specialty__c, Deployed_To__c, Name,Active__c ' +
                                  ' Governance_and_Archive_Specialty__c, Isilon_Track_Specialty__c, Local_Requirment_Set__c, Logical_Block_Level_Grouping__c, '+ 
                                  ' Pan_Theater_Level_Grouping__c, Speciality_Type__c,RecordType.DeveloperName,Theater2__c, Target_Tier__c,Velocity_Specaility_Achieved__c, RecordTypeId '+
                                  ' FROM Account_Groupings__c where (RecordType.DeveloperName=\'Partner_Grouping_Logical_Block\''+
                                  ' OR RecordType.DeveloperName=\'Partner_Grouping_PAN_Theater\') AND Active__c = true' ;
                                  //+' where  Theater2__c=\'\' and (RecordType.DeveloperName=\'Partner Grouping- Logical Block Level\' )'; 
                                  
        System.Debug('ruleResultQuery ###' + ruleResultQuery); 
        this.Query = ruleResultQuery ;    
    
    }
    
    /* @Constructor <PRM_PAN_VPP_VelocityRuleResultJob1(): This constructor would be used for   
                                                settingup the query for evaluation of job.>
       @param - String Query
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
 
    global PRM_PAN_VPP_VelocityRuleResultJob1(String Query){                  
        System.Debug('ruleResultQuery ###' + Query);  
        this.Query = Query ;  
    }
   
    /* @QueryLocator <PRM_PAN_VPP_VelocityRuleResultJob1(): This method executed by apex scheduler
                                                            overriddeen from SequencialBatchJobScheduler class.>
       @param - Database.BatchableContext BC
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
 
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
    
    /* @execute <PRM_PAN_VPP_VelocityRuleResultJob1(): This method executed by apex scheduler
                                                    overriddeen from SequencialBatchJobScheduler class.
                                                    This method Checks if groupings of type Logical Block then calls  
                                                    createLogicalBlockVelocityRuleResults(). If groupings of type PAN Theater then calls 
                                                    createPANTheaterVelocityRuleResults()
                                                    >
                                                    
       @param - Database.BatchableContext BC,List<SObject> scope
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
    */
 
    global override void execute(Database.BatchableContext BC, List<SObject> scope){
        list<Account_Groupings__c> lstGrouping = (list<Account_Groupings__c>)scope;
        list<Account_Groupings__c> lstLogicalBlock = new list<Account_Groupings__c>();
        list<Account_Groupings__c> lstPANTheater = new list<Account_Groupings__c>();
        string batchid = BC.getjobid();
        if(lstGrouping.size()>0){
            for(Account_Groupings__c grouping: lstGrouping){
                // 1) Check if groupings of type Logical Block then  add in list of Logical Blocks
                if(grouping.RecordType.DeveloperName == 'Partner_Grouping_Logical_Block'){
                    lstLogicalBlock.add(grouping);
                }
                // 2)If groupings of type PAN Theater then   add in list of PAN Theaters
                if(grouping.RecordType.DeveloperName == 'Partner_Grouping_PAN_Theater'){
                    lstPANTheater.add(grouping);
                }
            }
        }
        // 3)call createLogicalBlockVelocityRuleResults()
        if(lstLogicalBlock.size()>0){
            PRM_PAN_VPP_VelocityRuleResults PANVPPVelocityRuleResults = new PRM_PAN_VPP_VelocityRuleResults();
            //PANVPPVelocityRuleResults.createLogicalBlockVelocityRuleResults(lstLogicalBlock);
             PANVPPVelocityRuleResults.createLogicalBlockVelocityRuleResultswitherrors(lstLogicalBlock,batchid,emailerrors);
        }
        // 4) call createPANTheaterVelocityRuleResults()
        if(lstPANTheater.size()>0){
            PRM_PAN_VPP_VelocityRuleResults PANVPPVelocityRuleResults = new PRM_PAN_VPP_VelocityRuleResults();
            //PANVPPVelocityRuleResults.createPANLevelVelocityRuleResults(lstPANTheater);
            PANVPPVelocityRuleResults.createPANLevelVelocityRuleResultswitherrors(lstPANTheater,batchid,emailerrors);
        }       
    }

}