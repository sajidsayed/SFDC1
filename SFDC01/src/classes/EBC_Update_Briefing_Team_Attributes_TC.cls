/*
Author:     Devi Prasad Bal
Created on: 01-April-2010
Description: This class contains test method for EBC_Update_Briefing_Team_Attributes.cls
Modified by: 
Modified on: 
Reason:
*/

@isTest
private class EBC_Update_Briefing_Team_Attributes_TC {
    static testMethod void validateBriefingAttributes() {
    
    EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open');
    insert beRecord;
    
    ApexPages.currentPage().getParameters().put('Id',beRecord.Id);
    EBC_Update_Briefing_Team_Attributes updAtt3 = new EBC_Update_Briefing_Team_Attributes();
    updAtt3.retrieveInvitees();
    updAtt3.updateAttributes();
    updAtt3.cancel();   
    
    EBC_Invitees__c invitee1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Account Team Member');
    insert invitee1;
    EBC_Invitees__c invitee2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Customer');
    insert invitee2;
    EBC_Invitees__c invitee3 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='EMC Employee');
    insert invitee3;
    EBC_Invitees__c invitee4 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Other Invitee');
    insert invitee4;
    EBC_Invitees__c invitee5 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Partner');
    insert invitee5;
    EBC_Invitees__c invitee6 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Presenter (EMC Employee)');
    insert invitee6;
    EBC_Invitees__c invitee7 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Presenter (Non EMC Employee)');
    insert invitee7;
    
    
    EBC_Update_Briefing_Team_Attributes updAtt = new EBC_Update_Briefing_Team_Attributes();
    
    //updAtt.briefingEventId= beRecord.Id;
    updAtt.retrieveInvitees();
    updAtt.updateAttributes();
    updAtt.cancel();
    
    EBC_Invitees__c inviteeBA1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Briefing Advisor');
    insert inviteeBA1;
    
    
    EBC_Invitees__c inviteeLA1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Logistic Advisor');
    insert inviteeLA1;
    EBC_Invitees__c inviteeLA2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Logistic Advisor');
    insert inviteeLA2;
    EBC_Invitees__c inviteeR1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Requestor');
    insert inviteeR1;
    
    EBC_Invitees__c inviteeS1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Scheduler');
    insert inviteeS1;
    
    
    EBC_Update_Briefing_Team_Attributes updAtt2 = new EBC_Update_Briefing_Team_Attributes();
    
    updAtt2.retrieveInvitees();
    updAtt2.updateAttributes();
    updAtt2.cancel();
    
    EBC_Invitees__c inviteeBA2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Briefing Advisor');
    insert inviteeBA2;
    EBC_Invitees__c inviteeR2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Requestor');
    insert inviteeR2;
    EBC_Invitees__c inviteeS2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Last_Name__c='test', Attendee_Email__c='abc.def@xyz.com', Briefing_Team_Role__c='Scheduler');
    insert inviteeS2;
    
    }
}