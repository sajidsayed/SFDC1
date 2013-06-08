/*=================================================================================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  21/01/2011    Suman B                      To Evaluate the VelocityRules for each VelocityRuleResult
    02/02/2011    Ashwini Gowda                     Updated class to incorporate Revenue Calculation,
                                                    RollUp Rules and Tier Rules.
    02/21/2011    Prasad Kothawade        Defect#297 - Count of specilities acheived on Tier 
    02/22/2011    Prasad Kothawade        Defect#307 - Sepecilities % for multiple of 10 was not in upper bracket. 
    03/14/2011    Anirudh Singh           2514       Code Updated to have 5 total and/or Specialty Roll-Up Buckets.
    03/18/2011    Anand Sharma                       updating Education_Data_Refresh_Date__c  field value with 
                                                     current data time in method evaluateRollupRules in 
                                                     rollup calculation batch job. 
    03/18/2011    Ashwini Gowda           2599       Updated getRevenueRange() method to Change the Revenue Actuals 
                                                     on the Velocity Scorecards to display "100%+" instead of 110%,
                                                     etc for any revenue where the goal is 100% attained.
    29/03/2011     Anil Sure              Defect#340         Rules set for "Group Rule 3" or "Group Rule 4" or "Group Rule 5" 
                                                     fileds on Specialties ,counts are not displayed appropriately     
    30/03/2011    Ashwini Gowda           Defect#343 Modified method getRevenueRange().     
    29/07/2011    Suman B                            Added condition check in evaluateRollupRules() method for Null vlaues.                                                                                                 
    22/11/2011    Suman B                WR #180938  Updated logic in checkComplianceStatus()method for set the compliance status to 'Yes' for 
                                                     specality - 'Backup and Recovery', even if one Subcategory status is 'Achieved'
    5 March 2012  Arif                               getRevenueRange() method is now out of context.As the actual value is getting displayed now,
                                                     range is not required, since getRevenueRange() method is used to identify the range,
                                                     it is not required any more.
    06/03/2012    Suman B                            Added logic for Velocity Servicecard implementation.                                                    
    09/03/2012    Suman B                            Added logic to set the status of the Service Rule Result records.
                                                     created getServiceRuleResultStatus() and updated evaluateSpecialtyRule() and fecthAccount()
    12/03/2012    Anand Sharma                       updated getServiceRuleResultStatus() method to handle null point exception  
    13/03/2012    Anand Sharma                       updated evaluateVelocityRule() method to handle format revenue value  
    21/03/2012    Suman B                            Added Nullpointer check to validate GroupRule in evaluateSpecialtyRule()method.        
    20/7/2012     Arif                  197466       Adding a method and adding 'Field_Based_Rule_Type' part in evaluateVelocityRule method for cloud bulider
    30 Aug 2012   Arif                               Adding a new method for change in evaluation of local requirement set grouping
    10-Sep-2012   Prasad                             Fix duplicate Id issue - Grouping Id geting added multiple times - 
                                                     1)Fix on account update while stamping field Education_Data_Refresh_Date__c 
    15/11/2012     vivek kodi            197607       To send out error records(Apex Batch notifications) to SFDC Batch Administrators for the ESBI VPP Scheduler Jobs.                                           
 +=================================================================================================================================================*/


public class PRM_VPP_RuleEvaluator {

    Map<Id,Map<Id,List<Education_EducationGroup_Mapping__c>> > mapPartnerGroupId_Educations; 
    // outer map has key as partner group Id inner map has Education GroupId as Key
    
    // contains partnerGroupId+EducationGroupid as key and set of contacts falls in education group
    Map<String, Set<Id>> mapEducationGroupResult;
    
    // contains partnerGroupId+Grouprules id as key and set of contacts satisfies the rule
    Map<String, Set<Id>> mapGroupRuleResult ;
    
    // The map contains all education groups per their rule id -this should contains all irrespective of rule record type -query -to
    Map<Id, List<Education_Groups__c>> mapRuleID_EducationGroups ;
    
    //Education Group Record : query to VelocityRules having RT -Rollup
    Map <Id, Velocity_Rules__c> mapRollupRules;
  
    Map <String, List<Velocity_Rules__c>> mapTheater_RollupRules;   
    //Education Group Record : query to VelocityRules having RT -Group rule
    Map <Id, Velocity_Rules__c> mapGroupRules;
   
    //Key Partner Group Id and value is account
    Map<Id, Account> MapPartnerGroupId_ProfiledAccount = new Map<Id, Account>();
    Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap = new Map<Id,Velocity_Revenue__c>(); 
    
    // Exception Handling.
    List <EMCException> errors = new List <EMCException>();
    
/* @Constructor <PRM_VPP_VelocityRuleResults(): This constructor would be used for   
                                                settingup the datamemebers for evaluation.>
       @param - List<Velocity_Rule_Results__c> 
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/        
   public PRM_VPP_RuleEvaluator(List<Velocity_Rule_Results__c> lstVelocityRuleResult){
        mapGroupRuleResult = new Map<String, Set<Id>>();
        mapEducationGroupResult = new Map<String, Set<Id>>();
        mapRuleID_EducationGroups = new Map<Id, List<Education_Groups__c>>();
        mapRollupRules = new Map <Id, Velocity_Rules__c>();
        mapGroupRules = new Map <Id, Velocity_Rules__c>();
        mapTheater_RollupRules = new  Map <String, List<Velocity_Rules__c>>();
        Set<String> setPartnerGroupIds = new Set<String>();
        Set<Id> setProfiledAccountIds = new Set<Id>();
        Set<Id> setGroupRuleIds = new Set<Id>();        
              
        //Add partner PartnerGroup ID in set and Add Profiled Account Id on ProfiledAccountIds
        for(Velocity_Rule_Results__c velRuleResultRecord : lstVelocityRuleResult){
            if(velRuleResultRecord.Grouping__c != null){
                String strPartnerGrouping = velRuleResultRecord.Grouping__c;
                strPartnerGrouping = strPartnerGrouping.substring(0,15);
                setPartnerGroupIds.add(strPartnerGrouping);
            }
            if(velRuleResultRecord.AccountID__c != null)  setProfiledAccountIds.add(velRuleResultRecord.AccountID__c);
            if(velRuleResultRecord.Speciality_RuleID__c != null){
                Velocity_Rules__c objVelRule = velRuleResultRecord.Speciality_RuleID__r;
                if(objVelRule.Velocity_Rule_1__c != null){
                    setGroupRuleIds.add(objVelRule.Velocity_Rule_1__c);
                }
                if(objVelRule.Velocity_Rule_2__c != null){
                    setGroupRuleIds.add(objVelRule.Velocity_Rule_2__c);
                }
                //Added by Anil 
                 if(objVelRule.Group_Rule_3__c != null){
                    setGroupRuleIds.add(objVelRule.Group_Rule_3__c);
                }
                 if(objVelRule.Group_Rule_4__c != null){
                            setGroupRuleIds.add(objVelRule.Group_Rule_4__c);
                        }
                 if(objVelRule.Group_Rule_5__c != null){
                            setGroupRuleIds.add(objVelRule.Group_Rule_5__c);
                }

            }
            
        }
        //Returns all the profiled Account Id and its associated Revenue to Map
        revenueProfiledAccountMap = getRevenueDetails(setProfiledAccountIds);
        //Get all accounts and with rollup fields whose IDs in set ProfiledAccountIds
        System.debug('setProfiledAccountIds '+ setProfiledAccountIds );
        System.debug('setProfiledAccountIds '+ setProfiledAccountIds.size() );
        List<Account> lstAccount = fecthAccount(setProfiledAccountIds);
        System.debug('lstAccount.size() '+ lstAccount.size() );
        if(lstAccount != null && lstAccount.size() >0){
            for(Account accRecord: lstAccount){
                if(!MapPartnerGroupId_ProfiledAccount.containsKey(accRecord.Grouping__c)){
                    MapPartnerGroupId_ProfiledAccount.put(accRecord.Grouping__c, accRecord);                    
                }
            }
           System.debug('MapPartnerGroupId_ProfiledAccount '+MapPartnerGroupId_ProfiledAccount);
        }
        
        //Assumpition not more than 10000: Populate Map RollupRules - By querying on VelocityRules where record type is "Rollup"
     /*   mapRollupRules = fetchRollupRuleRecord();
         
         if(mapRollupRules!= null && mapRollupRules.size()>0){
           for(Velocity_Rules__c rollupRule : mapRollupRules.values()) {   
            if(mapTheater_RollupRules.containskey(rollupRule.Theater__c)){
               List<Velocity_Rules__c> rolluplist = mapTheater_RollupRules.get(rollupRule.Theater__c);
                   rolluplist.add(rollupRule);  
            }
            else{
              mapTheater_RollupRules.put(rollupRule.Theater__c, new List<Velocity_Rules__c>());
              mapTheater_RollupRules.get(rollupRule.Theater__c).add(rollupRule);
            } 
          } //End of for loop. 
         } */
        //Assumpition not more than 10000: Populate Map RollupRules - By querying on VelocityRules where record type is "Group Rule"
        if( (setGroupRuleIds != Null) && (setGroupRuleIds.size()>0) ){
           mapGroupRules = fetchGroupRuleRecord(setGroupRuleIds);
        }
        System.debug('lstVelocityRuleResult ==> '+lstVelocityRuleResult);
        //Populate MapRuleID_EducationGroups -By querying on "Education Group Record" object
        mapRuleID_EducationGroups = populateVelocityRuleWithEducationGroup(lstVelocityRuleResult); 
        
        // contains partnerGroupId+EducationGroupid as key and set of contacts falls in education group
        createMappEducationGrpIdEducationsANDmapEducationGroupResult(setPartnerGroupIds); 
                                                                     
     } //END OF CONSTRUCTOR

/* @Constructor <PRM_VPP_VelocityRuleResults(): This constructor would be used for   
                                                settingup the datamemebers for evaluation.>
       @param - List<Accounts> 
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/
    public PRM_VPP_RuleEvaluator(List<Account> listAccounts){
        mapGroupRuleResult = new Map<String, Set<Id>>();
        mapEducationGroupResult = new Map<String, Set<Id>>();
        mapRuleID_EducationGroups = new Map<Id, List<Education_Groups__c>>();
        mapRollupRules = new Map <Id, Velocity_Rules__c>();
        mapGroupRules = new Map <Id, Velocity_Rules__c>();
        mapTheater_RollupRules = new  Map <String, List<Velocity_Rules__c>>();
        Set<String> setPartnerGroupIds = new Set<String>();
        Set<Id> setProfiledAccountIds = new Set<Id>();
        Set<Id> setGroupRuleIds = new Set<Id>();        

        system.debug('INSIDE PRM_VPP_RuleEvaluator-CONSTRUCTOR Account ###');
        //Get all accounts and with rollup fields whose IDs in set ProfiledAccountIds
        // List<Account> lstAccount = fecthAccount(setProfiledAccountIds);
        
        if(listAccounts != null && listAccounts.size() >0){
            for(Account accRecord: listAccounts){
                System.debug( 'accRecord.Grouping__c : '+accRecord.Grouping__c );
                if(!MapPartnerGroupId_ProfiledAccount.containsKey(accRecord.Grouping__c)){
                    MapPartnerGroupId_ProfiledAccount.put(accRecord.Grouping__c, accRecord);                    
                }
                String strPartnerGrouping = accRecord.Grouping__c;
                strPartnerGrouping = strPartnerGrouping.substring(0,15);
                setPartnerGroupIds.add(strPartnerGrouping);
            }
            
        }
        
        //Assumpition not more than 10000: Populate Map RollupRules - By querying on VelocityRules where record type is "Rollup"
        mapRollupRules = fetchRollupRuleRecord();
         
         if(mapRollupRules!= null && mapRollupRules.size()>0){
           for(Velocity_Rules__c rollupRule : mapRollupRules.values()) {   
            if(mapTheater_RollupRules.containskey(rollupRule.Theater__c)){
               List<Velocity_Rules__c> rolluplist = mapTheater_RollupRules.get(rollupRule.Theater__c);
                   rolluplist.add(rollupRule);  
           }
            else{
              mapTheater_RollupRules.put(rollupRule.Theater__c, new List<Velocity_Rules__c>());
              mapTheater_RollupRules.get(rollupRule.Theater__c).add(rollupRule);
            } 
          } //End of for loop. 
         }

        List<Velocity_Rule_Results__c> listVRR = new list<Velocity_Rule_Results__c>();
        //Populate MapRuleID_EducationGroups -By querying on "Education Group Record" object
        mapRuleID_EducationGroups = populateVelocityRuleWithEducationGroup(listVRR); 
        
        // contains partnerGroupId+EducationGroupid as key and set of contacts falls in education group
        createMappEducationGrpIdEducationsANDmapEducationGroupResult(setPartnerGroupIds); 
         
    } //End of Constructor

     //this method will get called from bacth job, which will take Rule result as parameter
     public void evaluateVelocityRule(List<Velocity_Rule_Results__c> lstVelocityRuleResult){
        System.debug('lstVelocityRuleResult size-->'+lstVelocityRuleResult);
         
        List<Account> lstProfileAccountforupdate = new List<Account>();
        if(lstVelocityRuleResult.size() ==0) return;
        String LastPartnerGroupProcessed = lstVelocityRuleResult.get(0).Grouping__c;
        
        //Instantiate RuleEvaluator class pass the list above created
        //PRM_VPP_RuleEvaluator_GroupRule objReuleEvaluator = new PRM_VPP_RuleEvaluator_GroupRule(MapPartnerGroupId_ProfiledAccount.keySet());
        
        //List holding all Velocity Rule Results associated to individual profiled Account        
        List<Velocity_Rule_Results__c> CurrentAccountVRR = new List <Velocity_Rule_Results__c>();
        
        //Iterate over the list of Velocity Rule Result
        for(Velocity_Rule_Results__c velRuleResultRecord : lstVelocityRuleResult){
            /* */            
            CurrentAccountVRR.add(velRuleResultRecord);
            
            //1) VRR population : VelocitySpeciality/Tier method.
            Velocity_Rules__c objVelRule = velRuleResultRecord.Speciality_RuleID__r;
            System.debug('Velocity Rule result :objVelRule ---> '+ objVelRule);
           

            if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName == 'Specialty_Rule'){
               //velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
               //Populate Revenue Amount and Current(Range) only if Bucket is Revenue
               if(velRuleResultRecord.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    velRuleResultRecord.Revenue_Amount__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
                    // velRuleResultRecord.Current__c = getRevenueRange(velRuleResultRecord);
                    velRuleResultRecord.Current__c = velRuleResultRecord.Revenue_Amount__c;
                   
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velRuleResultRecord.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);                    
                    System.debug('Velocity Rule result for Specialty bucket strrevenue ---> '+  strrevenue);
                    velRuleResultRecord.Current__c = '$' + strrevenue;                  
                    System.debug('Velocity Rule result for bucket Specialty Rvenue:Current__c ---> '+  velRuleResultRecord.Current__c);
               }
               else{
                velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
               }
               System.debug('Velocity Rule result :Revenue_Amount__c ---> '+ velRuleResultRecord.Revenue_Amount__c);
               System.debug('Velocity Rule result :Current__c ---> '+  velRuleResultRecord.Current__c);
                /* revenue Tier*/
            }
         // else if(velRuleResultRecord.Speciality_RuleID__r.RecordTypeID =='012Q00000000ImZIAU'){            
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                //velRuleResultRecord.Current__c = String.valueOf(evaluateTierRule(objVelRule,velRuleResultRecord));
                //Populate Revenue Amount and Current(Range) only if Bucket is Revenue
                if(velRuleResultRecord.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    //velRuleResultRecord.Revenue_Amount__c =  String.valueof(evaluateTierRule(objVelRule,velRuleResultRecord));
                    velRuleResultRecord.Revenue_Amount__c =  evaluateTierRule(objVelRule,velRuleResultRecord);
                    //velRuleResultRecord.Current__c = getRevenueRange(velRuleResultRecord);
                    velRuleResultRecord.Current__c = velRuleResultRecord.Revenue_Amount__c;
                   
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velRuleResultRecord.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);                    
                    System.debug('Velocity Rule result for Tier_Rule bucket strrevenue ---> '+  strrevenue);
                    velRuleResultRecord.Current__c = '$' + strrevenue;                  
                    System.debug('Velocity Rule result for bucket Tier_Rule Rvenue:Current__c ---> '+  velRuleResultRecord.Current__c);
                }
                else{
                    //velRuleResultRecord.Current__c =  String.valueof(evaluateTierRule(objVelRule,velRuleResultRecord));
                    velRuleResultRecord.Current__c =  evaluateTierRule(objVelRule,velRuleResultRecord);
                }
                System.debug('Velocity Rule result :Revenue_Amount__c ---> '+ velRuleResultRecord.Revenue_Amount__c);
                System.debug('Velocity Rule result :Current__c ---> '+  velRuleResultRecord.Current__c);
            }
           
           /***** Added for Velocity Service Scorecard *****/
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Services_Rule'){
                   velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));              
                   // Added for setting the Status -VS_Rule_Result_Status__c.
                   velRuleResultRecord.VS_Rule_Result_Status__c = getServiceRuleResultStatus(objVelRule,velRuleResultRecord);   
           }  
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type'){
                   velRuleResultRecord.Current__c =  evaluateCloudBuilderRule(objVelRule,velRuleResultRecord);                 
           }                
          //}
        }//FOR

        // update accounts for rollup count
        /*Database.Saveresult[] resultAccount = Database.update(lstProfileAccountforupdate); 
         if(resultAccount != null){
           PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultAccount);
         }*/
        
        //update Velocity rule Result
        Database.Saveresult[] resultVelocityRuleResult = Database.update(lstVelocityRuleResult);
         if(resultVelocityRuleResult!= null){
           PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVelocityRuleResult);
          }
      
      
      /* HANDLING EXCEPTION LOG*/
        for (Database.Saveresult sr : resultVelocityRuleResult) {
            String dataErrs = '';
            if (!sr.isSuccess()) {
                // if the particular record did not get updated, we log the data error 
                for (Database.Error err : sr.getErrors()) {
                    dataErrs += err.getMessage();
                }
                System.debug('An exception occurred while attempting an update on ' + sr.getId());
                System.debug('ERROR: ' + dataErrs);
                errors.add(new EMCException(dataErrs, 'ERROR_VELOCITY_RULE_EVALUATION', new String [] {sr.getId()}));
            }
        }
      // log any errors that occurred
       if (errors.size() > 0) { 
            EMC_UTILITY.logErrors(errors);  
        }
     } // END of method - evaluateVelocityRule
     
      //this method will get called from bacth job, which will take Rule result as parameter
     public void evaluateVelocityRulewitherrors(List<Velocity_Rule_Results__c> lstVelocityRuleResult,string Batchid,List<EMCException> emailerrors){
        System.debug('lstVelocityRuleResult size in with errors method-->'+lstVelocityRuleResult);
        List<Account> lstProfileAccountforupdate = new List<Account>();
        if(lstVelocityRuleResult.size() ==0) return;
        String LastPartnerGroupProcessed = lstVelocityRuleResult.get(0).Grouping__c;
        
        //Instantiate RuleEvaluator class pass the list above created
        //PRM_VPP_RuleEvaluator_GroupRule objReuleEvaluator = new PRM_VPP_RuleEvaluator_GroupRule(MapPartnerGroupId_ProfiledAccount.keySet());
        
        //List holding all Velocity Rule Results associated to individual profiled Account        
        List<Velocity_Rule_Results__c> CurrentAccountVRR = new List <Velocity_Rule_Results__c>();
        
        //Iterate over the list of Velocity Rule Result
        for(Velocity_Rule_Results__c velRuleResultRecord : lstVelocityRuleResult){
            /* */            
            CurrentAccountVRR.add(velRuleResultRecord);
            
            //1) VRR population : VelocitySpeciality/Tier method.
            Velocity_Rules__c objVelRule = velRuleResultRecord.Speciality_RuleID__r;
            System.debug('Velocity Rule result :objVelRule ---> '+ objVelRule);

            if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName == 'Specialty_Rule'){
               //velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
               //Populate Revenue Amount and Current(Range) only if Bucket is Revenue
               if(velRuleResultRecord.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    velRuleResultRecord.Revenue_Amount__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
                    // velRuleResultRecord.Current__c = getRevenueRange(velRuleResultRecord);
                    velRuleResultRecord.Current__c = velRuleResultRecord.Revenue_Amount__c;
                   
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velRuleResultRecord.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);                    
                    System.debug('Velocity Rule result for Specialty bucket strrevenue ---> '+  strrevenue);
                    velRuleResultRecord.Current__c = '$' + strrevenue;                  
                    System.debug('Velocity Rule result for bucket Specialty Rvenue:Current__c ---> '+  velRuleResultRecord.Current__c);
               }
               else{
                velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));
               }
               System.debug('Velocity Rule result :Revenue_Amount__c ---> '+ velRuleResultRecord.Revenue_Amount__c);
               System.debug('Velocity Rule result :Current__c ---> '+  velRuleResultRecord.Current__c);
                /* revenue Tier*/
            }
         // else if(velRuleResultRecord.Speciality_RuleID__r.RecordTypeID =='012Q00000000ImZIAU'){            
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                //velRuleResultRecord.Current__c = String.valueOf(evaluateTierRule(objVelRule,velRuleResultRecord));
                //Populate Revenue Amount and Current(Range) only if Bucket is Revenue
                if(velRuleResultRecord.Speciality_RuleID__r.Bucket__c == 'Revenue'){
                    //velRuleResultRecord.Revenue_Amount__c =  String.valueof(evaluateTierRule(objVelRule,velRuleResultRecord));
                    velRuleResultRecord.Revenue_Amount__c =  evaluateTierRule(objVelRule,velRuleResultRecord);
                    //velRuleResultRecord.Current__c = getRevenueRange(velRuleResultRecord);
                    velRuleResultRecord.Current__c = velRuleResultRecord.Revenue_Amount__c;
                   
                    List<String> args = new String[]{'0','number','$###,###,###.00'};                      
                    Decimal decRevenueAmmount = Decimal.valueOf(velRuleResultRecord.Revenue_Amount__c);                 
                    String strrevenue = String.format(decRevenueAmmount.format(), args);                    
                    System.debug('Velocity Rule result for Tier_Rule bucket strrevenue ---> '+  strrevenue);
                    velRuleResultRecord.Current__c = '$' + strrevenue;                  
                    System.debug('Velocity Rule result for bucket Tier_Rule Rvenue:Current__c ---> '+  velRuleResultRecord.Current__c);
                }
                else{
                    //velRuleResultRecord.Current__c =  String.valueof(evaluateTierRule(objVelRule,velRuleResultRecord));
                    velRuleResultRecord.Current__c =  evaluateTierRule(objVelRule,velRuleResultRecord);
                }
                System.debug('Velocity Rule result :Revenue_Amount__c ---> '+ velRuleResultRecord.Revenue_Amount__c);
                System.debug('Velocity Rule result :Current__c ---> '+  velRuleResultRecord.Current__c);
            }
           
           /***** Added for Velocity Service Scorecard *****/
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Services_Rule'){
                   velRuleResultRecord.Current__c =  String.valueof(evaluateSpecialtyRule(objVelRule,velRuleResultRecord));              
                   // Added for setting the Status -VS_Rule_Result_Status__c.
                   velRuleResultRecord.VS_Rule_Result_Status__c = getServiceRuleResultStatus(objVelRule,velRuleResultRecord);   
           }  
           else if(velRuleResultRecord.Speciality_RuleID__r.RecordType.DeveloperName =='Field_Based_Rule_Type'){
                   velRuleResultRecord.Current__c =  evaluateCloudBuilderRule(objVelRule,velRuleResultRecord);                 
           }                
          //}
        }//FOR

        // update accounts for rollup count
        /*Database.Saveresult[] resultAccount = Database.update(lstProfileAccountforupdate); 
         if(resultAccount != null){
           PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultAccount);
         }*/
        
        //update Velocity rule Result
        Database.Saveresult[] resultVelocityRuleResult = Database.update(lstVelocityRuleResult);
         if(resultVelocityRuleResult!= null){
           PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVelocityRuleResult);
          }
      
      
      /* HANDLING EXCEPTION LOG*/
        for (Database.Saveresult sr : resultVelocityRuleResult) {
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
     } // END of method - evaluateVelocityRule
     
    private void createMappEducationGrpIdEducationsANDmapEducationGroupResult(Set<String> setPartnerGroupIds){
        system.debug('INSIDE createMappEducationGrpIdEducationsANDmapEducationGroupResult()- partnerGrpIDs ##' +setPartnerGroupIds);   
        mapPartnerGroupId_Educations = new Map<Id,Map<Id,List<Education_EducationGroup_Mapping__c>> >();
        for(Education_EducationGroup_Mapping__c EEGmapping :[SELECT 
                                                                e.Education_Group__c,e.PartnerId__c,e.Education__c, 
                                                                 e.Id,Education_Mentoring_Required__c,e.ContactId__c,
                                                                e.Contact_Status__c,Education_Mentoring_Completed__c,Education_Category__c 
                                                             FROM Education_EducationGroup_Mapping__c e
                                                             WHERE e.PartnerId__c IN : setPartnerGroupIds AND 
                                                              ( e.Contact_Status__c = 'Yes')])
        {
            if(MapPartnerGroupId_Educations.containskey(EEGmapping.PartnerId__c) ){
                Map<Id,List<Education_EducationGroup_Mapping__c>> MapEducationGrpId_Educations =  
                                   MapPartnerGroupId_Educations.get(EEGmapping.PartnerId__c) ;
                if(MapEducationGrpId_Educations.containskey(EEGmapping.Education_Group__c)){
                    MapEducationGrpId_Educations.get(EEGmapping.Education_Group__c).add(EEGmapping);
                }
                else{
                    List<Education_EducationGroup_Mapping__c> listEducations = new List<Education_EducationGroup_Mapping__c>();
                    listEducations.add(EEGmapping);
                    MapEducationGrpId_Educations.put(EEGmapping.Education_Group__c,listEducations) ;
                }
                // outer map has key as partner group Id 
                // inner map has Education GroupId as Key
            } // if the Key doesn't exist in the outer Map. 
            else{
                Map<Id,List<Education_EducationGroup_Mapping__c>> MapEducationGrpId_Educations =  
                                              new Map<Id,List<Education_EducationGroup_Mapping__c>>() ;
                List<Education_EducationGroup_Mapping__c> listEducations = new List<Education_EducationGroup_Mapping__c>();
                listEducations.add(EEGmapping); 
                MapEducationGrpId_Educations.put(EEGmapping.Education_Group__c,listEducations);
                MapPartnerGroupId_Educations.put(EEGmapping.PartnerId__c,MapEducationGrpId_Educations);
            }
            
            //populate mapEducationGroupResult map :contains partnerGroupId+EducationGroupid as key and set of contacts falls in education group
            if( (EEGmapping.ContactId__c != null) && (EEGmapping.Contact_Status__c =='Yes')){
                if(mapEducationGroupResult.containsKey(EEGmapping.PartnerId__c + '|' + EEGmapping.Education_Group__c)){
                    mapEducationGroupResult.get(EEGmapping.PartnerId__c + '|' + EEGmapping.Education_Group__c).add(EEGmapping.ContactId__c);
                }else{
                    mapEducationGroupResult.put(EEGmapping.PartnerId__c + '|' + EEGmapping.Education_Group__c, new Set<Id>());
                    mapEducationGroupResult.get(EEGmapping.PartnerId__c + '|' + EEGmapping.Education_Group__c).add(EEGmapping.ContactId__c);
                 system.debug('GROUPID CHAR -- ' +EEGmapping.PartnerId__c +'|'+EEGmapping.Education_Group__c);
                }
            }               
        }       
     } 
     
     public Set<Id> evaluateGroupRule(Velocity_Rules__c velocityRule, 
                                       Velocity_Rule_Results__c ruleResult){
        Set<Id>RuleLevelContactIds= null;
       //system.debug('INSIDE evaluateGroupRule()###' + velocityRule.name ); 
        if(mapGroupRuleResult.containskey(ruleResult.Grouping__c+'|'+ velocityRule.Id)){
            return mapGroupRuleResult.get(ruleResult.Grouping__c+'|'+ velocityRule.Id);
        }
        else{
            List<Education_Groups__c> listEducationGroups = 
                   mapRuleID_EducationGroups.get(velocityRule.Id);
            if(listEducationGroups != Null){
              system.debug('listEducationGroups()###'+ listEducationGroups.size()+'-- VELOCITY RULE:'+velocityRule.name );                     
            for(Education_Groups__c edugrp : listEducationGroups) {
                Set<Id> GroupLevelContactIds = new set<Id>();
                if(MapEducationGroupResult.containskey(ruleResult.Grouping__c+'|'+ edugrp.id)){
                    GroupLevelContactIds = MapEducationGroupResult.get(ruleResult.Grouping__c+'|'+ edugrp.id);
                }
                else {
                    //TODO.
                    List<Education_EducationGroup_Mapping__c> listEducation_EduGrpmapping = 
                                    getEducations(edugrp.Id,ruleResult.Grouping__c) ;
                    if(listEducation_EduGrpmapping!= null){
                        system.debug('EDUCATION GROUPID--'+edugrp.Id +' ACCOUNT GROUP -- '+ruleResult.Grouping__c);
                        GroupLevelContactIds = getEducationGroupedContacts(listEducation_EduGrpmapping,edugrp.Mentoring__c );
                    }
                    MapEducationGroupResult.put(ruleResult.Grouping__c+'|'+ edugrp.id,GroupLevelContactIds);
                    system.debug('CHECKING KEY - ' +ruleResult.Grouping__c+'|'+ edugrp.id);
                }
            
                if(RuleLevelContactIds ==Null){
                    RuleLevelContactIds=new set<ID>();
                    RuleLevelContactIds.addAll(GroupLevelContactIds);
                }
                else if(velocityRule.AND_OR__c =='AND'){
                    RuleLevelContactIds.retainAll(GroupLevelContactIds) ;
                }else{
                    RuleLevelContactIds.addAll(GroupLevelContactIds);
                }
             } //End of for-loop.
             mapGroupRuleResult.put(ruleResult.Grouping__c+'|'+ velocityRule.Id,RuleLevelContactIds);
            }  
         system.debug('RuleLevelContactIds #### :'+ RuleLevelContactIds);   
            return RuleLevelContactIds;       
        }
    } //End of Method -evaluateGroupRule.
      
    List<Education_EducationGroup_Mapping__c> getEducations(Id EducationGroupId, Id PartnerGroupingId){
        List<Education_EducationGroup_Mapping__c> ListEducationGroupMapping ;
        Map<Id,List<Education_EducationGroup_Mapping__c>> MapEducationGrpId_Educations = 
                                         MapPartnerGroupId_Educations.get(PartnerGroupingId);
        if(MapEducationGrpId_Educations!= null){
            ListEducationGroupMapping = MapEducationGrpId_Educations.get(EducationGroupId); 
        }
        return ListEducationGroupMapping ;  
    } //End of method - getEducations.
  
  
    Set<Id> getEducationGroupedContacts(List<Education_EducationGroup_Mapping__c> EducationsMappings, 
              boolean isMentoring){
        set<Id> setContactIds = new set<Id>();
        if(EducationsMappings != null){
         system.debug('INSIDE getEducationGroupedContacts#METHOD');
         system.debug('EDUCATION GROUP MENTORING -'+ isMentoring);              
            for(Education_EducationGroup_Mapping__c EEMobj : EducationsMappings){
             if(!setContactIds.contains(EEMobj.ContactId__c)){
                
            /*  if(isMentoring && (EEMobj.Education_Mentoring_Required__c =='Yes')){
                 setContactIds.add(EEMobj.ContactId__c);
               }*/
               if( isMentoring && (EEMobj.Education_Mentoring_Completed__c =='Yes' )){
                   setContactIds.add(EEMobj.ContactId__c);
               }else if(!isMentoring ){
                  setContactIds.add(EEMobj.ContactId__c);              
              }
              
            }
          }//End of for loop.
        }   
        return setContactIds ;
    } //End of method - getEducationGroupedContacts.

         /************ SPECALITY RULE *****************/ 
   /* Specality Rule */
  public Integer evaluateSpecialtyRule(Velocity_Rules__c velocityRule,Velocity_Rule_Results__c ruleResult){
    
    /* revenue Logic on the basis of Bucket */
     if(velocityRule.Bucket__c == 'Revenue'){
        Account profiledAccountRecord = MapPartnerGroupId_ProfiledAccount.get(ruleResult.Grouping__c); 
        System.debug('profiledAccountRecord  '+profiledAccountRecord );
        System.debug('ruleResult.Grouping__c  '+ruleResult.Grouping__c );
        //TODO SPECALITy RUle
    Double count = getRevenueforSpecialityRules(velocityRule,profiledAccountRecord,revenueProfiledAccountMap);    
         //Commented for Invalid conversion from runtime type Double to Integer
         //return count.intValue();
      Integer countValue = count.intValue();
   // Integer countvalue =0;
      return countValue;       
     }else{
   //TODO - getting subrules.
    set<Id> setGroupRules = new set<Id>(); 
      if(velocityRule.Velocity_Rule_1__c != null ){
         setGroupRules.add(velocityRule.Velocity_Rule_1__c);
      }
      if(velocityRule.Velocity_Rule_2__c != null ){
         setGroupRules.add(velocityRule.Velocity_Rule_2__c);
      } 
      //Added by Anil
      if(velocityRule.Group_Rule_3__c != null ){
         setGroupRules.add(velocityRule.Group_Rule_3__c);
      }   
       if(velocityRule.Group_Rule_4__c != null ){
         setGroupRules.add(velocityRule.Group_Rule_4__c);
      }   
       if(velocityRule.Group_Rule_5__c != null ){
         setGroupRules.add(velocityRule.Group_Rule_5__c);
      }   
 
 
    for(Id velocityGroupRuleId : setGroupRules ) {
       Velocity_Rules__c velocitygroupRule = mapGroupRules.get(velocityGroupRuleId);
       if(velocitygroupRule != Null){ 
          evaluateGroupRule(velocitygroupRule,ruleResult);
       }    
      } //End of for loop.
    if(velocityRule.AND_OR__c == 'AND'){
          return evaluateAndOperation(setGroupRules,ruleResult.Grouping__c,mapGroupRuleResult);
    }else{
          return evaluateOROperation(setGroupRules,ruleResult.Grouping__c,mapGroupRuleResult);
    }
   } 
  } //End of method - evaluateSpecialtyRule.    
 
 Integer evaluateANDOperation(set<Id> groupRuleIds,Id partnerGroupingId,
                              Map<String, Set<Id>> mapGroupRuleResult){
   set<Id> setContactIds ;
   set<Id> setGrpRuleContactIds ;
   if((groupRuleIds != null) && (groupRuleIds.size()>0)){
   for(Id grpRuleId : groupRuleIds){
     if(setContactIds  == Null){
       setGrpRuleContactIds = mapGroupRuleResult.get( partnerGroupingId +'|'+ grpRuleId);
       if(setGrpRuleContactIds != null) {
         setContactIds = new Set<ID>();
         setContactIds.addall(setGrpRuleContactIds);
       }
     }else{
       setGrpRuleContactIds = mapGroupRuleResult.get(partnerGroupingId +'|'+ grpRuleId);
       if(setGrpRuleContactIds != null) {
         setContactIds.retainall(mapGroupRuleResult.get( partnerGroupingId +'|'+ grpRuleId));
       }
      }
    } // End of for -loop.
   }if(setContactIds == Null){
    setContactIds = new Set<ID>();
   }
    return setContactIds.size(); 
  } // End of method -evaluateAndOperation.
  
  Integer evaluateOROperation(set<Id> GroupRuleIds,Id PartnerGroupingId,
                              Map<String, Set<Id>> mapGroupRuleResult){
    set<Id> setContactIds = new Set<ID>();
    set<Id> setGrpRuleContactIds ;
   for(Id grpRuleId : groupRuleIds){
       setGrpRuleContactIds = mapGroupRuleResult.get( partnerGroupingId +'|'+ grpRuleId);
       if(setGrpRuleContactIds != null) {
       setContactIds.addall(setGrpRuleContactIds);
      }
    }
    return setContactIds.size(); 
  } // End of method -evaluateOROperation.
  
    /**************** End of Suman Changes. ****************/ 

    /********************Ashwini Methods ***********************************/
   
 /* @Method <evaluateRollupRules(): This method would be called from batch job to evaluate
                                    the roll up rules.The batch job will iterate over the velocity
                                    Rule Result.>
       @param - <Velocity_Rules__c velocityRule, Velocity_Rule_Results__c ruleResult>
       @return <Account> - <Profiled Account>
       @throws exception - <No Exception>
*/  
    public Account evaluateRollupRules(Velocity_Rules__c velocityRule, Velocity_Rule_Results__c ruleResult){
        Account profiledAccountRecord = null;
        if(ruleResult.Grouping__c != null){
            if(MapPartnerGroupId_ProfiledAccount.containsKey(ruleResult.Grouping__c)){
                profiledAccountRecord = MapPartnerGroupId_ProfiledAccount.get(ruleResult.Grouping__c);  
                 system.debug('INSIDE evaluateRollupRules groupingId::'+profiledAccountRecord.Grouping__c);           
                if((mapTheater_RollupRules != Null) && (mapTheater_RollupRules.containskey(profiledAccountRecord.Theater1__c)) ){
                   system.debug('PROFILED ACCOUNT THEATER -- '+profiledAccountRecord.Theater1__c);
                   for(Velocity_Rules__c rollupRule: mapTheater_RollupRules.get(profiledAccountRecord.Theater1__c)){
                        Set<Id> setContactIds= evaluateGroupRule(rollupRule, ruleResult);
                        if(setContactIds != null ){
                           system.debug('setContactIds size---->'+setContactIds.size());
                            Integer count = setContactIds.size();
                            profiledAccountRecord.put(rollupRule.Field_Name__c,count);
                            System.debug('rollupRule.Field_Name__c---->'+rollupRule.Field_Name__c);
                            System.debug('profiledAccountRecord---->'+profiledAccountRecord);
                        }                   
                      } 
                    }               
                }
            }
        return profiledAccountRecord;      
    }
        
/* @Method <evaluateTierRule(): This method would be called from batch job to evaluate
                                the tier rules.The batch job will iterate over the velocity
                                Rule Result.>
   @param - <Velocity_Rules__c rule, Velocity_Rule_Results__c result>
   @return - <String>
   @throws exception - <No Exception>
*/
    public String evaluateTierRule(Velocity_Rules__c rule, Velocity_Rule_Results__c result){
     system.debug('INSIDE -TIER RULE # VRR --'+result);
        Map<Id,Account> profiledAccountMap = MapPartnerGroupId_ProfiledAccount;
        Account profiledAccount = profiledAccountMap.get(result.Grouping__c);
        //double tierRuleValue = 0;
        String tierRuleValue = '';
        if(rule.Bucket__c=='Revenue' ){
            tierRuleValue = getRevenueforTierRules(rule,profiledAccount,revenueProfiledAccountMap);
        }
        /*if(rule.Bucket__c=='Revenue' && rule.Local_Requirment_Set__c != null && rule.Local_Requirment_Set__c != ''){
            tierRuleValue = getRevenueforLocalReqTierRules(rule,profiledAccount,revenueProfiledAccountMap);
        }*/
        if(rule.Bucket__c=='SSCP'){
            tierRuleValue = isSSCP(profiledAccount);
        }
        if(rule.Bucket__c=='VSI' || rule.Bucket__c=='Velocity Services Implement'){
            tierRuleValue = isVSI(profiledAccount);
        }
        /* This logic is miograted to rollup rule evalution
        if(rule.Bucket__c=='Velocity Program'){
            tierRuleValue = isVelocityProgram(profiledAccount);
        }*/
        if(rule.Bucket__c=='Training'){
            tierRuleValue = isTraining(rule,result);
        }
        return tierRuleValue;
    }

/* @Method <getRevenueDetails(): This method would fetch all revenues associated to profiled Account and create
                                 a Map of Profiled Account Id and Revenue associated to it.>
   @param - <Set<Id> setProfiledAccountIds>
   @return - <Map<Id,Velocity_Revenue__c>: return a Map of Profiled Account Id and revenue associate to it>
   @throws exception - <No Exception>
*/  
    public Map<Id,Velocity_Revenue__c> getRevenueDetails(Set<Id> setProfiledAccountIds){
        Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap = new Map<Id,Velocity_Revenue__c>(); 
        List<Velocity_Revenue__c> velocityRevenueList = [Select v.AC_Curr_Per_Rev_HW_SW__c, v.AC_Curr_Per_Rev_SVS__c, 
                                        v.AC_Prev_Per_Rev_HW_SW__c, v.AC_Prev_Per_Rev_SVS__c, v.BR_Curr_Per_Rev_HW_SW__c, 
                                        v.BR_Curr_Per_Rev_SVS__c, v.BR_Prev_Per_Rev_HW_SW__c, v.BR_Prev_Per_Rev_SVS__c, 
                                        v.C_Curr_Per_Rev_HW_SW__c, v.C_Curr_Per_Rev_SVS__c, v.C_Prev_Per_Rev_HW_SW__c, 
                                        v.C_Prev_Per_Rev_SVS__c, v.GA_Curr_Per_Rev_HW_SW__c, v.GA_Curr_Per_Rev_SVS__c, 
                                        v.GA_Prev_Per_Rev_HW_SW__c, v.GA_Prev_Per_Rev_SVS__c, v.Id, 
                                        v.Partner_Profiled_Account__c, v.Total_Product_Curr_Per_Rev_HW_SW__c, 
                                        v.Total_Product_Prev_Per_Rev_HW_SW__c, v.Total_Services_Curr_Per_Rev_SVS__c,
                                        v.Total_Services_Prev_Per_Rev_SVS__c 
                                        from Velocity_Revenue__c v 
                                        where Partner_Profiled_Account__c in: setProfiledAccountIds];
        for(Velocity_Revenue__c revenue: velocityRevenueList){
            if(!revenueProfiledAccountMap.containsKey(revenue.Partner_Profiled_Account__c)){
                revenueProfiledAccountMap.put(revenue.Partner_Profiled_Account__c,revenue);
            }
        }   
        return revenueProfiledAccountMap;                                   
    }
   
 /* @Method <getRevenueforTierRules(): This method would calculate the revenue for Tier Rules
                                       based on theater,tier type and display Name.>
   @param - <Velocity_Rules__c rule,Account profiledAccount,Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap>
   @return - <String>
   @throws exception - <No Exception>
*/
    //Revenue calculation for Tier Rules
    public String getRevenueforTierRules(Velocity_Rules__c rule,Account profiledAccount,
                                            Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap){     
        String revenueAmountforTierRules = '0';
        Map<String,RevenueSpeciality__c> revenueValues = RevenueSpeciality__c.getAll(); 
        Map<String, String> tierRevenueValueMap = new Map<String, String>();    
        Velocity_Revenue__c velocityRevenue = revenueProfiledAccountMap.get(profiledAccount.id);    
        if(velocityRevenue!=null){
            double tierRevenueAmount = 0; 
           String ruleKey = rule.Display_Name__c+'|'+rule.Cluster__c+'|'+rule.Tier__c;    
           for(RevenueSpeciality__c revenue: revenueValues.values()){
              String strKey = revenue.Specialty__c+'|'+revenue.Theater__c+'|'+revenue.TierType__c;
                if(!tierRevenueValueMap.containsKey(strKey)){
                    tierRevenueValueMap.put(strKey,revenue.RevenueValues__c);
                }
            }
            if(tierRevenueValueMap.containsKey(ruleKey)){
                List<String> tierRevenueTableValues = (tierRevenueValueMap.get(ruleKey)).split(',');
                for(String tierRevenue: tierRevenueTableValues){
                    if(tierRevenue!=''){
                        if(velocityRevenue.get(tierRevenue)!=null){
                            tierRevenueAmount = tierRevenueAmount+double.valueOf(''+velocityRevenue.get(tierRevenue));
                        }    
                    }
                }
            }
            revenueAmountforTierRules = String.ValueOf(tierRevenueAmount);
            //return tierRevenueAmount;
        }
        return revenueAmountforTierRules;
    }
    
/* @Method <isSSCP(): This method would check if account is Solution_Center_Implemented.>
   @param - <Account profiledAccount>
   @return - <String: return 'Yes' if Solution_Center_Implemented__c is Yes else 'No'>
   @throws exception - <No Exception>
*/  
    public String isSSCP(Account ProfiledAccount){
        system.debug('Inside isSSCP()');
        String isSSCP = 'No';
        if(ProfiledAccount.Solution_Center_Implemented__c=='Yes'){
            isSSCP = 'Yes';
        }       
        return isSSCP;
    }
    
/* @Method <isVSI(): This method would check if account is Velocity_Services_Implement.>
   @param - <Account profiledAccount>
   @return - <String: return '1' if Velocity_Services_Implement__c is Yes else '0'>
   @throws exception - <No Exception>
*/  
    public String isVSI(Account ProfiledAccount){
        system.debug('Inside isVSI()');
        String isVSI = 'No';
        if(ProfiledAccount.Velocity_Services_Implement__c=='Yes'){
            isVSI = 'Yes';
        }       
        return isVSI;
    }
    
/* @Method <isVelocityProgram(): This method would check if different specialities of 
                                 account is Achieved or not, based on that it would 
                                 return the sum of no.of specialities achieved.>
   @param - <Account profiledAccount>
   @return - <String: return count of no.of specialities achieved>
   @throws exception - <No Exception>
*/      
    public String isVelocityProgram(Account ProfiledAccount){
       system.debug('Inside isVelocityProgram()');
        double count = 0;
        if(ProfiledAccount.Advanced_Consolidate_Compliance_Status__c=='Yes'){
            count=count+1;
        }
        if(ProfiledAccount.Backup_and_Recovery_Compliance_Status__c=='Yes'){
            count=count+1;
        }
        if(ProfiledAccount.Consolidate_Compliance_Status__c=='Yes'){
            count=count+1;
        }
        if(ProfiledAccount.Governance_and_Archive_Compliance_Status__c =='Yes'){
            count=count+1;
        }
        String velocityProgramValues = String.ValueOf(count);
        //return count;
        return velocityProgramValues;
    }
/* @Method <isTraining(): This method would check if bucket associated to rule is 
                                 training and return no.of contacts completed it.>
   @param - <Velocity_Rules__c rule,Velocity_Rule_Results__c result>
   @return - <String>
   @throws exception - <No Exception>
*/  
    public String isTraining(Velocity_Rules__c rule,Velocity_Rule_Results__c result){
      system.debug('Inside isTraining()');  
        double count = 0;
        Set<Id> setContactIds = evaluateGroupRule(rule, result);
        if(setContactIds != null && setContactIds.size() >0){
            count = evaluateGroupRule(rule, result).size();
        }
        //return count;
        String trainingValue = String.valueOf(count);
        return trainingValue;
    }
    
/* @Method <getRevenueforSpecialityRules(): This method would calculate the revenue for Speciality 
                                            Rules based on theater and Speciality.>
   @param - <Velocity_Rules__c rule,Account profiledAccount>
   @return - <double>
   @throws exception - <No Exception>
*/
    //For revenue calculation in Speciality Velocity Rules 
    public double getRevenueforSpecialityRules(Velocity_Rules__c rule,Account profiledAccount,
                                                Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap){
        double specialityRevenueAmount = 0;
        Map<String,VPP_Speciality_Revenue_Calculations__c> specialityRevenueValues = 
                                                    VPP_Speciality_Revenue_Calculations__c.getAll();    
        Map<String,String> specialityRevenueValueMap = new Map<String,String>();
        System.debug('revenueProfiledAccountMap '+revenueProfiledAccountMap);
        System.debug('profiledAccount '+profiledAccount );
        Velocity_Revenue__c velocityRevenue = revenueProfiledAccountMap.get(profiledAccount.id);    
        if(velocityRevenue ==null ){
            return specialityRevenueAmount ;
        }
        
        String ruleKey = rule.Specialty_Rule_Type__c+'|'+rule.Specilaity__c;
        for(VPP_Speciality_Revenue_Calculations__c specialityRevenue: specialityRevenueValues.values()){
            String strKey = specialityRevenue.Specialty_Rule_Type__c+'|'+specialityRevenue.Specilaity__c;
            if(!specialityRevenueValueMap.containsKey(strKey)){
                specialityRevenueValueMap.put(strKey,specialityRevenue.SpecialityRevenueValues__c);
            }
        }
        if(specialityRevenueValueMap.containsKey(ruleKey)){
            List<String> specialityRevenueTableValues = (specialityRevenueValueMap.get(ruleKey)).split(',');            
            System.debug('specialityRevenueTableValues-->'+specialityRevenueTableValues);
            for(String specialityRevenue: specialityRevenueTableValues){
                if(specialityRevenue!=''){
                    if(velocityRevenue.get(specialityRevenue)!=null){
                        System.debug('velocityRevenue.get(specialityRevenue)-->'+velocityRevenue.get(specialityRevenue));
                        specialityRevenueAmount = specialityRevenueAmount+
                                                double.valueOf(''+velocityRevenue.get(specialityRevenue));           
                    }    
                }
            }           
        }
     system.debug('END OF - getRevenueforSpecialityRules()' );   
        return specialityRevenueAmount;
    }

/* @Method <getRevenueRange(): This method would calculate the range based on the current
                               and actual values percentage.>
   @param - <Velocity_Rule_Results__c result>
   @return - <String>
   @throws exception - <No Exception>
*/  
    public String getRevenueRange(Velocity_Rule_Results__c result){
        integer revenueRange = 0;
        integer resultValue = 0;
        double revenueValue = 0;
        String revenueDetails = ''; 
        Map<String,VelocityRules__c> data = VelocityRules__c.getall();
        Integer rangeValue = data.get('RevenueRange').RangeValue__c.intValue();
        System.debug('rangeValue---->'+rangeValue);
        //Added Custom setting to check if the goal is achieved if greater than 100%
        Integer revenueGoalAchieved = data.get('GoalAttained').RangeValue__c.intValue();
        String displayRevenue = data.get('RevenueDetails').SpecialityRules__c; 
        String revenueAchieved = data.get('RevenueAchieved').SpecialityRules__c; 

        if(result.Revenue_Amount__c!=null &&
            result.RequiredCount__c!=null &&
            result.RequiredCount__c!='set by GAF' &&
            result.Required_Value_Type__c=='USD' ){
            if(result.RequiredCount__c!='0'){
                System.debug('Inside Revenue Range Method'+result.Revenue_Amount__c);                       
                revenueValue =(double.valueOf((result.Revenue_Amount__c))/double.valueOf((result.RequiredCount__c)))*100;           
                revenueRange = revenueValue.intValue();
                resultValue = Math.MOD(revenueRange,rangeValue);                
                if(revenueRange==0){
                    revenueDetails = ''+0+'%-'+rangeValue+'%';
                }
                //Added as per Req#2599 to check if revenue is greater than 100%
                else if(revenueValue>=revenueGoalAchieved){
                    //revenueDetails = displayRevenue+'+';
                revenueDetails = revenueAchieved;
                System.debug('revenueDetails-->'+revenueDetails);
                }
                else if(resultValue==0){
                    revenueDetails = revenueRange+'%-'+(revenueRange+rangeValue)+'%';
                }
                else if(revenueValue<rangeValue){
                    revenueDetails = (revenueRange-resultValue)+'%-'+rangeValue+'%';
                }                
                else{
                    revenueDetails = (revenueRange-resultValue)+'%-'+(revenueRange+rangeValue-resultValue )+'%';
                }

            }else{
                revenueDetails = displayRevenue;
            }
            
        }
        System.debug('revenueDetails-->'+revenueDetails);
        return revenueDetails;
    }  

/* @Method <checkComplianceStatus(): This method would check the Status of each Speciality and associates
                                     Compliance status against each speciality based on Status
                                     Sets complianceStatus = 'Non-compliant' if status is 'Not Achieved'
                                     Sets complianceStatus = 'Compliant' if status is 'Achieved'.>
   @param - <Account profiledAccount,List<Velocity_Rule_Results__c> velocityRuleResults>
   @return - Map<String,String>
   @throws exception - <No Exception>
*/  
    public Map<String,String> checkComplianceStatus(Account profiledAccount,List<Velocity_Rule_Results__c> velocityRuleResults){
        Map<String,boolean> complianceStatusMap = new Map<String,boolean>();
        Map<String,String> complianceStatusValuesMap = new Map<String,String>();
        for(Velocity_Rule_Results__c ruleResults: velocityRuleResults){
          System.debug('ruleResults.Speciality_RuleID__r.RecordType.DeveloperName '+ ruleResults.Speciality_RuleID__r.RecordType.DeveloperName );
            if(ruleResults.Speciality_RuleID__r.RecordType.DeveloperName == 'Specialty_Rule'){
              // Added by Suman for WR#180938.
              // Passing BR_Sub_category__c as a specality for 'Backup and Recovery'.
               if(ruleResults.Speciality_RuleID__r.BR_Sub_category__c != Null){
                  complianceStatusMap = getComplianceStatus(complianceStatusMap,
                                                        ruleResults.Speciality_RuleID__r.BR_Sub_category__c,ruleResults);
               }
               else{                            
                complianceStatusMap = getComplianceStatus(complianceStatusMap,
                                                        ruleResults.Speciality_RuleID__r.Specilaity__c,ruleResults);
               }                                                            
            } // End of Specialty_Rule condition.
            else if(ruleResults.Speciality_RuleID__r.RecordType.DeveloperName =='Tier_Rule'){
                complianceStatusMap = getComplianceStatus(complianceStatusMap,'Tier Rule',ruleResults);
            }
            System.debug('complianceStatusMap '+complianceStatusMap);
        } // End of for loop.
        System.debug('complianceStatusMap ----'+complianceStatusMap);
       
        if(complianceStatusMap.size()>0){
            for(String compliance: complianceStatusMap.KeySet()){
              if(compliance != 'Networker' && compliance != 'Avamar') {
                if(complianceStatusMap.get(compliance)==false){
                    complianceStatusValuesMap.put(compliance,'No');
                }
                else{
                    complianceStatusValuesMap.put(compliance,'Yes');
                }
             }   
           } // End of for loop.
          
          // Added condtion to check for specality - 'Backup and Recovery' based on the BR_Sub_category__c.
           if(complianceStatusMap.containskey('Networker') || complianceStatusMap.containskey('Avamar')){
                Boolean NetworkerStatus = false;
                Boolean AvamarStatus = false;
                if(complianceStatusMap.get('Networker')== true){
                    NetworkerStatus = true;
                }
                if(complianceStatusMap.get('Avamar')== true){
                    AvamarStatus = true;
                }
                complianceStatusValuesMap.put('Backup and Recovery', (AvamarStatus || NetworkerStatus)? 'Yes' :'No');  
           }
           // Changes End - WR#180938. 
        } // End of complianceStatusMap size condition.
        System.debug('complianceStatusValuesMap #### '+complianceStatusValuesMap);
        return complianceStatusValuesMap;
    } 

/* @Method <getComplianceStatus(): This method would check the Status of each Speciality and associates
                                     Compliance status against each speciality based on Status
                                     Sets complianceStatus = 'Non-compliant' if status is 'Not Achieved'
                                     Sets complianceStatus = 'Compliant' if status is 'Achieved'.>
   @param - <Map<String,boolean> complianceValues,String specialityValue,
                                                    Velocity_Rule_Results__c ruleResult>
   @return - Map<String,boolean>
   @throws exception - <No Exception>
*/  
    public Map<String,boolean> getComplianceStatus(Map<String,boolean> complianceValues,String specialityValue,
                                                    Velocity_Rule_Results__c ruleResult){
        System.debug('ruleResult.Status__c '+ruleResult.Status__c);
        if(!complianceValues.containsKey(specialityValue)){
            if(ruleResult.Status__c=='Not Achieved'){
                complianceValues.put(specialityValue,false);
                
            }
            else if(ruleResult.Status__c=='Achieved'){
               complianceValues.put(specialityValue,true);     
            }
        }
        else{
            if(ruleResult.Status__c=='Not Achieved'){
                complianceValues.put(specialityValue,(False && complianceValues.get(specialityValue)));
            }
            else if(ruleResult.Status__c=='Achieved'){
                complianceValues.put(specialityValue,(True && complianceValues.get(specialityValue)));
            }   
        }
        System.debug('complianceValues '+complianceValues);
        return complianceValues;
    }   
    
    public Account updateCompilanceStatus(Account objAccount,List<Velocity_Rule_Results__c> CurrentAccountVRR){
                  
         if(objAccount != null){
            //Assigns compliance status value against each profiled Account for diff specialities.
            //System.debug('CurrentAccountVRR '+CurrentAccountVRR);
            Map<String,String> complianceStatusValuesMap = checkComplianceStatus(objAccount,CurrentAccountVRR);
            objAccount.put('Consolidate_Compliance_Status__c',complianceStatusValuesMap.get('Consolidate'));
            objAccount.put('Backup_and_Recovery_Compliance_Status__c',complianceStatusValuesMap.get('Backup and Recovery'));
            objAccount.put('Advanced_Consolidate_Compliance_Status__c',complianceStatusValuesMap.get('Advanced Consolidate'));
            objAccount.put('Governance_and_Archive_Compliance_Status__c',complianceStatusValuesMap.get('Governance and Archive'));              
            objAccount.put('Velocity_Compliance_Status__c',complianceStatusValuesMap.get('Tier Rule'));
            System.debug('objAccount-->'+objAccount);
           
          }
          return objAccount;
    }
    
    //Private Helper Method
    
    //Return set of contacts from mapGroupRuleResult
    private Set<Id> getGroupedContacts(Id EduationGroupId){
        Set<Id> setContactId = new Set<Id>();
        if(mapGroupRuleResult.containsKey(EduationGroupId)){
            setContactId = mapGroupRuleResult.get(EduationGroupId);
        }        
        return setContactId; 
    }
    
    //Return List of Groups from mapRuleID_EducationGroups
    private List<Education_Groups__c> getRuleGroups(Id VelocityRuleId){
        List<Education_Groups__c> ListEducationGroup = new List<Education_Groups__c>();
        if(mapRuleID_EducationGroups.containsKey(VelocityRuleId)){
            ListEducationGroup = mapRuleID_EducationGroups.get(VelocityRuleId);
        }        
        return ListEducationGroup;      
    } 
    
    private List<Account> fecthAccount(Set<Id> setAccountId){
        List<Account> lstAccount = new List<Account>();
        string query1 = 'Select Id,Name,Grouping__c,Theater1__c,'
                          +'Velocity_Services_Implement__c,Solution_Center_Implemented__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,'
                          +'Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Compliance_Status__c,Deployed_Velocity_Services__c,(select Id,Products__c,Services_Program_Designation__c,Partner_Deployment_End_Date__c from Velocity_Services__r)';
        string query2 = ' From Account Where Id in:setAccountId';
        string query = '';
        Schema.DescribeFieldResult fieldResult = Velocity_Rules__c.Field_Name__c.getDescribe();
        List<Schema.PicklistEntry> pickListValue= fieldResult.getPicklistValues();
        system.debug('pickListValue----->' +pickListValue);
        for( Schema.PicklistEntry value : pickListValue){
            if(query.length() < 9000){ 
                query = query + value.getLabel()+',';
            }
        } 
        query = query.substring(0,query.lastIndexOf(','));
        query = query1 + query + query2;
        lstAccount = Database.query(query); 
        //Modified By Arif for cloud builder.
        
       /* lstAccount = [Select Id, Name, Count_of_Affiliate_Enablement_Center_SA__c,Count_of_Affiliate_Enablement_Center_SE__c, 
                            Count_of_Advanced_Sales_Accreditations__c, Count_of_Associate_Foundations__c, Count_of_Content_Management__c,
                            Count_of_Customer_Engineers__c, Count_of_Implementation_Engineers__c, Count_of_Product_Certifications__c,
                            Count_of_Quick_Starts__c, Count_of_Sales_Accreditations__c, Count_of_SE_Accreditations__c, Count_of_Storage_Administrators__c,
                            Count_of_Technology_Architects__c, Count_of_Trainings__c, Count_of_Velocity_System_Engineers__c , Grouping__c, Theater1__c,
                            Advanced_Consolidate_Specialty__c,Backup_and_Recovery_Speciality__c,Consolidate_Specialty__c,Governance_and_Archive_Specialty__c,
                            Velocity_Services_Implement__c,Solution_Center_Implemented__c,Advanced_Consolidate_Compliance_Status__c,Backup_and_Recovery_Compliance_Status__c,
                            Consolidate_Compliance_Status__c,Governance_and_Archive_Compliance_Status__c,Velocity_Specialties_Achieved__c,Velocity_Compliance_Status__c,Deployed_Velocity_Services__c   
                         From Account Where Id in:setAccountId]; */
        return lstAccount;
    }
    
    private Map<Id, Velocity_Rules__c> fetchRollupRuleRecord(){
        Map<Id, Velocity_Rules__c> mapVelocityRollupRule = new Map<Id, Velocity_Rules__c>(
                                                    [Select Id, Name, AND_OR__c, BR_Sub_category__c, Bucket__c,
                                                     Display_Name__c,Velocity_Rule_1__c,Velocity_Rule_2__c,Group_Rule_3__c,Group_Rule_4__c, 
                                                     Group_Rule_5__c, Required__c, Required_Type__c,Field_Name__c, Specialty_Rule_Type__c,
                                                     Specilaity__c, Tier__c, Is_Total_Revenue__c,Theater__c,Cluster__c
                                                     FROM  Velocity_Rules__c 
                                                     WHERE RecordType.DeveloperName ='Rollup_Rule'
                                                     limit: Limits.getLimitQueryRows()]);       
        return mapVelocityRollupRule;
    }
    
    private Map<Id, Velocity_Rules__c> fetchGroupRuleRecord(Set<Id> setGroupRuleIds){
        Map<Id, Velocity_Rules__c> mapVelocityGroupRule = new Map<Id, Velocity_Rules__c>(
                                                    [Select Id, Name, AND_OR__c,  BR_Sub_category__c, Bucket__c,Local_Requirment_Set__c,
                                                     Display_Name__c, Velocity_Rule_1__c,Velocity_Rule_2__c,Group_Rule_3__c,Group_Rule_4__c, 
                                                     Group_Rule_5__c, Required__c, Required_Type__c,Field_Name__c, Specialty_Rule_Type__c,
                                                     Specilaity__c, Tier__c, Is_Total_Revenue__c,Theater__c,Cluster__c
                                                     FROM  Velocity_Rules__c 
                                                     WHERE RecordType.DeveloperName ='Group_Rule' AND Id in: setGroupRuleIds
                                                     limit: Limits.getLimitQueryRows()]);       
        return mapVelocityGroupRule;
    }
    
    private Map<Id, List<Education_Groups__c>> populateVelocityRuleWithEducationGroup(List<Velocity_Rule_Results__c> lstVelocityRuleResults){
        Set<Id> setVelocityRuleIds = new Set<Id>();
        Set<Id> setEducationGroup = new Set<Id>();
        Map<Id, Education_Groups__c> mapEducationGroup = new Map<Id, Education_Groups__c>();
        Map<Id, List<Education_Groups__c>> mapTempVelruleWithEducationGroup = new Map<Id, List<Education_Groups__c>>();
        
        for(Velocity_Rule_Results__c velRuleResult :lstVelocityRuleResults){
            if(velRuleResult.Speciality_RuleID__c != null){
                setVelocityRuleIds.add(velRuleResult.Speciality_RuleID__c);
            
                Velocity_Rules__c objVelRule = velRuleResult.Speciality_RuleID__r;
                System.debug('objVelRule ==> '+objVelRule );
                if(objVelRule != null && objVelRule.Velocity_Rule_1__c != null){
                    setVelocityRuleIds.add(objVelRule.Velocity_Rule_1__c);
                }
                if(objVelRule != null && objVelRule.Velocity_Rule_2__c != null){
                    setVelocityRuleIds.add(objVelRule.Velocity_Rule_2__c);
                }
                //Added by Anil
                if(objVelRule != null && objVelRule.Group_Rule_3__c != null){
                    setVelocityRuleIds.add(objVelRule.Group_Rule_3__c);
                }
                if(objVelRule != null && objVelRule.Group_Rule_4__c != null){
                    setVelocityRuleIds.add(objVelRule.Group_Rule_4__c);
                }
                if(objVelRule != null && objVelRule.Group_Rule_5__c != null){
                    setVelocityRuleIds.add(objVelRule.Group_Rule_5__c);
                }                
            }
        }
    /*ADDING ROLLUP RULE IDS TO FETCH THE DATA*/
        if( (mapRollupRules!=null) && (mapRollupRules.size()>0) ){
          setVelocityRuleIds.addall(mapRollupRules.keyset());
        }
        if(setVelocityRuleIds.size() >0){
            Map<Id, Velocity_Rule_Member__c> mapTempEducationGroup = new Map<Id, Velocity_Rule_Member__c>(
                                                                [Select v.Speciality_Rule__c, v.Name, v.Id, v.Group__c ,                                                                        
                                                                    v.Group__r.Education_Group_Name__c, v.Group__r.Mentoring__c, 
                                                                    v.Group__r.Name, v.Group__r.Id 
                                                                 From   Velocity_Rule_Member__c v
                                                                 WHERE  Speciality_Rule__c in: setVelocityRuleIds
                                                                ]);
            
            for(Velocity_Rule_Member__c objVelRuleMember : mapTempEducationGroup.values()){             
                if(objVelRuleMember.Group__c != null){
                    setEducationGroup.add(objVelRuleMember.Group__c);
                }
            }   
                                                             
            if(setEducationGroup.size() >0){
                mapEducationGroup = new Map<Id, Education_Groups__c>([Select Id, Name, Education_Group_Name__c, Mentoring__c 
                                                                      From   Education_Groups__c
                                                                      WHERE id in: setEducationGroup]);
            }  
                                                                          
            if(mapTempEducationGroup != null && mapTempEducationGroup.size() >0){
                for(Velocity_Rule_Member__c objVelRuleMember : mapTempEducationGroup.values()){
                    Education_Groups__c objEducations = mapEducationGroup.get(objVelRuleMember.Group__c);
                    if(mapTempVelruleWithEducationGroup.containsKey(objVelRuleMember.Speciality_Rule__c)){
                        mapTempVelruleWithEducationGroup.get(objVelRuleMember.Speciality_Rule__c).add(objEducations);
                    }else{
                        mapTempVelruleWithEducationGroup.put(objVelRuleMember.Speciality_Rule__c, new List<Education_Groups__c>());
                        mapTempVelruleWithEducationGroup.get(objVelRuleMember.Speciality_Rule__c).add(objEducations);
                    }
                }
            }       
        }
        system.debug('mapTempVelruleWithEducationGroup ###'+ mapTempVelruleWithEducationGroup);        
        return mapTempVelruleWithEducationGroup;
    }
  
    public  Map<Id,List<Velocity_Rule_Results__c>> fetchVelocityRuleResults(List<Account> accounts){
      Set<Id> setAccountIds = new Set<Id>();
      for(Account acc: accounts){
          setAccountIds.add(acc.Id);
      }
      List<Velocity_Rule_Results__c> vrrs= [ Select Revenue_Amount__c, Required_value_Type__c,v.Speciality_RuleID__c, Speciality_RuleID__r.Local_Requirment_Set__c,
                                            v.Rule_theater__c, status__c,v.RequiredCount__c,Speciality_RuleID__r.RecordType.Name ,
                                            Speciality_RuleID__r.RecordType.DeveloperName, v.Name, v.Grouping__c, v.Current__c, 
                                            v.Account_Theater__c,Speciality_RuleID__r.RecordTypeId ,Speciality_RuleID__r.Bucket__c, 
                                            Speciality_RuleID__r.AND_OR__c, Speciality_RuleID__r.Velocity_Rule_2__c, Speciality_RuleID__r.Velocity_Rule_1__c,
                                            Speciality_RuleID__r.Group_Rule_3__c, Speciality_RuleID__r.Group_Rule_4__c, Speciality_RuleID__r.Group_Rule_5__c,
                                            Speciality_RuleID__r.Cluster__c, Speciality_RuleID__r.BR_Sub_category__c,
                                            Speciality_RuleID__r.Display_Name__c, Speciality_RuleID__r.Required_Type__c,Speciality_RuleID__r.Field_Name__c,
                                            Speciality_RuleID__r.Specialty_Rule_Type__c,Speciality_RuleID__r.Theater__c,Speciality_RuleID__r.Specilaity__c,Speciality_RuleID__r.Tier__c,
                                            Speciality_RuleID__r.Is_Total_Revenue__c,Speciality_RuleID__r.Name,v.AccountID__c, 
                                            VS_Rule_Result_Section__c, VS_Rule_Result_Display_Name__c
                                            From Velocity_Rule_Results__c v
                                            where v.accountId__c in :setAccountIds ORDER BY v.Grouping__c ];
      Map<Id,List<Velocity_Rule_Results__c>> MapAccountId_VelocityResults =new Map<Id,List<Velocity_Rule_Results__c>>();
      for(Velocity_Rule_Results__c vrr : vrrs ){
          List<Velocity_Rule_Results__c>lstVrr=MapAccountId_VelocityResults.get(vrr.AccountId__c);
          if(lstVrr==null){
              lstVrr=new  List<Velocity_Rule_Results__c>();
          }
          lstVrr.add(vrr);
          MapAccountId_VelocityResults.put(vrr.AccountId__c,lstVrr);
          
      }
      return MapAccountId_VelocityResults;

  }
  
   public void evaluateRollupRules(List<Account> accounts){
     system.debug('INSIDE evaluateRollupRules - ACCOUNTS  ');   
       Velocity_Rules__c objVelocityRule = new Velocity_Rules__c();
       Velocity_Rule_Results__c ruleResult;
       Map<Id,Account> mapAccounttoUpdate = new Map<Id,Account>();  
       Map<Id,List<Velocity_Rule_Results__c>> MapAccountId_VelocityResults = fetchVelocityRuleResults(accounts);
       Map<Id, List<Velocity_Rule_Results__c>> MapAccountId_TierCompliance = getTierComplianceValues(MapAccountId_VelocityResults);    
       List<Velocity_Rule_Results__c>lstVrrtoUpdate= new  List<Velocity_Rule_Results__c>();
       for(Account acc: accounts){
          if(acc.Grouping__c != Null){
            ruleResult = new Velocity_Rule_Results__c(Grouping__c = acc.Grouping__c ); 
            Account processAccount = evaluateRollupRules(objVelocityRule , ruleResult);  
           if (processAccount==null){
               processAccount=acc;
           }
          if(MapAccountId_VelocityResults.get(processAccount.Id) != null){        
           processAccount =updateCompilanceStatus(processAccount,MapAccountId_VelocityResults.get(processAccount.Id));
           String count=isVelocityProgram(processAccount);
           if(MapAccountId_TierCompliance != Null && MapAccountId_TierCompliance.get(processAccount.id)!= Null ){
             for( Velocity_Rule_Results__c vrr: MapAccountId_TierCompliance.get(processAccount.id)){
               vrr.current__c =count;
               lstVrrtoUpdate.add(vrr);
             }
           }
          } 
          // system.debug('MapAccountId_TierCompliance.get(acc.id).current__c '+MapAccountId_TierCompliance.get(acc.id).current__c);
           if(processAccount != Null) {
            
            // Add by Anand Sharma : 18-Mar-2011            
            //update account's field value with current data time               
            processAccount.Education_Data_Refresh_Date__c = System.now();
            
            mapAccounttoUpdate.put(processAccount.Id,processAccount);
           //listAccounttoUpdate.add(processAccount);
           }
          }
       } //End of for.
     // update accounts for rollup count
       PRM_VPP_DeltaIdentifer.ProcessOnAfterUpdating= true;
       Database.Saveresult[] resultAccount = Database.update(mapAccounttoUpdate.values()); 
       if(resultAccount != null){
          PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultAccount);
         }  
        
         //Update for VRR - compliance status
         Database.Saveresult[] resultVRR = Database.update(lstVrrtoUpdate); 
       if(resultVRR != null){
          PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVRR);
         }
     }// End of method - evaluateRollupRules -Accounts.
      public void evaluateRollupRuleswitherrors(List<Account> accounts,string Batchid,List<EMCException> emailerrors){
     system.debug('INSIDE evaluateRollupRules - ACCOUNTS  ');   
       Velocity_Rules__c objVelocityRule = new Velocity_Rules__c();
       Velocity_Rule_Results__c ruleResult;
       Map<Id,Account> mapAccounttoUpdate = new Map<Id,Account>();  
       Map<Id,List<Velocity_Rule_Results__c>> MapAccountId_VelocityResults = fetchVelocityRuleResults(accounts);
       List <EMCException> errors = new List <EMCException>();
       Map<Id, List<Velocity_Rule_Results__c>> MapAccountId_TierCompliance = getTierComplianceValues(MapAccountId_VelocityResults);    
       List<Velocity_Rule_Results__c>lstVrrtoUpdate= new  List<Velocity_Rule_Results__c>();
       for(Account acc: accounts){
          if(acc.Grouping__c != Null){
            ruleResult = new Velocity_Rule_Results__c(Grouping__c = acc.Grouping__c ); 
            Account processAccount = evaluateRollupRules(objVelocityRule , ruleResult);  
           if (processAccount==null){
               processAccount=acc;
           }
          if(MapAccountId_VelocityResults.get(processAccount.Id) != null){        
           processAccount =updateCompilanceStatus(processAccount,MapAccountId_VelocityResults.get(processAccount.Id));
           String count=isVelocityProgram(processAccount);
           if(MapAccountId_TierCompliance != Null && MapAccountId_TierCompliance.get(processAccount.id)!= Null ){
             for( Velocity_Rule_Results__c vrr: MapAccountId_TierCompliance.get(processAccount.id)){
               vrr.current__c =count;
               lstVrrtoUpdate.add(vrr);
             }
           }
          } 
          // system.debug('MapAccountId_TierCompliance.get(acc.id).current__c '+MapAccountId_TierCompliance.get(acc.id).current__c);
           if(processAccount != Null) {
            
            // Add by Anand Sharma : 18-Mar-2011            
            //update account's field value with current data time               
            processAccount.Education_Data_Refresh_Date__c = System.now();
            
            mapAccounttoUpdate.put(processAccount.Id,processAccount);
           //listAccounttoUpdate.add(processAccount);
           }
          }
       } //End of for.
     // update accounts for rollup count
       PRM_VPP_DeltaIdentifer.ProcessOnAfterUpdating= true;
       Database.Saveresult[] resultAccount = Database.update(mapAccounttoUpdate.values()); 
       if(resultAccount != null){
          PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultAccount);
         }  
        
         //Update for VRR - compliance status
         Database.Saveresult[] resultVRR = Database.update(lstVrrtoUpdate); 
       if(resultVRR != null){
          PRM_VPP_VelocityRuleResultsUtils.logFailedRecords(resultVRR);
         }
         /* HANDLING EXCEPTION LOG*/
		        for (Database.Saveresult sr : resultVRR) {
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
         
     }// End of method - evaluateRollupRules -Accounts.
     
    public Map<Id,List<Velocity_Rule_Results__c>>  getTierComplianceValues(Map<Id,List<Velocity_Rule_Results__c>> MapAccountId_VelocityResults){
        Map<Id,List<Velocity_Rule_Results__c>> MapAccountId_TierCompliance = new Map<Id, List<Velocity_Rule_Results__c>>();
        
        for(Id accontId :MapAccountId_VelocityResults.KeySet()){
        List<Velocity_Rule_Results__c> lstVrr=MapAccountId_VelocityResults.get(accontId);
           
           for(Velocity_Rule_Results__c vrr: lstVrr){
                   if (vrr.Speciality_RuleID__r.bucket__c =='Velocity Program'){
                      
                      List<Velocity_Rule_Results__c> lstAccVrr= MapAccountId_TierCompliance.get(accontId );
                       if(lstAccVrr==null){
                          lstAccVrr=new List<Velocity_Rule_Results__c> ();
                       }
                       lstAccVrr.add(vrr);
                       MapAccountId_TierCompliance.put(accontId ,lstAccVrr);
                       //break; set values for all 4 tier rules current value
                   } 
           }
        }
        return MapAccountId_TierCompliance; 
     }

/* @Method getServiceRuleResultStatus(): This method would be used for   
                                         settingup the status of the Service RuleResult.>
       @param - Velocity_Rule_Results__c 
       @return <void> - <Not Returning anything>
       @throws exception - <No Exception>
*/
   public string getServiceRuleResultStatus(Velocity_Rules__c objVelRule,Velocity_Rule_Results__c ruleResult){
    system.debug('INSIDE getServiceRuleResultStatus() --' + ruleResult.VS_Rule_Result_Section__c + ' '+ ruleResult.VS_Rule_Result_Display_Name__c);
    string status = 'Not Deployed';
    Account profiledAccountRecord ;
    string DeployedVelocityServices;
    List<string> VSdeployedList;
    List<Services__c> VSrlist;
    Map<String,Date> vrmap = new Map<String,Date>();
    if(MapPartnerGroupId_ProfiledAccount != null && MapPartnerGroupId_ProfiledAccount.containsKey(ruleResult.Grouping__c)){
        profiledAccountRecord= MapPartnerGroupId_ProfiledAccount.get(ruleResult.Grouping__c);
    }
   if( profiledAccountRecord != null ){
        DeployedVelocityServices = profiledAccountRecord.Deployed_Velocity_Services__c ;
        VSrlist = profiledAccountRecord.Velocity_Services__r;
         
    }
    if(DeployedVelocityServices != null ) {
        VSdeployedList = DeployedVelocityServices.split(';'); 
    }    
    if(VSdeployedList != Null ){
        for (string deployedValue : VSdeployedList){
             if(deployedValue.trim() == (ruleResult.VS_Rule_Result_Section__c + ' '+ ruleResult.VS_Rule_Result_Display_Name__c).trim()){
                system.debug('deployedValue ####'+ deployedValue) ; 
                status = 'Deployed' ;
                break ;
             }
        } // End of for loop.
    }
    /*if(profiledAccountRecord != null ){
    	System.debug('111.'+profiledAccountRecord.Id);
    	VSrlist = [select Id,Products__c,Services_Program_Designation__c,Partner_Deployment_End_Date__c from Services__c where Partner_Account__c = :profiledAccountRecord.Id];
    	System.debug('2222.'+VSrlist);
    }*/
    if(VSrlist!=null){
    for(Services__c vrs: VSrlist){
    	
  		vrmap.put(vrs.Products__c+vrs.Services_Program_Designation__c,vrs.Partner_Deployment_End_Date__c);
  	}
    }
  	if (vrmap.keySet().contains(ruleResult.VS_Rule_Result_Display_Name__c+ruleResult.VS_Rule_Result_Section__c)){
  		if(vrmap.get(ruleResult.VS_Rule_Result_Display_Name__c+ruleResult.VS_Rule_Result_Section__c)>=date.today()){
  			System.debug('in 2nd if  '+vrmap.get(objVelRule.Display_Name__c));
  			status = 'Deployed';
  			}else status = 'Not Deployed';
  		  	}
  		  	System.debug('before returning.... ' +status);
    return status ;
   } // End of method- getServiceRuleResultStatus().
   
   public string evaluateCloudBuilderRule(Velocity_Rules__c rule, Velocity_Rule_Results__c result){
         boolean conditionSatisfied = true; 
         integer intReturnValue = 0;
         Account profiledAccount;
         Map<String,Schema.SObjectField> mapAccountFields = Schema.SObjectType.Account.fields.getMap();
          list<string> lstfieldValues = new list<string>();
          set<string> fieldValues = new set<string>();
          list<string> requiredValues = new list<string>();
         try{
             profiledAccount = MapPartnerGroupId_ProfiledAccount.get(result.Grouping__c);
             system.debug('profiledAccount--------->' +profiledAccount);
             Schema.DisplayType fieldType = mapAccountFields.get(rule.Field_Name__c).getDescribe().getType();
             system.debug('fieldType --------->' +fieldType );
             if(fieldType == Schema.DisplayType.STRING || fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST
                || fieldType == Schema.DisplayType.TEXTAREA){
                   if(profiledAccount.get(rule.Field_Name__c) != null && profiledAccount.get(rule.Field_Name__c) != ''){ 
                       lstfieldValues = ((profiledAccount.get(rule.Field_Name__c))+';').split(';');
                       //system.debug('profiledAccount.get(rule.Field_Name__c)--------->' +profiledAccount.get(rule.Field_Name__c));
                        system.debug('lstfieldValues --------->' +lstfieldValues);
                       if(lstfieldValues.size()>0){
                            for(string value: lstfieldValues){
                                fieldValues.add(value.toLowerCase());
                            }
                       }
                  }     
             }

             if(fieldType == Schema.DisplayType.DATETIME || fieldType == Schema.DisplayType.DATE || fieldType == Schema.DisplayType.DOUBLE
                || fieldType == Schema.DisplayType.INTEGER || fieldType == Schema.DisplayType.ID){
                   if(profiledAccount.get(rule.Field_Name__c) != null && profiledAccount.get(rule.Field_Name__c) != ''){
                       lstfieldValues = (string.valueOf((profiledAccount.get(rule.Field_Name__c)))+';').split(';');
                       //system.debug('profiledAccount.get(rule.Field_Name__c)--------->' +profiledAccount.get(rule.Field_Name__c));
                        system.debug('lstfieldValues --------->' +lstfieldValues);
                       if(lstfieldValues.size()>0){
                            for(string value: lstfieldValues){
                                fieldValues.add(value.toLowerCase());
                            }
                       }
                  }
             }
             if(rule.Value__c != null && rule.Value__c != ''){
                 requiredValues = (rule.Value__c +';').split(';');
                 system.debug('requiredValues 0----->' +requiredValues );
             }    
             
         }catch(exception e){
             conditionSatisfied = false;
             system.debug('exception e----->' +e);
             
         }
         if(!rule.Any_Value_Acceptable__c){
             if(rule.AND_OR__c != null && rule.AND_OR__c != '' && rule.AND_OR__c == 'AND'){
                system.debug('requiredValues ----->' +requiredValues );
                system.debug('fieldValues ----->' +fieldValues);
                if(requiredValues.size()>0){
                    for(string value: requiredValues){
                        if(fieldValues.size()>0){
                            if(fieldValues.contains(value.toLowerCase())){
                            }else{
                                conditionSatisfied = false;
                                break;
                            }
                        }else{
                            conditionSatisfied = false;
                        }
                    }
                }
                if(conditionSatisfied){
                    intReturnValue = 1;
                }else{
                    intReturnValue = 0;
                }     
             }
             if(rule.AND_OR__c != null && rule.AND_OR__c != '' && rule.AND_OR__c == 'OR'){
                if(requiredValues.size()>0){
                    for(string value: requiredValues){
                        if(fieldValues.size()>0){
                            if(fieldValues.contains(value.toLowerCase())){
                                conditionSatisfied = true;
                                intReturnValue = intReturnValue  + 1;
                                
                            }else{
                                conditionSatisfied = false;
                            }
                        }
                    }
                }
                
             }
         }else{
            if(fieldValues.size()>0){
                conditionSatisfied = true;
                intReturnValue = intReturnValue  + 1;
            }else{
                conditionSatisfied = false;
            }
         }
         return string.valueOf(intReturnValue);
    }
    
    public String getRevenueforLocalReqTierRules(Velocity_Rules__c rule,Account profiledAccount,
                                            Map<Id,Velocity_Revenue__c> revenueProfiledAccountMap){     
        String revenueAmountforTierRules = '0';
        Map<String,RevenueSpeciality__c> revenueValues = RevenueSpeciality__c.getAll(); 
        Map<String, String> tierRevenueValueMap = new Map<String, String>();    
        Velocity_Revenue__c velocityRevenue = revenueProfiledAccountMap.get(profiledAccount.id);    
        if(velocityRevenue!=null){
            double tierRevenueAmount = 0; 
           String ruleKey = rule.Display_Name__c+'|'+rule.Local_Requirment_Set__c;    
           for(RevenueSpeciality__c revenue: revenueValues.values()){
              String strKey = revenue.Specialty__c+'|'+revenue.Local_Requirement_Set__c;
                if(!tierRevenueValueMap.containsKey(strKey)){
                    tierRevenueValueMap.put(strKey,revenue.RevenueValues__c);
                }
            }
            if(tierRevenueValueMap.containsKey(ruleKey)){
                List<String> tierRevenueTableValues = (tierRevenueValueMap.get(ruleKey)).split(',');
                for(String tierRevenue: tierRevenueTableValues){
                    if(tierRevenue!=''){
                        if(velocityRevenue.get(tierRevenue)!=null){
                            tierRevenueAmount = tierRevenueAmount+double.valueOf(''+velocityRevenue.get(tierRevenue));
                        }    
                    }
                }
            }
            revenueAmountforTierRules = String.ValueOf(tierRevenueAmount);
            //return tierRevenueAmount;
        }
        System.Debug('revenueAmountforTierRules------>' +revenueAmountforTierRules);
        return revenueAmountforTierRules;
    }
}