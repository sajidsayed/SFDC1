/*=====================================================================================================+
|  HISTORY  |
|  DATE          DEVELOPER               WR         DESCRIPTION
|   ====          =========               ==         =========== 
|	Test class name                                  BookingOperations_TC
|	28-Jan-12     krishna pydavula       223453      This class is used to Share the Booking object records and 
|													 handle the exceptions while records are create/edit from the Informatica.
+=====================================================================================================*/   

public class BookingOperations {
	
	 /* @Method <PopulateShareRecord(): Method to populate the Booking share record based on District Manager field> 
        @param - <void>
        @throws exception - <Handeled exceptions>
     */	
     
 public void PopulateShareRecord(List<Booking__c> bookings)
	{
		List<Booking__share> bookingshare=new List<Booking__share>();
		
			for(Booking__c bookingsrec: bookings)
			{
				Booking__share bookshare=new Booking__share();
				bookshare.ParentId=bookingsrec.id;
				bookshare.UserOrGroupId =bookingsrec.District_Manager__c;
				bookshare.AccessLevel='Read';
				bookingshare.add(bookshare);	
			}
			Database.UpsertResult[] sr= Database.upsert(bookingshare,false);
		
		
	}
		
	/* @Method <PopulateRelatedAccount(): Method to populate the Account based on Party Number > 
        @param - <void>
        @throws exception - <Handeled exceptions>
     */
	
	 public void PopulateRelatedAccount(List<Account> acc)
	 {
	 	Map<String,Account> mappartynumbers=new Map<String,Account>() ;
	 	for(Account a:acc)
	 	{
	 		mappartynumbers.put(a.Party_Number__c,a);
	 	}
	 	
	 	List<Booking__c> bookingacc=[select id,name,Account__c,Party_Number_Text__c from Booking__c where Party_Number_Text__c in:mappartynumbers.keyset()];
	 	if(bookingacc.size()>0 && bookingacc!=null)
	 	{
		 	for(Booking__c bookingrec:bookingacc)
		 	{
		 		Account accparty=mappartynumbers.get(bookingrec.Party_Number_Text__c);
		 		if(bookingrec.Party_Number_Text__c==accparty.Party_Number__c)
		 		{
		 			bookingrec.Account__c=accparty.id;
		 		}
		 	}	
	 	} 	
	 	Database.SaveResult[] sr= Database.update(bookingacc,false);
	 }
	 
	 /* @Method <PopulateRelatedDistrict(): Method to populate the Districtlookup based on OracleDistrictID > 
        @param - <void>
        @throws exception - <Handeled exceptions>
     */
     
	  public void PopulateRelatedDistrict(List<District_Lookup__c> disrict)
	  {
		Map<String,District_Lookup__c> mapOracleids=new Map<String,District_Lookup__c>() ;
	 	for(District_Lookup__c d:disrict)
	 		{
	 			mapOracleids.put(d.Oracle_District_ID__c,d);
	 		}
	 	
	 	List<Booking__c> bookingdist=[select id,name,Booking_District__c,Oracle_District_ID_Text__c from Booking__c where Oracle_District_ID_Text__c in:mapOracleids.keyset()];
	 	if(bookingdist.size()>0 && bookingdist!=null)
	 	{
		 	for(Booking__c bookingrec:bookingdist)
		 	{
		 		District_Lookup__c distioracleid=mapOracleids.get(bookingrec.Oracle_District_ID_Text__c);
		 		if(bookingrec.Oracle_District_ID_Text__c==distioracleid.Oracle_District_ID__c)
		 		{
		 			bookingrec.Booking_District__c=distioracleid.id;
		 		}
		 	}	
	 	} 	
	 	Database.SaveResult[] sr= Database.update(bookingdist,false);
				  		
	  } 
	  
	  /* @Method <CheckRelatedAccount(): Method to check the populated related account is correct or not based on Party Number > 
        @param - <void>
        @throws exception - <Handeled exceptions>
     */
	   public void CheckRelatedAccount(List<Booking__c> bookings,set<String> partyids,set<Id> accids)
	   {
	   		Map<String,Account> mappartynumber=new Map<String,Account>();
	   		Map<Id,Account> mappartyids=new Map<Id,Account>();
	   		List<Account> relateacc=[select id,name,Party_Number__c from account where id IN:accids];
	   		
	   		List<Account> acc=[select id,name,Party_Number__c from account where Party_Number__c IN:partyids];
	   		
	   		List<Booking__c> updatebookrec=[select id,name,Account__c,Party_Number_Text__c from Booking__c where id IN:bookings];
	   		
	   		if(acc.size()>0 && acc!=null)
	   		{
		  		for(Account a:acc)
		   		{
		   			mappartynumber.put(a.Party_Number__c,a);
		   		} 
	   		}
	   		if(relateacc.size()>0 && relateacc!=null)
	   		{
		  		for(Account a:relateacc)
		   		{
		   			mappartyids.put(a.id,a);
		   		} 
	   		}
	   		for(Booking__c booking:updatebookrec)
	   		{
	   			Account bookacc=mappartyids.get(booking.Account__c);
	   			
	   			if(bookacc!=null)
	   			{	
				if(booking.Party_Number_Text__c!=bookacc.Party_Number__c)
				{
					Account a=mappartynumber.get(booking.Party_Number_Text__c);
					
					if(a!=null)
					{
						booking.Account__c=a.id;
						
					}
				}
	   			}	   			
	   		}
	   		
	   		Database.SaveResult[] sr= Database.update(updatebookrec,false);
	   	
	   }
	   
	
}