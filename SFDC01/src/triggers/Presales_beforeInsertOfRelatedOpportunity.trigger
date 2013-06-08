/*==================================================================================================================+

|  HISTORY  |                                                                           

|  DATE          DEVELOPER                      WR        DESCRIPTION                               

|  ====          =========                      ==        =========== 
 |  01/01/2013   Srinivas Pinnamaneni         WR220748    Multiple Opportunities associated with one POC case.
 |  16May2013    Ganesh Soma                  WR264020    Poulating forecast amount of opportunity.
+==================================================================================================================**/
trigger Presales_beforeInsertOfRelatedOpportunity on Related_Opportunity__c (before insert, before update) {                               

    String strOppId = '';
    ID caseID = null;
    String strTemp = ''; 
    Set<ID> setCaseIDs = new Set<ID>(); 
    for(Related_Opportunity__c obj : trigger.new)
    {
        setCaseIDs.add(obj.Case__c); 
    }
    System.debug('SFDCDECV********setCaseIDs*******'+setCaseIDs);
    Presales_Operations objOperations = new Presales_Operations();
    // Declare MAP to store case ID and selected Opportunity ID
    Public Map<ID,String> mapCaseOppIds = objOperations.GetSelectedOppsforCase(setCaseIDs);        
    system.debug('mapCaseOppIds.size() == '+mapCaseOppIds.size());   
    //Ganesh:16May2013 - Commneted below line of code - WR264020
    //if(mapCaseOppIds == null || mapCaseOppIds.size() <= 0) return;   
    if(trigger.isInsert)
    {    
        for(Related_Opportunity__c obj : trigger.new)
        {
        	//Ganesh:16May2013 - Added below condition - WR264020
        	if(mapCaseOppIds.size()>0) 
        	{
              objOperations.CheckUniqueRelatedOpportunities(obj,mapCaseOppIds);
        	}
            // modified by wajid         
            obj.opp_forecast_amount__c = obj.forecast_amount__c;
           
        }
    }
       
    if(trigger.isUpdate)
    {
       for(Related_Opportunity__c obj : trigger.new)
       {
       	   //Ganesh:16May2013 - Added below condition - WR264020
          if(obj.Opportunity_Name__c != trigger.oldMap.get(obj.Id).Opportunity_Name__c && mapCaseOppIds.size()>0)
          {
                objOperations.CheckUniqueRelatedOpportunities(obj,mapCaseOppIds);
                 // modified by wajid
                 obj.opp_forecast_amount__c = obj.forecast_amount__c;
          }        
       }
    }
                
}