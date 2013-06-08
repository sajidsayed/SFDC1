/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
|   ====          =========               ==         =========== 
|	 
|	05-FEB-13     krishna pydavula       223453      This test class is used to coverage the code for "BookingOpertations"
|   												 and Triggers on Booking object .	
+=====================================================================================================*/
@IsTest(seealldata=true)
private class BookingOperations_TC {
	
	static testMethod void BookingUnittest()
	{
		User sysadmin = [Select id,Profileid from User where isActive=true and profile.Name='System Administrator' limit 1];
		Profile prof=[select id from Profile where id=:sysadmin.Profileid limit 1];
		List<BookingPermission__c> bookper=new List<BookingPermission__c>();
		BookingPermission__c booper1=new BookingPermission__c();
		booper1.name=prof.id;
		bookper.add(booper1);
		Database.upsert (bookper,false);
		
		User u = [Select id from User where isActive=true and profile.Name='System Administrator - API Only' limit 1];
		User insertuser = [Select id from User where isActive=true and profile.Name='EMEA Commercial User' and UserRole.name like '%DM' limit 1];
		system.runAs(u)
     	{
     	List<Booking__c> bookings=new List<Booking__c>();	
     	List<District_Lookup__c> districts=new List<District_Lookup__c>();
     	List<Account> bookacc=new List<Account>();
     	set<Id> accids=new set<Id>();
     	set<string> partyids=new set<string>();
     	
		Account Acc = new Account();
    	Acc.Name='ARROW ENTERPRISE COMPUTING SOLUTIONS,INC';
    	acc.Party_Number__c='1213456EMC';	
     	insert acc;  
     	accids.add(acc.id);
     	bookacc.add(Acc);
     	
     	AccountShare a=new AccountShare();
     	a.AccountId=acc.id;
     	a.UserOrGroupId=insertuser.id;	
     	a.AccountAccessLevel='Read';
     	a.OpportunityAccessLevel='Read';
     	insert a;
     	
     	Booking__c book=new Booking__c();
     	book.Account__c=acc.Id;
     	book.Booking_Status__c='Eval';
     	book.Sales_Order__c='54555';
     	book.Party_Number_Text__c='1213456EMC';
     	book.Oracle_District_ID_Text__c='12345678EMC';
     	book.District_Manager__c=insertuser.id;
     	book.Reporting_Date__c=system.today();
     	book.Revenue__c=233333;
     	insert book;
     	book.Party_Number_Text__c='1213456EMC1';
     	update book;
     	bookings.add(book);
     	partyids.add(book.Party_Number_Text__c);
     	
     	Booking__share bookshare=new Booking__share();
     	bookshare.ParentId=book.id;
     	bookshare.UserOrGroupId=book.District_Manager__c;
     	bookshare.AccessLevel='Read';
     	insert bookshare;
     	
     	District_Lookup__c disrict=new District_Lookup__c();
     	disrict.name='Test for booking';
     	disrict.Oracle_District_ID__c='12345678EMC';
     	districts.add(disrict);
     	insert districts;
     	
     	delete book;
		BookingOperations opts=new BookingOperations();
		opts.PopulateShareRecord(bookings);
		opts.PopulateRelatedAccount(bookacc);
		opts.PopulateRelatedDistrict(districts);
		opts.CheckRelatedAccount(bookings,partyids,accids);
		
     	}
	}

}