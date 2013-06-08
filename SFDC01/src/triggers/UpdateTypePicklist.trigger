/**
Date      :  10/3/2012                     
Name      :  Rajeev Satapathy
WR        :  207264      
Description: This trigger is used to update several fields related to task  
WR        :  230704
Description: Added the condition to insert record into OAR Member added custom object       
**/

trigger UpdateTypePicklist on Task(before update) { 
            
         if(trigger.isupdate){   
            String Curr = Userinfo.getDefaultCurrency();
            String UName = Userinfo.getName();
            DateTime ModDate = DateTime.now();
            
            set<id> stypes = new set<id>();
            for(recordtype objr : [Select Id From RecordType where sObjectType='Task' and developername = 'Renewals_Record_Type']){
            stypes.add(objr.id);
            }
                   
            for(Task T: Trigger.new){ 
            
             //Create an old and new map so that we can compare values  
              Task oldT = Trigger.oldMap.get(T.ID);    
              Task newT = Trigger.newMap.get(T.ID);
            
              
             //Retrieve the old and new Status Value   
              String OldStat = oldT.Status;
              String NewStat = newT.Status;
              String NewCom = newT.Task_Comments__c;
              String OldCom = oldT.Task_Comments__c;
             
            if(stypes.contains(T.RecordTypeId)){
              
                      
            // To diplay the custom type on records 
               if(T.Type__c != NULL)
                 {                  
                  T.Type = T.Type__c;
                 }    
                
                if(OldStat!= NewStat){
                      
               T.Status_Update_Date_Time__c = DateTime.now();
               }
           
               if (T.Type__c == Null){
                 T.AddError('Please select a value for the field Type');
               }
                  
            }
}          
   
   
// End Of Udpate Condtion

// Insert Record Into OAR Member Added Custom Object   
if(!TaskTriggerHelper.hasAlreadyfired()){
List<OAR_Member_Added__c> objList = new List<OAR_Member_Added__c>();

System.Debug('Stypes ------>' + stypes);
System.Debug('NEw trigger------>' +Trigger.new);
map<id,opportunity> opps = new map<id,opportunity>();
map<id,account> acc = new map<id,account>();
for(Task T: Trigger.new){
if((stypes.contains(T.RecordTypeId))&&(T.Status == 'Completed')){

OAR_Member_Added__c obj = new OAR_Member_Added__c();
obj.Text_1__c = T.Type__c;
obj.Text_2__c = T.Type_Detail__c;
obj.Text_3__c = T.Subject;
obj.Task_Comments__c = T.Description;
obj.Text_7__c = T.Status;

if(t.whatid!=null&&t.whatid.getsobjecttype()==opportunity.sobjecttype) {
    opps.put(t.whatid,null);
    }
opps.putAll([select id,Opportunity_Number__c from opportunity where id in :opps.keyset()]);
if(opps.containskey(t.whatid)) {
      String Oppnum = opps.get(t.whatid).Opportunity_Number__c;
      obj.Text_5__c = Oppnum;
   }
   
if(t.whatid!=null&&t.whatid.getsobjecttype()==account.sobjecttype) {
    acc.put(t.whatid,null);
    }
acc.putAll([select id,Name from account where id in :acc.keyset()]);
if(acc.containskey(t.whatid)) {
      String Accname = acc.get(t.whatid).Name;
      obj.Text_6__c = Accname;
   }   

String TempObj = Userinfo.getUserId();
System.Debug('Task Owner........' +TempObj);
if( t.ownerid.getsobjecttype() == user.sobjecttype ) {
  obj.user_1__c = t.ownerid;
}
if( t.CreatedById.getsobjecttype() == user.sobjecttype ) {
  obj.User2__c = t.CreatedById;
}
System.Debug('Trigger.oldMap.get(T.Id).Owner....' + T.Owner);

String urlForObj= URL.getSalesforceBaseUrl().toExternalForm() + '/'+T.WhatId;
obj.Task_Related_To_URL__c = urlForObj;

String RelUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+T.Id;
obj.Task_URL__c = RelUrl;

objList.add(obj);
}
}
if(!objList.isEmpty())

insert objList;
TaskTriggerHelper.setAlreadyfired();
}
   }
}