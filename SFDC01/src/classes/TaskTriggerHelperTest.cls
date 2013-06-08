// Test class for UpdateTypePicklist Trigger  -WR # 230704

@isTest(SeeAllData=true)
private class TaskTriggerHelperTest {

//Test Method for Task Trigger Helper class    
static testmethod void MyUnitTest(){
Boolean hasfired = TaskTriggerHelper.hasAlreadyfired();
TaskTriggerHelper.setAlreadyfired();
}
 //Task Insertion into custom Object          
 static testmethod void createNewTask() {
        RecordType taskRecordType = [select id from RecordType where sObjectType='Task' and DeveloperName like 'Renewals%' LIMIT 1];
         Account acc = testclassUtils.getAccount() ;
             insert acc ;
    Opportunity Opp= testclassUtils.getOppty ();
         insert Opp;
      Id accid = acc.Id;
     
        Task T = new Task();
        T.Type__c = 'PVR';
        T.Recordtypeid = taskRecordType.id;
        T.Type_Detail__c = 'Redirect';
        T.Subject = 'Renewals Type';
        T.Task_Comments__c = 'Test1';
        T.Description = 'Test';
        T.Rework_Types__c = 'Correction';
        
        T.Status = 'Completed';
        T.Status_Update_Date_Time__c = DateTime.now();
        T.VCE_Assigned_To__c = 'Testing';
        T.VCE_Last_Modifying_Partner__c = 'EMC';
        T.WhatId = accid;
        insert T;
               
     
OAR_Member_Added__c obj = new OAR_Member_Added__c();
obj.Text_1__c = T.Type__c;
obj.Text_2__c = T.Type_Detail__c;
obj.Text_3__c = T.Subject;
obj.Text_4__c = T.Description;
obj.Text_7__c = T.Status;

  obj.user_1__c = t.ownerid;

  obj.User2__c = t.CreatedById;

String urlForObj= URL.getSalesforceBaseUrl().toExternalForm() + '/'+T.WhatId;
obj.Task_Related_To_URL__c = urlForObj;
String RelUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+T.Id;
obj.Task_URL__c = RelUrl;

      String Oppnum = opp.Opportunity_Number__c;
      obj.Text_5__c = Oppnum;
      String accname = T.Whatid;
      obj.Text_6__c =accname ;
   
insert obj;
update T;        
        }
 // Task Field Udpate Test       
Static TestMethod Void TriggerTest(){

            String Curr = Userinfo.getDefaultCurrency();
            String UName = Userinfo.getName();
            DateTime ModDate = DateTime.now();
            
          Opportunity Opp= testclassUtils.getOppty ();
          insert Opp;
          Id oppid = opp.Id;
        
 Task T1 = new Task();
 RecordType taskRecordType = [select id from RecordType where sObjectType='Task' and DeveloperName like 'Renewals%' LIMIT 1];
        T1.Type__c = 'PVR';
        T1.Type_Detail__c = 'Redirect';
        T1.Subject = 'Renewals Type';
        T1.Recordtypeid = taskRecordType.id;
        T1.Rework_Types__c = 'Correction';
        T1.Task_Comments__c = 'Test1';
        T1.Description  += '\n'+ ' ' +Uname +':'+' '+ ModDate +':'+' ';
        T1.Status = 'Completed';
        T1.Status_Update_Date_Time__c = DateTime.now();
        T1.VCE_Assigned_To__c = 'Testing';
        T1.VCE_Last_Modifying_Partner__c = 'EMC';
        T1.Whatid = oppid;
        insert T1;
        
        OAR_Member_Added__c obj1 = new OAR_Member_Added__c();
        String Oppname = T1.WhatId;
         obj1.Text_5__c = Oppname;
         insert obj1;
      
    
if(T1.Type__c != NULL)
 {                  
   T1.Type = T1.Type__c;
 }

T1.AddError('Please select a value for the field Type');

}

}