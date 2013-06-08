/**

Modified By		:	Avinash Kaltari
Modified Date	:	25 May 2012
Purpose			:	To increase the coverage of WorksheetPopulateOnRequirement class

*/
@isTest
Private Class WorksheetPopulateOnRequirement_TC{
    Private static testMethod void startTest(){
        Application_Requirement__c req=new Application_Requirement__c(
                Requirement_Title__c='testRequirement',
                Requirement_Description__c='test',
                Phase_Identified__c='UAT');
            insert req;

            Worksheet__c worksheet=new Worksheet__c (
                Type__c='Planned',
                Requirement__c=req.Id);
            insert worksheet;

            Time_Sheet__c timesheet1=new Time_Sheet__c(
                Type__c='Planned',
                Actual_Hours__c=20,
                Status__c='Complete',
                Worksheet__c=worksheet.Id);
            insert timesheet1;

            Time_Sheet__c timesheet2=new Time_Sheet__c(
                Type__c='Unplanned',
                Actual_Hours__c=18,
                Status__c='Complete',
                Worksheet__c=worksheet.Id);
            insert timesheet2;

            worksheet.Work_Category__c='Design';
            update worksheet;
            
            timesheet2.Actual_Hours__c=0;
            update timesheet2;

//Avinash's code begins...
            Worksheet__c ws2 = new Worksheet__c (Type__c='Planned',Requirement__c=req.Id);
            ws2.Work_Category__c='Build & Unit Test';
            insert ws2;
            
            
            Time_Sheet__c timesheet3=new Time_Sheet__c(
                Type__c='Unplanned',
                Actual_Hours__c=18,
                Status__c='Complete',
                Worksheet__c=ws2.Id);
            insert timesheet3;
            timesheet3.Actual_Hours__c=0;
            update timesheet3;

            Worksheet__c ws3 = new Worksheet__c (Type__c='Planned',Requirement__c=req.Id);
            ws3.Work_Category__c='SIT';
            insert ws3;

            Time_Sheet__c timesheet4=new Time_Sheet__c(
                Type__c='Unplanned',
                Actual_Hours__c=18,
                Status__c='Complete',
                Worksheet__c=ws3.Id);
            insert timesheet4;
            timesheet4.Actual_Hours__c=0;
            update timesheet4;
//Avinash's code ends.

            
    }
}