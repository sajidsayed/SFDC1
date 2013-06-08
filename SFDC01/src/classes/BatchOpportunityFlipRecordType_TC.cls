@isTest(SeeAllData = true) 
private class BatchOpportunityFlipRecordType_TC {

         public static Set <Id> setAcc=new Set <Id>();
 public static Map<String,CustomSettingDataValueMap__c> mapCustomSettingDataValueMap = CustomSettingDataValueMap__c.getall();
 public static CustomSettingDataValueMap__c OpptyRecordTypes = (mapCustomSettingDataValueMap.get('Booked_Part_Perf_Rating_Opp_RecType'));
 public static String strRecType = OpptyRecordTypes.DataValue__c;
         public static List <Account> lstAcc=new List <Account>();
         public static String query;
         public static String strAccountIds = '(';
static testMethod void BatchOpportunityFlipRecordType(){
    
    Test.StartTest(); 
    lstAcc=[Select id from Account limit 10];
    for(integer k=0;k<10;k++){
    setAcc.add(lstAcc[k].id);
    strAccountIds = strAccountIds + '\'' + lstAcc[k].id + '\',';
    }
     if(strAccountIds.endsWith(',')){
         strAccountIds = strAccountIds.substring(0,strAccountIds.length() -1);
         strAccountIds = strAccountIds + ')';
         }
         
         query='select id,name,stageName,partner__c,recordtypeid,bypass_validation__c,Tier_2_Partner__c from opportunity where stageName=' + '\'Booked\'' + ' and recordtypeid != \'' + strRecType + '\' and (Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Partner__c in ' + strAccountIds + ' OR Tier_2_Partner__r.Profiled_Account__c in ' + strAccountIds + ' OR Tier_2_Partner__c in ' + strAccountIds + ') order by LastModifiedDate desc';
              
    
    BatchOpportunityFlipRecordType obj=new BatchOpportunityFlipRecordType (setAcc,false);
    BatchOpportunityFlipRecordType obj1=new BatchOpportunityFlipRecordType (setAcc,true);
    BatchOpportunityFlipRecordType obj2=new BatchOpportunityFlipRecordType (query,false);
    Id batchprocessId =  Database.executeBatch(obj2,10);
    BatchOpportunityFlipRecordType obj3=new BatchOpportunityFlipRecordType (query,true);
    
    Database.BatchableContext bc;
    List<SObject> st=new List<SObject>();
    
    
    //st=obj3.start(bc);
    obj3.execute(bc,st);
    obj3.finish(bc);
    Datetime dt = Datetime.now().addMinutes(1);
    String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
    System.Schedule('schedule',sch,obj3);
    


     
    Test.StopTest();
}
}