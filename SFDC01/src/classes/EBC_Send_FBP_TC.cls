/*
Author:     Devi Prasad Bal
Created on: 07-April-2010
Description: This class contains test method for EBC_Feedback.cls
Modified by: 
Modified on: 
Reason:
*/

@isTest
private class EBC_Send_FBP_TC {
    	static testMethod void validateSendFBP() {
    	
    	Date stDate = date.today();
    	Date enDate = date.today();
    	
    	// code to retrieve the contact record type id where the record type name is 'EMC Internal Contact'       
        Schema.DescribeSObjectResult myObjectSchema = Schema.SObjectType.Contact;
        Map<String,Schema.RecordTypeInfo> rtMapByName = myObjectSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo record_Type_name_RT = rtMapByName.get('EMC Internal Contact');
        Id internalContact= record_Type_name_RT.getRecordTypeId();
    	    	
    	Contact con = new Contact(RecordTypeId = internalContact, LastName='xyz', Email='abcd@wxyzl.com');
    	insert con;
    	
    	  	
    	EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open', Briefing_Advisor__c=con.Id, 
    																Start_Date__c=stDate, End_Date__c=enDate );
    	EBC_Briefing_Event__c beRecord2 = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open', Briefing_Advisor__c=NULL, 
    																Start_Date__c=stDate, End_Date__c=enDate );
    	insert beRecord;
    	insert beRecord2;
    	
    	EBC_Invitees__c inv1 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Send_FBP__c=true, Briefing_Team_Role__c='Briefing Advisor');
    	EBC_Invitees__c inv2 = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Send_FBP__c=false, Briefing_Team_Role__c='Other Invitee');
    	EBC_Invitees__c inv3 = new EBC_Invitees__c(Briefing_Event__c=beRecord2.Id, Send_FBP__c=false, Briefing_Team_Role__c='Other Invitee');
    	EBC_Invitees__c inv4 = new EBC_Invitees__c(Briefing_Event__c=beRecord2.Id, Send_FBP__c=true, Briefing_Team_Role__c='Briefing Advisor');
    	insert inv1;
    	insert inv2;
    	insert inv3;
    	insert inv4;
    	
    	//ApexPages.StandardController ctController=new ApexPages.StandardController(beRecord);
    	ApexPages.currentPage().getParameters().put('Id',beRecord.id);
    	
    	EBC_Send_FBP sendfbp = new EBC_Send_FBP();
    	sendfbp.additionalEmailIds='a@b.com,c@d.com,e@d.com'; 
    	sendfbp.sendMail();
    	sendfbp.getAdditionalEmailIds();
    	sendfbp.getBody();
    	sendfbp.getMailSent();
    	sendfbp.getSubject();
    	sendfbp.getMailSend();
    	sendfbp.getToAddresses();
    	sendfbp.getBA_Present();
    	sendfbp.setAdditionalEmailIds('d@z.com');
    	sendfbp.setBody('abc');
    	sendfbp.setBA_Present();
    	
    	ApexPages.currentPage().getParameters().put('Id',beRecord2.id);
    	
    	EBC_Send_FBP sendfbp2 = new EBC_Send_FBP();
    	sendfbp2.additionalEmailIds='a@b.com,c@d.com,e@d.com'; 
    	sendfbp2.sendMail(); 
    }
}