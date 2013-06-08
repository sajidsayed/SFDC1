/*===================================================================================================================================

History 
20th June 11  Prasad Kothawade    Class to handle some DML updates from opportunity triggers 
29th June 11  Ashwini Gowda		  Added Fix for overcoming recursive call.	 
====================================================================================================================================*/
public class PRM_OpportunityOperations{
	
    public static Boolean isDealregUpdated = true; 
    
    public void updateDealRegs(Map<Id,Opportunity> newOpportunityMap,Map<Id,Opportunity>OldOpportunityMap){
        Map<Id,Opportunity>SynergyOppMap = new Map<Id,Opportunity>();
        for(Id OppId:newOpportunityMap.KeySet()){
            if( 
                 OldOpportunityMap.get(OppId).Opportunity_Number__c != NewOpportunityMap.get(OppId).Opportunity_Number__c){
                    SynergyOppMap.put(OppId,NewOpportunityMap.get(OppId));
            }
        }
        if(SynergyOppMap.size()>0){
        	PRM_OpportunityOperations.isDealregUpdated = false;
            List<Lead> DealRegsList =[select id,Resend_Outbound_Message__c,Related_Opportunity__c from Lead where Related_Opportunity__c in :SynergyOppMap.keySet()];
            for(Lead deal:DealRegsList){
                deal.Resend_Outbound_Message__c='Synergy Opportunity No is changed-'+System.now();
            }
            update DealRegsList;           
        }
    }

}