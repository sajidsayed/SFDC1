trigger updateType on Worksheet__c (after insert, after update) {
Set<String> Ids= new Set<String>();
List<Worksheet__c> wsInfo = new List<Worksheet__c>();
List<Worksheet__c> wsUpdate = new List<Worksheet__c>();

for(Worksheet__c ws:Trigger.New){
    if(ws.Requirement__c != NULL){
    Ids.add(ws.Id);
     }
  }
  wsInfo=[select Work_Category__c,Type1__c,Actual_Hours_Planned1__c, Actual_Hours_Unplanned1__c from Worksheet__c where Id in :Ids];
  for(Worksheet__c w:wsInfo)
  {
  if(w.Work_Category__c=='Design' && w.Actual_Hours_Unplanned1__c==0)
        w.Type1__c='Design';
  if(w.Work_Category__c=='Build & Unit Test' && w.Actual_Hours_Unplanned1__c==0)
        w.Type1__c='Build & Unit Test';
  if(w.Work_Category__c=='SIT' && w.Actual_Hours_Unplanned1__c==0)
        w.Type1__c='SIT';
  if(w.Actual_Hours_Unplanned1__c!=0)
        w.Type1__c='Others';
     wsUpdate.add(w);
     System.debug('Type1__c: '+w.Type1__c);
    }  
update wsUpdate;
}