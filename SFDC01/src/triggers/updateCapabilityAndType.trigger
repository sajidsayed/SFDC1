trigger updateCapabilityAndType on Worksheet__c (before insert, before update) {

for(Worksheet__c ws:Trigger.New){
    if(ws.Requirement__c != NULL){
    ws.Capability__c=ws.Get_Capability__c;
    if(ws.Work_Category__c=='Build & Unit Test' && ws.Actual_Hours_Unplanned1__c==0)ws.Type1__c='Build & Unit Test';
    if(ws.Work_Category__c=='Design' && ws.Actual_Hours_Unplanned1__c==0)ws.Type1__c='Design';
    if(ws.Actual_Hours_Unplanned1__c!=0)ws.Type1__c='Others';
    if(ws.Work_Category__c=='SIT' && ws.Actual_Hours_Unplanned1__c==0)ws.Type1__c='SIT';
    }    
   }
}