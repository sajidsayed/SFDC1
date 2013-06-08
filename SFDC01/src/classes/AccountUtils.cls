/*=============================================================================
    HISTORY                                                                  
                                                               
    DATE            DEVELOPER                WR             DESCRIPTION                               
    ====            =========                ==             =========== 
    24-Aug-2011     Srinivas Nallapati      174234          Fix "Insufficent Privileges" error on Opportunity. 
                                                            When User lost access to some Account record which they previously might be having and 
                                                            they select same account on opportunity (may be form recently viewed items), they strat receiving 'Insifficent priviledges' error.      
    14.10.2011      Shipra Misra            173695          Worked for Nov release.Introduction new allaince partner & deleting existing  & Outsourcer field.
    29-Mar-2013    Uday Annapareddy         246616          Modified CheckAccountAccess to reduce SOQL exception.
==============================================================================*/
public with sharing class AccountUtils 
{
    public static Map<id,Account> mapaccRecordPartner;
    public static set<id> setOldPartnerIDs = new set<id>();
    /* uday
     This Method is used to check the partner account access.
     Modified the flow that we check the access only when the partner account is changed again dynamically.
    */
    public map<id,Account> CheckAccountAccess(set<id> setAccountIDs)
    {
    	boolean isNotFound = false;
    	//mapaccRecordPartner check whether the partner changed or not.
        if(mapaccRecordPartner != null){
        	//to avoid execution of below query when same set of partnerAccountIds(setAccountIDs) are passed from CheckUserAccessForPartnerAccountsOnOpportunity
        	if(!setOldPartnerIDs.ContainsAll(setAccountIDs)){  
        			isNotFound = true;
        		}
        }
        if(isNotFound || mapaccRecordPartner ==null){
        	mapaccRecordPartner= new Map<id,Account>([Select id,Theater1__c,BillingCountry from Account where id in:(setAccountIDs)]);
        	
        }
        setOldPartnerIDs.addAll(setAccountIDs);
        return mapaccRecordPartner;
    }
    
    public void CheckUserAccessForPartnerAccountsOnOpportunity(list<Opportunity> lstOpportunity)
    {
        Set<id> setPartnerIDs = new Set<id>();
        for(Opportunity op :  lstOpportunity)
        {
            if(op.partner__c != null)
               setPartnerIDs.add(op.partner__c);
            if(op.Tier_2_Partner__c != null)
               setPartnerIDs.add(op.Tier_2_Partner__c);
            if(op.Secondary_Alliance_Partner__c != null)
               setPartnerIDs.add(op.Secondary_Alliance_Partner__c);
            if(op.Primary_Alliance_Partner__c != null)
               setPartnerIDs.add(op.Primary_Alliance_Partner__c);
        }
        
        if(setPartnerIDs.size() > 0)
        {
        	map<id,Account> mapPartners = new map<id,Account>();
            	mapPartners = CheckAccountAccess(setPartnerIDs);
                for(Opportunity op : lstOpportunity){
                	if(op.partner__c != null)
	                   if(!mapPartners.containskey(op.partner__c))
	                       op.partner__c.adderror(System.Label.Distributor_Direct_Reseller_Access_Error);
	                if(op.Tier_2_Partner__c != null)
	                   if(!mapPartners.containskey(op.Tier_2_Partner__c))
	                       op.Tier_2_Partner__c.adderror(System.Label.Distribution_VAR_Access_Error);
	                if(op.Secondary_Alliance_Partner__c != null)
	                   if(!mapPartners.containskey(op.Secondary_Alliance_Partner__c))
	                       op.Secondary_Alliance_Partner__c.adderror(System.Label.Alliance_Partner_Access_Error);
	                if(op.Primary_Alliance_Partner__c != null)
	                   if(!mapPartners.containskey(op.Primary_Alliance_Partner__c))
	                       op.Primary_Alliance_Partner__c.adderror(System.Label.Alliance_Partner_Access_Error);
	                
	            }
	                
        }
    }
}