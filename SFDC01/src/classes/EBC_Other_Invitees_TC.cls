/*
Author:     Devi Prasad Bal
Created on: 04-April-2010
Description: This class contains test method for EBC_Other_Invitees.cls

Modified By     :   Avinash K
Modified Date   :   25 May 2012
Purpose         :   To increase the coverage for EBC_Other_Invitees class

Modified By     :   Emmanuel C
Modified Date   :   17 May 2013
Purpose         :   To increase the coverage for EBC_Other_Invitees class
*/

@isTest
private class EBC_Other_Invitees_TC {
    static testMethod void validateOtherInvitees() {
    
    EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open');
    insert beRecord;
    ApexPages.currentPage().getParameters().put('Id',beRecord.Id);
    EBC_Other_Invitees othInv = new EBC_Other_Invitees();

//Avinash's code begins...
    String strerror = othInv.getErrorMsg();
    othInv.setErrorMsg(strerror);
    
    othInv.wrapResourceList[4].AttendeeLastName='LN4';
    othInv.wrapResourceList[4].Email='mnpde@fxyz.com';
    othInv.saveAndAddMore();
    othInv.save();
    
//Avinash's code ends.

    othInv.wrapResourceList[0].AttendeeFirstName='FN';
    othInv.wrapResourceList[0].AttendeeLastName='';
    othInv.wrapResourceList[0].Email='';
    othInv.wrapResourceList[1].AttendeeLastName='LN';
    othInv.wrapResourceList[2].Email='abc.def@xyz.com';
    othInv.wrapResourceList[3].AttendeeLastName='LN3';
    othInv.wrapResourceList[3].Email='xyz';
    othInv.wrapResourceList[4].AttendeeLastName='LN4';
    othInv.wrapResourceList[4].Email='mnp.def@xyz.com';
    othInv.getrecords();
    othInv.saveAndAddMore();
    othInv.save();
    othInv.cancel();
    }
}