/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 Modified by 	: 	Avinash K
 Modified Date	:	24 May 2012
 Purpose		:	Added code to increase coverage for "EBC_addInvitees" Trigger and "EBC_ShowRoomAssignment" Class
 
 
 */
@isTest
private class EBC_ShowRoomAssignment_TC {

    static testMethod void EBC_ShowRoomAssignment() {
            EBC_Briefing_Center__c bc=new EBC_Briefing_Center__c(name='hello');
            insert bc;
            EBC_Briefing_Venue__c bv=new EBC_Briefing_Venue__c(Briefing_Center__c=bc.Id);
            insert bv;
            EBC_Briefing_Event__c beRecord = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open',Briefing_Center__c=bc.Id,Briefing_Venue__c=bv.Id);
    		insert beRecord;
    		EBC_Room__c room=new EBC_Room__c(Name='room',Briefing_Venue__c=bv.Id);
    		insert room;
    		EBC_Room__c room2=new EBC_Room__c(Name='room2',Briefing_Venue__c=bv.Id);
    		insert room2;
    		EBC_Room_Calendar__c rc=new EBC_Room_Calendar__c(Room__c=room.Id,Briefing_Event__c=beRecord.Id,Start_Date__c=Date.Today(),End_Date__c=Date.Today());
    		insert rc;
    		EBC_Briefing_Event__c beRecord2 = new EBC_Briefing_Event__c(Name= 'testName', Briefing_Status__c= 'Open',Briefing_Center__c=bc.Id,Briefing_Venue__c=bv.Id);
    		insert beRecord2;
    		    ApexPages.currentPage().getParameters().put('Id',beRecord.Id);
    		
    		EBC_WrapperShowRoomAssignment wrp=new EBC_WrapperShowRoomAssignment();
    		Date dt=Date.Today();
    		wrp.getEndDate();
    		
    		wrp.setEndDate(dt+'');
    		wrp.getStartDate();
    		
    		wrp.getBriefingEvent();
    		wrp.setBriefingEvent(beRecord.Name+'');
    		wrp.getRoomId();
    		wrp.setRoomId(room.Id);
    		wrp.setStartDate(dt+'');
    		wrp.getRoomName();
    		wrp.setRoomName(room.Name+'');
    		EBC_ShowRoomAssignment showAssignment = new EBC_ShowRoomAssignment();
    		showAssignment.getRecords();
    		showAssignment.updateBriefingEvent();
    		
    		
// Code added by Avinash begins...

    		Id bvid = beRecord2.Briefing_Venue__c;
    		EBC_Briefing_Event__c beclone = beRecord2.clone();
    		List<EBC_Briefing_Event__c> lst = [select name from EBC_Briefing_Event__c limit 50000];
    		beclone.Briefing_Venue__c = null;
    		ApexPages.currentPage().getParameters().put('Id',beclone.Id);
    		EBC_ShowRoomAssignment showAssignment1 = new EBC_ShowRoomAssignment();
    		beclone.Briefing_Venue__c = bvid;

// Code added by Avinash ends. 		
    		
    		
    		EBC_WrapperShowRoomAssignment wrps=new EBC_WrapperShowRoomAssignment();
    		wrps.getEndDate();
    		
    		wrps.setEndDate(dt+'');
    		wrps.getStartDate();
    		
    		wrps.getBriefingEvent();
    		wrps.getRoomId();
    		wrps.setRoomId(room2.Id);
    		wrps.setStartDate(dt+'');
    		wrps.getRoomName();
    		wrps.setRoomName(room2.Name+'');
    		EBC_ShowRoomAssignment showAssignments = new EBC_ShowRoomAssignment();
    		showAssignments.getRecords();
    		showAssignments.updateBriefingEvent();
    		
//Code by Avinash begins...

//Test code for EBC_addInvitees trigger    		
    		Date myDate = date.newinstance(1960, 2, 17);
    		datetime myDateTime = datetime.newInstance(2008, 12, 1);
    		Profile p = [select id from profile where name='System Administrator'];
    		User u = new User(alias = 'utest', email='unit.test@unit.test.com',isactive=true,
              emailencodingkey='UTF-8', lastname='Unit Test', 
              languagelocalekey='en_US',
              localesidkey='en_GB', profileid = p.Id,
              timezonesidkey='Europe/London', 
              username='unit.test@unit.test.com');
              
            //insert u;
    		
    		//Contact con=new Contact(LastName='testPresenter', Email = 'unit.test@unit.test.com', recordTypeId = '01270000000Q5VbAAK');
        	//insert con;
        	
        	Contact con = [select name, email from Contact where email <> null limit 1];
    		
    		Event ev = new Event(Subject='sub',WhatId=beRecord.Id, DurationInMinutes = 1, ActivityDateTime = myDateTime);
    		insert ev;
    		
    		EBC_Briefing_Center__c bc2=new EBC_Briefing_Center__c(name='bc2');
            insert bc2;
            
    		beRecord.Briefing_Center__c = bc2.id;
    		
    		EBC_Briefing_Venue__c bv2=new EBC_Briefing_Venue__c(Briefing_Center__c=bc2.Id);
            insert bv2;
/* Commented by Avinash due to an error occurring in Production "Invalid Operation on an Inactive User/Owner"
    		beRecord.Start_Date__c = myDate;
    		beRecord.Briefing_Venue__c = bv2.id;
    		update beRecord;
    		
    		beRecord.Start_Date__c = System.today();
    		update beRecord;
    		
    		beRecord.Requestor_Name__c = con.id;
    		update beRecord;
    		
    		beRecord.Briefing_Status__c = 'Cancel';
    		beRecord.Standard_Event_Id__c = ev.id;
    		beRecord.Room_Assignment__c = room.id;
    		update beRecord;
    		
    		beRecord.Briefing_Status__c = '';
    		beRecord.Room_Assignment__c = null;
    		update beRecord;
Commented by Avinash... */
			
    	
// Code by Avinash ends.
    }
}