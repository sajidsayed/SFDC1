/*
Author:     Devi Prasad Bal
Created on: 07-April-2010
Description: This class contains test method for EBC_Feedback.cls

Modified by :   Avinash K 
Modified on :   30 May 2012
Reason:     :   To increase coverage for EBC_Feedback class.
*/

@isTest
private class EBC_Feedback_TC {
    static testMethod void validateFeedback() {
    
    EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open');
    insert beRecord;
    
    Contact conRecord = new Contact(LastName='LN');
    insert conRecord;
    
    EBC_Topics__c topicRecord = new EBC_Topics__c(Name= 'TN');
    insert topicRecord;
    
    EBC_Session__c sessionRecord = new EBC_Session__c(Topic__c=topicRecord.Id, Briefing_Event__c=beRecord.Id);
    insert sessionRecord;
    
    EBC_Session_Presenter__c sessPresenterRecord = new EBC_Session_Presenter__c(Name='SN', Session__c=sessionRecord.Id, Presenter__c=conRecord.Id);
    insert sessPresenterRecord;
    
    
    ApexPages.StandardController ctController=new ApexPages.StandardController(beRecord);
    ApexPages.currentPage().getParameters().put('Id',beRecord.id);
    
    EBC_Feedback feedback = new EBC_Feedback(ctController);
    feedback.save();
    feedback.cancel();
    
    
    
    EBC_Briefing_Event__c beRecord2 = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open', Feedback_Status_Picklist__c= '',
                                                    Agenda_Coordination_Planning_Rating__c = 'Fair', Agenda_Coordination_Planning_Notes__c = '',
                                                    Evening_Venue_Rating__c='Fair', Evening_Venue_Notes__c='',
                                                    Briefing_Registration_Process_Rating__c='Fair', Briefing_Registration_Process__c='',
                                                    Briefing_Day_Services_Rating__c='Fair',Briefing_Day_Services_Notes__c='',
                                                    Briefing_Catering_Services_Rating__c='Fair', Briefing_Catering_Services_Notes__c='',
                                                    Hotel_Rating__c='Fair', Hotel_Notes__c='',
                                                    Briefing_Program_Website_Rating__c='Fair', Briefing_Program_Website_Notes__c='',
                                                    Transportation_Rating__c = 'Fair', Transportation_Notes__c = '');
    insert beRecord2;
    
    ApexPages.StandardController ctController2=new ApexPages.StandardController(beRecord);
    ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
    
    EBC_Feedback feedback2 = new EBC_Feedback(ctController2);
    feedback2.save();
    feedback2.cancel();
    // My code begins
    List<SelectOption> lstso = feedback2.getRatingOptions();
    feedback2.getSessRecords();
    
    // My code ends
//Avinash's code begins...

/* Commented by Avinash due to an error occurring in Production "Invalid Operation on an Inactive User/Owner"


    Contact con = testclassUtils.getContact();
    insert con;
    beRecord2.Requestor_Name__c = con.id;
    update beRecord2;
    
    ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
    EBC_Feedback feedback3 = new EBC_Feedback(ctController2);
    
    List<SelectOption> lstso = feedback3.getRatingOptions();
    
    con.FirstName = '';
    update con;
    beRecord2.Requestor_Name__c = con.id;
    update beRecord2;
    ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
    feedback3 = new EBC_Feedback(ctController2);
    
    EBC_Briefing_Center__c bc=new EBC_Briefing_Center__c(name='hello');
    insert bc;
    
    beRecord2.Briefing_Center__c = bc.id;
    beRecord2.Feedback_Status_Picklist__c = 'Submitted';
    update beRecord2;
    ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
    feedback3 = new EBC_Feedback(ctController2);
    
    List<Profile> lstp = [select name from Profile where name = 'EBC Application Site Profile' limit 1];
    if(lstp != null && lstp.size() > 0)
    {
        Profile p = lstp.get(0);
        List<User> lstuser = [select name from user where ProfileId = :p.id limit 1];
        if(lstuser != null && lstuser.size() > 0)
        {
            User u = lstuser.get(0);
            System.runAs(u)
            {
                ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
                feedback3 = new EBC_Feedback(ctController2);
            }
        }
    }

Commented by Avinash...  */ 
//Avinash's code ends.
    
    }
    
}