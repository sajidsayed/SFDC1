/*===========================================================================+
 |  HISTORY  |                                                                           
 |  DATE          DEVELOPER                WR       DESCRIPTION                               
 |  ====          =========                ==       =========== 
 |  01/12/2012    Anand Sharma                      Create batch to flip record type of opportunity 
 +===========================================================================*/
global class BatchOpportunityFlipRecordType implements Database.Batchable<sObject>, Schedulable{
    //holds query string 
    global final String Query;
    global Boolean  isRatingEligible;
    
    //default constructor
    global BatchOpportunityFlipRecordType (String strQuery, Boolean  isRatingEligibleFlag){
        this.Query = strQuery ;
        this.isRatingEligible = isRatingEligibleFlag;
    }
    global BatchOpportunityFlipRecordType (Set<Id> setAccountIds, Boolean  isRatingEligibleFlag){
        
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
        String strRecType = OpptyRecordTypes.DataValue__c;
        String strAccountIds = '(';
        for(String strAccount : setAccountIds){
            strAccountIds = strAccountIds + '\'' + strAccount + '\',';
        }
        if(strAccountIds.endsWith(',')){
            strAccountIds = strAccountIds.substring(0,strAccountIds.length() -1);
            strAccountIds = strAccountIds + ')';
        }
        this.isRatingEligible = isRatingEligibleFlag;
        if(this.isRatingEligible){
            this.Query  = 'select id,name,stageName,partner__c,recordtypeid,bypass_validation__c,Tier_2_Partner__c from opportunity where stageName=' + '\'Booked\'' + ' and recordtypeid != \'' + strRecType + '\' and (Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Partner__c in ' + strAccountIds + ' OR Tier_2_Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Tier_2_Partner__c in ' + strAccountIds + ') order by LastModifiedDate desc';
        }else{
            this.Query  = 'select id,name,stageName,partner__c,recordtypeid,bypass_validation__c,Tier_2_Partner__c from opportunity where stageName=' + '\'Booked\'' + ' and recordtypeid = \'' + strRecType + '\' and (Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Partner__c in ' + strAccountIds + ' OR Tier_2_Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Tier_2_Partner__c in ' + strAccountIds + ') and Distributor_Reseller_VAR_Rating_Eligible__c =\'NO\' order by LastModifiedDate desc';
        }
    }
    
    //create batch of records which is passed to execute method for processing
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.Query);
    }
    
    //Update the list of passed account scope and break the context to handle governer limit
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Opportunity> lstOpportunity = (List<Opportunity>) scope;
        
        Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall(); 
        CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));           
        String strRecType = OpptyRecordTypes.DataValue__c;
        CustomSettingDataValueMap__c OpptyNewBookedRecordTypes = (mapCustomSettingDataValueMap.get('New_Booked_Opportunity_Record_Type'));           
        String strNewBookedRecType = OpptyNewBookedRecordTypes.DataValue__c;
        
        for(Opportunity oppObj: lstOpportunity){            
            if(this.isRatingEligible){
                oppObj.recordtypeid=strRecType;
            }else{
                oppObj.recordtypeid=strNewBookedRecType;            
            }
            oppObj.bypass_validation__c = true;            
        }
        Database.update(lstOpportunity , false);
    }
    // no need to do any operation in this method as per current business logic.
    global void finish(Database.BatchableContext BC){        
    }
    
    //Execute batch class with default constructor from schedular
    global void execute(SchedulableContext sc) {        
        try {
            //Abort the existing schedule 
            CronTrigger ct = [SELECT id,CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :SC.getTriggerId()];
            if(ct != null) {
                System.abortJob(ct.Id);
            }
        } catch (Exception e) {
            System.debug('There are no jobs currently scheduled. ' + e.getMessage()); 
        }
        //execute batch job 
        database.executebatch(new BatchOpportunityFlipRecordType(Query, isRatingEligible));
   } 
}