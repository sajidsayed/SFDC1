/*
Author:     Devi Prasad Bal
Created on: 28-April-2010
Description: This class contains test method for EBC_Copy_Invitee.cls
Modified by: 
Modified on: 
Reason:
*/

@isTest
private class EBC_Copy_Invitee_TC {
    static testMethod void validateCopyInvitee() {
    
	    EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open');
	    insert beRecord;
	    
	    Contact conRecord = new Contact(LastName='LN');
	    insert conRecord;
	    
	    EBC_Invitees__c newInv = new EBC_Invitees__c(Briefing_Event__c=beRecord.Id, Contact__c=conRecord.Id);
	    insert newInv;
	    
	    ApexPages.StandardController ctController=new ApexPages.StandardController(newInv);
    	ApexPages.currentPage().getParameters().put('Id',newInv.id);
    	ApexPages.currentPage().getParameters().put('retURL',beRecord.id);
    	
	    
	    EBC_Copy_Invitee copyInv = new EBC_Copy_Invitee(ctController);
	    copyInv.setSelectedInvitee(newInv.Id);
	    copyInv.getSelectedInvitee();
	    copyInv.getInternalInvList();	    
	    copyInv.addInvitee();
	    copyInv.backToBE();
    
    }
}