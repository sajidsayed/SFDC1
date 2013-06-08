@isTest
private class Test_WorksheetToRequirement{

public testMethod static void testScorecard(){

//String releaseId='';
String userId='';
//String reqId='';
//String wSheetId='';
Date date1=null;

date1=date.newinstance(2009, 10, 26);

     //Release__c objRelease1=new Release__c(Name='Test Release');

for(User objUser:[Select id,name from User limit 1]){
userId=objUser.Id;
}

/*for(Application_Requirement__c objReqU:[Select id,name from Application_Requirement__c limit 1]){
reqId=objReqU.Id;
}

for(Worksheet__c objWSheet:[Select id,name from Worksheet__c limit 1]){
wSheetId=objWSheet.Id;
}*/


    Release__c objRel= new Release__c(
            Name='Toolkit Test'
            );
    Database.SaveResult insertRel = Database.insert(objRel);

    Capability__c capability= new Capability__c(Name='Test Capability',Release__c=objRel.Id);
    Database.SaveResult insertCapability = Database.insert(capability);
     
    Application_Requirement__c objReq1=new Application_Requirement__c(Requirement_Title__c='WS Test Req',
                Requirement_Description__c='WS Test Req Desc',
                Release__c=insertRel.id,
                Capability__c=capability.Id,
                Requestor__c=userId,
                Phase_Identified__c='RFP',
                System_Impacted__c='Salesforce.com',
                Actual_Design__c=3
                );
   Database.SaveResult insertReq = Database.insert(objReq1);
   if(insertReq.isSuccess())System.debug('Req insert');


   Worksheet__c objWS = new Worksheet__c(
            Requirement__c = insertReq.Id,
            Release__c = insertRel.id,
            Resource__c = userId,
            Planned_Start_Date__c=date1,
            Planned_End_Date__c=date1,
            Work_Category__c='Design',
            Work_Type__c='CRP',
            Complete__c=0
            );
    Database.SaveResult insertWs = Database.insert(objWS);


   Time_Sheet__c objTS = new Time_Sheet__c(
            Worksheet__c = insertWs.id,
            Resource__c = userId,
            Date__c = date1,
            Type__c = 'Planned',
            Status__c = 'Open',
            Actual_Hours__c=3
            );
    Database.SaveResult insertTS = Database.insert(objTS);


     update objWS;
     update objReq1;
    
}
}