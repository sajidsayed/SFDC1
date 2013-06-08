/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
|  ====          =========               ==         =========== 
|Testclass name									   BookingOperations_TC
| 29-Jan-12     krishna pydavula       223453      To Validate the system admin profiles.
|   
+=====================================================================================================*/  

trigger BeforeUpdateBooking on Booking__c (before delete, before insert) {
	
	Map<string,BookingPermission__c> bookingProfileid= BookingPermission__c.getAll();
	string standProfiled=userinfo.getProfileId();
	if (Trigger.IsInsert) {
		
		for(Booking__c booking:trigger.new)
		{
			if(bookingProfileid.containskey(standProfiled))
			{
				booking.addError(System.Label.Booking_Validation); 
			}
		
		}	
	}
	if (Trigger.IsDelete) {
		
		for(Booking__c booking:trigger.Old)
		{
			if(bookingProfileid.containskey(standProfiled))
			{
				booking.addError(System.Label.Booking_Validation);
			}
		
		}	
	}

}