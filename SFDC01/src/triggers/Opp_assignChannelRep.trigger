/*========================================================================================================================+
 |  HISTORY                                                                  
 |                                                                           
 |  DATE            DEVELOPER       WR/Req      DESCRIPTION                               
 |  ====            =========       ======      ===========          
 |  14.07.2010      Anand Sharma                This trigger will be called on insertion and updation of Opportunity 
                                                to assign Channel reps.
 |  21.10.2010      Anand Sharma                Added variable "isChannelVisibilityExecuted" to handle recurrsive call                                              
 |  20.10.2010      Shipra Misra                Updated code to work for Both EMC and ESG in single file.
 |  22.11.2010      Shipra Misra                Optimization of code to remove Too many Script Exception.
 |  21.02.2011      Shipra Misra                Worked for March release.
 |  12.05.2011      Shipra Misra                Worked for Jun release.Changes for including service provider field.
 |  07.06.2011      Shipra Misra                Worked for July release.Enable OAR to Fire when Opportunity is Owned by House Account.
 |  10.10.2011      Shipra Misra                Worked for November release.Updated Alliance functionality on the Opportunity.
    22/01/2011      Accenture                   Updated trigger to incorporate ByPass Logic
 |                                              NOTE: Please write all the code after BYPASS Logic
 +=========================================================================================================================*/

trigger Opp_assignChannelRep   on Opportunity (after insert, after update,before update)

{
  //Trigger BYPASS Logic
  if(CustomSettingBypassLogic__c.getInstance()!=null){
      if(CustomSettingBypassLogic__c.getInstance().By_Pass_Opportunity_Triggers__c){
                return;
      }
   }
    
    Set<String> oppIdSet=new Set<String>();
    Map<Id,Id> tierPartnerMap=new Map<Id,Id>();
    Map<Id,Id> tier2PartnerStringMap=new Map<Id,Id>();
    Map<Id,Id> mapPrimaryAllaincePartnerMap=new Map<Id,String>();
    Map<Id,Id> mapSecondaryAllaincePartnerMap=new Map<Id,String>();
    Map<id,Id> serviceProviderPartnerMap = new Map<id,Id>();
    boolean isUpdate;
    
    if(!Util.isChannelVisibilityExecuted)
    {       
        Util.isChannelVisibilityExecuted = true;        
        if(trigger.isInsert && trigger.isAfter)
        {
            isUpdate = false;
            for(Opportunity opp:trigger.new)
            {
                if(opp.Sales_Force__c !=null)
                {
                    if(opp.Partner__c !=null)
                    {
                        oppIdSet.add(opp.Id);
                        tierPartnerMap.put(opp.Id, opp.Partner__c);
                    }
                    if(opp.Tier_2_Partner__c !=null)
                    {
                        oppIdSet.add(opp.Id);
                        tier2PartnerStringMap.put(opp.Id, opp.Tier_2_Partner__c);
                    }
                    if(opp.Primary_Alliance_Partner__c!=null)
                    {
                        oppIdSet.add(opp.Id);
                        mapPrimaryAllaincePartnerMap.put(opp.Id, opp.Primary_Alliance_Partner__c);
                    }
                    if(opp.Secondary_Alliance_Partner__c!=null)
                    {
                        oppIdSet.add(opp.Id);
                        mapSecondaryAllaincePartnerMap.put(opp.Id, opp.Secondary_Alliance_Partner__c);
                    }
                    if(opp.Service_Provider__c!=null)
                    {
                        oppIdSet.add(opp.Id);
                        serviceProviderPartnerMap.put(opp.Id, opp.Service_Provider__c);
                    }
                }
            }
        }
        else if(trigger.isUpdate && trigger.isAfter)
        {
            isUpdate = true;
            System.debug('**Came inside is Update**'+isUpdate);
            for(Id newOppId: Trigger.newMap.keySet())
            {
                Opportunity newOpportunity = Trigger.newMap.get(newOppId);
                Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);
                System.debug('++++Update Entered++++'+newOpportunity+'**oldOpportunity**'+oldOpportunity);
                //If any of the partner is changed and The account Owner is not "House Account"                                            
                if( newOpportunity.Partner__c!=oldOpportunity.Partner__c )
                {
                  oppIdSet.add(newOpportunity.Id);
                  tierPartnerMap.put(newOpportunity.Id, oldOpportunity.Partner__c);
                  System.debug('**tierPartnerMap**--->'+tierPartnerMap);
                }
                if(newOpportunity.Tier_2_Partner__c!=oldOpportunity.Tier_2_Partner__c )
                {
                    oppIdSet.add(newOpportunity.Id);
                    tier2PartnerStringMap.put(newOpportunity.Id, oldOpportunity.Tier_2_Partner__c);
                    System.debug('**tier2PartnerStringMap**--->'+tier2PartnerStringMap);
                } 
                if(newOpportunity.Primary_Alliance_Partner__c!=oldOpportunity.Primary_Alliance_Partner__c  )
                {
                    oppIdSet.add(newOpportunity.Id);
                    mapPrimaryAllaincePartnerMap.put(newOpportunity.Id,oldOpportunity.Primary_Alliance_Partner__c);
                    System.debug('**mapPrimaryAllaincePartnerMap**--->PRIMARY'+mapPrimaryAllaincePartnerMap);
                }
                if(newOpportunity.Secondary_Alliance_Partner__c!= oldOpportunity.Secondary_Alliance_Partner__c  )
                {
                    oppIdSet.add(newOpportunity.Id);
                    mapSecondaryAllaincePartnerMap.put(newOpportunity.Id,oldOpportunity.Secondary_Alliance_Partner__c);
                    System.debug('**mapSecondaryAllaincePartnerMap**---> PRIMARY'+mapSecondaryAllaincePartnerMap);
                }
                if(newOpportunity.Service_Provider__c != oldOpportunity.Service_Provider__c )
                {
                    oppIdSet.add(newOpportunity.Id);
                    serviceProviderPartnerMap.put(newOpportunity.Id,oldOpportunity.Service_Provider__c);
                    System.debug('**serviceProviderPartnerMap**--->'+serviceProviderPartnerMap);
                }
                System.debug('SCRIPT QUERY STATEMENTS EXECUTED :  '+Limits.getAggregateQueries()); 
                System.debug('newOpportunity.OwnerId!=oldOpportunity.OwnerId===>'+newOpportunity.OwnerId+'******'+oldOpportunity.OwnerId);
                System.debug('newOpportunity.OwnerId!=oldOpportunity.OwnerId===>'+newOpportunity.Opportunity_owner__c+'******'+oldOpportunity.Opportunity_Owner__c);    
            
            }
        }
        else if(trigger.isUpdate && trigger.isBefore)
        {
            isUpdate = true;
            System.debug('**Came inside is Update BEFORE UPDATE**'+isUpdate);
            for(Id newOppId: Trigger.newMap.keySet())
            {
                Opportunity newOpportunity = Trigger.newMap.get(newOppId);
                Opportunity oldOpportunity = Trigger.oldMap.get(newOppId);
                System.debug('++++Update Entered++++'+newOpportunity+'**oldOpportunity**'+oldOpportunity);
                System.debug('newOpportunity.OwnerId!=oldOpportunity.OwnerId===>On Before UPDATE1--->'+newOpportunity.OwnerId+'******'+oldOpportunity.OwnerId);
                System.debug('newOpportunity.OwnerId!=oldOpportunity.Opportunity Owner===>On Before UPDATE1--->'+newOpportunity.Opportunity_owner__c+'******'+oldOpportunity.Opportunity_Owner__c); 
                if((newOpportunity.OwnerId!=oldOpportunity.OwnerId || newOpportunity.opportunity_owner__c!=oldOpportunity.opportunity_owner__c) && 
                    (oldOpportunity.Partner__c!=null || oldOpportunity.Tier_2_Partner__c!=null || oldOpportunity.Primary_Alliance_Partner__c!=null || 
                    oldOpportunity.Secondary_Alliance_Partner__c!=null || oldOpportunity.Service_Provider__c!=null) )
                {
                    System.debug('newOpportunity.OwnerId!=oldOpportunity.OwnerId===>On Before UPDATE--->'+newOpportunity.OwnerId+'******'+oldOpportunity.OwnerId);
                    System.debug('newOpportunity.OwnerId!=oldOpportunity.Opportunity Owner===>On Before UPDATE--->'+newOpportunity.Opportunity_owner__c+'******'+oldOpportunity.Opportunity_Owner__c);  
                    oppIdSet.add(newOpportunity.Id);
                    System.debug('***THE VALUE OF OPPORTUNITY ID IS***==='+newOpportunity.Id);
                    tierPartnerMap.put(newOpportunity.Id, oldOpportunity.Partner__c);
                    tier2PartnerStringMap.put(newOpportunity.Id, oldOpportunity.Tier_2_Partner__c);
                    mapPrimaryAllaincePartnerMap.put(newOpportunity.Id,oldOpportunity.Primary_Alliance_Partner__c);
                    mapSecondaryAllaincePartnerMap.put(newOpportunity.Id,oldOpportunity.Secondary_Alliance_Partner__c);
                    serviceProviderPartnerMap.put(newOpportunity.Id,oldOpportunity.Service_Provider__c);
                }
                else
                {
                    Util.isChannelVisibilityExecuted=false;
                }
                System.debug('SCRIPT QUERY STATEMENTS EXECUTED :  '+Limits.getAggregateQueries()); 
                
            }
            
        } 
        System.debug('SCRIPT QUERY STATEMENTS EXECUTED :  '+Limits.getAggregateQueries()+'oppIdSet.size()====>'+oppIdSet.size()); 
        if(oppIdSet.size()>0)
        {
            /* calling the Future method to run the functionality to handle/increase governer limit
            * Parameters:- Opportunity Id, Old Tier 1, Old tier 2, old Tier 2(string)
            *          globalAlliance and technologyAlliance.
            */
            System.debug('***OPPORTUNITY IN SET***==='+oppIdSet);
            Opp_assignChannelRep.AsynchAssignchannelRepsForEMC(oppIdSet,tierPartnerMap, tier2PartnerStringMap ,
                                             mapPrimaryAllaincePartnerMap,mapSecondaryAllaincePartnerMap,serviceProviderPartnerMap, isUpdate );
             
        }
        
    }
  }