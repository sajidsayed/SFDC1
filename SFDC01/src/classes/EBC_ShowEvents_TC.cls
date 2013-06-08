/*
Author:     Devi Prasad Bal
Created on: 04-04-2010
Description: This class contains test method for EBC_ShowEvents.cls
Modified by	: 	Avinash K
Modified on	: 	25 May 2012
Reason		:	Increased coverage for EBC_ShowEvents.cls
*/

@isTest
private class EBC_ShowEvents_TC {
    static testMethod void validateShowEvents() {
    
    EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open');
    insert beRecord;
    
    ApexPages.currentPage().getParameters().put('Id',beRecord.Id);
    
    Event ev = new Event(Subject='sub',WhatId=beRecord.Id, DurationInMinutes = 60, ActivityDateTime = System.now());
    
    ApexPages.StandardController ctController=new ApexPages.StandardController(ev);
    EBC_ShowEvents showEvObj = new EBC_ShowEvents(ctController);
    showEvObj.getEvents();
    
    
//Avinash's Code begins...

    insert ev;
    showEvObj.getEvents();
    
//Avinash'scode ends.
    
    }    
}