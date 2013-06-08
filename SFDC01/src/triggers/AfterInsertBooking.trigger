/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
|  ====          =========               ==         =========== 
| Testclass name								   BookingOperations_TC
| 29-Jan-12     krishna pydavula       223453      Booking Opertations
|   
+=====================================================================================================*/   
trigger AfterInsertBooking on Booking__c (after insert, after update) {
	
	BookingOperations bookopts=new BookingOperations();
	List<Booking__c> bookingshare=new List<Booking__c>();
	List<Booking__c> bookingaccnew=new List<Booking__c>();
	List<Booking__c> bookingaccold=new List<Booking__c>();
	set<Id> accids=new set<Id>(); 
	set<String> partyids=new set<String>();
	
	if(Trigger.IsInsert)
	{
		   for(Booking__c booking:trigger.new)
		    {
		  		if(booking.District_Manager__c!=null)
		  		{
		  			bookingshare.add(booking);		
		  		}
		  		
		  		if(booking.Account__c!=null)
		  		{
			  		accids.add(booking.Account__c);
		  		}
		  		if(booking.Party_Number_Text__c!=null) 
		  		{
		  			bookingaccnew.add(booking);
		  			partyids.add(booking.Party_Number_Text__c);
		  		}
		  	
			}
		try{
			if(bookingaccnew.size()>0 && bookingaccnew!=null)
			{
				bookopts.CheckRelatedAccount(bookingaccnew,partyids,accids);
			}
			
			if(bookingshare.size()>0 && bookingshare!=null)
			{		 
				bookopts.populatesharerecord(bookingshare);		
			} 
		}
		catch(Exception e)
		{
			system.debug('--------Exception----------------'+e);
		}
	   }
	if(Trigger.IsUpdate)
	{
		for(Booking__c booking:trigger.new)
		{
			if(booking.Party_Number_Text__c != Trigger.oldMap.get(booking.id).Party_Number_Text__c && booking.Party_Number_Text__c!=null)
	  		{
	  			bookingaccold.add(booking);
	  			partyids.add(booking.Party_Number_Text__c);
	  			accids.add(booking.Account__c);
	  		}
	  		
	  		if(booking.Account__c!=Trigger.oldMap.get(booking.id).Account__c && booking.Account__c!=null)
	  		{
	  			accids.add(booking.Account__c);
	  		}
	  		if(booking.District_Manager__c!=null)
		  	{
		  		bookingshare.add(booking);		
		  	}
		}
		try
	 {	
		if(bookingaccold.size()>0 && bookingaccold!=null)
		{
			bookopts.CheckRelatedAccount(bookingaccold,partyids,accids);
		}
		if(bookingshare.size()>0 && bookingshare!=null)
		{		 
			bookopts.populatesharerecord(bookingshare);		
		} 
	 }
	 catch(Exception e)
	 {
	 	system.debug('---------Exception---------------'+e);
	 }	
	}
}