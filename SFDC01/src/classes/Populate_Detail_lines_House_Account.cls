/*=====================================================================================================+

|  HISTORY  |                                                                            

|  DATE          DEVELOPER                WR            DESCRIPTION                               

|  ====          =========                ==            =========== 
  Test Class Name 									   Populate_Detail_lines_House_Acc_Sch_TC			                                                    
| 11/20/2012     Krishna Pydavula        212217        This class is used to populate the detail lines for House Account. 
                                                                                                          
+=====================================================================================================*/

global class Populate_Detail_lines_House_Account implements Database.Batchable<SObject> { 
	
public List <Opportunity> Opp=new List<Opportunity>();
public Id houseaccount = HouseAccount__c.getInstance().House_Account_User__c;
public String query;

global Populate_Detail_lines_House_Account()
	{
		Map<String,CustomSettingDataValueMap__c>  mapDataValueMap = CustomSettingDataValueMap__c.getAll();
		Integer querylimit =Integer.valueof( mapDataValueMap.get('Oppty query limit').datavalue__c);
		if(querylimit>0)
		{
		Period Currentquarter = [Select EndDate,StartDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
		Opp=[SELECT ID,Account_Oppty__c, Account_Address__c, Account_Flag__c, AccountId, Account_Name1__c, Account_Number__c, Account_Opportunity_Owner_District__c, OwnerId, Opportunity_Owner__c, Account_Owner_Region__c, Account_Owner_Area__c, Account_Owner_BU_Attribute__c, Account_Owner_Country__c, Account_Owner_District__c, Account_Owner_Division__c, Account_Owner_Forecast_Group__c, Account_Owner_Super_Area__c, Account_Owner_Theater__c, Account_TheaterText__c  FROM Opportunity  where 
		OwnerId =:houseaccount and ((StageName in('Pipeline','Upside','Strong Upside','Commit'))OR((StageName in('Submitted', 'Eval', 'Booked', 'Won') and (CloseDate >=: Currentquarter.StartDate and CloseDate <=:Currentquarter.EndDate)))) and Amount > 0
				and id not in( select Opportunity__c from Detail_Line__c) limit :querylimit];
		}	
	}

final static String DEFAULT_QUERY =' select Id,OpportunityId,PricebookEntry.Product2Id,UnitPrice,Opportunity.CurrencyIsoCode,Quote_Amount__c from OpportunityLineItem where OpportunityId in:Opp';
	      
	global database.querylocator start(Database.BatchableContext BC) 
   {        
   	  	 
        if (query == null || query.length() == 0)
            { 
                query = DEFAULT_QUERY; 
            }
                 
        return Database.getQueryLocator(query); 
   }
   global void execute(Database.BatchableContext BC,List<SObject> scope) 
    {  	
    	
    	List<OpportunityLineItem> lineitemprod =(OpportunityLineItem[]) scope;
    	List<Detail_Line__c> deatillines =new List<Detail_Line__c>();
    	if(lineitemprod.size()>0)
    	{
    		
    		for(OpportunityLineItem opptyProduct:lineitemprod)
    		{
    			 Detail_Line__c details=new Detail_Line__c();
    			 details.Opportunity__c=opptyProduct.OpportunityId;
    			 system.debug('----Opportunity Id-----------'+opptyProduct.OpportunityId);
                 details.Forecast_Group__c='House Account';
                 details.Split__c=100.0;
                 details.Direct_Amount__c=opptyProduct.UnitPrice;
                 details.Opportunity_Product__c=opptyProduct.Id;
                 details.OpportunityTeamMember__c=houseaccount;
                 details.OwnerId=houseaccount;
                 details.Owner__c=houseaccount;
                 details.Product__c=opptyProduct.PricebookEntry.Product2Id;
                 details.Quote_Amount__c=opptyProduct.Quote_Amount__c;
                 details.CurrencyIsoCode=opptyProduct.opportunity.CurrencyIsoCode;	
    			 deatillines.add(details);						 
    		} 
    	}
    	if(deatillines.size()>0)
    	{
    		
    		try{
    			Database.Saveresult[] results=Database.insert(deatillines,false);	
    		}
    		catch(Exception ex)
    		{
    			system.debug('----Exception----'+ex);
    		}
    	}
    	
    }
    global void finish(Database.BatchableContext BC)
          { //We don't need to do anything.
          }

}