/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER         WR                DESCRIPTION                               
 |  ====       =========         ==                =========== 
 |  1-JUN-10  Devi Prasad Bal  Initial Creation.  This class contains methods which help in getting the
 |													briefing event information on the briefing food option
 |													page and also defaults the date to the start date of 
 |													the briefing event.
 |  6-AUG-1-  Devi Prasad Bal  143152             Fixed the code to set the update block of the code work properly.
 +===========================================================================*/

public class EBC_Food_Options {
	
	public String bEventId; // to hold the briefing event record id of the associated briefing event 
	public EBC_Briefing_Event__c objBEvent {get;set;} // to hold the briefing event object record
	public Briefing_Food_Options__c bfo {get; set;} // to hold the briefing food option object record 
	
	public EBC_Food_Options(ApexPages.StandardController stdController)
	{
		bEventId = ApexPages.currentPage().getParameters().get('retURL'); // retrieve the briefing event record id of the associated briefing event
    	Id bfoId = stdController.getId(); // retrieve the briefing food option record id
    	if(bfoId == null) // the following block of code will work in case a new briefing food option record is being created
    	{
    		if(bEventId!=null)
			{
				bEventId=bEventId.replace('/','');
			
	            bfo = new Briefing_Food_Options__c();
	            
	            bfo.Briefing_Event__c=bEventId;
				bfo.Name='';
				bfo.Breakfast_Options__c='-None-';
				bfo.Lunch_Options__c='-None-';
				bfo.Special_Diet_Needs__c=false;
				bfo.Special_Diet_Needs_Notes__c='';
			}	
    	}
    	else // the following block of code will work in case of updating an existing briefing food option record 
    	{
    		List<Briefing_Food_Options__c> lstbfo=[Select  Id, Name,Breakfast_Options__c,Lunch_Options__c,Special_Diet_Needs__c, Briefing_Event__c, 
	                     Special_Diet_Needs_Notes__c,Date__c from Briefing_Food_Options__c where id =: bfoId Limit 1];	

			if(lstbfo.size()==1)
			{
				this.bfo = lstbfo[0]; // WR#143152
				bEventId = lstbfo[0].Briefing_Event__c;
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Please contact your system administrator.'));	
			}

    	}  
    	
		objBEvent=[Select   Id, Name, Start_Date__c, End_Date__c From EBC_Briefing_Event__c where Id=:bEventId];               
		if(bfoId == null)
    	{
    			bfo.Date__c=objBEvent.Start_Date__c; // default the start date of the briefing food option to start date of associated briefing event when a new briefing food option is being created
    	}
		
	}
	
	// method invoked on click of save button on the visualforce page
	public PageReference bfoSave()
    {
		try
		{	
			if(bEventId!=null)
			{
				List<Briefing_Food_Options__c> bfo_list = [Select Id, Date__c from Briefing_Food_Options__c where Briefing_Event__c =: bEventId];
				for(Briefing_Food_Options__c b: bfo_list)
				{
					if(b.Date__c == bfo.Date__c && b.Id != bfo.Id)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Please check.There is an existing briefing food option for the briefing event with the same date as chosen here.'));
						return null;	
					}  
				}
			}
						
			upsert bfo;
			return pageRedirect();
		}
		
		catch(DMLException e)
        {
			String errMg = '' + e;

			if(errMg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) // the following block of code will work when a validation rule fails
			{
				//Integer len1 = 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length();
				//Integer len2 = errMg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION',0) + len1 + 2;
				//Integer len3 = errMg.length();
				errMg = errMg.substring(errMg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION',0) + 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length() + 2,errMg.length()-4); 

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , '' + errMg));	
				return null;
			}
			else // this block of code will work in case of DML exception other than failure of validation rules
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , '' + errMg));
				return null;
			}
			
        }
		catch(Exception e)
        {
			System.debug('the exception is' +e);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR , '' + e));
			return null;
        }
		
	}
	
	// code to return to the briefing event detail page
	public PageReference pageRedirect()
    { 
        PageReference pageRef = new PageReference('/' + bEventId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}