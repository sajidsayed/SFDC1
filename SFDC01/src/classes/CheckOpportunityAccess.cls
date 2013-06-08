/*===========================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE       DEVELOPER     DESCRIPTION                               
 |  ====       =========     =========== 
 |  xx-xx-xx   xxxx          Initial Creation
 |	16-Dec-10 Shipra Misra   Updated code to add custom Setting for WR 151992
 |	18-Feb-11 Srinivas N     WR 159448    
+===========================================================================*/

public with sharing class CheckOpportunityAccess
{
	Boolean NoOpptyAccess=false;//{get;set;}
	
	public boolean checkOppAcces(String OpptyId)
	{
	    //NoOpptyAccess = false;
	    Opportunity objAccess;
	    Savepoint sp = Database.setSavepoint();
	    try
	    {
	        util.CheckOpportunityAccess=false;
	        objAccess = [Select Opportunity_Owner__r.Forecast_Group__c,o.Edit_Access__c, o.Id from Opportunity o where id=:OpptyId];
	        objAccess.Edit_Access__c = 'test';
	        //Changed for WR 159448 removing message from Add Sales team/splits page , Updating Opportunity by passing validation and Again updating with validation
	        objAccess.bypass_validation__c = true;
	        System.debug('In Try'); 
	        update objAccess;
	       	Database.rollback(sp);
	    }
	    catch(Exception ex1)
	    {
			System.debug('In Catch'); 
			System.debug('Exception----->'+ex1); 
			if((ex1.getmessage()).indexof('INSUFFICIENT_ACCESS_OR_READONLY')!=-1)
			{
				ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Error, 'INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id:');
				ApexPages.addMessage(myMsg1);
				System.debug('Oppty access exception----->'+ex1);    
				NoOpptyAccess = true;
			}
			else
	  	   	{ 
	            //Added by Shipra for new IIG Forecast Groups
	            Map<String,Special_Forecast_Groups__c>  mapSpecialForecastGroups = Special_Forecast_Groups__c.getAll();
	            //if(objAccess.Opportunity_Owner__r.Forecast_Group__c=='Direct' || objAccess.Opportunity_Owner__r.Forecast_Group__c=='Maintenance Renewals' )
	            if(mapSpecialForecastGroups.containsKey(objAccess.Opportunity_Owner__r.Forecast_Group__c) && mapSpecialForecastGroups.get(objAccess.Opportunity_Owner__r.Forecast_Group__c).Ownership_Allowed__c)
	            {
	              //Show error message oly when validation error is on the top of the page not on field
		          if(ex1.getMessage().indexof('[]')!=-1)
		          {   
		            Integer start_index=ex1.getMessage().indexof(',');
		            Integer end_index=ex1.getMessage().lastIndexof(':');
		            System.debug('end_index   '+end_index);
					ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error, ex1.getMessage().substring(start_index+1,end_index));
	                ApexPages.addMessage(myMsg2);
		          }
	              NoOpptyAccess = true;
	            }
      		}
		}
	    System.debug('Access----->'+NoOpptyAccess );      
	    return NoOpptyAccess;
    }
}