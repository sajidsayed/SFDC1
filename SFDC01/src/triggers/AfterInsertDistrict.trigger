/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
|  ====          =========               ==         =========== 
| Testclass name								   BookingOperations_TC
| 29-Jan-12     krishna pydavula       223453      To populate the district lookup field on Booking object.
|   
+=====================================================================================================*/   
trigger AfterInsertDistrict on District_Lookup__c (after insert) {

List<District_Lookup__c> district=new List<District_Lookup__c> ();
	for(District_Lookup__c disti:trigger.new)
	{
		district.add(disti);
	}
try{	
	BookingOperations bookopts=new BookingOperations();
	bookopts.PopulateRelatedDistrict(district);
  }catch(Exception e)
  {
  	system.debug('----------Exception-------------'+e);
  }
}