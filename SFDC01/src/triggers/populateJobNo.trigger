trigger populateJobNo on Mass_Opp_Reassignment_log__c(before insert) {
   
   Decimal LastJobNo=0;
   if(!Util.isTestCoverage){
     Mass_Opp_Reassignment_log__c latest_log = [select Job_Number__c from Mass_Opp_Reassignment_log__c order by Job_Number__c desc limit 1];
     LastJobNo = (Decimal)latest_log.get('Job_Number__c');  
     
   } 
   if(LastJobNo==null){
       LastJobNo=0;
   } 
   for(Mass_Opp_Reassignment_log__c log: Trigger.new ){
       log.Job_Number__c = LastJobNo + 1;
   }

}